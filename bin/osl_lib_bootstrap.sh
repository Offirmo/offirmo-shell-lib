#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## XXX this script is special XXX
## When sourced, it attempts to detect if another copy of OSL is already in the path.
## - If not, it setup the path to point at this copy
## - If yes, it checks version and select between the two
##
## This file is meant to be sourced EXPLICITELY WITH FULL PATH + PARAM:
##    source "xyz/osl_lib_bootstrap.sh" "xyz/osl_lib_bootstrap.sh"

## inspect current script url
## to find current OSL dir
echo "current file (explicitely given) is : $1" ## REM this script path should be given as a script !
script_full_path=`readlink -f "$1"`
echo "script_full_path set to $script_full_path"
script_full_dir=`dirname "$script_full_path"`
echo "script_full_dir  set to $script_full_dir"

## detect an existing OSL
installed_osl_version_script_path=`which 'osl_version.sh' 2> /dev/null`
if [[ $? -eq 0 ]]; then
	## an OSL is in the path
	echo "installed OSL found ! ($installed_osl_version_script_path)"
	## is it ourself ?
	## first rationalize the path
	installed_osl_version_script_path=`readlink -f "$installed_osl_version_script_path"`
	## and check
	if [[ "$installed_osl_version_script_path" == "$script_full_dir/osl_version.sh" ]]; then
		## yes it's ourself : just load it !
		echo "(this is ourself :)"
	else
		## the installed OSL is not us
		## refine path
		installed_osl_copy_bin_path=`dirname "$installed_osl_version_script_path"`
		echo "OSL copy found in : $installed_osl_copy_bin_path"
		## get versions
		sourced_osl_version=`$script_full_dir/osl_version.sh`
		installed_osl_version=`$installed_osl_copy_bin_path/osl_version.sh`
		echo "versions found : sourced = $sourced_osl_version, installed = $installed_osl_version"
		## compare versions
		## (we must use a copy of osl_lib_version)
		difference_found=false
		OIFS="$IFS"
		IFS='.'
		## REM : -a = array, splitted along IFS
		typeset -a version_left=( $sourced_osl_version )
		typeset -a version_right=( $installed_osl_version )
		typeset n diff

		for (( n=0; n<4; n+=1 )); do
			diff=$((version_left[n]-version_right[n]))
			if [ $diff -ne 0 ] ; then
				[ $diff -le 0 ] && latest_osl="installed" || latest_osl="sourced"
				difference_found=true
				break
			fi
		done
		IFS="$OIFS"
		if [[ "$difference_found" == false ]]; then
			echo  '(OSL versions are the same)'
			## just keep using the one in path
		else
			echo "using latest : $latest_osl"
			if [[ "$latest_osl" == "installed" ]]; then
				## just keep using the one in path
				do_nothing=1
			else
				## alter path to give precedence to embedded OSL
				## sorry, we have to add ourself in front
				export PATH="$script_full_dir:$PATH"
				echo "PATH set to $PATH"
			fi
		fi
	fi
else
	## no other copy is in the path
	echo "No OSL found."
	## set it up (be polite and put it at the end)
	export PATH="$PATH:$script_full_dir"
	echo "PATH set to $PATH"
fi

## done
