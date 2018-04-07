<?php
/**
 * 	config.php
 * 	The main configuration file for the web app
 * 	Add your database configuration below
 */


//Check to see if the user is accessing the site from a remote location (internet) or from the local development environment
if(isset($_SERVER['SERVER_ADDR']) && ($_SERVER['SERVER_ADDR'] == '127.0.0.1')) {
	define('SERVER_ENV','local');
	define('APP_MODE','development');
	ini_set('display_errors',1);
	ini_set('error_reporting',E_ALL);
} else {
	define('SERVER_ENV','remote');
	define('APP_MODE','production');
	ini_set('display_errors',0);
}

//Define the database information
define('DB_HOST','localhost');
define('DB_PASS','');   //Your Username
define('DB_USER','');   //Your password

//Check for a HTTP_HOST - if it is set, use it, otherwise use the default
define('HOST', (isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : 'www.greenbizcheck.com'));

//Check to see the host, as we may change the database and other parameters based on the URL
switch(HOST) {

	case stripos(HOST,'ecobizcheck') !== false:
										define('DB_PREFIX','ecobiz_');
										define('GENERATOR','ecobizcheck');
										define('EN_LANGUAGE', 'US');
										define('ADMIN_TEMPLATE','EcoBizCheck');
										define('SITE_NAME', 'EcoBizCheck');
										define('SITE_EMAIL', 'info@ecobizcheck.com');
										break;
										
	default:							define('DB_PREFIX','greenbiz_');
										define('GENERATOR','greenbizcheck');
										define('EN_LANGUAGE', 'AU');
										define('ADMIN_TEMPLATE','GreenBizCheck');
										define('SITE_NAME', 'GreenBizCheck');
										define('SITE_EMAIL', 'info@greenbizcheck.com');
										break;
	
}

//Set the default timezone
date_default_timezone_set('Australia/Brisbane');

//Define Absolute URL paths
define('URL', 'http' . (isset($_SERVER['HTTPS']) ? 's' : '') . '://' . $_SERVER['HTTP_HOST'] . '/');
define('API_URL', URL . 'api/v2/');
define('GBCAPI', SERVER_ENV == 'local' ? 'http://api.greenbizcheck.local/v2' : 'https://api.greenbizcheck.com/v2');

//Define paths to system files and other locations
define('PATH_ROOT',preg_replace('/\\\\/','/',realpath(dirname(__FILE__))));
define('PATH_SHARED',PATH_ROOT.'/../shared');
define('PATH_STAMP_CACHE',PATH_SHARED.'/stamp_cache');
define('PATH_STAMP',PATH_SHARED.'/stamp');
define('PATH_FILE_UPLOAD',PATH_SHARED.'/file_upload/');
define('PATH_TMP_UPLOAD',PATH_SHARED.'/upload/temp');
define('PATH_SYSTEM',PATH_ROOT.'/system');
define('PATH_LIB',PATH_SYSTEM.'/lib');
define('PATH_PLUGIN',PATH_SYSTEM.'/plugin');
define('PATH_TEMPLATE',PATH_SYSTEM.'/template');
define('PATH_FOP',PATH_SYSTEM.'/fop');
define('PATH_STATIONERY',PATH_SYSTEM.'/emailStationary/');
define('EMAIL_DEBUG',false);
define('FOP_RENDERER','http://127.0.0.1:8501/fop-renderer/fop');
define('MYSQL_AUTOCOMMIT', true);
define('SITE_ROOT','http' . '://' . HOST);
define('PATH_PDF_MERGE', realpath(preg_replace("/\\\\/", "/",PATH_SHARED . "/pdf_merge")));
define('GBC_API_PRV_KEY', '6799ed452fa0a240fb9333dc5fe143f1a7f7bbddc4f00a8e869e79fa19ced495');
define('GBC_API_PUB_KEY', 'd1b6ab37a0b9a6aa263c3353baa35e7cf32f4f97152caacbe5171435611dab9f');

//Secure Paths
define('PATH_SECURE', '/members/');
define('PATH_LOGIN', PATH_SECURE . 'login/');
define('PATH_REGISTER', PATH_SECURE . 'register/');
define('PATH_RESET', PATH_SECURE . 'reset/');

//Set the Google Maps API Details
define('GOOGLE_MAPS_ENABLED', 'true');
define('GOOGLE_MAPS_USE_KEY', 'true');
define('GOOGLE_MAPS_API_KEY', 'AIzaSyBFSLXw2chw2pxhmwr-BaFWakRwxs2LXLo');
define('GOOGLE_MAPS_SENSOR', 'false');
define('GOOGLE_MAPS_URL', 'https://maps.googleapis.com/maps/api/');

//Google Recaptcha v2
define('GOOGLE_RECAPTCHA_SITE_KEY', '6Lc9iSITAAAAAL1_EFqrlSVQxu6_3cUtMW3pPG9u');
define('GOOGLE_RECAPTCHA_SECRET_KEY', '6Lc9iSITAAAAAMHnrftVouXUrHdKPUnpWfGX74iU');

//Google Invisible ReCaptcha
define('GOOGLE_INVISIBLE_RECAPTCHA_SITE_KEY', '6LfMAxkUAAAAAHxTpQGKFvOjzbGLMWbmOpohdztk');
define('GOOGLE_INVISIBLE_RECAPTCHA_SECRET_KEY', '6LfMAxkUAAAAAJS18iAYTOjLkSGGw6lfrvUpY07L');

//Set the PDFTK paths
if(SERVER_ENV == "local") {
	define('PDFTK_PATH','/opt/pdflabs/pdftk/bin');
	define('GS_PATH','/usr/local/bin');
} else {
	define('PDFTK_PATH','/usr/bin');
	define('GS_PATH','/usr/bin');
}

//Set the date at which assessments created after will not recieve stamps/certificates until audited with BV
define('CLIENT_AUDIT_CUTOVER_DATE','2011-07-01');
define('SALT', 'zRJ9M7gHX8U4URHrndf-iKrti&e4%Z$#');
define('SALT2', '2EFLL4JqqZ0WAr07FZ9eVyOKsaBfljMS');

// Salt used to create hash for session cookie.
// Allows session cookies to be used whilst still being able to verify the cookie has not been changed.
// See lib/sessionCookie class.
define('SESSION_SALT', '32dc6ed537c4b42c7784218d8222cac01fdb36327e3de5ea45b3821e4e87f96e815cb4217542b0369eaa4c2be5544d36a9be72f8033427aff10b6b4c98f85b8a4e62a2e28f8c565978ca6f436ee3d9c9');
define('SESSION_COOKIE', 'gbc_session');
define('SESSION_EXPIRY', null); // Session cookie
define('DOWNLOAD_SESSION_COOKIE', 'gbc_session_download');


/* Define Standard Responses */
/* Australian English */
define('PASSWORD_COMPLEXITY_ERROR', 'Password does not meet complexity requirements.');
define('PASSWORD_CONFIRM_ERROR', 'Password and password confirmation do not match.');
define('EMAIL_ADDRESS_ALREADY_REGISTERED', 'Email address is already registered.');
define('EMAIL_ADDRESS_INVALID', 'Email address is already registered.');
define('USER_INSERT_SUCCESS', 'User successfully created.');
define('USER_UPDATE_SUCCESS', 'User successfully updated.');
define('USER_DELETE_SUCCESS', 'User successfully deleted.');
define('USERS_DELETE_SUCCESS', 'Users successfully deleted.');
define('USER_DELETE_FAIL', 'No users deleted.');
define('ENTRY_PAGE_SAVE_SUCCESS', 'Entry progress successfully saved.');
define('ENTRY_SUBMIT_SUCCESS', 'Entry successfully submitted.');
define('USER_DASHBOARD_ACCESS_SUCCESS', 'User dashboard access successfully updated.');
define('USER_DASHBOARD_ENTITY_SUCCESS', 'User entity access updated.');
define('USER_DASHBOARD_ENTRY_SUCCESS', 'User entry access updated.');
define('USER_DASHBOARD_ACCESS_FAIL', 'User dashboard access update failed.');
define('USER_DASHBOARD_ENTITY_FAIL', 'User entity access update failed.');
define('USER_DASHBOARD_ENTRY_FAIL', 'User entry access update failed.');

if(get_magic_quotes_gpc()) {
    function stripslashes_deep($value) {
        $value = is_array($value) ? array_map('stripslashes_deep', $value) : stripslashes($value);
        return $value;
    }
    $_POST = array_map('stripslashes_deep',$_POST);
    $_GET = array_map('stripslashes_deep',$_GET);
    $_COOKIE = array_map('stripslashes_deep',$_COOKIE);
    $_REQUEST = array_map('stripslashes_deep',$_REQUEST);
}

function classLoader($class) {
	if(is_file(PATH_LIB.'/'.$class.'.class.php')) {
		require_once(PATH_LIB.'/'.$class.'.class.php');
	} elseif(is_file(PATH_PLUGIN.'/'.$class.'/'.$class.'.class.php')) {
		require_once(PATH_PLUGIN.'/'.$class.'/'.$class.'.class.php');
	}
}
spl_autoload_register('classLoader');

?>
