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


OSL_SSPEC_describe "Offirmo Shell Lib mutexes"

## base

TEST_MUTEX_DIR=$HOME
TEST_MUTEX_RSRC_ID="osl_mutex_unit_test"

## initial cleanup

echo "* forced acquisition..."
OSL_MUTEX_force_acquire "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
## note : we cannot test forced acquisition again
## because it seems we cannot force retake a lock we already have
# release
OSL_MUTEX_release "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?

echo "* normal acquisition..."
OSL_MUTEX_acquire "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?
OSL_MUTEX_release "$TEST_MUTEX_DIR" $TEST_MUTEX_RSRC_ID
OSL_SSPEC_return_code_should_be_OK $?

OSL_SSPEC_end
