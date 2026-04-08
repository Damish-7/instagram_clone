<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$file = $_GET['file'] ?? '';

// Security: prevent directory traversal
$file = str_replace(['..', '\\', "\0"], '', $file);
$file = ltrim($file, '/');

$basePath = 'C:/MAMP/htdocs/instagram_clone_api/uploads/';
$fullPath = $basePath . $file;

if (!file_exists($fullPath)) {
    http_response_code(404);
    echo json_encode(['error' => 'File not found: ' . $file]);
    exit();
}

// Detect MIME type
$ext = strtolower(pathinfo($fullPath, PATHINFO_EXTENSION));
$mimeTypes = [
    'jpg'  => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'png'  => 'image/png',
    'gif'  => 'image/gif',
    'webp' => 'image/webp',
    'mp4'  => 'video/mp4',
    'mov'  => 'video/quicktime',
];

$mime = $mimeTypes[$ext] ?? 'application/octet-stream';
header("Content-Type: $mime");
header("Content-Length: " . filesize($fullPath));
header("Cache-Control: public, max-age=86400");

readfile($fullPath);
exit();