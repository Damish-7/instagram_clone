import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controller/notification_controller.dart';
import '../../model/search_model.dart';
import '../../utils/helpers.dart';
import '../../utils/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchNotifications();
      ctrl.fetchFollowRequests();
      ctrl.markAllRead();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ctrl.fetchNotifications();
            await ctrl.fetchFollowRequests();
          },
          child: CustomScrollView(
            slivers: [
              // ── Follow requests section ───────────────────────
              if (ctrl.followRequests.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Follow Requests',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) =>
                        _FollowRequestTile(request: ctrl.followRequests[i]),
                    childCount: ctrl.followRequests.length,
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
              ],

              // ── All notifications ─────────────────────────────
              if (ctrl.notifications.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No activity yet',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Recent Activity',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) =>
                        _NotificationTile(notif: ctrl.notifications[i]),
                    childCount: ctrl.notifications.length,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ── Follow request tile ───────────────────────────────────────────────────────
class _FollowRequestTile extends StatelessWidget {
  final FollowRequestModel request;
  const _FollowRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final ctrl   = Get.find<NotificationController>();
    final picUrl = Helpers.imageUrl(request.profilePic);

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage:
            picUrl.isNotEmpty ? CachedNetworkImageProvider(picUrl) : null,
        child: picUrl.isEmpty
            ? const Icon(Icons.person, color: Colors.grey)
            : null,
      ),
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
                text: request.username,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: ' wants to follow you'),
          ],
        ),
      ),
      subtitle: Text(Helpers.timeAgo(request.requestedAt),
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => ctrl.acceptRequest(request.followerId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Accept', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: () => ctrl.rejectRequest(request.followerId),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(72, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Decline', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  const _NotificationTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    final picUrl = Helpers.imageUrl(notif.profilePic);

    String message;
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case 'follow_request':
        message = 'sent you a follow request';
        icon = Icons.person_add_outlined;
        iconColor = AppTheme.primary;
        break;
      case 'follow_accepted':
        message = 'accepted your follow request';
        icon = Icons.person_outlined;
        iconColor = Colors.green;
        break;
      case 'like':
        message = 'liked your post';
        icon = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        message = 'commented on your post';
        icon = Icons.chat_bubble_outline;
        iconColor = Colors.blue;
        break;
      default:
        message = 'interacted with you';
        icon = Icons.notifications_outlined;
        iconColor = Colors.grey;
    }

    return Container(
      color: notif.isRead ? null : Colors.blue.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              picUrl.isNotEmpty ? CachedNetworkImageProvider(picUrl) : null,
          child: picUrl.isEmpty
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                  text: notif.username,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' $message'),
            ],
          ),
        ),
        subtitle: Text(Helpers.timeAgo(notif.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}