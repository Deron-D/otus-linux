#!/bin/bash

CLASS1=1
CLASS2=3
IONICE1=0
IONICE2=7
WORKDIR=/home

#create file for test
create_file(){
echo "Please wait. Generating a huge file...."
dd if=/dev/urandom of=$WORKDIR/testfile_src bs=1M count=1024 2> /dev/null
}

#main function
ionice_run(){
    if [[ $1 = 3 ]]; 
    then
	ionice -c $1 dd if=$WORKDIR/testfile_src of=$WORKDIR/test_file_dst_$2 bs=1M iflag=direct;
    else
	ionice -c $1 -n $2  dd if=$WORKDIR/testfile_src of=$WORKDIR/test_file_dst_$2 bs=1M iflag=direct;
    fi  
}

create_file

#save current scheduler value
IOscheduler=$(cat /sys/block/sda/queue/scheduler | awk -F"[" '{print $2}' | awk -F"]" '{print $1}')

#set cfq scheduler value
echo cfq > /sys/block/sda/queue/scheduler

#run time measuring for ionice processes
time ionice_run $CLASS1 $IONICE1 &
time ionice_run $CLASS2 $IONICE2 &
wait $(jobs -p)

#restore saved scheduler value
echo $IOscheduler > /sys/block/sda/queue/scheduler

#clean 
rm -f $WORKDIR/testfile_src
rm -f $WORKDIR/test_file_dst_$IONICE1
rm -f $WORKDIR/test_file_dst_$IONICE2
