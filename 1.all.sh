#!/bin/bash

./1.01_create_db.sh
./1.02_create_role.sh
./1.03_create_tbl.sh
./1.04_create_func.sh
./1.05_gen_code.sh
./1.06_gen_data.sh

dir=`pwd -P`
time=`date +"%y%m%d_%H%M"`
LOGDIR=$dir/log
FILE_PATH_NM=$LOGDIR"/Summary_"$time.log

echo "Result|Work_name|Start_time|End_time|Elapsed_time(sec)" > $FILE_PATH_NM
cat $LOGDIR/*.log |grep 'Result:' >> $FILE_PATH_NM
cat $FILE_PATH_NM
