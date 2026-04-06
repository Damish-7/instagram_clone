class CommentModel {
  final int id;
  final int postId;
  final int userId;
  final String username;
  final String? userProfilePic;
  final String comment;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.userProfilePic,
    required this.comment,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        postId: int.tryParse(json['post_id'].toString()) ?? 0,
        userId: int.tryParse(json['user_id'].toString()) ?? 0,
        username: json['username'] ?? '',
        userProfilePic: json['profile_pic'],
        comment: json['comment'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}