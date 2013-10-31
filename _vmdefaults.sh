#!/bin/bash - 
#===============================================================================
#
#          FILE:  _vmdefaults.sh
# 
#         USAGE:  source ./_vmdefaults.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Antonio Ramar Collins II (), zaiah.dj@gmail.com, ramar.collins@gmail.com
#       COMPANY: Vokay Ent. (vokayent@gmail.com)
#       CREATED: 07/01/2012 06:50:55 PM EDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

#====================================
# OPTIONS
#====================================

#====================================
# VARIABLES 
#====================================

#====================================
# FUNCTIONS 
#====================================

# Global config
ISO_DIR="$HOME/vm/iso"
__EDITOR="vim"

# Virtual Machine Details
RAM_DEFAULT=128
OS_TYPE_DEFAULT="linux"
NICS_DEFAULT=2					# Specify multiple NICS_ with integer
NIC_TYPES_DEFAULT=(nat)		# Type of NIC (hostonly, nat, bridged, intnet, none, null)
HDD_DEFAULT=10000				# Size (in MB)
HDD_TYPE_DEFAULT="ide"		# Hard Drive Type

# IP & Name Resolution
hostnameDEFAULT=
domainDEFAULT=
public_ipDEFAULT=
netmaskDEFAULT=
broadcastDEFAULT=
gatewayDEFAULT=
nameserversDEFAULT=

# Secure Access
sshPortDEFAULT=
sshKeyDEFAULT=

# Users 
userMainDEFAULT=
userMySQLDEFAULT=
userPGSQLDEFAULT=
userSSHDEFAULT=

# Directories
dirDevelopmentDEFAULT=			# Development directory for your project to rsync the two...
dirStagingDEFAULT=				
dirProductionDEFAULT=

# Databases
dbDEFAULT=

# Software
mysqlDEFAULT=
pgsqlDEFAULT=
monitorDEFAULT=
