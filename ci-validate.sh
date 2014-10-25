#!/bin/bash

cd /data1/breitner/ghc/ghc-validate

function get_branch () 
{
	git branch --list validate/\*|head -n 1|cut -c3-
}

function run (){
	printf "%q " "$@"
	echo
	"$@"
}
function run_quiet (){
	printf "%q " "$@"
	echo
	"$@" > /dev/null 2>&1
}
function run_to (){
	file="$1"
	shift
	printf "%q " "$@"
	echo "-> $file"
	"$@" > "$file" 2>&1
}


while true
do
while [ -z "$(get_branch)" ]; do sleep 1; done

BRANCH="$(get_branch)"
BRANCH_BASE="${BRANCH#validate/}"
LOGFILE="../validate-$BRANCH_BASE-$(date --iso=minutes).log"

echo "I am asked to validate $BRANCH_BASE"

echo "Cleaning up future branch names"
run_quiet ./sync-all --ignore-failure branch -D "validating/$BRANCH_BASE" "validated/$BRANCH_BASE" "broken/$BRANCH_BASE"

echo "Making sure we are on current master"
run_quiet ./sync-all checkout master
run_quiet ./sync-all pull
echo "Switching to that branch"
run_quiet ./sync-all checkout "$BRANCH"
git branch | fgrep -q "* $BRANCH"
echo "moving branch to validating/$BRANCH_BASE"
run_quiet ./sync-all --ignore-failure branch -m "$BRANCH" "validating/$BRANCH_BASE"
echo "Running validate"
export CPUS=8
if run_to "$LOGFILE" ./validate --no-dph 
then
	echo "validate successful"
	echo "moving branch to validated/$BRANCH_BASE"
	run_quiet ./sync-all --ignore-failure branch -m "validating/$BRANCH_BASE" "validated/$BRANCH_BASE"
else
	echo "validate broken"
	echo "moving branch to broken/$BRANCH_BASE"
	run_quiet ./sync-all --ignore-failure branch -m "validating/$BRANCH_BASE" "broken/$BRANCH_BASE"
fi
run_quiet make -C testsuite CLEANUP=1 CLEAN_ONLY=YES
run_quiet make clean
echo Resetting to master and updating 
run_quiet ./sync-all checkout master
run_quiet ./sync-all pull
echo "Waiting for new branches to appear."


sleep 10
done

