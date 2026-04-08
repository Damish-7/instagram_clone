<?php
require 'config/db.php';

$data   = json_decode(file_get_contents("php://input"), true) ?? [];
$action = $data['action'] ?? '';

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
        WHERE u.id = ? GROUP BY u.id
    ");
    $stmt->execute([$viewerId, $viewerId, $userId]);
    $user = $stmt->fetch();
    if (!$user) {
        echo json_encode(['status' => 'error', 'message' => 'User not found']);
        exit();
    }
    unset($user['password'], $user['token']);

    // Get ALL posts including reels
    $stmt = $pdo->prepare("
        SELECT * FROM posts WHERE user_id = ? ORDER BY created_at DESC
    ");
    $stmt->execute([$userId]);
    $posts = $stmt->fetchAll();

    echo json_encode(['status' => 'success', 'user' => $user, 'posts' => $posts]);
}

elseif ($action === 'update_bio') {
    $stmt = $pdo->prepare("UPDATE users SET bio = ? WHERE id = ?");
    $stmt->execute([$data['bio'] ?? '', $data['user_id'] ?? 0]);
    echo json_encode(['status' => 'success']);
}

elseif ($action === 'update_profile_pic') {
    $userId   = $data['user_id'] ?? 0;
    $base64   = $data['image_base64'] ?? '';
    $mimeType = $data['mime_type'] ?? 'image/jpeg';
    $filename = $data['filename'] ?? '';

    if (empty($base64)) {
        echo json_encode(['status' => 'error', 'message' => 'No image data']);
        exit();
    }

    $path = saveBase64File($base64, $mimeType, 'avatars', $filename);
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