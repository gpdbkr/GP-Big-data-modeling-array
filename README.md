# 빅데이터 데이터 모델을 위한한 예제 스크립트입니다.

운영계, 서비스계의 데이터 베이스는 온라인 트랜잭션에 최적화된 관계형 정규화 데이터 모델을 적용하지만, 데이터 웨어 하우스나 데이터 마트 같은 분석 업무 데이터베이스에서는 데이터 조회에 필요한 조인을 미리 해 놓은 통합 테이블 형태의 비 정규화 모델을 이용합니다.  비록 테이블 사이즈가 커진다는 단점이 있지만,  데이터 조회 시 조인 연산을 최소화하기 때문에 조회 성능을 향상  시킬 수 있습니다. 하지만 빅데이터 또는 대용량의 데이터 처리시 이러한 통합 테이블을 사용할 때에도 성능이 만족스럽지 않을 수 있습니다.

통합 데이터를 사용할 때에는 테이블 사이즈 뿐만 아니라 인덱스 사이즈도 커지는 단점이 있으며, row수가 많아서 데이터 검색시 검색 부하도 발생됩니다. 데이터가 계속 증가되고, 분석 SLA를 맞출 수 없는 빅데이터 분석 및 처리를 위해서는 더 효율적인 모델링을 적용해야 합니다. 센서의 데이터가 많이 발생되는 제조사 또는 고객 행동 패턴 분석이 필요한 웹로그 분석과 같은 경우 데이터 직렬화를 통해 전체 데이터 행(row)수를 줄였습니다. 이에 따라 인덱스의 크기가 줄어들고 스캔 속도가 빨라져서 조회 성능 개선 효과가 확연하게 드러났습니다. 뿐만 아니라 시스템 리소스 사용량이 줄고 분석 시간이 단축되어 더 많은 분석 쿼리 수행이 가능하게 되었습니다.

테스트를 수행한 동영상은 아래의 링크에 있습니다.
https://www.youtube.com/watch?v=_8G0v__y63g


## 테스트 스크립트 내용

```
1) 스크립트 unzip
소스를 다운 받아 GP-Big-data-modeling-array-main.zip을 마스터 노드의 /data/ 폴더에 copy
[gpadmin@mdw ~]$ cd /data
[gpadmin@mdw data]$ ls -la
-rw-rw-r--   1 gpadmin gpadmin 762536  3월 31 17:53 GP-Big-data-modeling-array-main.zip
[gpadmin@mdw data]$ unzip GP-Big-data-modeling-array-main.zip
[gpadmin@mdw data]$ mv GP-Big-data-modeling-array-main modeling
```


## 경로 및 파일 설명
```
[gpadmin@mdw data]$ cd modeling
[gpadmin@mdw modeling]$ ls -la
1.01_create_db.sh             # demo DB 생성 
1.02_create_role.sh           # role 생성 
1.03_create_tbl.sh            # Table 생성
1.04_create_func.sh           # 데이터 생성하는 함수 생성
1.04_create_func.sql          # 데이터 생성하는 함수
1.05_gen_code.sh              # 코드성 데이터 생성
1.06_gen_data.sh              # 이력성 데이터 생성
1.all.sh                      # 1.x 모두 실행
2.01_gen_array.sh             # raw data를 array 형태로 데이터 적재
2.02_add_index.sh             # 인덱스 추가
2.03_table_analyze.sh.        # 테이블 통계 작업 수행
2.04_table_size.sh            # 테이블 사이즈 확인
2.05_table_cnt.sh             # 테이블 건수 확인
2.06_compare_data_model.sh    # 데이터 모델 비교
2.11_raw_single_perf.sh       # raw 형태 테이블 싱글쿼리 수행
2.12_array_single_perf.sh     # array 형태 테이블 싱글쿼리 수행
2.21_raw_multi_perf.sh        # raw 형태 테이블 멀티 쿼리 수행
2.22_array_multi_perf.sh      # array 형태 테이블 멀티 쿼리 수행 
2.23_multi_perf_result.sh.    # 멀티 쿼리 수행 결과 확인   
2.all.sh
log                           # 로그 폴더
query                         # 테스트 쿼리

./query:
gen_query.sh                  # 쿼리 생성 
template_arr.sql              # 쿼리 템플릿 for array data type
template_raw.sql              # 쿼리 템플릿 for normal data type
param_cd_list_0.txt           # 파라미터 파일, gen_query.sh 수행하면 자동 생성
...
param_cd_list_19.txt

sql_arr_0.sql                 # array data type을 위한 쿼리
...
sql_arr_19.sql

sql_raw_0.sql                 # normal data type을 위한 쿼리
...
sql_raw_19.sql

./log:                        # 로그 폴더 
```
