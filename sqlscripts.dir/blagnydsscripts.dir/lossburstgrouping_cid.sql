CREATE OR REPLACE function lossburstgrouping_cid(VARCHAR,INTEGER,INTEGER) RETURNS text AS
$BODY$
DECLARE
	tbl_t ALIAS FOR $1;
	cid_t ALIAS FOR $2;
	dir_t ALIAS FOR $3;
	tid_t integer;
	viewname VARCHAR;
	row RECORD;
	previous integer;
	beg timestamp;
	fin timestamp;
	interloss interval;
	interpkt float;
	begseq bigint;
	endseq bigint;
	begip integer;
	endip integer;
	counter integer;
	timeout_p integer;
	rtt_a float;
	prevpkt float;
	previousts timestamp;
	presview integer;
	
BEGIN
	FOR row in execute 'SELECT COUNT(*) from pg_tables where schemaname = ''public'' and tablename = ''lossburst'' ' LOOP
		IF row.count = 0 THEN
			EXECUTE 'CREATE TABLE lossburst
			(
				tablename VARCHAR,
				tid	INTEGER,
				cnxid INTEGER,
				reverse BIT(1),
				beg	timestamp,
				fin	timestamp,
				interloss interval,
				startseq	bigint,
				endseq	bigint,
				startipid	integer,
				endipid	integer,
				count	INTEGER,
				prevpkt float,
				timeout	BIT(1)
				
			)';
		END IF;
	END LOOP;

	FOR ROW in execute 'SELECT COUNT(*) from lossburst where tablename = '''||tbl_t||''' and cnxid = '||cid_t||' ' LOOP
		IF row.count > 0 THEN
			RETURN 'Connection '||cid_t||' from table '||tbl_t||' already treated';
		END IF;
	END LOOP;
	execute 'select pkt_tid from traces where packets = '''||tbl_t||''' ' into tid_t;
	execute 'select '''||tbl_t||'''||''_''||cast('||cid_t||' as VARCHAR)||''_lossview'' ' into viewname;
	execute 'select count(*) from pg_views where viewname = '''||viewname||''' ' into presview;
	IF presview > 0 THEN
		execute 'DROP VIEW '||viewname||' ';
	END IF;
	execute 'CREATE TEMPORARY VIEW '||viewname||' as (select l.ts,interpacket,startseq,endseq,ipid from lossstats l, '||tbl_t||' t where l.cnxid = '||cid_t||' and t.cnxid = '||cid_t||' and t.ts = l.ts)';
	previous := 0;
	counter := 0;
	execute 'SELECT min(ts) from '||viewname||' ' into beg;
	execute 'SELECT startseq from '||viewname||' where ts = '''||beg||''' 'into begseq;
	execute 'SELECT ipid from '||viewname||' where ts = '''||beg||''' ' into begip;
	execute 'SELECT startseq from '||viewname||' where ts = '''||beg||''' 'into endseq;
	execute 'SELECT interpacket from '||viewname||' where ts = '''||beg||''' ' into interpkt;
	previous := begip;
	previousts := beg;
	prevpkt := interpkt;
	counter := 1;
	interloss := interval '00:00:00';
	execute 'SELECT 2*(extract(MINUTES FROM avg(rtt))*60+extract(SECONDS FROM avg(rtt))) from rtts('||cid_t||','||dir_t||','''||tbl_t||''') as t(ts timestamp, rtt interval) ' into rtt_a;
	IF interpkt > rtt_a THEN
		timeout_p := 1;
	END IF;

	FOR row in execute 'select * from '||viewname||' where ts > '''||beg||''' ' LOOP
		--new burst for ip distance
		IF row.ipid - previous > 2 THEN
			IF counter = 1 THEN
				fin := beg;
				endip = begip;
			END IF;
			interloss := interloss/counter;
			IF timeout_p = 1 THEN
				IF dir_t = 0 THEN
					RAISE NOTICE 'About to insert tablename %, tid %, cnxid % ,beg %,fin % ,interloss %, startseq %, endseq %, startipid %, endipid %, count % ,prevpkt %, timeout %',tbl_t,tid_t,cid_t,beg,fin,interloss,begseq,endseq,begip,endip,counter,prevpkt,1;
					EXECUTE 'INSERT INTO lossburst (tablename,tid,cnxid,beg,fin,interloss,startseq,endseq,startipid,endipid,count,prevpkt,timeout) VALUES ('''||tbl_t||''','||tid_t||','||cid_t||','''||beg||''','''||fin||''','''||interloss||''','||begseq||','||endseq||','||begip||','||endip||','||counter||','''||prevpkt||''',''1'') ';
				ELSE
					RAISE NOTICE 'About to insert tablename %, tid %, reverse %, cnxid % ,beg %,fin % ,interloss %, startseq %, endseq %, startipid %, endipid %, count % ,prevpkt %, timeout %',tbl_t,tid_t,1,cid_t,beg,fin,interloss,begseq,endseq,begip,endip,counter,prevpkt,1;
					EXECUTE 'INSERT INTO lossburst (tablename,tid,reverse,cnxid,beg,fin,interloss,startseq,endseq,startipid,endipid,count,prevpkt,timeout) VALUES ('''||tbl_t||''','||tid_t||',''1'','||cid_t||','''||beg||''','''||fin||''','''||interloss||''','||begseq||','||endseq||','||begip||','||endip||','||counter||','''||prevpkt||''',''1'') ';
				END IF;
			ELSE
				IF dir_t = 0 THEN
					RAISE NOTICE 'About to insert tablename %, tid %, cnxid % ,beg %,fin % ,interloss %, startseq %, endseq %, startipid %, endipid %, count % ,prevpkt %',tbl_t,tid_t,cid_t,beg,fin,interloss,begseq,endseq,begip,endip,counter,prevpkt;
                                        EXECUTE 'INSERT INTO lossburst (tablename,tid,cnxid,beg,fin,interloss,startseq,endseq,startipid,endipid,count,prevpkt) VALUES ('''||tbl_t||''','||tid_t||','||cid_t||','''||beg||''','''||fin||''','''||interloss||''','||begseq||','||endseq||','||begip||','||endip||','||counter||','''||prevpkt||''') ';
                                ELSE
					RAISE NOTICE 'About to insert tablename %, tid %, cnxid % ,beg %,fin % ,interloss %, startseq %, endseq %, startipid %, endipid %, count % ,prevpkt %',tbl_t,tid_t,cid_t,beg,fin,interloss,begseq,endseq,begip,endip,counter,prevpkt;
                                        EXECUTE 'INSERT INTO lossburst (tablename,tid,reverse,cnxid,beg,fin,interloss,startseq,endseq,startipid,endipid,count,prevpkt) VALUES ('''||tbl_t||''','||tid_t||',''1'','||cid_t||','''||beg||''','''||fin||''','''||interloss||''','||begseq||','||endseq||','||begip||','||endip||','||counter||','''||prevpkt||''') ';
                                END IF;
			END IF;
			counter := 1;
			beg := row.ts;
			begseq := row.startseq;
			begip := row.ipid;
			endseq := row.endseq;
			interpkt := row.interpacket;
			prevpkt := row.interpacket;
			previous := row.ipid;
			previousts := row.ts;
			interloss := interval '00:00:00';
			timeout_p := 0;
			--ALSO TIMEOUT
			IF interpkt > rtt_a THEN
				timeout_p := 1;
			END IF;
		--new burst for new time out
		ELSIF row.interpacket > rtt_a THEN
			IF counter = 1 THEN
                                fin := beg;
                                endip = begip;
			END IF;
			interloss := interloss/counter;
                        IF timeout_p = 1 THEN
                                IF dir_t = 0 THEN
                                        EXECUTE 'INSERT INTO lossburst (tablename,tid,cnxid,beg,fin,interloss,startseq,endseq,startipid,endipid,count,prevpkt,timeout) VALUES ('''||tbl_t||''','||tid_t||','||cid_t||','''||beg||''','''||fin||''','''||interloss||''','||begseq||','||endseq||','||begip||','||endip||','||counter||','''||prevpkt||''',''1'') ';
                                ELSE
                                        EXECUTE 'INSERT INTO lossburst (tablename,tid,reverse,cnxid,beg,fin,interloss,startseq,endseq,startipid,endipid,count,prevpkt,timeout) VALUES ('''||tbl_t||''','||tid_t||',''1'','||cid_t||','''||beg||''','''||fin||''','''||interloss||''','||begseq||','||endseq||','||begip||','||endip||','||counter||','''||prepkt||''',''1'') ';
                                END IF;
                        ELSE
                                IF dir_t = 0 THEN
                                        EXECUTE 'INSERT INTO lossburst (tablename,tid,cnxid,beg,fin,interloss,startseq,endseq,startipid,endipid,count,prevpkt) VALUES ('''||tbl_t||''','||tid_t||','||cid_t||','''||beg||''','''||fin||''','''||interloss||''','||begseq||','||endseq||','||begip||','||endip||','||counter||','''||prevpkt||''') ';
                                ELSE
                                        EXECUTE 'INSERT INTO lossburst (tablename,tid,reverse,cnxid,beg,fin,interloss,startseq,endseq,startipid,endipid,count,prevpkt) VALUES ('''||tbl_t||''','||tid_t||',''1'','||cid_t||','''||beg||''','''||fin||''','''||interloss||''','||begseq||','||endseq||','||begip||','||endip||','||counter||','''||prevpkt||''') ';
                                END IF;
			END IF;
			counter := 1;
			prevpkt := row.interpacket;
			previous := row.ipid;
			previousts := row.ts;
                        beg := row.ts;
                        begseq := row.startseq;
                        begip := row.ipid;
                        endseq := row.endseq;
                        interpkt := row.interpacket;
			interloss := interval '00:00:00';
			timeout_p := 1;
		--part of the same burst	
		ELSE
			counter := counter+1;
			endseq := row.endseq;
			endip := row.ipid;
			EXECUTE 'SELECT interval '''||interloss||''' + (timestamp '''||row.ts||'''- timestamp '''||previousts||''') ' into interloss;
			--interloss := interloss + (row.ts - previousts);
			previous := row.ipid;
			previousts := row.ts;
			fin := row.ts;
		END IF;
	END LOOP;
	RETURN 'Burst gathering for table '''||tbl_t||''' and connection '||cid_t||' has been done';
END

$BODY$
language 'plpgsql';


