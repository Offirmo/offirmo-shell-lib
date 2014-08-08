#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   version manipulation functions
##
## This file is meant to be sourced :
##    source osl_lib_semver.sh
##
## inspired from :
##    https://www.npmjs.org/doc/misc/semver.html

source osl_lib_version.sh


OSL_SEMVER_compute_next_incompatible_version()
{
	local current_version=$1
	local return_value=1 ## false until found otherwise

	## easy : just increase the first digit.
	## unless it's 0...

	local comp_result=$(OSL_SEMVER_compare $tested_version $reference_version)
	#echo "comparison result : $comp_result"
	if [[ $comp_result -lt 0 ]]; then
		## fine, it is
		#echo "le OK"
		return_value=0
	fi

	return $return_value
}
