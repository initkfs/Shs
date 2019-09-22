#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$__dir/../test-util.sh"
. "$__dir/../io-util.sh"

tempDirForTests=
file1ForTests=

setOnBeforeTests(){
	
	tempDirForTests=$(mktemp -d /tmp/XXXXXXXXXXXX)
	if [[ $? -ne 0 ]]; then
		echo "Error. Cannot create temp directory for test: $tempDirForTests. Exit" >&2
		exit 1
	else 
		echo "Create temp directory: $tempDirForTests"
	fi
	
	local fileName1=$(echo -n file1 | md5sum)
	file1ForTests="$tempDirForTests/${fileName1} tempfile.temp"
	touch "$file1ForTests"
	if [[ $? -ne 0 ]]; then
		echo "Error. Cannot create temp file for test: $file1ForTests. Exit" >&2
		exit 1
	fi
}

testGetFileExtension() {
	
	local pathWithDot="./path .dir"
	
	assertEquals "txt" "$(getFileExtension "${pathWithDot}/file.txt")"
	
	#test path with trailing whitespace character
	assertEquals "" "$(getFileExtension "${pathWithDot}/file.txt " )"
	
	assertEquals "" "$(getFileExtension "${pathWithDot}/file")"

	assertEquals "" "$(getFileExtension "./" )"
	
}

testDirSha256SumFiles() {
	local sum=$(dirSha256SumFiles "$tempDirForTests")
	assertEquals "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" "$sum"
}

testDirCountFiles() {
	local count=$(dirCountFiles "$tempDirForTests")
	assertEquals 1 "$count"
}

testGetBasename() {
	local basename=$(getBasename /path-to/dir )
	assertEquals "dir" "$basename"
	
	assertEquals "."  "$(getBasename "./")"
	
	assertEquals "/"  "$(getBasename "/")"
}

testTrimLastPathSeparator() {
	local trimmedPath=$(trimLastPathSeparator "/path/file/")
	assertEquals /path/file "$trimmedPath"
	
	local backSlashPath="\path\file\\"
	assertEquals "$backSlashPath" "$(trimLastPathSeparator "$backSlashPath" )"
}

testConvertToSafe(){
	local converted=$(convertToSafe "f:i!\l$ e:/n-a*&me")
	assertEquals "f_i__l__e__n_a__me" "$converted"
}

testDirFiles() {
	
	local foundFiles=()
	fileIterator() {
		foundFiles+=("$1")
	}
	
	dirFiles "$tempDirForTests" fileIterator

	for foundFile in "${foundFiles[@]}"
	do
	assertEquals "$file1ForTests" "$foundFile"

	done
}

setOnAfterTests() {
	if [[ ! -f $file1ForTests ]]; then
		echo "Error. Can not delete test file: $file1. Exit." >&2
	else
		rm "$file1ForTests"
		if [[ $? -ne 0 ]]; then
			echo "Unable to delete test file: $file1ForTests"  >&2
		fi
	fi
	
	if [[ ! -d $tempDirForTests ]]; then
		echo "Error. Cannot delete temp test directory: $tempDir" >&2
	else
		rmdir "$tempDirForTests"
		if [[ $? -ne 0 ]]; then
			echo "Unable to delete test directory: $tempDirForTests"  >&2
		else
			#log, prevent data loss
			echo "Delete test directory: $tempDirForTests"
		fi
	fi
}


setOnBeforeTests
runUnitTests
setOnAfterTests
