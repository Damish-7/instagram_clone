import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controller/chat_controller.dart';
import '../../utils/helpers.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.chatUsers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No messages yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.fetchChatUsers,
          child: ListView.builder(
            itemCount: ctrl.chatUsers.length,
            itemBuilder: (_, i) {
              final user = ctrl.chatUsers[i];
              return ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: user.profilePic != null
                      ? CachedNetworkImageProvider(
                          Helpers.imageUrl(user.profilePic!))
                      : null,
                  child: user.profilePic == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user.username,
                    style: TextStyle(
                      fontWeight: user.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
                subtitle: Text(
                  user.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: user.unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: user.unreadCount > 0 ? Colors.black : Colors.grey,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Helpers.timeAgo(user.lastMessageTime),
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                    if (user.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text('${user.unreadCount}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  ctrl.openChat(user.userId, user.username);
                  Get.to(() => ChatRoomScreen(
                        userId: user.userId,
                        username: user.username,
                        profilePic: user.profilePic,
                      ));
                },
              );
            },
          ),
        );
      }),
    );
  }
}