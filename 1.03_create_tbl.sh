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

DROP SCHEMA IF EXISTS  equipment CASCADE;
CREATE SCHEMA equipment;

CREATE TABLE equipment.eqp_info (
    eqp_cd integer,
    eqp_nm text
) DISTRIBUTED BY (eqp_cd);

CREATE TABLE equipment.unit_info (
    eqp_cd integer,
    eqp_nm text,
    unit_cd integer,
    unit_nm text
) DISTRIBUTED BY (unit_cd);

CREATE TABLE equipment.param_info (
    eqp_cd integer,
    eqp_nm text,
    unit_cd integer,
    unit_nm text,
    param_cd numeric,
    param_nm text,
    create_time timestamp,
    update_time timestamp,
    delete_flag boolean default false
) DISTRIBUTED BY (param_cd);

CREATE TABLE equipment.process_info (
    process_cd integer,
    process_nm text
) DISTRIBUTED BY (process_cd);


CREATE TABLE equipment.step_info (
    process_cd integer,
    process_nm text,
    step_cd integer,
    step_seq text
) DISTRIBUTED BY (step_cd);

-- History Table 
CREATE TABLE equipment.eq_data_raw (
    line text,
    eqp_cd integer,
    unit_cd integer,
    param_cd numeric,
    processid text,
    stepseq text,
    root_nm text,
    leaf_nm integer,
    act_time timestamp without time zone,
    param_value numeric
)
WITH (appendonly=true, compresstype=zstd, compresslevel=7) DISTRIBUTED RANDOMLY PARTITION BY RANGE(act_time)
          (
          partition p2201 start('2022-01-01') end ('2022-02-01'),
          partition p2202 start('2022-02-01') end ('2022-03-01'),
          partition p2203 start('2022-03-01') end ('2022-04-01'),
          partition p2204 start('2022-04-01') end ('2022-05-01'),
          partition p2205 start('2022-05-01') end ('2022-06-01'),
          partition p2206 start('2022-06-01') end ('2022-07-01'),
          partition p2207 start('2022-07-01') end ('2022-08-01'),
          partition p2208 start('2022-08-01') end ('2022-09-01'),
          partition p2209 start('2022-09-01') end ('2022-10-01'),
          partition p2210 start('2022-10-01') end ('2022-11-01'),
          partition p2211 start('2022-11-01') end ('2022-12-01'),
          partition p2212 start('2022-12-01') end ('2023-01-01'),
          DEFAULT PARTITION pothers
          );

-- History raw table after 3 times increment
CREATE TABLE equipment.eq_data_raw_inc (
    line text,
    eqp_cd integer,
    unit_cd integer,
    param_cd numeric,
    processid text,
    stepseq text,
    root_nm text,
    leaf_nm integer,
    act_time timestamp without time zone,
    param_value numeric
)
WITH (appendonly=true, compresstype=zstd, compresslevel=7) DISTRIBUTED RANDOMLY PARTITION BY RANGE(act_time)
          (
          partition p2201 start('2022-01-01') end ('2022-02-01'),
          partition p2202 start('2022-02-01') end ('2022-03-01'),
          partition p2203 start('2022-03-01') end ('2022-04-01'),
          partition p2204 start('2022-04-01') end ('2022-05-01'),
          partition p2205 start('2022-05-01') end ('2022-06-01'),
          partition p2206 start('2022-06-01') end ('2022-07-01'),
          partition p2207 start('2022-07-01') end ('2022-08-01'),
          partition p2208 start('2022-08-01') end ('2022-09-01'),
          partition p2209 start('2022-09-01') end ('2022-10-01'),
          partition p2210 start('2022-10-01') end ('2022-11-01'),
          partition p2211 start('2022-11-01') end ('2022-12-01'),
          partition p2212 start('2022-12-01') end ('2023-01-01'),
          DEFAULT PARTITION pothers
          );
-- History array table after 3 times increment
CREATE TABLE equipment.eq_data_raw_with_array_inc (
    line text,
    eqp_cd integer,
    unit_cd integer,
    param_cd numeric,
    processid text[],
    stepseq text[],
    root_nm text[],
    leaf_nm integer[],
    act_time timestamp without time zone[],
    param_value numeric[],
    create_time date
)
WITH (appendonly=true, compresstype=zstd, compresslevel=7) DISTRIBUTED RANDOMLY PARTITION BY RANGE(create_time)
          (
          partition p2201 start('2022-01-01') end ('2022-02-01'),
          partition p2202 start('2022-02-01') end ('2022-03-01'),
          partition p2203 start('2022-03-01') end ('2022-04-01'),
          partition p2204 start('2022-04-01') end ('2022-05-01'),
          partition p2205 start('2022-05-01') end ('2022-06-01'),
          partition p2206 start('2022-06-01') end ('2022-07-01'),
          partition p2207 start('2022-07-01') end ('2022-08-01'),
          partition p2208 start('2022-08-01') end ('2022-09-01'),
          partition p2209 start('2022-09-01') end ('2022-10-01'),
          partition p2210 start('2022-10-01') end ('2022-11-01'),
          partition p2211 start('2022-11-01') end ('2022-12-01'),
          partition p2212 start('2022-12-01') end ('2023-01-01'),
          DEFAULT PARTITION pothers
          );
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
