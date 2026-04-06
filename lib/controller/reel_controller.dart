import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../model/reel_model.dart';
import '../utils/api_client.dart';
import '../utils/api_constants.dart';
import '../utils/helpers.dart';

class ReelController extends GetxController {
  var reels = <ReelModel>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;
  var currentIndex = 0.obs;
  VideoPlayerController? videoController;
  final _storage = GetStorage();

  @override
  void onInit() {
    fetchReels();
    super.onInit();
  }

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }

  int get myId =>
      int.tryParse(_storage.read('user')?['id'].toString() ?? '0') ?? 0;

  // ─── Fetch reels ─────────────────────────────────────────────────
  Future<void> fetchReels() async {
    try {
      isLoading(true);
      final res = await ApiClient.instance.post(
        ApiConstants.posts,
        data: {'action': 'get_reels', 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        reels.value = (res.data['reels'] as List)
            .map((r) => ReelModel.fromJson(r))
            .toList();
        if (reels.isNotEmpty) _initVideo(reels[0].videoUrl);
      }
    } catch (e) {
      Helpers.showError('Failed to load reels');
    } finally {
      isLoading(false);
    }
  }

  // ─── Init video player ───────────────────────────────────────────
  Future<void> _initVideo(String url) async {
    videoController?.dispose();
    videoController = VideoPlayerController.networkUrl(Uri.parse(
      Helpers.imageUrl(url),
    ));
    await videoController!.initialize();
    videoController!.setLooping(true);
    videoController!.play();
    update();
  }

  // ─── On reel page changed ────────────────────────────────────────
  void onPageChanged(int index) {
    currentIndex.value = index;
    _initVideo(reels[index].videoUrl);
  }

  // ─── Like reel ───────────────────────────────────────────────────
  Future<void> toggleLike(int reelId) async {
    final index = reels.indexWhere((r) => r.id == reelId);
    if (index == -1) return;
    final reel = reels[index];
    final wasLiked = reel.isLiked;
    reels[index] = reel.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? reel.likesCount - 1 : reel.likesCount + 1,
    );
    try {
      await ApiClient.instance.post(
        ApiConstants.posts,
        data: {
          'action': wasLiked ? 'unlike' : 'like',
          'post_id': reelId,
          'user_id': myId,
        },
      );
    } catch (_) {
      reels[index] = reel;
    }
  }

  // ─── Upload reel ─────────────────────────────────────────────────
  Future<void> uploadReel(String caption) async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    try {
      isUploading(true);
      final bytes = await file.readAsBytes();
      final filename = file.name.isNotEmpty ? file.name : 'reel.mp4';

      final formData = dio.FormData.fromMap({
        'action': 'create_post',
        'user_id': myId.toString(),
        'caption': caption,
        'media_type': 'video',
        'media': dio.MultipartFile.fromBytes(bytes, filename: filename),
      });
      final res = await ApiClient.uploadFile(
        endpoint: ApiConstants.posts,
        formData: formData,
      );
      if (res.data['status'] == 'success') {
        Helpers.showSuccess('Reel uploaded!');
        fetchReels();
      } else {
        Helpers.showError(res.data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      Helpers.showError('Reel upload failed: ${e.toString()}');
    } finally {
      isUploading(false);
    }
  }
}