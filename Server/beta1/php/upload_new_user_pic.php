<?php	
	require_once("config.php");
	
	$user_id = null;
	$media_url = null;
	
	$user_id = $conn->real_escape_string($_POST['user_id']);
	$media_url = $conn->real_escape_string($_POST['media_url']);
	
	$uploaddir = '../uploads/users/' . $user_id . '/';
	if (!file_exists($uploaddir)) {
		mkdir($uploaddir, 0777, true);
	}
	
	$file = basename($_FILES['uploadedfile']['name']);
	$uploadfile = $uploaddir . $file;
	
	if (move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $uploadfile)) {
		$sql = "UPDATE	users
				SET		user_profile_pic = '$media_url'
				WHERE	user_id = '$user_id';";
				
		if ($conn->query($sql) === TRUE) {
			echo "SUCCESS";
		} else {
			echo "ERROR: " . $sql . "<br>" . $conn->error;
		}
	}
	else {
		echo "ERROR";
	}
	
	$conn->close();
?>
