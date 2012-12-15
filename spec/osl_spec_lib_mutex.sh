#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of color codes
##
## This file is meant to be executed.

source osl_lib_init.sh

source osl_lib_mutex.sh

source osl_lib_sspec.sh
OSL_debug_activated=true


OSL_SSPEC_describe "Offirmo Shell Lib mutexes"

## base

TEST_MUTEX_DIR=$HOME
TEST_MUTEX_RSRC_ID="osl_mutex_unit_test"

## initial cleanup
OSL_MUTEX_cleanup "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID

## adjust for test
OSL_MUTEX_LOCKFILE_RETRY_WAIT_TIME=1
OSL_MUTEX_LOCKFILE_RETRY_MAX_COUNT=3

echo "* forced acquisition..."
OSL_MUTEX_force_lock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
## note : we cannot test forced acquisition again
## because it seems we cannot force retake a lock we already have

# release
OSL_MUTEX_unlock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?

echo "* normal acquisition..."
OSL_MUTEX_lock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_unlock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?

echo "* try acquisition..."
OSL_MUTEX_trylock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_trylock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
OSL_MUTEX_unlock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?

echo "* concurrent lock (no reentrancy)..."
OSL_MUTEX_lock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_lock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
OSL_MUTEX_trylock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_NOK $?
OSL_MUTEX_unlock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?

echo "* double unlock..."
OSL_MUTEX_lock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_unlock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_unlock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?

## cleanup
OSL_MUTEX_cleanup "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID

OSL_SSPEC_end
