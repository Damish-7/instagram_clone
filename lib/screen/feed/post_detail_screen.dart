import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controller/feed_controller.dart';
import '../../model/post_model.dart';
import '../../utils/helpers.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final feedCtrl = Get.find<FeedController>();
    final commentCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      feedCtrl.fetchComments(post.id);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post image
                  CachedNetworkImage(
                    imageUrl: Helpers.imageUrl(post.mediaUrl),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),

                  // Caption
                  if (post.caption != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                                text: post.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: '  ${post.caption}'),
                          ],
                        ),
                      ),
                    ),

                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Comments',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),

                  // Comments list
                  Obx(() {
                    if (feedCtrl.isCommentsLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (feedCtrl.comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No comments yet. Be the first!',
                            style: TextStyle(color: Colors.grey)),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: feedCtrl.comments.length,
                      itemBuilder: (_, i) {
                        final c = feedCtrl.comments[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: c.userProfilePic != null
                                ? CachedNetworkImageProvider(
                                    Helpers.imageUrl(c.userProfilePic!))
                                : null,
                            child: c.userProfilePic == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          title: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                    text: c.username,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextSpan(text: '  ${c.comment}'),
                              ],
                            ),
                          ),
                          subtitle: Text(Helpers.timeAgo(c.createdAt),
                              style: const TextStyle(fontSize: 11)),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          // Comment input
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              top: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    feedCtrl.addComment(post.id, commentCtrl.text);
                    commentCtrl.clear();
                  },
                  child: const Text('Post',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}