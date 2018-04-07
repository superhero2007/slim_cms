<?php
// Only return email_body if $RETURN_EMAIL_BODY is true. Should reduce XSLT processing requirements.
$RETURN_EMAIL_BODY = false;

// Return the email bodies when we are showing the email bodies.
if (isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'email_show') {
	$RETURN_EMAIL_BODY = true;
}

//Now get everything
//All of this information below is used for the XSL rendering
//We should try and limit the amount of details coming out for this as there could be a lot of information which could slow down the system

//Get the result filter object

//Get all of the different client types
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`client_type`;
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'client_type');
	}
	$result->close();
}

if($result = $this->db->query($sql = sprintf('
	SELECT 
		`client`.*,
		`client_type`.`client_type`
	FROM `%1$s`.`client`
	LEFT JOIN `%1$s`.`client_type` ON `client`.`client_type_id` = `client_type`.`client_type_id`
	WHERE 1
	' . resultFilter::conditional_client_filter($this->db, $this->user) . '
	ORDER BY `client`.`company_name` ASC
',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'client');
	}
	$result->close();
}

//Get Partner to Client Relationship
if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`partner_2_client`
		LEFT JOIN `%1$s`.`client` ON `parter_2_client`.`client_id` = `client`.`client_id`
		',
		DB_PREFIX.'billing'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'partner_2_client');
	}
	$result->close();
}
		
if($result = $this->db->query(sprintf('
	SELECT
		`country`.`country_id`,
		`country`.`country`
		FROM `%1$s`.`country`;
		',
		DB_PREFIX.'resources'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'country');
	}
	$result->close();
}

if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`anzsic`
		ORDER BY `description`;
		',
		DB_PREFIX.'resources'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'industry');
	}
	$result->close();
}

if(isset($_REQUEST['client_id'])) {
	if($result = $this->db->query(sprintf('
		SELECT `client_contact`.*
		FROM `%1$s`.`client_contact`
		LEFT JOIN `%1$s`.`client` ON `client_contact`.`client_id` = `client`.`client_id`
		WHERE `client_contact`.`firstname` != ""
		AND `client_contact`.`lastname` != ""
		AND `client_contact`.`email` != ""
		AND `client_contact`.`client_id` = %2$d
		ORDER BY `client_contact`.`sequence` ASC;
	',
		DB_PREFIX.'core',
		$_REQUEST['client_id']
	))) {
		while($row = $result->fetch_object()) {
	 		$row->photo = is_file(PATH_ROOT.'/public_html/_images/partners/business_owner_contact_'.$row->client_contact_id.'.gif') ? 'yes' : 'no';
			$this->row2config($row,'client_contact');
		}
		$result->close();
	}	
}
//Only run this if the client_id is set in the request string
if(isset($_REQUEST['client_id']) || (isset($_REQUEST['mode']) && $_REQUEST['mode'] == "invoice_list")) {
	if($result = $this->db->query(sprintf('
		SELECT `client_note`.*
		FROM `%1$s`.`client_note`
		WHERE `client_note`.`client_id` = %2$d;
	',
		DB_PREFIX.'core',
		$_REQUEST['client_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'client_note');
		}
		$result->close();
	}
	if($result = $this->db->query(sprintf('
		SELECT `associate`.*
		FROM `%1$s`.`associate`;
	',
		DB_PREFIX.'associate'
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'associate');
		}
		$result->close();
	}
	if($result = $this->db->query(sprintf('
		SELECT `checklist`.*
		FROM `%1$s`.`checklist`
		LEFT JOIN `%1$s`.`checklist_2_client_type` ON `checklist`.`checklist_id` = `checklist_2_client_type`.`checklist_id`
		WHERE 1		
		;
	',
		DB_PREFIX.'checklist',
		DB_PREFIX.'core'
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'checklist');
		}
		$result->close();
	}
	
	if($result = $this->db->query(sprintf('
		SELECT `checklist_variation`.*
		FROM `%1$s`.`checklist_variation`;
	',
		DB_PREFIX.'checklist'
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'checklist_variation');
		}
		$result->close();
	}
}

//Only run this if the client_id is set in the request string
if(isset($_REQUEST['client_id']) || (isset($_REQUEST['mode']) && $_REQUEST['mode'] == "invoice_list")) {
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`transaction`
	LEFT JOIN `%2$s`.`client` ON `transaction`.`client_id` = `client`.`client_id`
	WHERE 1
',
	DB_PREFIX.'pos',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'transaction');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT
		`invoice`.*,
		DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY) AS `due_date`,
		DATEDIFF(NOW(),DATE_ADD(`invoice`.`invoice_date`, INTERVAL `invoice`.`terms` DAY)) AS `days_passed`,
		`coupon_2_invoice`.`coupon_id`
	FROM `%1$s`.`invoice`
	LEFT JOIN `%1$s`.`coupon_2_invoice` ON `invoice`.`invoice_id` = `coupon_2_invoice`.`invoice_id`
	LEFT JOIN `%2$s`.`client` ON `invoice`.`client_id` = `client`.`client_id`
	WHERE 1
	ORDER BY `invoice_date` ASC;
',
	DB_PREFIX.'pos',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'invoice');
	}
	$result->close();
}

if($result = $this->db->query(sprintf('
	SELECT
		*,
		`quantity` * `price_per_item` AS `total`
	FROM `%1$s`.`product_2_invoice`
	LEFT JOIN `%1$s`.`invoice` ON `product_2_invoice`.`invoice_id` = `invoice`.`invoice_id`
	LEFT JOIN `%2$s`.`client` ON `invoice`.`client_id` = `client`.`client_id`
	WHERE 1
',
	DB_PREFIX.'pos',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'product_2_invoice');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`product`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'product');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`product_price`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'product_price');
	}
	$result->close();
}
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`currency`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'currency');
	}
	$result->close();
}

//Get the coupon codes that are valid
if($result = $this->db->query(sprintf('
	SELECT
	`coupon`.`coupon_id`,
	`coupon`.`coupon`,
	`coupon`.`discount`,
	`coupon`.`discount_type`
	FROM `%1$s`.`coupon`
	WHERE `expire_date` > now()
    ORDER BY `coupon`;
',
	DB_PREFIX.'pos'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'coupon');
	}
	$result->close();
}

}
if(isset($_REQUEST['client_id'])) {
	$cc = new clientChecklist($this->db);
	$clientChecklists = $cc->getChecklists($_REQUEST['client_id']);
	foreach($clientChecklists as $clientChecklist) {
	
		is_null($clientChecklist->current_score) ? $clientChecklist->current_score = '0' : 1;
		$this->row2config($clientChecklist,'client_checklist');
	}

if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`client_checklist_permission`
	LEFT JOIN `%2$s`.`client` ON `client_checklist_permission`.`client_id` = `client`.`client_id`
	WHERE 1
',
	DB_PREFIX.'checklist',
	DB_PREFIX.'core'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'client_checklist_permission');
	}
	$result->close();
}

}

//Client audits
if (isset($_REQUEST['client_id'])) {
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`client_checklist`
		LEFT JOIN `%2$s`.`audit` ON `audit`.`client_checklist_id` = `client_checklist`.`client_checklist_id`
		WHERE `client_checklist`.`client_id` = %3$d;
	',
		DB_PREFIX.'checklist',
		DB_PREFIX.'audit',
		$_REQUEST['client_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'client_checklist_audit');
		}
		$result->close();
	}
}

// Client Emails
if (isset($_REQUEST['client_id'])) {
	if ($result = $this->db->query(sprintf('
		SELECT `client_email`.*
		FROM `%1$s`.`client_email` 
			INNER JOIN `%2$s`.`client_contact` USING (client_contact_id)
		WHERE `client_contact`.`client_id` = %3$d
	',
		DB_PREFIX.'crm',
		DB_PREFIX.'core',
		$_REQUEST['client_id']
	))) {
		while($row = $result->fetch_object()) {
			$row->sent_date = strftime("%Y-%m-%dT%H:%M:%S", strtotime($row->sent_date));
			$row->sent_date_au = date("d/m/Y H:i:s", strtotime($row->sent_date));
			// Only return email_body if $RETURN_EMAIL_BODY is true.
			if (!$RETURN_EMAIL_BODY) {
				$row->email_body = NULL;
			}
			$this->row2config($row,"client_email");
		}
		$result->close();
	}
}

//Get Dashboard Access Fields 
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`dashboard_group`;
',
	DB_PREFIX.'dashboard'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'dashboard_group');
	}
	$result->close();
}
 
if($result = $this->db->query(sprintf('
	SELECT *
	FROM `%1$s`.`dashboard_role`;
',
	DB_PREFIX.'dashboard'
))) {
	while($row = $result->fetch_object()) {
		$this->row2config($row,'dashboard_role');
	}
	$result->close();
}

if(isset($_REQUEST['client_contact_id'])) {
	if($result = $this->db->query(sprintf('
		SELECT *
		FROM `%1$s`.`client_contact_2_dashboard`
		WHERE `client_contact_id` = %2$d;
	',
		DB_PREFIX.'dashboard',
		$_REQUEST['client_contact_id']
	))) {
		while($row = $result->fetch_object()) {
			$this->row2config($row,'client_contact_2_dashboard');
		}
		$result->close();
	}
}

//Get the client_checklist questions and answers
if(isset($_REQUEST['client_checklist_id']) && (isset($_REQUEST['mode']) && $_REQUEST['mode'] == "client_checklist_answer_report")) {
	$clientChecklist = new clientChecklist($this->db);
	$client_checklist_id = $_REQUEST['client_checklist_id'];
	
	//echo "<pre>";
	//Client Results
	$clientResults = $clientChecklist->getClientResults($client_checklist_id);
	foreach($clientResults as $clientResult) {
		$clientResult->arbitrary_value = str_replace("<br/>","<br/><br/>",nl2br(mb_convert_encoding($clientResult->arbitrary_value,"HTML-ENTITIES","UTF-8")));
		$this->row2config($clientResult,'client_result');
	}
		
	//Checklist Pages
	$checklistPages = $clientChecklist->getChecklistPages($client_checklist_id);
	foreach($checklistPages as $checklistPage) {
		//var_dump($checklistPage);
		$this->row2config($checklistPage,'checklistPage');
	}
	
	//Checklist Questions
	$pageQuestions = $clientChecklist->getClientChecklistQuestions($client_checklist_id);
	foreach($pageQuestions as $pageQuestion) {
		//var_dump($pageQuestion);
		$this->row2config($pageQuestion,'question');
	}
	
	//Checklist Answers
	$questionAnswers = $clientChecklist->getClientChecklistAnswers($client_checklist_id);
	foreach($questionAnswers as $questionAnswer) {
		$this->row2config($questionAnswer,'answer');
	}	
	//echo "</pre>";
}

// Stationery templates list.
$stationeryTemplates = stationery::getTemplates();
foreach ($stationeryTemplates as $template) {
	$this->row2config($template, 'stationery_template');
}

if (isset($_REQUEST['stationery_template']) && is_file(PATH_STATIONERY.$_REQUEST['stationery_template'])) {
	$clientEmail = new clientEmail($this->db);
	$clientId = $_REQUEST['client_id'];
	$clientContactId = isset($_REQUEST['client_contact_id']) ? $_REQUEST['client_contact_id'] : NULL;
	$renderedEmail = $clientEmail->render($clientId, $clientContactId, $_REQUEST['stationery_template']);
	$stationeryBodyNode = $this->doc->lastChild->appendChild($this->doc->createElement('stationery_body', $renderedEmail));
}

	
	//Error checking
	function validateEmail(&$error, $email, $db) {
		if(isset($error['email'])) return;
		if($result = $db->query(sprintf('
			SELECT *
			FROM `%1$s`.`client_contact`
			WHERE `email` = "%2$s"
			LIMIT 1;
		',
			DB_PREFIX.'core',
			$db->escape_string($email)
		))) {
			if($result->num_rows > 0) {
			 	$row = $result->fetch_object();
			 	if(isset($_GET['client_contact_id']) && $_GET['client_contact_id'] === $row->client_contact_id) {
			 		return;	 
			 	}
				$error['email'] = 'This email address is already registered';
			}
			$result->close();
		}
		return;
	}
	
	function validatePassword(&$error,$password_0,$password_1,$passwordFieldKey = 'password_0', $db) {
		if(isset($error[$passwordFieldKey])) return;
		
		$password = new password($db);
		
		if(!$password->checkPasswordComplexity($password_0)) {
			$error[$passwordFieldKey] = 'Password does not meet complexity requirements.';
		}
		
		if($password_0 != $password_1) {
			$error[$passwordFieldKey] = 'Passwords don\'t match';
		} 
		
		return;
	}


if(isset($_REQUEST['action'])) {
	switch($_REQUEST['action']) {
		case 'email_send': {
			$clientId = $_REQUEST['client_id'];
			$clientContactId = isset($_REQUEST['client_contact_id']) ? $_REQUEST['client_contact_id'] : NULL;
			
			$clientEmail = new clientEmail($this->db);
			$clientEmail->sendHTMLToClient(
				$clientId, 
				$clientContactId, 
				$_REQUEST['stationery_template'], 
				$_REQUEST['email_subject'], 
				$_REQUEST['email_body'], 
				$_REQUEST['email_cc']
			);
			header('Location: ?page=clients&mode=client_edit&client_id='.$_REQUEST['client_id']."#email_list");
			die();
		}
		case 'client_save': {
				
			if(isset($_POST['client_id']) && $_POST['client_id'] != "")
			{
				//Existing clients are being updated via admin	
				$registered = empty($_POST['registered']) ? date('Y-m-d H:i:s') : $_POST['registered'];
				$this->db->query(sprintf('
					UPDATE `%1$s`.`client` SET
						`client_type_id` = %3$d,
						`affiliate_id` = IF(%4$d != 0,%4$d,NULL),
						`associate_id` = IF(%5$d != 0,%5$d,NULL),
						`parent_id` = IF(%6$d != 0,%6$d,NULL),
						`associate_account_id` = IF(%7$d != 0,%7$d,NULL),
						`city_id` = %8$d,
						`source` = "%9$s",
						`registered` = "%10$s",
						`username` = "%11$s",
						`password` = "%12$s",
						`company_name` = "%13$s",
						`address_line_1` = "%15$s",
						`address_line_2` = "%16$s",
						`suburb` = "%17$s",
						`postcode` = "%18$s",
						`state` = "%19$s",
						`country` = "%20$s",
						`parent_company_id` = %21$d,
						`anzsic_id` = IF(%22$d != 0,%22$d,NULL),
						`existing_business_owner_id` = IF(%23$d != 0,%23$d,NULL),
						`distributor_id` = IF(%24$d != 0,%24$d,NULL)
					WHERE `client_id` = %2$d;
				',
					DB_PREFIX.'core',
					$this->db->escape_string($_POST['client_id']),
					$this->db->escape_string($_POST['client_type_id']),
					$this->db->escape_string($_POST['affiliate_id']),
					$this->db->escape_string($_POST['associate_id']),
					$this->db->escape_string($_POST['parent_id']),
					$this->db->escape_string($_POST['associate_account_id']),
					$this->db->escape_string($_POST['city_id']),
					$this->db->escape_string($_POST['source']),
					$this->db->escape_string($registered),
					$this->db->escape_string($_POST['username']),
					$this->db->escape_string($_POST['password']),
					$this->db->escape_string($_POST['company_name']),
					$this->db->escape_string($_POST['company_name']),
					$this->db->escape_string($_POST['address_line_1']),
					$this->db->escape_string($_POST['address_line_2']),
					$this->db->escape_string($_POST['suburb']),
					$this->db->escape_string($_POST['postcode']),
					$this->db->escape_string($_POST['state']),
					$this->db->escape_string($_POST['country']),
					($_POST['parent_company_id'] === '0' || $_POST['parent_company_id'] === 0 ? null : $this->db->escape_string($_POST['parent_company_id'])),
					$this->db->escape_string($_POST['industry']),
					$this->db->escape_string($_POST['existing_business_owner_id']),
					$this->db->escape_string($_POST['distributor_id'])
				));
				$client_id = $_POST['client_id'];
				$this->db->query(sprintf('
					UPDATE `%1$s`.`client` SET
						`account_no` = "%3$s"
					WHERE `client_id` = %2$d
				',
					DB_PREFIX.'core',
					$client_id,
					clientUtils::luhn($client_id,strtotime($registered))
				));
			}
			else {
				//New Client Registraion via admin
				$registered = empty($_POST['registered']) ? date('Y-m-d H:i:s') : $_POST['registered'];
				$this->db->query(sprintf('
					INSERT INTO `%1$s`.`client` SET
						`client_type_id` = %3$d,
						`affiliate_id` = IF(%4$d != 0,%4$d,NULL),
						`associate_id` = IF(%5$d != 0,%5$d,NULL),
						`parent_id` = IF(%6$d != 0,%6$d,NULL),
						`associate_account_id` = IF(%7$d != 0,%7$d,NULL),
						`city_id` = %8$d,
						`source` = "%9$s",
						`registered` = "%10$s",
						`username` = "%11$s",
						`password` = "%12$s",
						`company_name` = "%13$s",
						`address_line_1` = "%15$s",
						`address_line_2` = "%16$s",
						`suburb` = "%17$s",
						`postcode` = "%18$s",
						`state` = "%19$s",
						`country` = "%20$s",
						`parent_company_id` = %21$d,
						`anzsic_id` = IF(%22$d != 0,%22$d,NULL),
						`existing_business_owner_id` = IF(%23$d != 0,%23$d,NULL);
				',
					DB_PREFIX.'core',
					$this->db->escape_string($_POST['client_id']),
					$this->db->escape_string($_POST['client_type_id']),
					$this->db->escape_string($_POST['affiliate_id']),
					$this->db->escape_string($_POST['associate_id']),
					$this->db->escape_string($_POST['parent_id']),
					$this->db->escape_string($_POST['associate_account_id']),
					$this->db->escape_string($_POST['city_id']),
					$this->db->escape_string($_POST['source']),
					$this->db->escape_string($registered),
					$this->db->escape_string($_POST['username']),
					$this->db->escape_string($_POST['password']),
					$this->db->escape_string($_POST['company_name']),
					$this->db->escape_string($_POST['company_name']),
					$this->db->escape_string($_POST['address_line_1']),
					$this->db->escape_string($_POST['address_line_2']),
					$this->db->escape_string($_POST['suburb']),
					$this->db->escape_string($_POST['postcode']),
					$this->db->escape_string($_POST['state']),
					$this->db->escape_string($_POST['country']),
					($_POST['parent_company_id'] === '0' || $_POST['parent_company_id'] === 0 ? null : $this->db->escape_string($_POST['parent_company_id'])),
					$this->db->escape_string($_POST['industry']),
					$this->db->escape_string($_POST['existing_business_owner_id'])
				));
				
				$client_id = $this->db->insert_id;
				$this->db->query(sprintf('
					UPDATE `%1$s`.`client` SET
						`account_no` = "%3$s"
					WHERE `client_id` = %2$d
				',
					DB_PREFIX.'core',
					$client_id,
					clientUtils::luhn($client_id,strtotime($registered))
				));
			}
			
			//Update the JV Partner to Client Mapping
			if(isset($_POST['jv_partner_id']) && $_POST['jv_partner_id'] != "0")
			{
				$PartnerInformation = new billing($this->db);
				$partner_result = $PartnerInformation->replaceJVPartner($client_id, $_POST['jv_partner_id']);
			}
		
			header('location: ?page=clients&mode=client_edit&client_id='.$client_id);
			die();
		}
		case 'client_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`client`
				WHERE `client_id` = %3$d;
				DELETE FROM `%1$s`.`client_contact`
				WHERE `client_id` = %3$d;
				DELETE FROM `%1$s`.`client_note`
				WHERE `client_id` = %3$d;
				DELETE FROM `%2$s`.`client_result`
				WHERE `client_checklist_id IN (
					SELECT `client_checklist_id`
					FROM `%2$s`.`client_checklist`
					WHERE `client_id` = %3$d
				);
				DELETE FROM `%2$s`.`client_commitment`
				WHERE `client_checklist_id IN (
					SELECT `client_checklist_id`
					FROM `%2$s`.`client_checklist`
					WHERE `client_id` = %3$d
				);
				DELETE FROM `%2$s`.`client_checklist`
				WHERE `client_id` = %3$d;
				OPTIMIZE TABLE
					`%1$s`.`client`,
					`%1$s`.`client_contact`,
					`%1$s`.`client_note`,
					`%2$s`.`client_checklist`,
					`%2$s`.`client_result`,
					`%2$s`.`client_commitment`;
			',
				DB_PREFIX.'core',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['client_id'])
			));
			header('location: ?page=clients');
			die();
		}
		case 'client_contact_save': {
		 
			//Do error checking first
		
			$error	= array();
			$fields	= array(
				array('First name','firstname',1),
				array('Last name','lastname',1),
				array('Title / Position','position',0),
				array('Email','email',1,'email'),
				array('Phone','phone',0),
				array('Url','url',0),
				array('Client Admin','is_client_admin',0),
				array('Send Auto Emails','send_auto_emails',0)
			);

			$data = validateForm::validateDetails($fields,$error);
			validateEmail($error,$_POST['email'], $this->db);
		
			//If there are errors create the XML and return to the post form to correct
		 	$this->row2config($_POST,'return_values');
		 	$this->row2config($error,'error');

		 	if(!empty($error)) return;

		 	
			//If the above finds no errors we can insert/edit the details into the database below 
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`client_contact` SET
					`client_contact_id` = %2$d,
					`client_id` = %3$d,
					`sequence` = %4$d,
					`salutation` = "%5$s",
					`firstname` = "%6$s",
					`lastname` = "%7$s",
					`position` = "%8$s",
					`email` = "%9$s",
					`phone` = "%10$s",
					`is_client_admin` = %11$d,
					`send_auto_emails` = %12$d,
					`display_contact_photo` = %13$d,
					`url` = "%14$s",
					`description` = "%15$s",
					`locked_out` = "%16$s",
					`locked_out_expiry` = "%17$s"
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['client_contact_id']),
				$this->db->escape_string($_REQUEST['client_id']),
				$this->db->escape_string($_REQUEST['sequence']),
				$this->db->escape_string(""),
				$this->db->escape_string($_REQUEST['firstname']),
				$this->db->escape_string($_REQUEST['lastname']),
				$this->db->escape_string($_REQUEST['position']),
				$this->db->escape_string($_REQUEST['email']),
				$this->db->escape_string($_REQUEST['phone']),
				$this->db->escape_string($_REQUEST['is_client_admin']),
				$this->db->escape_string($_REQUEST['send_auto_emails']),
				$this->db->escape_string(isset($_REQUEST['display_contact_photo']) ? $_REQUEST['display_contact_photo'] : NULL),
				$this->db->escape_string(isset($_REQUEST['url']) ? $_REQUEST['url'] : NULL),
				$this->db->escape_string(isset($_REQUEST['description']) ? $_REQUEST['description'] : NULL),
				$this->db->escape_string(isset($_REQUEST['locked_out']) ? $_REQUEST['locked_out'] : '0'),
				$this->db->escape_string(isset($_REQUEST['locked_out_expiry']) ? $_REQUEST['locked_out_expiry'] : NULL)
			));
			
			//Upload the photo into the database for the business owner
			if(isset($_FILES['photo'])) {
				if(!is_null($_FILES['photo'])) {
					if($_FILES['photo']['error'] == UPLOAD_ERR_OK) {
						$img_info = getimagesize($_FILES['photo']['tmp_name']);
						if($img_info[0] == 130 && $img_info[1] == 180 && $img_info['mime'] == 'image/gif') {
							move_uploaded_file($_FILES['photo']['tmp_name'],PATH_ROOT.'/public_html/_images/partners/business_owner_contact_'.$_POST['client_contact_id'].'.gif');
						}
					}
				}
			}
						
			header('location: ?page=clients&mode=client_edit&client_id='.$_POST['client_id']);
			die();
		}
		case 'client_contact_set_password': {
		 
			//Do error checking first
		
			$error	= array();
			$fields	= array(
				array('Password','password_0',1),
				array('Confirm Password','password_1',1)
			);

			$data = validateForm::validateDetails($fields,$error);
			validatePassword($error, $_POST['password_0'], $_POST['password_1'], 'password_0', $this->db);
		
			//If there are errors create the XML and return to the post form to correct
		 	$this->row2config($_POST,'password_return_values');
		 	$this->row2config($error,'error');

		 	if(!empty($error)) return;

			if (clientContact::resetPassword($this->db, $_POST['client_contact_id'], $_POST['password_0'])) {
				header('location: ?page=clients&mode=client_edit&client_id='.$_POST['client_id']);
				die();
			}
						
			return;
		}
		case 'client_contact_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`client_contact`
				WHERE `client_contact_id` = %2$d;
				OPTIMIZE TABLE `%1$s`.`client_contact`;
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['client_contact_id'])
			));
			header('location: ?page=clients&mode=client_edit&client_id='.$_REQUEST['client_id']);
			die();
		}
		case 'client_contact_reorder': {
			for($i=1;$i<count($_REQUEST['table-client-contact-list']);$i++) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`client_contact` SET
						`sequence` = %2$d
					WHERE `client_contact_id` = %3$d;
				',
					DB_PREFIX.'core',
					$i,
					$this->db->escape_string($_REQUEST['table-client-contact-list'][$i])
				));
			}
			die();
		}
		case 'client_note_save': {
			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`client_note` SET
					`client_note_id` = %2$d,
					`client_id` = %3$d,
					`timestamp` = IF("%4$s" != "","%4$s",NOW()),
					`note` = "%5$s";
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_POST['client_note_id']),
				$this->db->escape_string($_POST['client_id']),
				$this->db->escape_string($_POST['timestamp']),
				$this->db->escape_string($_POST['note'])
			));
			header('location: ?page=clients&mode=client_edit&client_id='.$_POST['client_id']);
			die();
		}
		case 'client_note_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`client_note`
				WHERE `client_note_id` = %2$d;
				OPTIMIZE TABLE `%1$s`.`client_note`;
			',
				DB_PREFIX.'core',
				$this->db->escape_string($_REQUEST['client_note_id'])
			));
			header('location: ?page=clients&mode=client_edit&client_id='.$_REQUEST['client_id']);
			die();
		}
		case 'client_checklist_save': {
			$clientChecklistId = null;
			$clientChecklist = new clientChecklist($this->db);
			
			//See if the client_checklist is auditable
			$audit = $_POST['audit'];
			if($clientChecklist->checklistAuditRequired($_POST['checklist_id']) == '0') {
				$audit = 0;
			}
			
			if(empty($_POST['client_checklist_id'])) {
				$this->db->query(sprintf('
					INSERT INTO `%1$s`.`client_checklist` SET
						`checklist_id` = %2$d,
						`checklist_variation_id` = IF("%3$d" != "",%3$d,NULL),
						`client_id` = %4$d,
						`name` = "%5$s",
						`audit_required` = %6$d;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($_POST['checklist_id']),
					$this->db->escape_string($_POST['checklist_variation_id']),
					$this->db->escape_string($_POST['client_id']),
					$this->db->escape_string($_POST['name']),
					$audit
				));
				$clientChecklistId = $this->db->insert_id;
				
			} else {
				$clientChecklistId = $_POST['client_checklist_id'];
				$this->db->query(sprintf('
					UPDATE `%1$s`.`client_checklist` SET
						`checklist_variation_id` = IF("%2$d" != "",%2$d,NULL),
						`name` = "%3$s",
						`audit_required` = %5$d
					WHERE `client_checklist_id` = %4$d;
				',
					DB_PREFIX.'checklist',
					$this->db->escape_string($_POST['checklist_variation_id']),
					$this->db->escape_string($_POST['name']),
					$this->db->escape_string($_POST['client_checklist_id']),
					$audit
				));
			}

			// Create any permissions required (for the first time).
			if (isset($_POST['client_checklist_permission'])) {
				$newPermissions = array();
				foreach ($_POST['client_checklist_permission'] as $clientContactId => $value) {
					if ($value == 1) {
						$newPermissions[$clientContactId] = array(1, 1, 1); // can_read_checklist, can_read_report, can_edit_report
					}					
				}		
			}
			
			//Check to see if the client_checklist is ready for auditing
			if(isset($_POST['audit_cost']) && isset($_POST['client_checklist_id'])) {
				$this->db->query(sprintf('
					UPDATE `%1$s`.`audit` SET
						`audit_cost` = "%2$s"
					WHERE `client_checklist_id` = %3$d;
				',
					DB_PREFIX.'audit',
					$this->db->escape_string($_POST['audit_cost']),
					$this->db->escape_string($_POST['client_checklist_id'])
				));
			}
			
			header('location: ?page=clients&mode=client_edit&client_id='.$_POST['client_id']);
			die();
		}
		case 'client_checklist_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`client_checklist`
				WHERE `client_checklist_id` = %2$d;
				DELETE FROM `%1$s`.`client_result`
				WHERE `client_checklist_id` = %2$d;
				DELETE FROM `%1$s`.`client_commitment`
				WHERE `client_checklist_id` = %2$d;
				DELETE FROM `%1$s`.`client_checklist_permission`
				WHERE `client_checklist_id` = %2$d;
				OPTIMIZE TABLE
					`%1$s`.`client_checklist`,
					`%1$s`.`client_result`,
					`%1$s`.`client_commitment`;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['client_checklist_id'])
			));
			header('location: ?page=clients&mode=client_edit&client_id='.$_REQUEST['client_id']);
			die();
		}
		case 'client_checklist_reopen': {
			$this->db->multi_query(sprintf('
				UPDATE `%1$s`.`client_checklist`
				SET `completed` = NULL
				WHERE `client_checklist_id` = %2$d;
			',
				DB_PREFIX.'checklist',
				$this->db->escape_string($_REQUEST['client_checklist_id'])
			));
			header('location: ?page=clients&mode=client_edit&client_id='.$_REQUEST['client_id']);
			die();
		}
		case 'transaction_save': {
			$timestamp = strtotime($_POST['timestamp']) !== false ? strtotime($_POST['timestamp']) : time();
			$timestamp = date('Y-m-d H:i:s',$timestamp);
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`transaction` SET
					`client_id` = %2$d,
					`currency_id` = %3$d,
					`timestamp` = "%4$s",
					`amount` = "%5$f",
					`method` = "%6$s";
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['client_id']),
				$this->db->escape_string($_POST['currency_id']),
				$this->db->escape_string($timestamp),
				$this->db->escape_string($_POST['amount']),
				$this->db->escape_string($_POST['method'])
			));
			
			//Distribute the payment with the associated parties
			$distribution = new billing($this->db);
			$distribution->applyRevenueShare($this->db->insert_id);
			
			header('location: ?page=clients&mode=client_edit&client_id='.$_POST['client_id']);
			die();
		}
		case 'transaction_delete': {
			$this->db->query(sprintf('
				DELETE FROM `%1$s`.`transaction`
				WHERE `transaction_id` = %2$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['transaction_id'])
			));
			
			//Delete any associated revenue distribution based on this transaction
			$distribution = new billing($this->db);
			$distribution->deleteRevenueShare($_REQUEST['transaction_id']);
			
			header('location: ?page=clients&mode=client_edit&client_id='.$_REQUEST['client_id']);
			die();
		}
		case 'invoice_save': {

			//Replace or create the invoice
			$invoice = new invoice($this->db);
			$existing_invoice = $invoice->getInvoiceById($_REQUEST['invoice_id']);
			
			if(($_REQUEST['coupon_id'] > 0) && ($existing_invoice->coupon_id > 0)) {
				$discount = 0;
			}
			else {
				$discount = $_POST['discount'];
			}
			
			$invoice_id = $invoice->addInvoice($_POST['client_id'], $_POST['currency_id'], $_POST['terms'], $_POST['invoice_date'] != '' ? date("Y-m-d",strtotime($_POST['invoice_date'])) : null, $discount, $_POST['notes'], $_POST['invoice_id'], $_REQUEST['archive'], ($_REQUEST['paid_date'] != '' && $_REQUEST['paid_date'] != '0000-00-00') ? date("Y-m-d",strtotime($_REQUEST['paid_date'])) : null);
			
			//If coupon_id is not equal to zero insert the invoice coupon redemption, otherwise delete on the invoice id
			if($_REQUEST['coupon_id'] > 0) {
				$invoice->insertCoupon2Invoice($_REQUEST['invoice_id'], $_REQUEST['coupon_id']);
			}
			else {
				if(!is_null($existing_invoice) && $existing_invoice->coupon_id > 0) {
					$invoice->deleteCoupon2Invoice($_REQUEST['invoice_id']);
				}
			}
			
			$invoice->updateInvoicePricePerItem($invoice_id);

			//Return to admin after completing the process
			header('location: ?page=clients&mode=invoice_edit&client_id='.$_POST['client_id'].'&invoice_id='.$invoice_id);
			die();
		}
		case 'invoice_delete': {
 
			$invoice = new invoice($this->db);
			$invoice->deleteInvoice($_REQUEST['invoice_id']);
			
			header('location: ?page=clients&mode=client_edit&client_id='.$_REQUEST['client_id']);
			die();
		}
		case 'product_2_invoice_save': {
		 
		 $product_price = 0;
		 
		 //Added a lookup on product_price before insert
		 if($result = $this->db->query(sprintf('
			SELECT `price`
			FROM `%1$s`.`product_price`
			WHERE `product_id` = %2$d
			LIMIT 1;
		',
			DB_PREFIX.'pos',
			$this->db->escape_string($_POST['product_id'])
		))) {
		 	$row = $result->fetch_object();
			$product_price = $row->price;
		}
		 
			$this->db->query(sprintf('
				INSERT INTO `%1$s`.`product_2_invoice` SET
					`invoice_id` = %2$d,
					`product_id` = %3$d,
					`quantity` = %4$d,
					`price_per_item` = "%5$f",
					`received` = %6$d;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_POST['invoice_id']),
				$this->db->escape_string($_POST['product_id']),
				$this->db->escape_string($_POST['quantity']),
				$product_price,
				$this->db->escape_string($_POST['received'])
			));
			
			$invoice = new invoice($this->db);
			$invoice->updateInvoicePricePerItem($_POST['invoice_id']);
			
			header('location: ?page=clients&mode=invoice_edit&client_id='.$_POST['client_id'].'&invoice_id='.$_POST['invoice_id']);
			die();
		}
		case 'product_2_invoice_delete': {
			$this->db->multi_query(sprintf('
				DELETE FROM `%1$s`.`product_2_invoice` WHERE `product_2_invoice_id` = %2$d;
				OPTIMIZE TABLE
					`%1$s`.`product_2_invoice`;
			',
				DB_PREFIX.'pos',
				$this->db->escape_string($_REQUEST['product_2_invoice_id'])
			));
			
			$invoice = new invoice($this->db);
			$invoice->updateInvoicePricePerItem($invoice_id);
			
			header('location: ?page=clients&mode=invoice_edit&client_id='.$_REQUEST['client_id'].'&invoice_id='.$_REQUEST['invoice_id']);
			die();
		}
		case 'send_invoice': {
			$pdfInvoice = new pdfInvoice($this->db);
			$pdfInvoice->build($_POST['invoice_id']);
			$pdfInvoice->output('invoice.pdf');
			die();
		}
		//Takes a client_checklist_id, creates a new checklsit and duplicates the answers into the new checklist
		case 'duplicate_client_checklist': {
			$clientChecklist = new clientChecklist($this->db);
			$new_client_checklist_id = $clientChecklist->duplicateClientChecklist($_REQUEST['client_checklist_id']);
			
			//If it worked, use the first URL, otherwise use the second URL and report the status
			if(!is_null($new_client_checklist_id)) {
				header('Location: ?page=clients&mode=client_checklist_edit&client_id=' . $_REQUEST['client_id'] . '&client_checklist_id=' . $new_client_checklist_id . '&query_result=success');
			}
			else {
				header('Location: ?page=clients&mode=client_checklist_edit&client_id=' . $_REQUEST['client_id'] . '&client_checklist_id=' . $_REQUEST['client_checklist_id'] . '&query_result=failed');				
			}
			die();
		}
		case 'export_client_results': {
			$clientChecklist = new clientChecklist($this->db);
			$clientChecklist->exportQuestionAnswers($_REQUEST['client_checklist_id']);
		}
		case 'client_contact_save_dashboard': {

		 	if($_REQUEST['enabled'] == '1') {
				$this->db->query(sprintf('
					REPLACE INTO `%1$s`.`client_contact_2_dashboard` SET
						`client_contact_id` = %2$d,
						`dashboard_group_id` = %3$d,
						`dashboard_role_id` = %4$d;
				',
					DB_PREFIX.'dashboard',
					$this->db->escape_string($_POST['client_contact_id']),
					$this->db->escape_string($_POST['dashboard_group_id']),
					$this->db->escape_string($_POST['dashboard_role_id'])
				));
			} elseif($_REQUEST['enabled'] == '0') {
				$this->db->query(sprintf('
					DELETE FROM `%1$s`.`client_contact_2_dashboard`
					WHERE `client_contact_id` = %2$d;
				',
					DB_PREFIX.'dashboard',
					$this->db->escape_string($_POST['client_contact_id'])
				));
			}
			
			
			header('location: ?page=clients&mode=client_contact_edit&client_id='.$_POST['client_id'].'&client_contact_id='.$_POST['client_contact_id']);
			die();
		}
	}
}


?>