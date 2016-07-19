<?php	
	require_once("config.php");
	
	$user_id = $conn->real_escape_string($_POST['user_id']);
	$chat_id = $conn->real_escape_string($_POST['chat_id']);
	$email = $conn->real_escape_string($_POST['email']);
	$name = $conn->real_escape_string($_POST['name']);
	$surname = $conn->real_escape_string($_POST['surname']);
	$profile_pic = $conn->real_escape_string($_POST['profile_pic']);
	$profile_url = $conn->real_escape_string($_POST['profile_url']);
	$bio = $conn->real_escape_string($_POST['bio']);
	$birthday = $conn->real_escape_string($_POST['birthday']);
	$gender = $conn->real_escape_string($_POST['gender']);
	
	$sql = "UPDATE	users
			SET		user_chat_id = '$chat_id',
					user_email = '$email',
					user_name = '$name',
					user_surname = '$surname',
					user_profile_pic = '$profile_pic',
					user_profile_url = '$profile_url',
					user_bio = '$bio',
					user_birthday = '$birthday',
					user_gender = '$gender'
			WHERE	user_id = '$user_id';";
			
	if ($conn->query($sql) === TRUE) {
		echo "SUCCESS";
		
		$user_id = $conn->insert_id;
		
		$url = 'http://server.ubisocial.it/php/create_ubi_pic.php';
		$data = array(	'src' => $profile_pic,
						'dst' => "../uploads/users/".$user_id."/",
						'id' => $user_id,
					  );
		$options = array(
			'http' => array(
				'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
				'method'  => 'POST',
				'content' => http_build_query($data),
			),
		);
		$context  = stream_context_create($options);
		$response = file_get_contents($url, false, $context);
	} 
	else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
