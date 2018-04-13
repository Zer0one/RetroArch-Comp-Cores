#!/bin/bash

### Init
cd -- "$(dirname "$0")"

OLDIFS=$IFS
IFS=$'\n'
shopt -s nullglob


### Variables declaration
dirBase="modules"
dirPrev="$dirBase._previous"
dirCurr="$dirBase.current"
dirNew="$dirBase.new"
dirEq="$dirBase._same"
dirDiff="$dirBase._updated"
dirRem="$dirBase._removed"
dirAdd="$dirBase._added"
fileComp="compCores.txt"
coreExt="dylib"
stopEx="false"


### Check current folders status
## Previous folder
echo "Checking folders status…"
if [ -d "$dirPrev" ]; then
	echo "\"$dirPrev\" folder already exist, please delete and rerun"
	stopEx="true"
fi
## Current folder
if [ ! -d "$dirCurr" ]; then
	echo "Can't find \"$dirCurr\" folder please create it and rerun"
	stopEx="true"
fi
## New folder
if [ ! -d "$dirNew" ]; then
	echo "Can't find \"$dirNew\" folder please create it and rerun"
	stopEx="true"
fi

### Create or re-arrange aux folders
echo "Creating aux folders…"
if [ "$stopEx" == "false" ]; then
	## Move "current" folder content into "previous"
	if [ ! -d "$dirPrev" ]; then
		mv  "./$dirCurr" "./$dirPrev"
	fi
	## Recreate "current" folder
	if [ ! -d "$dirCurr" ]; then
		mkdir "./$dirCurr"
	fi
	## Create "equal" folder
	if [ ! -d "./$dirEq" ]; then
		mkdir "./$dirEq"
	fi
	## Create "updated" folder
	if [ ! -d "./$dirDiff" ]; then
		mkdir "./$dirDiff"
	fi
	## Create "removed" folder
	if [ ! -d "./$dirRem" ]; then
		mkdir "./$dirRem"
	fi
	## Create "add" folder
	if [ ! -d "./$dirAdd" ]; then
		mkdir "./$dirAdd"
	fi

fi

### Compare RetroArch cores/modules
echo "Comparing cores…"
if [ "$stopEx" == "false" ]; then
	## "Calculate" file present on both folder (in a case-insensitive way "-i")
	comm -12i <(ls ./$dirPrev/) <(ls ./$dirNew/) > $fileComp
	
	## Output only if differ "-q", recursive "-r", string is non Zer0 in length "-n"
	while read p; do
		# echo "$dirCurr$p" "$dirNew$p"
		# Manage updated RetroArch core
		if [ -n "$(diff -rq "./$dirPrev/$p" "./$dirNew/$p")" ]; then
			mv "./$dirNew/$p" "./$dirCurr"
			mv "./$dirPrev/$p" "./$dirDiff"
		# Manage equal RetroArch core
		else
			mv "./$dirNew/$p" "./$dirCurr"
			# mv "./$dirPrev/$p" "./$dirEq"
			rm "./$dirPrev/$p"
		fi
	done <$fileComp
	
	for f in "./$dirPrev/"*.$coreExt; do
		# cp "$f" "./$dirCurr"
		mv "$f" "./$dirRem"
	done

	for f in "./$dirNew/"*.$coreExt; do
		cp "$f" "./$dirCurr"
		mv "$f" "./$dirAdd"
	done
fi

### CleanUp folders
echo "Cleaning up…"
if [ "$stopEx" == "false" ]; then	
	rm $fileComp

	rm "./$dirPrev/.DS_Store" > /dev/null 2>&1
	if [ -z "$(ls -A ./$dirPrev)" ]; then
	   rm -r "./$dirPrev"
	fi
	#rm "./$dirNew/.DS_Store" > /dev/null 2>&1
	# if [ -z "$(ls -A ./$dirNew)" ]; then
	#    rm -r "./$dirNew"
	# fi
	rm "./$dirDiff/.DS_Store" > /dev/null 2>&1
	if [ -z "$(ls -A ./$dirDiff)" ]; then
	   rm -r "./$dirDiff"
	fi
	rm "./$dirEq/.DS_Store" > /dev/null 2>&1
	if [ -z "$(ls -A ./$dirEq)" ]; then
	   rm -r "./$dirEq"
	fi
	rm "./$dirRem/.DS_Store" > /dev/null 2>&1
	if [ -z "$(ls -A ./$dirRem)" ]; then
	   rm -r "./$dirRem"
	fi
	rm "./$dirAdd/.DS_Store" > /dev/null 2>&1
	if [ -z "$(ls -A ./$dirAdd)" ]; then
	   rm -r "./$dirAdd"
	fi
fi

### Finish
IFS=$OLDIFS