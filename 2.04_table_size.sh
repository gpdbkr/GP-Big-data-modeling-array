#!/bin/bash


BMT_NO=$0
dir=`pwd -P`
time=`date +"%y%m%d_%H%M%S"`
LOGDIR=/$dir/log
LOGFILE=$LOGDIR"/"$BMT_NO".log"

START_TM1=`date "+%Y-%m-%d %H:%M:%S"`
echo "$0: START TIME : " $START_TM1

###### query start
psql -U udba -d demo -q > $LOGFILE 2>&1 <<-!

 SELECT a.schemaname AS schema_nm
      , a.tb_nm
      , round(sum(a.tb_total_byte)/1024.0/1024.0) tb_total_Mb
      , round(sum(a.table_byte)/1024.0/1024.0)    table_size_Mb
      , round(sum(a.index_byte)/1024.0/1024.0)   index_size_Mb
   FROM ( SELECT st.schemaname
                , split_part(st.relname::text, '_1_prt_'::text, 1) AS tb_nm
                , st.relname AS tb_pt_nm
                , pg_total_relation_size(st.relid) AS tb_total_byte
                , pg_table_size(st.relid) AS table_byte
                , pg_indexes_size(st.relid) AS index_byte
           FROM pg_stat_all_tables st
      JOIN pg_class cl ON cl.oid = st.relid
     WHERE st.schemaname not like 'pg_temp%' 
       AND st.schemaname <> 'pg_toast' 
       AND st.schemaname = 'equipment'
       AND cl.relkind <> 'i'
--       AND cl.relname like 'eq_data_raw_%inc%' 
) a
group by 1, 2
order by 1, 2
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

cat $LOGFILE
