<?php
class pos extends plugin {
	private $currency_id	= 1;
	private $products		= array();
	private $productDesctiptions = array();
	private $cartItems		= array();
	private $currencies		= array();
	private $subtotal		= 0;
	private $discount		= 0;
	private $total			= 0;
	private $discountable_total = 0;
	private $coupon			= false;
	private $client			= false;
	private $currency_tax_rate = 0;
	
	public function __construct() {
		$this->getCurrencies();
		$this->getProducts();
		$this->getProductDescriptions();
	}
	
	public function getCart() {
		$this->getItems();
		$this->addItem();
		$this->getCoupon();
		
		foreach($this->currencies as $currency) {
			$currencyNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('currency'));
			$currencyNode->setAttribute('currency_id',$currency->currency_id);
			$currencyNode->setAttribute('code',$currency->code);
			$currencyNode->setAttribute('symbol',$currency->symbol);
			$currencyNode->setAttribute('symbol_pos',$currency->symbol_pos);
			$currencyNode->setAttribute('tax_exempt',$currency->tax_exempt);
			$currencyNode->setAttribute('description',$currency->description);
			$currencyNode->setAttribute('tax_name',$currency->tax_name);
			$currencyNode->setAttribute('tax_rate',$currency->tax_rate);
			if($this->currency_id == $currency->currency_id) {
				$currencyNode->setAttribute('selected',1);
				$this->currency_tax_rate = $currency->tax_rate;
			}
		}
		foreach($this->products as $product) {
			$productNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('product'));
			$productNode->setAttribute('product_id',$product->product_id);
			$productNode->setAttribute('name',$product->name);
			$productNode->setAttribute('price',$product->price);
			foreach($this->productDescriptions as $productDescription) {
				if($productDescription->product_id == $product->product_id) {
					$productDescriptionNode = $productNode->appendChild($GLOBALS['core']->doc->createElement('productDescription'));
					$productDescriptionNode->setAttribute('product_description_id',$productDescription->product_description_id);
					$productDescriptionNode->setAttribute('product_id',$productDescription->product_id);
					$productDescriptionNode->setAttribute('description',$productDescription->description);
				}
			}
		}
		foreach($this->cartItems as $item_id => $item) {
			$this->total = $this->subtotal += $item->quantity * $this->products[$item->product_id]->price;			
			$itemNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('item'));
			$itemNode->setAttribute('item_id',$item_id);
			$itemNode->setAttribute('product_id',$item->product_id);
			$itemNode->setAttribute('quantity',$item->quantity);
			$itemNode->setAttribute('timestamp',$item->timestamp);
			foreach($this->getSuggestions($item->product_id) as $suggestion) {
				$suggestionNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('suggestion'));
				$suggestionNode->setAttribute('suggestion_id',$suggestion->suggestion_id);
				$suggestionNode->setAttribute('product_id',$suggestion->product_id);
			}
		}
		$summaryNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('summary'));
		$summaryNode->setAttribute('subtotal',$this->subtotal);
		//$summaryNode->setAttribute('tax',round($this->subtotal / 11,2));
		$summaryNode->setAttribute('tax',round($this->subtotal - ($this->subtotal / (1 + ($this->currency_tax_rate * 0.01))),2));
		
		//Checks to see if we are on a partner site first.  If we are a coupon can't be used as we may be giving a discount already
		if($this->getJVPartnerDiscount() > 0) {
			$this->discount = round($this->subtotal * ($this->getJVPartnerDiscount() / 100),2);
			$summaryNode->setAttribute('coupon',round($this->getJVPartnerDiscount()).'%');
			$summaryNode->setAttribute('discount',$this->discount);
			$this->total = $this->subtotal - $this->discount;
		}
		else {
			if($this->coupon) {
			switch($this->coupon->discount_type) {
				case 'dollar': {
					$this->discount = round($this->coupon->discount,2);
					$summaryNode->setAttribute('coupon','$'.number_format($this->coupon->discount));
					break;
				}
				case 'percent': {
					$this->discount = round($this->discountable_total * ($this->coupon->discount / 100),2);
					$summaryNode->setAttribute('coupon',$this->coupon->discount.'%');
					break;
				}
			}
			
			$summaryNode->setAttribute('discount',$this->discount);
			$summaryNode->setAttribute('coupon_name',$this->coupon->coupon);
			$this->total = $this->subtotal - $this->discount;
		} else {
			$summaryNode->setAttribute('coupon',null);
			$summaryNode->setAttribute('discount',0);
		}
		}
		$summaryNode->setAttribute('total',$this->total);
		return;
	}
	
	//When the user doesn't pay via Pay Pal an invoice is generated and is emailed to them
	private function createAndEmailInvoice() {
		// Create the invoice.
		$invoiceObj = new invoice($this->db);
		$invoice_id	= $invoiceObj->addInvoice($GLOBALS['core']->plugin->clients->client->client_id, $this->currency_id, 14, date('Y-m-d'), $this->discount);
		
		$discountPerItem = 0;
		if($this->discount > 0) {
			$totalItems = 0;
			foreach($this->cartItems as $item_id => $item) {
				$totalItems += $item->quantity;
			}
			$discountPerItem = $this->discount / $totalItems;
		}
		
		foreach($this->cartItems as $item_id => $item) {
			$product_id = $item->product_id;
			$quantity = $item->quantity;
			$price = round($this->products[$item->product_id]->price - $discountPerItem, 2);
			
			$invoiceObj->addProductToInvoice($invoice_id, $product_id, $quantity, $price, false);
		}
				
		$coupon_id = ($this->coupon ? $this->coupon->coupon_id : false);
		if($coupon_id) {
			$invoiceObj->redeemCoupon($GLOBALS['core']->plugin->clients->client->client_id, $coupon_id, $this->discount);
			$invoiceObj->insertCoupon2Invoice($invoice_id, $coupon_id);
		}

		$invoice = $invoiceObj->getInvoiceById($invoice_id);
		
		// Create the invoice node.
		$doc = $GLOBALS['core']->doc;
		$fopNode = $doc->lastChild->appendChild($doc->createElement('fop'));
		$fopNode->appendChild(invoice::toXml($invoice, $doc));
				
		// Generate the invoice PDF.
		//Check the current site, for the correct invoice
		$invoice_template = GENERATOR . "-invoice";
		$invoiceFilename = (ADMIN_TEMPLATE != '' ? ADMIN_TEMPLATE : "GreenBizCheck")."-Invoice-".$invoice->invoice_no_display.".pdf";
		$invoiceFop = new fopRenderer($invoice_template, @$doc);	
		$invoicePdf = $invoiceFop->render();
		
		// Email
		$contacts = clientContact::stGetClientContactsByClientId($this->db, $this->client->client_id);
		$contactNames = array();
		$to = array();
		foreach ($contacts as $contact) {
			$contactNames[] = $contact->firstname;
			$to[] = mailer::nameAndEmail($contact->firstname." ".$contact->lastname, $contact->email);
		}
		
		$message = "<html>\r\n".
			"<body>\r\n".
			"<p>Hi ".implode('/', $contactNames)."</p>".
			"<p>Please find attached your invoice for payment.</p><p>On receipt of payment you will be able to access your GreenBizCheck environmental assessment.</p>\r\n".
			"<p>If you have any queries, please feel free to contact us by replying to this message.</p>\r\n".
			"<p>Kind regards,</p>\r\n".
			"<p>The GreenBizCheck Team<br />\r\n".
			"<a href=\"http://www.greenbizcheck.com/\">www.greenbizcheck.com</a></p>\r\n".
			"<p><strong><em>Please consider the environment before printing this email. We are losing 40 million acres of oxygen producing forests through logging and land clearing every year.</em></strong></p>\r\n".
			"</body>\r\n".
			"</html>\r\n";
			
		//Add this email to the CRM for the current client
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_email` (client_contact_id, sent_date, email_to, email_stationery, email_subject, email_body)
				VALUES ("%2$d", "%3$s", "%4$s", "%5$s", "%6$s", "%7$s")
			',
				DB_PREFIX.'crm',
				$this->db->escape_string($contacts[0]->client_contact_id),
				$this->db->escape_string(date('Y-m-d H:i:s', time())),
				$this->db->escape_string($contacts[0]->email),
				'', //There is no stationary for this email
				$this->db->escape_string("Invoice for Payment: Invoice #".$invoice->invoice_no_display),
				$this->db->escape_string($message)
			));
		
		//Get the account owner if one exists
		$account_owner = clientContact::stGetAccountOwnerByClientId($this->db, $this->client->client_id);
		
		//Set the BCC addresses for the invoice to be emailed.
		$bccAddresses = "info@greenbizcheck.com";
		
		if(!is_null($account_owner->email)){
			$bccAddresses .= ", " . $account_owner->email;
		}
		
		mailer::deliver($to, "\"GreenBizCheck\" <info@greenbizcheck.com>", "Invoice for Payment: Invoice #".$invoice->invoice_no_display, $message, array($invoiceFilename => $invoicePdf), $bccAddresses);
		
		$this->clearCartInvoice();
	}
	
	public function checkout() {
		if(($this->client = $GLOBALS['core']->plugin->clients->client) == false || !isset($_POST['action']) || $_POST['action'] != 'checkout') { return; }
		if($this->total > 0) {
			if ($_POST['method'] == 'sendInvoice') {
				$this->createAndEmailInvoice();
			}
			else {
				$this->paypalForm();
			}
		} else {
			foreach($this->cartItems as $item_id => $item) {
				$pos = new pointOfSale($GLOBALS['core']->db);
				$pos->addProductToAccount($this->client->client_id,$item->product_id,$item->quantity);
			}
			//Send email to head office with details of transaction
			$this->emailTransactionSummary();
			//$this->clearCart();
		}
		return;
	}
	
	public function emailTransactionSummary() {
		// Create the invoice.
		$invoiceObj = new invoice($this->db);
		$invoice_id	= $invoiceObj->addInvoice($GLOBALS['core']->plugin->clients->client->client_id, $this->currency_id, 14, date('Y-m-d'), $this->discount);
		
		$discountPerItem = 0;
		if($this->discount > 0) {
			$totalItems = 0;
			foreach($this->cartItems as $item_id => $item) {
				$totalItems += $item->quantity;
			}
			$discountPerItem = $this->discount / $totalItems;
		}
		
		foreach($this->cartItems as $item_id => $item) {
			$product_id = $item->product_id;
			$quantity = $item->quantity;
			$price = round($this->products[$item->product_id]->price - $discountPerItem, 2);
			
			$invoiceObj->addProductToInvoice($invoice_id, $product_id, $quantity, $price, false);
		}
				
		$coupon_id = ($this->coupon ? $this->coupon->coupon_id : false);
		if($coupon_id) {
			$invoiceObj->redeemCoupon($GLOBALS['core']->plugin->clients->client->client_id, $coupon_id, $this->discount);
			$invoiceObj->insertCoupon2Invoice($invoice_id, $coupon_id);
		}

		$invoice = $invoiceObj->getInvoiceById($invoice_id);
		
		// Create the invoice node.
		$doc = $GLOBALS['core']->doc;
		$fopNode = $doc->lastChild->appendChild($doc->createElement('fop'));
		$fopNode->appendChild(invoice::toXml($invoice, $doc));
				
		// Generate the invoice PDF.
		//Check the current site, for the correct invoice
		$invoice_template = GENERATOR . "-invoice";
		$invoiceFilename = (ADMIN_TEMPLATE != '' ? ADMIN_TEMPLATE : "GreenBizCheck")."-Invoice-".$invoice->invoice_no_display.".pdf";
		$invoiceFop = new fopRenderer($invoice_template, @$doc);	
		$invoicePdf = $invoiceFop->render();
		
		$message = "<html>\r\n".
			"<body>\r\n".
			"<p>Hi GreenBizCheck Team,</p>".
			"<p>Please find attached an invoice for a recent transaction where a zero balance was applied.</p>\r\n".
			"</body>\r\n".
			"</html>\r\n";
		
		mailer::deliver("\"GreenBizCheck\" <info@greenbizcheck.com>", "\"GreenBizCheck\" <info@greenbizcheck.com>", "Invoice for Payment: Invoice #".$invoice->invoice_no_display, $message, array($invoiceFilename => $invoicePdf));
		
		$this->clearCart();
		
		return;
	}
	
	//Does the same as the clear cart method but also adds the ability to redirect to another location based on the payment type
	public function clearCartInvoice() {
		if(count($this->cartItems)) {
			foreach($this->cartItems as $item_id => $item) {
				$this->destroyCookie($item_id);
			}
			setcookie('coupon','',time()-1000,'/');
			header('location: /cart/invoice-thankyou/');
			die();
		}
		return;
	}
	
	public function clearCart() {
		if(count($this->cartItems)) {
			foreach($this->cartItems as $item_id => $item) {
				$this->destroyCookie($item_id);
			}
			setcookie('coupon','',time()-1000,'/');
			header('location: /cart/thankyou/');
			die();
		}
		return;
	}
	
	public function pdfInvoice() {
		if (isset($_REQUEST['account_no']) && isset($_REQUEST['invoice_id'])) {
			$luhn = clientUtils::unluhn($_REQUEST['account_no']);
			$client = client::stGetClientById(
						$GLOBALS['core']->db, 
						$GLOBALS['core']->db->escape_string($luhn['client_id']), 
						'DATE(`client`.`registered`) = "%4$s"', 
						array($GLOBALS['core']->db->escape_string($luhn['registered']))
					);
									
			// Ensure the client could be found with its account number.
			if ($client) {
				// Load the invoice.
				$invoiceObj = new invoice($GLOBALS['core']->db);
				$invoice = $invoiceObj->getInvoiceById($_REQUEST['invoice_id']);
				
				// Create the invoice node.
				$doc = $GLOBALS['core']->doc;
				$fopNode = $doc->lastChild->appendChild($doc->createElement('fop'));
				$fopNode->appendChild(invoice::toXml($invoice, $doc));
				
				// Generate the invoice PDF.
				if (!isset($_REQUEST['debug'])) {

					//Check the current site, for the correct invoice
					$invoice_template = GENERATOR . "-invoice";
					$invoiceFop = new fopRenderer($invoice_template, @$doc);
					$invoiceFop->sendFile((ADMIN_TEMPLATE != '' ? ADMIN_TEMPLATE : "GreenBizCheck")."-Invoice-".$invoice->invoice_id.".pdf");
				}
			}
		}
	}
	
	public function payAccount() {
		 if(isset($GLOBALS['core']->plugin->clients->client->client_id)) {
			if($result = $GLOBALS['core']->db->query(sprintf('
				SELECT
					`client`.`client_id`,
					`client`.`account_no`,
					`client`.`company_name`,
					`currency`.`currency_id`,
					`currency`.`code` AS `currency_code`,
					`currency`.`tax_name`,
					`currency`.`tax_rate`
				FROM `%1$s`.`client`
				LEFT JOIN `%2$s`.`city` ON `client`.`city_id` = `city`.`city_id`
				LEFT JOIN `%2$s`.`country` ON `city`.`country_id` = `country`.`country_id`
				LEFT JOIN `%3$s`.`currency` ON `country`.`currency_id` = `currency`.`currency_id`
				WHERE `client`.`client_id` = %4$d;
			',
				DB_PREFIX.'core',
				DB_PREFIX.'resources',
				DB_PREFIX.'pos',
				$GLOBALS['core']->plugin->clients->client->client_id
			))) {
				if($account = $result->fetch_object()) {
					$accountNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('account'));
					$accountNode->setAttribute('client_id',$account->client_id);
					$accountNode->setAttribute('account_no',$account->account_no);
					$accountNode->setAttribute('company_name',$account->company_name);
					$accountNode->setAttribute('currency_id',$account->currency_id);
					$accountNode->setAttribute('currency_code',$account->currency_code);
					$accountNode->setAttribute('tax_name',$account->tax_name);
					$accountNode->setAttribute('tax_rate',$account->tax_rate);
				}
				$result->close();
			}
			if(isset($account)) {
				$ballance = array();
				if($result = $GLOBALS['core']->db->query(sprintf('
					SELECT
						`invoice`.`invoice_id`,
						`invoice`.`currency_id`,
						`invoice`.`invoice_date`,
						`invoice`.`discount`,
						`currency`.`code` AS `currency_code`,
						`currency`.`tax_name`,
						`currency`.`tax_rate`
					FROM `%1$s`.`invoice`
					LEFT JOIN `%1$s`.`currency` ON `invoice`.`currency_id` = `currency`.`currency_id`
					WHERE `invoice`.`client_id` = %2$d
					ORDER BY `invoice`.`invoice_date` DESC;
				',
					DB_PREFIX.'pos',
					$account->client_id
				))) {
					while($invoice = $result->fetch_object()) {
						if(isset($_REQUEST['invoice_id']) && $invoice->invoice_id == $_REQUEST['invoice_id']) {
							header("Location /pay-your-account/invoice-pdf?account_no=".$_REQUEST['account_no']."&invoice_id=".$_REQUEST['invoice_id']);
							die();
						}
						$invoice->amount = 0;
						if($result_2 = $GLOBALS['core']->db->query(sprintf('
							SELECT `quantity` * `price_per_item` AS `amount`
							FROM `%1$s`.`product_2_invoice`
							WHERE `product_2_invoice`.`invoice_id` = %2$d;
						',
							DB_PREFIX.'pos',
							$invoice->invoice_id
						))) {
							while($row = $result_2->fetch_object()) {
								$invoice->amount += $row->amount;
							}
							$result_2->close();
						}
						$invoiceNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('invoice'));
						$invoiceNode->setAttribute('invoice_id',$invoice->invoice_id);
						$invoiceNode->setAttribute('invoice_date',$invoice->invoice_date);
						$invoiceNode->setAttribute('discount',$invoice->discount);
						$invoiceNode->setAttribute('amount',$invoice->amount);
						$invoiceNode->setAttribute('currency_id',$invoice->currency_id);
						$invoiceNode->setAttribute('currency_code',$invoice->currency_code);
						$invoiceNode->setAttribute('tax_name',$invoice->tax_name);
						$invoiceNode->setAttribute('tax_rate',$invoice->tax_rate);
						$ballance[$invoice->currency_code] = isset($ballance[$invoice->currency_code]) ? $ballance[$invoice->currency_code] += $invoice->amount : $invoice->amount;
					}
					$result->close();
				}
				if($result = $GLOBALS['core']->db->query(sprintf('
					SELECT
						`transaction`.`transaction_id`,
						`transaction`.`currency_id`,
						`transaction`.`timestamp`,
						`transaction`.`amount`,
						`transaction`.`method`,
						`currency`.`code` AS `currency_code`,
						`currency`.`tax_name`,
						`currency`.`tax_rate`
					FROM `%1$s`.`transaction`
					LEFT JOIN `%1$s`.`currency` ON `transaction`.`currency_id` = `currency`.`currency_id`
					WHERE `transaction`.`client_id` = %2$d
					ORDER BY `transaction`.`timestamp` DESC;
				',
					DB_PREFIX.'pos',
					$account->client_id
				))) {
					while($transaction = $result->fetch_object()) {
						$transactionNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('transaction'));
						$transactionNode->setAttribute('transaction_id',$transaction->transaction_id);
						$transactionNode->setAttribute('timestamp',$transaction->timestamp);
						$transactionNode->setAttribute('amount',$transaction->amount);
						$transactionNode->setAttribute('method',$transaction->method);
						$transactionNode->setAttribute('currency_id',$transaction->currency_id);
						$transactionNode->setAttribute('currency_code',$transaction->currency_code);
						$transactionNode->setAttribute('tax_name',$transaction->tax_name);
						$transactionNode->setAttribute('tax_rate',$transaction->tax_rate);
						$ballance[$transaction->currency_code] = isset($ballance[$transaction->currency_code]) ? $ballance[$transaction->currency_code] -= $transaction->amount : $transaction->amount * -1;
					}
					$result->close();
				}
				foreach($ballance as $currency_code => $amount) {
					$ballanceNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('ballance'));
					$ballanceNode->setAttribute('currency_code',$currency_code);
					$ballanceNode->setAttribute('amount',$amount);
				}
				if(isset($_POST['action']) && $_POST['action'] == 'payAccount') {
					$sandbox = false;
			
					$custom				= new stdClass;
					$custom->client_id	= $account->client_id;
					$custom->mode		= 'account';
					
					$ppData = array(
						'cmd'			=> '_cart',
						'business' 		=> ($sandbox ? 'greebiz_biz@greenbizcheck.com' : 'mg@greenbizcheck.com'),
						'charset'		=> "UTF-8",
						'custom'		=> base64_encode(serialize($custom)),
						'currency_code'	=> $_POST['currency'],
						'upload'		=> '1',
						'no_shipping'	=> '1',
						'no_note'		=> '1',
						'return'		=> 'https://www.greenbizcheck.com/pay-your-account/',
						'cancel_return'	=> 'https://www.greenbizcheck.com/pay-your-account/'
					);
					
					$ppData['item_name_1']	= 'Paying account '.$account->account_no;
					$ppData['amount_1']		= $_POST['amount'];
					$ppData['quantity_1']	= 1;
					
					if(function_exists('openssl_x509_read')) {
						$paypal = new PayPalEWP();
						$paypal->setTempFileDirectory('/tmp');
						$paypal->setCertificate(PATH_SYSTEM.'/cert/my-pubcert.pem',PATH_SYSTEM.'/cert/my-prvkey.pem');
						$paypal->setCertificateID($sandbox ? 'ACXBK33SB2JKL' : '2J7GGASSGTTX4');
						$paypal->setPayPalCertificate(PATH_SYSTEM.'/cert/paypal-'.($sandbox ? 'sandbox' : 'live').'-pubcert.pem');
						
						$this->node->appendChild($GLOBALS['core']->doc->createElement(
							'paypal',
							"-----BEGIN PKCS7-----".str_replace("\n","",$paypal->encryptButton($ppData))."-----END PKCS7-----"
						));
					}
					$this->node->setAttribute('paypalAddress','https://www'.($sandbox ? '.sandbox' : null).'.paypal.com/cgi-bin/webscr');
				}	
			}
		}
		return;
	}
	
	private function addItem() {
		if(isset($_POST['action']) && $_POST['action'] == 'add_product_to_cart') {
			$quantity = (@is_int($_POST['quantity']) ? $_POST['quantity'] : 1);
			if(($product = @$this->products[$_POST['product_id']]) != false) {
				$item_id = 0;
				foreach($this->cartItems as $item_id => $item) {
					if($item->product_id == $product->product_id) {
						$this->cartItems[$item_id]->quantity += $quantity;
						setcookie('item['.$item_id.'][qty]',$this->cartItems[$item_id]->quantity,0,'/');
						header('location: /cart/?last_item='.$item_id);
						die();
					}
				}
				$item_id++;
				$this->cartItems[$item_id] = new stdClass();
				$this->cartItems[$item_id]->product_id = $product->product_id;
				$this->cartItems[$item_id]->quantity = $quantity;
				$this->cartItems[$item_id]->timestamp = time();
				setcookie('item['.$item_id.'][id]',$this->cartItems[$item_id]->product_id,0,'/');
				setcookie('item['.$item_id.'][qty]',$this->cartItems[$item_id]->quantity,0,'/');
				setcookie('item['.$item_id.'][ts]',$this->cartItems[$item_id]->timestamp,0,'/');
				header('location: /cart/?last_item='.$item_id);
				die();
			}
		}
		if(($item = @$this->cartItems[$_REQUEST['last_item']]) && ($product = @$this->products[$item->product_id])) {
			$lastItemNode = $this->node->appendChild($GLOBALS['core']->doc->createElement('lastItem'));
			$lastItemNode->setAttribute('product_id',$product->product_id);
			$lastItemNode->setAttribute('name',$product->name);
			$lastItemNode->setAttribute('price',$product->price);
		}
		return;
	}
	
	//Returns product details of the items the user has added to their shopping cart
	private function getItems() {
		if(isset($_COOKIE['item']) && is_array($_COOKIE['item'])) {
			foreach($_COOKIE['item'] as $item_id => $item) {
				 if(isset($_POST['remove_item']) && $item['id'] == $_POST['remove_item']) {
					$this->destroyCookie($item_id);
				} elseif(isset($item['id']) && isset($item['ts']) && isset($item['qty'])) {
					if(isset($_POST['quantity'][$item_id]) && is_numeric($_POST['quantity'][$item_id])) {
						$item['qty'] = floor($_POST['quantity'][$item_id]);
					}
					if($item['qty'] <= 0) {
						$this->destroyCookie($item_id);
					} else {
						$this->cartItems[$item_id] = new stdClass();
						$this->cartItems[$item_id]->product_id = $item['id'];
						$this->cartItems[$item_id]->quantity = $item['qty'];
						$this->cartItems[$item_id]->timestamp = $item['ts'];
						
						setcookie('item['.$item_id.'][id]',$this->cartItems[$item_id]->product_id,0,'/');
						setcookie('item['.$item_id.'][qty]',$this->cartItems[$item_id]->quantity,0,'/');
						setcookie('item['.$item_id.'][ts]',$this->cartItems[$item_id]->timestamp,0,'/');
					}
				}
			}
		}
		if(isset($_POST['action']) && $_POST['action'] == 'update_cart') {
			header('location: /cart/');
			die();
		}
		return;
	}
	
	//Function to get any discount that may be available for the current domain (billing system)
	private function getJVPartnerDiscount() {
	 	$PartnerInformation = new billing($this->db);
	 	$partner_id = $PartnerInformation->getClient2PartnerRelationship((isset($GLOBALS['core']->plugin->clients->client->client_id)) ? ($GLOBALS['core']->plugin->clients->client->client_id) : null);
	 
	 	if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`discount`
			FROM `%1$s`.`revenue_split`
			WHERE `jv_partner_id` = %2$d;
		',
			DB_PREFIX.'billing',
			$partner_id
		))) {
				if($row = $result->fetch_object()) {
					
					return $row->discount;
					echo $row->discount;
					die();
				}
				else
				{
				 	//No discount to run
					return 0;	
				}
		}
	}
	
	//Looks into the database and checks see if there is a matching coupon to what the user has entered.
	//Also checks the data, redemption cound and product type of the coupon
	private function getCoupon() {
		if(isset($_POST['coupon'])) {
			$string = md5($_POST['coupon']);
		} elseif(isset($_COOKIE['coupon'])) {
			$string = $_COOKIE['coupon'];
		} else {
			return;
		}
		$error = 'The coupon you entered is not valid';
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`coupon`.`coupon_id`,
				UNIX_TIMESTAMP(`coupon`.`active_date`) AS `active_date`,
				UNIX_TIMESTAMP(`coupon`.`expire_date`) AS `expire_date`,
				`coupon`.`coupon`,
				`coupon`.`limit` - COUNT(`coupon_redemption`.`coupon_id`) AS `remaining`,
				`coupon`.`discount_type`,
				`coupon`.`discount`,
				`coupon`.`dollar_limit`,
				IF(SUM(`coupon_redemption`.`discount`) IS NOT NULL, SUM(`coupon_redemption`.`discount`), 0) AS `dollar_limit_claimed`
			FROM `%1$s`.`coupon`
			LEFT JOIN `%1$s`.`coupon_redemption` USING(`coupon_id`)
			WHERE MD5(`coupon`.`coupon`) = "%2$s"
			GROUP BY `coupon`.`coupon_id`;
		',
			DB_PREFIX.'pos',
			$GLOBALS['core']->db->escape_string($string)
		))) {
			if($row = $result->fetch_object()) {
				if(time() < $row->active_date) {
					$error = 'The coupon you entered is not active until '.date('h:ia \o\n jS M Y',$row->active_date);
				} elseif(time() > $row->expire_date) {
					$error = 'The coupon you entered expired at '.date('h:ia \o\n jS M Y',$row->active_date);
				} elseif($row->remaining <= 0) {
					$error = 'The coupon you entered has exceded the usage limit';
				} elseif(($row->dollar_limit_claimed >= $row->dollar_limit) && ($row->dollar_limit > 0)) {
					$error = 'The coupon you entered has exceded the usage limit';
				} elseif(!$this->isValidCouponProduct($row->coupon_id)){
					$error = "The coupon you entered can't be used with any of your products";
				} else {
					$this->coupon = $row;
					setcookie('coupon',md5($row->coupon),0,'/');
					$result->close();
					return;
				}
			}
			$result->close();
		}
		$this->node->appendChild($GLOBALS['core']->doc->createElement('couponError',$error));
	}
	
	//Check to see if the coupon provided is useable on any of the products in the shopping cart
	private function isValidCouponProduct($coupon_id) {
	 	$discountableTotal = 0;
	 	$valid = false;
	 	$completeTotal = 0;
	 	
	 	foreach($this->cartItems as $item_id => $item) {
			$completeTotal += $item->quantity * $this->products[$item->product_id]->price;
		}
	 	
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
			`coupon_2_product`.`product_id`,
			`product_price`.`price`
			FROM `%1$s`.`coupon_2_product`
			LEFT JOIN `%1$s`.`product_price` ON`coupon_2_product`.`product_id` = `product_price`.`product_id`
			WHERE `coupon_2_product`.`coupon_id` = %2$d AND `product_price`.`currency_id` = %3$d;
		',
			DB_PREFIX.'pos',
			$GLOBALS['core']->db->escape_string($coupon_id),
			$this->currency_id
		))) {
			if($result->num_rows == 0) {
				$this->discountable_total = $completeTotal;
				return true;
			}
		
			//Loop through the results and the products
			while($row = $result->fetch_object()) {	 	
			 	foreach($this->cartItems as $product) {
					if($product->product_id === $row->product_id) {
					 	$discountableTotal += $row->price;
						$valid = true;
					}
				}
			}
			
			//The coupon can't be used on this product
			if(!$valid) {
				$this->discountable_total = $completeTotal;
				return false;
			}
		}
		$this->discountable_total = $discountableTotal;
		return true;
	}
		
	private function getProducts() {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`product`.`product_id`,
				`product`.`name`,
				`product_price`.`price`
			FROM `%1$s`.`product`
			LEFT JOIN `%1$s`.`product_price` ON
				`product_price`.`product_id` = `product`.`product_id` AND
				`product_price`.`currency_id` = %2$d;
		',
			DB_PREFIX.'pos',
			$this->currency_id
		))) {
			while($row = $result->fetch_object()) {
				$this->products[$row->product_id] = $row;
			}
			$result->close();
		}
		return;		
	}
	
	//Get the descriptions/items for all of the available products
	//Each product can have zero or many items or descriptions attached - this is just a text description of the actual product
	private function getProductDescriptions() {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`product_description`;
		',
			DB_PREFIX.'pos'
		))) {
			while($row = $result->fetch_object()) {
				$this->productDescriptions[$row->product_description_id] = $row;
			}
			$result->close();
		}
		return;		
	}
	
	private function getCurrencies($code=false) {
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`currency`.`currency_id`,
				`currency`.`code`,
				`currency`.`symbol`,
				`currency`.`symbol_pos`,
				`currency`.`tax_exempt`,
				`currency`.`description`,
				`currency`.`tax_name`,
				`currency`.`tax_rate`
			FROM `%1$s`.`currency`
		',
			DB_PREFIX.'pos'
		))) {
			while($row = $result->fetch_object()) {
				$this->currencies[$row->currency_id] = $row;
				if($code && $code == $row->code) { $this->currency_id = $row->currency_id; }
			}
			$result->close();
		}
		if(
			isset($GLOBALS['core']->plugin->clients->client->currency_id) && 
			in_array($GLOBALS['core']->plugin->clients->client->currency_id,array_keys($this->currencies))
		) {
			$this->currency_id = $GLOBALS['core']->plugin->clients->client->currency_id;
			setcookie('currency',$this->currency_id,time()+(60*60*24*365),'/');
			return;
		}
		if(
			isset($_POST['action']) && 
			$_POST['action'] == 'change_currency' &&
			isset($_POST['currency_id']) &&
			in_array($_POST['currency_id'],array_keys($this->currencies))
		) {
			$this->currency_id = $_POST['currency_id'];
			setcookie('currency',$this->currency_id,time()+(60*60*24*365),'/');
			return;
		}
		if(
			isset($_COOKIE['currency']) &&
			in_array($_COOKIE['currency'],array_keys($this->currencies))
		) {
			$this->currency_id = $_COOKIE['currency'];
			setcookie('currency',$this->currency_id,time()+(60*60*24*365),'/');
			return;
		}
		return;
	}
	
	//Lists a number of add on product suggestions to the user based on what is already in their shopping cart
	private function getSuggestions($product_id) {
		$suggestion = array();
		if($result = $GLOBALS['core']->db->query(sprintf('
			SELECT
				`suggestion`.`suggestion_id`,
				`product`.`product_id`,
				`product`.`name`,
				`product`.`price`
			FROM `%1$s`.`suggestion`
			LEFT JOIN `%1$s`.`product` ON `suggestion`.`suggested_product_id` = `product`.`product_id`
			WHERE `suggestion`.`product_id` = %2$d;
		',
			DB_PREFIX.'pos',
			$GLOBALS['core']->db->escape_string($product_id)
		))) {
			while($row = $result->fetch_object()) {
				$suggestion[] = $row;
			}
			$result->close();
		}
		return($suggestion);
	}
	
	//This function is invoked by a return signal from Pay Pal.  This allows us to capture any successful Pay Pal payments and record the transaction details.
	public function paypalIPN() {
		if(isset($_POST['test_ipn']) && $_POST['test_ipn'] == 1) {
			$ch = curl_init('https://www.sandbox.paypal.com/cgi-bin/webscr');
		} else {
			$ch = curl_init('https://www.paypal.com/cgi-bin/webscr');
		}
		
		//Work with the Pay Pal IPN to get the transaction data
		curl_setopt($ch,CURLOPT_RETURNTRANSFER,true);
		curl_setopt($ch,CURLOPT_HEADER,false);
		curl_setopt($ch,CURLOPT_POST,true);
		curl_setopt($ch,CURLOPT_POSTFIELDS,file_get_contents("php://input").'&cmd=_notify-validate');
		$IPNresult = trim(curl_exec($ch));
		curl_close($ch);
		
		$data = unserialize(base64_decode(trim($_POST['custom'])));
		
		//Insert the IPN/Pay Pal transaction details into the database
		$GLOBALS['core']->db->query(sprintf('
			INSERT IGNORE INTO `%1$s`.`paypal_transaction` SET
				`paypal_txn_id` = "%2$s",
				`data` = "%3$s",
				`verification` = "%4$s",
				`client_id` = %5$d;
		',
			DB_PREFIX.'pos',
			$GLOBALS['core']->db->escape_string(trim($_POST['txn_id'])),
			$GLOBALS['core']->db->escape_string(serialize($_POST)),
			$GLOBALS['core']->db->escape_string($IPNresult),
			$data->client_id
		));
		
		//If the payment was successful - continue processing
		if($GLOBALS['core']->db->affected_rows <= 0 || $IPNresult != 'VERIFIED' || $_POST['payment_status'] != 'Completed') { return; } 
		
		$this->getCurrencies($_POST['mc_currency']);
		
		//Insert the transaction to the client account
		$invoice = new invoice($GLOBALS['core']->db);
		$invoice->addTransaction($data->client_id,$this->currency_id,$_POST['mc_gross'],'PayPal Transaction');
		
		//If the user is using the shopping cart and is not using the pay account or external Pay Pal functions - Continue
		if($data->mode == 'cart') {
			$invoice_id	= $invoice->addInvoice($data->client_id,$this->currency_id,14,date('Y-m-d'),$data->discount);
			
			for($i=0;$i<$_POST['num_cart_items'];$i++) {
				$product_id	= $_POST['item_number'.($i+1)];
				$quantity	= $_POST['quantity'.($i+1)];
				
				$invoice->addProductToInvoice($invoice_id,$product_id,$quantity,$this->products[$product_id]->price,true);
				
				//Checks to see that the payment is via the shopping cart - On successful transaction add products and checklist to client
				$pos = new pointOfSale($GLOBALS['core']->db);
				$pos->addProductToAccount($data->client_id,$product_id,$quantity);
			}
			if($data->coupon_id) {
				$invoice->redeemCoupon($data->client_id,$data->coupon_id,$data->discount);
			}
		}
		
		//Get the account owners details if applicable
		$account_owner_details = new clientContact($GLOBALS['core']->db);
		$account_owner = $account_owner_details->stGetAccountOwnerByClientId($GLOBALS['core']->db, $data->client_id);
		
		//sends and email to the client who made the purchase
		$clientEmail = new clientEmail($GLOBALS['core']->db);
		$clientEmail->send($data->client_id,'Your Green Business Certification','payment_received',null,true,$account_owner->email);
		
		$client_deatils = new client($GLOBALS['core']->db);
		$client = $client_deatils->stGetClientById($GLOBALS['core']->db, $data->client_id);
		
		//Send an email to info@greenbizcheck.com to notify of the payment made matching client to Pay Pal.
		$message = "<html>\r\n".
			"<body>\r\n".
			"<p><strong>Company Name:</strong> " . $client->company_name ."<br />\r\n".
			"<strong>Client ID:</strong> " . $client->client_id ."<br />\r\n".
			"<strong>Payment Amount:</strong> $" . $_POST['mc_gross'] . " " . $_POST['mc_currency'] . "<br />\r\n".
			"<strong>Payment Date:</strong> " . $_POST['payment_date'] ."<br />\r\n".
			"<strong>Transaction ID:</strong> " . $_POST['txn_id'] ."<br />\r\n".
			"<strong>Senders Email:</strong> " . $_POST['payer_email'] ."<br />\r\n".
			"<strong>Senders Name:</strong> " . $_POST['first_name'] . " " . $_POST['last_name'] ."</p>\r\n".
			"<p><strong>Products:</strong><br />\r\n";
			
			for($i=0;$i<$_POST['num_cart_items'];$i++) {
				$message .= $_POST['quantity'.($i+1)] . " x " . $_POST['item_name'.($i+1)] ."<br />\r\n";
			}
			
			$message .= "</p>";
			
			if($data->mode == 'cart'){
				$message .= "<p><strong>Assessments have been auto issued to this client.</strong></p>\r\n";
			}
			
			//Add the details about the account_owner/business owner
			$message .= "<p><strong>Account Owner:</strong> ";
			if(isset($account_owner)) {
				$message .= $account_owner->company_name . "</p>";	
			}
			else {
				$message .= "None Assigned</p>";
			}
			
			$message .=	"</body>\r\n".
					   	"</html>\r\n";
			
			$to = "info@greenbizcheck.com";
			if(isset($account_owner->email)) {
				$to .= "," . $account_owner->email;
			}
			
			$sendmail = new mailer($GLOBALS['core']->db);
			$sendmail->deliver($to,"\"GreenBizCheck Webmaster\" <webmaster@greenbizcheck.com>", "PayPal Payment Received from client: " .$client->company_name , $message);
		
		return;
	}
	
	private function paypalForm() {
		/****************************************************
							PayPal Sandbox
			
		Buyer:		tech_1245226326_per@greenbizcheck.com
		Seller:		greebiz_biz@greenbizcheck.com
		Password:	245226282
		****************************************************/
		$sandbox = false;
		
		$custom				= new stdClass;
		$custom->client_id	= $this->client->client_id;
		$custom->coupon_id	= ($this->coupon ? $this->coupon->coupon_id : false);
		$custom->subtotal	= (string) $this->subtotal;
		$custom->discount	= (string) $this->discount;
		$custom->total		= (string) $this->total;
		$custom->mode		= 'cart';
		
		$ppData = array(
			'cmd'			=> '_cart',
			'business' 		=> ($sandbox ? 'greebiz_biz@greenbizcheck.com' : 'mg@greenbizcheck.com'),
			'charset'		=> "UTF-8",
			'custom'		=> base64_encode(serialize($custom)),
			'currency_code'	=> $this->currencies[$this->currency_id]->code,
			'upload'		=> '1',
			'no_shipping'	=> '1',
			'no_note'		=> '1',
			'return'		=> 'https://www.greenbizcheck.com/cart/thankyou/',
			'cancel_return'	=> 'https://www.greenbizcheck.com/cart/'
		);
		
		$discountPerItem = 0;
		if($this->discount > 0) {
			$totalItems = 0;
			foreach($this->cartItems as $item_id => $item) {
				$totalItems += $item->quantity;
			}
			$discountPerItem = $this->discount / $totalItems;
		}
		
		$i = 1;
		foreach($this->cartItems as $item_id => $item) {
			$ppData['item_name_'.$i]	= $this->products[$item->product_id]->name;
			$ppData['item_number_'.$i]	= $item->product_id;
			$ppData['amount_'.$i]		= round($this->products[$item->product_id]->price - $discountPerItem,2);
			$ppData['quantity_'.$i]		= $item->quantity;
			$i++;
		}
		$paypal = new PayPalEWP();
		$paypal->setTempFileDirectory('/tmp');
		$paypal->setCertificate(PATH_SYSTEM.'/cert/my-pubcert.pem',PATH_SYSTEM.'/cert/my-prvkey.pem');
		$paypal->setCertificateID($sandbox ? 'ACXBK33SB2JKL' : '2J7GGASSGTTX4');
		$paypal->setPayPalCertificate(PATH_SYSTEM.'/cert/paypal-'.($sandbox ? 'sandbox' : 'live').'-pubcert.pem');

		$this->node->appendChild($GLOBALS['core']->doc->createElement(
			'paypal',
			"-----BEGIN PKCS7-----".str_replace("\n","",$paypal->encryptButton($ppData))."-----END PKCS7-----"
		));
		$this->node->setAttribute('paypalAddress','https://www'.($sandbox ? '.sandbox' : null).'.paypal.com/cgi-bin/webscr');
		return;
		
	}
	
	private function destroyCookie($item_id) {
		setcookie('item['.$item_id.'][id]','',time()-1000,'/');
		setcookie('item['.$item_id.'][qty]','',time()-1000,'/');
		setcookie('item['.$item_id.'][ts]','',time()-1000,'/');
		return;
	}
}
?>