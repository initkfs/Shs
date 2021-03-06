#!/usr/bin/env bash

# Author : initkfs

# Year-Month-Day. Example:
# getDateISO
# -> 2017-01-01
getDateISO() {
	local date
	date=$(date +%Y-%m-%d)
	if [[ $? -ne 0 ]]; then
		echo "Error. Cannot read ISO date, result: '$date'. Exit." >&2
		exit 1
	fi
	echo "$date"
}

# Year-Month-Day Hour:Minute:Second. Example:
# getDateTime
# -> 2018-07-27 00:39:11
getDateTime() {
	local datetime
	datetime=$(date "+%Y-%m-%d %H:%M:%S")
	if [[ $? -ne 0 ]]; then
		echo "Error. Cannot read datetime, result: '$dateTime'. Exit." >&2
		exit 1
	fi
	echo "$datetime"
}

# year-month-day_hour_min_sec. Example:
# getSafeDateTime
# -> 2017-01-21_01_42_39
getSafeDateTime() {
	local exitCode
	local dateTime
	dateTime=$(getDateTime)
	exitCode=$?
	if [[ $exitCode -ne 0 || -z $dateTime ]]; then
		echo "Error. Cannot convert datetime $dateTime to the save form, result: '$dateTime', exit code: ${exitCode}. Exit." >&2
		exit 1
	fi
	
	local -r safeResult=${dateTime//[: ]/_}
	echo "$safeResult"
}

#getSecFromDate 2018-01-01
#-> 1514754000
getSecFromDate() {
	if [[ -z $1 ]]; then
		echo "Error. Cannot convert date to seconds. Date is empty. Exit." >&2
		exit 1
	fi
	
	#yyyy-mm-dd
	local -r datePattern="^[0-9]{4}-(((0[13578]|(10|12))-(0[1-9]|[1-2][0-9]|3[0-1]))|(02-(0[1-9]|[1-2][0-9]))|((0[469]|11)-(0[1-9]|[1-2][0-9]|30)))$"
	if [[ ! $1 =~ $datePattern ]]; then
		echo "Error. Received incorrect format of date for seconds calculating. Expected ISO format yyyy-mm-dd. But received: '$1'. Exit." >&2
		exit 1
	fi 
	
	local convertCode
	local secFromDate
	secFromDate=$(date -d "$1" +%s)
	convertCode=$?
	if [[ $convertCode -ne 0 ]]; then
		echo "Error converting date '$1' to seconds with result: '$secFromDate' and exit code '$convertCode'. Exit" >&2
		exit 1
	fi
	
	echo "$secFromDate"
}

# Return date difference in days without leap seconds
# Example:
# getDateDifference 2017-01-01 2017-01-10
# -> 9
getDateDifference() {
	
	if [[ -z $1 || -z $2 ]]; then
		echo "Error. Date for difference calculating cannot be empty. Expected two date, but received: 1-'$1', 2-'$2'. Exit" >&2
		exit 1
	fi
	
	local -r convertError="Error converting date to seconds"
	local secFromDate1
	secFromDate1=$(getSecFromDate "$1")
	if [[ $? -ne 0 || -z $secFromDate1 ]]; then
		echo "$convertError '$1' (first date). Exit" >&2
		exit 1
	fi
	
	local secFromDate2
    secFromDate2=$(getSecFromDate "$2")
    if [[ $? -ne 0 ]]; then
		echo "$convertError '$2' (second date). Exit" >&2
		exit 1
	fi
    
	local -r difference=$(( (secFromDate1 - secFromDate2) / 86400 ))
	
	if (( difference < 0 )); then 
		local -r result=$(( 0 - difference ))
		echo "$result"
	else 
		echo "$difference"
	fi
}



