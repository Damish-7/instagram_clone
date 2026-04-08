<?php
require 'config/db.php';

$data   = json_decode(file_get_contents("php://input"), true) ?? [];
$action = $data['action'] ?? '';

// ─── Search users ─────────────────────────────────────────────────
if ($action === 'search') {
    $query  = trim($data['query'] ?? '');
    $userId = $data['user_id'] ?? 0;

    if (empty($query)) {
        echo json_encode(['status' => 'success', 'users' => []]);
        exit();
    }

    $stmt = $pdo->prepare("
        SELECT u.id, u.username, u.bio, u.profile_pic, u.is_private,
               MAX(CASE WHEN f.follower_id = ? AND f.status = 'accepted' THEN 1 ELSE 0 END) AS is_following,
               MAX(CASE WHEN f.follower_id = ? AND f.status = 'pending'  THEN 1 ELSE 0 END) AS is_requested
        FROM users u
        LEFT JOIN follows f ON f.following_id = u.id AND f.follower_id = ?
        WHERE u.username LIKE ? AND u.id != ?
        GROUP BY u.id
        LIMIT 20
    ");
    $stmt->execute([$userId, $userId, $userId, '%' . $query . '%', $userId]);
    echo json_encode(['status' => 'success', 'users' => $stmt->fetchAll()]);
}

// ─── Suggested users ──────────────────────────────────────────────
elseif ($action === 'suggestions') {
    $userId = $data['user_id'] ?? 0;

    $stmt = $pdo->prepare("
        SELECT u.id, u.username, u.bio, u.profile_pic, u.is_private,
               0 AS is_following, 0 AS is_requested
        FROM users u
        WHERE u.id != ?
          AND u.id NOT IN (
            SELECT following_id FROM follows WHERE follower_id = ?
          )
        ORDER BY RAND()
        LIMIT 10
    ");
    $stmt->execute([$userId, $userId]);
    echo json_encode(['status' => 'success', 'users' => $stmt->fetchAll()]);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}