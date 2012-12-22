#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - critical utilities / setup that must be set at the very start.
##   --> So this file must be sourced as soon as possible !
## 
## This file is meant to be sourced :
##    source osl_lib_init.sh


## a critical util
OSL_INIT_ensure_dir()
{
	if [[ ! -d "$1" ]]; then
#		echo "creating $1..."
		mkdir -p "$1" # -p = create parent dirs if needed
	fi

	if [[ ! -d "$1" ]]; then
		# creation failed...
		return 1
	else
		# OK
		return 0
	fi
}


## Source base env vars
source osl_inc_env.sh


## Redefine the "source" shell command.
# This is a hack to portabily be able to know the currently sourced script
## hat tip : http://dbaspot.com/shell/391701-how-get-script-name-when-sourcing.html
## Of course, only works after this special lib file has been sourced once.
source()
{
	# we skip this file itself
	# because in other funcs in this file we may want to know the last parent sourced file
	if [[ ! "$1" = "osl_lib_init.sh" ]]; then
		sourced_script=$1
	fi
	
	# source the file, using alternate syntax to avoid loops
	. $*
}


### useful dynamic vars

# formated script invocation date
if [[ -z "$OSL_INIT_exec_date_for_human" ]]; then
	# for human (useful in display)
	OSL_INIT_exec_date_for_human=`date +%Y/%m/%d-%H:%M.%S`
	# for filenames (useful for naming a log file for example)
	OSL_INIT_exec_day_date_for_file=`date +%Y%m%d`
	OSL_INIT_exec_date_for_file="$OSL_INIT_exec_day_date_for_file-`date +%Hh%Mm%S`"
fi

# It's often useful to have the script base name and full path.
# But this is tricky because previous commands may change current dir
# or invocation in or from other scripts may change script name.
# so we query intelligently only if needed
if [[ -z $OSL_INIT_script_full_path ]]; then
	OSL_INIT_script_full_path=`readlink -f "$0"`
	#echo "script_full_path set to $script_full_path"
	OSL_INIT_script_base_name=`basename "$OSL_INIT_script_full_path"`
	#echo "script_base_name set to $script_base_name"
	OSL_INIT_script_full_dir=`dirname $OSL_INIT_script_full_path`
	#echo "script_full_dir  set to $script_full_dir"

	# preferred invocation name (useful when there is an alias)
	# by default, = script name
	OSL_INIT_script_preferred_invocation_name=$OSL_INIT_script_base_name
fi

# backup of the "Internal Field Separator"
# Very useful because we often need to change it.
if [[ -z "$OSL_INIT_ORIGINAL_IFS" ]]; then
	OSL_INIT_ORIGINAL_IFS=$IFS
fi
OSL_INIT_restore_default_IFS()
{
	IFS=$OSL_INIT_ORIGINAL_IFS
}

OSL_INIT_DEFAULT_LOG_DIR=~/logs
mkdir -p $OSL_INIT_DEFAULT_LOG_DIR
if [[ -z "$OSL_INIT_LOGFILE" ]]; then
	
	OSL_INIT_LOGFILE="$OSL_INIT_DEFAULT_LOG_DIR/log.$OSL_INIT_exec_date_for_file.$USER.$OSL_INIT_script_base_name.log"
	#echo "OSL_INIT_LOGFILE set to $OSL_INIT_LOGFILE"
fi


## For some scripts, we want systematic logging to a file,
## while keeping output for users.
## Will use tee and a recursion for that.
OSL_INIT_engage_tee_redirection_to_logfile()
{
	# XXX WARNING XXX
	# THIS CODE MUST BE TESTED CAREFULLY
	# OR IT MAY CAUSE INFINITE LOOPS !

	# XXX WARNING (II) XXX
	# tee redirection MUST be engaged at the VERY BEGINNING of a script
	# since it will relaunch the calling script
	# and thus code above this call will be executed twice.
	# In the same way, tee redirection CANNOT be engaged from a sourced script.
	# (added a control to detect that)
	 
	if [[ -z "$OSL_INIT_TEE_REDIRECTION_ENGAGED" && -z "$OSL_INIT_TEE_REDIRECTION_DISABLED" ]]; then
		#echo "[debug] OSL tee redirect : 1st call"

		local redirected_script="$0" # by default, we call ourself again
		if [[ -n "$OSL_INIT_sourced_script" ]]; then
			# unless we are in a sourced script,
			# we can NOT activate tee redirection
			echo "[WARNING : activation of save output to log NOT possible from a sourced script]"
			do_nothing=1
			# ... proceed with execution
		else
			echo ""
			export OSL_INIT_TEE_REDIRECTION_ENGAGED=1
			# redirect stderr to stdout then to tee which will output to both the file and stdout
			echo "[Output also saved to : $OSL_INIT_LOGFILE]" # displayed on standard output only
			# now write to logfile only
			echo ""                                                                 > $OSL_INIT_LOGFILE
			echo "----------------------------------------------------------------" >> $OSL_INIT_LOGFILE
			echo "Infinity script launched on $OSL_INIT_exec_date_for_human :"      >> $OSL_INIT_LOGFILE
			echo "executing \"$0\" with params [$*]"                                >> $OSL_INIT_LOGFILE
			echo "----------------------------------------------------------------" >> $OSL_INIT_LOGFILE
			# 2>&1 we want both stdout and stderr
			#echo "[debug] OSL tee redirect : sourcing $redirected_script $*"
			. $0 $* 2>&1 | tee -a $OSL_INIT_LOGFILE
			local return_code=$PIPESTATUS
			#echo "[debug] OSL tee redirect : back from recursion, $?, $return_code"
			exit $return_code
		fi
	else
		#echo "[debug] OSL tee redirect : 2nd call (or no redirection)"
		do_nothing=1
		# ... proceed with execution
	fi
}
