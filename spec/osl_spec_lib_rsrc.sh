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


OSL_SSPEC_describe "Offirmo Shell Lib safe rsrc manip"

## base

TEST_RSRC_DIR=$HOME

OSL_SSPEC_should_spec normal use

OSL_SSPEC_should_spec normal OSL_RSRC_end_managed_write_operation_error


## clean remains

OSL_SSPEC_end
