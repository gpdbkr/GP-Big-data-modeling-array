#!/bin/bash

BMT_NO=$0
dir=`pwd -P`
time=`date +"%y%m%d_%H%M%S"`
LOGDIR=/$dir/log
LOGFILE=$LOGDIR"/"$BMT_NO".log"

START_TM1=`date "+%Y-%m-%d %H:%M:%S"`
echo "$0: START TIME : " $START_TM1

###### query start
psql -U gpadmin -d template1 -e > $LOGFILE 2>&1 <<-!

--drop database if exists demo;
create database demo encoding='UTF8';

select 'demo' dbname, pg_size_pretty(pg_Database_size('demo'));

SELECT
    t.schemaname,
    t.tablename,
    t.tableowner
FROM
    pg_tables t
    LEFT JOIN pg_class c ON t.tablename = c.relname
WHERE
    t.schemaname NOT IN ('pg_catalog', 'information_schema','gp_toolkit')
ORDER BY 1, 2;

select * from gp_segment_configuration order by 1;

!
###### query end

END_TM1=`date "+%Y-%m-%d %H:%M:%S"`

SHMS=`echo $START_TM1 | awk '{print $2}'`
EHMS=`echo $END_TM1   | awk '{print $2}'`

SEC1=`date +%s -d ${SHMS}`
SEC2=`date +%s -d ${EHMS}`
DIFFSEC=`expr ${SEC2} - ${SEC1}`

echo "Result:""|"$BMT_NO"|"$START_TM1"|"$END_TM1"|"$DIFFSEC  >> $LOGFILE
echo "$0: End TIME : "$END_TM1

echo -e "\033[43;31m$0: Total Elapsed TIME : "$DIFFSEC "sec\033[0m"

