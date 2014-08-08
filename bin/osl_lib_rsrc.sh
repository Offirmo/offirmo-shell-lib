#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - method for asfely creating and writing/reading rsrcs
##     with concurrency detection and "clean" status detection
##
## This file is meant to be sourced :
##    source osl_lib_rsrc.sh

## osl_lib_init is supposed to be already sourced

## This lib is built upon those two :
source osl_lib_stamp.sh
source osl_lib_mutex.sh





## Check if the rsrc is ready,
## i.e. properly initialized and not currently being modified
OSL_RSRC_check()
{
	local control_dir="$1"
	local rsrc_id="$2"
	local return_code=1 # !0 = error by default

	OSL_STAMP_check_rsrc_ok "$control_dir" "$rsrc_id"
	return_code=$?

	return $return_code
}


OSL_RSRC_cleanup()
{
	local control_dir="$1"
	local rsrc_id="$2"
	local return_code=1 # !0 = error by default

	OSL_STAMP_delete_rsrc_stamps "$control_dir" "$rsrc_id"
	OSL_MUTEX_cleanup "$control_dir" "$rsrc_id"
	return_code=$? # don't really care for this func

	return $?
}


## will forcefully take any lock
OSL_RSRC_force_begin_managed_write_operation()
{
	local control_dir="$1"
	local rsrc_id="$2"
	local caller_info="$3"
	local return_code=1 # !0 = error by default

	OSL_MUTEX_force_lock "$control_dir" "$rsrc_id" "$caller_info"
	return_code=$?

	if [[ $return_code -eq 0 ]]; then
		OSL_STAMP_begin_managed_write_operation "$control_dir" "$rsrc_id" "$caller_info"
		return_code=$?
		OSL_RSRC_state=$OSL_STAMP_last_managed_operation_modif_date
		if [[ $return_code -ne 0 ]]; then
			OSL_MUTEX_unlock "$control_dir" "$rsrc_id"
		fi
	fi

	return $return_code
}


## normal, will wait if lock is held
OSL_RSRC_begin_managed_write_operation()
{
	local control_dir="$1"
	local rsrc_id="$2"
	local caller_info="$3"
	local return_code=1 # !0 = error by default

	OSL_MUTEX_lock "$control_dir" "$rsrc_id" "$caller_info"
	return_code=$?

	if [[ $return_code -eq 0 ]]; then
		OSL_STAMP_begin_managed_write_operation "$control_dir" "$rsrc_id" "$caller_info"
		return_code=$?
		OSL_RSRC_state=$OSL_STAMP_last_managed_operation_modif_date
		if [[ $return_code -ne 0 ]]; then
			OSL_MUTEX_unlock "$control_dir" "$rsrc_id"
		fi
	fi

	return $return_code
}


## will not wait if lock is held
OSL_RSRC_try_managed_write_operation()
{
	local control_dir="$1"
	local rsrc_id="$2"
	local caller_info="$3"
	local return_code=1 # !0 = error by default

	OSL_MUTEX_trylock "$control_dir" "$rsrc_id" "$caller_info"
	return_code=$?

	if [[ $return_code -eq 0 ]]; then
		OSL_STAMP_begin_managed_write_operation "$control_dir" "$rsrc_id" "$caller_info"
		return_code=$?
		OSL_RSRC_state=$OSL_STAMP_last_managed_operation_modif_date
		if [[ $return_code -ne 0 ]]; then
			OSL_MUTEX_unlock "$control_dir" "$rsrc_id"
		fi
	fi

	return $return_code
}


OSL_RSRC_end_managed_write_operation()
{
	local control_dir="$1"
	local rsrc_id="$2"
	local return_code=1 # !0 = error by default

	## assume we have the lock
	OSL_STAMP_last_managed_operation_modif_date=$OSL_RSRC_state
	OSL_STAMP_end_managed_write_operation "$control_dir" "$rsrc_id"
	return_code=$?
	OSL_MUTEX_unlock "$control_dir" "$rsrc_id"
	# don't care about mutex for this op

	return $return_code
}


OSL_RSRC_end_managed_write_operation_with_error()
{
	local control_dir="$1"
	local rsrc_id="$2"

	## stamps : do nothing. Sufficient for now to leave the stamps in a bad state

	OSL_MUTEX_unlock "$control_dir" "$rsrc_id"
	# don't care about mutex for this op

	return 0
}


OSL_RSRC_begin_managed_read_operation()
{
	local control_dir="$1"
	local rsrc_id="$2"
	local return_code=1 # !0 = error by default

	## no mutex
	OSL_STAMP_begin_managed_read_operation "$control_dir" "$rsrc_id"
	return_code=$?
	OSL_RSRC_state=$OSL_STAMP_last_managed_operation_modif_date

	return $return_code
}


OSL_RSRC_end_managed_read_operation()
{
	local control_dir="$1"
	local rsrc_id="$2"
	local return_code=1 # !0 = error by default

	OSL_STAMP_last_managed_operation_modif_date=$OSL_RSRC_state
	OSL_STAMP_end_managed_read_operation "$control_dir" "$rsrc_id"
	return_code=$?

	return $return_code
}
