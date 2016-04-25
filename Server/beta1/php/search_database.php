<?php	
	require_once("config.php");
	
	$query_text = null;
	
	$query_text = $conn->real_escape_string($_POST['query']);
	$query_array = explode(" ", $query_text);
	
	$results = array();
	
	for ($i = 0; $i < count($query_array); ++$i) {
		$value = $query_array[$i];
		
		if (strlen($value) > 1) {
			$sql = "SELECT	*
					FROM	users u INNER JOIN map m USING(user_id)
							INNER JOIN statuses s 
							ON u.user_id = s.status_author_id
					WHERE	(u.user_email LIKE '%$value%'
							OR u.user_name LIKE '%$value%'
							OR u.user_surname LIKE '%$value%')
							AND m.user_lat != 0 
							AND m.user_lon != 0
							AND s.status_date =	(SELECT		MAX(s1.status_date) 
												FROM		statuses s1 
												WHERE		s1.status_author_id = s.status_author_id
												GROUP BY 	s1.status_author_id);";
			
			$result = $conn->query($sql);
			
			if ($result->num_rows > 0) {
				while($row = $result->fetch_assoc()) {
					if ( !(in_array($row, $results)) ) {
						array_push($results, $row);
					}
				}
			}
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
