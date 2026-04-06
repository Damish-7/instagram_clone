import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controller/chat_controller.dart';
import '../../utils/helpers.dart';

class ChatRoomScreen extends StatelessWidget {
  final int userId;
  final String username;
  final String? profilePic;

  const ChatRoomScreen({
    super.key,
    required this.userId,
    required this.username,
    this.profilePic,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();
    final messageCtrl = TextEditingController();
    final scrollCtrl = ScrollController();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: profilePic != null
                  ? CachedNetworkImageProvider(Helpers.imageUrl(profilePic!))
                  : null,
              child: profilePic == null ? const Icon(Icons.person, size: 18) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollCtrl.hasClients) {
                  scrollCtrl.jumpTo(scrollCtrl.position.maxScrollExtent);
                }
              });

              if (ctrl.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profilePic != null
                            ? CachedNetworkImageProvider(
                                Helpers.imageUrl(profilePic!))
                            : null,
                        child: profilePic == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      const Text('Say hi to start the conversation!',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: ctrl.messages.length,
                itemBuilder: (_, i) {
                  final msg = ctrl.messages[i];
                  return Align(
                    alignment: msg.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: msg.isMe ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: msg.isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(msg.message,
                              style: TextStyle(
                                  color: msg.isMe
                                      ? Colors.white
                                      : Colors.black)),
                          const SizedBox(height: 2),
                          Text(Helpers.timeAgo(msg.sentAt),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: msg.isMe
                                      ? Colors.white70
                                      : Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Input bar
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              top: 8,
            ),
            child: Row(
              children: [
                const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: messageCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => GestureDetector(
                      onTap: ctrl.isSending.value
                          ? null
                          : () {
                              ctrl.sendMessage(messageCtrl.text);
                              messageCtrl.clear();
                            },
                      child: Icon(
                        Icons.send,
                        color: ctrl.isSending.value
                            ? Colors.grey
                            : Colors.blue,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}