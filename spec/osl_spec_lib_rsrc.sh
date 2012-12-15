#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of safe rsrc manip
##
## This file is meant to be executed.

source osl_lib_init.sh

source osl_lib_rsrc.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib safe rsrc manipulation"

## base

TEST_RSRC_DIR=$HOME
TEST_RSRC_ID="test_rsrc"

## adjust for test
OSL_MUTEX_LOCKFILE_RETRY_WAIT_TIME=1
OSL_MUTEX_LOCKFILE_RETRY_MAX_COUNT=3

## initial cleanup just in case
OSL_RSRC_cleanup "$TEST_RSRC_DIR" $TEST_RSRC_ID


echo "* testing read of nonexistent rsrc"
OSL_RSRC_check "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?


echo "* testing nominal write case"
OSL_RSRC_begin_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_RSRC_end_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
## state must be OK
OSL_RSRC_check "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?


echo "* testing nominal read case"
OSL_RSRC_begin_managed_read_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_RSRC_end_managed_read_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
## state must still be OK
OSL_RSRC_check "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?


echo "* testing conflict case 1 : concurrent writes"
OSL_RSRC_begin_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_RSRC_last_managed_operation_modif_date_SAVE_1=$OSL_STAMP_last_managed_operation_modif_date
# simulated concurrent modif
# we release the lock to simulate a forced op
OSL_MUTEX_unlock "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_RSRC_begin_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_RSRC_last_managed_operation_modif_date_SAVE_2=$OSL_STAMP_last_managed_operation_modif_date

# restore first call value
OSL_STAMP_last_managed_operation_modif_date=$OSL_RSRC_last_managed_operation_modif_date_SAVE_1
# should fail
OSL_RSRC_end_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
# restore second call value
OSL_STAMP_last_managed_operation_modif_date=$OSL_RSRC_last_managed_operation_modif_date_SAVE_2
# should also fail
OSL_RSRC_end_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?


echo "* testing conflict case 2 : read while writing"
OSL_RSRC_begin_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_RSRC_last_managed_operation_modif_date_SAVE_1=$OSL_STAMP_last_managed_operation_modif_date
## read while there is a write
## conflict should be detected
OSL_RSRC_begin_managed_read_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
## end write
OSL_RSRC_end_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?


echo "* testing conflict case 3 : write while we are reading"
OSL_RSRC_begin_managed_read_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_RSRC_last_managed_operation_modif_date_SAVE_1=$OSL_STAMP_last_managed_operation_modif_date
# modif while we are reading
OSL_RSRC_begin_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_RSRC_last_managed_operation_modif_date_SAVE_2=$OSL_STAMP_last_managed_operation_modif_date
# another read : must fail at once
OSL_RSRC_begin_managed_read_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?

# restore first call value
OSL_STAMP_last_managed_operation_modif_date=$OSL_RSRC_last_managed_operation_modif_date_SAVE_1
# should fail
OSL_RSRC_end_managed_read_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
# restore second call value
OSL_STAMP_last_managed_operation_modif_date=$OSL_RSRC_last_managed_operation_modif_date_SAVE_2
# this one should suceed
OSL_RSRC_end_managed_write_operation "$TEST_RSRC_DIR" $TEST_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?


OSL_SSPEC_should_spec OSL_RSRC_end_managed_write_operation_with_error


## clean remains
OSL_RSRC_cleanup "$TEST_RSRC_DIR" $TEST_RSRC_ID


OSL_SSPEC_end
