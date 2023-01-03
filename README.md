# 빅데이터 데이터 모델을 위한한 예제 스크립트입니다.

운영계, 서비스계의 데이터 베이스는 온라인 트랜잭션에 최적화된 관계형 정규화 데이터 모델을 적용하지만, 데이터 웨어 하우스나 데이터 마트 같은 분석 업무 데이터베이스에서는 데이터 조회에 필요한 조인을 미리 해 놓은 통합 테이블 형태의 비 정규화 모델을 이용합니다.  비록 테이블 사이즈가 커진다는 단점이 있지만,  데이터 조회 시 조인 연산을 최소화하기 때문에 조회 성능을 향상  시킬 수 있습니다. 하지만 빅데이터 또는 대용량의 데이터 처리시 이러한 통합 테이블을 사용할 때에도 성능이 만족스럽지 않을 수 있습니다.

통합 데이터를 사용할 때에는 테이블 사이즈 뿐만 아니라 인덱스 사이즈도 커지는 단점이 있으며, row수가 많아서 데이터 검색시 검색 부하도 발생됩니다. 데이터가 계속 증가되고, 분석 SLA를 맞출 수 없는 빅데이터 분석 및 처리를 위해서는 더 효율적인 모델링을 적용해야 합니다. 센서의 데이터가 많이 발생되는 제조사 또는 고객 행동 패턴 분석이 필요한 웹로그 분석과 같은 경우 데이터 직렬화를 통해 전체 데이터 행(row)수를 줄였습니다. 이에 따라 인덱스의 크기가 줄어들고 스캔 속도가 빨라져서 조회 성능 개선 효과가 확연하게 드러났습니다. 뿐만 아니라 시스템 리소스 사용량이 줄고 분석 시간이 단축되어 더 많은 분석 쿼리 수행이 가능하게 되었습니다.

테스트를 수행한 동영상은 아래의 링크에 있습니다.
https://www.youtube.com/watch?v=_8G0v__y63g


## 설정을 위한 작업

```
1) 스크립트 unzip
소스를 다운 받아 gpkrutil-main.zip을 마스터 노드의 /data/ 폴더에 copy
[gpadmin@mdw ~]$ cd /data
[gpadmin@mdw data]$ ls -la
-rw-rw-r--   1 gpadmin gpadmin 762536  3월 31 17:53 gpkrutil-main.zip
[gpadmin@mdw data]$ unzip gpkrutil-main.zip
[gpadmin@mdw data]$ mv gpkrutil-main gpkrutil
[gpadmin@mdw gpkrutil]$ cd gpkrutil
[gpadmin@mdw gpkrutil]$ ls -la
backupconf                  # 설정파일 백업    
cronlog                     # crontool 로그 위치
crontool                    # crontab으로 수행되는 스크립트 위치
gpkrutil_crt_dba_schema.sh  # gpkrutil을 이용시 필요한 테이블 및 VIEW DDL 실행 쉘
gpkrutil_crt_dba_schema.sql # gpkrutil을 이용시 필요한 테이블 및 VIEW DDL SQL
gpkrutil_path.sh            # gpkrutil path 및 DB 운영을 위한 alias 모음
hostfile_all                # Greenplum 마스터 및 데이터 노드 호스트명
hostfile_seg                # Greenplum 데이터 노드 호스트명
knowledge                   # Greenplum 이슈 knowledge 모음
mngdb                       # 수작업으로 필요한 DB 스크립트 
mnghistory                  # 증설 등의 비정기 작업의 이력
mnglog                      # mngdb의 DB 관리 스크립트 수행 로그 위치
mngsys                      # OS 레벨에서 편리한 스크립트
statlog                     # DB 상태로그 위치
stattool                    # DB 상태로그를 수집을 위한 스크립트
temp                        # 아직 반영은 안되었지만, 향후 적용할 스크립트 임시 저장소
[gpadmin@mdw gpkrutil]$ 

2) Path 설정
[gpadmin@mdw ~]$ vi ~/.bashrc
source /data/gpkrutil/gpkrutil_path.sh

[gpadmin@mdw ~]$ source ~/.bashrc

3) Hostfile 설정
각 시스템에 맞도록 설정
[gpadmin@mdw ~]$ cd $GPKRUTIL
[gpadmin@mdw gpkrutil]$ vi hostfile_all
mdw
smdw
sdw1
sdw2
sdw3
sdw4
[gpadmin@mdw gpkrutil]$ vi hostfile_seg
sdw1
sdw2
sdw3
sdw4
[gpadmin@mdw gpkrutil]$

4) gpkrutil을 위한 table 및 VIEW 생성
[gpadmin@mdw gpkrutil]$ ./gpkrutil_crt_dba_schema.sh
[gpadmin@mdw gpkrutil]$ cd mnglog
[gpadmin@mdw mnglog]$ ls -la
-rw-rw-r--  1 gpadmin gpadmin 13284  3월 30 13:50 gpkrutil_crt_dba_schema.log
[gpadmin@mdw mnglog]$ grep  ERROR *.log

5) Crontab 설정
[gpadmin@mdw gpkrutil]$ cd crontool
[gpadmin@mdw crontool]$ cat crontab.txt
* * * * * /bin/bash /data/gpkrutil/crontool/cron_sys_rsc.sh 5 11 &
* * * * * /bin/bash /data/gpkrutil/stattool/dostat 1 1 &
00 00 * * * /bin/bash /data/gpkrutil/crontool/cron_vacuum_analyze.sh &

...
crontab에 적용
[gpadmin@mdw crontool]$ crontab -e 

6) 로그 확인
[gpadmin@mdw crontool]$ cd $GPKRUTIL/statlog
[gpadmin@mdw statlog]$ ls
lt.20220401.txt  qqit.20220401.txt  session.20220401.txt
qq.20220401.txt  rss.20220401.txt   sys.20220401.txt
[gpadmin@mdw statlog]$

[gpadmin@mdw statlog]$ cd $GPKRUTIL/cronlog
[gpadmin@mdw cronlog]$ ls
cron_log_load_2022-03-29.log                  
cron_tb_size_2022-03-30.log                   
cron_vacuum_analyze_gpadmin_2022-03-25.log    
cron_vacuum_analyze_gpperfmon_2022-03-25.log  
killed_idle.20220401.log
[gpadmin@mdw cronlog]$

```

## 기타 사항
1. DB 로그에 쿼리 소요시간을 적재를 위해서는 log_duration을 on으로 설정
```
[gpadmin@mdw cronlog]$ gpconfig -c log_duration -v on --masteronly
[gpadmin@mdw cronlog]$ gpstop -u
```

## 경로 및 파일 설명
```
[gpadmin@mdw gpkrutil]$ ls -lR
backupconf                  # 설정파일 백업    
cronlog                     # crontool 로그 위치
crontool                    # crontab으로 수행되는 스크립트 위치
gpkrutil_crt_dba_schema.sh  # gpkrutil을 이용시 필요한 테이블 및 VIEW DDL 실행 쉘
gpkrutil_crt_dba_schema.sql # gpkrutil을 이용시 필요한 테이블 및 VIEW DDL SQL
gpkrutil_path.sh            # gpkrutil path 및 DB 운영을 위한 alias 모음
hostfile_all                # Greenplum 마스터 및 데이터 노드 호스트명
hostfile_seg                # Greenplum 데이터 노드 호스트명
knowledge                   # Greenplum 이슈 knowledge 모음
mngdb                       # 수작업으로 필요한 DB 스크립트 
mnghistory                  # 증설 등의 비정기 작업의 이력
mnglog                      # mngdb의 DB 관리 스크립트 수행 로그 위치
mngsys                      # OS 레벨에서 편리한 스크립트
statlog                     # DB 상태로그 위치
stattool                    # DB 상태로그를 수집을 위한 스크립트
temp                        # 아직 반영은 안되었지만, 향후 적용할 스크립트 임시 저장소
[gpadmin@mdw gpkrutil]$ 

./crontool:
cron_dstat_log_load.sh      # 시스템 리소스 sys.20220401.txt. 로그를 DB에 업로드
cron_kill_idle.sh           # Idle 세션 kill
cron_log_load.sh            # DB log를 DB에 적재
cron_pghba_sync_backup.sh   # pg_hba.conf, postgresql.conf 백업 및 스탠바이 마스터에 sync
cron_session_cmd_rsc.sh     # 세션의 쿼리 commnad 별 리소스 gathering, (마스터 및 각 세그먼트에 적용 필요)  
cron_sys_rsc.sh             # dstat 로그 크론 등록
cron_tb_size.sh             # 테이블/파티션별 사이즈를 DB에 적재 
cron_vacuum_analyze.sh      # 카탈로그 테이블 vacuum 수행
crontab.txt                 # crontab 등록 예시
run_sys_rsc.sh              # 모든 노드의 system 리소스 dstat 로깅 (기본 5초)

./mngdb:
run_reorg_tb.sh             # 특정 테이블 reorg 수행
vacuum.freeze.template0.sh  # template0 database vacuum full 수행
vacuum_full_analyze.sh      # 카탈로그 Vacuum Full 수행
fn_chk_skew.sql             # 데이터 파일을 이용하여 skew 점검하는 함수 소스
crt_fn_chk_skew.sh          # skew 점검 함수 생성(1회 수행 필요)
chk_skew.sql                # skew 점검(crt_fn_chk_skew.sh 사전 수행 필수)
chk_age_db.sql              # DB 레벨에서 age 점검
chk_age_table.sql           # Table 레벨에서 age 점검
chk_catalog_bloat.sql       # catalog 테이블에 대한 bloat 점검
chk_partition.sql           # 파티션 관리 점검
get_sys_stat.sql            # gpcc의 시스템 리소스 현황으로 부터, 시스템 사용량 추출

./mngsys:
scpall.sh                   # scp를 모든 노드에 수행 
scpseg.sh                   # scp를 세그먼트 노드에 수행
sshall.sh                   # ssh를 모든 노드에 수행
sshkey_copy.sh              # ssh 키를 각 노드에 복사
sshkey_gen.sh               # ssh 키를 생성 (마스터 노드에만 수행 필요)
sshseg.sh                   # ssh를 세그먼트 노드에만 수행
run_proc_cpumem.sh          # 세션 프로세스의 cpu/memory 사용률 수집(각 노드에서 개별 수행 필요, 필요시 crontab에 등록하여 사용)
run_proc_disk.sh            # 세션 프로세스의 disk 사용률 수집(각 노드에서 개별 수행 필요, 필요시 crontab에 등록하여 사용)

./stattool:
dostat                      # 아래의 DB 상태 로깅 스크립트 랩핑
get_qq_active_ss_cnt.sh     # statlog의 qq로그로 부터, 액티브 세션 
lt.sh                       # 락 발생 테이블 로깅
qq.sh                       # 활성 세션 로그
qqit.sh                     # 활성 세션 로그 및 쿼리 일부 로깅
rss.sh                      # resource queue 상태 로깅
session.sh                  # 세션 정보(all, active, idle) 세션 수 로깅
session_user.sh             # 사용자별 세션 카운트 로깅
pgb_user.sh                 # pgbouncer의 사용자별 pool 카운트 로깅

[gpadmin@mdw gpkrutil]$
```
# Realtime-analysis-with-GPSS
# Realtime-analysis-with-GPSS
# Realtime-analysis-with-GPSS
# GP-Big-data-modeling-array
