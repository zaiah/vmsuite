/******************************************************
* nics.sql 
* 
* Basic NIC profiles.
* Maybe it's easier to manage all the types here?
******************************************************/
CREATE TABLE nics (
	id INTEGER PRIMARY KEY AUTOINCREMENT,  /* Seems dumb */
	group_name TEXT,	  /* Give it a name */
	nic_count INTEGER,  /* How many interfaces to create */
	nic_types TEXT		  /* Use comma chop to get this...*/
);

