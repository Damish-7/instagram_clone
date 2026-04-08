<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// This file is at: backend/path_debug.php
$backendDir  = __DIR__;                          // backend/
$uploadsDir  = __DIR__ . '/../uploads/';         // backend/../uploads = uploads/
$uploadsDir2 = __DIR__ . '/../../uploads/';      // Wrong - goes above backend

$result = [
    'this_file_is_at'       => $backendDir,
    'uploads_path_option1'  => realpath($uploadsDir)  ?: $uploadsDir  . ' (NOT FOUND)',
    'uploads_path_option2'  => realpath($uploadsDir2) ?: $uploadsDir2 . ' (NOT FOUND)',
    'option1_exists'        => is_dir($uploadsDir),
    'option2_exists'        => is_dir($uploadsDir2),
    'option1_writable'      => is_writable($uploadsDir),
];

// Also list what's actually in the uploads folder
if (is_dir($uploadsDir)) {
    $result['uploads_contents'] = scandir($uploadsDir);
}

// config/db.php is one level deeper
$fromConfig = __DIR__ . '/config/../../../uploads/';
$result['from_config_path'] = realpath(__DIR__ . '/config/../../uploads/') 
    ?: __DIR__ . '/config/../../uploads/ (NOT FOUND)';

echo json_encode($result, JSON_PRETTY_PRINT);