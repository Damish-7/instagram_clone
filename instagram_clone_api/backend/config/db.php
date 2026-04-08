<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

define('DB_HOST', 'localhost');
define('DB_NAME', 'instagram_clone');
define('DB_USER', 'root');
define('DB_PASS', 'root');
define('DB_PORT', '8889');

try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8",
        DB_USER, DB_PASS
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB failed: ' . $e->getMessage()]);
    exit();
}

// Upload folder is at instagram_clone_api/uploads/
// db.php is at instagram_clone_api/backend/config/db.php
// So ../../ goes up to instagram_clone_api/
define('UPLOAD_BASE', 'C:/MAMP/htdocs/instagram_clone_api/uploads/');

// Save base64 encoded file — used for Chrome/Web uploads
function saveBase64File($base64Data, $mimeType, $folder, $filename = '') {
    $uploadBase = 'C:/MAMP/htdocs/instagram_clone_api/uploads/';
    $dir = $uploadBase . $folder . '/';

    if (!is_dir($dir)) mkdir($dir, 0777, true);

    // Get extension from mime type
    $mimeMap = [
        'image/jpeg'      => 'jpg',
        'image/jpg'       => 'jpg',
        'image/png'       => 'png',
        'image/gif'       => 'gif',
        'image/webp'      => 'webp',
        'video/mp4'       => 'mp4',
        'video/quicktime' => 'mov',
    ];
    $ext = $mimeMap[$mimeType] ?? 'jpg';

    // If filename given, use its extension
    if (!empty($filename)) {
        $givenExt = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
        if (!empty($givenExt)) $ext = $givenExt;
    }

    $newFilename = uniqid() . '_' . time() . '.' . $ext;
    $destPath    = $dir . $newFilename;

    // Decode base64 and save
    $imageData = base64_decode($base64Data);
    if ($imageData === false || strlen($imageData) === 0) {
        return null;
    }

    if (file_put_contents($destPath, $imageData) !== false) {
        return $folder . '/' . $newFilename;
    }

    return null;
}

// Legacy multipart upload (for mobile)
function uploadFile($file, $folder = '') {
    $uploadBase = 'C:/MAMP/htdocs/instagram_clone_api/uploads/';
    $dir = $uploadBase . ($folder ? $folder . '/' : '');
    if (!is_dir($dir)) mkdir($dir, 0777, true);

    $ext = strtolower(pathinfo($file['name'] ?? 'file', PATHINFO_EXTENSION));
    if (empty($ext)) $ext = 'jpg';

    $filename = uniqid() . '_' . time() . '.' . $ext;
    $destPath = $dir . $filename;

    if (!empty($file['tmp_name']) && is_uploaded_file($file['tmp_name'])) {
        if (move_uploaded_file($file['tmp_name'], $destPath)) {
            return ($folder ? $folder . '/' : '') . $filename;
        }
    }
    if (!empty($file['tmp_name']) && file_exists($file['tmp_name'])) {
        if (copy($file['tmp_name'], $destPath)) {
            return ($folder ? $folder . '/' : '') . $filename;
        }
    }
    return null;
}