/******************************************************
* vm.sql 
* 
* Tables for vmcreator thing.
******************************************************/

CREATE TABLE defaults (
	id INTEGER PRIMARY KEY AUTOINCREMENT
);

/******************************************************
* disk_img 
* 
* The disk images / iso files.
******************************************************/
CREATE TABLE disk_img (
	id INTEGER PRIMARY KEY AUTOINCREMENT
);


/******************************************************
* settings
* 
* Where do we hold settings?
******************************************************/
CREATE TABLE settings (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	host_dir TEXT,				/* Where did we install program files? */
	install_dir TEXT,			/* Where did we leave executable links? */
	install_date TEXT,		/* When did we install this? */
	vbox_type TEXT,			/* Local (no root) or Systemwide? */
	vbox_bin TEXT,				/* Path to virtualbox executable */
	profile_name TEXT,		/* Can switch depending on versions */
	user_owner TEXT			/* User who installed */
);


CREATE TABLE vbox_versions (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	vbox_location TEXT,

);

/******************************************************
* vm_img 
* 
* The .vdi files.
******************************************************/
CREATE TABLE vm_img (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	vm_name TEXT,
	vm_alias TEXT,
	vm_uuid TEXT,
	vm_location TEXT   /* May need it for cloning. */
);


/******************************************************
* users 
* 
* Users who manage stuff.
******************************************************/
CREATE TABLE users (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	username TEXT,
	user_function TEXT,
	user_pwd TEXT
);


/******************************************************
* groups 
* 
* A group of VM's that serve the same purpose...
******************************************************/
CREATE TABLE groups (
	id INTEGER PRIMARY KEY AUTOINCREMENT
);


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
