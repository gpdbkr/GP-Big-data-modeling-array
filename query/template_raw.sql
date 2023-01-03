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
        and data.param_cd in (XXXXXXXXXX)
	AND data.act_time >= '2022-01-01 00:00:00' and act_time < '2022-02-28 00:00:00'
;
