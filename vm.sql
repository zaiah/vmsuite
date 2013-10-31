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
CREATE TABLE servers (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	server_name TEXT,
	server_ip TEXT,
	server_domainname TEXT
);

CREATE TABLE keys (
	id INTEGER PRIMARY KEY AUTOINCREMENT
);
