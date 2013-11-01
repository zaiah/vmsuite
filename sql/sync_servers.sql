/******************************************************
* servers 
* 
* Servers that we've decided to use for syncing.
******************************************************/
CREATE TABLE sync_servers (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	server_name TEXT,
	server_ip TEXT,
	server_domainname TEXT,
	server_shortname TEXT,
	server_user TEXT,
	need_key TEXT /* true or false */
);
