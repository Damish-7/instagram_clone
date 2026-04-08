<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$uploadsDir = 'C:\\MAMP\\htdocs\\instagram_clone_api\\uploads\\avatars\\';
$files = array_diff(scandir($uploadsDir), ['.', '..']);

$result = [];
foreach ($files as $file) {
    $path = $uploadsDir . $file;
    $size = filesize($path);
    $first50 = file_get_contents($path, false, null, 0, 50);
    $first10hex = bin2hex(substr($first50, 0, 10));
    $first50text = substr($first50, 0, 50);

    $isValidPng  = str_starts_with($first10hex, '89504e47');
    $isValidJpeg = str_starts_with($first10hex, 'ffd8ff');

    $result[] = [
        'file'          => $file,
        'size_bytes'    => $size,
        'first_hex'     => $first10hex,
        'first_text'    => $first50text,
        'valid_png'     => $isValidPng,
        'valid_jpeg'    => $isValidJpeg,
        'verdict'       => $isValidPng ? 'VALID PNG'
                        : ($isValidJpeg ? 'VALID JPEG'
                        : 'CORRUPTED - content: ' . substr($first50text, 0, 30)),
    ];
}

echo json_encode($result, JSON_PRETTY_PRINT);