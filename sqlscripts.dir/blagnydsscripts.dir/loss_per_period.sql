CREATE OR REPLACE FUNCTION loss_per_period(VARCHAR,INTEGER,INTEGER,INTERVAL) RETURNS SETOF RECORD AS
$BODY$
DECLARE
	tbl_t ALIAS FOR $1;
	cid_t ALIAS FOR $2;
	dir_t ALIAS FOR $3;
	per_t ALIAS FOR $4;
	row RECORD;
	rv RECORD;
	start_t timestamp;
	end_t timestamp;
	retr numeric;
	ro numeric;
	dup numeric;
	COUNTER INTEGER;
BEGIN
	if dir_t = 0 then
		EXECUTE 'select min(ts) from '||tbl_t||' where cnxid = '||cid_t||' and reverse is null' INTO start_t;
		EXECUTE 'select max(ts) from '||tbl_t||' where cnxid = '||cid_t||' and reverse is null' INTO end_t;
		
	else
		EXECUTE 'select max(ts) from '||tbl_t||' where cnxid = '||cid_t||' and reverse is not null' INTO end_t;
		EXECUTE 'select min(ts) from '||tbl_t||' where cnxid = '||cid_t||' and reverse is not null' INTO start_t;
	end if;
	COUNTER := 0;
	WHILE start_t < end_t LOOP
		if COUNTER % 100 = 0 then
			RAISE NOTICE 'Computing loss for time %, period % (end is %)',start_t,per_t,end_t;
		end if;
		execute 'select retr from retr_rate('||cid_t||','||dir_t||','''||tbl_t||''','''||start_t||''','''||per_t||''') as t(retr numeric,ro numeric,dup numeric)' into retr;
		execute 'select ro from retr_rate('||cid_t||','||dir_t||','''||tbl_t||''','''||start_t||''','''||per_t||''') as t(retr numeric,ro numeric,dup numeric)' into ro;
		execute 'select dup from retr_rate('||cid_t||','||dir_t||','''||tbl_t||''','''||start_t||''','''||per_t||''') as t(retr numeric,ro numeric,dup numeric)' into dup;
		SELECT INTO rv start_t, retr,ro,dup;
		execute 'select timestamp '''||start_t||''' + interval '''||per_t||''' ' into start_t;
		RETURN NEXT rv;
		COUNTER := COUNTER+1;
	END LOOP;
END
$BODY$
language 'plpgsql';

