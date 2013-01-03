#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - method for shell mutexes
##
## This file is meant to be sourced :
##    source osl_lib_mutex.sh

## osl_lib_init is supposed to be already sourced
source osl_lib_output.sh
source osl_lib_debug.sh
source osl_lib_file.sh
source osl_lib_interrupt_func.sh

## Note :
## Shell mutexes are not trivial : http://stackoverflow.com/questions/185451/quick-and-dirty-way-to-ensure-only-one-instance-of-a-shell-script-is-running-at


if [[ -z "$OSL_MUTEX_METHOD" ]]; then
	which lockfile 2>&1 > /dev/null
	if [[ $? -eq 0 ]]; then
		## `lockfile` is available, use, it's the best method
		OSL_debug "  --> using 'lockfile' for mutexes..."
		OSL_MUTEX_METHOD='lockfile'
	else
		OSL_debug "  --> using 'symlink' for mutexes..."
		OSL_MUTEX_METHOD='symlink'
	fi
fi
## I choose for now a non-reentrant NFS compatible solution, using "lockfile"

OSL_MUTEX_SUFFIX=".lock"

## timing
if [[ -z "$OSL_MUTEX_LOCKFILE_RETRY_WAIT_TIME" ]]; then
	OSL_MUTEX_LOCKFILE_RETRY_WAIT_TIME=3
fi
if [[ -z "$OSL_MUTEX_LOCKFILE_RETRY_MAX_COUNT" ]]; then
	OSL_MUTEX_LOCKFILE_RETRY_MAX_COUNT=300
fi
## total 300 x 3sec = 900s = 1/4h


OSL_MUTEX_internal_init_vars()
{
	OSL_debug "initializing internal mutexes variables..."

	OSL_MUTEX_unreleased_mutexes=""
}
if [[ -z "$OSL_MUTEX_VARS_INITED" ]]; then
	OSL_MUTEX_internal_init_vars
	OSL_MUTEX_VARS_INITED=true
fi


OSL_MUTEX_lock()
{
	local lock_dir=$1
	local rsrc_id=$2
	local caller_info=$3
	local return_code=1 # !0 = error by default

	case $OSL_MUTEX_METHOD in
	'lockfile')
		OSL_MUTEX_lock_with_lockfile_method "$lock_dir" "$rsrc_id" "$caller_info"
		return_code=$?
		;;
	'symlink')
		OSL_MUTEX_lock_with_symlink_method "$lock_dir" "$rsrc_id" "$caller_info"
		return_code=$?
		;;
	*)
		OSL_OUTPUT_display_error_message "mutex method internal error"
		;;
	esac

	return $return_code
}


OSL_MUTEX_trylock()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default

	case $OSL_MUTEX_METHOD in
	'lockfile')
		OSL_MUTEX_trylock_with_lockfile_method $lock_dir $rsrc_id
		return_code=$?
		;;
	'symlink')
		OSL_MUTEX_trylock_with_symlink_method $lock_dir $rsrc_id
		return_code=$?
		;;
	*)
		OSL_OUTPUT_display_error_message "mutex method internal error"
		;;
	esac

	return $return_code
}


OSL_MUTEX_unlock()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default

	case $OSL_MUTEX_METHOD in
	'lockfile')
		OSL_MUTEX_unlock_with_lockfile_method $lock_dir $rsrc_id
		return_code=$?
		;;
	'symlink')
		OSL_MUTEX_unlock_with_symlink_method $lock_dir $rsrc_id
		return_code=$?
		;;
	*)
		OSL_OUTPUT_display_error_message "mutex method internal error"
		;;
	esac
	
	return $return_code
}


OSL_MUTEX_force_lock()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default

	case $OSL_MUTEX_METHOD in
	'lockfile')
		OSL_MUTEX_force_lock_with_lockfile_method $lock_dir $rsrc_id
		return_code=$?
		;;
	'symlink')
		OSL_MUTEX_force_lock_with_symlink_method $lock_dir $rsrc_id
		return_code=$?
		;;
	*)
		OSL_OUTPUT_display_error_message "mutex method internal error"
		;;
	esac
	
	return $return_code
}




OSL_MUTEX_cleanup()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default

	case $OSL_MUTEX_METHOD in
	'lockfile')
		OSL_MUTEX_cleanup_with_lockfile_method $lock_dir $rsrc_id
		return_code=$?
		;;
	'symlink')
		OSL_MUTEX_cleanup_with_symlink_method $lock_dir $rsrc_id
		return_code=$?
		;;
	*)
		OSL_OUTPUT_display_error_message "mutex method internal error"
		;;
	esac
	
	return $return_code
}






#############################################################
#############################################################
#############################################################
#############################################################






OSL_MUTEX_lock_with_lockfile_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default

	local lock_file=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX
	
	OSL_debug "attempting blocking lock on $lock_file..."

	## we don't use integrated retry feature to be able to display a message
	local try_count=0
	while :
    do
    	# retry = 1 to wait at last one time
		lockfile -$OSL_MUTEX_LOCKFILE_RETRY_WAIT_TIME -r 1 "$lock_file" 2>&1 > /dev/null
		return_code=$?
    	try_count=$(expr $try_count + 1) ## 1 wait and two tests
		[[ $return_code -eq 0 ]] && break
		if [[ $try_count -ge $OSL_MUTEX_LOCKFILE_RETRY_MAX_COUNT ]]; then
			break
		else
			LOCK_OWNER=`stat -c "%U %y" "$lock_file" 2> /dev/null | awk -F"." '{ print $1 }'`
			echo "still trying to acquire mutex for \"$rsrc_id\" held by : $LOCK_OWNER..."
		fi
	done

	if [[ $return_code -eq 0 ]]; then
		OSL_debug "  --> mutex acquisition success for $rsrc_id"
		#OSL_MUTEX_unreleased_mutexes="$OSL_MUTEX_unreleased_mutexes|$lock_file"
	else
		OSL_debug "  --> mutex acquisition FAILED for $rsrc_id"
	fi
		
	#OSL_debug "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"

	return $return_code
}


OSL_MUTEX_trylock_with_lockfile_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default
	
	local lock_file=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX

	OSL_debug "attempting non-blocking lock on $lock_file..."

	lockfile -0 -r 0 "$lock_file" 2>&1 > /dev/null
	return_code=$?

	if [[ $return_code -eq 0 ]]; then
		OSL_debug "  --> mutex non-blocking acquisition success for $rsrc_id"
		#OSL_MUTEX_unreleased_mutexes="$OSL_MUTEX_unreleased_mutexes|$lock_file"
	else
		OSL_debug "  --> mutex non-blocking acquisition FAILED for $rsrc_id"
	fi

	return $return_code
}


OSL_MUTEX_unlock_with_lockfile_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default

	local lock_file=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX

	#OSL_debug "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"
	OSL_debug "unlocking $lock_file..."

	rm -f "$lock_file"
	return_code=$?

	if [[ $return_code -eq 0 ]]; then
		OSL_debug "  --> mutex release success for $rsrc_id"
		## TODO
	else
		OSL_debug "  --> mutex release FAILED for $rsrc_id"
	fi
	
	return $return_code
}


OSL_MUTEX_force_lock_with_lockfile_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default
	
	local lock_file=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX
	
	OSL_debug "attempting force lock on $lock_file..."
	
	## experience : locktimeout of 0 is not allowed
	rm -f "$lock_file"
	lockfile -0 -r 0 -l 1 -s 1 "$lock_file" 2>&1 > /dev/null
	return_code=$?
	
	if [[ $return_code -eq 0 ]]; then
		OSL_debug "  --> mutex forced acquisition success for $rsrc_id"
		#OSL_MUTEX_unreleased_mutexes="$OSL_MUTEX_unreleased_mutexes|$lock_file"
	else
		OSL_debug "  --> mutex forced acquisition FAILED for $rsrc_id"
	fi
	
	#OSL_debug "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"
	
	return $return_code
}




OSL_MUTEX_cleanup_with_lockfile_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default
	
	local lock_file=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX
	
	rm -f "$lock_file"
	return_code=$?
	
	return $return_code
}









#############################################################
#############################################################
#############################################################
#############################################################
## http://stackoverflow.com/a/327991/587407






OSL_MUTEX_lock_with_symlink_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local caller_info=$3
	local return_code=1 # !0 = error by default

	local lock_link=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX
	
	OSL_debug "[MUTEX] attempting blocking lock on $lock_link..."

	## we don't use integrated retry feature to be able to display a message
	local try_count=0
	while :
    do
    	ln -s -T "$lock_dir" "$lock_link"  2> /dev/null
		return_code=$?
    	try_count=$(expr $try_count + 1) ## 1 wait and two tests
		[[ $return_code -eq 0 ]] && break
		if [[ $try_count -ge $OSL_MUTEX_LOCKFILE_RETRY_MAX_COUNT ]]; then
			break
		else
			echo "still trying to acquire mutex for \"$rsrc_id\"..."
			OSL_debug "Mutex is \"$(OSL_FILE_abspath "$lock_link")\", additional info : $caller_info"
			sleep $OSL_MUTEX_LOCKFILE_RETRY_WAIT_TIME
		fi
	done

	if [[ $return_code -eq 0 ]]; then
		OSL_debug "[MUTEX]   --> mutex acquisition success for $rsrc_id"
		#OSL_MUTEX_unreleased_mutexes="$OSL_MUTEX_unreleased_mutexes|$lock_link"
	else
		OSL_debug "[MUTEX]   --> mutex acquisition FAILED for $rsrc_id"
	fi
		
	#OSL_debug "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"

	return $return_code
}


OSL_MUTEX_trylock_with_symlink_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default
	
	local lock_link=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX

	OSL_debug "[MUTEX] attempting non-blocking lock on $lock_link..."

	ln -s -T "$lock_dir" "$lock_link"  2> /dev/null
	return_code=$?

	if [[ $return_code -eq 0 ]]; then
		OSL_debug "[MUTEX]   --> mutex non-blocking acquisition success for $rsrc_id"
		#OSL_MUTEX_unreleased_mutexes="$OSL_MUTEX_unreleased_mutexes|$lock_link"
	else
		OSL_debug "[MUTEX]   --> mutex non-blocking acquisition FAILED for $rsrc_id"
	fi

	return $return_code
}


OSL_MUTEX_unlock_with_symlink_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default

	local lock_link=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX

	#OSL_debug "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"
	OSL_debug "[MUTEX] unlocking $lock_link..."

	[ -h "$lock_link" ] && mv "$lock_link" "$lock_link.deleteme"
	rm -f "$lock_link.deleteme"
	return_code=$?

	[ -h "$lock_link" ] && echo "XXX strange, mutex is still here ??!?!"
	rm -f "$lock_link"

	if [[ $return_code -eq 0 ]]; then
		OSL_debug "[MUTEX]   --> mutex release success for $rsrc_id"
		## TODO
	else
		OSL_debug "[MUTEX]   --> mutex release FAILED for $rsrc_id"
	fi
	
	return $return_code
}


OSL_MUTEX_force_lock_with_symlink_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default
	
	local lock_link=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX
	
	OSL_debug "[MUTEX] attempting force lock on $lock_link..."
	
	[ -e "$lock_link" ] && mv "$lock_link" "$lock_link.deleteme"
	rm -f "$lock_link.deleteme"
	ln -s "$lock_dir" "$lock_link"
	return_code=$?
	
	if [[ $return_code -eq 0 ]]; then
		OSL_debug "[MUTEX]   --> mutex forced acquisition success for $rsrc_id"
		#OSL_MUTEX_unreleased_mutexes="$OSL_MUTEX_unreleased_mutexes|$lock_link"
	else
		OSL_debug "[MUTEX]   --> mutex forced acquisition FAILED for $rsrc_id"
	fi
	
	#OSL_debug "mutexes currently held : $OSL_MUTEX_unreleased_mutexes"
	
	return $return_code
}




OSL_MUTEX_cleanup_with_symlink_method()
{
	local lock_dir=$1
	local rsrc_id=$2
	local return_code=1 # !0 = error by default
	
	local lock_link=$lock_dir/$rsrc_id$OSL_MUTEX_SUFFIX
	
	[ -e "$lock_link" ] && mv "$lock_link" "$lock_link.deleteme"
	rm -f "$lock_link.deleteme"
	return_code=$?
	
	return $return_code
}
