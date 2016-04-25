<?php	
	require_once("config.php");
	
	$place_id = null;
	$user_id = null;
	$review_text = null;
	$review_rating = null;
	$review_date = null;
	
	$place_id = $conn->real_escape_string($_POST['place_id']);
	$user_id = $conn->real_escape_string($_POST['user_id']);
	$review_text = $conn->real_escape_string($_POST['review_text']);
	$review_rating = $conn->real_escape_string($_POST['review_rating']);
	$review_date = $conn->real_escape_string($_POST['review_date']);
	
	$place_review_date_utc_offset = $conn->real_escape_string($_POST['place_review_date_utc_offset']);
	
	$sql = "SELECT	*
			FROM	place_reviews
			WHERE	place_id = '$place_id'
					AND user_id = '$user_id';";
				
	$result = $conn->query($sql);
	
	if ($result->num_rows > 0) {
		$sql = "UPDATE	place_reviews
				SET		review_text = '$review_text',
						review_rating = '$review_rating',
						review_date = ADDDATE(UTC_TIMESTAMP(), INTERVAL $place_review_date_utc_offset MINUTE)
				WHERE	place_id = '$place_id'
						AND user_id = '$user_id';";
	}
	else {
		if (strlen($review_date) < 1) {
			$sql = "INSERT INTO	place_reviews(place_id, user_id, review_text, review_rating, review_date)
					VALUES('$place_id', '$user_id', '$review_text', '$review_rating', ADDDATE(UTC_TIMESTAMP(), INTERVAL $place_review_date_utc_offset MINUTE));";
		}
		else {
			$sql = "INSERT INTO	place_reviews(place_id, user_id, review_text, review_rating, review_date)
					VALUES('$place_id', '$user_id', '$review_text', '$review_rating', '$review_date');";
		}
	}
	
	if ($conn->query($sql) === TRUE) {
		$url = BASE_URL . '/php/update_place_rating.php';
		$data = array('place_id' => $place_id);
		$options = array(
			'http' => array(
				'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
				'method'  => 'POST',
				'content' => http_build_query($data),
			),
		);
		$context  = stream_context_create($options);
		$response = file_get_contents($url, false, $context);
		echo $response;
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
