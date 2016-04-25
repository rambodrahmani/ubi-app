<?php
	require_once("config.php");
	
	$user_id = null;
	$lat = null;
	$lon = null;
	
	$user_id = $conn->real_escape_string($_POST['user_id']);
	$lat = $conn->real_escape_string($_POST['lat']);
	$lon = $conn->real_escape_string($_POST['lon']);
	
	$sql = "UPDATE	map
			SET		user_lat = '$lat',
					user_lon = '$lon'
			WHERE	user_id = '$user_id';";
			
	if ($conn->query($sql) === TRUE) {
		echo "SUCCESS";
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
