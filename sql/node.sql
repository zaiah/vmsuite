/******************************************************
 * node
 *
 * Defaults are the first row.
 * Any other settings are farther down the list.
******************************************************/
CREATE TABLE node_defaults (
	id INTEGER PRIMARY KEY AUTOINCREMENT,  /* Seems dumb */
	ram INTEGER,			/* Default RAM allocation */
	balloon INTEGER,		/* Balloon size... */
	fs_size INTEGER,		/* File system size */
	os_type TEXT,			/* Default OS type - Linux */
	nic_prof INTEGER,	   /* NIC profile from nics.sql */
	cpus INTEGER,			/* Set CPUs to use at once */	
	cpu_ex INTEGER,		/* Set a CPU execution limit */
	net_bw INTEGER,		/* Set a network io limit */
	disk_bw INTEGER		/* Set a disk io limit */
);
