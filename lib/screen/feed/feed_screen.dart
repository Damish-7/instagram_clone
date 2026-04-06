import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/feed_controller.dart';
import '../../controller/story_controller.dart';
import '../../controller/auth_controller.dart';
import '../../model/post_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../story/story_screen.dart';
import 'post_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedCtrl = Get.find<FeedController>();
    final storyCtrl = Get.find<StoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _showUploadDialog(context, feedCtrl),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (feedCtrl.isLoading.value) return _buildShimmer();
        return RefreshIndicator(
          onRefresh: () async {
            await feedCtrl.fetchPosts();
            await storyCtrl.fetchStories();
          },
          child: CustomScrollView(
            slivers: [
              // Stories row
              SliverToBoxAdapter(child: _buildStoriesRow(storyCtrl)),
              const SliverToBoxAdapter(child: Divider(height: 1)),

              // Posts
              feedCtrl.posts.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No posts yet')))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _PostCard(post: feedCtrl.posts[i]),
                        childCount: feedCtrl.posts.length,
                      ),
                    ),
            ],
          ),
        );
      }),
    );
  }

  // ─── Stories row ─────────────────────────────────────────────────
  Widget _buildStoriesRow(StoryController ctrl) {
    return SizedBox(
      height: 100,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: ctrl.storyGroups.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return _addStoryButton(ctrl);
              final group = ctrl.storyGroups[i - 1];
              return GestureDetector(
                onTap: () => Get.to(() => StoryScreen(group: group)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: group.allSeen
                              ? null
                              : AppTheme.storyGradient,
                          color: group.allSeen ? Colors.grey[300] : null,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: group.userProfilePic != null
                                ? CachedNetworkImageProvider(
                                    Helpers.imageUrl(group.userProfilePic!))
                                : null,
                            child: group.userProfilePic == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(group.username,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _addStoryButton(StoryController ctrl) {
    return Obx(() => GestureDetector(
          onTap: ctrl.isUploading.value ? null : ctrl.uploadStory,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                        radius: 30, child: Icon(Icons.person, size: 30)),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: AppTheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Your story', style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ));
  }

  // ─── Upload dialog ────────────────────────────────────────────────
  void _showUploadDialog(BuildContext context, FeedController ctrl) {
    final captionCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('New Post'),
      content: TextField(
        controller: captionCtrl,
        decoration: const InputDecoration(hintText: 'Write a caption...'),
        maxLines: 3,
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            ctrl.uploadPost(captionCtrl.text);
          },
          child: const Text('Upload'),
        ),
      ],
    ));
  }

  // ─── Shimmer loading ─────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.white),
              title: Container(height: 10, color: Colors.white),
            ),
            Container(height: 300, color: Colors.white),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Post Card Widget ─────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final PostModel post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final feedCtrl = Get.find<FeedController>();
    final authCtrl = Get.find<AuthController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        ListTile(
          leading: CircleAvatar(
            backgroundImage: post.userProfilePic != null
                ? CachedNetworkImageProvider(
                    Helpers.imageUrl(post.userProfilePic!))
                : null,
            child: post.userProfilePic == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(post.username,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(Helpers.timeAgo(post.createdAt)),
          trailing: post.userId == authCtrl.myId
              ? IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => Get.dialog(AlertDialog(
                    content: TextButton.icon(
                      onPressed: () {
                        Get.back();
                        feedCtrl.deletePost(post.id);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete post',
                          style: TextStyle(color: Colors.red)),
                    ),
                  )),
                )
              : null,
        ),

        // Image
        GestureDetector(
          onDoubleTap: () => feedCtrl.toggleLike(post.id),
          child: CachedNetworkImage(
            imageUrl: Helpers.imageUrl(post.mediaUrl),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
                height: 300, color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator())),
            errorWidget: (_, __, ___) =>
                Container(height: 300, color: Colors.grey[200],
                    child: const Icon(Icons.broken_image)),
          ),
        ),

        // Actions
        Obx(() {
          final current = feedCtrl.posts.firstWhereOrNull((p) => p.id == post.id) ?? post;
          return Row(
            children: [
              IconButton(
                icon: Icon(
                  current.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: current.isLiked ? Colors.red : null,
                ),
                onPressed: () => feedCtrl.toggleLike(post.id),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () => Get.to(() => PostDetailScreen(post: current)),
              ),
              const Spacer(),
            ],
          );
        }),

        // Likes count
        Obx(() {
          final current = feedCtrl.posts.firstWhereOrNull((p) => p.id == post.id) ?? post;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('${Helpers.formatCount(current.likesCount)} likes',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }),

        // Caption
        if (post.caption != null && post.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                      text: post.username,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '  ${post.caption}'),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),
        const Divider(height: 1),
      ],
    );
  }
}