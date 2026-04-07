class SearchUserModel {
  final int id;
  final String username;
  final String? bio;
  final String? profilePic;
  final bool isPrivate;
  final bool isFollowing;
  final bool isRequested;

  SearchUserModel({
    required this.id,
    required this.username,
    this.bio,
    this.profilePic,
    this.isPrivate = false,
    this.isFollowing = false,
    this.isRequested = false,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) =>
      SearchUserModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        username: json['username'] ?? '',
        bio: json['bio'],
        profilePic: json['profile_pic'],
        isPrivate: json['is_private'] == 1 || json['is_private'] == true,
        isFollowing: json['is_following'] == 1 || json['is_following'] == true,
        isRequested: json['is_requested'] == 1 || json['is_requested'] == true,
      );

  SearchUserModel copyWith({bool? isFollowing, bool? isRequested}) =>
      SearchUserModel(
        id: id,
        username: username,
        bio: bio,
        profilePic: profilePic,
        isPrivate: isPrivate,
        isFollowing: isFollowing ?? this.isFollowing,
        isRequested: isRequested ?? this.isRequested,
      );
}

class NotificationModel {
  final int id;
  final int userId;
  final int fromUserId;
  final String username;
  final String? profilePic;
  final String type;
  final int? referenceId;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.fromUserId,
    required this.username,
    this.profilePic,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        userId: int.tryParse(json['user_id'].toString()) ?? 0,
        fromUserId: int.tryParse(json['from_user_id'].toString()) ?? 0,
        username: json['username'] ?? '',
        profilePic: json['profile_pic'],
        type: json['type'] ?? '',
        referenceId: json['reference_id'] != null
            ? int.tryParse(json['reference_id'].toString())
            : null,
        isRead: json['is_read'] == 1 || json['is_read'] == true,
        createdAt: json['created_at'] ?? '',
      );
}

class FollowRequestModel {
  final int followerId;
  final String username;
  final String? profilePic;
  final String? bio;
  final String requestedAt;

  FollowRequestModel({
    required this.followerId,
    required this.username,
    this.profilePic,
    this.bio,
    required this.requestedAt,
  });

  factory FollowRequestModel.fromJson(Map<String, dynamic> json) =>
      FollowRequestModel(
        followerId: int.tryParse(json['follower_id'].toString()) ?? 0,
        username: json['username'] ?? '',
        profilePic: json['profile_pic'],
        bio: json['bio'],
        requestedAt: json['requested_at'] ?? '',
      );
}