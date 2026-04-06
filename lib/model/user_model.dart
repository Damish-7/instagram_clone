class UserModel {
  final int id;
  final String username;
  final String email;
  final String? bio;
  final String? profilePic;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isFollowing;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.profilePic,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isFollowing = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        bio: json['bio'],
        profilePic: json['profile_pic'],
        followersCount: int.tryParse(json['followers_count'].toString()) ?? 0,
        followingCount: int.tryParse(json['following_count'].toString()) ?? 0,
        postsCount: int.tryParse(json['posts_count'].toString()) ?? 0,
        isFollowing: json['is_following'] == 1 || json['is_following'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'bio': bio,
        'profile_pic': profilePic,
        'followers_count': followersCount,
        'following_count': followingCount,
        'posts_count': postsCount,
        'is_following': isFollowing,
      };
}