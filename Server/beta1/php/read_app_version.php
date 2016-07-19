<?php	
	require_once("config.php");
	
	$platform_id = null;
	
	$platform_id = $conn->real_escape_string($_POST['platform_id']);
	
	$results = array();
	
	$sql = "SELECT	*
			FROM	current_versions
			WHERE	platform_id = '$platform_id';";
			
	$rs = $conn->query($sql);
	
	if ($rs->num_rows > 0) {
		while($row = $rs->fetch_assoc()) {
			array_push($results, $row);
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
