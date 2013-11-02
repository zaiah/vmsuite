/******************************************************
 * default layout
******************************************************/
CREATE TABLE node_defaults (
	id INTEGER PRIMARY KEY AUTOINCREMENT,  /* Seems dumb */
	ram INTEGER,			/* Default RAM allocation */
	balloon INTEGER,		/* Balloon size... */
	fs_size INTEGER,		/* File system size */
	os_type TEXT,			/* Default OS type - Linux */
	nic_prof INTEGER	   /* NIC profile from nics.sql */
);
