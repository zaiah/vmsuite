/******************************************************
* settings
* 
* Where do we hold settings?
******************************************************/
CREATE TABLE settings (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	editor TEXT,				/* vim */
	host_dir TEXT,				/* Where did we install program files? */
	install_dir TEXT,			/* Where did we leave executable links? */
	install_date TEXT,		/* When did we install this? */
	vbox_type TEXT,			/* Local (no root) or Systemwide? */
	vbox_bin TEXT,				/* Path to virtualbox executable */
	last_mod_date TEXT,     /* Last modified date */
	user_owner TEXT			/* User who installed */
);
