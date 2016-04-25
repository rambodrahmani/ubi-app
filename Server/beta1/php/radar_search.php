<?php
	date_default_timezone_set('UTC');
	
	require_once("config.php");
	require_once("php-googleplaces-master/src/GooglePlaces.php");
	require_once("php-googleplaces-master/src/GooglePlacesClient.php");
	
	$location = null;
	$place_types = null;
	
	$location = $conn->real_escape_string($_POST['location']);
	$place_types = $conn->real_escape_string($_POST['place_types']);
	
	$google_places = new joshtronic\GooglePlaces(SERVER_KEY);
	$google_places->location = $location;
	$google_places->radius = "400";
	
	$type_google_place = array("accounting", "airport", "amusement_park", "aquarium", "art_gallery", "atm", "bakery", "bank", "bar", "beauty_salon", "bicycle_store", "book_store", "bowling_alley", "bus_station", "cafe", "campground", "car_dealer", "car_rental", "car_repair", "car_wash", "casino", "cemetery", "church", "city_hall", "clothing_store", "convenience_store", "courthouse", "dentist", "department_store", "doctor", "electrician", "electronics_store", "embassy", "establishment", "finance", "fire_station", "florist", "food", "funeral_home", "furniture_store", "gas_station", "general_contractor", "grocery_or_supermarket", "gym", "hair_care", "hardware_store", "health", "hindu_temple", "home_goods_store", "hospital", "insurance_agency", "jewelry_store", "laundry", "lawyer", "library", "liquor_store", "local_government_office", "locksmith", "lodging", "meal_delivery", "meal_takeaway", "mosque", "movie_rental", "movie_theater", "moving_company", "museum", "night_club", "painter", "park", "parking", "pet_store", "pharmacy", "physiotherapist", "place_of_worship", "plumber", "police", "post_office", "real_estate_agency", "restaurant", "roofing_contractor", "rv_park", "school", "shoe_store", "shopping_mall", "spa", "stadium", "storage", "store", "subway_station", "synagogue", "taxi_stand", "train_station", "travel_agency", "university", "veterinary_care", "zoo");
	
	if (strlen($place_types) > 0)
	{
		$google_places->types = $place_types;
	}
	else {
		$google_places->types = str_replace(",", "|", str_replace(array('[', '"', ']'),"", json_encode($type_google_place)));
	}
	
	$google_places->language = "it";
	$radar_search_results = $google_places->radarSearch();
	
	$radar_search_results_array = $radar_search_results['results'];
	
	while($radar_search_results['status'] != "OK")
	{
		if ( ($radar_search_results['status'] == "ERROR") || ($radar_search_results['status'] == "INVALID_REQUEST") || ($radar_search_results['status'] == "NOT_FOUND") || ($radar_search_results['status'] == "REQUEST_DENIED") || ($radar_search_results['status'] == "UNKNOWN_ERROR") || ($radar_search_results['status'] == "ZERO_RESULTS") )
		{
			echo $radar_search_results['status'];
			break;
		}
		if ($radar_search_results['status'] == "OVER_QUERY_LIMIT")
		{
			usleep(rand(100, 1000));
			
			$radar_search_results = $google_places->radarSearch();
		}
	}
	
	$radar_search_place_ids = array();
	
	global $VM_servers;
	$server_balancer = 0;
	
	foreach($radar_search_results_array as $result)
	{	
		$place_google_id = $result['place_id'];
		
		$radar_search_place_ids[] = $place_google_id;
	}
	
	$place_ids_container = array();
	$place_ids_container_to_string = "";
	foreach($radar_search_place_ids as $place_id)
	{
		$sql = "SELECT	*
				FROM	places
				WHERE	place_google_id = '$place_id';";
				
		$result = $conn->query($sql);
		
		if ($result->num_rows == 0) {
			$place_ids_container[] = $place_id;
			
			if ( (count($place_ids_container) >= count($radar_search_place_ids)/count($VM_servers) ) || 
				( $place_id == $radar_search_place_ids[count($radar_search_place_ids) - 1] ) )
			{
				$place_ids_container_to_string = implode(", ", $place_ids_container);
				
				$url = 'http://' . $VM_servers[$server_balancer] . '/php/post_new_place.php';
				if ($server_balancer == (count($VM_servers) - 1)) {
					$server_balancer = 0;
				}
				else {
					$server_balancer++;
				}
				
				$data = array(
								'places_google_id' => $place_ids_container_to_string,
								'date_utc_offset' => '0'
							  );
				
				foreach ($data as $key => &$val) {
					if (is_array($val)) $val = implode(',', $val);
					$post_params[] = $key. '='.urlencode($val);
				}
				$post_string = implode('&', $post_params);
			
				$parts = parse_url($url);
			
				$fp = fsockopen($parts['host'], 
					isset($parts['port'])?$parts['port']:80, 
					$errno, $errstr, 30);
					
				$out = "POST ".$parts['path']." HTTP/1.1\r\n";
				$out.= "Host: ".$parts['host']."\r\n";
				$out.= "Content-Type: application/x-www-form-urlencoded\r\n";
				$out.= "Content-Length: ".strlen($post_string)."\r\n";
				$out.= "Connection: Close\r\n\r\n";
				if (isset($post_string)) $out.= $post_string;
			
				fwrite($fp, $out);
				fclose($fp);
				
				unset($place_ids_container);
				$place_ids_container = array();
				unset($place_ids_container_to_string);
				$place_ids_container_to_string = "";
			}
		}
	}
	
	sleep(2);
	
	$results = array();
	while (count($results) < count($radar_search_place_ids))
	{
		foreach($radar_search_place_ids as $place_google_id)
		{
			$sql = "SELECT	*
					FROM	places
					WHERE	place_google_id = '$place_google_id';";
			$result = $conn->query($sql);
			
			if ($result->num_rows > 0) {
				while($row = $result->fetch_assoc()) {
					array_push($results, $row);
				}
			}
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
