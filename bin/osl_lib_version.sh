#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   version codes manipulation functions
##
## This file is meant to be sourced :
##    source osl_lib_version.sh


OSL_VERSION_MAX_PARTS=4

## total hat tip to : http://stackoverflow.com/a/3511118/587407
OSL_VERSION_compare()
{
	local raw_version_left=$1
	local raw_version_right=$2
	local difference_found=false
	
	IFS='.'
	## REM : -a = array, splitted along IFS
	typeset -a version_left=( $raw_version_left )
	typeset -a version_right=( $raw_version_right )
	typeset n diff

	for (( n=0; n<$OSL_VERSION_MAX_PARTS; n+=1 )); do
		diff=$((version_left[n]-version_right[n]))
		if [ $diff -ne 0 ] ; then
			[ $diff -le 0 ] && echo '-1' || echo '1'
			difference_found=true
			break
		fi
	done
	
	if [[ "$difference_found" == false ]]; then
		echo  '0'
	fi
	
	OSL_INIT_restore_default_IFS
}

OSL_VERSION_test_greater_or_equal()
{
	local tested_version=$1
	local reference_version=$2
	local return_value=1 ## false until found otherwise
	
	local comp_result=$(OSL_VERSION_compare $tested_version $reference_version)
	#echo "comparison result : $comp_result"
	if [[ $comp_result -ge 0 ]]; then
		## fine, it is
		#echo "ge OK"
		return_value=0
	fi
	
	return $return_value
}

OSL_VERSION_test_smaller_or_equal()
{
	local tested_version=$1
	local reference_version=$2
	local return_value=1 ## false until found otherwise
	
	local comp_result=$(OSL_VERSION_compare $tested_version $reference_version)
	#echo "comparison result : $comp_result"
	if [[ $comp_result -le 0 ]]; then
		## fine, it is
		#echo "le OK"
		return_value=0
	fi
	
	return $return_value
}

