# 빅데이터 데이터 모델을 위한한 예제 스크립트 / Example scripts for a big data model.

운영계, 서비스계의 데이터 베이스는 온라인 트랜잭션에 최적화된 관계형 정규화 데이터 모델을 적용하지만, 데이터 웨어 하우스나 데이터 마트 같은 분석 업무 데이터베이스에서는 데이터 조회에 필요한 조인을 미리 해 놓은 통합 테이블 형태의 비 정규화 모델을 이용합니다.  비록 테이블 사이즈가 커진다는 단점이 있지만,  데이터 조회 시 조인 연산을 최소화하기 때문에 조회 성능을 향상  시킬 수 있습니다. 하지만 빅데이터 또는 대용량의 데이터 처리시 이러한 통합 테이블을 사용할 때에도 성능이 만족스럽지 않을 수 있습니다.

통합 데이터를 사용할 때에는 테이블 사이즈 뿐만 아니라 인덱스 사이즈도 커지는 단점이 있으며, row수가 많아서 데이터 검색시 검색 부하도 발생됩니다. 데이터가 계속 증가되고, 분석 SLA를 맞출 수 없는 빅데이터 분석 및 처리를 위해서는 더 효율적인 모델링을 적용해야 합니다. 센서의 데이터가 많이 발생되는 제조사 또는 고객 행동 패턴 분석이 필요한 웹로그 분석과 같은 경우 데이터 직렬화를 통해 전체 데이터 행(row)수를 줄였습니다. 이에 따라 인덱스의 크기가 줄어들고 스캔 속도가 빨라져서 조회 성능 개선 효과가 확연하게 드러났습니다. 뿐만 아니라 시스템 리소스 사용량이 줄고 분석 시간이 단축되어 더 많은 분석 쿼리 수행이 가능하게 되었습니다.

실제 운영환경에 적용시 5~10배 이상의 성능 개선효과가 있었습니다.

Operational and service databases apply relational normalized data models optimized for online transactions, but analytic business databases such as data warehouses and data marts use denormalized models with pre-integrated joins required to retrieve data. Although it has the disadvantage of increasing the table size, it can improve query performance because it minimizes the join operation when retrieving data. However, when dealing with big data or large amounts of data, performance may not be satisfactory even with these union tables.

When integrated data is used, not only the size of the table but also the size of the index increases and the number of rows also increases, causing search load when searching for data. Data continues to grow and more efficient modeling must be applied for big data analysis and processing where analytics SLAs cannot be met. In the case of web log analysis that requires analysis of manufacturers or customer behavior patterns that generate a lot of sensor data, the total number of data rows has been reduced through data serialization. This reduced the size of the index and increased the scan speed, which greatly improved query performance. You can also perform more analytic queries with less system resource usage and shorter analysis times.

When applied to the production environment, there was a performance improvement effect of 5 to 10 times or more.

- Demo video
  - 한글 버전: https://youtu.be/_8G0v__y63g
  - English version: https://youtu.be/EdmpJSOX7lw 


## script setup

```
1) Download and unzip the example script
소스를 다운 받아 GP-Big-data-modeling-array-main.zip을 마스터 노드의 /data/ 폴더에 copy

Download the source and copy GP-Big-data-modeling-array-main.zip to the master node's /data folder

[gpadmin@mdw ~]$ cd /data
[gpadmin@mdw data]$ ls -la
-rw-rw-r--   1 gpadmin gpadmin 762536  3월 31 17:53 GP-Big-data-modeling-array-main.zip
[gpadmin@mdw data]$ unzip GP-Big-data-modeling-array-main.zip
[gpadmin@mdw data]$ mv GP-Big-data-modeling-array-main modeling
```


## path and file description
```
[gpadmin@mdw data]$ cd modeling
[gpadmin@mdw modeling]$ ls -la
1.01_create_db.sh             # Create demo DB 
1.02_create_role.sh           # Create role  
1.03_create_tbl.sh            # Create Table 
1.04_create_func.sh           # Create functions to generate data
1.04_create_func.sql          # Functions to generate data
1.05_gen_code.sh              # Generate master code data
1.06_gen_data.sh              # Generate historical data
1.all.sh                      # 1.x run all
2.01_gen_array.sh             # Load raw data in array form
2.02_add_index.sh             # Create indexes 
2.03_table_analyze.sh.        # Gather table statistics
2.04_table_size.sh            # Check table size
2.05_table_cnt.sh             # Check the number of rows in a table
2.06_compare_data_model.sh    # Data model comparison
2.11_raw_single_perf.sh       # Execute single query on denormalization & raw type table
2.12_array_single_perf.sh     # Execute single query on denormalization & array type table
2.21_raw_multi_perf.sh        # Execute multiple queries on denormalization & raw type table
2.22_array_multi_perf.sh      # Execute multiple queries on denormalization & array type table
2.23_multi_perf_result.sh.    # Check the performance result between raw type and array type
2.all.sh
log                           # log folder
query                         # Queries for performance testing

./query:
gen_query.sh                  # create queries 
template_arr.sql              # query template for array data type
template_raw.sql              # query template for normal data type
param_cd_list_0.txt           # Parameter file, automatically generated when gen_query.sh is executed
...
param_cd_list_19.txt

sql_arr_0.sql                 # Query for array data type
...
sql_arr_19.sql

sql_raw_0.sql                 # Queries for raw data types
...
sql_raw_19.sql

./log:                        # log folder

```

## 테이블 스키마 / table schema
```
## raw type
demo=# \d equipment.eq_data_raw_inc
     Append-Only Table "equipment.eq_data_raw_inc"
   Column    |            Type             | Modifiers
-------------+-----------------------------+-----------
 line        | text                        |
 eqp_cd      | integer                     |
 unit_cd     | integer                     |
 param_cd    | numeric                     |
 processid   | text                        |
 stepseq     | text                        |
 root_nm     | text                        |
 leaf_nm     | integer                     |
 act_time    | timestamp without time zone |
 param_value | numeric                     |
Compression Type: zstd
Compression Level: 7
Block Size: 32768
Checksum: t
Indexes:
    "idx_eq_data_raw_inc_03" btree (param_cd)
Number of child tables: 13 (Use \d+ to list them.)
Distributed randomly
Partition by: (act_time)

## array type
demo=# \d equipment.eq_data_raw_with_array_inc
Append-Only Table "equipment.eq_data_raw_with_array_inc"
   Column    |             Type              | Modifiers
-------------+-------------------------------+-----------
 line        | text                          |
 eqp_cd      | integer                       |
 unit_cd     | integer                       |
 param_cd    | numeric                       |
 processid   | text[]                        | ==> Array
 stepseq     | text[]                        | ==> Array
 root_nm     | text[]                        | ==> Array
 leaf_nm     | integer[]                     | ==> Array
 act_time    | timestamp without time zone[] | ==> Array
 param_value | numeric[]                     | ==> Array
 create_time | date                          |
Compression Type: zstd
Compression Level: 7
Block Size: 32768
Checksum: t
Indexes:
    "idx_eq_data_raw_with_array_inc_03" btree (param_cd)
Number of child tables: 13 (Use \d+ to list them.)
Distributed randomly
Partition by: (create_time)
```

## raw table을 array type table로 적재 / load raw table into array type table
raw 데이터를 group by와 array_agg 함수를 이용해서 array data type으로 쉽게 변환할 수 있습니다.

You can easily convert raw data to array data type using group by and array_agg functions.
```
[gpadmin@mdw modeling]$ cat 2.01_gen_array.sh
...
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
...
[gpadmin@mdw modeling]$
```

## array data 타입 쿼리 / array data type query
array 컬럼에 대해서 unnest 함수를 이용하여 array에서 row로 쉽게 전환할 수 있습니다.

You can easily convert from  array to row by using the unnest function for array columns.
```
[gpadmin@mdw modeling]$ cat 2.11_raw_single_perf.sh
...
SELECT
        data.processid,
        data.stepseq,
        data.root_nm,
        data.leaf_nm,
        info.eqp_nm,
        info.unit_nm,
        info.param_nm
FROM equipment.eq_data_raw_inc as data,
equipment.param_info info
WHERE 1 = 1
        AND data.eqp_cd = info.eqp_cd
        AND data.unit_cd = info.unit_cd
        AND data.param_cd = info.param_cd
        and data.param_cd in (1055502,2147982,4146252)
	AND data.act_time >= '2022-01-01 00:00:00' and act_time < '2022-02-28 00:00:00'
;
...
[gpadmin@mdw modeling]$ cat 2.12_array_single_perf.sh
...
SELECT
        unnest(processid) as processid,
        unnest(stepseq) as stepseq,
        unnest(root_nm) as root_nm,
        unnest(leaf_nm) as leaf_nm,
        info.eqp_nm,
        info.unit_nm,
        info.param_nm
FROM equipment.eq_data_raw_with_array_inc data,
equipment.param_info info
WHERE 1 = 1
        AND data.eqp_cd = info.eqp_cd
        AND data.unit_cd = info.unit_cd
        AND data.param_cd = info.param_cd
        and data.param_cd in (1055502,2147982,4146252)
	AND data.create_time >= '2022-01-01 00:00:00' and data.create_time < '2022-02-28 00:00:00'
;
...
```


## 테이블 사이즈 / table size
데이터에 따라서 다르겠지만, 테이블 사이즈도 줄어들고, 인덱스 사이즈가 1% 정도로 아주 많이 줄어들었습니다.

Depending on the data, the table size has also decreased, and the index size has decreased a lot, about 1%.

```
[gpadmin@mdw log]$ cat 2.04_table_size.sh.log
Time: 10.286 ms
 schema_nm |           tb_nm            | tb_total_mb | table_size_mb | index_size_mb
-----------+----------------------------+-------------+---------------+---------------
 equipment | eq_data_raw_inc            |       48887 |         23232 |         25655
 equipment | eq_data_raw_with_array_inc |        7862 |          7706 |           156
```

## 싱글 쿼리 성능/ single query performance
동일한 쿼리 결과이지만, 성능은 대략 5배 정도 차이 발생하였습니다.

The same query results, but the performance is about 5 times different.

```
[gpadmin@mdw log]$ tail 2.1*.out
==> 2.11_raw_single_perf.sh.out <==
 P_0       | STEP_127 | LOT27   |       4 | EQP_127 | UINT_1798 | SENSOR_359776
 P_0       | STEP_127 | LOT26   |      15 | EQP_127 | UINT_1798 | SENSOR_359776
 P_0       | STEP_127 | LOT25   |      22 | EQP_127 | UINT_1798 | SENSOR_359776
 P_0       | STEP_127 | LOT23   |      20 | EQP_127 | UINT_1798 | SENSOR_359776
 P_0       | STEP_127 | LOT22   |      10 | EQP_127 | UINT_1798 | SENSOR_359776
 P_0       | STEP_127 | LOT20   |      19 | EQP_127 | UINT_1798 | SENSOR_359776
(32764 rows)

Time: 1386.944 ms
Result:|./2.11_raw_single_perf.sh|2023-01-02 00:28:55|2023-01-02 00:28:57|2

==> 2.12_array_single_perf.sh.out <==
 P_0       | STEP_210 | LOT28   |      12 | EQP_210 | UINT_2946 | SENSOR_589300
 P_0       | STEP_210 | LOT28   |      12 | EQP_210 | UINT_2946 | SENSOR_589300
 P_0       | STEP_210 | LOT28   |       8 | EQP_210 | UINT_2946 | SENSOR_589300
 P_0       | STEP_210 | LOT28   |       8 | EQP_210 | UINT_2946 | SENSOR_589300
 P_0       | STEP_210 | LOT28   |       8 | EQP_210 | UINT_2946 | SENSOR_589300
 P_0       | STEP_210 | LOT28   |       8 | EQP_210 | UINT_2946 | SENSOR_589300
(32764 rows)

Time: 244.005 ms
Result:|./2.12_array_single_perf.sh|2023-01-02 01:23:42|2023-01-02 01:23:43|1
[gpadmin@mdw log]$
```

## 2000개의 쿼리 성능 테스트 결과 / 2000 queries performance test results
- 테스트 환경/Test environment
  - Master node: 4 vcore, 32GB
  - Data node: 2 node, 8 vcore, 64GB

- 2000개 쿼리 수행 소요시간 / Elapsed time for executing 2000 queries
  - raw data type  : 2040 sec
  - array data type:  257 sec

- 2000개 쿼리 개당 평균 소요시간 / Average elapsed time for each query of 2000 queries:
  - raw data type  : 19969.7 ms
  - array data type:   285.2 ms
```
[gpadmin@mdw log]$ tail 2.2*.log
==> 2.21_raw_multi_perf.sh.log <==
Result:|./2.21_raw_multi_perf.sh|2023-01-02 01:29:29|2023-01-02 02:03:29|2040

==> 2.22_array_multi_perf.sh.log <==
Result:|./2.22_array_multi_perf.sh|2023-01-02 01:23:51|2023-01-02 01:28:08|257

[gpadmin@mdw log]$ cat raw_multi_report.out
raw : result_rows_sum  run_time_sum(ms) avg_run_time(ms)
71823248 4.03388e+07 19969.7
[gpadmin@mdw log]$ cat arr_multi_report.out
array : result_rows_sum  run_time_sum(ms) avg_run_time(ms)
71823248 576233 285.264
[gpadmin@mdw log]$

```

