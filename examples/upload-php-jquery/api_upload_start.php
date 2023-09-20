<?php

require_once __DIR__ . '/vendor/autoload.php';

$api_config = new Medialab\Config\PrivateTokenConfig(MLAPI_MEDIALAB_URI, MLAPI_PRIVATE_TOKEN);
$medialab = new Medialab\Service\MedialabService($api_config);

// use upload reference as new folder name to place all files in.
// if no reference is given, we generate one ourselves.
$upload_reference = filter_var($_POST['reference'] ?: 'Upload ' . time(), FILTER_SANITIZE_STRING);

try {
	$folder_target = $medialab->execute('folders/' . MLAPI_ROOT_FOLDER_ID, 'POST', [
		'form_params' => [
			'name' => $upload_reference,
		],
	]);
	// In production we could store this folder_id with the relevant entities so we always know where to find the media.
//	$target_folder_id = $folder_target['folder_id'];
} catch(Exception $ex) {
	mltest_sendError($ex->getMessage());
	die();
}

try {
	$upload_id = $medialab->execute('upload/id', 'POST', [
		'form_params' => [
			'folder_id' => $folder_target['folder_id'],
			'hide_response' => true,
		]
	]);

	// return the URL that can be used for direct upload without additional authorization requirements.
	mltest_sendJson([
		'ulid' => $upload_id['ulid'],
		'url_upload_direct' => $upload_id['url_upload_direct'],
	]);
} catch(Exception $ex) {
	mltest_sendError($ex->getMessage());
}

