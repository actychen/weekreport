weeklyreport
============

This is a simple script for making weekly report

Future
------

 - create a ticket
 - prevent duplicate tickets
 - make weekly report

Usage
-----

## create ticket

create_ticket.sh -p project1 -u "user1" -m "do test1 for project1"

    -p : the short name of the project
    -u : you customer name or id
    -m : comment what you did

you can define your projects in this script.

## make report

    make_report -w 2017W01
    -w : the year and the number of the week, the default is last week
    ps. the first day of a week is Monday

Things to do
============
customize groups for project
