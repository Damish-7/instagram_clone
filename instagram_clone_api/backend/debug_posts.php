<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'config/db.php';

$result = [];

// Check recent posts in DB
$stmt = $pdo->query("SELECT id, user_id, caption, media_url, media_type, created_at FROM posts ORDER BY created_at DESC LIMIT 5");
$posts = $stmt->fetchAll();
$result['recent_posts'] = $posts;

// Check if files actually exist on disk
foreach ($posts as $post) {
    $mediaUrl  = $post['media_url'];
    $fullPath  = 'C:/MAMP/htdocs/instagram_clone_api/uploads/' . $mediaUrl;
    $result['file_check'][] = [
        'media_url'   => $mediaUrl,
        'full_path'   => $fullPath,
        'file_exists' => file_exists($fullPath),
        'file_size'   => file_exists($fullPath) ? filesize($fullPath) : 0,
        'public_url'  => 'http://localhost:8888/instagram_clone_api/uploads/' . $mediaUrl,
    ];
}

// Check uploads folder contents
$postsDir = 'C:/MAMP/htdocs/instagram_clone_api/uploads/posts/';
$result['posts_folder_files'] = is_dir($postsDir)
    ? array_diff(scandir($postsDir), ['.', '..'])
    : 'folder not found';

echo json_encode($result, JSON_PRETTY_PRINT);