#!/bin/bash

tree1="$1"
tree2="$2"
benchname="$3"
shift; shift; shift

if [ -z "$tree1" -o -z "$tree2" -o -z "$benchname" ]
then 
  echo "Usage: $0 tree1 tree2 benchname"
  exit 1
fi

path1="$( find $tree1 -path \*/$benchname -type d )"
path2="$( find $tree2 -path \*/$benchname -type d )"

if [ -z "$path1" ]
then
  echo "Could not find a directory $benchname in $tree1"
  exit 1
fi
echo "Found $path1 in $tree1"
if [ -z "$path2" ]
then
  echo "Could not find a directory $benchname in $path2"
  exit 1
fi
echo "Found $path2 in $tree2"

(cd $path1; make clean)
(cd $path2; make clean)

echo Diff follows...

${DIFF:-diff -U 10000} \
 <(cd $path1 && make NoFibRuns=1 2>&1) \
 <(cd $path2 && make NoFibRuns=1 2>&1)


