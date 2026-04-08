<?php
require 'config/db.php';

$data   = json_decode(file_get_contents("php://input"), true) ?? [];
$action = $data['action'] ?? '';

if ($action === 'follow') {
    $followerId  = $data['follower_id'] ?? 0;
    $followingId = $data['following_id'] ?? 0;

    $stmt = $pdo->prepare("SELECT is_private FROM users WHERE id = ?");
    $stmt->execute([$followingId]);
    $target = $stmt->fetch();
    $status = ($target && $target['is_private']) ? 'pending' : 'accepted';

    $stmt = $pdo->prepare("DELETE FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$followerId, $followingId]);

    $stmt = $pdo->prepare("INSERT INTO follows (follower_id, following_id, status) VALUES (?, ?, ?)");
    $stmt->execute([$followerId, $followingId, $status]);

    $notifType = $status === 'pending' ? 'follow_request' : 'follow_accepted';
    $stmt = $pdo->prepare("INSERT INTO notifications (user_id, from_user_id, type) VALUES (?, ?, ?)");
    $stmt->execute([$followingId, $followerId, $notifType]);

    echo json_encode(['status' => 'success', 'follow_status' => $status]);
}

elseif ($action === 'unfollow') {
    $stmt = $pdo->prepare("DELETE FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$data['follower_id'] ?? 0, $data['following_id'] ?? 0]);
    echo json_encode(['status' => 'success']);
}

elseif ($action === 'accept') {
    $followerId  = $data['follower_id'] ?? 0;
    $followingId = $data['following_id'] ?? 0;
    $stmt = $pdo->prepare("UPDATE follows SET status = 'accepted' WHERE follower_id = ? AND following_id = ? AND status = 'pending'");
    $stmt->execute([$followerId, $followingId]);
    $stmt = $pdo->prepare("INSERT INTO notifications (user_id, from_user_id, type) VALUES (?, ?, 'follow_accepted')");
    $stmt->execute([$followerId, $followingId]);
    $stmt = $pdo->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ? AND from_user_id = ? AND type = 'follow_request'");
    $stmt->execute([$followingId, $followerId]);
    echo json_encode(['status' => 'success']);
}

elseif ($action === 'reject') {
    $stmt = $pdo->prepare("DELETE FROM follows WHERE follower_id = ? AND following_id = ?");
    $stmt->execute([$data['follower_id'] ?? 0, $data['following_id'] ?? 0]);
    echo json_encode(['status' => 'success']);
}

elseif ($action === 'get_requests') {
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("
        SELECT f.follower_id, u.username, u.profile_pic, u.bio, f.created_at AS requested_at
        FROM follows f JOIN users u ON u.id = f.follower_id
        WHERE f.following_id = ? AND f.status = 'pending'
        ORDER BY f.created_at DESC
    ");
    $stmt->execute([$userId]);
    echo json_encode(['status' => 'success', 'requests' => $stmt->fetchAll()]);
}

elseif ($action === 'get_notifications') {
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("
        SELECT n.*, u.username, u.profile_pic
        FROM notifications n JOIN users u ON u.id = n.from_user_id
        WHERE n.user_id = ? ORDER BY n.created_at DESC LIMIT 30
    ");
    $stmt->execute([$userId]);
    $stmt2 = $pdo->prepare("SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0");
    $stmt2->execute([$userId]);
    $unread = $stmt2->fetch()['count'];
    echo json_encode(['status' => 'success', 'notifications' => $stmt->fetchAll(), 'unread_count' => $unread]);
}

elseif ($action === 'mark_read') {
    $stmt = $pdo->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ?");
    $stmt->execute([$data['user_id'] ?? 0]);
    echo json_encode(['status' => 'success']);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}