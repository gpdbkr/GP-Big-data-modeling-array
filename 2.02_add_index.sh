#!/bin/bash

BMT_NO=$0
dir=`pwd -P`
time=`date +"%y%m%d_%H%M%S"`
LOGDIR=/$dir/log
LOGFILE=$LOGDIR"/"$BMT_NO".log"

START_TM1=`date "+%Y-%m-%d %H:%M:%S"`
echo "$0: START TIME : " $START_TM1

###### query start
psql -U udba -d demo -e > $LOGFILE 2>&1 <<-!

--equipment.eq_data_raw
--create index idx_eq_data_raw_03 on equipment.eq_data_raw (param_cd);

--equipment.param_info
create index idx_param_info_01 on equipment.param_info(param_cd);

--equipment.eq_data_raw_inc
create index idx_eq_data_raw_inc_03 on equipment.eq_data_raw_inc (param_cd);

--equipment.eq_data_raw_with_array_inc
create index idx_eq_data_raw_with_array_inc_03 on equipment.eq_data_raw_with_array_inc (param_cd);

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
