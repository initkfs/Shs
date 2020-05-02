#!/usr/bin/env bash
# Author : initkfs

# Example:
# getFileExtension "file.txt.temp"
# -> temp
# getFileExtension "file"
# -> 
# But: getFileExtension "file.txt.temp " -> "", extension is empty
getFileExtension(){
	local -r path=$1
	if [[ -z $path ]]; then
		echo "Error. Cannot get file extension. Path is empty. Exit" >&2
		exit 1
	fi
	
	local -r ext=${path##*.}
	if [[ $ext == "$path" ]]; then
		#extension not found
		echo ""
	else
	
		#check is part contains path separator or spaces.
		if [[ $ext =~ [\\\/[:space:]] ]]; then
			echo ""
			return
		fi
	
		echo "$ext"
	fi  
}

# Example:
# dirSha256SumFiles ./emptyDirectory
# -> 
# dirSha256SumFiles ./dirWith2Files
# -> e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
#    512d47b0ee0cb463598eb8376840216ed2866848300d5952b2e5efee311ee6bc
dirSha256SumFiles(){
	local -r dir=$1
	if [[ ! -d $dir || ! -r $dir || ! -x $dir ]]; then
		echo "Error. Cannot calculate sha256 sum in directory $dir. Permissions required or directory does not exist. Exit" >&2
		exit 1
	fi
	
	local -r hashes=$(find "$dir" -type f -exec sha256sum {} + | awk '{print $1}'  )
	echo "$hashes"
}

dirCountFiles(){
	local -r dir=$1
	if [[ ! -d $dir || ! -r $dir || ! -x $dir ]]; then
		echo "Error. Cannot get files count in dir $dir. Permissions required or directory does not exist. Exit" >&2
		exit 1
	fi
	
	local -r count=$(find "$dir" -type f | wc -l)
	echo "$count"
}

# getBasename "/absolute-path to folder/file.txt"
# -> file.txt
# Empty extension: getFileExtension "/dir.dir/file"
# ->
# getBasename /
# -> /
# getBasename ./
# -> .
# getBasename .
# -> .
getBasename() {
	local -r path=$1
	
	if [[ -z $path ]]; then
		echo "Error. Cannot get basename from path. Path is empty. Exit" >&2
		exit 1
	fi
	
	#"${_##*/}" is not valid result for some arguments
	local -r basename="$(basename "$path")"
	echo "$basename"
}

# trimLastPathSeparator /path/file/
# -> /path/file
# trimLastPathSeparator /
# -> /
# \path\file\ -> \path\file\
trimLastPathSeparator() {
	local path=$1
	
	if [[ -z $path ]]; then
		echo "Error. Cannot trim last path separator. Path is empty. Exit" >&2
		exit 1
	fi
	
	if [[ $path == "/" ]]; then
		echo "$path"
	else
	
		path="${path%[/]}"
		echo "$path"
	
	fi
}

#convertToSafeName "f:i!l$ e:/n-a*&me"
# -> f_i_l__e__n_a__me
convertToSafe() {
	local -r name=$1
	
	if [[ -z $name ]]; then
		echo "Error. Cannot convert filename to safe form. Filename is empty. Exit" >&2
		exit 1
	fi
	
	local -r replaced=$(echo "$name" | sed -e "s/[[:punct:]\/\\ ]/_/g")
	echo "$replaced"
}

#Example:
#foundFiles=()
#fileIterator() {
	#foundFiles+=("$1")
#}
#dirFiles "$dir" fileIterator
#dirFiles "$dir" fileIterator "-type f -name "out*""
#
#for foundFile in "${foundFiles[@]}"
#do
#echo "File: $foundFile"
#done
dirFiles() {
	if [[ ! -d $1 ]]; then
		echo "Cannot find files in directory $1. Invalid directory received. Exit" >&2
		exit 1
	fi
	 
	if [[ -z $2 ]]; then
		echo "Finded file applyer cannot be empty. Pass function by name. Exit" >&2
		exit 1
	fi
	
	local -r iterator=$2
	
	local findPattern
	if [[ -z $3 ]]; then
		findPattern="-type f"
	else
		findPattern=$3
	fi
	
	if [[ -n $IFS ]]; then
		local -r oldIFS=$IFS
	fi
	
	while IFS= read -rd '' file <&3; do
		"$iterator" "$file" 3<&-
	done 3< <(find "$1" "$findPattern" -print0)
	
	if [[ -n $oldIFS ]]; then
		IFS=$oldIFS
	fi
}

# Copy all files from source to destination. Hidden files are also copied. If the destination directory does not exist, then it will be created.
# Example:
# copyAllFiles "$source" "$dest"
copyAllFiles(){
	if [[ ! -d $1 ]]; then
		echo "Cannot copy all files from directory. Directory not found: $1. Exit" >&2
		exit 1
	fi

	if [[ -z $2 ]]; then
		echo "Cannot copy all files from $1 to $2. Destination is empty. Exit" >&2
		exit 1
	fi

	cp --archive --no-target-directory "$1" "$2"
	if [[ $? -ne 0 ]]; then
		echo "Error copying all files from $1 to $2. Exit" >&2
		exit 1
	fi
}















