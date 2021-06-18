#!/bin/bash
# Script to calculate the coverage percentage of an input lcov file.
# This script print an output for the Github actions

totalLines=0

readedLines=0

while IFS= read -r line; do
    if [[ $line == LF* ]];
    then
      add=${line##*:}
      ((totalLines+=add))
    fi
    if [[ $line == LH* ]];
    then
      add=${line##*:}
      ((readedLines+=add))
    fi
done < "$1"

printf '::set-output name=percentage::%.1f%%\n' "$(echo "$readedLines/$totalLines*100" | bc -l)"