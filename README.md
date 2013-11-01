# vmsuite

Wrappers for virtualbox emulating the functionality of zones in the absence of time.


## Commands we use all the time.
### Installing Scripts
Create ~/bin
Modify the PATH if necessary
Record changes to file or SQLite
Check for SQLite and other programs
"Install" by linking to executable dir.
Uninstall by removing said links.
Get other files within the same directory.
Know where we're executing from.

### Setting flags
Flags are always changing depending on options to programs.

### Generating options
Still no good quick way to do this, but there's probably some good quick way out there.

### Running in debug mode.
Use `echo` before every command to see what would happen.


## Global Functions
- _get_vm_by_id() - Retrieve a vm by ID.  Don't repeat anywhere.
- _update_vm_by_id() - Retrieve a vm by ID.  Don't repeat anywhere.
- _remove_item_by_id() - Retrieve a vm by ID.  Don't repeat anywhere.




## vmgo
COMPLETED
Install this mess..
	*setup some server somewhere to sync vm'=s... 

Rebuild databases....

Update virtualbox


x --first-run               Build databases and all that jazz.
x --rebuild                 Rebuild databases for new versions.
--no-server-setup         Skip the whole server setup step.
x --clobber                 Totally overwrite your old setup.



## vmmaster

Management of virtualbox itself
--download			Download the software
--deploy				Deploy an install somewhere (local or systemwide)
--at					Set a different directory than the default.
--as					Run as a different user.
x --update        Update virtualbox.

You can build for local testing by using the source code and forget root.
http://download.virtualbox.org/virtualbox/4.3.0/VirtualBox-4.3.0.tar.bz2

When you're really ready to build, use something else...



## vmimg

Images are a continual problem.  Whether I set them up or not...
They should be stored somewhere...

--refresh  Get the newest list of images.
--download Download said images.
--alias    Set names for images.



## vmdefault

Mess with the default guest image details.

-a | --ip-address <N>     Define an IP address for the new node.
-c | --clone <name>       Define a new name for the clone.
-d | --domain <domain>    Define an actual domain name for the new node.
-f | --fs-size <N in mb>  Define the size of the node's filesystem.
-i | --image <img>        Build from specified image.
-m | --ram <N in mb>      Create a new node with specified name.
-n | --new <VM_NAME>      Create a new node with specified name.
-s | --ssh-key <key>      Import an SSH key for use with the node.


## vmbuilder

Build a guest containing some image.

-a | --ip-address <N>     Define an IP address for the new node.
-c | --clone <name>       Define a new name for the clone.
-d | --domain <domain>    Define an actual domain name for the new node.
-f | --fs-size <N in mb>  Define the size of the node's filesystem.
-i | --image <img>        Build from specified image.
-m | --ram <N in mb>      Create a new node with specified name.
-n | --new <VM_NAME>       Create a new node with specified name.
-s | --ssh-key <key>      Import an SSH key for use with the node.
-r | --remove <VM_NAME>    Get rid of a particular VM.

-u | --username <name>    Create a user for the node with specified username.
--from-disk               Use the files from CD drive versus an iso file.
-h | --help               Display a short help and exit. 
-p | --use-rdp


## vmmgr (rename to vmsingle and vmmulti?)

*vmmulti can start profiles
*vmsingle can start single vm imgs

Start, stop, rotate, flip around, make sing and dance different VM's.

- -l     Lists all VMs
	Needs much more information: 
		uuid w/o brackets
		date of last modify
		purpose of vm

x -f     Starts a new process in the foreground.
	Indicate machine with argument	
-p     Starts a new (set of) VM(s) according to a profile.
	Add to db to start a profile
	To insure that we can start everything, we need to also make copies, lest one profile has multiple of the same VM.
-b     Starts a new instance of a VM in the background, logging to file or db.
	Indicate machine with argument	
-k     Stop an instance of a VM. or profiles
-r     Restart an instance of a VM.
-s     Take a snapshot of a VM.
x -h     Show this help message and quit.
-a     Set an alias for a machine.

## vmmulti

...

## vmwatch 

Tracks stats on different vms.  memory, disk free, any other data that you can fit in.


## vmsec

Manage security of VM's through SSH keys.
Keep user credentials somewhere.
This tool should be able to output lots of text in order to work with other tools. 

### Local Functions

generate_ssh_key() - Generates an SSH key
revoke_and_regenerate() - Revoke an SSH key and regenerate
check_user_against - Use a randomly generated username as the current user.



## vmnet

Does some network goodness to different VM's.
More specifically, vmnet can put the different VM's into different network groups, set up these boxes to run with DHCP/Gateways/bla at a specific IP.  Use snapshots, and sed and some other trickery to make it all come together. 
