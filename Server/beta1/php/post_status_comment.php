<?php	
	require_once("config.php");
	
	$user_id = null;
	$status_id = null;
	$comment_content_text = null;
	$status_comment_date_utc_offset = null;
	
	$user_id = $conn->real_escape_string($_POST['user_id']);
	$status_id = $conn->real_escape_string($_POST['status_id']);
	$comment_content_text = $conn->real_escape_string($_POST['comment_content_text']);
	$status_comment_date_utc_offset = $conn->real_escape_string($_POST['status_comment_date_utc_offset']);
	
	$comment_content_text = str_replace('\n', '', $comment_content_text);
	
	$sql = "INSERT INTO	status_comments(status_id, user_id, comment_content_text, comment_date)
			VALUES('$status_id', '$user_id', '$comment_content_text',  ADDDATE(UTC_TIMESTAMP(), INTERVAL $status_comment_date_utc_offset MINUTE));";
	
	$rs = $conn->query($sql);
	
	if ($rs === TRUE) {
		echo $conn->insert_id;
	} else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
