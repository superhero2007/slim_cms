<?php
class invoice extends dbModel {
	private $invoice_id;
	
	public static function toXml($invoice, $doc) {
		// Primary invoice tag.
		$invoiceNode = self::createElementWithAttributes($doc, 'invoice', $invoice);
		
		
		// invoice/items/item tags.
		if (isset($invoice->items)) {
			$itemsNode = $doc->createElement('items');
			foreach ($invoice->items as $item) {
				$itemsNode->appendChild(self::createElementWithAttributes($doc, 'item', $item));
			}
			$invoiceNode->appendChild($itemsNode);
		}
		
		// invoice/client & invoice/client/client_contacts/client_contact tags.
		if (isset($invoice->client)) {
			$clientNode = client::toXml($invoice->client, $doc);
			$invoiceNode->appendChild($clientNode);
		}
		
		// invoice/currency tag
		if (isset($invoice->currency)) {
			$currencyNode = currency::toXml($invoice->currency, $doc);
			$invoiceNode->appendChild($currencyNode);
		}
		
		// invoice/coupon tag
		if (isset($invoice->coupon)) {
			foreach($invoice->coupon as $coupon) {
				$invoiceNode->appendChild(self::createElementWithAttributes($doc, 'coupon', $coupon));
			}
		}
				
		return($invoiceNode);
	}
	
	public static function arrayToXml($invoices, $doc) {
		$invoicesNode = $doc->createElement('invoices');
		if (isset($invoices) && is_array($invoices)) {
			foreach ($invoices as $invoice) {
				$invoicesNode->appendChild(self::toXml($invoice, $doc));
			}
		}
		return($invoicesNode);
	}
		
	public function addInvoice($client_id,$currency_id,$terms=14,$date,$discount, $notes=null, $invoice_id=null, $archive=null, $paid_date=null) {
		$this->db->query(sprintf('
			REPLACE INTO `%1$s`.`invoice` SET
				`client_id` = %2$d,
				`currency_id` = %3$d,
				`invoice_date` = "%4$s",
				`terms` = %5$d,
				`discount` = "%6$f",
				`invoice_id` = %7$d,
				`notes` = "%8$s",
				`archive` = %9$d,
				`paid_date` = "%10$s";
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($client_id),
			$this->db->escape_string($currency_id),
			$this->db->escape_string($date),
			$this->db->escape_string($terms),
			$this->db->escape_string($discount),
			$this->db->escape_string($invoice_id),
			$this->db->escape_string($notes),
			$this->db->escape_string($archive),
			$this->db->escape_string($paid_date)

		));
		
		return($this->db->insert_id);
	}
	
	// Deprecated: Use getInvoiceById
	public function getInvoice($invoice_id) {
		return(getInvoiceById($invoice_id));
	}
	
	public function getInvoiceById($invoice_id, $additionalWhere = NULL, $additionalVariables = NULL) {
		$invoice = false;
		if($result = $this->query('
			SELECT
			 	`invoice`.`invoice_id`,
			 	`invoice`.`client_id`,
				`invoice`.`currency_id`,
			 	`invoice`.`timestamp`,
				`invoice`.`invoice_date`,
			 	`invoice`.`terms`,
				`invoice`.`discount`,
				`invoice`.`notes`,
				`invoice`.`archive`,
				`invoice`.`paid_date`,
				`coupon_2_invoice`.`coupon_id`
			 FROM `%1$s`.`invoice`
			 LEFT JOIN `%1$s`.`coupon_2_invoice` ON `invoice`.`invoice_id` = `coupon_2_invoice`.`invoice_id`
			 WHERE `invoice`.`invoice_id` = %2$d '.
				$this->additionalWhereToSql($additionalWhere, true)
		,
			$this->additionalVariablesMerge(
				$additionalVariables,
				array(
					DB_PREFIX.'pos',
					$this->db->escape_string($invoice_id)
				)
			)
		)) {
			if($invoice = $result->fetch_object()) {
				$invoice->items = $this->getInvoiceItems($invoice->invoice_id);
				$invoice->client = client::stGetClientById($this->db, $invoice->client_id);
				$invoice->currency = currency::stGetCurrencyById($this->db, $invoice->currency_id);
				$invoice->coupon = $this->getAppliedCoupon($invoice->coupon_id);
				
				// Extra display attributes for invoice.
				$invoice->invoice_no_display = str_pad($invoice->client->client_id, 4, '0', STR_PAD_LEFT).'-'.str_pad($invoice->invoice_id, 4, '0', STR_PAD_LEFT);
				$invoice->invoice_date_long = date('jS F Y', strtotime($invoice->invoice_date));
				$invoice->due_date = date('Y-m-d', strtotime($invoice->invoice_date) + ($invoice->terms * 24 * 60 * 60));
				$invoice->due_date_long = date('jS F Y', strtotime($invoice->invoice_date) + ($invoice->terms * 24 * 60 * 60));
				
				$invoiceTotal = 0.0;
				if (isset($invoice->items)) {
					foreach ($invoice->items as $item) {
						$invoiceTotal += round($item->price_per_item, 2) * $item->quantity;
					}
				}
				$invoice->total = $invoiceTotal;
				
				//Now check to see if there is a coupon set, if so figure out the discount and change the $invoice->discount item
				if($invoice->coupon_id > 0) {
					if($invoice->coupon[0]->discount_type = 'percent') {
						$invoice->discount = $invoice->total * ($invoice->coupon[0]->discount * 0.01);
					}
					else {
						//Discount is a dollar value
						$invoice->discount = $invoice->coupon[0]->discount;
					}
				}
				
				$invoice->amount_due = $invoice->total;
			}
			$result->close();
		}

		return($invoice);
	}
	
	public function getInvoicesByClientId($client_id) {
		$invoices = array();
		if($result = $this->db->query(sprintf('
			SELECT
			 	`invoice`.`invoice_id`,
			 	`invoice`.`client_id`,
			 	`invoice`.`timestamp`,
			 	`invoice`.`terms`
			 FROM `%1$s`.`invoice`
			 WHERE `invoice`.`client_id` = %2$d
			 ORDER BY `invoice`.`timestamp` ASC;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($client_id)
		))) {
			while($row = $result->fetch_object()) {
				$row->items = $this->getInvoiceItems($row->invoice_id);
				$invoices[] = $row;
			}
			$result->close();
		}
		return($invoices);
	}
	
	public function getInvoiceItems($invoice_id) {

		$items = array();
		if($result = $this->db->query(sprintf('
			SELECT
				`product_2_invoice`.`product_2_invoice_id`,
				`product_2_invoice`.`product_id`,
				`product`.`name`,
				`product_2_invoice`.`quantity`,
				`product_2_invoice`.`price_per_item`,
				`product_2_invoice`.`received`,
				`product`.`audit`
			FROM `%1$s`.`product_2_invoice`
			LEFT JOIN `%1$s`.`product` USING(`product_id`)
			WHERE `product_2_invoice`.`invoice_id` = %2$d
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($invoice_id)
		))) {
			while($row = $result->fetch_object()) {
				$items[] = $row;
			}
			$result->close();
		}
		return($items);
	}
	
	public function updateInvoiceDiscount($invoice_id) {
		
		$discount = 0;
		
		//First get the invoice object
		$invoice = $this->getInvoiceById($invoice_id);
		if($invoice->coupon_id > 0) {
			 
			//Now get the coupn details
			$coupon = $this->getAppliedCoupon($invoice->coupon_id);
		
			$items = $this->getInvoiceItems($invoice_id);
			$undiscountedInvoiceAmount = 0;
			
			foreach($items as $item) {
				if($result = $this->db->query(sprintf('
					SELECT *
					FROM `%1$s`.`product_price`
					WHERE `product_price`.`product_id` = %2$d
					AND `product_price`.`currency_id` = (
							SELECT `currency_id`
							FROM `%1$s`.`invoice`
							WHERE `invoice_id` = %3$d)
				',
					DB_PREFIX.'pos',
					$this->db->escape_string($item->product_id),
					$this->db->escape_string($invoice_id)
				))) {
					while($row = $result->fetch_object()) {
						$undiscountedInvoiceAmount += ($row->price * $item->quantity);
					}
					$result->close();
				}
			}
			
			if($coupon[0]->discount_type == 'dollar') {
				$discount = $coupon[0]->discount;
			}
			else {
				$discount = ($undiscountedInvoiceAmount * ($coupon[0]->discount * 0.01));
			}
		} else {
			$discount = $invoice->discount;
		}
		
		//Now update the invoice discount field with the right discount on the original price items
		$this->addInvoice($invoice->client_id,$invoice->currency_id,$invoice->terms,$invoice->invoice_date ,$discount, $invoice->notes, $invoice->invoice_id, $invoice->archive, $invoice->paid_date);
		
		return;
	}
	
	public function addProductToInvoice($invoice_id,$product_id,$quantity,$price_per_item,$received=0) {
		$this->db->query($sql = sprintf('
			INSERT INTO `%1$s`.`product_2_invoice` SET
				`invoice_id` = %2$d,
				`product_id` = %3$d,
				`quantity` = %4$d,
				`price_per_item` = "%5$f",
				`received` = %6$d;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($invoice_id),
			$this->db->escape_string($product_id),
			$this->db->escape_string($quantity),
			$this->db->escape_string($price_per_item),
			($received = true ? 1 : 0)
		));
		return($this->db->insert_id);
	}
	
	//Delete coupon redemption - required for setting the coupon in the admin system as it can change
	public function deleteCouponRedemption($invoice_id) {
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`coupon_redemption`
			WHERE `invoice_id` = %2$d;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($client_id)
		));
		
		return;
	}
	
	public function insertCoupon2Invoice($invoice_id, $coupon_id) {
		$this->db->query(sprintf('
			REPLACE INTO `%1$s`.`coupon_2_invoice` SET
				`invoice_id` = %2$d,
				`coupon_id` = %3$d;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($invoice_id),
			$this->db->escape_string($coupon_id)
		));
		
		return($this->db->insert_id);
	}
	
	public function deleteCoupon2Invoice($invoice_id) {
	 
		$this->db->multi_query(sprintf('
			DELETE FROM `%1$s`.`coupon_2_invoice` WHERE
				`invoice_id` = %2$d;
			UPDATE `%1$s`.`invoice`
				SET `discount` = 0
			WHERE `invoice_id` = %2$d;
			OPTIMIZE TABLE
				`%1$s`.`coupon_2_invoice`;
				`%1$s`.`invoice`;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($invoice_id)
		));
		
		return;
	}
	
	//Delete the invoice and the invoice data from all other tables
	public function deleteInvoice($invoice_id) {

		$this->db->multi_query(sprintf('
			DELETE FROM `%1$s`.`invoice` WHERE `invoice_id` = %2$d;
			DELETE FROM `%1$s`.`product_2_invoice` WHERE `invoice_id` = %2$d;
			DELETE FROM `%1$s`.`coupon_2_invoice` WHERE `invoice_id` = %2$d;
			OPTIMIZE TABLE
				`%1$s`.`invoice`,
				`%1$s`.`product_2_invocie`;
				`%1$s`.`coupon_2_invoice`;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($invoice_id)
		));
		
		return;
	}
	
	public function redeemCoupon($client_id,$coupon_id,$discount,$invoice_id=0) {
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`coupon_redemption` SET
				`client_id` = %2$d,
				`coupon_id` = %3$d,
				`discount` = "%4$f",
				`invoice_id` = %5$d;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($client_id),
			$this->db->escape_string($coupon_id),
			$this->db->escape_string($discount),
			$this->db->escape_string($invoice_id)
		));
		return($this->db->insert_id);
	}
	
	public function addTransaction($client_id,$currency_id,$amount,$method) {
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`transaction` SET
				`client_id` = %2$d,
				`currency_id` = %3$d,
				`amount` = "%4$f",
				`method` = "%5$s";
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($client_id),
			$this->db->escape_string($currency_id),
			$this->db->escape_string($amount),
			$this->db->escape_string($method)
		));
		
			//Distribute the payment with the associated parties
			$distribution = new billing($this->db);
			$distribution->applyRevenueShare($this->db->insert_id);
		
		return($this->db->insert_id);
	}
	
	//Get product by the product id
	public function getProductAndPriceByProductId($product_id, $currency_id) {
		$product = null;
		if($result = $this->db->query(sprintf('
			SELECT
				`product`.`product_id`,
				`product`.`name`,
				`product_price`.`price`
			FROM `%1$s`.`product`
			LEFT JOIN `%1$s`.`product_price` ON `product_price`.`product_id` = `product`.`product_id`
			WHERE `product`.`product_id` = %3$d
			AND `product_price`.`currency_id` = %2$d
			LIMIT 1;
		',
			DB_PREFIX.'pos',
			$currency_id,
			$product_id
		))) {
			while($row = $result->fetch_object()) {
			 
				$product = $row;
			}
			$result->close();
		}
		
		return $product;
	}
	
	//This should only run when a new auto invoice is created.
	//This allows us to correctly identify the client invoice to attach to other auto invoice reminders
	public function autoInvoiceRenewalMap($existing_invoice_id, $new_invoice_id) {
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`auto_invoice_renewal_map` SET
				`existing_invoice_id` = %2$d,
				`new_invoice_id` = %3$d;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($existing_invoice_id),
			$this->db->escape_string($new_invoice_id)
		));

		return($this->db->insert_id);
	}
	
	//Generate New Auto Invoice - Then pass back to calling autoInvoice function
	public function generateAutoInvoice($invoice_number)
	{
			//We need to get the client and the details from invoice_number parameter and create a new invoice - then we need to
			//Get the items fromthe existing invoice
			$existing_invoice_items = $this->getInvoiceItems($invoice_number);
	
			//Get the invoice data
			$existing_invoice = $this->getInvoiceById($invoice_number);
	
			// Create the invoice - Set the details based on the previous invoice
			$invoice_id	= $this->addInvoice($existing_invoice->client_id, $existing_invoice->currency_id, 30, date('Y-m-d'), $existing_invoice->discount);
			
			//Update the auto invoice renewal database
			$this->autoInvoiceRenewalMap($invoice_number, $invoice_id);
		 
			$discountPerItem = 0;
			if($existing_invoice->discount > 0) {
				$totalItems = 0;
				foreach($existing_invoice_items as $item_id => $item) {
					$totalItems += $item->quantity;
				}
				$discountPerItem = $existing_invoice->discount / $totalItems;
			}

			foreach($existing_invoice_items as $item) {
			 	$product_id = $item->product_id;
				$quantity = $item->quantity;
				
				$product = $this->getProductAndPriceByProductId($product_id,$existing_invoice->currency_id);
				
				$price = round($product->price - $discountPerItem, 2);
				$this->addProductToInvoice($invoice_id, $product_id, $quantity, $price, false);
			}
			
			return $invoice_id;
	}
	
	public function getInvoiceItemQuantity($invoice_id) {
		$quantity = 0;
		if($result = $this->db->query(sprintf('
			SELECT
				SUM(`quantity`) AS `quantity`
			FROM `%1$s`.`product_2_invoice`
			WHERE `invoice_id` = %2$d;
		',
			DB_PREFIX.'pos',
			$invoice_id
		))) {
			while($row = $result->fetch_object()) {
			 
				$quantity = $row->quantity;
			}
			$result->close();
		}
		
		return $quantity;
	}
	
	public function getInvoiceDiscount($invoice_id) {
		$discount = 0;
		if($result = $this->db->query(sprintf('
			SELECT
				`discount`
			FROM `%1$s`.`invoice`
			WHERE `invoice_id` = %2$d;
		',
			DB_PREFIX.'pos',
			$invoice_id
		))) {
			while($row = $result->fetch_object()) {
			 
				$discount = $row->discount;
			}
			$result->close();
		}
		
		return $discount;
	}
	
	public function updateInvoicePricePerItem($invoice_id) {
	 	$this->updateInvoiceDiscount($invoice_id);
	 	$totalItems = 		$this->getInvoiceItemQuantity($invoice_id);
	 	$discount = 		$this->getInvoiceDiscount($invoice_id);
		$discountPerItem = 	0.00;
		
		if($discount > 0) {
			$discountPerItem = $discount / $totalItems;	
		}
		
		//Now update the items attached to the invoice so that they are the correct price per item
		$this->db->query(sprintf('
			UPDATE `%1$s`.`product_2_invoice` SET
				`price_per_item` = (
					(SELECT 
						`price` 
					FROM `%1$s`.`product_price` 
					WHERE `product_price`.`product_id` = `product_2_invoice`.`product_id`
					AND `product_price`.`currency_id` = (
						SELECT `currency_id`
						FROM `%1$s`.`invoice`
						WHERE `invoice_id` = %2$d))
					 - %3$f)
			WHERE `invoice_id` = %2$d;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($invoice_id),
			$this->db->escape_string($discountPerItem)
		));
		
		return;
	}
	
	//Auto Invoice
	//Pass the invoice to duplicate and also if it to be emailed - Only need to create the invoice on first notification
	public function autoInvoice($invoice_number, $email_subject = null, $email_stationary = null, $createInvoice = false, $transactionType) {
		
		//First check to see if the client has disabled auto emails
		$clientInvoice = $this->getInvoiceById($invoice_number);
		$clientEmail = new clientEmail($this->db);
		if($clientEmail->allowAutoEmail($clientInvoice->client_id) == false) {
			//Finish this process
			return;
		}
	 
	 	$invoice_id = 0;
	 	$client_id = '';
	 
		if($createInvoice) {
			$invoice_id = $this->generateAutoInvoice($invoice_number);
		}
		else {
			$invoice_id = $invoice_number; 
		}
		
		//Now do the email to the client/associate and head office
		if(!is_null($email_stationary)) {

			$invoice = $this->getInvoiceById($invoice_id);
			$objects->clientUtils		= new clientUtils($this->db);	
			$clientDetail	= $objects->clientUtils->getClientByClientId($invoice->client_id);
		 
			// Create the invoice node.
			$doc = new DOMDocument('1.0','UTF-8');
			$doc->appendChild($doc->createElement('config'));
			//$invoiceDoc = $->doc;
			
			$fopNode = $doc->lastChild->appendChild($doc->createElement('fop'));
			$fopNode->appendChild(invoice::toXml($invoice, $doc));
			
			// Generate the invoice PDF.
			//Check the current site, for the correct invoice
			$invoice_template = GENERATOR . "-invoice";
			$invoiceFilename = (ADMIN_TEMPLATE != '' ? ADMIN_TEMPLATE : "GreenBizCheck")."-Invoice-".$invoice->invoice_no_display.".pdf";
			$invoiceFop = new fopRenderer($invoice_template, @$doc);
			$invoicePdf = $invoiceFop->render();
		
			// Email
			//Construct the body
			$clientNode = $doc->lastChild->appendChild($doc->createElement('client'));
			foreach($clientDetail as $key => $val) {
				if($key == 'contact') { continue; }
					$clientNode->setAttribute($key,$val);
			}
		
			for($i=0;$i<count($clientDetail->contact);$i++) {
				$contactNode = $clientNode->appendChild($doc->createElement('contact'));
				foreach($clientDetail->contact[$i] as $key => $val) {
					$contactNode->setAttribute($key,$val);
				}
				if($clientDetail->contact[$i]->send_auto_emails == 1) {
					$emailTo[] = $clientDetail->contact[$i]->email;
				}
			}
		
			$xsl = new XSLTProcessor();
			$xsl->registerPHPFunctions();
			$xsl->importStyleSheet(DOMDocument::load(PATH_SYSTEM.'/emailStationary/'.$email_stationary.'.xsl'));
			$emailTo		= implode(', ',$emailTo);
			$message		= $xsl->transformToXML($doc);			

			//Convert the message to inline html
			$pre = Premailer::html($message);
			$message = $pre['html'];

			//Add this email to the CRM for the current client
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`client_email` (client_contact_id, sent_date, email_to, email_stationery, email_subject, email_body)
				VALUES ("%2$d", "%3$s", "%4$s", "%5$s", "%6$s", "%7$s")
			',
				DB_PREFIX.'crm',
				$this->db->escape_string($clientDetail->contact[0]->client_contact_id),
				$this->db->escape_string(date('Y-m-d H:i:s', time())),
				$this->db->escape_string($clientDetail->contact[0]->email),
				'', //Not storing the stationary details in the system - just the message for now
				$this->db->escape_string($email_subject),
				$this->db->escape_string($message)
			));
		
			//Get the account owner if one exists
			$account_owner = clientContact::stGetAccountOwnerByClientId($this->db, $invoice->client_id);
		
			//Set the BCC addresses for the invoice to be emailed.
			$bccAddresses = "info@greenbizcheck.com";
		
			mailer::deliver($emailTo, "\"GreenBizCheck\" <info@greenbizcheck.com>", $email_subject, $message, array($invoiceFilename => $invoicePdf), $bccAddresses);
	  }
		return;
	}
	
	//Get the details from the paypal_transaction table
	public function getPayPalTransaction($paypal_transaction_id) {
		$transaction = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`paypal_transaction`
			WHERE `paypal_transaction`.`paypal_transaction_id` = %2$d;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($paypal_transaction_id)
		))) {
			while($row = $result->fetch_object()) {
				$transaction = $row;
			}
			$result->close();
		}
		return($transaction);
	}
	
	public function getAppliedCoupon($coupon_id) {
		$coupon = array();
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`coupon`
			WHERE `coupon_id` = %2$d;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($coupon_id)
		))) {
			while($row = $result->fetch_object()) {
				$coupon[] = $row;
			}
			$result->close();
		}
		return($coupon);
	}
}
?>