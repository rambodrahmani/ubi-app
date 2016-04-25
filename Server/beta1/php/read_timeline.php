<?php	
	require_once("config.php");
	
	$user_ids = null;
	
	$user_ids = $conn->real_escape_string($_POST['user_ids']);
	$user_ids_array = explode(" ", $user_ids);
	
	$results = array();
	
	for ($i = 0; $i < count($user_ids_array); ++$i) {
		$obj = new stdClass();
		
		$user_id = $user_ids_array[$i];
		
		$rs = $conn->query("SELECT		*
							FROM		statuses s
							WHERE		s.status_author_id = '$user_id'
										AND s.status_date = (SELECT		MAX(s1.status_date)
															FROM		statuses s1
															WHERE		s1.status_author_id = s.status_author_id
															GROUP BY	s1.status_author_id)
							ORDER BY	s.status_date DESC;");
		
		$obj->status = $rs->fetch_object();
	
		if($rs && $obj->status) {
	
			$status_id = $obj->status->status_id;
			$status_place_id = $obj->status->status_place_id;
			
			$obj->place = "NO_LOC";
			if ($status_place_id != 0) {
				$rs = $conn->query("SELECT	*
									FROM	places
									WHERE	place_id = '$status_place_id';");
				if ($rs->num_rows > 0)
					$obj->place = $rs->fetch_object();
			}
	
			$rs = $conn->query("SELECT	st.*, u.user_name, u.user_surname
								FROM	status_tags st INNER JOIN users u USING(user_id)
								WHERE	status_id = '$status_id';");
	
			if ($rs->num_rows > 0) {
				$tags = array();
				while ($obj_tag = $rs->fetch_object()) {
					$tags[] = $obj_tag;
				}
				$obj->tags = $tags;
			}else {
				$obj->tags = "NO_TAGS";
			}
	
			$rs = $conn->query("SELECT	user_id
								FROM	status_likes
								WHERE	status_id = '$status_id';");	
			if ($rs->num_rows > 0) {
				$likes = array();
				while ($obj_like = $rs->fetch_object()) {
					$likes[] = $obj_like;
				}
				$obj->likes = $likes;
			}else{
				$obj->likes = "NO_LIKES";
			}
			
			$rs = $conn->query("SELECT	COUNT(*) AS comments_num
								FROM	status_comments
								WHERE	status_id = '$status_id';");
	
			if ($rs->num_rows > 0) {
				$obj->comments = $rs->fetch_object();
			}else{
				$obj->comment = "NO_COMMENTS";
			}
			
			$results[] = $obj;
		}
	}
	
	$conn->close();
	
	echo json_encode($results, JSON_UNESCAPED_SLASHES);
?>
