<?php	
	require_once("config.php");
	
	$place_id = null;
	
	$place_id = $conn->real_escape_string($_POST['place_id']);
	
	$sql = "SET @ratings_sum := 0;";
	$rs = $conn->query($sql);
	
	$sql = "SET @ratings_num := 0;";
	$rs = $conn->query($sql);
	
	$sql = "SELECT		SUM(review_rating), COUNT(*) INTO @ratings_sum, @ratings_num
			FROM		place_reviews
			WHERE		place_id = '$place_id'
			GROUP BY	place_id;";
	$rs = $conn->query($sql);
	
	$sql = "UPDATE	places
			SET		place_rating = (@ratings_sum/@ratings_num)
			WHERE	place_id = '$place_id';";
	if ($conn->query($sql) === TRUE)
	{
		echo "SUCCESS";
	} 
	else {
		echo "ERROR: " . $sql . "<br>" . $conn->error;
	}
	
	$conn->close();
?>
