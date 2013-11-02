#!/bin/bash -
#------------------------------------------------------
# vmmgr.sh (vmmgs, vmmgm)
# 
# Shortcuts to start and stop single VMs and groups.
#
# ---------
# Licensing
# ---------
# 
# Copyright (c) 2013 Vokayent
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#------------------------------------------------------

LIB="sh/vmlib.sh"
BINDIR="$(dirname "$(readlink -f $0)")"   	# The program's directory.
source "$BINDIR/$LIB"	                     # Include the library.
PROGRAM="vmgo"                            	# Program name.


# usage message
# Show a usage message and die.
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -  ]

-l|--list           desc
-f|--foreground     desc
-b|--background     desc
-n|--name           desc
-a|--alias          desc
-k|--kill           desc
-r|--restart        desc
-s|--snap           desc
-v|--verbose        Be verbose in output.
-h|--help           Show this help and quit.
"
   exit $STATUS
}


# Die if no options received.
[ -z $BASH_ARGV ] && echo "Nothing to do." && usage 1
while [ $# -gt 0 ]
do
   case "$1" in
     -l|--list)
         LIST=true
      ;;
     -f|--foreground)
         FOREGROUND=true
      ;;
     -b|--background)
         BACKGROUND=true
      ;;
     -n|--name)
         NAME=true
      ;;
     -a|--alias)
         ALIAS=true
      ;;
     -k|--kill)
         KILL=true
      ;;
     -r|--restart)
         RESTART=true
      ;;
     -s|--snap)
         SNAP=true
      ;;
      -v|--verbose)
        VERBOSE=true
      ;;
      -h|--help)
        usage 0
      ;;
      -*)
      printf "Bad argument.\n";
      exit 1
     ;;
      *) break;;
   esac
shift
done

# Set verbosity and other flags.
eval_flags

if [ ! -z $LIST ]
then
   echo '...'
fi

if [ ! -z $FOREGROUND ]
then
   echo '...'
fi

if [ ! -z $BACKGROUND ]
then
   echo '...'
fi

if [ ! -z $NAME ]
then
   echo '...'
fi

if [ ! -z $ALIAS ]
then
   echo '...'
fi

if [ ! -z $KILL ]
then
   echo '...'
fi

if [ ! -z $RESTART ]
then
   echo '...'
fi

if [ ! -z $SNAP ]
then
   echo '...'
fi
