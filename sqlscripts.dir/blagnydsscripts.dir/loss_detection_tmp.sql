--this function is detecting a packet disturbance for a given connection in a given table by checking SN and IPID
--Each packet out of the sequence is flagged as retransmission (1), duplicate (2) or reordering (3) rto (4)
CREATE OR REPLACE FUNCTION loss_detection(INTEGER,INTEGER,VARCHAR) RETURNS SETOF RECORD AS
$BODY$
DECLARE
	tbl_t ALIAS FOR $3;
	cid_t ALIAS FOR $1;
	dir_t ALIAS FOR $2;
	row RECORD;
	tid SMALLINT;
	j INTEGER;
	query VARCHAR(500);
	biggest BIGINT;
	max_ipid BIGINT;
	prev_ts timestamp;
	rtt_t interval;
	rtt_m interval;
	rto_t interval;
	err_t interval;
	std_t interval;
	code INTEGER;
	counter INTEGER;
BEGIN

	for row in execute 'select count(*) from pg_tables where tablename = ''loss_detection'' and schemaname = ''public'' ' LOOP
		if row.count = 0 then
			execute 'CREATE TABLE loss_detection
			(
				tablename VARCHAR,
				tid	INTEGER,
				cid	INTEGER,
				reverse	BIT(1),
				ts	TIMESTAMP,
				code	INTEGER
			)';
		end if;
	end loop;

	EXECUTE 'SELECT pkt_tid FROM traces where packets='''||tbl_t||''' ' into tid;
	
	if dir_t = 0 then
		query := 'SELECT ts,endseq,ipid FROM '||tbl_t||' where cnxid='||cid_t||' and reverse ISNULL and endseq NOTNULL and flags NOT LIKE ''%R%'' and flags NOT LIKE ''%S%'' ORDER BY ts ASC';
	else
		query := 'SELECT ts,endseq,ipid FROM '||tbl_t||' where cnxid='||cid_t||' and reverse ISNOTNULL and endseq NOTNULL and flags NOT LIKE ''%R%'' and flags NOT LIKE ''%S%'' ORDER BY ts ASC';
	end if;	

	counter := 0;

	biggest := 0;
	max_ipid := -1;
	execute 'select avg(rtt) from rtts('||cid_t||','||dir_t||','''||tbl_t||''') as t(ts timestamp, rtt interval) ' into rtt_t;
	execute 'select CAST( CAST(stddev(extract(SECONDS from rtt)) as VARCHAR) as interval) from rtts('||cid_t||','||dir_t||','''||tbl_t||''') as t(ts timestamp, rtt interval)' into std_t;
	rto_t := rtt_t+4*std_t;

	FOR row IN EXECUTE query LOOP
		IF counter % 100 = 0 THEN
			RAISE NOTICE 'Starting loop for ts % and ipid % with values rtt_t = %, rto_t = %, std_t = %',row.ts,row.ipid,rtt_m,rto_t,std_t;
		END IF;
		code := 0;
		IF row.ipid = max_ipid THEN
			code := 2;
			IF counter%100 = 0 THEN
				RAISE NOTICE 'For ts % duplicate detected',row.ts;
			END IF;
		ELSIF row.endseq <= biggest THEN
			--retransmission
			IF row.ipid > max_ipid and row.ts - prev_ts < rto_t THEN
				max_ipid := row.ipid;
				code := 1;
				IF counter%100 = 0 THEN
					RAISE NOTICE 'For ts %, retransmission detected',row.ts;
				END IF;
			ELSIF row.ipid > max_ipid and row.ts - prev_ts >= rto_t THEN
				max_ipid := row.ipid;
                                code := 4;
				IF counter%100 = 0 THEN
					RAISE NOTICE 'For ts %, timeout detected',row.ts;
				END IF;
			--reordering
			ELSIF row.ipid < max_ipid THEN
				code := 3;
				IF counter%100=0 THEN
					RAISE NOTICE 'For ts %, reordering detected',row.ts;
				END IF;
			ELSE
				max_ipid := row.ipid;
				IF counter%100=0 THEN
					RAISE NOTICE 'For ts %, unclassified with ipid and same SN',row.ts;
				END IF;
			END IF;
		--normal case
		ELSE
			IF counter%100=0 THEN
				RAISE NOTICE 'Entering the recomputation of rtt and rto for ts % and ipid %',row.ts,row.ipid;
			END IF;
			max_ipid := row.ipid;
			biggest := row.endseq;
			execute 'select rtt from rtts('||cid_t||','||dir_t||','''||tbl_t||''') as t(ts timestamp, rtt interval) where ts <= '''||row.ts||''' order by ts DESC limit 1' into rtt_m;
			IF rtt_m ISNULL THEN
				execute 'select rtt from rtts('||cid_t||','||dir_t||','''||tbl_t||''') as t(ts timestamp, rtt interval) where ts >= '''||row.ts||''' limit 1' into rtt_m;
				RAISE NOTICE 'For ts % no RTT found for previous values of ts so the next one taken instead (%)',row.ts,rtt_m;
			END IF;

			IF counter%100=0 THEN
                                RAISE NOTICE 'Measured rtt is %, estimated one is %',rtt_m, rtt_t;
                        END IF;

			rtt_t := 0.9*rtt_t+0.1*rtt_m;
			err_t :=  rtt_m - rtt_t;
			rtt_t := rtt_t+0.125*err_t;
			IF err_t < interval '00:00:00' THEN
				err_t := rtt_t - rtt_m;
			END IF;
			execute 'select '''||std_t||''' + 0.25*(interval '''||err_t||'''- interval '''||std_t||''')' into std_t;
			
			IF counter % 100 = 0 THEN
				RAISE NOTICE 'Following values for following parameters: rtt_m %, rtt_t %, err_t %, std_t %',rtt_m,rtt_t,err_t,std_t;
			END IF;

			rto_t := rtt_m + 4*std_t;
		END IF;

		prev_ts := row.ts;

		IF code > 0 THEN

			IF counter % 100 = 0 THEN
				RAISE NOTICE 'About to insert the following values tablename: %, tid: %, cid: %, ts: %, code: %',tbl_t,tid,cid_t,row.ts,code;
			END IF;			

			IF dir_t = 1 THEN
				EXECUTE 'INSERT INTO loss_detection (tablename, tid, cid, reverse,ts,code) VALUES ('''||tbl_t||''','||tid||','||cid_t||',''1'','''||row.ts||''','||code||')';
			ELSE
				EXECUTE 'INSERT INTO loss_detection (tablename, tid, cid, ts,code) VALUES ('''||tbl_t||''','||tid||','||cid_t||','''||row.ts||''','||code||')';
			END IF;
		END IF;

		counter := counter+1;

	END LOOP;
END
$BODY$
language 'plpgsql';

