#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - file manipulation uitilities
##
## This file is meant to be sourced :
##    source osl_lib_file.sh

source osl_lib_output.sh
source osl_lib_debug.sh


## absolute, expanded path of the given file (even if it doesn’t exist)
## useful since expanding ~ in bash may be tricky
## thanks http://stackoverflow.com/a/11949850/587407
OSL_FILE_realpath()
{
	local path="$*"
	path="`eval echo ${path//>}`"
	## REM -m means "ok if doesn’t exist"
	readlink -m "$path"
}


## Absolute path of a file from a relative path.
## avantage over readlink : works even if we DON’T want symlinks to be followed
## thanks http://stackoverflow.com/a/3915986/587407
OSL_FILE_abspath()
{
	local path="`OSL_FILE_realpath "$*"`"
	case "$path" in
	/*)printf "%s\n" "$path";;
	*)printf "%s\n" "$PWD/$path";;
	esac;
}


## Find common path between given two path
## NOTE : path are compared in text only. They don’t have to exist
##        and they WONT be normalized/escaped
## Result in "$return_value"
## http://stackoverflow.com/questions/78497/design-patterns-or-best-practices-for-shell-scripts
OSL_FILE_find_common_path()
{
	typeset var from="$1"
	typeset var to="$2"
	#echo "from : \"$from\""
	#echo "to : \"$to\""
	return_value="OSL_FILE_find_common_path ERROR"

	local common_part="$from" # for now

	while [[ "${to#$common_part}" == "${to}" ]]; do
		# no match, means that candidate common part is not correct
		# go up one level (reduce common part)
		common_part="$(dirname $common_part)"
		#echo "reducing to $common_part"
	done
	return_value=$common_part
	return 0
}


# returns relative path to $2=$target from $1=$source
## NOTE : path are compared in text only. They don’t have to exist
##        and they WONT be normalized/escaped
## Result in "$return_value"# both $1 and $2 are absolute paths beginning with /
OSL_FILE_find_relative_path()
{
	local source="$1"
	local target="$2"
	#echo "source : \"$source\""
	#echo "target : \"$target\""
	return_value="OSL_FILE_compute_relative_path ERROR"

	local common_part=$source # for now

	local result=""

	#echo "common_part is now : \"$common_part\""
	#echo "result is now      : \"$result\""
	#echo "target#common_part : \"${target#$common_part}\""
	while [[ "${target#$common_part}" == "${target}" ]]; do
		# no match, means that candidate common part is not correct
		# go up one level (reduce common part)
		common_part="$(dirname $common_part)"
		# and record that we went back
		if [[ -z $result ]]; then
			result=".."
		else
			result="../$result"
		fi
		#echo "common_part is now : \"$common_part\""
		#echo "result is now      : \"$result\""
		#echo "target#common_part : \"${target#$common_part}\""
	done

	#echo "common_part is     : \"$common_part\""

	if [[ $common_part == "/" ]]; then
		# special case for root (no common path)
		result="$result/"
	fi

	# since we now have identified the common part,
	# compute the non-common part
	forward_part="${target#$common_part}"
	#echo "forward_part = \"$forward_part\""

	if [[ -n $result ]] && [[ -n $forward_part ]]; then
		#echo "(simple concat)"
		result="$result$forward_part"
	elif [[ -n $forward_part ]]; then
		#echo "(concat with slash removal)"
		result="${forward_part:1}"
	else
		#echo "(no concat)"
		do_nothing=1
	fi
	#echo "result = \"$result\""
	return_value=$result

	return 0
}


OSL_FILE_ensure_line_is_present_in_file()
{
	typeset var line="$1"
	typeset var file="$(OSL_FILE_realpath $2)"

	OSL_debug "* ensuring that line \"$line\" is present in file \"$file\""

	if ! [[ -f "$file" ]]; then
		OSL_OUTPUT_display_error_message "file \"$file\" not found !"
		return 1
	fi

	# REM : --fixed-strings : Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
	typeset var test=`grep --count --fixed-strings --line-regexp "$line" "$file"`

	if [[ $test -ne 0 ]]; then
		# the line is already in the file
		OSL_debug "  -> Already set."

		do_nothing=1
	else
		# the line is not in the file, add it
		OSL_debug "  -> Not set, adding it..."

		# 1) add it to the temp file
		echo "$line" >> "$file"
	fi

	return 0
}


## remove trailing and .git
## remove github ref
## repo endpoint should be a git url like in https://www.kernel.org/pub/software/scm/git/docs/git-clone.html "git url"
OSL_FILE_shorten_git_repo_dir()
{
	typeset var repository="$*"

	#OSL_debug "* extracting repo target dir for $repository"

	## first remove trailing / if any
	local length=${#repository}
	[[ "${repository:$length-1}" = "/" ]] && repository=${repository:0:$length-1}

	## then remove trailing .git if any
	length=${#repository}
	[[ "${repository:$length-4}" = ".git" ]] && repository=${repository:0:$length-4}

	## remove remote transport if any
	[[ "${repository:0:6}" = "ssh://" ]] && repository=${repository:6}
	[[ "${repository:0:6}" = "git://" ]] && repository=${repository:6}
	[[ "${repository:0:6}" = "ftp://" ]] && repository=${repository:6}
	[[ "${repository:0:7}" = "ftps://" ]] && repository=${repository:7}
	[[ "${repository:0:7}" = "http://" ]] && repository=${repository:7}
	[[ "${repository:0:8}" = "https://" ]] && repository=${repository:8}
	[[ "${repository:0:8}" = "rsync://" ]] && repository=${repository:8}

	## remove user git if any
	[[ "${repository:0:4}" = "git@" ]] && repository=${repository:4}

	## remove user github.com if any
	[[ "${repository:0:11}" = "github.com:" ]] && repository=${repository:11}
	[[ "${repository:0:11}" = "github.com/" ]] && repository=${repository:11}

	echo ${repository}

	return 0
}


## extract the dir where this repo would be created
## repo endpoint should be a git url like in https://www.kernel.org/pub/software/scm/git/docs/git-clone.html "git url"
OSL_FILE_extract_git_repo_dir()
{
	typeset var repository="`OSL_FILE_shorten_git_repo_dir "$*"`"

	## find last path element
	## This is so magical :
	## http://stackoverflow.com/questions/3162385/how-to-split-a-string-in-shell-and-get-the-last-field
	echo ${repository##*/}

	return 0
}