<?php	
	require_once("config.php");
	
	$results = array();
	
	$event_id = null;
	
	$event_id = $conn->real_escape_string($_POST['event_id']);
	
	$sql = "SELECT	user_id
			FROM	event_participants
			WHERE	event_id = '$event_id';";
			
	$result = $conn->query($sql);
	
	if ($result->num_rows > 0) {
		while($row = $result->fetch_assoc()) {
			array_push($results, $row);
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
