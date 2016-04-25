<?php	
	require_once("config.php");
	require_once("php-googleplaces-master/src/GooglePlaces.php");
	require_once("php-googleplaces-master/src/GooglePlacesClient.php");
	
	$reviews_counter = 0;
	
	$places_google_id = null;
	$date_utc_offset = null;
	
	$places_google_id = $conn->real_escape_string($_POST['places_google_id']);
	$date_utc_offset = $conn->real_escape_string($_POST['date_utc_offset']);
	
	$places_google_id_array = explode(", ", $places_google_id);
	
	$google_places = new joshtronic\GooglePlaces(SERVER_KEY);
	
	$places_details = array();
	
	foreach($places_google_id_array as $place_google_id)
	{
		if (strlen($place_google_id) > 3)
		{
			$google_places->place_id = $place_google_id;
			$google_places->language = "it";
			$details = $google_places->details();
						
			$sql = "SELECT	*
					FROM	places
					WHERE	place_google_id = '$place_google_id';";
			$result = $conn->query($sql);
			
			if ($result->num_rows > 0) {
				$row = $result->fetch_assoc();
				$place_id = $row['place_id'];
			} 
			else
			{
				while($details['status'] != "OK")
				{
					if ( ($details['status'] == "ERROR") || ($details['status'] == "INVALID_REQUEST") || ($details['status'] == "NOT_FOUND") || ($details['status'] == "REQUEST_DENIED") || ($details['status'] == "UNKNOWN_ERROR") || ($details['status'] == "ZERO_RESULTS") )
					{
						echo $details['status'];
						break;
					}
					if ($details['status'] == "OVER_QUERY_LIMIT")
					{
						usleep(rand(100, 1000));
						
						$details = $google_places->details();
					}
				}
				
				if ($details['status'] == "OK")
				{
					$place_name = $conn->real_escape_string($details["result"]["name"]);
					$place_lat = $details["result"]["geometry"]["location"]["lat"];
					$place_lon = $details["result"]["geometry"]["location"]["lng"];
					$place_icon_url = $conn->real_escape_string($details["result"]["icon"]);
					$place_string = $conn->real_escape_string($details["result"]["formatted_address"]);
					$place_google_id = $details["result"]["place_id"];
					$place_rating = $details["result"]["rating"];
					$place_types = $conn->real_escape_string(implode(", ", $details["result"]["types"]));
					$place_website_url = $conn->real_escape_string($details["result"]["website"]);
					$place_phone_number = $details["result"]["formatted_phone_number"];
					$place_int_phone_number = $details["result"]["international_phone_number"];
					$place_utc_offset = $details["result"]["utc_offset"];
					$place_google_url = $conn->real_escape_string($details["result"]["url"]);
					$place_cover_pic_url = "";
				
					$sql = "INSERT INTO	places(place_name, place_lat, place_lon, place_icon_url, place_string, place_google_id, place_rating, place_types, place_website_url, place_phone_number, place_int_phone_number, place_utc_offset, place_google_url, place_cover_pic_url)
							VALUES('$place_name', '$place_lat', '$place_lon', '$place_icon_url', '$place_string', '$place_google_id', '$place_rating', '$place_types', '$place_website_url', '$place_phone_number', '$place_int_phone_number', '$place_utc_offset', '$place_google_url', '$place_cover_pic_url');";
				
					if ($conn->query($sql) === TRUE)
					{
						$place_id = $conn->insert_id;
						$data = array(
										"place_id" => $place_id,
										"place_details" => $details
									  );
						$places_details[] = $data;
					} 
					else {
						echo "ERROR: " . $sql . "<br>" . $conn->error;
					}
				}
			}
		}
	}
	
	foreach($places_details as $place_details)
	{
		$place_id = $place_details["place_id"];
		$place_reviews = $place_details["place_details"]["result"]["reviews"];
		
		foreach($place_reviews as $place_review)
		{	
			$review_rating = $place_review["rating"];
	
			$review_text = $place_review["text"];
		
			$review_date = $place_review["time"];
			$review_date = date("Y-m-d H:i:s", $review_date);
		
			$user_profile_url = $place_review["author_url"];
			
			if (strlen($user_profile_url) > 0)
			{
				$user_full_name = $place_review["author_name"];
				$user_full_name_array = explode(" ", $user_full_name);
				$user_name = $user_full_name_array[0];
				$user_surname = $user_full_name_array[1];
		
				$user_profile_url_array = explode("/", $user_profile_url);
				$user_g_id = $user_profile_url_array[count($user_profile_url_array) - 1];
		
				$user_email = $user_g_id;
		
				$request_url = "https://www.googleapis.com/plus/v1/people/" . $user_g_id ."?key=" . SERVER_KEY;
				$response = file_get_contents($request_url);
				
				$wait_time = 0;
				$wait_counter = 1;
				while($response === FALSE)
				{
					$wait_time += $wait_counter * rand(100, 500);
					$wait_counter++;
					usleep($wait_time);
					
					$response = file_get_contents($request_url);
				}
				
				$json = json_decode($response, TRUE);
				
				$user_bio = $json['aboutMe'];
				$user_profile_pic = $json['image']['url'];
				$user_profile_pic = str_replace("?sz=50", "", $user_profile_pic);
				$user_gender = $json['gender'];
				if ($user_gender == "male") {
					$user_gender = "M";
				}
				else {
					$user_gender = "F";
				}
			}
			else {
				$user_email = "unknown.google.reviewer";
				$user_name = "Un utente";
				$user_surname = "Google";
				$user_profile_pic = BASE_URL . '/uploads/unknown_google_user.png';
				$user_profile_url = "unknown.google.reviewer";
				$user_bio = "";
				$user_gender = "";
			}
			
			$user_bio = str_replace("\n", "", $user_bio);
		
			$url = BASE_URL . '/php/register_user.php';
			$data = array(	'email' => $user_email,
							'name' => $user_name,
							'surname' => $user_surname,
							'profile_pic' => $user_profile_pic,
							'profile_url' => $user_profile_url,
							'last_status_text' => '',
							'bio' => $user_bio,
							'birthday' => '',
							'gender' => $user_gender,
							'chat_id' => '0',
							'status_date_utc_offset' => $date_utc_offset);
			$options = array(
				'http' => array(
					'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
					'method'  => 'POST',
					'content' => http_build_query($data),
				),
			);
			$context  = stream_context_create($options);
			$user_id = file_get_contents($url, false, $context);
			
			if ($user_id > 0)
			{
				$url = BASE_URL . '/php/post_place_review.php';
				$data = array(	'place_id' => $place_id,
								'user_id' => $user_id,
								'review_text' => $review_text,
								'review_rating' => $review_rating,
								'review_date' => $review_date,
								'place_review_date_utc_offset' => $date_utc_offset
							  );
				$options = array(
					'http' => array(
						'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
						'method'  => 'POST',
						'content' => http_build_query($data),
					),
				);
				$context  = stream_context_create($options);
				$post_place_review_response = file_get_contents($url, false, $context);
			}
		}
	}
	
	foreach($places_details as $place_details)
	{
		$place_id = $place_details["place_id"];
		$place_photos_array = $place_details["place_details"]["result"]["photos"];
		
		$counter = 1;
		foreach($place_photos_array as $place_photo)
		{
			$photo_reference = $place_photo["photo_reference"];
			
			$request_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photoreference=" . $photo_reference . "&key=" . SERVER_KEY;
			$imageContent = file_get_contents($request_url);
			
			$wait_time = 0;
			$wait_counter = 1;
			while($imageContent === FALSE)
			{
				$wait_time += $wait_counter * rand(100, 500);
				$wait_counter++;
				usleep($wait_time);
				
				$imageContent = file_get_contents($request_url);
			}
			
			$saved_time = time();
			$pic_url = BASE_URL . "/uploads/places/" . $place_id . "/" . ($saved_time + $counter) . ".jpg";
			$sql = "INSERT INTO	place_photos(place_id, photo_url)
					VALUES('$place_id', '$pic_url');";
		
			while ($conn->query($sql) === FALSE) {
				$saved_time = time();
				$pic_url = BASE_URL . "/uploads/places/" . $place_id . "/" . ($saved_time + $counter) . ".jpg";
				$sql = "INSERT INTO	place_photos(place_id, photo_url)
						VALUES('$place_id', '$pic_url');";
			}
			
			if ($counter == 1)
			{
				$sql = "UPDATE	places
						SET		place_cover_pic_url = '$pic_url'
						WHERE	place_id = '$place_id';";
				$result = $conn->query($sql);
			}
			
			$upload_dir = "../uploads/places/" . $place_id . "/";
			$file_name = $upload_dir . ($saved_time + $counter) . ".jpg";
			if (!file_exists($upload_dir)) {
				mkdir($upload_dir, 0777, true);
			}
			file_put_contents($file_name, $imageContent);
			
			$counter += 1;
		}
	}
	
	$results = array();
	
	$sql = "SELECT	*
			FROM	places
			WHERE	place_id = '$place_id';";
	$result = $conn->query($sql);
	
	if ($result->num_rows > 0) {
		while($row = $result->fetch_assoc()) {
			array_push($results, $row);
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
