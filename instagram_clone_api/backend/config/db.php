<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// MAMP credentials
define('DB_HOST', 'localhost');
define('DB_NAME', 'instagram_clone');
define('DB_USER', 'root');
define('DB_PASS', 'root');
define('DB_PORT', '8889');

try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8",
        DB_USER,
        DB_PASS
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB connection failed: ' . $e->getMessage()]);
    exit();
}

define('UPLOAD_DIR', __DIR__ . '/../../uploads/');

function uploadFile($file, $folder = '') {
    $uploadDir = __DIR__ . '/../../uploads/';
    $dir = $uploadDir . ($folder ? $folder . '/' : '');

    // Create folder if not exists
    if (!is_dir($dir)) {
        mkdir($dir, 0777, true);
    }

    // Get extension safely
    $originalName = $file['name'] ?? 'upload';
    $ext = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

    // Default extensions if missing
    if (empty($ext)) {
        $mimeType = $file['type'] ?? '';
        $mimeMap = [
            'image/jpeg' => 'jpg',
            'image/png'  => 'png',
            'image/gif'  => 'gif',
            'image/webp' => 'webp',
            'video/mp4'  => 'mp4',
            'video/quicktime' => 'mov',
        ];
        $ext = $mimeMap[$mimeType] ?? 'jpg';
    }

    $filename = uniqid() . '_' . time() . '.' . $ext;
    $destPath = $dir . $filename;

    // Try move_uploaded_file first (standard)
    if (!empty($file['tmp_name']) && is_uploaded_file($file['tmp_name'])) {
        if (move_uploaded_file($file['tmp_name'], $destPath)) {
            return ($folder ? $folder . '/' : '') . $filename;
        }
    }

    // Fallback: copy from tmp (works better on Windows)
    if (!empty($file['tmp_name']) && file_exists($file['tmp_name'])) {
        if (copy($file['tmp_name'], $destPath)) {
            return ($folder ? $folder . '/' : '') . $filename;
        }
    }

    // Last resort: read raw input stream
    $rawData = file_get_contents($file['tmp_name']);
    if ($rawData !== false && strlen($rawData) > 0) {
        if (file_put_contents($destPath, $rawData) !== false) {
            return ($folder ? $folder . '/' : '') . $filename;
        }
    }

    return null;
}