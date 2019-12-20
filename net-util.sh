#!/usr/bin/env bash
# Author : initkfs
isValidUrl() {
	
	local -r targetUrl=$1
	if [[ -z $targetUrl ]]; then
		echo "Error. URL is empty. Unable to check if url is valid." >&2
		exit 1
	fi
	#TODO https://stackoverflow.com/questions/161738/what-is-the-best-regular-expression-to-check-if-a-string-is-a-valid-url
	local -r nonI18nUrlRegex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
	if [[ $targetUrl =~ $nonI18nUrlRegex ]]; then
		echo 0
	else
		echo 1
	fi
}

#https://self-signed.badssl.com" > 000 0
getServerCode() {
	
	local -r targetUrl=$1
	
	if [[ -z $targetUrl ]]; then
		echo "Error. Unable to get server response, url is empty" >&2
		exit 1
	fi
	
	local isValid
	isValid=$(isValidUrl "$targetUrl")
	if [[ isValid -ne 0 ]]; then
		echo "Error. Unable to get server response, url is not valid: $targetUrl" >&2
		exit 1
	fi
		
	#wget -q --tries=10 --timeout=20 --spider  "$targetSite"
	#TODO --insecure for custom certificates?
	local retCode
	local serverCode
	serverCode=$(curl --silent --location --connect-timeout 5 --output /dev/null --write-out "%{http_code}" "$targetUrl")
	retCode=$?
	echo "$serverCode $retCode"
}

isUrlAccessible() {
	
	local -r targetUrl=$1
	
	if [[ -z $targetUrl ]]; then
		echo "Error. URL is empty. Unable to check if url is accessible." >&2
		exit 1
	fi
	
	local -r codeAndRet=$(getServerCode "$targetUrl")
	
	local serverCode="${codeAndRet% *}"
	local requestReturnCode="${codeAndRet#* }"
	if [[ $serverCode -ne 200 || $requestReturnCode -ne 0 ]]; then
		echo 1
	else
		echo 0
	fi
}

isGoogleAccessible() {
	local -r url="https://google.com"
	
	local result
	result=$(isUrlAccessible "$url")
	echo "$result"
}
