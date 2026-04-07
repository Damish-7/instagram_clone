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
    final ctrl     = Get.find<ProfileController>();
    final authCtrl = Get.find<AuthController>();
    final isMe     = userId == authCtrl.myId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.loadProfile(userId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              ctrl.profileUser.value?.username ?? 'Profile',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        actions: isMe
            ? [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Get.dialog(AlertDialog(
                    content: TextButton.icon(
                      onPressed: () { Get.back(); authCtrl.logout(); },
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
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.loadProfile(userId),
          child: CustomScrollView(
            slivers: [
              // ── Profile header ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: isMe ? ctrl.updateProfilePic : null,
                            child: _buildAvatar(user.profilePic, 40),
                          ),
                          const SizedBox(width: 24),
                          // Stats
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatCol(label: 'Posts',
                                    count: ctrl.userPosts.length),
                                _StatCol(label: 'Followers',
                                    count: user.followersCount),
                                _StatCol(label: 'Following',
                                    count: user.followingCount),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(user.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(user.bio!),
                      ],
                      const SizedBox(height: 16),
                      // Buttons
                      if (isMe)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _showEditBioDialog(ctrl),
                            child: const Text('Edit Profile'),
                          ),
                        )
                      else
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: ctrl.isUpdating.value
                                  ? null
                                  : () => ctrl.toggleFollow(userId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: user.isFollowing
                                    ? Colors.grey[200]
                                    : AppTheme.primary,
                                foregroundColor: user.isFollowing
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              child: Text(
                                  user.isFollowing ? 'Following' : 'Follow'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Message'),
                            ),
                          ),
                        ]),
                    ],
                  ),
                ),
              ),

              // ── Grid tab ─────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Column(children: [
                  Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Icon(Icons.grid_on),
                  ),
                  Divider(height: 1),
                ]),
              ),

              // ── Posts + Reels grid ────────────────────────────────
              ctrl.userPosts.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No posts yet',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final post = ctrl.userPosts[i];
                          final isVideo = post.mediaType == 'video';
                          final imgUrl  = Helpers.imageUrl(post.mediaUrl);

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // Image or video thumbnail
                              imgUrl.isEmpty
                                  ? Container(color: Colors.grey[300],
                                      child: const Icon(Icons.image,
                                          color: Colors.grey))
                                  : CachedNetworkImage(
                                      imageUrl: imgUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                          color: Colors.grey[200]),
                                      errorWidget: (_, __, ___) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.grey),
                                      ),
                                    ),
                              // Video indicator
                              if (isVideo)
                                const Positioned(
                                  top: 6, right: 6,
                                  child: Icon(Icons.play_circle_filled,
                                      color: Colors.white, size: 20),
                                ),
                            ],
                          );
                        },
                        childCount: ctrl.userPosts.length,
                      ),
                    ),
            ],
          ),
        );
      }),
    );
  }

  // ── Build avatar with proxy URL ───────────────────────────────────
  Widget _buildAvatar(String? profilePic, double radius) {
    final url = Helpers.imageUrl(profilePic);
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          backgroundImage: url.isNotEmpty
              ? CachedNetworkImageProvider(url)
              : null,
          child: url.isEmpty
              ? Icon(Icons.person, size: radius, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                color: AppTheme.primary, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }

  void _showEditBioDialog(ProfileController ctrl) {
    final bioCtrl =
        TextEditingController(text: ctrl.profileUser.value?.bio ?? '');
    Get.dialog(AlertDialog(
      title: const Text('Edit Bio'),
      content: TextField(
        controller: bioCtrl,
        maxLines: 3,
        decoration: const InputDecoration(
            hintText: 'Write something about yourself...'),
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

class _StatCol extends StatelessWidget {
  final String label;
  final int count;
  const _StatCol({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(Helpers.formatCount(count),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ]);
}