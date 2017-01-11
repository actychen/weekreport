#!/bin/bash

printUsage() {
    echo
    echo "Create ticket and add ticket into weekly report"
    echo
    echo "syntax : create_ticket -p PROJECT -u USERID|EMAIL -m COMMENT [ -f attachefile ] [ -t TO ]"
    echo
    echo "-t    send email to TO "
    echo
}

checkProject() {
# put all kind of jobs into the group
projectlist="project1|project2|project3"
mainproject="project1"

if [ -z "$PROJECT" ]; then
    echo "Please asign the group of ticket using -p"
    echo "Use $mainproject as default"
    PROJECT="$mainproject"
else
    if [ -z "`echo $PROJECT | egrep $projectlist`" ]; then
       echo
       echo "NoT support this group : $PROJECT"
       echo "Use $mainproject as default"
       echo
       PROJECT="$mainproject"
    fi
fi
}

while getopts "p:u:m:f:t" OPTNAME
do
    case $OPTNAME in
        p)
            PROJECT="$OPTARG";;
        u)
            CALLERID="`echo $OPTARG | cut -d@ -f1`";;
        m)
            COMMENT="$OPTARG";;
        f)
            FILEATTCHED="$OPTARG";;
        t)
            TO="$OPTARG"
            SENDMAIL="YES";;
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

checkProject

# check comment
if [ -z "$COMMENT" ]; then
    echo "Please add commment for this ticket using -m"
    exit
fi
ASSIGN=$LOGNAME

echo "Project : $Project"

NOW=`date +"%Y%m%d-%H%M%S"`
WEEK=`date +"%YW%V"`

BASEDIR=$(dirname "$0")
TICKET_DIR="$BASEDIR/log/`date +"%Y%m"`"
if [ ! -d $TICKET_DIR ]; then
   mkdir -p $TICKET_DIR
fi 

SHA1SUM_FILE="$BASEDIR/log/`date +"%Y%m"`/$PROJECT-`date +"%Y%m"`.sha1sum"


TICKET_FILE="$TICKET_DIR/${PROJECT}-${NOW}.ticket"
echo "Write ticket to $TICKET_FILE"
echo "Subject : $COMMENT"
echo

echo "caller_id: $CALLERID" >> $TICKET_FILE
echo "assigned_to : $ASSIGN" >> $TICKET_FILE
echo "ISSUE : $COMMENT" >> $TICKET_FILE 

if [ ! -z $FILEATTCHED ] ;then
    if [ -f $FILEATTCHED ]; then
        echo " " >> $TICKET_FILE 
        cat $FILEATTCHED >> $TICKET_FILE
    else
        echo "$FILEATTCHED not found"
    fi
fi

#check sha1sum
TICKET_SHA1SUM=`sha1sum $TICKET_FILE | cut -d " " -f1`

if [ -z "`grep $TICKET_SHA1SUM $SHA1SUM_FILE`" ]; then
   echo "$TICKET_SHA1SUM $TICKET_FILE" >> $SHA1SUM_FILE
else
   echo "This ticket was summited as same titile"
   echo "Please change a new comment for your ticket"
   echo 
   echo "$TICKET_FILE deleted"
   rm -f $TICKET_FILE
   exit
fi

echo "----------"
cat "$TICKET_FILE"
echo "----------"

# add ticket to weeklyreport
REPORT_DIR="$BASEDIR/report/`date +"%Y"`"
if [ ! -d $REPORT_DIR ]; then
   mkdir -p $REPORT_DIR
fi
REPORT_FILE="$REPORT_DIR/${PROJECT}-$WEEK"
echo "put this ticket to report $REPORT_FILE" 
echo "$NOW $COMMENT" >> $REPORT_FILE

# crate ticket by mail

if [ ! -z $TO  ]; then
    echo "mail -s '${COMMENT}' $TO < $TICKET_FILE"
    echo
    mail -s "$COMMENT" $PROJECT $TO < $TICKET_FILE
fi

