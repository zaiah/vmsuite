#!/bin/bash - 
#===============================================================================
#
#          FILE:  _vm-skeleton.sh
# 
#         USAGE:  source _vm-skeleton.sh
# 
#   DESCRIPTION:  A skeleton for all the different types of data we have.
# 
#        AUTHOR: Antonio Ramar Collins II (), zaiah.dj@gmail.com, ramar.collins@gmail.com
#       COMPANY: Vokay Ent. (vokayent@gmail.com)
#       CREATED: 05/18/2012 09:34:04 PM EDT
#      REVISION:  ---
#===============================================================================

#===============================================================================
# Convention:
# 
# Normal names are defined as usual.
# Locals are preceded with _ (there are none here however...)
# 
#===============================================================================

skeleton() {
cat <<EOF
# Virtual Machine Details
vmname=
ram=
ostype=
nics=					# Specify multiple nics with integer
nicTypes=			# Type of NIC (hostonly, nat, bridged, intnet, none, null)
hdd=					# Size
hddType=				# Hard Drive Type
iso=

# IP & Name Resolution
hostname=
domain=
public_ip=
netmask=
broadcast=
gateway=
nameservers=

# Secure Access
sshPort=
sshKey=

# Users 
userMain=
userMySQL=
userPGSQL=
userSSH=

# Directories
dirDevelopment=			# Development directory for your project to rsync the two...
dirStaging=				
dirProduction=

# Databases
db=

# Software
mysql=yes
pgsql=
monitor=munin

EOF
}
