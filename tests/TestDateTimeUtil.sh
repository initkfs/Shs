#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$__dir/../test-util.sh"
. "$__dir/../datetime-util.sh"

yearMonthDayPattern=[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}
datePattern=^${yearMonthDayPattern}$

timePattern="[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}"
dateTimePattern="^$yearMonthDayPattern ${timePattern}$"

testGetIsoDate() {
	local dateISO=$(getDateISO)
	[[ $dateISO =~ $datePattern ]] || assertEquals 0 $?
}

testGetDateTime() {
	local dateTime=$(getDateTime)
	[[ $dateTime =~ $dateTimePattern ]] || assertEquals 0 $?
}

testGetSecFromDate() {
	local timestamp=$(getSecFromDate 2018-01-01)
	assertEquals 1514754000 "$timestamp"
}

testGetDateDifference(){
	local date1="2017-01-01"
	local date2="2017-01-10"
	
	assertEquals 9  "$(getDateDifference "$date1" "$date2")"
	
	assertEquals 9  "$(getDateDifference "$date2" "$date1")" 	
}

testGetSafeDateTime() {
	local datetime=$(getSafeDateTime )
	[[ $datetime =~ ^[[:digit:]_-]+$ ]] || assertEquals 0 $?
}


runUnitTests
