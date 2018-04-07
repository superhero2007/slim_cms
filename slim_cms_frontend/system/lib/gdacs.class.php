<?php
/*
//Class to interface with GDACS
//Glonal Disaster Alert and Coordination System
//http://www.gdacs.org
*/

class gdacs {
	private $db;
	private $gdacsFeedUrl = "http://www.gdacs.org/xml/rss.xml";
	
	public function __construct($db) {
		$this->db = $db;

		return;
	}

	//Replace the feed events into the database
	public function updateGdacsFeed($database_prefix = null) {
		$gdacsData = $this->getGdacsFeed();

		foreach($gdacsData->channel->item as $item) {
			$namespaces = $item->getNamespaces(true);
			$gdacs = $item->children($namespaces['gdacs']);
			$geo = $item->children($namespaces['geo']);

			$this->db->query(sprintf('
				REPLACE INTO `%1$s`.`gdacs` SET
					`eventid` = %2$d,
					`title` = "%3$s",
					`description` = "%4$s",
					`link` = "%5$s",
					`guid` = "%6$s",
					`pubDate` = "%7$s",
					`lat` = "%8$s",
					`lng` = "%9$s",
					`eventtype` = "%10$s",
					`eventname` = "%11$s",
					`alertlevel` = "%12$s",
					`severity` = "%13$s",
					`population` = "%14$s";
			',
				(!is_null($database_prefix) ? $database_prefix : DB_PREFIX).'resources',
				$this->db->escape_string($gdacs->eventid),
				$this->db->escape_string($item->title),
				$this->db->escape_string($item->description),
				$this->db->escape_string($item->link),
				$this->db->escape_string($item->guid),
				$this->db->escape_string($item->pubDate),
				$this->db->escape_string($geo->Point->lat),
				$this->db->escape_string($geo->Point->long),
				$this->db->escape_string($gdacs->eventtype),
				$this->db->escape_string($gdacs->eventname),
				$this->db->escape_string($gdacs->alertlevel),
				$this->db->escape_string($gdacs->severity),
				$this->db->escape_string($gdacs->population)
			));
		}

		//Archive any Gdacs events that have not been updated in 7 days
		$this->db->query(sprintf('
			UPDATE 
			`%1$s`.`gdacs`
			SET `archive` = %2$d
			WHERE `timestamp` < now() - interval 7 day;
		',
			(!is_null($database_prefix) ? $database_prefix : DB_PREFIX).'resources',
			$this->db->escape_string('1')
		));

		return;
	}


	public function getGdacsEvents($additionalWhere = '') {
		$events = array();

		//Get all Clients if no client_id is set, otherwise, just get the client that is set
		if($result = $this->db->query(sprintf('
			SELECT *
			FROM `%1$s`.`gdacs`
			WHERE 1
			AND `archive` = 0
			' . $additionalWhere . '
			ORDER BY `timestamp`
		',
			DB_PREFIX.'resources'
		))) {
			while($row = $result->fetch_object()) {
			
				$events[] = $row;
			}
			$result->close();
		}

		return $events;
	}


	//Gets the feed data from the GDACS URL
	private function getGdacsFeed() {
		$xml = simplexml_load_file($this->gdacsFeedUrl);
		return $xml;
	}

	public function getGDACS() {

		$featureCollection = new stdClass;
		$featureCollection->type = "FeatureCollection";

		$features = array();

		//Get any Gdacs events to display
		$events = $this->getGdacsEvents();
		foreach ($events as $key => $event) {

			//Create the Feature Object
			$feature = new stdClass;
			$feature->type = "Feature";

			//Crete the Geometry Object;
			$geometry = new stdClass;
			$geometry->type = "Point";
			$geometry->coordinates = array($event->lng, $event->lat);
			$feature->geometry = $geometry;

			//Create the Properties Object
			$properties = $event;
			$properties->link = $event->link;
			$properties->markertype = "gdacs";

			switch($event->eventtype) {
				case 'EQ': $properties->name = 'EARTHQUAKE ';
				break;

				case 'TC': $properties->name = "CYCLONE " . $event->eventname;
				break;

				default: $properties->name = $event->eventname;
				break;
			}
			
			$properties->style = new stdClass;
			$properties->style->radius = "25";
			$properties->style->fillOpacity = "0.35";
			$properties->style->weight = "2";
			$properties->style->stroke = "true";
			$properties->style->color = strtolower($event->alertlevel);
			$properties->style->fillColor = strtolower($event->alertlevel);

			$feature->properties = $properties;
			$feature->id = $event->eventid;
			$features[] = $feature;
		}

		$featureCollection->features = $features;
		return $featureCollection;
	}

}

?>