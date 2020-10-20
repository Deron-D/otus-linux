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
	INPUTFILE=$1
	OUTPUTFILE=$2
	BEGINTIME=`head -n 1 $1 |awk '{print $4}'`
	ENDTIME=`tail -n 1 $1 |awk '{print $4}'`
	echo $BEGINTIME; echo $ENDTIME
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
