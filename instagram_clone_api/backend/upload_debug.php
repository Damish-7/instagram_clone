<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$result = [
    'method'       => $_SERVER['REQUEST_METHOD'],
    'post_keys'    => array_keys($_POST),
    'files_keys'   => array_keys($_FILES),
    'upload_dir'   => __DIR__ . '/../uploads/',
    'dir_exists'   => is_dir(__DIR__ . '/../uploads/'),
    'dir_writable' => is_writable(__DIR__ . '/../uploads/'),
];

if (!empty($_FILES)) {
    foreach ($_FILES as $key => $file) {
        $result['file_info'][$key] = [
            'name'     => $file['name'],
            'type'     => $file['type'],
            'size'     => $file['size'],
            'error'    => $file['error'],
            'tmp_name' => $file['tmp_name'],
            'tmp_exists' => file_exists($file['tmp_name']),
        ];
    }
}

// Try a test write
$testFile = __DIR__ . '/../uploads/test_write.txt';
$writeOk = file_put_contents($testFile, 'test') !== false;
$result['can_write_to_uploads'] = $writeOk ? 'YES' : 'NO';
if ($writeOk) unlink($testFile);

echo json_encode($result, JSON_PRETTY_PRINT);