#!/bin/bash -
#
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

# usage message
# Show a usage message and die.
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -  ]

-i|--ip-address     desc
-c|--clone          desc
-d|--domain         desc
-f|--fs-size        desc
-i|--image          desc
-r|--ram            desc
-n|--new            desc
-m|--modify         desc
-r|--remove         desc
-f|--from-disk      desc
-v|--verbose        Be verbose in output.
-h|--help           Show this help and quit.
"
   exit $STATUS
}


[ -z $BASH_ARGV ] && printf "Nothing to do\n" && usage 1
while [ $# -gt 0 ]
do
   case "$1" in
     -i|--ip-address)
         IP_ADDRESS=true
      ;;
     -c|--clone)
         CLONE=true
      ;;
     -d|--domain)
         DOMAIN=true
      ;;
     -f|--fs-size)
         FS_SIZE=true
      ;;
     -i|--image)
         IMAGE=true
      ;;
     -r|--ram)
         RAM=true
      ;;
     -n|--new)
         NEW=true
      ;;
     -m|--modify)
         MODIFY=true
      ;;
     -r|--remove)
         REMOVE=true
      ;;
     -f|--from-disk)
         FROM_DISK=true
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

if [ ! -z $IP_ADDRESS ]
then
   echo '...'
fi

if [ ! -z $CLONE ]
then
   echo '...'
fi

if [ ! -z $DOMAIN ]
then
   echo '...'
fi

if [ ! -z $FS_SIZE ]
then
   echo '...'
fi

if [ ! -z $IMAGE ]
then
   echo '...'
fi

if [ ! -z $RAM ]
then
   echo '...'
fi

if [ ! -z $NEW ]
then
   echo '...'
fi

if [ ! -z $MODIFY ]
then
   echo '...'
fi

if [ ! -z $REMOVE ]
then
   echo '...'
fi

if [ ! -z $FROM_DISK ]
then
   echo '...'
fi
