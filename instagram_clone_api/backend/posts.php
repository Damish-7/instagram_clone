<?php
require 'config/db.php';

$data = isset($_POST['action']) ? $_POST : json_decode(file_get_contents("php://input"), true);
$action = $data['action'] ?? '';

// ─── Get feed posts ───────────────────────────────────────────────
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
        GROUP BY p.id
        ORDER BY p.created_at DESC
        LIMIT 30
    ");
    $stmt->execute([$userId, $userId, $userId, $userId]);
    echo json_encode(['status' => 'success', 'posts' => $stmt->fetchAll()]);
}

// ─── Get reels ────────────────────────────────────────────────────
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
        GROUP BY p.id
        ORDER BY p.created_at DESC
        LIMIT 20
    ");
    $stmt->execute([$userId, $userId]);
    echo json_encode(['status' => 'success', 'reels' => $stmt->fetchAll()]);
}

// ─── Create post ─────────────────────────────────────────────────
elseif ($action === 'create_post') {
    $userId    = $_POST['user_id'] ?? 0;
    $caption   = $_POST['caption'] ?? '';
    $mediaType = $_POST['media_type'] ?? 'image';

    if (!isset($_FILES['media'])) {
        echo json_encode(['status' => 'error', 'message' => 'No media file']);
        exit();
    }

    $mediaUrl = uploadFile($_FILES['media'], $mediaType === 'video' ? 'videos' : 'posts');
    if (!$mediaUrl) {
        echo json_encode(['status' => 'error', 'message' => 'Upload failed']);
        exit();
    }

    $stmt = $pdo->prepare("INSERT INTO posts (user_id, caption, media_url, media_type) VALUES (?, ?, ?, ?)");
    $stmt->execute([$userId, $caption, $mediaUrl, $mediaType]);
    echo json_encode(['status' => 'success', 'post_id' => $pdo->lastInsertId()]);
}

// ─── Delete post ─────────────────────────────────────────────────
elseif ($action === 'delete_post') {
    $postId = $data['post_id'] ?? 0;
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("DELETE FROM posts WHERE id = ? AND user_id = ?");
    $stmt->execute([$postId, $userId]);
    echo json_encode(['status' => 'success']);
}

// ─── Like ────────────────────────────────────────────────────────
elseif ($action === 'like') {
    $postId = $data['post_id'] ?? 0;
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("INSERT IGNORE INTO likes (user_id, post_id) VALUES (?, ?)");
    $stmt->execute([$userId, $postId]);
    echo json_encode(['status' => 'success']);
}

// ─── Unlike ──────────────────────────────────────────────────────
elseif ($action === 'unlike') {
    $postId = $data['post_id'] ?? 0;
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("DELETE FROM likes WHERE user_id = ? AND post_id = ?");
    $stmt->execute([$userId, $postId]);
    echo json_encode(['status' => 'success']);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}
?>