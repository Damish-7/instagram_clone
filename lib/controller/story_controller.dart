import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../model/story_model.dart';
import '../utils/api_client.dart';
import '../utils/api_constants.dart';
import '../utils/helpers.dart';

class StoryController extends GetxController {
  var storyGroups = <UserStoryGroup>[].obs;
  var isLoading   = false.obs;
  var isUploading = false.obs;
  final _storage  = GetStorage();

  @override
  void onInit() { fetchStories(); super.onInit(); }

  int get myId =>
      int.tryParse(_storage.read('user')?['id'].toString() ?? '0') ?? 0;

  Future<void> fetchStories() async {
    try {
      isLoading(true);
      final res = await ApiClient.instance.post(ApiConstants.stories,
          data: {'action': 'get_stories', 'user_id': myId});
      if (res.data['status'] == 'success') {
        final rawStories = (res.data['stories'] as List)
            .map((s) => StoryModel.fromJson(s)).toList();
        storyGroups.value = _groupByUser(rawStories);
      }
    } catch (e) {
      Helpers.showError('Failed to load stories');
    } finally {
      isLoading(false);
    }
  }

  List<UserStoryGroup> _groupByUser(List<StoryModel> stories) {
    final Map<int, List<StoryModel>> map = {};
    for (final s in stories) map.putIfAbsent(s.userId, () => []).add(s);
    return map.entries.map((e) {
      final list = e.value;
      return UserStoryGroup(
        userId: e.key,
        username: list.first.username,
        userProfilePic: list.first.userProfilePic,
        stories: list,
        allSeen: list.every((s) => s.isSeen),
      );
    }).toList();
  }

  Future<void> uploadStory() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    try {
      isUploading(true);
      final bytes     = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      final filename  = file.name.isNotEmpty ? file.name : 'story.jpg';
      final ext       = filename.split('.').last.toLowerCase();
      final mimeType  = ext == 'png' ? 'image/png' : 'image/jpeg';

      final res = await ApiClient.instance.post(ApiConstants.stories, data: {
        'action':       'create_story',
        'user_id':      myId.toString(),
        'media_type':   'image',
        'image_base64': base64Str,
        'mime_type':    mimeType,
        'filename':     filename,
      });
      if (res.data['status'] == 'success') {
        Helpers.showSuccess('Story uploaded!');
        fetchStories();
      } else {
        Helpers.showError(res.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      Helpers.showError('Story upload failed: ${e.toString()}');
    } finally {
      isUploading(false);
    }
  }

  Future<void> markSeen(int storyId) async {
    try {
      await ApiClient.instance.post(ApiConstants.stories,
          data: {'action': 'mark_seen', 'story_id': storyId, 'user_id': myId});
    } catch (_) {}
  }
}