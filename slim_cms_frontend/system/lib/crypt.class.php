<?php
class crypt {

	private static $encrypt_method = 'AES-256-CBC';
	private static $hash = 'sha256';

	public static function encrypt($string) {
		return base64_encode(openssl_encrypt($string, self::$encrypt_method, SALT, 0, substr(hash(self::$hash, SALT2), 0, 16)));
	}

	public static function decrypt($string) {
		return openssl_decrypt(base64_decode($string), self::$encrypt_method, SALT, 0, substr(hash(self::$hash, SALT2), 0, 16));
	}
}
?>