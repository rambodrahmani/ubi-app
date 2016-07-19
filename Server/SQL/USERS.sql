-- UBI_OLD

DROP TABLE IF EXISTS `USERS`;
CREATE TABLE `USERS`
(
	ID				INT(11) AUTO_INCREMENT NOT NULL,
	Email			VARCHAR(255) NOT NULL,
	Name			VARCHAR(255) NOT NULL,
	Surname			VARCHAR(255) NOT NULL,
	Profile_Pic		VARCHAR(255) NOT NULL,
	Profile_URL		VARCHAR(255) NOT NULL,
	Last_Post_ID	LONGTEXT NOT NULL,
	Bio				LONGTEXT,
	Birthday		DATE,
	Sex				CHAR(1),
	PRIMARY KEY(`ID`),
	UNIQUE(`Email`),
    UNIQUE(`ProfilePic`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;




-- PIM

CREATE TABLE `users`
(
	user_id			INT(11) AUTO_INCREMENT NOT NULL,
        user_name		VARCHAR(255) NOT NULL,
        user_surname		VARCHAR(255) NOT NULL,
 	user_phone_number	VARCHAR(255) NOT NULL,
        user_profile_pic	VARCHAR(255) NOT NULL,
        user_bio		LONGTEXT,
        PRIMARY KEY(`user_id`),
        UNIQUE(`user_phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;