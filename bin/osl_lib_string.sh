#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   string manipulation functions
##
## This file is meant to be sourced :
##    source osl_lib_string.sh


OSL_STRING_to_lower()
{
	echo "$*" | awk '{print tolower($0)}'
}

OSL_STRING_to_upper()
{
	echo "$*" | awk '{print toupper($0)}'
}

OSL_STRING_trim()
{
	## total hat tip to : http://stackoverflow.com/a/3352015/587407
	local var="$*"
	var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
	echo -n "$var"
}
