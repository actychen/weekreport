#!/bin/bash
APP_NAME=`echo $(basename $(readlink -nf $0))`  

printUsage() {
    echo
    echo "Make weekly report from tickets your solved"
    echo
    echo "Syntax: $APP_NAME -w [WEEK]"
    echo
    echo "-w      the year and the number of week, e.g 2017W01"
    echo
    echo "If you don't use -w, it will creat weekly report on last week"
    echo
}

checkweek() {
if [ -z $WEEK ]; then
    echo "Please asign the week of report using -w"
    echo "ex. $APP_NAME -w 2017W01"
    echo "Make Report Use last week "
    echo
    LASTWEEK=`date -d "last week" +%YW%V`
else
    thisYear=`echo $WEEK | cut -d"W" -f1` 
    thisWeek=`echo $WEEK | cut -d"W" -f2`

    if [ "$thisYear" -gt "`date +%Y`" ]; then
        echo "Year is not correct, must less than current year"
        exit
    elif [ "$thisWeek" -gt "52" ]; then
        echo "Week should be less than 52"
        exit
    elif [ "$thisYear" -eq "`date +%Y`" ] && [ "$thisWeek" -gt "`date +%V`" ]; then
	    echo "warn: This week is in the future"
        exit
    else
        LASTWEEK=$WEEK
    fi
fi

}

getTITLE() {
case "$PROJECT" in
    project1)
        TITLE="PROJECT1";;
    project2)
        TITLE="PROJECT2";;
    project3)
        TITLE="PROJECT3";;
    *)
        TITLE="Other";;
esac
}

makeReport() {
    echo
    echo -e "making Weekly report - $LASTWEEK" > $REPORT_MDFILE
    echo -e "========\n" >> $REPORT_MDFILE
    PROJECT_LIST="project1 project2 project3"
    for PROJECT in $PROJECT_LIST
    do
       getTITLE
       REPORT_FILE="$REPORT_DIR/$PROJECT-$LASTWEEK"
       echo -e "### $TITLE :\n" >> $REPORT_MDFILE
       if [ -f $REPORT_FILE ]; then                                                                                   
          echo "LOAD Ticket from REPROT FILE - $REPORT_FILE"
          TICKET_LIST="`cat $REPORT_FILE | cut -d" " -f1`"
          echo -e "TICKET LIST :\n $TICKET_LIST"
	  NUM=0
          for TICKET_ID in $TICKET_LIST
          do
	      NUM=`expr $NUM + 1`
              LASTMONTH=`echo $TICKET_ID | cut -c1-6`
              TICKET_FILE="$BASEDIR/log/$LASTMONTH/$PROJECT-$TICKET_ID.ticket" 
              CALLER_ID="`grep caller_id $TICKET_FILE | cut -d: -f2 | cut -d" " -f2-`"
              ISSUE="`grep ISSUE $TICKET_FILE | cut -d: -f2- | cut -d" " -f2-`"
              echo -e "    $NUM. $ISSUE (uid:$CALLER_ID)" >> $REPORT_MDFILE
          done
          echo
       fi
       echo -e "\n" >> $REPORT_MDFILE
    done                        
    cat $REPORT_MDFILE

}


while getopts "w:" OPTNAME
do
    case $OPTNAME in
        w)
            WEEK="$OPTARG";;
        *)
            printUsage
            exit;;
    esac
done

# main program
if [ "`uname -s`" != "Linux" ]; then
    echo "Please run this on Linux"
    exit
fi

NOW=`date +"%Y%m%d"`
checkweek

echo "Use $LASTWEEK to make report"
BASEDIR=$(dirname "$0")
REPORT_DIR="$BASEDIR/report/`echo $LASTWEEK | cut -d"W" -f1`"

if [ ! -d $REPORT_DIR ]; then
    echo "No report found"
    echo "please create ticket first"
    exit
fi

echo "REPORTDIR : $REPORT_DIR"

REPORT_MDFILE="$REPORT_DIR/WEEKREPRT-${LASTWEEK}.md"

if [ ! -f $REPORT_MDFILE ]; then
    makeReport
else
    echo "Weekly report - $LASTWEEK already exists."
    read -p "Do you want to overwirte ? (y/n)" overwrite
    case "$overwrite" in
        y|Y)
            echo "Yes - making report"
            makeReport;;
        n|N)
            echo "No - stop";;
    esac
fi
