#!/bin/bash


# Navigation script to check if directory exisits
# in sub directories of system home directory.
#
# Script uses DFS to navigate down paths one by one
# until it reaches the end, if the script recognises
# the target directory, it terminates script and jumps
# the user to the directory.
# 
# @param target_dir: directory user wants to jump to
function  dnav() {
  start_dir="$HOME"
  target_dir="$1"

  stack=("$start_dir")
  found_path=""

  while [ ${#stack[@]} -gt 0 ]; do
    current_dir="${stack[-1]}"
    stack=("${stack[@]:0:${#stack[@]}-1}")

    if [ "$(basename "$current_dir")" == "$target_dir" ]; then
      found_path="$current_dir"
      break
    fi

    for file in "$current_dir"/*; do
      if [ -d "$file" ]; then
        stack+=("$file")
      fi
    done
  done

  if [ -n "$found_path"]; then
    cd "$found_path" || exit
  else
    echo "Directory '$target_dir' not found on system"
  fi
}
