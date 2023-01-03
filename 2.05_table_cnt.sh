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

/*
select 'equipment.eq_data_raw                     ' as table_nm, count(*) cnt from  equipment.eq_data_raw                    ;
--increase 4 times
select 'equipment.eq_data_raw_inc                 ' as table_nm, count(*) cnt from  equipment.eq_data_raw_inc                ;
select 'equipment.eq_data_raw_with_array_inc      ' as table_nm, count(*) cnt from  equipment.eq_data_raw_with_array_inc     ;

--Master Table
select 'equipment.eqp_info                        ' as table_nm, count(*) cnt from  equipment.eqp_info                       ;
select 'equipment.param_info                      ' as table_nm, count(*) cnt from  equipment.param_info                     ;
select 'equipment.process_info                    ' as table_nm, count(*) cnt from  equipment.process_info                   ;
select 'equipment.step_info                       ' as table_nm, count(*) cnt from  equipment.step_info                      ;
select 'equipment.unit_info                       ' as table_nm, count(*) cnt from  equipment.unit_info                      ;
*/

select 'equipment.eq_data_raw_inc' as table_nm, count(*) cnt 
  from equipment.eq_data_raw_inc;                           

select 'equipment.eq_data_raw_with_array_inc ' as table_nm, count(*) cnt 
  from  equipment.eq_data_raw_with_array_inc;

select 'equipment.eq_data_raw_with_array_inc_unnest' as table_nm
     ,  (select count(*) 
	   from (select unnest(processid) cnt 
                   from equipment.eq_data_raw_with_array_inc
                ) tmp
        ) unnest_cnt;

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

#cat $LOGFILE
