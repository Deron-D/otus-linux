#!/bin/bash

VERYNICE=19
NOTNICE=-20
WORKDIR=/home
FILE1=testfile1
FILE2=testfile2

run_niced_dd(){
nice -n $1 dd if=/dev/urandom of=$WORKDIR/$2 bs=1M count=1024 2> /dev/null
}

#run time measuring for niced processes
time run_niced_dd $NOTNICE  $FILE1 &
time run_niced_dd $VERYNICE $FILE2 &
wait $(jobs -p)

#clean 
rm -f $WORKDIR/$FILE1
rm -f $WORKDIR/$FILE2
