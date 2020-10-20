#!/bin/sh
# Define variables:
# log file
LOGFILE=./access-4560-644067.log
# Lockfile
LOCKFILE=/tmp/httpd_log_analyze.pid
# Report file
REPORTFILE=./reportfile.txt
# Number of TOP active IPs
X=10
# Number of TOP requested locations
Y=10
# Email address for the report
EMAIL=root@localhost

#Main function
analyze_log_file() {
	INPUTFILE=$1; OUTPUTFILE=$2
	BEGINTIME=`head -n 1 $1 |awk '{print $4}'| cut -c2-`; ENDTIME=`tail -n 1 $1 |awk '{print $4}' | cut -c2-`
	echo "=============================================" > $OUTPUTFILE
	echo "HTTPD usage report                           " >> $OUTPUTFILE
	echo "Analyze period is from $BEGINTIME to $ENDTIME" >> $OUTPUTFILE
	echo "=============================================" >> $OUTPUTFILE
	echo "$X IP addresses (with the largest number of requests)" >> $OUTPUTFILE 
        cat $1 |awk '{print $1}' |sort |uniq -c |sort -rn| tail -$X >> $OUTPUTFILE
        echo "---------------------------------------------" >> $OUTPUTFILE
        echo "$Y requested addresses (with the largest number of requests)" >> $OUTPUTFILE
        cat $1 |awk '{print $7}' |sort |uniq -c |sort -rn| tail -$Y >> $2
        echo "---------------------------------------------" >> $OUTPUTFILE
        echo "All errors since the last launch" >> $OUTPUTFILE
        cat $1 |awk '{print $9}' |grep -E "[4-5]{1}[0-9][0-9]" |sort |uniq -c |sort -rn >> $OUTPUTFILE
        echo "---------------------------------------------" >> $OUTPUTFILE
        echo "A list of all return codes indicating their number since the last launch" >> $OUTPUTFILE
        cat $1 |awk '{print $9}' |sort |uniq -c |sort -rn >> $OUTPUTFILE
	echo "---------------------------------------------" >> $OUTPUTFILE

}


if ( set -C; echo "$$" > "$LOCKFILE" ) 2> /dev/null; 
then
    trap 'rm -f "$LOCKFILE"; exit $?' INT TERM EXIT
    #while true
    #do
    #    # What to do
    #    ls -ld ${LOCKFILE}
    #    sleep 1
    #done
   #Do It
   analyze_log_file $LOGFILE $REPORTFILE
   rm -f "$LOCKFILE"
   trap - INT TERM EXIT 
else
   echo "Failed to acquire lockfile: $LOCKFILE."
   echo "Held by $(cat $LOCKFILE)" 
fi
