<?php	
	require_once("config.php");
	
	$results = array();
	
	$place_id = null;
	
	$place_id = $conn->real_escape_string($_POST['place_id']);
	
	$sql = "SELECT		*
			FROM		place_reviews pr INNER JOIN users u USING(user_id)
			WHERE		pr.place_id = '$place_id'
			ORDER BY	pr.review_date ASC;";
			
	$result = $conn->query($sql);
	
	if ($result->num_rows > 0) {
		while($row = $result->fetch_assoc()) {
			array_push($results, $row);
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
