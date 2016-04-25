<?php	
	require_once("config.php");
	
	$results = array();
	
	$status_id = null;
	
	$status_id = $conn->real_escape_string($_POST['status_id']);
	
	$sql = "SELECT		*
			FROM		status_comments sc INNER JOIN users u USING(user_id)
			WHERE		sc.status_id = '$status_id'
			ORDER BY	sc.comment_date ASC;";
			
	$result = $conn->query($sql);
	
	if ($result->num_rows > 0) {
		while($row = $result->fetch_assoc()) {
			array_push($results, $row);
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
