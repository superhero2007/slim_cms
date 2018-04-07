<?php
class mailer {
	private $db;
	
	public static function deliver($to, $from, $subject, $message, $attachments = array(), $bcc = null) {

		if (is_array($to)) {
			$to = implode(', ', $to);
		}
		$headers =
			"From: $from\r\n".
			"Reply-To: $from\r\n".
			"Return-Path: $from\r\n".
			"Organization: GreenBizCheck\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n";
			
		$boundry = md5(uniqid(microtime()));
		
		$body =
			"--".$boundry."\r\n".
			"Content-Type: text/html; charset=UTF-8\r\n".
			"Content-Disposition: inline\r\n\r\n".
			$message."\r\n";
			
		$headers .=
			"Content-Type: multipart/mixed; boundary=\"".$boundry."\"\r\n";
			
		//Added so that we can CC the account owner if needed
		if ($bcc != NULL) {
			$headers .= "Cc: $bcc\r\n";
		}
			
		foreach($attachments as $filename => $data) {
			$body .= 
				"--".$boundry."\r\n".
				"Content-Transfer-Encoding: base64\r\n".
				"Content-Type: ".self::filenameMimeType($filename)."\r\n".
				"Content-Size: ".strlen($data)."\r\n".
				"Content-Disposition: attachment; filename=\"".$filename."\"\r\n\r\n".
				chunk_split(base64_encode($data))."\r\n\r\n";
		}
		
		$body .=
			"--".$boundry."--\r\n";
			
		return mail($to, $subject, $body, $headers, '-finfo@greenbizcheck.com');
	}
	
	public static function nameAndEmail($name, $email) {
		return '"'.$name.'" <'.$email.'>';
	}
	
	public function __construct($db) {
		$this->db = $db;
	}
	
	public function processTasks() {
		$startTime = microtime(true);
		if($result = $this->db->query(sprintf('
			SELECT
				`task`.`task_id`,
				`task`.`to`,
				`task`.`subject`,
				`task`.`body`,
				`task`.`headers`
			FROM `%1$s`.`task`
			WHERE `task`.`status` = "pending"
			AND `task`.`schedule` <= NOW();
		',
			DB_PREFIX.'mailer'
		))) {
			while($row = $result->fetch_object()) {
				$this->sendEmail($row->to,$row->subject,$row->body,$row->headers);
				$this->changeTaskStatus($row->task_id,'completed');
				if(microtime(true) - $startTime >= 30) { break; }
			}
			$result->close();
		}
		return;
	}
	
	public function addTask($stationary_id,$toName,$toEmail,$vars,$schedule,$attachments=array()) {
		if($result = $this->db->query(sprintf('
			SELECT
				`stationary`.`subject`,
				`stationary`.`body`
			FROM `%1$s`.`stationary`
			WHERE `stationary_id` = %2$d;
		',
			DB_PREFIX.'mailer',
			$this->db->escape_string($stationary_id)
		))) {
			if($row = $result->fetch_object()) {
				$subject = $row->subject;
				$body = $row->body;
			}
			$result->close();
		} else {
			return(false);
		}
		$to = $toName.' <'.$toEmail.'>';
		foreach($vars as $key => $val) {
			$subject = str_replace('%'.$key.'%',$val,$subject);
			$body = str_replace('%'.$key.'%',$val,$body);
		}
		$body = 
			"<html>\r\n".
			"<body>\r\n".
			$body."\r\n".
			"<p>Kind regards,</p>\r\n".
			"<p>The GreenBizCheck Team<br />\r\n".
			"<a href=\"http://www.greenbizcheck.com/\">www.greenbizcheck.com</a></p>\r\n".
			"<p><strong><em>Please consider the environment before printing this email. We are losing 40 million acres of oxygen producing forests through logging and land clearing every year.</em></strong></p>\r\n".
			"</body>\r\n".
			"</html>\r\n";
			
		$headers =
			"From: GreenBizCheck <info@greenbizcheck.com>\r\n".
			"Reply-To: GreenBizCheck <info@greenbizcheck.com>\r\n".
			"Return-Path: GreenBizCheck <info@greenbizcheck.com>\r\n".
			"Organization: GreenBizCheck\r\n".
			"X-Priority: 3\r\n".
			"X-Mailer: PHP". phpversion() ."\r\n".
			"MIME-Version: 1.0\r\n";
			
		if(count($attachments) > 0) {
			$boundry = md5(uniqid(microtime()));
			$body =
				"--".$boundry."\r\n".
				"Content-Type: text/html; charset=UTF-8\r\n".
				"Content-Disposition: inline\r\n\r\n".
				$body."\r\n";
			$headers .=
				"Content-Type: multipart/mixed; boundary=\"".$boundry."\"\r\n";
			foreach($attachments as $filename => $data) {
				$body .= 
					"--".$boundry."\r\n".
					"Content-Transfer-Encoding: base64\r\n".
					"Content-Disposition: attachment; filename=\"".$filename."\"\r\n\r\n".
					chunk_split(base64_encode($data))."\r\n\r\n";
			}
			$body .=
				"--".$boundry."--\r\n";
		} else {
			$headers .=
				"Content-Type: text/html; charset=UTF-8\r\n";
		}
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`task` SET
				`stationary_id` = %2$d,
				`to` = "%3$s",
				`subject` = "%4$s",
				`body` = "%5$s",
				`headers` = "%6$s",
				`schedule` = FROM_UNIXTIME(%7$d),
				`created` = NOW(),
				`status` = "%8$s";
		',
			DB_PREFIX.'mailer',
			$this->db->escape_string($stationary_id),
			$this->db->escape_string($to),
			$this->db->escape_string($subject),
			$this->db->escape_string($body),
			$this->db->escape_string($headers),
			$this->db->escape_string($schedule),
			($schedule <= time() ? 'completed' : 'pending')
		));
		if($schedule <= time()) {
			$this->sendEmail($to,$subject,$body,$headers);
		}
		return($this->db->insert_id);
	}
	
	public function rescheduleTask($task_id,$schedule) {
		$this->db->query(sprintf('
			UPDATE `%1$s`.`task` SET
				`schedule` = "%2$s"
			WHERE `task_id` = %3$d;
		',
			DB_PREFIX.'mailer',
			date("Y-m-d H:i:s",$schedule),
			$this->db->escape_string($task_id)
		));
		return;
	}
	
	private function sendEmail($to,$subject,$body,$headers) {
		if(EMAIL_DEBUG == false) {
			mail($to,$subject,$body,$headers, '-finfo@greenbizcheck.com');
		} else {		
			mail('debugger <td@greenbizcheck.com>',$subject,$body,$headers,'-finfo@greenbizcheck.com');
		}
		return;
	}
	
	private function changeTaskStatus($task_id,$status) {
		$this->db->query(sprintf('
			UPDATE %1$s.task SET
				status = "%2$s"
			WHERE task_id = %3$d;
		',
			DB_PREFIX.'mailer',
			$this->db->escape_string($status),
			$this->db->escape_string($task_id)
		));
		return;
	}
	
	private static function filenameMimeType($filename) {
		$fileParts = explode('.', $filename);
		
		if ($fileParts && count($fileParts) > 1) {
			$ext = strtolower($fileParts[count($fileParts) - 1]);
			switch ($ext) {
				case '323':		 return 'text/h323';
				case 'acx':		 return 'application/internet-property-stream';
				case 'ai':		 return 'application/postscript';
				case 'aif':		 return 'audio/x-aiff';
				case 'aifc':	 return 'audio/x-aiff';
				case 'aiff':	 return 'audio/x-aiff';
				case 'asf':		 return 'video/x-ms-asf';
				case 'asr':		 return 'video/x-ms-asf';
				case 'asx':		 return 'video/x-ms-asf';
				case 'au':		 return 'audio/basic';
				case 'avi':		 return 'video/x-msvideo';
				case 'axs':		 return 'application/olescript';
				case 'bas':		 return 'text/plain';
				case 'bcpio':	 return 'application/x-bcpio';
				case 'bin':		 return 'application/octet-stream';
				case 'bmp':		 return 'image/bmp';
				case 'c':		 return 'text/plain';
				case 'cat':		 return 'application/vnd.ms-pkiseccat';
				case 'cdf':		 return 'application/x-netcdf';
				case 'cdf':		 return 'application/x-cdf';
				case 'cer':		 return 'application/x-x509-ca-cert';
				case 'class':	 return 'application/octet-stream';
				case 'clp':		 return 'application/x-msclip';
				case 'cmx':		 return 'image/x-cmx';
				case 'cod':		 return 'image/cis-cod';
				case 'cpio':	 return 'application/x-cpio';
				case 'crd':		 return 'application/x-mscardfile';
				case 'crl':		 return 'application/pkix-crl';
				case 'crt':		 return 'application/x-x509-ca-cert';
				case 'csh':		 return 'application/x-csh';
				case 'css':		 return 'text/css';
				case 'dcr':		 return 'application/x-director';
				case 'der':		 return 'application/x-x509-ca-cert';
				case 'dir':		 return 'application/x-director';
				case 'dll':		 return 'application/x-msdownload';
				case 'dms':		 return 'application/octet-stream';
				case 'doc':		 return 'application/msword';
				case 'dot':		 return 'application/msword';
				case 'dvi':		 return 'application/x-dvi';
				case 'dxr':		 return 'application/x-director';
				case 'eps':		 return 'application/postscript';
				case 'etx':		 return 'text/x-setext';
				case 'evy':		 return 'application/envoy';
				case 'exe':		 return 'application/octet-stream';
				case 'fif':		 return 'application/fractals';
				case 'flr':		 return 'x-world/x-vrml';
				case 'gif':		 return 'image/gif';
				case 'gtar':	 return 'application/x-gtar';
				case 'gz':		 return 'application/x-gzip';
				case 'h':		 return 'text/plain';
				case 'hdf':		 return 'application/x-hdf';
				case 'hlp':		 return 'application/winhlp';
				case 'hqx':		 return 'application/mac-binhex40';
				case 'hta':		 return 'application/hta';
				case 'htc':		 return 'text/x-component';
				case 'htm':		 return 'text/html';
				case 'html':	 return 'text/html';
				case 'htt':		 return 'text/webviewhtml';
				case 'ico':		 return 'image/x-icon';
				case 'ief':		 return 'image/ief';
				case 'iii':		 return 'application/x-iphone';
				case 'ins':		 return 'application/x-internet-signup';
				case 'isp':		 return 'application/x-internet-signup';
				case 'jfif':	 return 'image/pipeg';
				case 'jpe':		 return 'image/jpeg';
				case 'jpeg':	 return 'image/jpeg';
				case 'jpg':		 return 'image/jpeg';
				case 'js':		 return 'application/x-javascript';
				case 'latex':	 return 'application/x-latex';
				case 'lha':		 return 'application/octet-stream';
				case 'lsf':		 return 'video/x-la-asf';
				case 'lsx':		 return 'video/x-la-asf';
				case 'lzh':		 return 'application/octet-stream';
				case 'm13':		 return 'application/x-msmediaview';
				case 'm14':		 return 'application/x-msmediaview';
				case 'm3u':		 return 'audio/x-mpegurl';
				case 'man':		 return 'application/x-troff-man';
				case 'mdb':		 return 'application/x-msaccess';
				case 'me':		 return 'application/x-troff-me';
				case 'mht':		 return 'message/rfc822';
				case 'mhtml':	 return 'message/rfc822';
				case 'mid':		 return 'audio/mid';
				case 'mny':		 return 'application/x-msmoney';
				case 'mov':		 return 'video/quicktime';
				case 'movie':	 return 'video/x-sgi-movie';
				case 'mp2':		 return 'video/mpeg';
				case 'mp3':		 return 'audio/mpeg';
				case 'mpa':		 return 'video/mpeg';
				case 'mpe':		 return 'video/mpeg';
				case 'mpeg':	 return 'video/mpeg';
				case 'mpg':		 return 'video/mpeg';
				case 'mpp':		 return 'application/vnd.ms-project';
				case 'mpv2':	 return 'video/mpeg';
				case 'ms':		 return 'application/x-troff-ms';
				case 'msg':		 return 'application/vnd.ms-outlook';
				case 'mvb':		 return 'application/x-msmediaview';
				case 'nc':		 return 'application/x-netcdf';
				case 'nws':		 return 'message/rfc822';
				case 'oda':		 return 'application/oda';
				case 'p10':		 return 'application/pkcs10';
				case 'p12':		 return 'application/x-pkcs12';
				case 'p7b':		 return 'application/x-pkcs7-certificates';
				case 'p7c':		 return 'application/x-pkcs7-mime';
				case 'p7m':		 return 'application/x-pkcs7-mime';
				case 'p7r':		 return 'application/x-pkcs7-certreqresp';
				case 'p7s':		 return 'application/x-pkcs7-signature';
				case 'pbm':		 return 'image/x-portable-bitmap';
				case 'pdf':		 return 'application/pdf';
				case 'pfx':		 return 'application/x-pkcs12';
				case 'pgm':		 return 'image/x-portable-graymap';
				case 'pko':		 return 'application/ynd.ms-pkipko';
				case 'pma':		 return 'application/x-perfmon';
				case 'pmc':		 return 'application/x-perfmon';
				case 'pml':		 return 'application/x-perfmon';
				case 'pmr':		 return 'application/x-perfmon';
				case 'pmw':		 return 'application/x-perfmon';
				case 'pnm':		 return 'image/x-portable-anymap';
				case 'pot':		 return 'application/vnd.ms-powerpoint';
				case 'ppm':		 return 'image/x-portable-pixmap';
				case 'pps':		 return 'application/vnd.ms-powerpoint';
				case 'ppt':		 return 'application/vnd.ms-powerpoint';
				case 'prf':		 return 'application/pics-rules';
				case 'ps':		 return 'application/postscript';
				case 'pub':		 return 'application/x-mspublisher';
				case 'qt':		 return 'video/quicktime';
				case 'ra':		 return 'audio/x-pn-realaudio';
				case 'ram':		 return 'audio/x-pn-realaudio';
				case 'ras':		 return 'image/x-cmu-raster';
				case 'rgb':		 return 'image/x-rgb';
				case 'rmi':		 return 'audio/mid';
				case 'roff':	 return 'application/x-troff';
				case 'rtf':		 return 'application/rtf';
				case 'rtx':		 return 'text/richtext';
				case 'scd':		 return 'application/x-msschedule';
				case 'sct':		 return 'text/scriptlet';
				case 'setpay':	 return 'application/set-payment-initiation';
				case 'setreg':	 return 'application/set-registration-initiation';
				case 'sh':		 return 'application/x-sh';
				case 'shar':	 return 'application/x-shar';
				case 'sit':		 return 'application/x-stuffit';
				case 'snd':		 return 'audio/basic';
				case 'spc':		 return 'application/x-pkcs7-certificates';
				case 'spl':		 return 'application/futuresplash';
				case 'src':		 return 'application/x-wais-source';
				case 'sst':		 return 'application/vnd.ms-pkicertstore';
				case 'stl':		 return 'application/vnd.ms-pkistl';
				case 'stm':		 return 'text/html';
				case 'sv4cpio':	 return 'application/x-sv4cpio';
				case 'sv4crc':	 return 'application/x-sv4crc';
				case 'svg':		 return 'image/svg+xml';
				case 'swf':		 return 'application/x-shockwave-flash';
				case 't':		 return 'application/x-troff';
				case 'tar':		 return 'application/x-tar';
				case 'tcl':		 return 'application/x-tcl';
				case 'tex':		 return 'application/x-tex';
				case 'texi':	 return 'application/x-texinfo';
				case 'texinfo':	 return 'application/x-texinfo';
				case 'tgz':		 return 'application/x-compressed';
				case 'tif':		 return 'image/tiff';
				case 'tiff':	 return 'image/tiff';
				case 'tr':		 return 'application/x-troff';
				case 'trm':		 return 'application/x-msterminal';
				case 'tsv':		 return 'text/tab-separated-values';
				case 'txt':		 return 'text/plain';
				case 'uls':		 return 'text/iuls';
				case 'ustar':	 return 'application/x-ustar';
				case 'vcf':		 return 'text/x-vcard';
				case 'vrml':	 return 'x-world/x-vrml';
				case 'wav':		 return 'audio/x-wav';
				case 'wcm':		 return 'application/vnd.ms-works';
				case 'wdb':		 return 'application/vnd.ms-works';
				case 'wks':		 return 'application/vnd.ms-works';
				case 'wmf':		 return 'application/x-msmetafile';
				case 'wps':		 return 'application/vnd.ms-works';
				case 'wri':		 return 'application/x-mswrite';
				case 'wrl':		 return 'x-world/x-vrml';
				case 'wrz':		 return 'x-world/x-vrml';
				case 'xaf':		 return 'x-world/x-vrml';
				case 'xbm':		 return 'image/x-xbitmap';
				case 'xla':		 return 'application/vnd.ms-excel';
				case 'xlc':		 return 'application/vnd.ms-excel';
				case 'xlm':		 return 'application/vnd.ms-excel';
				case 'xls':		 return 'application/vnd.ms-excel';
				case 'xlt':		 return 'application/vnd.ms-excel';
				case 'xlw':		 return 'application/vnd.ms-excel';
				case 'xof':		 return 'x-world/x-vrml';
				case 'xpm':		 return 'image/x-xpixmap';
				case 'xwd':		 return 'image/x-xwindowdump';
				case 'z':		 return 'application/x-compress';
				case 'zip':		 return 'application/zip';
			}
		}
		
		return 'application/octet-stream';
	}
	
}
?>