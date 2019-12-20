#!/usr/bin/env bash
#initkfs, 2018
set -u
scriptName="$(basename "$([[ -L "$0" ]] && readlink "$0" || echo "$0")")"
if [[ -z $scriptName ]]; then
  echo "Error, script name is empty. Exit" >&2
  exit 1
fi
#script directory
_source="${BASH_SOURCE[0]}"
while [[ -h "$_source" ]]; do
  _dir="$( cd -P "$( dirname "$_source" )" && pwd )"
  _source="$(readlink "$_source")"
  [[ $_source != /* ]] && _source="$_dir/$_source"
done
scriptDir="$( cd -P "$( dirname "$_source" )" && pwd )"
if [[ ! -d $scriptDir ]]; then
  echo "$scriptName error: incorrect script source directory $scriptDir, exit" >&2
  exit 1
fi
#Start script

testFilePrefix='Test'
running=0
failed=()

testDir=$scriptDir/tests

if [[ ! -d $testDir ]]; then
	echo "Error. Not found test directory: $testDir" >&2
	exit 1
fi

testFiles=$(find "$testDir" -type f -name 'Test*')
allFiles=$(echo "$testFiles" | wc -l)

printError() {
	local -r message=$1
	echo -e "\033[1;31m $message \033[0m" >&2
}

while read -r file;
do
	if [[ -f $file ]]; then

	if [[ ! -x $file ]]; then
		printError "Error. Test file is not executable: $file" 
		continue
	fi

	filename=$(basename "$file")
	if [[ -z $filename ]]; then
		printError "Error. Filename is empty of test file: $file"
		continue
	fi
	
	if [[ $filename == $testFilePrefix* ]]; then
		testOut=$("$file" 2>&1)
		testResult=$?
		(( running++ ))

	if [[ $testResult -eq 0 ]]; then
		echo "Success. $filename" 
		if [[ ! -z $testOut ]]; then
			echo "$testOut"
		fi
	else
		if [[ ! -z $testOut ]]; then
			printError "$testOut"
		fi
		
		printError "Fail: $filename. Path: $file"
		failed+=("$file")
	fi
		fi
			fi

done <<EOF
$testFiles
EOF

echo "Running: $running, found: $allFiles"

failCount=${#failed[@]}
if [[ $failCount -eq 0 ]]; then
    echo "No failed"
    exit 0
else

	echo "Failed ($failCount): "
	for message in "${failed[@]}"
	do
		echo -e "$message"
	done
	
	exit 1
fi
