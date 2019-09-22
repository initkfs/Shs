#!/usr/bin/env bash
# Author : initkfs

LOGGER_LEVEL_ALL=2
LOGGER_LEVEL_DEBUG=4
LOGGER_LEVEL_INFO=6
LOGGER_LEVEL_WARNING=8
LOGGER_LEVEL_ERROR=16

if [[ -z $LOGGER_GLOBAL_LEVEL ]]; then
	LOGGER_GLOBAL_LEVEL=$LOGGER_LEVEL_ALL
fi

if [[ -z $LOGGER_GLOBAL_HANDLERS ]]; then
	LOGGER_GLOBAL_HANDLERS=()
fi

logFormat() {
	local logFormat='%DATE [%LEVEL] %MESSAGE'
	
    local level="$1"
    local message="$2"
    local date="$(date '+%F %T %Z')"

    logFormat="${logFormat/'%MESSAGE'/$message}"
    logFormat="${logFormat/'%LEVEL'/$level}"
    logFormat="${logFormat/'%DATE'/$date}"
    echo "$logFormat"
}

#consoleHandler $LOGGER_LEVEL_ERROR "message"
consoleHandler() {
	
	local level=$1
	if [[ -z $level ]]; then
		echo "Error. Console logger handler: logger level is empty. Set to error" >&2
		level=$LOGGER_LEVEL_ERROR
	fi
	
	local message=$2
	local defaultMessage="Undefined console message"
	if [[ -z $message ]]; then
		echo "Error. Console logger handler: message is empty. Set to default: $defaultMessage" >&2
		level=$LOGGER_LEVEL_ERROR
	fi
	
	local LOGGER_COLOR_WARNING="\033[1;33m" # Yellow
	local LOGGER_COLOR_ERROR="\033[1;31m" # Red
	local LOGGER_RESET_COLOR="\033[0m"
	
	local levelColor=
	local levelName=""
	
	case "$level" in
	$LOGGER_LEVEL_DEBUG ) 
	levelName=DEBUG
	;;
	$LOGGER_LEVEL_INFO ) 
	levelName=INFO
	;;
	$LOGGER_LEVEL_WARNING ) 
	levelName=WARNING
	levelColor=$LOGGER_COLOR_WARNING
	;;
	$LOGGER_LEVEL_ERROR ) 
	levelName=ERROR
	levelColor=$LOGGER_COLOR_ERROR
	;;
	* ) 
	echo "Error. Unsupported syslog level: '$level'. Set to error"
	levelName=ERROR
	levelColor=$LOGGER_COLOR_ERROR
	;;
	esac
	
	local formattedMessage="$levelName: $message"
	if [[ ! -z $levelColor ]]; then
		formattedMessage="${levelColor}${formattedMessage}${LOGGER_RESET_COLOR}"
		echo -e "$formattedMessage"
	else
		echo "$formattedMessage"
	fi
	
}

# LOGGER_GLOBAL_LEVEL=$LOGGER_LEVEL_DEBUG
# handlers=("consoleHandler")
# Pass handlers by reference without '$'
# log $LOGGER_LEVEL_INFO "Log message"  handlers
# -> 2018-07-28 19:15:09 +03 [6] Log message
log() {

	#TODO validate
	local globalLevel=$LOGGER_GLOBAL_LEVEL
	if [[ -z $globalLevel ]]; then
		echo "Error. Global logger level is empty. Set to: $LOGGER_LEVEL_ALL" >&2
		globalLevel=$LOGGER_LEVEL_ALL
	fi
	
	local loggerlevel=$1
	local message=$2
	if [[ ! -z $3 ]]; then
		local -n logHandlers=$3
	fi
	
	if [[ -z $message ]]; then
		#TODO or exit?
		message="Error. Log message is empty!"
		echo "Error. Logger message is empty. Set default: '$message'" >&2
	fi
	
	if [[ -z $loggerlevel ]]; then
		loggerlevel=$LOGGER_LEVEL_ALL
	fi
	
	if [[ ! $loggerlevel =~ ^[[:digit:]]{1,2}$ ]]; then
		echo "Error. Invalid logger level value received, expected number, but received: '$loggerlevel'. Set to: $LOGGER_LEVEL_ALL" >&2
		loggerlevel=$LOGGER_LEVEL_ALL
	fi 
	
	if [[ -z $logHandlers ]]; then
		local logHandlers=("${LOGGER_GLOBAL_HANDLERS[@]}")
		
		if [[ -z $logHandlers ]]; then
			echo "Error. Global logger handlers are not defined. Set to console" >&2
			logHandlers=("consoleHandler")
		fi
	fi
	
	local logRecord=$(logFormat "$loggerlevel" "$message")
		
	#minimal logger level >= global logger level
	if [[ $loggerlevel -ge $globalLevel ]]; then 
	
	local handlerExitStatus
    for logHandler in "${logHandlers[@]}"
    do
        "$logHandler" "$loggerlevel" "$logRecord" 
        handlerExitStatus=$?
			if [[ $handlerExitStatus -ne 0 ]]; then
				echo "Log handler '$logHandler' error with code: $handlerExitStatus" >&2
			fi
    done
    fi
}

#Supported levels: low, normal, critical
#syslogHandler critical "Hello, syslog" "sys_tag"
#Aug 12 21:24:54 user sys_tag: Hello, syslog 
syslogHandler() {
	
	if [[ ! -n $(which "logger") ]]; then
		echo "Cannot write to syslog. Logger is undefined. Exit" >&2
		exit 1
	fi
	
	local message=$2
	if [[ -z $message ]]; then
		message="undefined_message"
		echo "Error. Syslog message is empty. Set default: $message" >&2
	fi
	
	local title=$3
	if [[ -z $title ]]; then
		title=""
	fi
	
	
	local level=$1
	local defaultLevel=$LOGGER_LEVEL_ERROR
	
	if [[ -z $1 ]]; then
		level=$defaultLevel
		echo "Error. Syslog level is empty. Set to error" >&2
	fi
	
	#TODO default
	case "$level" in
	$LOGGER_LEVEL_DEBUG   ) level=debug;;
	$LOGGER_LEVEL_INFO  ) level=info;;
	$LOGGER_LEVEL_WARNING   ) level=warn;;
	$LOGGER_LEVEL_ERROR   ) level=err ;;
	*       ) 
	echo "Error. Unsupported syslog level: '$level'. Set to error"
	level=crit;;
	esac
	
	echo "$message" | logger  -p "user.$level" -t "$title"
}

fileHandler() {
	local filePath=$LOGGER_FILE_HANDLER_PATH
	
	if [[ -z filePath || ! -f $filePath || ! -w $filePath ]]; then
		echo "Error cannot write log file with path: $filePath. Exit" >&2
		exit 1
	fi
	
	local level=$1
	local message=$2
	
	if [[ ! -f "$filePath" ]]; then
	touch "$filePath"
	#TODO check error
	fi
	
	echo "$message" >> "$filePath"
}

logDebug() {
	log $LOGGER_LEVEL_DEBUG "$1" "$2"
}

logInfo() {
	log $LOGGER_LEVEL_INFO "$1" "$2"
}

logWarning() {
	log $LOGGER_LEVEL_WARNING "$1" "$2"
}

logError() {
	log $LOGGER_LEVEL_ERROR "$1" "$2"
}


#sendNotification $level $title $message $time
#Levels: low, normal, critical
#Example:
#sendNotification normal "Hello" "world"
sendNotification() {
	local level=critical
	local title=$2
	local message=$3
	
	local notifyLevels=("low" "normal" "critical")
	local defaultLevel=critical
	if [[ -z $1 ]]; then
		echo "Cannot send notification. Level is empty. Possible levels: '${notifyLevels[@]}'. Set to '$defaultLevel'" >&2
		level=$defaultLevel
	else 
	
		if [[ ! " ${notifyLevels[@]} " =~ " $1 " ]]; then
			echo "Error. Unsupported level: $1. Set to $defaultLevel"  >&2
			level=$defaultLevel
		else
			level=$1
		fi
	fi
	
	if [[ -z $title ]]; then
		title="Undefined notification title"
		echo "Error. Notification title message is empty. Set default title: '$title'" >&2
	fi
	
	if [[ -z $message ]]; then
		message="Undefined notification message"
		echo "Error. Notification message is empty. Set default message: '$message'" >&2
	fi
	
	local timeLimit=5000
	if [[ ! -z $4 ]]; then
		timeLimit=$4
	fi
	
messageData="Notification message: $message, level: $level, title: $title"
#TODO extract function
if [[ -n $(which notify-send) ]]; then

	notify-send -u "$level" -t "$timeLimit" "$title" "$message"
	if [[ $? -ne 0 ]]; then
		echo "notify-send error. $messageData" >&2
	fi
	
elif [[ -n $(which zenity) ]]; then
		local zenityLevel="--error"
		 case "$level" in
		low)
			zenityLevel="--info"
			;;
		normal)
			zenityLevel="--info"
			;;
		esac
	zenity $zenityLevel --title="$title" --text="$message"
	if [[ $? -ne 0 ]]; then
		echo "zenity error. $messageData" >&2
	fi
	
elif [[ -n $(which xmessage) ]]; then
	 xmessage -center "TITLE: $title MESSAGE: $message"
	if [[ $? -ne 0 ]]; then
		echo "xmessage error. $messageData" >&2
	fi

else
	echo "Error. Cannot send notification. Unsupported sender. Message: $message, level: $level, title: $title" >&2
fi
}

#sendErrorNotification $message $time-expire
sendErrorNotification() {
	local level="critical"
	local title="Error!"
	sendNotification "$level" "$title" "$1" "$2"
}

#endWarningNotification $message $time-expire
sendWarningNotification() {
	local level="normal"
	local title="Warning!"
	sendNotification "$level" "$title" "$1" "$2"
}

#sendInfoNotification $message $time-expire
sendInfoNotification() {
	#TODO 'low' level?
	local level="normal"
	local title="Info!"
	sendNotification "$level" "$title" "$1" "$2"
}

desktopNotificationHandler(){
	local level=$1
	local message=$2
	
	case "$level" in
	$LOGGER_LEVEL_DEBUG   ) sendInfoNotification "$message";;
	$LOGGER_LEVEL_INFO  ) sendInfoNotification "$message";;
	$LOGGER_LEVEL_WARNING   ) sendWarningNotification "$message";;
	$LOGGER_LEVEL_ERROR   ) sendErrorNotification "$message";;
	*       ) sendErrorNotification "$message";;
	esac
}
