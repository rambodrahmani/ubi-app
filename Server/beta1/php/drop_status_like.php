<?php	
	require_once("config.php");
	
	$status_id = null;
	$user_id = null;
	
	$status_id = $conn->real_escape_string($_POST['status_id']);
	$user_id = $conn->real_escape_string($_POST['user_id']);
	
	$sql = "DELETE FROM	status_likes
			WHERE		status_id = '$status_id'
						AND user_id = '$user_id';";
	
	$rs = $conn->query($sql);
	
	if ($rs === TRUE) {
		echo "SUCCESS";
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
