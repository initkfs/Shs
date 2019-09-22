#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$__dir/../test-util.sh"
. "$__dir/../string-util.sh"

inputString="apple orange mango"
separator=";"
inputStringWithSeparator="apple${separator}orange${separator}mango"

testPrintFieldByIndex() {
	local result=$(printFieldByIndex "$inputString" 1)
	assertEquals "orange" "$result" 
}

testPrintFieldByIndexWithSeparator() {
	local result=$(printFieldByIndex "$inputStringWithSeparator" 1 "$separator")
	assertEquals "orange" "$result" 
}

testGetCountFields() {
	local result=$(getCountFields "$inputString")
	assertEquals 3 "$result" 
}

testGetCountFieldsWithSeparator() {
	local result=$(getCountFields "$inputStringWithSeparator" "$separator")
	assertEquals 3 "$result"
}

runUnitTests
