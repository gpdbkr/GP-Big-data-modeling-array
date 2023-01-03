CREATE FUNCTION equipment.create_info() RETURNS text
    AS $$
DECLARE
BEGIN

DROP TABLE IF EXISTS equipment.eqp_info;
CREATE TABLE equipment.eqp_info AS
SELECT seq eqp_cd, 'EQP_' || seq as eqp_nm
FROM generate_series(0, 2999, 1) seq
DISTRIBUTED BY (eqp_cd) ;


DROP TABLE IF EXISTS equipment.unit_info;
CREATE TABLE equipment.unit_info AS
SELECT eqp_cd, eqp_nm, ((eqp.eqp_cd)*14 + seq) %  (14*600)unit_cd, 'UINT_' || ((eqp.eqp_cd)*14 + seq) %  (14*600) as unit_nm
FROM generate_series(0, 30, 1) seq,
     equipment.eqp_info eqp
DISTRIBUTED BY (unit_cd);

DROP TABLE IF EXISTS equipment.param_info;
CREATE TABLE equipment.param_info AS
SELECT unit.eqp_cd, unit.eqp_nm, unit.unit_cd, unit.unit_nm,
        ((unit.unit_cd)*200::numeric + seq) % (200*8400) param_cd, 'SENSOR_' || ((unit.unit_cd)*200::numeric + seq) %  (200*8400) as param_nm, clock_timestamp() as create_time, clock_timestamp() as update_time, false as delete_flag
FROM generate_series(0, 199, 1) seq,
     equipment.unit_info unit
DISTRIBUTED BY (param_cd);

DROP TABLE IF EXISTS equipment.process_info;
CREATE TABLE equipment.process_info AS
SELECT seq process_cd, 'P_' || seq process_nm
FROM  generate_series(0, 20, 1) seq
DISTRIBUTED BY (process_cd);

DROP TABLE IF EXISTS equipment.step_info;
CREATE TABLE equipment.step_info AS
SELECT process.process_cd, process.process_nm , (process_cd * 600) + seq step_cd, 'STEP_' || (process_cd * 600) + seq step_seq
FROM  generate_series(0, 599, 1) seq,
      equipment.process_info process
DISTRIBUTED BY (step_cd);

return 'SUCCESS';
END
$$
LANGUAGE plpgsql NO SQL;


CREATE FUNCTION equipment.create_data(start_lot_nm integer, lot_count integer) RETURNS text
    AS $$
DECLARE
	v_sql text;
	idx int := 0;
	lot_nm int;
	lot_start_time timestamp without time zone;
	inserted_cnt bigint;
BEGIN

FOR idx IN 0..(lot_count -1)
LOOP
	lot_nm = start_lot_nm + idx;
	lot_start_time = '2022-01-01 00:00:00'::timestamp without time zone + (((10 * 60)  + (10 * 60) + (10 * 60) + (10 * 60) + (10 * 60) + (10 * 60) * random() ) * lot_nm || ' seconds')::interval;
	v_sql := '
	INSERT INTO equipment.eq_data_raw
	SELECT ''VMWARE'' as line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time, param_value FROM (
	select eqp_cd, eqp_nm, unit_cd, unit_nm, param_cd, param_nm, ''P_'' || (eqp_cd / 600) as processid, ''STEP_'' || eqp_cd as stepseq, ''LOT' || lot_nm || '''::text as root_nm, seq as leaf_nm, 
		''' || lot_start_time || '''::timestamp without time zone +  (((10 * 60) * unit_cd + (10 * 60) * random() ) || '' seconds'')::interval as act_time, round(random()::numeric, 5) as param_value,
		case when random() < 0.34 then 1 else 0 end is_visible
	FROM equipment.param_info, 
		generate_series(1, 24, 1) seq
	WHERE eqp_cd >= 0 and eqp_cd < 600
	order by param_cd, act_time
	)  as a
	WHERE is_visible = 1
	';
	execute v_sql;
	GET DIAGNOSTICS inserted_cnt = ROW_COUNT;
	RAISE NOTICE '%th inserted [%]', idx, inserted_cnt;
END LOOP;

return 'SUCCESS';
END
$$
LANGUAGE plpgsql NO SQL;


CREATE FUNCTION equipment.create_data(start_time timestamp without time zone, start_lot_nm integer, lot_count integer) RETURNS text
    AS $$
DECLARE
	v_sql text;
	idx int := 0;
	lot_nm int;
	lot_start_time timestamp without time zone;
	inserted_cnt bigint;
BEGIN

lot_start_time = start_time;
FOR idx IN 0..(lot_count -1)
LOOP
	lot_nm = start_lot_nm + idx;
	v_sql := '
	INSERT INTO equipment.eq_data_raw
	SELECT ''VMWARE'' as line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time, param_value FROM (
	select eqp_cd, eqp_nm, unit_cd, unit_nm, param_cd, param_nm, ''P_'' || (eqp_cd / 600) as processid, ''STEP_'' || eqp_cd as stepseq, ''LOT' || lot_nm || '''::text as root_nm, seq as leaf_nm, 
		''' || lot_start_time || '''::timestamp without time zone +  (((10 * 60) * unit_cd + (10 * 60) * random() ) || '' seconds'')::interval as act_time, round(random()::numeric, 5) as param_value,
		case when random() < 0.34 then 1 else 0 end is_visible
	FROM equipment.param_info, 
		generate_series(1, 24, 1) seq
	WHERE eqp_cd >= 0 and eqp_cd < 600
	order by param_cd, act_time
	)  as a
	WHERE is_visible = 1
	';
	lot_start_time = lot_start_time + (((10 * 60)  + (10 * 60) * random() ) || ' seconds')::interval;
	RAISE NOTICE 'SQL: [%]', v_sql;
	execute v_sql;
	GET DIAGNOSTICS inserted_cnt = ROW_COUNT;
	RAISE NOTICE '%th inserted [%]', idx, inserted_cnt;
END LOOP;

return 'SUCCESS';
END
$$
LANGUAGE plpgsql NO SQL;

/*
create or replace function equipment.random_string(length integer) returns text as
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;
*/
/*
CREATE FUNCTION equipment.create_data2(start_lot_nm integer, lot_count integer) RETURNS text
    AS $$
DECLARE
        v_sql text;
        idx int := 0;
        lot_nm int;
        lot_start_time timestamp without time zone;
        inserted_cnt bigint;
BEGIN

FOR idx IN 0..(lot_count -1)
LOOP
        lot_nm = start_lot_nm + idx;
        lot_start_time = '2022-01-01 00:00:00'::timestamp without time zone + (((10 * 60)  + (10 * 60) + (10 * 60) + (10 * 60) + (10 * 60) + (10 * 60) * random() ) * lot_nm || ' seconds')::interval;
        v_sql := '
        INSERT INTO equipment.eq_data_raw2
        SELECT ''VMWARE'' as line, eqp_cd, unit_cd, param_cd, processid, stepseq, root_nm, leaf_nm, act_time, param_value1, param_value2, param_value3, param_value4, param_value5 FROM (
        select eqp_cd, eqp_nm, unit_cd, unit_nm, param_cd, param_nm, ''P_'' || (eqp_cd / 600) as processid, ''STEP_'' || eqp_cd as stepseq, ''LOT' || lot_nm || '''::text as root_nm, seq as leaf_nm,
                ''' || lot_start_time || '''::timestamp without time zone +  (((10 * 60) * unit_cd + (10 * 60) * random() ) || '' seconds'')::interval as act_time, round(random()::numeric, 5) as param_value1,equipment.random_string(10) as param_value2,equipment.random_string(10) as param_value3,equipment.random_string(10) as param_value4,equipment.random_string(10) as param_value5,
                case when random() < 0.34 then 1 else 0 end is_visible
        FROM equipment.param_info,
                generate_series(1, 24, 1) seq
        WHERE eqp_cd >= 0 and eqp_cd < 600
        order by param_cd, act_time
        )  as a
        WHERE is_visible = 1
        ';
        execute v_sql;
        GET DIAGNOSTICS inserted_cnt = ROW_COUNT;
        RAISE NOTICE '%th inserted [%]', idx, inserted_cnt;
END LOOP;

return 'SUCCESS';
END
$$
LANGUAGE plpgsql NO SQL;
*/
