<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require 'config/db.php';

$data = json_decode(file_get_contents("php://input"), true);
$action = $data['action'] ?? '';

// ─── Register ────────────────────────────────────────────────────────
if ($action === 'register') {
    $username = trim($data['username'] ?? '');
    $email    = trim($data['email'] ?? '');
    $password = $data['password'] ?? '';

    if (!$username || !$email || !$password) {
        echo json_encode(['status' => 'error', 'message' => 'All fields required']);
        exit();
    }

    // Check duplicate
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? OR username = ?");
    $stmt->execute([$email, $username]);
    if ($stmt->fetch()) {
        echo json_encode(['status' => 'error', 'message' => 'Email or username already exists']);
        exit();
    }

    $hashed = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
    $stmt->execute([$username, $email, $hashed]);

    echo json_encode(['status' => 'success', 'message' => 'Account created!']);
}

// ─── Login ───────────────────────────────────────────────────────────
elseif ($action === 'login') {
    $email    = trim($data['email'] ?? '');
    $password = $data['password'] ?? '';

    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($password, $user['password'])) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid email or password']);
        exit();
    }

    // Generate token
    $token = bin2hex(random_bytes(32));
    $stmt = $pdo->prepare("UPDATE users SET token = ? WHERE id = ?");
    $stmt->execute([$token, $user['id']]);

    unset($user['password']);
    $user['token'] = $token;

    echo json_encode(['status' => 'success', 'token' => $token, 'user' => $user]);
}

// ─── Logout ──────────────────────────────────────────────────────────
elseif ($action === 'logout') {
    $userId = $data['user_id'] ?? 0;
    $stmt = $pdo->prepare("UPDATE users SET token = NULL WHERE id = ?");
    $stmt->execute([$userId]);
    echo json_encode(['status' => 'success']);
}

else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}
