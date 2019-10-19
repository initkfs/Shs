#!/usr/bin/env bash
# Author : initkfs
assertEquals() {
	local expected=$1
	local actual=$2
	local numRegexp='^[0-9]+$'
	if [[ $expected =~ $numRegexp && $actual =~ $numRegexp ]] ; then
		if [[ $actual -ne "$expected" ]]; then
			echo "Error. Expected number: \"$expected\", but received \"$actual\". Exit" >&2
			exit 1
		fi
	else 
		if [[ $actual != "$expected" ]]; then
			echo "Error. Expected string: \"$expected\", but received \"$actual\". Exit" >&2
			exit 1
		fi
	
	fi
	
	true
}

assertFileExists(){
	
	local file=$1
	
	if [[ -z $file ]]; then
		echo "Error. Expected file cannot be empty. Exit" >&2
		exit 1
	fi
	
	if [[ ! -f $file ]]; then
		echo "Error. Expected existing file, but the file does not exist: $file. Exit" >&2
		exit 1
	fi
	
	true
}

runUnitTests() {
	local testFileFunctionNames=$(grep -E '^(function )?[[:blank:]]*test.*?[?!(]' "$0" | sed --regexp-extended 's/^function[[:blank:]]*//' | tr -d '(){')
		
	for testFileFunctionName in $testFileFunctionNames
	do
	local exitCode
	local out
	out=$("$testFileFunctionName")
	exitCode=$?
	if [[ $exitCode -ne 0 ]]; then
		echo "Function failed with output: $out Function name: $testFileFunctionName in file: $0. Exit code: $exitCode" >&2
		exit 1
	fi
	done
}

