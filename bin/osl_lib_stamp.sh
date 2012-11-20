#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - method for creating and checking stamp files
##
## This file is meant to be sourced :
##    source osl_lib_stamp.sh

## osl_lib_init is supposed to be already sourced
source osl_lib_output.sh
source osl_lib_debug.sh


####### basic stamp functions #######

## check if a stamp exists and init it if needed
## also create parent dir if needed
## give ability to create stamp with old date
## useuful for some apps
OSL_STAMP_ensure_stamp()
{
	local stamp_file=$1
	local oldest_mode=$2

	OSL_INIT_ensure_dir `dirname $stamp_file`
	if [[ -f "$stamp_file" ]]; then
		# stamp exists, leave it untouched
		do_nothing=1
	else
		if [[ -n $oldest_mode ]]; then
			# init it with the oldest possible date
			touch -t 197101010000 "$stamp_file"
		else
			# create it with the current date
			OSL_STAMP_touch_stamps "$stamp_file"
		fi
	fi

	return 0
}


# retrieve the timestamp of a stamp
# example :
# echo "date = $(OSL_STAMP_stamp_date "toto.stamp")
OSL_STAMP_stamp_date()
{
	local stamp_file=$1
	stat -c %y "$stamp_file"
}


####### advanced stamp functions #######
## With a pair of stamps,
## we may detect if a work is in progress or not.

## For a specified "resource"
## We create two stamps :
## - a "last modification" stamp
## - a "modification finished" stamp.
##
## A script must touch the "last modification stamp"
## as soon as it starts to alter the resource.
## A script must touch *both* stamps
## when it finishes to alter the resource.
##
## With the "last modification" stamp, a script can detect if the ressource
## was modified since it began to access it.
## With the "modification finished" stamp, a script may detect if an operation
## is pending or was aborted on the ressource :
## - if both stamps have the same date, then last operation finished correctly
## - if stamps have a different date, it could mean either :
##   - that an operation is in progress
##   - that an operation was aborted before completion
##   in both cases, access to the resource should be aborted.
##
## Note: obviously, for race conditions, access to those stamps
## should be coupled with a lock. This is done in functions from "OSL mutex" lib.



OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX=".last_mod.stamp"
OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX=".last_eoo.stamp"


## init the stamp pair for a given rsrc
OSL_STAMP_internal_init_managed_rsrc_stamps()
{
	local stamp_dir=$1
	local rsrc_id=$2

	local last_modif_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX
	local modif_finished_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX

	#OSL_debug "[OSL_STAMP] creating \"$stamp_dir/$rsrc_id\" stamps..."
	
	## if stamps don't exist, they will be created
	## use old mode to ensure different dates, which is ok because
	## it means that rsrc is not ready (not initialized)
	OSL_STAMP_ensure_stamp "$last_modif_stamp_file" to_oldest_possible_date
	OSL_STAMP_ensure_stamp "$modif_finished_stamp_file"
	
	return 0
}


## A func to touch a stamp.
## To be reliable, we must hack a little bit
OSL_STAMP_touch_stamps()
{
	local stamp_1=$1
	local stamp_2=$2

	touch "$stamp_1"
	## problem : it seems that
	##   touch foo
	## and
	##   touch --reference "foo" "bar"
	## have different resolutions on a RAM fs (seen by experience)
	## so we use --reference on oneself for the first stamp to give him the same rounding
	touch --reference "$stamp_1" "$stamp_1"
	
	## we can now safely proceed with the second stamp (if any)
	if [[ -n "$stamp_2" ]]; then
		touch --reference "$stamp_1" "$stamp_2"
	fi
	
	return $?
}


## Check if the rsrc is ready,
## i.e. properly initialized and not currently being modified
OSL_STAMP_check_rsrc_ok()
{
	local return_code=1 # !0 = modif in progress by default
	## just in case
	OSL_STAMP_internal_init_managed_rsrc_stamps "$1" "$2"

	local stamp_dir=$1
	local rsrc_id=$2

	local last_modif_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX
	local modif_finished_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX

	local last_modification_date=$(OSL_STAMP_stamp_date "$last_modif_stamp_file")
	local end_of_modification_date=$(OSL_STAMP_stamp_date "$modif_finished_stamp_file")

	OSL_debug "[OSL_STAMP] comparing stamp dates for rsrc \"$rsrc_id\" : $last_modification_date == $end_of_modification_date ?"
	
	if [[ "$last_modification_date" == "$end_of_modification_date" ]]; then
		## it seems that no operation is in progress
		## at the time of this test
		OSL_debug "[OSL_STAMP] -> comparison OK (equality) seems no op in progress."
		return_code=0
	else
		OSL_debug "[OSL_STAMP] -> comparison NOK (inequality) seems unfinished op."
	fi

	return $return_code
}


## delete the stamp pair for a given rsrc
## useful in special cases or for cleanups
OSL_STAMP_delete_rsrc_stamps()
{
	local stamp_dir=$1
	local rsrc_id=$2

	local last_modif_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX
	local modif_finished_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX

	rm -f "$last_modif_stamp_file" "$modif_finished_stamp_file"
	
	return 0
}


OSL_STAMP_last_managed_operation_modif_date="" # state/return var, do not modify !
OSL_STAMP_begin_managed_write_operation()
{
	## just in case
	OSL_STAMP_internal_init_managed_rsrc_stamps "$1" "$2"

	local stamp_dir=$1
	local rsrc_id=$2

	local last_modif_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX
	local modif_finished_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX

	## no check of current state.
	## If it's not OK, it could be because a previous operation was interrupted
	## and this call may be here to fix the rsrc.
	## So there is no use to check stamp state.
	
	## force stamp modification
	OSL_STAMP_touch_stamps "$last_modif_stamp_file"

	## and store the date
	OSL_STAMP_last_managed_operation_modif_date=$(OSL_STAMP_stamp_date "$last_modif_stamp_file")
	
	OSL_debug "[OSL_STAMP] beginning managed write of rsrc \"$rsrc_id\" on $OSL_STAMP_last_managed_operation_modif_date..."

	return 0
}


OSL_STAMP_end_managed_write_operation()
{
	local return_code=1 # !0 = error by default
	
	## just in case
	OSL_STAMP_internal_init_managed_rsrc_stamps "$1" "$2"

	local stamp_dir=$1
	local rsrc_id=$2

	local last_modif_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX
	local modif_finished_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX

	local expected_last_modif_date=$OSL_STAMP_last_managed_operation_modif_date
	local actual_last_modif_date=$(OSL_STAMP_stamp_date "$last_modif_stamp_file")

	if [[ "$actual_last_modif_date" == "$expected_last_modif_date" ]]; then
		## fine, no one touched the last modif stamp.
		## so WE touch it to show that current state is no longer what it was at the beginning
		## and also touch "done" stamp to record completion date
		OSL_STAMP_touch_stamps "$last_modif_stamp_file" "$modif_finished_stamp_file"
		return_code=$?
		OSL_debug "[OSL_STAMP] ending managed write of rsrc \"$rsrc_id\" on $(OSL_STAMP_stamp_date "$last_modif_stamp_file")/$(OSL_STAMP_stamp_date "$modif_finished_stamp_file") properly."
	else
		## state changed by someone else while we where writing !
		## touch the last modif stamp again so concurrent writer will notice the problem
		OSL_STAMP_touch_stamps "$last_modif_stamp_file"
		## do nothing more
		## return code stays NOK
		OSL_debug "[OSL_STAMP] Warning : concurrent write detected for rsrc \"$rsrc_id\" !"
	fi
	
	return $return_code
}



OSL_STAMP_begin_managed_read_operation()
{
	local return_code=1 # !0 = modif in progress by default
	## just in case
	OSL_STAMP_internal_init_managed_rsrc_stamps "$1" "$2"

	local stamp_dir=$1
	local rsrc_id=$2

	local last_modif_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX
	local modif_finished_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX

	OSL_STAMP_check_rsrc_ok "$1" "$2"
	local rsrc_dirty=$?
	
	if [[ $rsrc_dirty -eq 0 ]]; then
		## no modif, fine
		## but no stamp modification (read only)
		OSL_STAMP_last_managed_operation_modif_date=$(OSL_STAMP_stamp_date "$last_modif_stamp_file")
		return_code=0
		OSL_debug "[OSL_STAMP] begin managed read of rsrc \"$rsrc_id\" on $OSL_STAMP_last_managed_operation_begin_date..."
	else
		OSL_debug "[OSL_STAMP] aborting read of rsrc \"$rsrc_id\" because rsrc is not ready !"
	fi
		
	return $return_code
}



OSL_STAMP_end_managed_read_operation()
{
	local return_code=1 # !0 = modif in progress by default
	## just in case
	OSL_STAMP_internal_init_managed_rsrc_stamps "$1" "$2"

	local stamp_dir=$1
	local rsrc_id=$2

	local last_modif_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX
	local modif_finished_stamp_file=$stamp_dir/$rsrc_id$OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX

	local expected_last_modif_date=$OSL_STAMP_last_managed_operation_modif_date
	local actual_last_modif_date=$(OSL_STAMP_stamp_date "$last_modif_stamp_file")

	OSL_debug "[OSL_STAMP] End of read : comparing stamp dates for rsrc \"$rsrc_id\" : $expected_last_modif_date, $actual_last_modif_date..."

	if [[ "$actual_last_modif_date" == "$expected_last_modif_date" ]]; then
		## fine, no one touched the last modif stamp.
		## we leave everything untouched
		return_code=0 # OK
		OSL_debug "[OSL_STAMP] -> Comparison OK (equality), no concurrent chage, ending managed read of rsrc \"$rsrc_id\"."
	else
		## state changed by someone else while we where reading !
		## do nothing
		do_nothing=1
		## return code stays NOK
		OSL_debug "[OSL_STAMP] -> Comparison NOK (inequality), Warning : concurrent chage detected while reading rsrc \"$rsrc_id\" !"
	fi
		
	return $return_code
}
