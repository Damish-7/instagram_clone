<?php
require 'config/db.php';

$data = json_decode(file_get_contents("php://input"), true);
$action = $data['action'] ?? '';

// ─── Follow ───────────────────────────────────────────────────────
if ($action === 'follow') {
    $followerId  = $data['follower_id'] ?? 0;
    $followingId = $data['following_id'] ?? 0;
    $stmt = $pdo->prepare("INSERT IGNORE INTO follows (follower_id, following_id) VALUES (?, ?)");
    $stmt->execute([$followerId, $followingId]);
    echo json_encode(['status' => 'success']);
}

// ─── Unfollow ─────────────────────────────────────────────────────
elseif ($action === 'unfollow') {
    $followerId  = $data['follower_id'] ?? 0;
    $followingId = $data['following_id'] ?? 0;
    $stmt = $pdo->prepare("DELETE FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$followerId, $followingId]);
    echo json_encode(['status' => 'success']);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}
?>