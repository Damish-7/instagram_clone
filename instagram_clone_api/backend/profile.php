<?php
require 'config/db.php';

$data = isset($_POST['action']) ? $_POST : json_decode(file_get_contents("php://input"), true);
$action = $data['action'] ?? '';

// ─── Get profile ──────────────────────────────────────────────────
if ($action === 'get_profile') {
    $userId   = $data['user_id'] ?? 0;
    $viewerId = $data['viewer_id'] ?? 0;

    $stmt = $pdo->prepare("
        SELECT u.*,
               COUNT(DISTINCT p.id) AS posts_count,
               COUNT(DISTINCT f1.follower_id) AS followers_count,
               COUNT(DISTINCT f2.following_id) AS following_count,
               MAX(CASE WHEN f3.follower_id = ? THEN 1 ELSE 0 END) AS is_following
        FROM users u
        LEFT JOIN posts p ON p.user_id = u.id
        LEFT JOIN follows f1 ON f1.following_id = u.id
        LEFT JOIN follows f2 ON f2.follower_id = u.id
        LEFT JOIN follows f3 ON f3.follower_id = ? AND f3.following_id = u.id
        WHERE u.id = ?
        GROUP BY u.id
    ");
    $stmt->execute([$viewerId, $viewerId, $userId]);
    $user = $stmt->fetch();

    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'User not found']);
        exit();
    }
    unset($user['password'], $user['token']);

    // Get user posts
    $stmt = $pdo->prepare("SELECT * FROM posts WHERE user_id = ? ORDER BY created_at DESC");
    $stmt->execute([$userId]);
    $posts = $stmt->fetchAll();

    echo json_encode(['status' => 'success', 'user' => $user, 'posts' => $posts]);
}

// ─── Update bio ───────────────────────────────────────────────────
elseif ($action === 'update_bio') {
    $userId = $data['user_id'] ?? 0;
    $bio    = trim($data['bio'] ?? '');
    $stmt = $pdo->prepare("UPDATE users SET bio = ? WHERE id = ?");
    $stmt->execute([$bio, $userId]);
    echo json_encode(['status' => 'success']);
}

// ─── Update profile pic ───────────────────────────────────────────
elseif ($action === 'update_profile_pic') {
    $userId = $_POST['user_id'] ?? 0;
    if (!isset($_FILES['profile_pic'])) {
        echo json_encode(['status' => 'error', 'message' => 'No file']);
        exit();
    }
    $path = uploadFile($_FILES['profile_pic'], 'avatars');
    if (!$path) {
        echo json_encode(['status' => 'error', 'message' => 'Upload failed']);
        exit();
    }
    $stmt = $pdo->prepare("UPDATE users SET profile_pic = ? WHERE id = ?");
    $stmt->execute([$path, $userId]);
    echo json_encode(['status' => 'success', 'profile_pic' => $path]);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}
?>