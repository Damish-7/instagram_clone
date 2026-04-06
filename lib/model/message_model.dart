class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final String sentAt;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.sentAt,
    required this.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, int myId) =>
      MessageModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
        receiverId: int.tryParse(json['receiver_id'].toString()) ?? 0,
        message: json['message'] ?? '',
        sentAt: json['sent_at'] ?? '',
        isMe: int.tryParse(json['sender_id'].toString()) == myId,
      );
}

class ChatUserModel {
  final int userId;
  final String username;
  final String? profilePic;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  ChatUserModel({
    required this.userId,
    required this.username,
    this.profilePic,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) => ChatUserModel(
        userId: int.tryParse(json['user_id'].toString()) ?? 0,
        username: json['username'] ?? '',
        profilePic: json['profile_pic'],
        lastMessage: json['last_message'] ?? '',
        lastMessageTime: json['last_message_time'] ?? '',
        unreadCount: int.tryParse(json['unread_count'].toString()) ?? 0,
      );
}