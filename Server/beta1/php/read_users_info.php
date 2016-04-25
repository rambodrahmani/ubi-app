<?php	
	require_once("config.php");
	
	$user_ids = null;
	
	$user_ids = $conn->real_escape_string($_POST['user_ids']);
	$user_ids_array = explode(" ", $user_ids);
	
	$results = array();
	
	for ($i = 0; $i < count($user_ids_array); ++$i) {
		$user_id = $user_ids_array[$i];
	
		$sql = "SELECT	*
				FROM	users u INNER JOIN map m USING(user_id)
						INNER JOIN statuses s 
						ON u.user_id = s.status_author_id
				WHERE	u.user_id = '$user_id'
						AND s.status_date =	(SELECT		MAX(s1.status_date) 
											FROM		statuses s1 
											WHERE		s1.status_author_id = '$user_id'
											GROUP BY 	s1.status_author_id);";
		
		$result = $conn->query($sql);
		
		if ($result->num_rows > 0) {
			while($row = $result->fetch_assoc()) {
				array_push($results, $row);
			}
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
