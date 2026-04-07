import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_model.dart';
import '../model/post_model.dart';
import '../utils/api_client.dart';
import '../utils/api_constants.dart';
import '../utils/helpers.dart';

class ProfileController extends GetxController {
  var profileUser = Rxn<UserModel>();
  var userPosts   = <PostModel>[].obs;
  var isLoading   = false.obs;
  var isUpdating  = false.obs;
  final _storage  = GetStorage();

  int get myId =>
      int.tryParse(_storage.read('user')?['id'].toString() ?? '0') ?? 0;

  Future<void> loadProfile(int userId) async {
    try {
      isLoading(true);
      final res = await ApiClient.instance.post(ApiConstants.profile, data: {
        'action': 'get_profile', 'user_id': userId, 'viewer_id': myId,
      });
      if (res.data['status'] == 'success') {
        profileUser.value = UserModel.fromJson(
            Map<String, dynamic>.from(res.data['user']));
        userPosts.value = (res.data['posts'] as List)
            .map((p) => PostModel.fromJson(p)).toList();
      }
    } catch (e) {
      Helpers.showError('Failed to load profile');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateBio(String bio) async {
    try {
      isUpdating(true);
      final res = await ApiClient.instance.post(ApiConstants.profile, data: {
        'action': 'update_bio', 'user_id': myId, 'bio': bio,
      });
      if (res.data['status'] == 'success') {
        loadProfile(myId);
        Helpers.showSuccess('Bio updated!');
      }
    } catch (e) {
      Helpers.showError('Update failed');
    } finally {
      isUpdating(false);
    }
  }

  Future<void> updateProfilePic() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    try {
      isUpdating(true);
      final bytes     = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      final filename  = file.name.isNotEmpty ? file.name : 'avatar.jpg';
      final ext       = filename.split('.').last.toLowerCase();
      final mimeType  = ext == 'png' ? 'image/png' : 'image/jpeg';

      final res = await ApiClient.instance.post(ApiConstants.profile, data: {
        'action':       'update_profile_pic',
        'user_id':      myId.toString(),
        'image_base64': base64Str,
        'mime_type':    mimeType,
        'filename':     filename,
      });
      if (res.data['status'] == 'success') {
        loadProfile(myId);
        Helpers.showSuccess('Profile picture updated!');
      } else {
        Helpers.showError(res.data['message'] ?? 'Update failed');
      }
    } catch (e) {
      Helpers.showError('Update failed: ${e.toString()}');
    } finally {
      isUpdating(false);
    }
  }

  Future<void> toggleFollow(int targetUserId) async {
    final user = profileUser.value;
    if (user == null) return;
    final wasFollowing = user.isFollowing;
    try {
      await ApiClient.instance.post(ApiConstants.follow, data: {
        'action': wasFollowing ? 'unfollow' : 'follow',
        'follower_id': myId,
        'following_id': targetUserId,
      });
      loadProfile(targetUserId);
    } catch (e) {
      Helpers.showError('Action failed');
    }
  }
}