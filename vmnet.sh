#!/bin/bash -

PROGRAM=

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
		--)
		;;
		-*)
		;;
		*)
		;;
	esac
	shift
done
