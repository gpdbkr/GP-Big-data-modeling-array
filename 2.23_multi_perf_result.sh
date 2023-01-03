#!/bin/bash

BMT_NO=$0
dir=`pwd -P`
time=`date +"%y%m%d_%H%M%S"`
LOGDIR=/$dir/log
LOGFILE=$LOGDIR"/"$BMT_NO".log"

START_TM1=`date "+%Y-%m-%d %H:%M:%S"`
echo "$0: START TIME : " $START_TM1

cat $LOGDIR/sql_raw*.out |grep rows |awk '{print $1}'| sed 's/(//g' | gawk '{sum += $1;cnt++} END {print sum}' > $LOGDIR/raw_multi_report.out
cat $LOGDIR/sql_raw*.out |grep Time |gawk '{sum += $2;cnt++} END {print sum}' >> $LOGDIR/raw_multi_report.out
cat $LOGDIR/sql_raw*.out |grep Time |gawk '{sum += $2;cnt++} END {print sum/cnt}' >> $LOGDIR/raw_multi_report.out
echo $(cat $LOGDIR/raw_multi_report.out | cut -f1 -d' ') > $LOGDIR/raw_multi_report.out
perl -p -i -e '$.==1 and print "raw : result_rows_sum  run_time_sum(ms) avg_run_time(ms) \n"' $LOGDIR/raw_multi_report.out 

cat $LOGDIR/sql_arr*.out |grep rows |awk '{print $1}'| sed 's/(//g' | gawk '{sum += $1;cnt++} END {print sum}' > $LOGDIR/arr_multi_report.out
cat $LOGDIR/sql_arr*.out |grep Time |gawk '{sum += $2;cnt++} END {print sum}' >> $LOGDIR/arr_multi_report.out
cat $LOGDIR/sql_arr*.out |grep Time |gawk '{sum += $2;cnt++} END {print sum/cnt}' >> $LOGDIR/arr_multi_report.out
echo $(cat $LOGDIR/arr_multi_report.out | cut -f1 -d' ') > $LOGDIR/arr_multi_report.out
perl -p -i -e '$.==1 and print "array : result_rows_sum  run_time_sum(ms) avg_run_time(ms) \n"' $LOGDIR/arr_multi_report.out

echo -e " \n"
cat $LOGDIR/raw_multi_report.out
echo -e " \n"
cat $LOGDIR/arr_multi_report.out
echo -e " \n"

END_TM1=`date "+%Y-%m-%d %H:%M:%S"`

SHMS=`echo $START_TM1 | awk '{print $2}'`
EHMS=`echo $END_TM1   | awk '{print $2}'`

SEC1=`date +%s -d ${SHMS}`
SEC2=`date +%s -d ${EHMS}`
DIFFSEC=`expr ${SEC2} - ${SEC1}`

echo "Result:""|"$BMT_NO"|"$START_TM1"|"$END_TM1"|"$DIFFSEC  >> $LOGFILE
echo "$0: End TIME : "$END_TM1

echo -e "\033[43;31m$0: Total Elapsed TIME : "$DIFFSEC "sec\033[0m"
