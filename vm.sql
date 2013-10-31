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
* The disk image.
******************************************************/
CREATE TABLE disk_img (
	id INTEGER PRIMARY KEY AUTOINCREMENT
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

CREATE TABLE keys (
	id INTEGER PRIMARY KEY AUTOINCREMENT
);
