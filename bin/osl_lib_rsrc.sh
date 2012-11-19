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
	local control_dir=$1
	local rsrc_id=$2

	OSL_STAMP_check_rsrc_ok "$control_dir" "$rsrc_id"
	return $?
}


OSL_RSRC_cleanup()
{
	local control_dir=$1
	local rsrc_id=$2

	OSL_STAMP_delete_rsrc_stamps "$control_dir" "$rsrc_id"
	return $?
}


OSL_RSRC_begin_managed_write_operation()
{
	local control_dir=$1
	local rsrc_id=$2

	OSL_STAMP_begin_managed_write_operation "$control_dir" "$rsrc_id"
	return $?
}


OSL_RSRC_end_managed_write_operation()
{
	local control_dir=$1
	local rsrc_id=$2

	OSL_STAMP_end_managed_write_operation "$control_dir" "$rsrc_id"
	return $?
}


OSL_RSRC_end_managed_write_operation_with_error()
{
	local control_dir=$1
	local rsrc_id=$2

	## do nothing. Sufficient for now.
}


OSL_RSRC_begin_managed_read_operation()
{
	local control_dir=$1
	local rsrc_id=$2

	OSL_STAMP_begin_managed_read_operation "$control_dir" "$rsrc_id"
	return $?
}


OSL_RSRC_end_managed_read_operation()
{
	local control_dir=$1
	local rsrc_id=$2

	OSL_STAMP_end_managed_read_operation "$control_dir" "$rsrc_id"
	return $?
}
