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

source osl_lib_mutex.sh

source osl_lib_sspec.sh
OSL_debug_activated=true


OSL_SSPEC_describe "Offirmo Shell Lib mutexes"

## base

TEST_MUTEX_DIR=$HOME
TEST_MUTEX_DIR=$(pwd)
TEST_MUTEX_RSRC_ID="osl_mutex_unit_test"
TEST_MUTEX_RSRC_ID2="osl_mutex_unit_test2"

## initial cleanup
OSL_MUTEX_cleanup "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_MUTEX_cleanup "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID2

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


## 2013/01/03 an interesting case
echo "* two different mutexes in the same directory..."
OSL_MUTEX_lock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_trylock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID2
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_unlock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_unlock "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID2
OSL_SSPEC_return_code_should_be_OK $?
## eventually, was not a bug. Keep the test, though.

## cleanup
OSL_MUTEX_cleanup "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_MUTEX_cleanup "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID2

OSL_SSPEC_end
