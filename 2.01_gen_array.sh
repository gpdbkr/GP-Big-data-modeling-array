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

truncate table equipment.eq_data_raw_with_array_inc;

INSERT INTO equipment.eq_data_raw_with_array_inc
SELECT line, eqp_cd, unit_cd, param_cd,
	array_agg(processid order by act_time) as processid,
	array_agg(stepseq order by act_time) as stepseq,
	array_agg(root_nm order by act_time) as root_nm,
	array_agg(leaf_nm order by act_time) as root_nm,
	array_agg(act_time order by act_time) as act_time,
	array_agg(param_value order by act_time) as param_value,
	date_trunc('DAY', act_time) create_time
FROM equipment.eq_data_raw_inc
group by line,eqp_cd, unit_cd, param_cd,date_trunc('DAY', act_time)
;
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
