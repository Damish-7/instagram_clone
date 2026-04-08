<?php
require 'config/db.php';

$data   = json_decode(file_get_contents("php://input"), true) ?? [];
$action = $data['action'] ?? $_POST['action'] ?? '';

if ($action === 'get_feed') {
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("
        SELECT p.*, u.username, u.profile_pic,
               COUNT(DISTINCT l.user_id) AS likes_count,
               COUNT(DISTINCT c.id) AS comments_count,
               MAX(CASE WHEN l2.user_id = ? THEN 1 ELSE 0 END) AS is_liked
        FROM posts p
        JOIN users u ON p.user_id = u.id
        LEFT JOIN likes l ON l.post_id = p.id
        LEFT JOIN comments c ON c.post_id = p.id
        LEFT JOIN likes l2 ON l2.post_id = p.id AND l2.user_id = ?
        WHERE p.media_type = 'image'
          AND (p.user_id = ? OR p.user_id IN (
            SELECT following_id FROM follows WHERE follower_id = ?
          ))
        GROUP BY p.id ORDER BY p.created_at DESC LIMIT 30
    ");
    $stmt->execute([$userId, $userId, $userId, $userId]);
    echo json_encode(['status' => 'success', 'posts' => $stmt->fetchAll()]);
}

elseif ($action === 'get_reels') {
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("
        SELECT p.*, u.username, u.profile_pic,
               COUNT(DISTINCT l.user_id) AS likes_count,
               COUNT(DISTINCT c.id) AS comments_count,
               MAX(CASE WHEN l2.user_id = ? THEN 1 ELSE 0 END) AS is_liked
        FROM posts p
        JOIN users u ON p.user_id = u.id
        LEFT JOIN likes l ON l.post_id = p.id
        LEFT JOIN comments c ON c.post_id = p.id
        LEFT JOIN likes l2 ON l2.post_id = p.id AND l2.user_id = ?
        WHERE p.media_type = 'video'
        GROUP BY p.id ORDER BY p.created_at DESC LIMIT 20
    ");
    $stmt->execute([$userId, $userId]);
    echo json_encode(['status' => 'success', 'reels' => $stmt->fetchAll()]);
}

elseif ($action === 'create_post') {
    $userId    = $data['user_id'] ?? 0;
    $caption   = $data['caption'] ?? '';
    $mediaType = $data['media_type'] ?? 'image';
    $base64    = $data['image_base64'] ?? '';
    $mimeType  = $data['mime_type'] ?? 'image/jpeg';
    $filename  = $data['filename'] ?? '';

    if (empty($base64)) {
        echo json_encode(['status' => 'error', 'message' => 'No image data']);
        exit();
    }

    $folder   = $mediaType === 'video' ? 'videos' : 'posts';
    $mediaUrl = saveBase64File($base64, $mimeType, $folder, $filename);

    if (!$mediaUrl) {
        echo json_encode(['status' => 'error', 'message' => 'Failed to save file']);
        exit();
    }

    $stmt = $pdo->prepare("INSERT INTO posts (user_id, caption, media_url, media_type) VALUES (?, ?, ?, ?)");
    $stmt->execute([$userId, $caption, $mediaUrl, $mediaType]);
    echo json_encode(['status' => 'success', 'post_id' => $pdo->lastInsertId()]);
}

elseif ($action === 'delete_post') {
    $postId = $data['post_id'] ?? 0;
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("DELETE FROM posts WHERE id = ? AND user_id = ?");
    $stmt->execute([$postId, $userId]);
    echo json_encode(['status' => 'success']);
}

elseif ($action === 'like') {
    $stmt = $pdo->prepare("INSERT IGNORE INTO likes (user_id, post_id) VALUES (?, ?)");
    $stmt->execute([$data['user_id'] ?? 0, $data['post_id'] ?? 0]);
    echo json_encode(['status' => 'success']);
}

elseif ($action === 'unlike') {
    $stmt = $pdo->prepare("DELETE FROM likes WHERE user_id = ? AND post_id = ?");
    $stmt->execute([$data['user_id'] ?? 0, $data['post_id'] ?? 0]);
    echo json_encode(['status' => 'success']);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}