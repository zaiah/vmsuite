/******************************************************
* keys 
* 
* SSH keys for server management.
******************************************************/
CREATE TABLE keys (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	key_name TEXT,
	key_location TEXT
);
