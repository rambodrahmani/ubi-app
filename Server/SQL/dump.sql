DROP TABLE IF EXISTS `addresses`;
DROP TABLE IF EXISTS `event_partecipants`;
DROP TABLE IF EXISTS `events`;
DROP TABLE IF EXISTS `status_tag`;
DROP TABLE IF EXISTS `status_like`;
DROP TABLE IF EXISTS `status_comments`;
DROP TABLE IF EXISTS `statuses`;
DROP TABLE IF EXISTS `map`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users`
(
	user_id				INT(11) AUTO_INCREMENT NOT NULL,
	user_chat_id		INT(11) NOT NULL,
	user_email			VARCHAR(255) NOT NULL,
	user_name			VARCHAR(255) NOT NULL,
	user_surname		VARCHAR(255) NOT NULL,
	user_profile_pic	VARCHAR(255) NOT NULL,
	user_profile_url	VARCHAR(255) NOT NULL,
	user_bio			LONGTEXT,
	user_birthday		DATE,
	user_sex			CHAR(1),
	user_lastpost_id	INT(11),
	PRIMARY KEY(`user_id`),
	UNIQUE(`user_email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `map`
(
	user_email		VARCHAR(255) NOT NULL,
	user_lat		DOUBLE NOT NULL,
	user_lon		DOUBLE NOT NULL,
	user_lastaccess	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(`user_email`),
	FOREIGN KEY(`user_email`) REFERENCES `users`(`user_email`)
	ON DELETE CASCADE
	ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `statuses`
(
	status_id				INT(11) AUTO_INCREMENT NOT NULL,
	status_author_email		VARCHAR(255) NOT NULL,
	status_address_id		INT(11) DEFAULT NULL,
	status_date				TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	status_content_text		LONGTEXT NOT NULL,
	status_content_media	VARCHAR(255) DEFAULT NULL,
	PRIMARY KEY(`status_id`),
	FOREIGN KEY(`status_author_email`) REFERENCES `users`(`user_email`)
	ON DELETE CASCADE
	ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `status_comments`
(
	comment_id				INT(11) AUTO_INCREMENT NOT NULL,
	comment_status_id		INT(11) NOT NULL,
	comment_author_email	VARCHAR(255) NOT NULL,
	comment_content_text	LONGTEXT NOT NULL,
	comment_date			TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	comment_parent			INT(11) NOT NULL,
	PRIMARY KEY(`comment_id`),
	FOREIGN KEY(`comment_status_id`) REFERENCES `statuses`(`status_id`)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY(`comment_author_email`) REFERENCES `users`(`user_email`)
	ON DELETE CASCADE
	ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `status_like`
(
	like_id				INT(11) AUTO_INCREMENT NOT NULL,
	like_status_id		INT(11) NOT NULL,
	like_author_email	VARCHAR(255) NOT NULL,
	PRIMARY KEY(`like_id`),
	FOREIGN KEY(`like_status_id`) REFERENCES `statuses`(`status_id`)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY(`like_author_email`) REFERENCES `users`(`user_email`)
	ON DELETE CASCADE
	ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `status_tag`
(
	tag_id			INT(11) AUTO_INCREMENT NOT NULL,
	tag_status_id	INT(11) NOT NULL,
	tag_user_email	VARCHAR(255) NOT NULL,
	PRIMARY KEY(`tag_id`),
	FOREIGN KEY(`tag_status_id`) REFERENCES `statuses`(`status_id`)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY(`tag_user_email`) REFERENCES `users`(`user_email`)
	ON DELETE CASCADE
	ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `events`
(
	event_id			INT(11) AUTO_INCREMENT NOT NULL,
	event_author_email	VARCHAR(255) NOT NULL,
	event_name			VARCHAR(255) NOT NULL,
	event_picture_url	VARCHAR(255) NOT NULL,
	event_description	LONGTEXT NOT NULL,
	event_address_id 	INT(11) DEFAULT NULL,
	event_date_start	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	event_date_end		TIMESTAMP NOT NULL,
	PRIMARY KEY(`event_id`),
	FOREIGN KEY(`event_author_email`) REFERENCES `users`(`user_email`)
	ON DELETE CASCADE
	ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `event_partecipants`
(
	event_id	INT(11) NOT NULL,
	user_email	VARCHAR(255) NOT NULL,
	PRIMARY KEY(`event_id`, user_email),
	FOREIGN KEY(`event_id`) REFERENCES `events`(`event_id`)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY(`user_email`) REFERENCES `users`(`user_email`)
	ON DELETE CASCADE
	ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `addresses`
(
	address_id			INT(11) AUTO_INCREMENT NOT NULL,
	address_name		VARCHAR(255) NOT NULL,
	address_lat			DOUBLE NOT NULL,
	address_lon			DOUBLE NOT NULL,
	address_picture_url	VARCHAR(255) NOT NULL,
	address_description	LONGTEXT NOT NULL,
	address_place_id	VARCHAR(255) NOT NULL,
	PRIMARY KEY(`address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;