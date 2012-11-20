#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   -funcs to check current machine / OS capabilities
##
## This file is meant to be sourced :
##    source osl_lib_capabilities.sh

OSL_CAPABILITIES_internal_GetVersionFromFile()
{
	VERSION=`cat $1 | tr "\n" ' ' | sed s/.*VERSION.*=\ // `
}

OSL_CAPABILITIES_detect_current_linux_distribution()
{
	local return_code=0 # OK until found otherwise

	## taken and adapted from :
	## http://www.novell.com/coolsolutions/feature/11251.html
	## see also http://superuser.com/a/80256/112791
	## and http://serverfault.com/questions/3331/how-do-i-find-out-what-version-of-linux-is-running/3334#3334

	## note : the suffix letter is the short option name
	local uname_s=`uname --kernel-name`
	local uname_r=`uname --kernel-release`
	local uname_p=`uname --processor`
	
	OSL_CAPABILITIES_OS=$uname_s ## for now
	OSL_CAPABILITIES_REV=$uname_r ## for now
	OSL_CAPABILITIES_ARCH=$uname_p ## for now
	OSL_CAPABILITIES_PSEUDONAME=""
	OSL_CAPABILITIES_DIST=""
	OSL_CAPABILITIES_OSSTR=""
	OSL_CAPABILITIES_INFO_FILE=""

	if [ "$uname_s" = "SunOS" ] ; then
		OSL_CAPABILITIES_OS=Solaris
		OSL_CAPABILITIES_OSSTR="${OSL_CAPABILITIES_OS} $OSL_CAPABILITIES_REV (${OSL_CAPABILITIES_ARCH} `uname -v`)"
	elif [ "$uname_s" = "AIX" ] ; then
		OSL_CAPABILITIES_OSSTR="${OSL_CAPABILITIES_OS} `oslevel` (`oslevel -r`)"
	elif [ "$uname_s" = "Linux" ] ; then

		## We need more infos.
		## Systems use to have a file with details.
		## Some OS try to be standard, some have their own files.
		if [ -f /etc/lsb-release ] ; then
			## "linux standard base" http://www.linuxfoundation.org/collaborate/workgroups/lsb
			## File common to many linux distribs.
			OSL_CAPABILITIES_INFO_FILE="/etc/lsb-release"
			OSL_CAPABILITIES_DIST=`cat "$OSL_CAPABILITIES_INFO_FILE" | grep "DISTRIB_ID" | sed s/DISTRIB_ID=//`
			OSL_CAPABILITIES_PSEUDONAME=`cat "$OSL_CAPABILITIES_INFO_FILE" | grep "DISTRIB_CODENAME" | sed s/DISTRIB_CODENAME=//`
			OSL_CAPABILITIES_REV=`cat "$OSL_CAPABILITIES_INFO_FILE" | grep "DISTRIB_RELEASE" | sed s/DISTRIB_RELEASE=//`
		elif [ -f /etc/debian_version ] ; then
			OSL_CAPABILITIES_INFO_FILE="/etc/debian_version"
			OSL_CAPABILITIES_DIST="Debian"
			OSL_CAPABILITIES_REV="`cat "$OSL_CAPABILITIES_INFO_FILE"`"
			#OSL_CAPABILITIES_PSEUDONAME ?
		elif [ -f /etc/redhat-release ] ; then
			OSL_CAPABILITIES_INFO_FILE="/etc/redhat-release"
			OSL_CAPABILITIES_DIST='RedHat'
			OSL_CAPABILITIES_PSEUDONAME=`cat "$OSL_CAPABILITIES_INFO_FILE" | sed s/.*\(// | sed s/\)//`
			OSL_CAPABILITIES_REV=`cat "$OSL_CAPABILITIES_INFO_FILE" | sed s/.*release\ // | sed s/\ .*//`
		elif [ -f /etc/SUSE-release ] ; then
			OSL_CAPABILITIES_INFO_FILE="/etc/SUSE-release"
			OSL_CAPABILITIES_DIST=`cat "$OSL_CAPABILITIES_INFO_FILE" | tr "\n" ' '| sed s/VERSION.*//`
			OSL_CAPABILITIES_REV=`cat "$OSL_CAPABILITIES_INFO_FILE" | tr "\n" ' ' | sed s/.*=\ //`
			#OSL_CAPABILITIES_PSEUDONAME ?
		elif [ -f /etc/mandrake-release ] ; then
			OSL_CAPABILITIES_INFO_FILE="/etc/mandrake-release"
			OSL_CAPABILITIES_DIST='Mandrake'
			OSL_CAPABILITIES_PSEUDONAME=`cat "$OSL_CAPABILITIES_INFO_FILE" | sed s/.*\(// | sed s/\)//`
			OSL_CAPABILITIES_REV=`cat "$OSL_CAPABILITIES_INFO_FILE" | sed s/.*release\ // | sed s/\ .*//`
		elif [ -f /etc/UnitedLinux-release ] ; then
			OSL_CAPABILITIES_INFO_FILE="/etc/UnitedLinux-release"
			OSL_CAPABILITIES_DIST="${OSL_CAPABILITIES_DIST}[`cat "$OSL_CAPABILITIES_INFO_FILE" | tr "\n" ' ' | sed s/VERSION.*//`]"
		fi
		
		OSL_CAPABILITIES_OSSTR="$uname_s ${OSL_CAPABILITIES_DIST} ${OSL_CAPABILITIES_REV} (${OSL_CAPABILITIES_PSEUDONAME} $uname_r `uname -m`)"
	fi

	return $return_code
}


OSL_CAPABILITIES_ensure_current_linux_distribution_detected()
{
	if [[ -z "$OSL_CAPABILITIES_OS_DISTRIBUTION_DETECTED" ]]; then
		OSL_CAPABILITIES_OS_DISTRIBUTION_DETECTED=true
		OSL_CAPABILITIES_detect_current_linux_distribution
		return $?
	else
		return 0
	fi
}


OSL_CAPABILITIES_is_debian_based()
{
	local result=false ## by default
	OSL_CAPABILITIES_ensure_current_linux_distribution_detected
	case $OSL_CAPABILITIES_DIST in
	"Debian")
		result=true
		;;
	"Ubuntu")
		result=true
		;;
	*)
		do_nothing=1
		;;
	esac
	echo $result
}


OSL_CAPABILITIES_has_apt()
{
	OSL_CAPABILITIES_is_debian_based
}
