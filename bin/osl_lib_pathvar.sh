#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   PATH-like variables manipulation functions
##
## This file is meant to be sourced :
##    source osl_lib_pathvar.sh




# try to prevent repetitive appends to some variables
# with "include" guards. But this is error prone because :
# - some things are inherited by subshells (env vars) and other are not (prompt, aliases)
# - so we should be careful about what to put in the guards or not.
# - it also can be useful to reset some vars to their default/good value when launching a subshell.
# So we use a special function instead :
# Note 1 : PLV means "path-like vars" and means a var containing a list of paths separated by ':'
# Note 2 : See examples of use below.
OSL_PATHVAR_check_if_PLV_contains_this_path()
{
	typeset var PLV="$1"
	typeset var path_to_check="$2"
	local return_code=1 # !0 = modif in progress by default
	
	# taken from http://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
	cmd="echo \"\$$PLV\" | tr ':' '\n' | grep -x -c \"$path_to_check\""
	#echo $cmd
	
	typeset var count=`eval $cmd`
	#echo "check_if_PLV_contains_this_path $PLV $path_to_check : $count"
	if [[ $count -ge 1 ]]; then
		return_code=0
	fi
	
	return $return_code
}



OSL_PATHVAR_append_to_PLV_if_not_already_there()
{
	typeset var PLV="$1"
	typeset var path_to_add=$2
	
	typeset var PLV_content
	eval PLV_content=\$$PLV
	#echo $PLV
	#echo $PLV_content
	
	OSL_PATHVAR_check_if_PLV_contains_this_path  "$PLV"  "$path_to_add"
	if [[ $? -eq 0 ]]; then
		# given path is already in the PLV
		#echo "(skipping append of \"$path_to_add\" to $PLV)"
		do_nothing=1
	else
		# given path is not in the PLV, add it :
		if [[ $PLV == "MANPATH" && "$PLV_content" == ":" ]]; then
			# this is the "append to MANPATH" special case (see above)
			eval export $PLV=$PLV_content$path_to_add # concat without separator
		elif [[ -z "$PLV_content" ]]; then
			# the current PLV is blank
			# don't use a separator, and use export
			eval export $PLV=$path_to_add
		else
			# append
			eval $PLV=\$$PLV:$path_to_add
		fi
	fi
}



OSL_PATHVAR_prepend_to_PLV_if_not_already_there()
{
	typeset var PLV="$1"
	typeset var path_to_add=$2
	
	typeset var PLV_content
	eval PLV_content=\$$PLV
	#echo $PLV
	#echo $PLV_content
	
	OSL_PATHVAR_check_if_PLV_contains_this_path  "$PLV"  "$path_to_add"
	if [[ $? -eq 0 ]]; then
		# given path is already in the PLV
		#echo "(skipping prepend of \"$path_to_add\" to $PLV)"
		do_nothing=1
	else
		# given path is not in the PLV, add it :
		if [[ -z "$PLV_content" ]]; then
			# the current PLV is blank, don't use a separator, and use export
			eval export $PLV=$path_to_add
		else
			# prepend
			eval $PLV=$path_to_add:\$$PLV
		fi
	fi
}
