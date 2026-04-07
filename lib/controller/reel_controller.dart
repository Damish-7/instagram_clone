import 'dart:convert';
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
  var reels        = <ReelModel>[].obs;
  var isLoading    = false.obs;
  var isUploading  = false.obs;
  var currentIndex = 0.obs;
  var isVideoReady = false.obs;

  final Map<int, VideoPlayerController> _videoControllers = {};
  final _storage = GetStorage();

  @override
  void onInit() { fetchReels(); super.onInit(); }

  @override
  void onClose() { _disposeAll(); super.onClose(); }

  void _disposeAll() {
    for (final c in _videoControllers.values) c.dispose();
    _videoControllers.clear();
  }

  int get myId =>
      int.tryParse(_storage.read('user')?['id'].toString() ?? '0') ?? 0;

  VideoPlayerController? get currentVideo =>
      _videoControllers[currentIndex.value];

  Future<void> fetchReels() async {
    try {
      isLoading(true);
      _disposeAll();
      isVideoReady(false);
      final res = await ApiClient.instance.post(
        ApiConstants.posts,
        data: {'action': 'get_reels', 'user_id': myId},
      );
      if (res.data['status'] == 'success') {
        reels.value = (res.data['reels'] as List)
            .map((r) => ReelModel.fromJson(r)).toList();
        if (reels.isNotEmpty) {
          currentIndex.value = 0;
          await _initVideo(0);
        }
      }
    } catch (e) {
      Helpers.showError('Failed to load reels');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _initVideo(int index) async {
    if (index < 0 || index >= reels.length) return;
    for (final entry in _videoControllers.entries) {
      if (entry.key != index) entry.value.pause();
    }
    if (_videoControllers.containsKey(index)) {
      _videoControllers[index]!.play();
      isVideoReady(true);
      return;
    }
    isVideoReady(false);
    final url = Helpers.imageUrl(reels[index].videoUrl);
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
    _videoControllers[index] = ctrl;
    try {
      await ctrl.initialize();
      ctrl.setLooping(true);
      ctrl.play();
      isVideoReady(true);
      update();
    } catch (e) {
      isVideoReady(false);
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    _initVideo(index);
  }

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
      await ApiClient.instance.post(ApiConstants.posts, data: {
        'action': wasLiked ? 'unlike' : 'like',
        'post_id': reelId,
        'user_id': myId,
      });
    } catch (_) { reels[index] = reel; }
  }

  Future<void> uploadReel(String caption) async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    try {
      isUploading(true);
      final bytes     = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      final filename  = file.name.isNotEmpty ? file.name : 'reel.mp4';
      final ext       = filename.split('.').last.toLowerCase();
      final mimeType  = ext == 'mov' ? 'video/quicktime' : 'video/mp4';
      final res = await ApiClient.instance.post(ApiConstants.posts, data: {
        'action':       'create_post',
        'user_id':      myId.toString(),
        'caption':      caption,
        'media_type':   'video',
        'image_base64': base64Str,
        'mime_type':    mimeType,
        'filename':     filename,
      });
      if (res.data['status'] == 'success') {
        Helpers.showSuccess('Reel uploaded!');
        await fetchReels();
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