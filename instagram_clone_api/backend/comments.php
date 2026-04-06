<?php
require 'config/db.php';

$data = json_decode(file_get_contents("php://input"), true);
$action = $data['action'] ?? '';

// ─── Get comments ─────────────────────────────────────────────────
if ($action === 'get_comments') {
    $postId = $data['post_id'] ?? 0;
    $stmt = $pdo->prepare("
        SELECT c.*, u.username, u.profile_pic
        FROM comments c
        JOIN users u ON c.user_id = u.id
        WHERE c.post_id = ?
        ORDER BY c.created_at ASC
    ");
    $stmt->execute([$postId]);
    echo json_encode(['status' => 'success', 'comments' => $stmt->fetchAll()]);
}

// ─── Add comment ──────────────────────────────────────────────────
elseif ($action === 'add_comment') {
    $postId  = $data['post_id'] ?? 0;
    $userId  = $data['user_id'] ?? 0;
    $comment = trim($data['comment'] ?? '');

    if (!$comment) {
        echo json_encode(['status' => 'error', 'message' => 'Comment is empty']);
        exit();
    }

    $stmt = $pdo->prepare("INSERT INTO comments (post_id, user_id, comment) VALUES (?, ?, ?)");
    $stmt->execute([$postId, $userId, $comment]);
    echo json_encode(['status' => 'success', 'comment_id' => $pdo->lastInsertId()]);
}

// ─── Delete comment ───────────────────────────────────────────────
elseif ($action === 'delete_comment') {
    $commentId = $data['comment_id'] ?? 0;
    $userId    = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("DELETE FROM comments WHERE id = ? AND user_id = ?");
    $stmt->execute([$commentId, $userId]);
    echo json_encode(['status' => 'success']);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}
?>