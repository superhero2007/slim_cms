<?php
/*
File: index.php
This is the file which when called with the correct variables will return a GreenBizCheck stamp in the right size and colour
This stamp generator is used on certificates and reports aswell as throughout the site
*/

//Get access to the JPGraph Library
require_once('../../config.php');

//require_once('jpgraph/jpgraph.php');
JpGraph\JpGraph::load();

//Bar Graph Data
//require_once('jpgraph/jpgraph_bar.php');
JpGraph\JpGraph::module('bar');

//Pie Graph Data
//require_once('jpgraph/jpgraph_pie.php');
//require_once('jpgraph/jpgraph_pie3d.php');
JpGraph\JpGraph::module('pie');
JpGraph\JpGraph::module('pie3d');

//Radar Graph
//require_once('jpgraph/jpgraph_radar.php');
JpGraph\JpGraph::module('radar');

//GBC Database
$db;

class gbcGraph {

	private $im;
	private $image;
	
	function constructGraph() {
		switch($_REQUEST["g"]) {
			case 'barGraph':
				$this->barGraph();
				break;
				
			case 'pie3dGraph':
				$this->pie3dGraph();
				break;
				
			case 'pieGraph':
				$this->pieGraph();
				break;
				
			case 'radarGraph':
				$this->radarGraph();
				break;
		}
	}
	
	//Construct the bar graph
	function barGraph() {
		
		$url_xdata = $_REQUEST['xdata'];

		foreach($url_xdata as $data) {
			$xdata[] = str_replace("-"," ", $data);
		}
		
		$url_ydata = $_REQUEST['ydata'];
		
		foreach($url_ydata as $data) {
			$ydata[] = $data;
		}
		
		$graph = new Graph($_REQUEST['w'],$_REQUEST['h']);
		$graph->SetScale('textlin');
		$graph->SetMargin(150,150,30,170);
		if(isset($_REQUEST['graphTitle'])) {
			$graph->title->Set(str_replace("-"," ", $_REQUEST['graphTitle']));
		}
		$graph->title->SetFont(FF_ARIAL,FS_NORMAL,16);
		$graph->xaxis->SetFont(FF_ARIAL,FS_NORMAL,16);
		$graph->yaxis->SetFont(FF_ARIAL,FS_NORMAL,16);
		$graph->xaxis->SetLabelAngle(45);
		
		$graph->xaxis->SetTickLabels($xdata);
		$barPlot = new BarPlot($ydata);
		$barPlot->SetShadow();
		$barPlot->SetWidth(0.6);
		$graph->Add($barPlot);
			
		// Send file using mod_xsendfile Apache header.
		header("X-Sendfile: ".$graph->Stroke());
		header("Content-Type: image/png");
		die();
	}
	
	//Construct the pie graph in 3d
	function pie3dGraph() {
		
		$data = $_REQUEST['data'];
		//Strip the dashes from the data
		
		for($i=0;$i<count($data);$i++) {
			$data[$i] = str_replace("-"," ",$data[$i]);
		}
		
		$labels = $_REQUEST['labels'];
		//Strip the dashes from the data
		
		for($i=0;$i<count($labels);$i++) {
			$labels[$i] = str_replace("-"," ",$labels[$i]) . " (%.1f%%)";
		}
		
		$legend = $_REQUEST['legend'];
		//Strip the dashes from the data
		
		for($i=0;$i<count($legend);$i++) {
			$legend[$i] = str_replace("-"," ",$legend[$i]);
		}
		
		//$ydata = $_REQUEST['ydata'];
		
		$graph = new PieGraph($_REQUEST['w'],$_REQUEST['h']);

		$theme_class= new VividTheme;
		$graph->SetTheme($theme_class);

		if(isset($_REQUEST['graphTitle'])) {
			$graph->title->Set(str_replace("-"," ", $_REQUEST['graphTitle']));
		}
		$graph->title->SetFont(FF_ARIAL,FS_NORMAL,16);
		$graph->title->SetColor('black');
		
		// Create
		$p1 = new PiePlot3D($data);
		$p1->SetLabels($labels);
		$p1->SetLegends($legend);
		$p1->ShowBorder();
		$p1->value->SetFont(FF_ARIAL,FS_NORMAL,12);
		$p1->value->SetColor('black');
		$p1->SetLabelType(PIE_VALUE_PER);
		$p1->setLabelPos(1);
		$p1->value->Show();
		$p1->setCenter(0.5,0.40);
		$p1->SetAngle(50);
		$graph->Add($p1);
			
		// Send file using mod_xsendfile Apache header.
		header("X-Sendfile: ".$graph->Stroke());
		header("Content-Type: image/png");
		die();
	}
	
	//Regular Pie Graph
	function pieGraph() {
		
		$data = $_REQUEST['data'];
		//Strip the dashes from the data
		
		for($i=0;$i<count($data);$i++) {
			$data[$i] = str_replace("-"," ",$data[$i]);
		}
		
		$labels = $_REQUEST['labels'];
		//Strip the dashes from the data
		
		for($i=0;$i<count($labels);$i++) {
			$labels[$i] = str_replace("-"," ",$labels[$i]) . " (%.1f%%)";
		}
		
		$legend = $_REQUEST['legend'];
		//Strip the dashes from the data
		
		for($i=0;$i<count($legend);$i++) {
			$legend[$i] = str_replace("-"," ",$legend[$i]);
		}
		
		//$ydata = $_REQUEST['ydata'];
		
		$graph = new PieGraph($_REQUEST['w'],$_REQUEST['h']);

		$theme_class= new VividTheme;
		$graph->SetTheme($theme_class);

		if(isset($_REQUEST['graphTitle'])) {
			$graph->title->Set(str_replace("-"," ", $_REQUEST['graphTitle']));
		}
		$graph->title->SetFont(FF_ARIAL,FS_NORMAL,16);
		$graph->title->SetColor('black');
		
		// Create
		$p1 = new PiePlot($data);
		$p1->setCenter(0.5,0.60);
		$p1->SetSize(0.3);
		$p1->SetLabels($labels);
		$p1->SetLegends($legend);
		$p1->ShowBorder();
		$p1->value->SetFont(FF_ARIAL,FS_NORMAL,12);
		$p1->value->SetColor('black');
		$p1->SetLabelType(PIE_VALUE_PER);
		$p1->setLabelPos(1);
		$p1->value->Show();
		$p1->SetGuideLines(true, false);
		//$p1->SetGuideLinesAdjust(0.5);
		$graph->Add($p1);
			
		// Send file using mod_xsendfile Apache header.
		header("X-Sendfile: ".$graph->Stroke());
		header("Content-Type: image/png");
		die();
	}
	
	//Radar Graph
	function radarGraph() {
		
		//Values for the graph
		$ydatas = $_REQUEST['ydata'];
		//Strip the dashes from the data
		
		//for($i=0;$i<count($data);$i++) {
		foreach($ydatas as $ydata) {
			$ydata = str_replace("-"," ",$ydata);
			$data[] = $ydata;
		}
		
		
		//Titles
		//$labels = $_REQUEST['xdata'];
		$xdatas = $_REQUEST['xdata'];
		//Strip the dashes from the data
		
		//for($i=0;$i<count($labels);$i++) {
		foreach($xdatas as $xdata) {
			$xdata = " \n" . str_replace("-","\n",$xdata) . "\n ";
			$labels[] = $xdata;
		}
		
		//Set the Graph Type
		$graph = new RadarGraph($_REQUEST['w'],$_REQUEST['h']);
		
		$graph->SetScale('lin',0,100);
		$graph->yscale->ticks->Set(25,5);
		$graph->SetCenter(0.5,0.5);
		$graph->axis->SetFont(FF_ARIAL,FS_BOLD,8);
		$graph->axis->SetWeight(1);
		$graph->axis->SetColor('gray');
		$graph->grid->SetLineStyle('solid');
		$graph->grid->SetColor('gray');
		$graph->grid->Show();
		$graph->HideTickMarks(true);
		$graph->SetFrame(false);
		$graph->SetMargin(5,5,5,5);

		//Labels
		$graph->SetTitles($labels);
		$graph->axis->title->SetColor(array(113,113,113));
		$graph->axis->title->SetFont(FF_ARIAL,FS_BOLD,11);
		$graph->axis->title->SetParagraphAlign("center");
		
		//Create the radar plot
		$p1 = new RadarPlot($data);
		$p1->SetColor(array(223,223,223));
		$p1->SetFillColor(array(52,152,219));
		$p1->SetLineWeight(0);
		
		//Add the plot to the graph file
		$graph->Add($p1);
			
		// Send file using mod_xsendfile Apache header.
		header("X-Sendfile: ".$graph->Stroke());
		header("Content-Type: image/png");
		die();
	}
	
	//Push the newly created image to the users web browser
	public function render() {
		if($input = $this->check_input()) {
			$this->constructGraph($input);
		}
		else {
			// An error occurred, display it as an image.
			header("Content-type: image/png");
			imagepng($this->im);
			imagedestroy($this->im);
			return;
		}
	}
	
	//Checks the URL variables to make sure that they are valid - We must pass the stamp generator atleast two variables being a combination of (cclid or s) and (w or h)
	private function check_input($error=false) {
		$input = $_GET;
		
		//Check that the stamp variable has been set
		if(!isset($input['g'])) {
			$this->writeError('"g" is required');
			return(false);
		}
		
		//Check that the width variable has been set
		if(isset($input['w'])) {
			if(!is_numeric($input['w'])) {
				$this->writeError('"w" must be a number');
				return(false);
			} elseif($input['w'] < 1 || $input['w'] > 150000) {
				$this->writeError('"w" must be between 1 and 150000');
				return(false);
			}
		}
		else {
			$this->writeError('"w" is required');
		}
		
		//check that the height variable has been set
		if(isset($input['h'])) {
			if(!is_numeric($input['h'])) {
				$this->writeError('"h" must be a number');
				return(false);
			} elseif($input['h'] < 1 || $input['h'] > 150000) {
				$this->writeError('"h" must be between 1 and 150000');
				return(false);
			}
		}
		else {
			$this->writeError('"h" is required');
		}
		
		//return the image page and other details
		$result = new StdClass;
		$result->max_width	= isset($input['w']) ? $input['w'] : $input['h'];
		$result->max_height	= isset($input['h']) ? $input['h'] : $input['w'];
		return($result);
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
}

//Get a stamp class object and call the render function
$gbcGraph = new gbcGraph();
$gbcGraph->render();

?>