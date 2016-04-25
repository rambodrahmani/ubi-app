<?php	
	require_once("config.php");
	
	$place_google_id = null;
	$event_author_id = null;
	$event_name = null;
	$event_picture_url = null;
	$event_description = null;
	$event_start_date = null;
	$event_end_date = null;
	$event_date_utc_offset = null;
	
	$place_google_id = $conn->real_escape_string($_POST['place_google_id']);
	
	$event_author_id = $conn->real_escape_string($_POST['event_author_id']);
	$event_name = $conn->real_escape_string($_POST['event_name']);
	$event_picture_url = $conn->real_escape_string($_POST['event_picture_url']);
	$event_description = $conn->real_escape_string($_POST['event_description']);
	$event_start_date = $conn->real_escape_string($_POST['event_start_date']);
	$event_end_date = $conn->real_escape_string($_POST['event_end_date']);
	$event_date_utc_offset = $conn->real_escape_string($_POST['event_date_utc_offset']);
	
	if ($place_google_id == "NO_LOC") {
		$event_place_id = 0;
	} else {
		$sql = "SELECT	*
				FROM	places
				WHERE	place_google_id = '$place_google_id';";
				
		$result = $conn->query($sql);
		
		if ($result->num_rows > 0) {
			$row = $result->fetch_assoc();
			$event_place_id = $row['place_id'];
		}
		else {
				$url = BASE_URL . '/php/post_new_place.php';
				$data = array(	'places_google_id' => $place_google_id . ", ",
								'date_utc_offset' => $event_date_utc_offset);
				$options = array(
					'http' => array(
						'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
						'method'  => 'POST',
						'content' => http_build_query($data),
					),
				);
				$context  = stream_context_create($options);
				$response= file_get_contents($url, false, $context);
				$json = json_decode($response, true);
				$event_place_id = $json[0]["place_id"];
		}
	}
	
	$sql = "INSERT INTO	events(event_author_id, event_name, event_picture_url, event_description, event_place_id, event_start_date, event_end_date)
					VALUES('$event_author_id', '$event_name', '$event_picture_url', '$event_description', '$event_place_id', '$event_start_date', '$event_end_date')";
			
	$rs = $conn->query($sql);
	
	if ($rs === TRUE) {
		$event_id = $conn->insert_id;
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
	
	if ($event_picture_url == "NO_MEDIA") {
		echo "SUCCESS";
	}
	else {
		$uploaddir = '../uploads/events/' . $event_author_id . '/';
		if (!file_exists($uploaddir)) {
			mkdir($uploaddir, 0777, true);
		}
	
		$file = basename($_FILES['uploadedfile']['name']);
		$uploadfile = $uploaddir . $file;
	
		if (move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $uploadfile)) {
			echo "SUCCESS";
		}
		else {
			echo "ERROR";
		}
	}
?>
