#!/bin/bash -
#-----------------------------------------------------#
# vmmaster.sh
# 
# Manage the virtualbox installation on machine.
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
#-----------------------------------------------------#

LIB="sh/vmlib.sh"
BINDIR="$(dirname "$(readlink -f $0)")"   	# The program's directory.
source "$BINDIR/$LIB"	                     # Include the library.
PROGRAM="vmmaster"                          	# Program name.


# usage message
# Show a usage message and die.
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -  ]

-d|--download       desc
-d|--deploy <arg>   desc
-a|--at <arg>       desc
-a|--as <arg>       desc
-u|--update         desc
-v|--verbose        Be verbose in output.
-h|--help           Show this help and quit.
"
   exit $STATUS
}


[ -z $BASH_ARGV ] && printf "Nothing to do\n" && usage 1
while [ $# -gt 0 ]
do
   case "$1" in
     -d|--download)
         DOWNLOAD=true
      ;;
     -d|--deploy)
         DEPLOY=true
         shift
         DEPLOY_ARG=$1
      ;;
     -a|--at)
         AT=true
         shift
         AT_ARG=$1
      ;;
     -a|--as)
         AS=true
         shift
         AS_ARG=$1
      ;;
     -u|--update)
         UPDATE=true
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


if [ ! -z $DOWNLOAD ]
then
   echo '...'
fi

if [ ! -z $DEPLOY ]
then
   echo '...'
fi

if [ ! -z $AT ]
then
   echo '...'
fi

if [ ! -z $AS ]
then
   echo '...'
fi

if [ ! -z $UPDATE ]
then
   echo '...'
fi
