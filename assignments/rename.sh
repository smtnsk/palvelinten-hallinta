#!/bin/bash

find . -type f -name "README.md" |
	while read -r LINE; do
		FOLDER="$(sed 's|./||;s|/READ.*||' <<< $LINE)"
		
		sed -i '' "s|/H./|/$FOLDER/|g" "$LINE"
	done

unset FOLDER
