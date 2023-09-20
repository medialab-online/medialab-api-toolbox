<?php

/**
 * Rename this file to config.php and change the following information:
 */

/**
 * Full URL to your MediaLab tenant.
 */
define('MLAPI_MEDIALAB_URI', 'https://client.medialab.co');

/**
 * Personal Private Token (can be generated on your Profile page).
 */
define('MLAPI_PRIVATE_TOKEN', 'Your private token');

/**
 * In this example, we create a new folder per upload to store all files together.
 * The following folder id is used as root when creating these folders.
 */
define('MLAPI_ROOT_FOLDER_ID', 0);

/**
 * Uncomment the following lines to enable error reporting for testing purposes.
 */
//error_reporting(E_ALL);
//ini_set('display_errors', 1);
