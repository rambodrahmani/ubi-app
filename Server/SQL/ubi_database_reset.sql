delete from events
where event_id>0;

delete from places
where place_id>0;

delete from statuses
where status_id>0;

delete from users
where user_id>0;

ALTER TABLE users AUTO_INCREMENT=1;

ALTER TABLE statuses AUTO_INCREMENT=1;

ALTER TABLE places AUTO_INCREMENT=1;

ALTER TABLE events AUTO_INCREMENT=1;