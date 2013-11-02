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



vmsuite.sh (a lil something to jog your memory...)
x vmbuilder.sh
x vmdefault.sh
Rx vmgo.sh
x vmmaster.sh
x vmmgr --runas single / multi
(be sure to include called filename evaluation to tell which stream of logic to invoke)
	vmmgs.sh 
	vmmgm.sh
x vmimg.sh - Some pretty cool stuff can probably done w/ PXE...
  vmwatch
 	Wrappers for --metrics option
  vminfo
 	View that aggregates a ton of information on VM's
	uuid, dateCreated, name, network, groups it's attached to, bla...
  vmnet.sh
 	Just for router/network management
	(See all the different virtual networks created, etc)


## vmdefaults (i never want to ever ever ever do this shit again...)
defaults will get their own folder, and SQL can load them/reload them as necessary

we'll edit the different ones from here...

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

--refresh     Get the newest list of images.
--download    Download said images.
--alias       Set names for images.
--start-pxe   Set up an image for booting over PXE.


## vmdefault (this is silly because it can be reloaded without this much work)

Mess with the default guest image details.

-a | --ip-address <N>     Define an IP address for the new node.
-c | --clone <name>       Define a new name for the clone.
-d | --domain <domain>    Define an actual domain name for the new node.
-f | --fs-size <N in mb>  Define the size of the node's filesystem.
-i | --image <img>        Build from specified image.
-m | --ram <N in mb>      Create a new node with specified name.


## vmbuilder

Build a guest containing some image.

catch identifier
catch --to argument since it will be another profile
write lib routine to load all arguments at once

-a | --ip-address <N>        Define an IP address for the new node.
-c | --clone <name>          Define a new name for the clone.
-d | --domain <domain>       Define an actual domain name for the new node.
-f | --fs-size <N in mb>     Define the size of the node's filesystem.
-i | --image <img>           Build from specified image.
-m | --ram <N in mb>         Create a new node with specified name.
-n | --new <VM_NAME>         Create a new node with specified name.
-r | --remove <VM_NAME>   	  Get rid of a particular VM.
--from-disk               	  Use the files from CD drive versus an iso file.
-o | --morph <VM_NAME>       Should totally change a VM.
-s | --morph-and-copy <VM_NAME>  Should morph and copy/clone a VM.
-e | --name <VM_NAME>		  Use name as identifier when morphing.
-u | --uuid <VM_UUID>        Use uuid as identiifer when morphing.


## vmmgr (rename to vmsingle and vmmulti?)

*vmmulti can start profiles*
*vmsingle can start single vm imgs*

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

This is tough, b/c I think I need to copy nodes somehow, so that they can run.


## vmwatch 

Tracks stats on different vms.  memory, disk free, any other data that you can fit in.


## vmnet

Does some network goodness to different VM's.
More specifically, vmnet can put the different VM's into different network groups, set up these boxes to run with DHCP/Gateways/bla at a specific IP.  Use snapshots, and sed and some other trickery to make it all come together. 
