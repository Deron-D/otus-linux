#!/bin/sh
# Define variables:
# First found log file
LOGFILE=$(find / -type f -name "access-4560-644067.log" | sed '2,$d')
# Lockfile
LOCKFILE=/tmp/httpd_log_analyze.pid
# Report file
REPORTFILE=/tmp/httpd_log_analyze_report.txt
# Number of TOP active IPs
X=10
# Number of TOP requested locations
Y=10
# File for save processed lines
PROCESSEDLINES=/tmp/httpd_log_analyze.tmp
# Email address for the report
EMAIL=vagrant@localhost.localdomain

#Main function
analyze_log_file() {
	INPUTFILE=$1; OUTPUTFILE=$2
	BEGINTIME=`head -n 1 $1 | awk '{print $4}'| sed 's/\[//'`; ENDTIME=`tail -n 1 $1 | awk '{print $4}' | sed 's/\[//'`
        SKIPLINES=${SKIPLINES:-0}
        if [ -f last_run.tmp ];
        then 
    	    SKIPLINES=$(cat $PROCESSEDLINES)
    	    SKIPLINES=$(($SKIPLINES+1))
        fi
	echo "=============================================" > $OUTPUTFILE
	echo "HTTPD usage report                           " >> $OUTPUTFILE
	echo "Analyze period is from $BEGINTIME to $ENDTIME" >> $OUTPUTFILE
	echo "=============================================" >> $OUTPUTFILE
	echo "$X top IP addresses" >> $OUTPUTFILE 
        tail -n +$SKIPLINES $1 | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{print $1, $2}' | head -$X >> $OUTPUTFILE
        echo "---------------------------------------------" >> $OUTPUTFILE
        echo "$Y top requested addresses" >> $OUTPUTFILE
        tail -n +$SKIPLINES $1 | awk '{print $6}' FPAT='[^ ]*|"[^"]*"' | awk '{if($2 != ""){print $2}}'| sort | uniq -c | sort -rn |  awk '{print $1, $2}' | head -$Y   >> $2
        echo "---------------------------------------------" >> $OUTPUTFILE
        echo "All errors since the last launch" >> $OUTPUTFILE
        tail -n +$SKIPLINES $1 |awk '{print $9}' |grep -E "[4-5]{1}[0-9][[:digit:]]" |sort |uniq -c |sort -rn | awk '{print $1, $2}' >> $OUTPUTFILE
        echo "---------------------------------------------" >> $OUTPUTFILE
        echo "A list of all return codes indicating their number since the last launch" >> $OUTPUTFILE
        tail -n +$SKIPLINES $1 | awk '{print $7}' FPAT='[^ ]*|"[^"]*"'| sort | uniq -c | sort -rn | awk '{print $1, $2}' >> $OUTPUTFILE
	echo "---------------------------------------------" >> $OUTPUTFILE
	wc -l $INPUTFILE | awk '{print $1}' > $PROCESSEDLINES

}

if ( set -C; echo "$$" > "$LOCKFILE" ) 2> /dev/nul; 
then
   # set trap
   trap 'rm -f "$LOCKFILE"; exit $?' SIGHUP INT TERM EXIT
   analyze_log_file $LOGFILE $REPORTFILE
   cat $REPORTFILE | mail -s "HTTPD usage report from $BEGINTIME to $ENDTIME" $EMAIL
   rm -f "$LOCKFILE"
   # unset trap
   trap - SIGHUP INT TERM EXIT 
else
   echo "Failed to acquire lockfile: $LOCKFILE."
   echo "Held by $(cat $LOCKFILE)" 
fi
