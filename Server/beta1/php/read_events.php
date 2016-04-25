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
				FROM	events e INNER JOIN places p
						ON e.event_place_id = p.place_id
						INNER JOIN users u ON e.event_author_id = u.user_id
				WHERE	e.event_end_date >= CURRENT_TIMESTAMP()
						AND p.place_lat >= ('$lat' - '$latDelta')
						AND p.place_lat <= ('$lat' + '$latDelta')
						AND p.place_lon >= ('$lon' - '$lonDelta')
						AND p.place_lon <= ('$lon' + '$lonDelta');";
		
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
