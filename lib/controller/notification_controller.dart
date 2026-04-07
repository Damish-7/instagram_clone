import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/search_model.dart';
import '../utils/api_client.dart';
import '../utils/api_constants.dart';
import '../utils/helpers.dart';

class NotificationController extends GetxController {
  var notifications  = <NotificationModel>[].obs;
  var followRequests = <FollowRequestModel>[].obs;
  var unreadCount    = 0.obs;
  var isLoading      = false.obs;
  final _storage     = GetStorage();

  @override
  void onInit() {
    fetchNotifications();
    fetchFollowRequests();
    super.onInit();
  }

  int get myId =>
      int.tryParse(_storage.read('user')?['id'].toString() ?? '0') ?? 0;

  // ─── Fetch all notifications ──────────────────────────────────
  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      final res = await ApiClient.instance.post(
        ApiConstants.follow,
        data: {'action': 'get_notifications', 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        notifications.value = (res.data['notifications'] as List)
            .map((n) => NotificationModel.fromJson(n))
            .toList();
        unreadCount.value =
            int.tryParse(res.data['unread_count'].toString()) ?? 0;
      }
    } catch (_) {} finally {
      isLoading(false);
    }
  }

  // ─── Fetch follow requests ────────────────────────────────────
  Future<void> fetchFollowRequests() async {
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.follow,
        data: {'action': 'get_requests', 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        followRequests.value = (res.data['requests'] as List)
            .map((r) => FollowRequestModel.fromJson(r))
            .toList();
      }
    } catch (_) {}
  }

  // ─── Accept request ───────────────────────────────────────────
  Future<void> acceptRequest(int followerId) async {
    try {
      await ApiClient.instance.post(ApiConstants.follow, data: {
        'action': 'accept',
        'follower_id': followerId,
        'following_id': myId,
      });
      followRequests.removeWhere((r) => r.followerId == followerId);
      fetchNotifications();
      Helpers.showSuccess('Follow request accepted');
    } catch (e) {
      Helpers.showError('Failed to accept');
    }
  }

  // ─── Reject request ───────────────────────────────────────────
  Future<void> rejectRequest(int followerId) async {
    try {
      await ApiClient.instance.post(ApiConstants.follow, data: {
        'action': 'reject',
        'follower_id': followerId,
        'following_id': myId,
      });
      followRequests.removeWhere((r) => r.followerId == followerId);
      Helpers.showSuccess('Request declined');
    } catch (e) {
      Helpers.showError('Failed to reject');
    }
  }

  // ─── Mark all read ────────────────────────────────────────────
  Future<void> markAllRead() async {
    try {
      await ApiClient.instance.post(ApiConstants.follow,
          data: {'action': 'mark_read', 'user_id': myId});
      unreadCount.value = 0;
    } catch (_) {}
  }
}