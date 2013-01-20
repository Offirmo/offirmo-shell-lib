#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## XXX this script is special XXX
## It returns current lib version
## without expecting the PATH to be set.
## So it can be used at bootstrap
## for selecting between 2 instances of OSL.
##
## This file is meant to be executed.


## inspect how we are launched
script_full_path=`readlink -f "$0"`
#echo "script_full_path set to $script_full_path"
script_full_dir=`dirname $script_full_path`
#echo "script_full_dir  set to $script_full_dir"

## now source our version info with exact path
source "$script_full_dir/osl_inc_env.sh"

## done
echo "$OSL_VERSION"
