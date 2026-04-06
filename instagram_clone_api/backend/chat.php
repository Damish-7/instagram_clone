<?php
require 'config/db.php';

$data = json_decode(file_get_contents("php://input"), true);
$action = $data['action'] ?? '';

// ─── Get chat users ───────────────────────────────────────────────
if ($action === 'get_chat_users') {
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("
        SELECT u.id AS user_id, u.username, u.profile_pic,
               m.message AS last_message,
               m.sent_at AS last_message_time,
               SUM(CASE WHEN m.receiver_id = ? AND m.is_read = 0 THEN 1 ELSE 0 END) AS unread_count
        FROM messages m
        JOIN users u ON u.id = CASE
            WHEN m.sender_id = ? THEN m.receiver_id
            ELSE m.sender_id
        END
        WHERE m.sender_id = ? OR m.receiver_id = ?
        GROUP BY u.id, m.message, m.sent_at
        ORDER BY m.sent_at DESC
    ");
    $stmt->execute([$userId, $userId, $userId, $userId]);
    echo json_encode(['status' => 'success', 'users' => $stmt->fetchAll()]);
}

// ─── Get messages ─────────────────────────────────────────────────
elseif ($action === 'get_messages') {
    $userId     = $data['user_id'] ?? 0;
    $receiverId = $data['receiver_id'] ?? 0;

    // Mark as read
    $stmt = $pdo->prepare("UPDATE messages SET is_read = 1 WHERE sender_id = ? AND receiver_id = ?");
    $stmt->execute([$receiverId, $userId]);

    $stmt = $pdo->prepare("
        SELECT * FROM messages
        WHERE (sender_id = ? AND receiver_id = ?)
           OR (sender_id = ? AND receiver_id = ?)
        ORDER BY sent_at ASC
        LIMIT 100
    ");
    $stmt->execute([$userId, $receiverId, $receiverId, $userId]);
    echo json_encode(['status' => 'success', 'messages' => $stmt->fetchAll()]);
}

// ─── Send message ─────────────────────────────────────────────────
elseif ($action === 'send_message') {
    $senderId   = $data['sender_id'] ?? 0;
    $receiverId = $data['receiver_id'] ?? 0;
    $message    = trim($data['message'] ?? '');

    if (!$message) {
        echo json_encode(['status' => 'error', 'message' => 'Empty message']);
        exit();
    }

    $stmt = $pdo->prepare("INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)");
    $stmt->execute([$senderId, $receiverId, $message]);
    echo json_encode(['status' => 'success', 'message_id' => $pdo->lastInsertId()]);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}
?>