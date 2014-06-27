#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of color codes
##
## This file is meant to be executed.

## reset path to be sure we test this local OSL instance
export PATH=../bin:$PATH

source osl_lib_init.sh

source osl_lib_stamp.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib stamps"

## base

TEST_STAMP_DIR=$HOME
#TEST_STAMP_DIR=/a_ram_fs
TEST_STAMP_PATH=$TEST_STAMP_DIR/osl_stamp_unit_test.stamp

echo "* testing base functions : stamp creation mode 1"
OSL_STAMP_ensure_stamp $TEST_STAMP_PATH
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_file_should_exist $TEST_STAMP_PATH

stamp_file_date=$(OSL_STAMP_stamp_date "$TEST_STAMP_PATH")
#echo "stamp_file_date = $stamp_file_date"
OSL_SSPEC_string_should_not_be_empty "$stamp_file_date"
OSL_SSPEC_string_should_eq "$(stat -c %y "$TEST_STAMP_PATH")" "$stamp_file_date"

## cleanup
rm "$TEST_STAMP_PATH"

echo "* testing base functions : stamp creation mode 2"
OSL_STAMP_ensure_stamp "$TEST_STAMP_PATH" in_old_mode
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_file_should_exist $TEST_STAMP_PATH

stamp_file_date=$(OSL_STAMP_stamp_date "$TEST_STAMP_PATH")
#echo "stamp_file_date = $stamp_file_date"
OSL_SSPEC_string_should_not_be_empty "$stamp_file_date"
OSL_SSPEC_string_should_eq "1971-01-01 00:00:00.000000000 +0100" "$stamp_file_date"

## cleanup
rm "$TEST_STAMP_PATH"


STAMP_TEST_RSRC_ID="advanced_osl_stamp_unit_test"

echo "* testing advanced functions : internal funcs"
## first we must clean existing remains
OSL_STAMP_delete_rsrc_stamps "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
## then start over
OSL_STAMP_internal_init_managed_rsrc_stamps "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_file_should_exist "$TEST_STAMP_DIR/$STAMP_TEST_RSRC_ID$OSL_STAMP_MANAGED_RSRC_LAST_MODIF_STAMP_SUFFIX"
OSL_SSPEC_file_should_exist "$TEST_STAMP_DIR/$STAMP_TEST_RSRC_ID$OSL_STAMP_MANAGED_RSRC_MODIF_FINISHED_STAMP_SUFFIX"

## by default, state must be NOK
OSL_STAMP_check_rsrc_ok "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?


echo "* testing advanced functions : nominal write case"
OSL_STAMP_begin_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_STAMP_end_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
## state must be OK
OSL_STAMP_check_rsrc_ok "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?


echo "* testing advanced functions : nominal read case"
OSL_STAMP_begin_managed_read_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_STAMP_end_managed_read_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
## state must still be OK
OSL_STAMP_check_rsrc_ok "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?


echo "* testing advanced functions : conflict case 1 : concurrent writes"
OSL_STAMP_begin_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_STAMP_last_managed_operation_modif_date_SAVE_1=$OSL_STAMP_last_managed_operation_modif_date
# concurrent modif, cannot detect concurrency at this stage
OSL_STAMP_begin_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_STAMP_last_managed_operation_modif_date_SAVE_2=$OSL_STAMP_last_managed_operation_modif_date

# restore first call value
OSL_STAMP_last_managed_operation_modif_date=$OSL_STAMP_last_managed_operation_modif_date_SAVE_1
# should fail
OSL_STAMP_end_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
# restore second call value
OSL_STAMP_last_managed_operation_modif_date=$OSL_STAMP_last_managed_operation_modif_date_SAVE_2
# should also fail
OSL_STAMP_end_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?


echo "* testing advanced functions : conflict case 2 : read while writing"
OSL_STAMP_begin_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_STAMP_last_managed_operation_modif_date_SAVE_1=$OSL_STAMP_last_managed_operation_modif_date
## read while there is a write
## conflict should be detected
OSL_STAMP_begin_managed_read_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
## end write
OSL_STAMP_end_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?


echo "* testing advanced functions : conflict case 3 : write while we are reading"
OSL_STAMP_begin_managed_read_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_STAMP_last_managed_operation_modif_date_SAVE_1=$OSL_STAMP_last_managed_operation_modif_date
# modif while we are reading
OSL_STAMP_begin_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_STAMP_last_managed_operation_modif_date_SAVE_2=$OSL_STAMP_last_managed_operation_modif_date
# another read : must fail at once
OSL_STAMP_begin_managed_read_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?

# restore first call value
OSL_STAMP_last_managed_operation_modif_date=$OSL_STAMP_last_managed_operation_modif_date_SAVE_1
# should fail
OSL_STAMP_end_managed_read_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
# restore second call value
OSL_STAMP_last_managed_operation_modif_date=$OSL_STAMP_last_managed_operation_modif_date_SAVE_2
# this one should suceed
OSL_STAMP_end_managed_write_operation "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?


## clean remains
OSL_STAMP_delete_rsrc_stamps "$TEST_STAMP_DIR" $STAMP_TEST_RSRC_ID

OSL_SSPEC_end
