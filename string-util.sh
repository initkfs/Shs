#!/usr/bin/env bash
# Author : initkfs
# printFieldByIndex string index [separator]
# Index starts with 0.
# Example:
# string="a b c d"
# printFieldByIndex "$string" 0 
# -> a
# printFieldByIndex "$string" 1 
# -> b
printFieldByIndex() {
	local -r string=$1
	if [[ -z $string ]]; then
		echo "Error printing field by index in string. String is empty. Exit" >&2 
		exit 1
	fi
	
	local fieldIndex=$2
	if [[ ! $fieldIndex =~ ^[0-9]+$ || $fieldIndex -lt 0 ]]; then
		echo "Error printing field by index. Expected number equal or greater than 0, but received: '$fieldIndex'. Exit"  >&2
		exit 1
	fi
	
	#awk index starts with 1
	((fieldIndex++))
	
	local separator=" ";
	if [[ -n $3 ]]; then 
		separator=$3
	fi
	
	#don't delete duplicate '-v'
	local -r content=$(echo "$string" | awk -v sep="$separator" -F "$separator" -v indexField="$fieldIndex"  '{ print $indexField }' )
	echo "$content"
}

# getCountFields string [separator]
# Example:
# string="a-b-c-d"
# getCountFields "$string" "-"
# -> 4
getCountFields() {
	local -r string=$1
	if [[ -z $string ]]; then
		echo "Error calculating fields in string. String is empty. Exit" >&2 
		exit 1
	fi
	
	local separator=" ";
	if [[ -n $2 ]]; then 
		separator=$2
	fi
	
	local -r content=$(echo "$string" | awk -v sep=$separator -F "$separator" '{ print NF }' )
	echo "$content"
}



