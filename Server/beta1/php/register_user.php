<?php	
	require_once("config.php");
	
	$email = $conn->real_escape_string($_POST['email']);
	$name = $conn->real_escape_string($_POST['name']);
	$surname = $conn->real_escape_string($_POST['surname']);
	$profile_pic = $conn->real_escape_string($_POST['profile_pic']);
	$profile_url = $conn->real_escape_string($_POST['profile_url']);
	$last_status_text = $conn->real_escape_string($_POST['last_status_text']);
	$bio = $conn->real_escape_string($_POST['bio']);
	$birthday = $conn->real_escape_string($_POST['birthday']);
	$gender = $conn->real_escape_string($_POST['gender']);
	$chat_id = $conn->real_escape_string($_POST['chat_id']);
	
	$google_plus_id = $conn->real_escape_string($_POST['google_plus_id']);
	
	$status_date_utc_offset = $conn->real_escape_string($_POST['status_date_utc_offset']);
	
	$sql = "SELECT	*
			FROM	users
			WHERE	user_email = '$email'
					OR user_email = '$google_plus_id';";
			
	$rs = $conn->query($sql);
	
	$user_id = 0;
	
	if ($rs->num_rows > 0) {
		$row = $rs->fetch_assoc();
		$user_id = $row['user_id'];
	} else {
		$sql = "INSERT INTO users (user_chat_id, user_email, user_name, user_surname, user_profile_pic, user_profile_url, user_bio, user_birthday, user_gender)
				VALUES('$chat_id', '$email', '$name', '$surname', '$profile_pic', '$profile_url', '$bio', '$birthday', '$gender');";
		
		if ($conn->query($sql) === TRUE) {
			$user_id = $conn->insert_id;
	
			/*
			 * CREATE ICON UBI
			 */
	
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
			
			$sql_map = "INSERT INTO	map (user_id)
						VALUES('$user_id');";
						
			if (strlen($last_status_text) > 0) {
				$sql_statuses = "INSERT INTO statuses(status_place_id, status_author_id, status_content_text, status_content_media, status_date)
								VALUES('0', '$user_id', '$name $surname si è appena registrato su Ubi! Dagli un caloroso bevenuto!', 'NO_MEDIA', ADDDATE( UTC_TIMESTAMP(), INTERVAL $status_date_utc_offset MINUTE)),
								('0', '$user_id', '$last_status_text', 'NO_MEDIA', ADDDATE( UTC_TIMESTAMP(), INTERVAL ($status_date_utc_offset + 1) MINUTE));";
			}
			else {
				$sql_statuses = "INSERT INTO statuses(status_place_id, status_author_id, status_content_text, status_content_media, status_date)
								VALUES('0', '$user_id', '$name $surname si è appena registrato su Ubi! Dagli un caloroso bevenuto!', 'NO_MEDIA', ADDDATE( UTC_TIMESTAMP(), INTERVAL $status_date_utc_offset MINUTE));";
			}
			
			if ($conn->query($sql_map) === TRUE && $conn->query($sql_statuses) === TRUE) {
				// SUCCESS
			} else {
				echo "ERROR: " . $conn->error;
			}
		} else {
			echo "ERROR: " . $sql . "<br>" . $conn->error;
		}
	}
	
	$conn->close();
	
	echo $user_id;
?>
