#!/bin/bash -
#------------------------------------------------------
# vmgo.sh 
# 
# Deploy vmsuite for the first time.
#-----------------------------------------------------#

#source "$(dirname "$(readlink -f $0)")/conf/__config.sh"
PROGRAM="vmgo"                       # Program name.
BINDIR=                              # The program's directory.

# Giant list that will be maintanined here.
__SQLITE="/usr/bin/sqlite3"
DIR="$HOME/.vmsuite"
DB="$HOME/.vmsuite/vm.db"
IMG_DIR=
VBOX_DIR=
KEY_DIR=

usage() {
	STATUS="${1:-0}"
	echo "Usage: ./${PROGRAM}
	
"
	exit $STATUS
}

# Die if no options received.
[ -z $BASH_ARGV ] && echo "Nothing to do." && usage 1
while [ $# -gt 0 ]
do
	case "$1" in 
		--set-install-directory)
		shift
		INSTALL_DIRECTORY=$1
		;;
		--first-run)
		FIRST_RUN=true
		;;
		--rebuild)
		REBUILD=true
		;;
		--no-server-setup)
		SKIP_SERVER=true
		;;
		-v|--verbose)
		usage 0
		;;
		-h|--help)
		usage 0
		;;
		-*)
		;;
		*)
		;;
	esac
shift
done


# Set all flags.
if [ ! -z $VERBOSE ]
then
	MV_FLAGS="-v"
	LN_FLAGS="-v"
	MKDIR_FLAGS="-pv"
	GZCREATE_FLAGS="czvf"
	BZ2CREATE_FLAGS="cjvf"
	UNGZ_FLAGS="xzvf"
	UNBZ2_FLAGS="xjvf"
	SCP_FLAGS="-v"
	RM_FLAGS="-rfv"
else
	MV_FLAGS=
	LN_FLAGS=
	MKDIR_FLAGS="-p"
	GZCREATE_FLAGS="czf"
	BZ2CREATE_FLAGS="cjf"
	UNGZ_FLAGS="xzf"
	UNBZ2_FLAGS="xjf"
	SCP_FLAGS=
	RM_FLAGS="-rf"
fi


# Do the first run.
if [ ! -z $FIRST_RUN ]
then

# Set directory.
[ ! -z "$INSTALL_DIRECTORY" ] && DIR="$INSTALL_DIRECTORY" 

# Do filesystem purtyness.
mkdir -p $DIR/{img,file,vbox,keys}
mkdir -p $DIR/vbox/{src,bin}

# Load database tables.
[ ! -f $DB ] && $__SQLITE $DB < "${BINDIR}/vm.sql"
fi 


# Rebuild the databases.
if [ ! -z $REBUILD ]
then

fi
