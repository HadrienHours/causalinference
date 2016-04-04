CREATE OR REPLACE function lossstats(VARCHAR) RETURNS text AS
$BODY$
DECLARE
        tbl_t ALIAS FOR $1;
        cid_t integer;
        dir_t integer;
        tid_t integer;
        row RECORD;
	row2 RECORD;
        prevbulk timestamp;
        counter_cid INTEGER;
	losscount INTEGER;
	tocount INTEGER;
	interbulk FLOAT;
	interloss FLOAT;
	counter INTEGER;
	totcnxs INTEGER;
	presence INTEGER;
BEGIN
	FOR row in execute 'SELECT COUNT(*) FROM pg_tables where schemaname = ''public'' and tablename = ''lossburstsummary'' ' LOOP
		IF row.count = 0 THEN
			execute 'CREATE TABLE lossburstsummary
			(
				tablename	VARCHAR,
				tid		INTEGER,
				cnxid		INTEGER,
				reverse		BIT(1),
				burstcount	INTEGER,
				losscount	INTEGER,
				tocount		INTEGER,
				intraloss	FLOAT,
				interloss	FLOAT
			)';
		END IF;
	END LOOP;

	EXECUTE 'SELECT pkt_tid from traces where packets = '''||tbl_t||''' ' into tid_t;
	EXECUTE 'SELECT COUNT(*) from (SELECT distinct cnxid from lossburst where tablename = '''||tbl_t||''') AS foo ' into totcnxs;
	counter := 0;
	FOR row in execute 'SELECT distinct cnxid FROM lossburst where tablename = '''||tbl_t||''' ' LOOP
		counter := counter+1;
		execute 'SELECT count(*) from lossburstsummary where tablename = '''||tbl_t||''' and cnxid = '||row.cnxid||' ' into presence;
		IF presence > 0 THEN
			RAISE NOTICE 'Cnxid % for table % already present in lossburstsummary',row.cnxid,tbl_t;
			CONTINUE;
		END IF;
		FOR row2 in execute 'SELECT * FROM lossburst where tablename = '''||tbl_t||'''  and cnxid = '||row.cnxid||' ' LOOP
			IF prevbulk IS NULL or losscount = 0 THEN
				IF row2.reverse IS NULL THEN
					dir_t := 0;
				ELSE
					dir_t := 1;
				END IF;
				prevbulk := row2.fin;
				losscount := row2.count;
				IF row2.timeout IS NOT NULL THEN
					tocount := 1;
				ELSE
					tocount := 0;
				END IF;
				counter_cid := 1;
				interbulk := 0.0;
				EXECUTE 'SELECT EXTRACT(MINUTES FROM interval '''||row2.interloss||''')*60 + extract(SECONDS FROM interval '''||row2.interloss||''')' into interloss;
			ELSE
				losscount := losscount+row2.count;
				IF row2.timeout IS NOT NULL THEN
                                        tocount := tocount+1;
                                END IF;
				EXECUTE 'SELECT '||interbulk||' + extract(MINUTES FROM (timestamp '''||row2.beg||''' - timestamp '''||prevbulk||'''))*60 + extract(SECONDS FROM (timestamp '''||row2.beg||''' - timestamp '''||prevbulk||''')) ' into interbulk;
				counter_cid := counter_cid + 1;
			END IF;
		END LOOP;
		interbulk := interbulk / counter_cid;
		interloss := interloss / counter_cid;
		IF dir_t = 0 THEN
			--RAISE NOTICE 'About to insert tablename = %, tid =%, cnxid = %, losscount = %, tocount = %, intraloss = %, interloss = %',tbl_t,tid_t,row.cnxid,losscount,tocount,interloss,interbulk;
			EXECUTE 'INSERT INTO lossburstsummary (tablename,tid,cnxid,burstcount,losscount,tocount,intraloss,interloss) VALUES ('''||tbl_t||''','||tid_t||','||row.cnxid||','||counter_cid||','||losscount||','||tocount||','||interloss||','||interbulk||')';
		ELSE
			--RAISE NOTICE 'About to insert tablename = %, tid =%, cnxid = %, reverse = ''1'', losscount = %, tocount = %, intraloss = %, interloss = %',tbl_t,tid_t,row.cnxid,losscount,tocount,interloss,interbulk;
			EXECUTE 'INSERT INTO lossburstsummary (tablename,tid,cnxid,reverse,burstcount,losscount,tocount,intraloss,interloss) VALUES ('''||tbl_t||''','||tid_t||','||row.cnxid||',''1'','||counter_cid||','||losscount||','||tocount||','||interloss||','||interbulk||')';
		END IF;
		interbulk := 0;
		interloss := 0;
		losscount := 0;
		tocount := 0;
		IF counter%10 = 0 THEN
			RAISE NOTICE '% connections treated among %',counter,totcnxs;
		END IF;
	END LOOP;
	RETURN ''||totcnxs||' lines added to table lossburstsummary';
END

$BODY$
language 'plpgsql';
