test -d nofib || { echo "No nofib found" ; exit 1 ;  }

set -e

if [ "$1" = "slow" ]
then
  mode=slow
  variant="-slow"
  shift
else
  mode=norm
  variant=""
fi

git fetch origin

name="$(date --iso=minutes)-$(cd ..; git rev-parse HEAD|cut -c-8)"

if [ "$1" != noclean ]
then
	make distclean
	perl boot
	./configure 
fi
/usr/bin/time -o buildtime-$name make -j8
cd nofib/
make clean
make boot
(cd ..; git log origin/master..HEAD; cd nofib; make mode=$mode) 2>&1 |
	tee ../nofib-$name$variant.log
