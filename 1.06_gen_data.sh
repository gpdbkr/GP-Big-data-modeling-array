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

--generating 2 months data for Jan and Feb 2022
select equipment.create_data(20,10);

--increasing 4 times for Jan and Feb 2022
INSERT INTO equipment.eq_data_raw_inc
(line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time, param_value)
select *
from   equipment.eq_data_raw
where  act_time >= '2022-01-01'::timestamp
and    act_time  < '2022-03-01'::timestamp
;

INSERT INTO equipment.eq_data_raw_inc
(line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time, param_value)
select
       line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time + '1 second'::interval, param_value
from   equipment.eq_data_raw
where  act_time >= '2022-01-01'::timestamp
and    act_time  < '2022-03-01'::timestamp
;

INSERT INTO equipment.eq_data_raw_inc
(line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time, param_value)
select
       line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time + '3 second'::interval, param_value
from   equipment.eq_data_raw
where  act_time >= '2022-01-01'::timestamp
and    act_time  < '2022-03-01'::timestamp
;

INSERT INTO equipment.eq_data_raw_inc
(line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time, param_value)
select
       line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time + '5 second'::interval, param_value
from   equipment.eq_data_raw
where  act_time >= '2022-01-01'::timestamp
and    act_time  < '2022-03-01'::timestamp
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
