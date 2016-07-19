<?php
	define('BASE_URL', 'http://server.ubisocial.it');
	
	define('DB_SERVER', "localhost");
	define('DB_USER', "ubi_user");
	define('DB_PASSWORD', "ubi_pw");
	define('DB_DATABASE', "ubi_db");
	
	define('APP_KEY', 'AIzaSyDvVkUL9hae0vMfYRVbG0AZjnwuj2ZLIcI');
	define('SERVER_KEY', 'AIzaSyDoVN35NQvRJ_W3EiTwPLri2M0aDf9wxx0');
	define('VM1_KEY', 'AIzaSyDCbus2J2meXpr5UMiSirWFHMdON02wSQw');
	define('VM2_KEY', 'AIzaSyDojf241YOwN3vftz0b4-GR4uI4YW0_9hk');
	define('VM3_KEY', 'AIzaSyDhKn8IMRDX5fUlny7TtOn7R9jA1_4SArw');
	define('VM4_KEY', 'AIzaSyBjBpERri1Bc8h7PD8Ae9hlx41qXWDwiz0');
	define('VM5_KEY', 'AIzaSyC13ErZXUygf51Q2jD8LDZfhMDkXp-XHYw');
	define('VM6_KEY', 'AIzaSyDYTERjcuxehnw11mtaIpdwwkoGZsaE2eI');
	
	$conn = new mysqli(DB_SERVER, DB_USER, DB_PASSWORD, DB_DATABASE);
	
	if ($conn->connect_error) {
		die("Connection failed: " . $conn->connect_error);
	}
	
	$conn->set_charset("utf8");
	
	$VM_servers = array('vm1.ubisocial.it', 'vm2.ubisocial.it', 'vm3.ubisocial.it', 'vm4.ubisocial.it', 'vm5.ubisocial.it', 'vm6.ubisocial.it');
?>
