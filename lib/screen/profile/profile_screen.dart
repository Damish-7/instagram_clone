import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controller/profile_controller.dart';
import '../../controller/auth_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';

class ProfileScreen extends StatelessWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final authCtrl = Get.find<AuthController>();
    final isMe = userId == authCtrl.myId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadProfile(userId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              ctrl.profileUser.value?.username ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        actions: isMe
            ? [
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Get.dialog(AlertDialog(
                    content: TextButton.icon(
                      onPressed: () {
                        Get.back();
                        authCtrl.logout();
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Log out',
                          style: TextStyle(color: Colors.red)),
                    ),
                  )),
                ),
              ]
            : null,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = ctrl.profileUser.value;
        if (user == null) return const Center(child: Text('User not found'));

        return RefreshIndicator(
          onRefresh: () => ctrl.loadProfile(userId),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar + stats row
                      Row(
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: isMe ? ctrl.updateProfilePic : null,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: user.profilePic != null
                                      ? CachedNetworkImageProvider(
                                          Helpers.imageUrl(user.profilePic!))
                                      : null,
                                  child: user.profilePic == null
                                      ? const Icon(Icons.person, size: 40)
                                      : null,
                                ),
                                if (isMe)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Stats
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatColumn(
                                    label: 'Posts',
                                    count: user.postsCount),
                                _StatColumn(
                                    label: 'Followers',
                                    count: user.followersCount),
                                _StatColumn(
                                    label: 'Following',
                                    count: user.followingCount),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Username + bio
                      Text(user.username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(user.bio!),
                      ],

                      const SizedBox(height: 16),

                      // Action buttons
                      if (isMe) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showEditBioDialog(ctrl),
                                child: const Text('Edit Profile'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() => ElevatedButton(
                                    onPressed: ctrl.isUpdating.value
                                        ? null
                                        : () => ctrl.toggleFollow(userId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ctrl.profileUser.value?.isFollowing ??
                                                  false
                                              ? Colors.grey[200]
                                              : AppTheme.primary,
                                      foregroundColor:
                                          ctrl.profileUser.value?.isFollowing ??
                                                  false
                                              ? Colors.black
                                              : Colors.white,
                                    ),
                                    child: Text(
                                      ctrl.profileUser.value?.isFollowing ??
                                              false
                                          ? 'Following'
                                          : 'Follow',
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Message'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Grid divider
              const SliverToBoxAdapter(child: Divider(height: 1)),

              // Posts grid
              ctrl.userPosts.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grid_on, size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No posts yet',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final post = ctrl.userPosts[i];
                          return CachedNetworkImage(
                            imageUrl: Helpers.imageUrl(post.mediaUrl),
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          );
                        },
                        childCount: ctrl.userPosts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                    ),
            ],
          ),
        );
      }),
    );
  }

  void _showEditBioDialog(ProfileController ctrl) {
    final bioCtrl = TextEditingController(text: ctrl.profileUser.value?.bio);
    Get.dialog(AlertDialog(
      title: const Text('Edit Bio'),
      content: TextField(
        controller: bioCtrl,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Write something about yourself...'),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            ctrl.updateBio(bioCtrl.text);
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int count;
  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(Helpers.formatCount(count),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}