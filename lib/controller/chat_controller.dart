import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/message_model.dart';
import '../utils/api_client.dart';
import '../utils/api_constants.dart';
import '../utils/helpers.dart';

class ChatController extends GetxController {
  var chatUsers = <ChatUserModel>[].obs;
  var messages = <MessageModel>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var receiverId = 0.obs;
  var receiverName = ''.obs;
  Timer? _pollingTimer;
  final _storage = GetStorage();

  int get myId =>
      int.tryParse(_storage.read('user')?['id'].toString() ?? '0') ?? 0;

  @override
  void onInit() {
    fetchChatUsers();
    super.onInit();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  // ─── Fetch chat users list ───────────────────────────────────────
  Future<void> fetchChatUsers() async {
    try {
      isLoading(true);
      final res = await ApiClient.instance.post(
        ApiConstants.chat,
        data: {'action': 'get_chat_users', 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        chatUsers.value = (res.data['users'] as List)
            .map((u) => ChatUserModel.fromJson(u))
            .toList();
      }
    } catch (e) {
      Helpers.showError('Failed to load chats');
    } finally {
      isLoading(false);
    }
  }

  // ─── Open chat room ──────────────────────────────────────────────
  void openChat(int userId, String username) {
    receiverId.value = userId;
    receiverName.value = username;
    fetchMessages();
    _startPolling();
  }

  // ─── Fetch messages ──────────────────────────────────────────────
  Future<void> fetchMessages() async {
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.chat,
        data: {
          'action': 'get_messages',
          'user_id': myId,
          'receiver_id': receiverId.value,
        },
      );
      if (res.data['status'] == 'success') {
        messages.value = (res.data['messages'] as List)
            .map((m) => MessageModel.fromJson(m, myId))
            .toList();
      }
    } catch (_) {}
  }

  // ─── Send message ────────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    try {
      isSending(true);
      final res = await ApiClient.instance.post(
        ApiConstants.chat,
        data: {
          'action': 'send_message',
          'sender_id': myId,
          'receiver_id': receiverId.value,
          'message': text.trim(),
        },
      );
      if (res.data['status'] == 'success') {
        fetchMessages();
      }
    } catch (e) {
      Helpers.showError('Failed to send message');
    } finally {
      isSending(false);
    }
  }

  // ─── Poll every 3 seconds for new messages ───────────────────────
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => fetchMessages(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }
}