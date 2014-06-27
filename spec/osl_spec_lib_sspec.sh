#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - a set of calls to unit test functions to check them
##
## This file is meant to be executed.

## reset path to be sure we test this local OSL instance
export PATH=../bin:$PATH

source osl_lib_init.sh
source osl_lib_sspec.sh

OSL_SSPEC_describe "Offirmo Shell Lib unit test utilities"

OSL_SSPEC_end
