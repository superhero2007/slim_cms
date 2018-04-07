<?php
//File Download Class
class fileDownload {
 
 	private $db;
	
	public function __construct($db) {
		$this->db = $db;
	}

    public function getFileInfo($hash) {
        $file = new stdClass;

		//Get the file based on the hash
		$query = sprintf('SELECT * FROM %1$s.file_upload WHERE file_upload.hash = "%2$s";', DB_PREFIX.'core', $hash);

		if($result = $this->db->query($query)) {
			while($row = $result->fetch_object()) {
                $file = $row;
				$file->hash = $hash;
                $file->path = PATH_FILE_UPLOAD . $hash;
                $file->size = !empty($file->size) ? $file->size : (file_exists($file->path) ? filesize($file->path) : null);
				$file->readable_size = $this->human_filesize($file->size);
			}
			$result->close();
		}

        //If no match, check for legacy filesize
        if(!isset($file->name)) {
            $file = $this->getLegacyFileInfo($hash);
        }

        return $file;
    }

    private function getLegacyFileInfo($hash) {
        $file = new stdClass;
        $file->path = PATH_FILE_UPLOAD . $hash;

        if(file_exists($file->path)) {
            $file->name = $hash;
			$file->hash = $hash;
            $file->size = filesize($file->path);
            $file->upload_date = filectime($file->path);
			$file->readable_size = $this->human_filesize($file->size);
        }

        return $file;
    }

    public function getFile($hash) {

        //Get the File info
        $file = $this->getFileInfo($hash);
		
		//Check that the file exists, if so continue
		if(!file_exists($file->path)) {
			die();
		}

		//Set the download rate
		$rate = 1000;
	    header('Cache-control: private');
	    header('Content-Type: application/octet-stream');
	    header('Content-Length: '.filesize($file->path));
	    header('Content-Disposition: filename='.$file->name);

	    flush();
	    $download = fopen($file->path, "r");
	    while(!feof($download))
	    {
	        //Send the current file part to the browser
	        print fread($download, round($rate * 1024));
	        flush();
	        sleep(0.5);
	    }
	    fclose($download);
	    die();	

    }

	function human_filesize($bytes, $dec = 2) 
	{
		$size   = array('B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
		$factor = floor((strlen($bytes) - 1) / 3);

		return sprintf("%.{$dec}f", $bytes / pow(1024, $factor)) . @$size[$factor];
	}
}
?>