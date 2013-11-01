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
