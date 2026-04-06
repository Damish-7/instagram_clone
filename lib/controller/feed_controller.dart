import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../model/post_model.dart';
import '../model/comment_model.dart';
import '../utils/api_client.dart';
import '../utils/api_constants.dart';
import '../utils/helpers.dart';

class FeedController extends GetxController {
  var posts = <PostModel>[].obs;
  var comments = <CommentModel>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;
  var isCommentsLoading = false.obs;
  final _storage = GetStorage();

  @override
  void onInit() {
    fetchPosts();
    super.onInit();
  }

  int get myId => int.tryParse(_storage.read('user')?['id'].toString() ?? '0') ?? 0;

  // ─── Fetch feed posts ────────────────────────────────────────────
  Future<void> fetchPosts() async {
    try {
      isLoading(true);
      final res = await ApiClient.instance.post(
        ApiConstants.posts,
        data: {'action': 'get_feed', 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        posts.value = (res.data['posts'] as List)
            .map((p) => PostModel.fromJson(p))
            .toList();
      }
    } catch (e) {
      Helpers.showError('Failed to load feed');
    } finally {
      isLoading(false);
    }
  }

  // ─── Like / Unlike ───────────────────────────────────────────────
  Future<void> toggleLike(int postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = posts[index];
    final wasLiked = post.isLiked;

    // Optimistic update
    posts[index] = post.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    );

    try {
      await ApiClient.instance.post(
        ApiConstants.posts,
        data: {
          'action': wasLiked ? 'unlike' : 'like',
          'post_id': postId,
          'user_id': myId,
        },
      );
    } catch (e) {
      // Revert on error
      posts[index] = post;
    }
  }

  // ─── Upload post ─────────────────────────────────────────────────
  Future<void> uploadPost(String caption) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    try {
      isUploading(true);
      final bytes = await file.readAsBytes();
      String filename = file.name.isNotEmpty ? file.name : 'post.jpg';
      if (!filename.contains('.')) filename = 'post.jpg';
      final ext = filename.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png'
          : ext == 'gif' ? 'image/gif'
          : ext == 'webp' ? 'image/webp'
          : 'image/jpeg';

      final formData = dio.FormData.fromMap({
        'action': 'create_post',
        'user_id': myId.toString(),
        'caption': caption,
        'media_type': 'image',
        'media': dio.MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: dio.DioMediaType.parse(mimeType),
        ),
      });
      final res = await ApiClient.uploadFile(
        endpoint: ApiConstants.posts,
        formData: formData,
      );
      if (res.data['status'] == 'success') {
        Helpers.showSuccess('Post uploaded!');
        fetchPosts();
      } else {
        Helpers.showError(res.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      Helpers.showError('Upload failed: ${e.toString()}');
    } finally {
      isUploading(false);
    }
  }

  // ─── Delete post ─────────────────────────────────────────────────
  Future<void> deletePost(int postId) async {
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.posts,
        data: {'action': 'delete_post', 'post_id': postId, 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        posts.removeWhere((p) => p.id == postId);
        Helpers.showSuccess('Post deleted');
      }
    } catch (e) {
      Helpers.showError('Failed to delete post');
    }
  }

  // ─── Fetch comments ──────────────────────────────────────────────
  Future<void> fetchComments(int postId) async {
    try {
      isCommentsLoading(true);
      final res = await ApiClient.instance.post(
        ApiConstants.comments,
        data: {'action': 'get_comments', 'post_id': postId},
      );
      if (res.data['status'] == 'success') {
        comments.value = (res.data['comments'] as List)
            .map((c) => CommentModel.fromJson(c))
            .toList();
      }
    } catch (e) {
      Helpers.showError('Failed to load comments');
    } finally {
      isCommentsLoading(false);
    }
  }

  // ─── Add comment ─────────────────────────────────────────────────
  Future<void> addComment(int postId, String comment) async {
    if (comment.trim().isEmpty) return;
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.comments,
        data: {
          'action': 'add_comment',
          'post_id': postId,
          'user_id': myId,
          'comment': comment,
        },
      );
      if (res.data['status'] == 'success') {
        fetchComments(postId);
        // Update count on post
        final index = posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = posts[index];
          posts[index] = PostModel(
            id: post.id,
            userId: post.userId,
            username: post.username,
            userProfilePic: post.userProfilePic,
            caption: post.caption,
            mediaUrl: post.mediaUrl,
            mediaType: post.mediaType,
            likesCount: post.likesCount,
            commentsCount: post.commentsCount + 1,
            isLiked: post.isLiked,
            createdAt: post.createdAt,
          );
        }
      }
    } catch (e) {
      Helpers.showError('Failed to add comment');
    }
  }
}