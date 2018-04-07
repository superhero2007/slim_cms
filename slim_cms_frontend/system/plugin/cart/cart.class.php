<?php
class cart extends plugin {
	private $client;
	private $certification;
	
	public function getProducts() {
		if(($this->client = $GLOBALS['core']->plugin->clients->client) == false) return;
		$this->certification = new certification($GLOBALS['core']->db);
		if(isset($_POST['action']) && $_POST['action'] == 'certify') {
			$error = array();
			$fields = array(
				array('Number of employees','num_employees',1,'int'),
				array('agree','agree',1)
			);
			$data = validateForm::validateDetails($fields,$error);
			$data['num_employees'] = floor($data['num_employees']);
			if(!isset($error['num_employees']) && $data['num_employees'] <= 0) {
				$error['num_employees'] = 'Number of staff must be greater than zero';
			}
			if(validateForm::writeErrors($GLOBALS['core']->doc,$this->node,$error)) return;
			while($certLevel = current($this->certification->certLevels)) {
				if($data['num_employees'] >= $certLevel->min_staff) {
					break;
				}
				next($this->certLevels);
			}

			$this->node->setAttribute('mode','confirm');
			$this->node->setAttribute('num_employees',$data['num_employees']);
			$this->node->appendChild($GLOBALS['core']->doc->createElement('certLevel'));
			foreach($certLevel as $key => $val) {
				$this->node->lastChild->setAttribute($key,$val);
			}
			$this->paypalForm($certLevel->cert_level_id);
		}
			if(isset($_POST['action']) && $_POST['action'] == 'invoice') {
				$this->node->setAttribute('mode','invoice');
				$this->certification->createInvoice($certLevel->cert_level_id,$this->client);
			}
		return;
	}
	
	private function paypalForm($cert_level_id) {	
		$ppData = array(
			'cmd'			=> '_cart',
			'business' 		=> 'info@greenbizcheck.com',
			'charset'		=> "UTF-8",
			'custom'		=> $this->client->client_id.'-'.$cert_level_id,
			'currency_code'	=> 'AUD',
			'upload'		=> '1',
			'no_shipping'	=> '1',
			'no_note'		=> '1',
			'return'		=> 'http://www.greenbizcheck.com/certify/thankyou/',
			'cancel_return'	=> 'http://www.greenbizcheck.com/',
			'address1'		=> $this->client->address_line_1,
			'address2'		=> $this->client->address_line_2,
			'city'			=> $this->client->suburb,
			'state'			=> $this->client->state,
			'country'		=> $this->client->country,
			'zip'			=> $this->client->postcode,
			'first_name'	=> $this->client->contact[0]->firstname,
			'last_name'		=> $this->client->contact[0]->lastname,
			'email'			=> $this->client->contact[0]->email,
			'phone'			=> $this->client->contact[0]->phone
		);
		$ppData['item_name_1'] = 'GreenBizCheck Environmental Certification';
		$ppData['amount_1'] = $this->certification->certLevels[$cert_level_id]->member_fee;
		$ppData['quantity_1'] = 1;
		if(function_exists('openssl_x509_read')) {
			$paypal = new PayPalEWP();
			$paypal->setTempFileDirectory('/tmp');
			$paypal->setCertificate(PATH_SYSTEM.'/cert/my-pubcert.pem',PATH_SYSTEM.'/cert/my-prvkey.pem');
			$paypal->setCertificateID('T7CC2ES5UK792');
			$paypal->setPayPalCertificate(PATH_SYSTEM.'/cert/paypal-pubcert.pem');
			$this->node->appendChild($GLOBALS['core']->doc->createElement(
				'paypal',
				"-----BEGIN PKCS7-----".str_replace("\n","",$paypal->encryptButton($ppData))."-----END PKCS7-----"
			));
		}
		return;
	}
}
?>