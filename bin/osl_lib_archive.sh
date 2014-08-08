#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   archives manipulation functions
##
## This file is meant to be sourced :
##    source osl_lib_archive.sh


## useful to unpack sources
## archive path = ex. foo.zip
## dest dir = full destination dir where archive *content* will be put
## expected_unpack_dir = optional hint, see below
OSL_ARCHIVE_unpack_to()
{
	local archive_path="$1"
	local destination_dir="$2"
	local expected_unpack_dir="$3" ## (optional) lot of unpackers give no control over the output dir.
                                  ## If we want to extract in a custom dir, we want to know the auto dir
                                  ## that the unpacker will use in order to mv/rename it afterward.
                                  ## Usually we can guess it, but if not possible, this param is a hint.
                                  ## Not needed if unpack dir = <filename without dot>.<extension>
	local return_code=1 # error/problem by default

	echo "* unpacking \"$archive_path\" to \"$destination_dir\"..."

	echo "  - testing expected destination dir : $destination_dir..."
	if [[ -d $destination_dir ]]; then
		echo "    --> already exists !"
		return 1; ## conflict
	fi

	echo "  - unpack in progress..."
	local prev_wd=$(pwd)
	cd `dirname $destination_dir`

	## great hat tip to http://ubuntuforums.org/showpost.php?p=10287642&postcount=4
	## since double extensions ar hard to parse, we take the opportunity to store them.
	local extension=""
	case $archive_path in
	*.tar.bz2) extension=".tar.bz2" && tar xvjf   $archive_path ;;
	*.tar.gz)  extension=".tar.gz"  && tar xvzf   $archive_path ;;
	*.tar.xz)  extension=".tar.xz"  && tar Jxvf   $archive_path ;;
	*.bz2)     extension=".bz2"     && bunzip2    $archive_path ;;
	*.rar)     extension=".rar"     && unrar x    $archive_path ;;
	*.gz)      extension=".gz"      && gunzip     $archive_path ;;
	*.tar)     extension=".tar"     && tar xvf    $archive_path ;;
	*.tbz2)    extension=".tbz2"    && tar xvjf   $archive_path ;;
	*.tgz)     extension=".tgz"     && tar xvzf   $archive_path ;;
	*.zip)     extension=".zip"     && unzip      $archive_path ;;
	*.Z)       extension=".Z"       && uncompress $archive_path ;;
	*.7z)      extension=".7z"      && 7z x       $archive_path ;;
	*)         echo "XXX don't know how to extract such an archive : '$archive_path'..." && return 1;;
	esac
	return_code=$?

	## since we now have the extension, we can compute the file name
	local archive_name=`basename $archive_path`
	local length=${#archive_name}
	local root=${archive_name:0:$length-${#extension}}

	#echo "  - archive name : $archive_name"
	#echo "  - extension    : $extension"
	#echo "  - basename     : $root"
	#echo "  - pwd          : $(pwd)"
	if [[ -z $expected_unpack_dir ]]; then # rem : -z = zero-length ?
		expected_unpack_dir=$root
	fi
	#echo "   - expected unpack dir : $expected_unpack_dir"

	if [[ $return_code -ne 0 ]]; then
		echo "XXX something failed during unpacking..."
	else
		mv  "$expected_unpack_dir"  "$destination_dir"
		return_code=$?
		echo "  - unpack done."
	fi

	## back to prev dir
	cd "$prev_wd"

	return $return_code
}
