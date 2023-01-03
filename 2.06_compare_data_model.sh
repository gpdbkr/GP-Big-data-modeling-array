#!/bin/bash
psql -U udba -d demo -e <<-!
\d equipment.eq_data_raw_inc;
\d equipment.eq_data_raw_with_array_inc;
select * from equipment.eq_data_raw_inc where eqp_cd = 0 and unit_cd = 0 and param_cd = 85;
\x
select * from equipment.eq_data_raw_with_array_inc where eqp_cd = 0 and unit_cd = 0 and param_cd = 85 limit 1;
\x
select line,eqp_cd,unit_cd,param_cd,unnest(processid),unnest(stepseq),unnest(root_nm),unnest(leaf_nm),unnest(act_time),unnest(param_value) from equipment.eq_data_raw_with_array_inc where eqp_cd = 0 and unit_cd = 0 and param_cd = 85; 
!

