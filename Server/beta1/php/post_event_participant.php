<?php
	require_once("config.php");
	
	$event_id = null;
	$user_id = null;
	
	$event_id = $conn->real_escape_string($_POST['event_id']);
	$user_id = $conn->real_escape_string($_POST['user_id']);
	
	$sql = "INSERT INTO	event_participants(event_id, user_id)
			VALUE('$event_id', '$user_id');";
	
	if ($conn->query($sql) === TRUE) {
		echo "SUCCESS";
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
