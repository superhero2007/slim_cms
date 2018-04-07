<?php
class PayPalEWP {
  var $certificate;	// Certificate resource
  var $certificateFile;	// Path to the certificate file

  var $privateKey;	// Private key resource (matching certificate)
  var $privateKeyFile;	// Path to the private key file

  var $paypalCertificate;	// PayPal public certificate resource
  var $paypalCertificateFile;	// Path to PayPal public certificate file

  var $certificateID; // ID assigned by PayPal to the $certificate.

  var $tempFileDirectory;

  function PayPal() {
  }

  /*
    setCertificate: set the client certificate and private key pair.

    $certificateFilename - The path to the client certificate

    $keyFilename - The path to the private key corresponding to the certificate

    Returns: TRUE iff the private key matches the certificate.
   */

  function setCertificate($certificateFilename, $privateKeyFilename) {
    $result = FALSE;

    if (is_readable($certificateFilename) && is_readable($privateKeyFilename)) {
      $certificate =
	openssl_x509_read(file_get_contents($certificateFilename));

      $privateKey =
	openssl_get_privatekey(file_get_contents($privateKeyFilename));

      if (($certificate !== FALSE) &&
	  ($privateKey !== FALSE) &&
	  openssl_x509_check_private_key($certificate, $privateKey)) {
	$this->certificate = $certificate;
	$this->certificateFile = $certificateFilename;

	$this->privateKey = $privateKey;
	$this->privateKeyFile = $privateKeyFilename;
	
	$result = TRUE;
      }
    }

    return $result;
  }

  /*
    setPayPalCertificate: Sets the PayPal certificate

    $fileName - The path to the PayPal certificate.

    Returns: TRUE iff the certificate is read successfully, FALSE otherwise.
   */

  function setPayPalCertificate($fileName) {
    if (is_readable($fileName)) {
      $certificate = openssl_x509_read(file_get_contents($fileName));

      if ($certificate !== FALSE) {
	$this->paypalCertificate = $certificate;
	$this->paypalCertificateFile = $fileName;

	return TRUE;
      }
    }

    return FALSE;
  }

  /*
    setCertificateID: Sets the ID assigned by PayPal to the client certificate

    $id - The certificate ID assigned when the certificate was uploaded to PayPal
   */

  function setCertificateID($id) {
    $this->certificateID = $id;
  }

  /*
    setTempFileDirectory: Sets the directory into which temporary files are written.

    $directory - Directory in which to write temporary files.

    Returns: TRUE iff directory is usable.
   */

  function setTempFileDirectory($directory) {
    if (is_dir($directory) && is_writable($directory)) {
      $this->tempFileDirectory = $directory;
      return TRUE;
    } else {
      return FALSE;
    }
  }

  /*
    encryptButton: Using the previously set certificates and tempFileDirectory
    encrypt the button information.

    $parameters - Array with parameter names as keys.

    Returns: The encrypted string for the _s_xclick button form field.
   */

  function encryptButton($parameters) {
    // Check encryption data is available.

    if (($this->certificateID == '') ||
	!IsSet($this->certificate) ||
	!IsSet($this->paypalCertificate)) {
      return FALSE;
    }

    $clearText = '';
    $encryptedText = '';

    // Compose clear text data.

    $clearText = 'cert_id=' . $this->certificateID;

    foreach (array_keys($parameters) as $key) {
      $clearText .= "\n{$key}={$parameters[$key]}";
    }

    $clearFile = tempnam($this->tempFileDirectory, 'clear_');
    $signedFile = preg_replace('/clear/', 'signed', $clearFile);
    $encryptedFile = preg_replace('/clear/', 'encrypted', $clearFile);

    $out = fopen($clearFile, 'wb');
    fwrite($out, $clearText);
    fclose($out);

    if (!openssl_pkcs7_sign($clearFile, $signedFile, $this->certificate, $this->privateKey, array(), PKCS7_BINARY)) {
      return FALSE;
    }

    $signedData = explode("\n\n", file_get_contents($signedFile));

    $out = fopen($signedFile, 'wb');
    fwrite($out, base64_decode($signedData[1]));
    fclose($out);

    if (!openssl_pkcs7_encrypt($signedFile, $encryptedFile, $this->paypalCertificate, array(), PKCS7_BINARY)) {
      return FALSE;
    }

    $encryptedData = explode("\n\n", file_get_contents($encryptedFile));

    $encryptedText = $encryptedData[1];

    @unlink($clearFile);
    @unlink($signedFile);
    @unlink($encryptedFile);

    return $encryptedText;
  }
}
?>