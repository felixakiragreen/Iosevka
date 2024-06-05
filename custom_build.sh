#!/bin/bash

# exit early on error
set -e

# steps:
# 1. take the file used in the argument
# 2. create a symlink to the file in the current directory
# 3. run build using symlink and extracted build name

if [ $# -ne 1 ]; then
	echo "Usage: $0 <file>"
	exit 1
fi

FILE=$1

if [ ! -f "$FILE" ]; then
	echo "File $FILE does not exist"
	exit 1
fi


echo "Creating symlink to $FILE"
if [ -L private-build-plans.toml ]; then
	rm -f private-build-plans.toml
fi
ln -s "$FILE" private-build-plans.toml

# Extract the build name from the first line of the toml file using awk
BUILD_NAME=$(awk -F'[][]' '/\[buildPlans\./{print $2; exit}' "$FILE" | cut -d'.' -f2)

# Check if BUILD_NAME is empty
if [ -z "$BUILD_NAME" ]; then
	echo "Failed to extract build name"
	exit 1
fi

echo "Running verda with build name $BUILD_NAME"

# Run the bun build command with the extracted build name
bun run build -- contents::"${BUILD_NAME}"