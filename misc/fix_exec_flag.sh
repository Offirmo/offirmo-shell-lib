#!/bin/sh -x

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file just fix the exec flag for OSL scripts.
## Just don't care about it.

set -ev

## supposedly run from OSL root dir

chmod +x bin/osl_help.sh
chmod +x spec/*.sh
