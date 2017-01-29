#!/bin/bash

function compilefile {
	luac5.1 -s -o $1.lc $1.lua
}

function uploadfile {
	curl -s -A "" -H "Accept:" -H "Expect:" -H "Content-Type:" \
	     "http://$1/file/$2" --data-binary @$2 > /dev/null
}


verb="$1"

if [ "$verb" == "compile" ]; then
	files=${@:2}
	for f in ${files[@]}
	do
		echo "Compiling $f"
		ext=`echo $f | sed 's/.*\.//'`
		noext=`echo $f | sed 's/\(.*\)\..*/\1/'`
		compilefile $noext
	done
elif [ "$verb" == "upload" ]; then
	host="$2"
	files=${@:3}
	for f in ${files[@]}
	do
		echo "Uploading $f"
		uploadfile $host $f
	done
fi