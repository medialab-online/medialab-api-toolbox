<?php

require_once __DIR__ . '/../config.php';

session_start();

/**
 * Send error response
 * @param string $error
 */
function mltest_sendError($error) {
	header("HTTP/1.1 400 Bad Request");
	header('Content-Type: application/json');
	echo json_encode([
		'error' => $error,
	]);
}

/**
 * Send json
 * @param mixed $data
 */
function mltest_sendJson($data) {
	header('Content-Type: application/json');
	echo json_encode($data);
}
