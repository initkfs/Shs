#!/usr/bin/env bash

# Author : initkfs

#Example:
# res=$(isCommandExists "ls")
# [[ $res -eq 0 ]] && echo "yes"
#
# res=$(isCommandExists "blablablah")
# [[ $res -eq 1 ]] && echo "no"
isCommandExists() {
	local devNull='/dev/null'
	if [[ ! -w $devNull ]]; then 
		echo "Error. Cannot check command if exists. $devNull is not writable. Exit" >&2
		exit 1;
	fi
	
	local command=$1
	if [[ -z $command ]]; then
		echo "Error. Cannot check command if exists. Command is empty. Exit" >&2
		exit 1;
	fi
	
	local isExists
	type "$command" &> "$devNull"
	isExists=$?

	if  [[ $isExists -eq 0 ]]; then
		echo 0
		#return 0
	else
		echo 1
		#return 1
	fi
}


