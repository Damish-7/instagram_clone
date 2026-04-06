<?php
require 'config/db.php';

$data = isset($_POST['action']) ? $_POST : json_decode(file_get_contents("php://input"), true);
$action = $data['action'] ?? '';

// ─── Get stories ──────────────────────────────────────────────────
if ($action === 'get_stories') {
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("
        SELECT s.*, u.username, u.profile_pic,
               MAX(CASE WHEN sv.user_id = ? THEN 1 ELSE 0 END) AS is_seen
        FROM stories s
        JOIN users u ON s.user_id = u.id
        LEFT JOIN story_views sv ON sv.story_id = s.id AND sv.user_id = ?
        WHERE s.expires_at > NOW()
          AND (s.user_id = ? OR s.user_id IN (
            SELECT following_id FROM follows WHERE follower_id = ?
          ))
        GROUP BY s.id
        ORDER BY s.user_id = ? DESC, s.created_at DESC
    ");
    $stmt->execute([$userId, $userId, $userId, $userId, $userId]);
    echo json_encode(['status' => 'success', 'stories' => $stmt->fetchAll()]);
}

// ─── Create story ─────────────────────────────────────────────────
elseif ($action === 'create_story') {
    $userId    = $_POST['user_id'] ?? 0;
    $mediaType = $_POST['media_type'] ?? 'image';

    if (!isset($_FILES['media'])) {
        echo json_encode(['status' => 'error', 'message' => 'No file']);
        exit();
    }

    $mediaUrl = uploadFile($_FILES['media'], 'stories');
    if (!$mediaUrl) {
        echo json_encode(['status' => 'error', 'message' => 'Upload failed']);
        exit();
    }

    $stmt = $pdo->prepare("
        INSERT INTO stories (user_id, media_url, media_type, expires_at)
        VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL 24 HOUR))
    ");
    $stmt->execute([$userId, $mediaUrl, $mediaType]);
    echo json_encode(['status' => 'success']);
}

// ─── Mark seen ────────────────────────────────────────────────────
elseif ($action === 'mark_seen') {
    $storyId = $data['story_id'] ?? 0;
    $userId  = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("INSERT IGNORE INTO story_views (story_id, user_id) VALUES (?, ?)");
    $stmt->execute([$storyId, $userId]);
    echo json_encode(['status' => 'success']);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}
?>