<?php

class mapping {
	private $db;
	private $googleGeocode = "https://maps.googleapis.com/maps/api/geocode/json?key=" . GOOGLE_MAPS_API_KEY;

	function __construct($db) {
		$this->db = $db;
	}

	public function getCoordinates($address) {
		return $this->googleAPIQuery($this->googleGeocode . "&address=" . str_replace(' ','+', preg_replace("/ {2,}/", " ", ltrim($address,' +'))));
	}

	public function getAddress($lat, $lng) {	
		return $this->googleAPIQuery($this->googleGeocode . "&latlng=" . $lat . "," . $lng);
	}

	private function googleAPIQuery($url) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_PROXYPORT, 3128);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
		$response = json_decode(curl_exec($ch));
		curl_close($ch);

		return $response;
	}

}

?>