<?php	
	require_once("config.php");
	
	$comment_id = $conn->real_escape_string($_POST['comment_id']);
	
	$sql = "DELETE FROM	status_comments
			WHERE		comment_id = '$comment_id';";
	
	$rs = $conn->query($sql);
	
	if ($rs === TRUE) {
		echo "SUCCESS";
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
