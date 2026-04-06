class ReelModel {
  final int id;
  final int userId;
  final String username;
  final String? userProfilePic;
  final String videoUrl;
  final String? caption;
  final String? audioName;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String createdAt;

  ReelModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userProfilePic,
    required this.videoUrl,
    this.caption,
    this.audioName,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) => ReelModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        userId: int.tryParse(json['user_id'].toString()) ?? 0,
        username: json['username'] ?? '',
        userProfilePic: json['profile_pic'],
        videoUrl: json['media_url'] ?? '',
        caption: json['caption'],
        audioName: json['audio_name'],
        likesCount: int.tryParse(json['likes_count'].toString()) ?? 0,
        commentsCount: int.tryParse(json['comments_count'].toString()) ?? 0,
        isLiked: json['is_liked'] == 1 || json['is_liked'] == true,
        createdAt: json['created_at'] ?? '',
      );

  ReelModel copyWith({bool? isLiked, int? likesCount}) => ReelModel(
        id: id,
        userId: userId,
        username: username,
        userProfilePic: userProfilePic,
        videoUrl: videoUrl,
        caption: caption,
        audioName: audioName,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount,
        isLiked: isLiked ?? this.isLiked,
        createdAt: createdAt,
      );
}