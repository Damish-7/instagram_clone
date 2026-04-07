class ApiConstants {
  static const String baseUrl =
      'http://localhost:8888/instagram_clone_api/backend/';

  // Use PHP proxy to serve images - bypasses CORS on Chrome
  static const String uploadUrl =
      'http://localhost:8888/instagram_clone_api/backend/serve_file.php?file=';

  static const String auth     = 'auth.php';
  static const String posts    = 'posts.php';
  static const String stories  = 'stories.php';
  static const String chat     = 'chat.php';
  static const String profile  = 'profile.php';
  static const String comments = 'comments.php';
  static const String follow   = 'follow.php';
}