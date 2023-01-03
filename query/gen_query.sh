rm -f sql_raw_*.sql
rm -f sql_arr_*.sql

PARAM_CNT=300
QUERY_CNT=100

## Generating param_cd list
for i in `seq 0 19`
do
echo $i

psql -U gpadmin -d demo -AXtc "
select param_cd
from (
      select query_no, string_agg(param_cd, ',') param_cd
      from (
            select query_no, ((random() * 10000000)::int)::text param_cd
            from    generate_series(1, $PARAM_CNT) param_no,
                    generate_series(1, $QUERY_CNT)  query_no
            ) a
      group by query_no
     ) b
order by query_no
;
" > param_cd_list_${i}.txt
done


## Generating SQL
for j in `seq 0 19`
do 
    echo $j
    for i in `cat param_cd_list_${j}.txt`
    do
        sed "s/XXXXXXXXXX/$i/g" template_raw.sql >> sql_raw_${j}.sql
        sed "s/XXXXXXXXXX/$i/g" template_arr.sql >> sql_arr_${j}.sql
    done
done
