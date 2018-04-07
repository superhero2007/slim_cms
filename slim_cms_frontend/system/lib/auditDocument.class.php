<?php
//Audit File Uploading Class

class auditDocument {
 
 	private $db;
	
	//Get an instance of the database connection in the constructor
	public function __construct($db) {
		$this->db = $db;
	}

	//Call to upload a new document for an audit item
	function uploadDocument() {
		if (!empty($_FILES)) {
 			//Get the file extension
 			$ext = end(explode('.', $_FILES['Filedata']['name']));
 			
			//Get the file name for document storage
			$file_name = $_REQUEST['client_checklist_id'] . "_" . $_REQUEST['audit_id'] . "_" . time() . "." . $ext;
			
			//Create the file name - Audit document path from config + the original file name
			$targetFile =  PATH_AUDIT_DOCUMENTS . "/" . $file_name;
	
			//Move the temp file to the audit documents folder with the details above
			move_uploaded_file($_FILES['Filedata']['tmp_name'],$targetFile);
			//echo $_FILES['Filedata']['name'] . " uploaded";
			
			//Insert the uploaded file into the database
			$this->addAuditDocument($_REQUEST['client_checklist_id'], $_REQUEST['audit_id'],$_FILES['Filedata']['name'],$file_name);
		}
		return;
	}

	//Call to insert the uploaded document into the database with real name and filed name attached to a client checklist
	public function addAuditDocument($client_checklist_id, $audit_id, $document_name, $document_file_name){
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`document_2_client_checklist` SET
				`client_checklist_id` = %2$d,
				`document_name` = "%3$s",
				`document_file_name` = "%4$s",
				`audit_id` = %5$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($document_name),
			$this->db->escape_string($document_file_name),
			$this->db->escape_string($audit_id)
		));
		return;
	}

	//Call to delete uploaded document from the database
	public function deleteAuditDocument($client_checklist_id, $audit_id) {
			
		//Now delete the database entry	 
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`document_2_client_checklist`
			WHERE `client_checklist_id` = %2$d AND `audit_id` = %3$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($audit_id)
		));
		
		return;
	}

	//Call to delete uploaded document from the database
	public function deleteAuditEvidence($client_checklist_id, $audit_id) {
		
		$this->db->query(sprintf('
			DELETE FROM `%1$s`.`audit_evidence`
			WHERE `client_checklist_id` = %2$d AND `audit_id` = %3$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($audit_id)
		));
		
		return;
	}

	//Call to insert the uploaded document into the database with real name and filed name attached to a client checklist
	public function addAuditEvidence($client_checklist_id, $audit_id, $hash){
		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`audit_evidence` SET
				`client_checklist_id` = %2$d,
				`audit_id` = %3$d,
				`value` = "%4$s";
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($audit_id),
			$this->db->escape_string($hash)
		));
		return;
	}

	public function getCertificationLevel($certification_level_id) {
		$certification_level = null;

		$query = sprintf('
			SELECT *
			FROM %1$s.certification_level
			WHERE `certification_level_id` = %2$d
			LIMIT 1;
		',
			DB_PREFIX.'checklist',
			$this->db->escape_string($certification_level_id)
		);

	 	if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$certification_level = $row;
			}
		}

		return $certification_level;
	}
	
	//Take the audit file id as a parameter and send the original file to screen for download with the original file name
	public function downloadAuditDocument($audit_document_id) {
	 	$uploadfile = "";
	 	$document_name = "";
	 
	 	//Get the document details from the database first
	 	if($result = $this->db->query(sprintf('
			SELECT
			`document_file_name`,
			`document_name`
			FROM `%1$s`.`document_2_client_checklist`
			WHERE `document_id` = %2$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($audit_document_id)
		))) {
		 	
			 //Loop through the results and delete the files from the file system
			while($row = $result->fetch_object()) {
				$uploadfile = PATH_AUDIT_DOCUMENTS . "/" . $row->document_file_name;
				$document_name = $row->document_name;
			}
		}
		
		//Get the info about the file for the content type header
		//$finfo = finfo_open(FILEINFO_MIME_TYPE);
		//$content_type = finfo_file($finfo,$uploadfile);
		
        //Send file to the browser with the original file name
      //  header("Content-type: ". $content_type);
        header("Content-disposition: attachment; filename=".$document_name);
		header("Content-length: ".filesize($uploadfile));
		
		//Open the file and start reading/writing it to eht browser
		$fp = fopen($uploadfile, "r");
		while (!feof($fp)) {
			echo fread($fp, 256*1024);
		}
		
		//Close the file and finish
		fclose($fp);
        die();
	}
	
	//Submit Audit
	public function submitAudit($client_checklist_id, $current_score, $certification_level_id, $client_contact_id) {
		$this->superseedAudits($client_checklist_id);

		$this->db->query(sprintf('
			INSERT INTO `%1$s`.`audit` SET
				`client_checklist_id` = %2$d,
				`certification_level_id` = %3$d,
				`client_contact_id` = %4$d,
				`audit_score` = "%5$s";
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string($certification_level_id),
			$this->db->escape_string($client_contact_id),
			$this->db->escape_string($current_score)
		));
		
		//Update the audit cost
		$auditCost = new auditCost($this->db);
		$auditCost->setAuditCost($this->db->insert_id);
		
		return;
	}

	//Superseed Audit
	public function superseedAudits($client_checklist_id) {
		$this->db->query(sprintf('
			UPDATE `%1$s`.`audit` SET
			`status` = "3",
			`audit_finish_date` = "%3$s"
			WHERE `client_checklist_id` = %2$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($client_checklist_id),
			$this->db->escape_string(date("Y-m-d H:i:s"))
		));

		return;
	}
	
	//Resubmit Audit
	public function resubmitAudit($audit_id) {
	 	if($result = $this->db->query(sprintf('
			UPDATE `%1$s`.`audit` SET 
			`status` = "2"
			WHERE `audit_id` = %2$d;
		',
			DB_PREFIX.'audit',
			$this->db->escape_string($audit_id)
		)))

		return;
	}
}
?>