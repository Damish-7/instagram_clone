class StoryModel {
  final int id;
  final int userId;
  final String username;
  final String? userProfilePic;
  final String mediaUrl;
  final String mediaType;
  final String expiresAt;
  final bool isSeen;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userProfilePic,
    required this.mediaUrl,
    this.mediaType = 'image',
    required this.expiresAt,
    this.isSeen = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        userId: int.tryParse(json['user_id'].toString()) ?? 0,
        username: json['username'] ?? '',
        userProfilePic: json['profile_pic'],
        mediaUrl: json['media_url'] ?? '',
        mediaType: json['media_type'] ?? 'image',
        expiresAt: json['expires_at'] ?? '',
        isSeen: json['is_seen'] == 1 || json['is_seen'] == true,
      );
}

// Groups stories by user
class UserStoryGroup {
  final int userId;
  final String username;
  final String? userProfilePic;
  final List<StoryModel> stories;
  final bool allSeen;

  UserStoryGroup({
    required this.userId,
    required this.username,
    this.userProfilePic,
    required this.stories,
    this.allSeen = false,
  });
}