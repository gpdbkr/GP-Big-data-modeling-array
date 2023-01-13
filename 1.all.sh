#!/bin/bash

function load_hba() {
  ## need to add the new roles to pg_hba.conf file before proceeding
  # to define $MASTER_DATA_DIRECTORY or $COORDINATE_DATA_DIRECTION, which is used in gp7
  GP_VERSION=$(psql -v ON_ERROR_STOP=1 -t -A -c "SELECT CASE WHEN POSITION ('Greenplum Database 4.3' IN version) > 0 THEN 'gpdb_4_3' WHEN POSITION ('Greenplum Database 5' IN version) > 0 THEN 'gpdb_5' WHEN POSITION ('Greenplum Database 6' IN version) > 0 THEN 'gpdb_6' WHEN POSITION ('Greenplum Database 7' IN version) > 0 THEN 'gpdb_7' ELSE 'postgresql' END FROM version();")
  if [ "${GP_VERSION}" == "gpdb_7" ]; then
      MASTER_DATA_DIRECTORY=$COORDINATOR_DATA_DIRECTORY
  else
      MASTER_DATA_DIRECTORY=$MASTER_DATA_DIRECTORY
  fi

  echo -e "local    demo     udba         trust" >> $MASTER_DATA_DIRECTORY/pg_hba.conf
  echo -e "local    demo     uadhoc       trust" >> $MASTER_DATA_DIRECTORY/pg_hba.conf
  echo -e "local    demo     uoltp        trust" >> $MASTER_DATA_DIRECTORY/pg_hba.conf
  echo -e "local    demo     uetl         trust" >> $MASTER_DATA_DIRECTORY/pg_hba.conf

  ## reload the pg_hba.conf file
  psql -d template1 -c "select pg_reload_conf();"
}

./1.01_create_db.sh
./1.02_create_role.sh

# Need to add entry to pg_hba.conf file for new roles before proceeding to step1.03
load_hba

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
