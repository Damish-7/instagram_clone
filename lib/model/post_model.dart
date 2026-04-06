class PostModel {
  final int id;
  final int userId;
  final String username;
  final String? userProfilePic;
  final String? caption;
  final String mediaUrl;
  final String mediaType;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userProfilePic,
    this.caption,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        userId: int.tryParse(json['user_id'].toString()) ?? 0,
        username: json['username'] ?? '',
        userProfilePic: json['profile_pic'],
        caption: json['caption'],
        mediaUrl: json['media_url'] ?? '',
        mediaType: json['media_type'] ?? 'image',
        likesCount: int.tryParse(json['likes_count'].toString()) ?? 0,
        commentsCount: int.tryParse(json['comments_count'].toString()) ?? 0,
        isLiked: json['is_liked'] == 1 || json['is_liked'] == true,
        createdAt: json['created_at'] ?? '',
      );

  PostModel copyWith({bool? isLiked, int? likesCount}) => PostModel(
        id: id,
        userId: userId,
        username: username,
        userProfilePic: userProfilePic,
        caption: caption,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount,
        isLiked: isLiked ?? this.isLiked,
        createdAt: createdAt,
      );
}