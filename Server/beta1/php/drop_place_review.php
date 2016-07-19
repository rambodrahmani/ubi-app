<?php
	require_once("config.php");
	
	$review_id = $conn->real_escape_string($_POST['review_id']);
	$place_id = $conn->real_escape_string($_POST['place_id']);
	
	$sql = "DELETE FROM	place_reviews
			WHERE		review_id = '$review_id';";
			
	$result = $conn->query($sql);
	
	if ($result === TRUE)
	{
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
