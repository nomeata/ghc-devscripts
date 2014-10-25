#!/bin/bash

tree1=$1
tree2=$2
mod=$3

if [ -z "$1" -o -z "$2" -o -z "$3" ]
then 
  echo "Usage: $0 tree1 tree2 module-name"
  exit 1
fi

file="$( echo $mod | tr . /)"

path1="$( find $tree1 -path \*$file.hi | grep -v haskell2010 )"
path2="$( find $tree2 -path \*$file.hi | grep -v haskell2010 )"
if [ -z "$path1" ]
then
  echo "Could not find $file.hi in $tree1"
  exit 1
fi
if [ -z "$path2" ]
then
  echo "Could not find $file.hi in $tree2"
  exit 1
fi


${DIFF:-diff -U 10000} \
 <($tree1/inplace/bin/ghc-stage1 --show-iface $path1) \
 <($tree2/inplace/bin/ghc-stage1 --show-iface $path2)


