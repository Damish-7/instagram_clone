<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$result = ['php' => 'OK'];

// Test DB
try {
    $pdo = new PDO(
        "mysql:host=localhost;port=8889;dbname=instagram_clone;charset=utf8",
        "root", "root"
    );
    $result['database'] = 'Connected OK';
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $result['users_table'] = 'OK - ' . $row['count'] . ' users';

    // Check posts with media
    $stmt = $pdo->query("SELECT id, media_url FROM posts LIMIT 3");
    $posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $result['recent_posts'] = $posts;

} catch (PDOException $e) {
    $result['database'] = 'FAILED: ' . $e->getMessage();
}

// Check uploads folder
$uploadPath = __DIR__ . '/../uploads/';
$result['uploads_folder_exists'] = is_dir($uploadPath) ? 'YES' : 'NO - Create it!';
$result['uploads_path'] = realpath($uploadPath) ?: $uploadPath . ' (not found)';

// List uploaded files
if (is_dir($uploadPath)) {
    $files = [];
    foreach (['posts', 'stories', 'avatars', 'videos'] as $sub) {
        $subPath = $uploadPath . $sub;
        $files[$sub] = is_dir($subPath)
            ? count(array_diff(scandir($subPath), ['.', '..'])) . ' files'
            : 'folder missing';
    }
    $result['uploaded_files'] = $files;
}

echo json_encode($result, JSON_PRETTY_PRINT);