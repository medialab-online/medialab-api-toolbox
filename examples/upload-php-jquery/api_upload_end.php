<?php

require_once __DIR__ . '/vendor/autoload.php';

$api_config = new Medialab\Config\PrivateTokenConfig(MLAPI_MEDIALAB_URI, MLAPI_PRIVATE_TOKEN);
$medialab = new Medialab\Service\MedialabService($api_config);

// we don't store the ulid in the session, but instead we require the browser to provide it to us on each call.
// this will help to prevent any issues with multiple simultaneous uploads by the same user.
if(empty($_POST['ulid'])) {
	mltest_sendError('No active upload found.');
	die();
}

$upload_id = filter_var($_POST['ulid'], FILTER_SANITIZE_STRING);

try {
	$upload_finish = $medialab->execute("upload/id/{$upload_id}", 'DELETE');
} catch(Exception $ex) {
	mltest_sendError($ex->getMessage());
	die();
}

if($upload_finish['status'] !== 'success') {
	mltest_sendError('There was a problem while uploading some of your files. Please try again!');
	die();
}

$files_ids = [];
foreach($upload_finish['files'] as $file) {
	$files_ids[] = $file['file_id'];
}

// now let's generate a share link with 7 days expiry for the files
try {
	$share_link = $medialab->execute('files/0/share/link', 'POST', [
		'form_params' => [
			'files' => $files_ids,
			'download' => 'source',
			'expires' => 7,
		],
	]);
	mltest_sendJson($share_link);
} catch(Exception $ex) {
	mltest_sendError($ex->getMessage());
	die();
}
