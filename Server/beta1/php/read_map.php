<?php	
	require_once("config.php");
	
	$results = array();
	
	$lat = null;
	$lon = null;
	$latDelta = null;
	$lonDelta = null;
	
	$lat = $conn->real_escape_string($_POST['lat']);
	$lon = $conn->real_escape_string($_POST['lon']);
	$latDelta = $conn->real_escape_string($_POST['latdelta']);
	$lonDelta = $conn->real_escape_string($_POST['londelta']);
	
	if($lat && $lon && $latDelta && $lonDelta)
	{
		$sql = "SELECT	*
				FROM	users u INNER JOIN map m USING(user_id)
						INNER JOIN statuses s 
						ON u.user_id = s.status_author_id
				WHERE	user_lastaccess + INTERVAL 6 HOUR >= CURRENT_TIMESTAMP()
						AND m.user_lat >= ('$lat' - '$latDelta')
						AND m.user_lat <= ('$lat' + '$latDelta')
						AND m.user_lon >= ('$lon' - '$lonDelta')
						AND m.user_lon <= ('$lon' + '$lonDelta')
						AND m.user_lat != 0 
						AND m.user_lon != 0
						AND s.status_date =	(SELECT		MAX(s1.status_date) 
											FROM		statuses s1 
											WHERE		s1.status_author_id = s.status_author_id
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
