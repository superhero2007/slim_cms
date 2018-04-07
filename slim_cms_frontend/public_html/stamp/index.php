<?php
/*
File: index.php
This is the file which when called with the correct variables will return a GreenBizCheck stamp in the right size and colour
This stamp generator is used on certificates and reports aswell as throughout the site
*/

require_once('../../config.php');
$db;

class stamp {

	private $im;
	private $source_im;
	private $cache_filename;

	//Stamp class constructor - This will get the URL passed to the stamp generator and start building the stamp	
	public function __construct() {
		if($input = $this->check_input()) {
		 
		 	//Take the URL variables and construct a file name to attempt and find in the /stamp directory
			$this->cache_filename = PATH_STAMP_CACHE.'/'.$input->image_path.'/'.$input->image_path.'-size_'.$input->max_width.'x'.$input->max_height.'.png';
			
			//Test the file to see if the URL constructed above actually exists - If so continue
			if (!file_exists($this->cache_filename)) {
			 	
			 	//Check to see if the file we are to create hasn't alread been created
				if (!file_exists(dirname($this->cache_filename))) {
					mkdir(dirname($this->cache_filename), 0777, true);
				}
			
				//Call the set image function with the image, width and height 
				$this->setImage($input->source,$input->max_width,$input->max_height);
			}
		}
	}
	
	//Push the newly created image to the users web browser
	public function render() {
		if ($this->cache_filename) {
			// Send file using mod_xsendfile Apache header.
			header("X-Sendfile: ".$this->cache_filename);
		    header("Content-Type: image/png");
			die();
		}
		else {
			// An error occurred, display it as an image.
			header("Content-type: image/png");
			imagepng($this->im);
			imagedestroy($this->im);
			return;
		}
	}
	
	//Add section to handle certification lookup on entering checklist_id
	//Takes the input from the query string and returns the value of 's' based in the value if 'clid'
	//This allows you to add a URL variable 'cclid' (client checklist id) which will then lookup the current score for this client checklist id and return the right stamp colour and stamp to create
	private function getCertificationLevel($input)
	{	
		$this->db = new mysqli(DB_HOST,DB_USER,DB_PASS);
		$this->db->autocommit(MYSQL_AUTOCOMMIT);
		
		$cclid = $_GET['cclid'];
		$audit_required = 0;
	
		if($result = $this->db->query(sprintf('
			SELECT
				`client_checklist`.`client_id`,
				`client_checklist`.`checklist_id`,
				`client_checklist`.`current_score`,
				`client_checklist`.`completed`,
				`client_checklist`.`audit_required`,
				`client_checklist`.`checklist_variation_id`,
				(SELECT `name` FROM `%1$s`.`certification_level` WHERE `client_checklist`.`checklist_id` = `certification_level`.`checklist_id` AND (ROUND(`client_checklist`.`current_score`,2) * 100) >= `certification_level`.`target` ORDER BY `certification_level`.`target` DESC LIMIT 1) AS `certification_level`,
				(SELECT `logo` FROM `%1$s`.`checklist` WHERE `client_checklist`.`checklist_id` = `checklist`.`checklist_id`) AS `certification_logo`
			FROM `%1$s`.`client_checklist`
			WHERE `client_checklist`.`client_checklist_id` = ' . $cclid . ';
		',
		DB_PREFIX.'checklist',
		DB_PREFIX.'core'
		)))
		{
			while($row = $result->fetch_object()) {
				//Get the checklist logo name and add it to the certification level that the client has achieved.
				$input['s'] = $row->certification_logo . "_" . str_replace(' ', '', strtolower($row->certification_level));
				
				//We need to check and see if it it a micro certification
				if($row->checklist_variation_id == 2) {
					$input['s'] = GENERATOR."_green_efficiency_standard";	
				}
				
				//If the user has not scored high enough for a gold/silver/bronze - set to generic certification in progress stamp
				if(is_null($row->certification_level)) {
					$input['s'] = GENERATOR."_inprogress";	
				}
				
				if(($row->checklist_variation_id == 2) && (is_null($row->certification_level))) {
					$input['s'] = GENERATOR."_assessment_inprogress";	
				}
				
				$audit_required = $row->audit_required;
			}
		}
		
		//Check to see if the checklist requires audit and if so has it been audited and certified
		if($audit_required == 1) {

			if($result = $this->db->query(sprintf('
				SELECT
					`audited`,
					`certified`
				FROM `%1$s`.`audit`
				WHERE `status` != 3
				AND `client_checklist_id` = %2$d;
			',
			DB_PREFIX.'audit',
			$cclid
			)))
			{
				while($row = $result->fetch_object()) {
			 		//If the client has not been audited and verified only provide the inprogress stamp
					if($row->audited != 1 || $row->certified != 1)
					{
						$input['s'] = GENERATOR."_inprogress";
					}
				}

				//Check for the empty result
				if(is_null($result)) {
					$input['s'] = GENERATOR."_inprogress";
				}
			}
		}	
		
		return $input;
	}
	
	//Checks the URL variables to make sure that they are valid - We must pass the stamp generator atleast two variables being a combination of (cclid or s) and (w or h)
	private function check_input($error=false) {
		$input = $_GET;
		
		//The following line checks to see if the variable clid has been set
		//This only fires when the cclid url variable is passed
		if(isset($_GET['cclid'])) {
			$input = $this->getCertificationLevel($input);
		}
		
		//Check that the stamp variable has been set
		if(!isset($input['s'])) {
			$this->writeError('"s" is required');
			return(false);
		} elseif(($source = PATH_STAMP . '/'.$input['s'].'.png') && !is_file($source)) {
			
			//The called file doesn't exist, try and get a default, if not report the error
			if(!is_file(PATH_STAMP . '/'.GENERATOR.'.png')) {
				$this->writeError('"s" is invalid or does not exist');
				return(false);
			} else {
				$source = PATH_STAMP . '/'.GENERATOR.'.png';
			}
		}
		
		//Check that the width variable has been set
		if(!isset($input['w']) && !isset($input['h'])) {
			$this->writeError('"w" or "h" is required');
			return(false);
		}
		
		//Check that the width variable has been set
		if(isset($input['w'])) {
			if(!is_numeric($input['w'])) {
				$this->writeError('"w" must be a number');
				return(false);
			} elseif($input['w'] < 1 || $input['w'] > 5000) {
				$this->writeError('"w" must be between 1 and 5000');
				return(false);
			}
		}
		
		//check that the height variable has been set
		if(isset($input['h'])) {
			if(!is_numeric($input['h'])) {
				$this->writeError('"h" must be a number');
				return(false);
			} elseif($input['h'] < 1 || $input['h'] > 5000) {
				$this->writeError('"h" must be between 1 and 5000');
				return(false);
			}
		}
		
		//return the image page and other details
		$return = new stdClass();
		$return->image_path = $input['s'];
		$return->source = $source;
		$return->max_width	= isset($input['w']) ? $input['w'] : $input['h'];
		$return->max_height	= isset($input['h']) ? $input['h'] : $input['w'];
		return($return);
	}
	
	//If there are any errors with the user input or in generating the stamp write the errors to the image and send to the web browser
	private function writeError($error) {
		$this->im	= imagecreatetruecolor(320,320);
		$background	= imagecolorallocate($this->im,255,255,255);
		$textcolor	= imagecolorallocate($this->im,255,0,0);
		imagefilledrectangle($this->im,0,0,320,320,$background);
		imagestring($this->im,5,0,150,$error,$textcolor);
		return;
	}
	
	//Take the stamp file, width and height and generate the stamp
	private function setImage($source,$max_w,$max_h) {
		$source_im = imagecreatefrompng($source);
		list($img_w,$img_h) = getimagesize($source);
		$f = min($max_w / $img_w, $max_h / $img_h, 1);
		$this->width	= round($f * $img_w);
		$this->height	= round($f * $img_h);
		$this->im = imagecreatetruecolor($this->width,$this->height);
		
		imagealphablending($this->im,false);
		imagefill($this->im,0,0,imagecolorallocatealpha($this->im,0,0,0,127));
		imagesavealpha($this->im,true);
		imagecopyresampled($this->im,$source_im,0,0,0,0,$this->width,$this->height,$img_w,$img_h);
		imagedestroy($source_im);
		imagepng($this->im, $this->cache_filename);	
		imagedestroy($this->im);
		return;
	}
}

//Get a stamp class object and call the render function
$stamp = new stamp();
$stamp->render();
?>