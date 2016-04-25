<?php	
	require_once("config.php");
	
	$status_id = null;
	$user_id = null;
	
	$status_id = $conn->real_escape_string($_POST['status_id']);
	$user_id = $conn->real_escape_string($_POST['user_id']);
	
	$sql = "INSERT INTO	status_likes(status_id, user_id)
			VALUE('$status_id', '$user_id');";
	
	if ($conn->query($sql) === TRUE) {
		echo "SUCCESS";
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
