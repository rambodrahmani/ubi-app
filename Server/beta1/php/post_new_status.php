<?php	
	require_once("config.php");
	
	$place_google_id = null;
	$status_author_id = null;
	$status_content_text = null;
	$status_content_media = null;
	$status_date_utc_offset = null;
	$tagged_people = null;
	
	$place_google_id = $conn->real_escape_string($_POST['place_google_id']);
	
	$status_author_id = $conn->real_escape_string($_POST['status_author_id']);
	$status_content_text = $conn->real_escape_string($_POST['status_content_text']);
	$status_content_media = $conn->real_escape_string($_POST['status_content_media']);
	
	$status_date_utc_offset = $conn->real_escape_string($_POST['status_date_utc_offset']);
	
	$tagged_people = $conn->real_escape_string($_POST['tagged_people']);
	
	if ($place_google_id == "NO_LOC") {
		$status_place_id = 0;
	} else {
		$sql = "SELECT	*
				FROM	places
				WHERE	place_google_id = '$place_google_id';";
				
		$result = $conn->query($sql);
		
		if ($result->num_rows > 0) {
			$row = $result->fetch_assoc();
			$status_place_id = $row['place_id'];
		}
		else {
				$url = BASE_URL . '/php/post_new_place.php';
				$data = array(	'places_google_id' => $place_google_id . ", ",
								'date_utc_offset' => $status_date_utc_offset);
				$options = array(
					'http' => array(
						'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
						'method'  => 'POST',
						'content' => http_build_query($data),
					),
				);
				$context  = stream_context_create($options);
				$response = file_get_contents($url, false, $context);
				$json = json_decode($response, true);
				$status_place_id = $json[0]["place_id"];
		}
	}
	
	$sql = "INSERT INTO	statuses(status_author_id, status_place_id, status_date, status_content_text, status_content_media)
			VALUES('$status_author_id', '$status_place_id', ADDDATE(UTC_TIMESTAMP(), INTERVAL $status_date_utc_offset MINUTE), '$status_content_text', '$status_content_media');";
			
	$rs = $conn->query($sql);
	
	if ($rs === TRUE) {
		$status_id = $conn->insert_id;
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	if ( !($tagged_people == "NO_TAGS") ) {
	
		$tagged_people_array = explode(" ", $tagged_people);
		
		for ($i = 0; $i < count($tagged_people_array); ++$i) {
			$user_id = $tagged_people_array[$i];
			
			$sql = "INSERT INTO	status_tags(status_id, user_id)
					VALUES('$status_id', '$user_id');";
		
			$rs = $conn->query($sql);
			
			if ($rs === FALSE) {
				echo "ERROR: " . $sql . "<br>" . $conn->error;
			}
		}
	}
	
	$conn->close();
	
	if ($status_content_media == "NO_MEDIA") {
		echo "SUCCESS";
	}
	else {
		$uploaddir = '../uploads/statuses/' . $status_author_id . '/';
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
