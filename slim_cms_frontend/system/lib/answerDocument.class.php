<?php
//Answer File Uploading Class

class answerDocument {
 
 	private $db;
	
	//Get an instance of the database connection in the constructor
	public function __construct($db) {
		$this->db = $db;
	}

	//Blueimp File Upload
	function uploadAnswerFile() {
		if (!empty($_FILES)) {
			
 			//Get the file extension
 			$ext = end(explode('.', $_FILES['Filedata']['name']));
 			
			//Get the file name for document storage
			$file_name = $_REQUEST['file_name'] . "." . $ext;
			
			//Create the file name - Audit document path from config + the original file name
			$targetFile =  PATH_ANSWER_DOCUMENTS . "/" . $file_name;
	
			//Move the temp file to the audit documents folder with the details above
			move_uploaded_file($_FILES['Filedata']['tmp_name'],$targetFile);
			
			//Echo the file name for the script to pick up
			echo $file_name;
		}	

		return;
	}

	//Uploadify Based File Upload 
	//Call to upload a new document for an audit item
	function uploadAnswerDocument() {
		if (!empty($_FILES)) {
 			//Get the file extension
 			$ext = end(explode('.', $_FILES['Filedata']['name']));
 			
			//Get the file name for document storage
			$file_name = $_REQUEST['file_name'] . "." . $ext;
			
			//Create the file name - Audit document path from config + the original file name
			$targetFile =  PATH_ANSWER_DOCUMENTS . "/" . $file_name;
	
			//Move the temp file to the audit documents folder with the details above
			move_uploaded_file($_FILES['Filedata']['tmp_name'],$targetFile);
			
			//Echo the file name for the script to pick up
			echo $file_name;
		}
		return;
	}

	//Get file details
	public function getFileDetails($hash) {
		$file = new stdClass;

		$query = sprintf('
			SELECT *
			FROM %1$s.client_result_answer_file
			WHERE client_result_answer_file.hash = "%2$s"
			LIMIT 1;
		',
			DB_PREFIX.'checklist',
			$hash
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$file = $row;
			}
			$result->close();
		}

		//Check if file exists
		$file->exists = file_exists(PATH_ANSWER_DOCUMENTS . "/" . $hash);	

		return $file;
	}
	
	//Download the answerDocument to screen
	public function downloadAnswerDocument($document_name) {
		$file_name = PATH_ANSWER_DOCUMENTS . "/" . $document_name;
		
		//Check that the file exists, if so continue
		if(!file_exists($file_name)) {
			die();
		}

		//If a matching answer file is found in the database, get the details
		$query = sprintf('
			SELECT *
			FROM %1$s.client_result_answer_file
			WHERE client_result_answer_file.hash = "%2$s";
		',
			DB_PREFIX.'checklist',
			$document_name
		);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				if(isset($row->name)) {
					$document_name = $row->name;
				}
			}
			$result->close();
		}			

		//Set the download rate
		$download_rate = 1000;
	    header('Cache-control: private');
	    header('Content-Type: application/octet-stream');
	    header('Content-Length: '.filesize($file_name));
	    header('Content-Disposition: filename='.$document_name);

	    flush();
	    $file = fopen($file_name, "r");
	    while(!feof($file))
	    {
	        //Send the current file part to the browser
	        print fread($file, round($download_rate * 1024));
	        flush();
	        sleep(0.5);
	    }
	    fclose($file);
	    die();	
	}
}
?>