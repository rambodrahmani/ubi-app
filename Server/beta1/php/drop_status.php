<?php	
	require_once("config.php");
	
	$status_id = $conn->real_escape_string($_POST['status_id']);
	
	$sql = "DELETE FROM	statuses
			WHERE		status_id = '$status_id';";
	
	$rs = $conn->query($sql);
	
	if ($rs === TRUE) {
		echo "SUCCESS";
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
