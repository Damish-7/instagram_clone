import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../controller/reel_controller.dart';
import '../../model/reel_model.dart';
import '../../utils/helpers.dart';

class ReelScreen extends StatelessWidget {
  const ReelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReelController>();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Reels',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showUploadDialog(ctrl),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        if (ctrl.reels.isEmpty) {
          return const Center(
              child: Text('No reels yet',
                  style: TextStyle(color: Colors.white, fontSize: 16)));
        }
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: ctrl.reels.length,
          onPageChanged: ctrl.onPageChanged,
          itemBuilder: (_, i) => _ReelItem(index: i),
        );
      }),
    );
  }

  void _showUploadDialog(ReelController ctrl) {
    final captionCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('Upload Reel'),
      content: TextField(
        controller: captionCtrl,
        decoration: const InputDecoration(hintText: 'Caption...'),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            ctrl.uploadReel(captionCtrl.text);
          },
          child: const Text('Upload'),
        ),
      ],
    ));
  }
}

class _ReelItem extends StatelessWidget {
  final int index;
  const _ReelItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ReelController>();

    return Obx(() {
      final reel      = ctrl.reels[index];
      final isCurrent = ctrl.currentIndex.value == index;
      // Use currentVideo getter which maps to _videoControllers[currentIndex]
      final vidCtrl   = isCurrent ? ctrl.currentVideo : null;
      final ready     = isCurrent && ctrl.isVideoReady.value && vidCtrl != null;

      return Stack(
        fit: StackFit.expand,
        children: [
          // ── Video or loading ──────────────────────────────────────
          if (ready)
            GestureDetector(
              onTap: () {
                if (vidCtrl.value.isPlaying) {
                  vidCtrl.pause();
                } else {
                  vidCtrl.play();
                }
              },
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: vidCtrl.value.size.width,
                  height: vidCtrl.value.size.height,
                  child: VideoPlayer(vidCtrl),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // ── Gradient overlay ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),

          // ── Right side actions ────────────────────────────────────
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                // Like
                Obx(() {
                  final current =
                      ctrl.reels.firstWhereOrNull((r) => r.id == reel.id) ??
                          reel;
                  return Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          current.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: current.isLiked ? Colors.red : Colors.white,
                          size: 30,
                        ),
                        onPressed: () => ctrl.toggleLike(reel.id),
                      ),
                      Text(Helpers.formatCount(current.likesCount),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // Comments
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: Colors.white, size: 30),
                      onPressed: () {},
                    ),
                    Text(Helpers.formatCount(reel.commentsCount),
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),

                // Share
                const Icon(Icons.send_outlined,
                    color: Colors.white, size: 30),
              ],
            ),
          ),

          // ── Bottom info ───────────────────────────────────────────
          Positioned(
            left: 12,
            bottom: 80,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${reel.username}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                if (reel.caption != null && reel.caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(reel.caption!,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                if (reel.audioName != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.music_note,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(reel.audioName!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12)),
                  ]),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}