#! /bin/bash

## Offirmo Shell Library
## http://
##
## This file defines :
##   - method for shell mutexes
##
## This file is meant to be sourced :
##    source osl_lib_mutex.sh

## osl_lib_init is supposed to be already sourced
source osl_lib_output.sh


## Note :
## Shell mutexes are not trivial : http://stackoverflow.com/questions/185451/quick-and-dirty-way-to-ensure-only-one-instance-of-a-shell-script-is-running-at

## I choose for now a non-reentrant NFS compatible solution, using "lockfile"

OSL_MUTEX_SUFFIX=".lock"
OSL_MUTEX_LOCKFILE_LOCKTIMEOUT=900 # 1/4 hour

OSL_MUTEX_internal_init_vars()
{
	echo "[initializing mutexes...]"

	OSL_MUTEX_unreleased_mutexes=""
}
if [[ -z "$OSL_MUTEX_VARS_INITED" ]]; then
	OSL_MUTEX_internal_init_vars
	OSL_MUTEX_VARS_INITED=true
fi


OSL_MUTEX_acquire()
{
	local return_code=1 # !0 = error by default
	
	local lock_dir=$1
	local rsrc_id=$2

	local lock_file=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX

	lockfile -r0 -l $OSL_MUTEX_LOCKFILE_LOCKTIMEOUT "$lock_file" 2>&1 > /dev/null
	return_code=$?

	if [[ $return_code -eq 0 ]]; then
		echo "[mutex acquisition success for $rsrc_id]"
		OSL_MUTEX_unreleased_mutexes="$OSL_MUTEX_unreleased_mutexes|$lock_file"
	else
		echo "[mutex acquisition FAILED for $rsrc_id]"
	fi
		
	echo "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"

	return $return_code
}


OSL_MUTEX_release()
{
	local return_code=1 # !0 = error by default
	
	local lock_dir=$1
	local rsrc_id=$2

	local lock_file=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX

	rm -f "$lock_file"
	return_code=$?

	echo "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"

	if [[ $return_code -eq 0 ]]; then
		echo "[mutex release success for $rsrc_id]"
		## TODO
	else
		echo "[mutex release FAILED for $rsrc_id]"
	fi
	
	return $return_code
}


OSL_MUTEX_force_acquire()
{
	local return_code=1 # !0 = error by default
	
	local lock_dir=$1
	local rsrc_id=$2

	local lock_file=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX

	## experience : locktimeout of 0 is not allowed
	lockfile -r0 -l 1 -s 1 "$lock_file" 2>&1 > /dev/null
	return_code=$?

	if [[ $return_code -eq 0 ]]; then
		echo "[mutex forced acquisition success for $rsrc_id]"
		OSL_MUTEX_unreleased_mutexes="$OSL_MUTEX_unreleased_mutexes|$lock_file"
	else
		echo "[mutex forced acquisition FAILED for $rsrc_id]"
	fi
		
	echo "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"

	return $return_code
}

