<?php
//File Upload Class

class fileUpload {
 
 	private $db;
 	private $files = array();
 	private $response = array();
	
	//Get an instance of the database connection in the constructor
	public function __construct($db) {
		$this->db = $db;
		$this->processAction();
	}

	private function processAction() {
		if(isset($_REQUEST['action'])) {
			switch($_REQUEST['action']){

				case 'upload':
					$this->uploadFile();
				break;

				case 'delete':
					$this->deleteFile();
				break;

				default:
					$this->jsonResponse('Error: Invalid request.');
				break;
			}
		} else {
			$this->jsonResponse('Error: No request.');
		}

		return;
	}

	//Upload file
	public function uploadFile() {

		if (!empty($_FILES)) {
			foreach($_FILES as $uploadFile) {

				//Get the file details
				$fileDetails = pathinfo($uploadFile['name']);

				//Create the file object
				$file = new stdClass;
				$file->name = $uploadFile['name'];
				$file->size = $uploadFile['size'];
				$file->tmpname = $uploadFile['tmp_name'];
				$file->hash = isset($_REQUEST['hash']) && $_REQUEST['hash'] !== '' ? $_REQUEST['hash'] : $this->generateRandomKey();

				//Delete any existing file and then insert a new file
				$this->removeFile($file->hash);
				$this->insertFile($file);
			}
			$this->jsonResponse(array_merge(array('files' => $this->files)));
		}	

		return;
	}

	//Insert File into database and filesystem
	private function insertFile($file) {

		//Insert file into the database
		$this->db->query(sprintf('INSERT INTO %1$s.file_upload SET hash = "%2$s",name = "%3$s",size = "%4$s"',DB_PREFIX.'core',$file->hash,$file->name,$file->size));

		//Relocate the file to the filesystem
		move_uploaded_file($file->tmpname, PATH_FILE_UPLOAD . "/" . $file->hash);
		$this->files[] = $file;

		return;
	}

	//Remove the file form the database and filesystem
	private function removeFile($hash) {

		//Remove any other files with the same hash from the filesystem
		$removeFiles = glob(PATH_FILE_UPLOAD . "/" . $hash);
		foreach($removeFiles as $removeFile) {
			if(unlink($removeFile)) {
				//Remove any files with the same hash from the database
				$this->db->query(sprintf('DELETE FROM `%1$s`.`file_upload` WHERE `file_upload`.`hash` = "%2$s";', DB_PREFIX.'core', $this->db->escape_string($hash)));
				$this->setResponseData('false', 'File successfully deleted.');
			} else {
				$this->setResponseData('true', 'Error deleting file.');
			}
		}

		return;
	}

	//Public delete file for AJAX post
	public function deleteFile() {

		if(isset($_POST['hash'])) {
			$this->removeFile($_POST['hash']);
		} else {
			$this->setResponseData('true', 'Invalid file.');
		}

		return;
	}

	private function setResponseData($error, $message) {

		$reponseData = array();
		$responseData['error'] = $error;
		$responseData['message'] = $message;
		$this->response[] = $responseData;
		$this->jsonResponse(array_merge(array('response' => $this->response)));		

		return;
	}

	private function jsonResponse($data) {

		header('Content-Type: application/json');
		echo json_encode($data);
		die();
	}

	//Get a random key for the file storage
	private function generateRandomKey() {
		$key = null;

		do {
			$key = md5(uniqid(rand(),1));
		} while($this->checkRandomKeyExists($key));

		return $key;
	}

	private function checkRandomKeyExists($key) {
		$exists = false;
		$query = sprintf('SELECT * FROM %1$s.file_upload WHERE file_upload.hash = "%2$s";', DB_PREFIX.'core',$key);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
				$exists = true;
			}
			$result->close();
		}

		return $exists;
	}
}
?>