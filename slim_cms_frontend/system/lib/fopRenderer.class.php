<?php
    class fopRenderer {
        
        private $templateName;
        private $xml;
        
        public function __construct($templateName, $xml) {
            $this->templateName = $templateName;
            $this->xml = $xml;
        }
        
        public function render() {
            return $this->renderOrSend(false, NULL);
        }
        
        public function sendFile($filename) {
            $this->renderOrSend(true, $filename);
        }
        
        private function renderOrSend($isOutput, $filename) {
            // Render the XSL-FO document from the assessment stylesheet and report DOM.
            $foXslt = new DOMDocument();
            $foXslt->load(PATH_FOP."/".$this->templateName."/".$this->templateName.".xsl");
            
            $xsl = new XSLTProcessor();
            $xsl->registerPHPFunctions();
            $xsl->importStyleSheet($foXslt);
            $fo = $xsl->transformToXML($this->xml);

            // Post XSL-FO to fop-servlet and get PDF in response.
            $base_path = "file:///".PATH_FOP."/".$this->templateName."/";
            $headers = array("Content-type: text/xml");
            $http = curl_init(FOP_RENDERER."?basePath=".$base_path);
            curl_setopt($http,  CURLOPT_POST,           1);         // Method: POST
            curl_setopt($http,  CURLOPT_POSTFIELDS,     $fo);       // FO 
            curl_setopt($http,  CURLOPT_HTTPHEADER,     $headers);
            curl_setopt($http,  CURLOPT_HEADER,         0);         // Do not return HTTP headers
            
            if ($isOutput) {
                // Return the contents of the PDF.
                header("Content-type: application/x-pdf");
                header("Content-disposition: attachment; filename=".$filename);
                curl_exec($http); // Will auto-output results.
                die();
            }
            else {
                // Return PDF data as string if not outputting.
                curl_setopt($http, CURLOPT_RETURNTRANSFER,  1);
                return curl_exec($http);
            }            
            
        }
        
        //Takes the data of a file, and a file (with complete path) name and save it to a location
        public function save_file($data, $filename) {           
			$fp = fopen($filename, "w");
			fwrite($fp, $data);
			fclose($fp);
			
			return;
        }
        
        //Takes an array of existing PDF files, and a file name, with path, merges the files and outputs them to screen
        public function mergeFilesAndReturn($pdfArray, $filename) {
        	
        	//Get the array of pdf files and add to the pdf merge command
        	$filenameAndPath = PATH_PDF_MERGE . "/" . $filename;
        	$pdfs = "";
        	foreach($pdfArray as $pdf) {
        		$pdfs .= PATH_PDF_MERGE . "/" . $pdf . " ";
        	}
        
			//$command = PDFTK_PATH . '/pdftk ' . $pdfs . 'cat output ' . $filenameAndPath;
			$this->waitForFile($pdfs[0], '30');
			
			$command = GS_PATH . "/gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=" . $filenameAndPath . " " . $pdfs;
			$result = passthru($command);
			
			header('Content-type: application/x-pdf');
			header('Content-disposition: attachment; filename=' . $filename);
			
			readfile($filenameAndPath);
			
			//Delete the temp files
			foreach($pdfArray as $key=>$val) {
				if($key === 'temp') {
					unlink(PATH_PDF_MERGE . "/" . $val);
				}
			}
			
			//Delete the downloaded report
			unlink($filenameAndPath);

			die();
        }
        
        //Check that the file exists, if not sleep and try again
        public function waitForFile($file, $time = 30) {
			
			$count = 0;
			while (!is_readable($file)) {
				if($count > $time) {
					break;
				}
				sleep(1);
				$count++;
			}        
        
        	return;
        }
        
    }
?>