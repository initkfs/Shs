#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$__dir/../test-util.sh"
. "$__dir/../common-util.sh"

testIsValidCommandExists() {
	local result
	result=$(isCommandExists "ls")
	assertEquals 0 "$result"
}

testIsInvalidCommandExists() {
	local result
	result=$(isCommandExists "e2fc71 4c4727e")
	assertEquals 1 "$result"
}

runUnitTests



