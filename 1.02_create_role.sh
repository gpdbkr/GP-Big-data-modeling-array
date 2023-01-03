#!/bin/bash

BMT_NO=$0
dir=`pwd -P`
time=`date +"%y%m%d_%H%M%S"`
LOGDIR=/$dir/log
LOGFILE=$LOGDIR"/"$BMT_NO".log"

START_TM1=`date "+%Y-%m-%d %H:%M:%S"`
echo "$0: START TIME : " $START_TM1

###### query start
psql -U gpadmin -d demo -e > $LOGFILE 2>&1 <<-!

/* Drop Object*/

DROP SCHEMA IF EXISTS  equipment CASCADE;

DROP ROLE IF EXISTS udba;
DROP ROLE IF EXISTS uadhoc;
DROP ROLE IF EXISTS uoltp;
DROP ROLE IF EXISTS uetl;

DROP RESOURCE QUEUE rqoltp;
DROP RESOURCE QUEUE rqadhoc;
DROP RESOURCE QUEUE rqbatch;

/* Resource Group */
CREATE RESOURCE GROUP rgoltp WITH (concurrency=30, cpu_rate_limit=30, memory_limit=0);
CREATE RESOURCE GROUP rgadhoc WITH (concurrency=30, cpu_rate_limit=20, memory_limit=0);
CREATE RESOURCE GROUP rgbatch WITH (concurrency=30, cpu_rate_limit=10, memory_limit=0);

/* Role */
CREATE ROLE uoltp   LOGIN ENCRYPTED PASSWORD 'uoltp'   RESOURCE QUEUE rqoltp;
CREATE ROLE uadhoc  LOGIN ENCRYPTED PASSWORD 'uadhoc'  RESOURCE QUEUE rqadhoc;
CREATE ROLE udba    LOGIN ENCRYPTED PASSWORD 'udba'    RESOURCE QUEUE rqbatch;
CREATE ROLE uetl    LOGIN ENCRYPTED PASSWORD 'changeme';

alter role uoltp  resource group rgoltp;
alter role uadhoc resource group rgadhoc;
alter role udba   resource group rgbatch;

/* Schema */
CREATE SCHEMA equipment;


/* Grant */
GRANT ALL ON SCHEMA equipment TO uoltp ;
GRANT ALL ON SCHEMA equipment TO uadhoc ;
GRANT ALL ON SCHEMA equipment TO udba   ;
GRANT ALL ON SCHEMA equipment TO uetl;

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
