CREATE OR REPLACE function lossburstgrouping(VARCHAR) RETURNS text AS
$BODY$
DECLARE
	tbl_t ALIAS FOR $1;
	cid_t integer;
	dir_t integer;
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
	rev BIT(1);
	row2 record;
	flag_pres INTEGER;
	endts timestamp;
	nextipid integer;
	countertreated INTEGER;
	counteruntreated INTEGER;
	presence INTEGER;
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

	execute 'select pkt_tid from traces where packets = '''||tbl_t||''' ' into tid_t;

	countertreated := 0;
	counteruntreated := 0;
	FOR row in execute 'select distinct cnxid from lossstats where tablename = '''||tbl_t||''' order by cnxid ' LOOP
		execute 'SELECT count(*) from lossburst where tablename = '''||tbl_t||''' and cnxid = '||row.cnxid||' ' into presence;
		IF presence > 0 THEN
			RAISE NOTICE 'Cnxid % already present in lossburst for table %',row.cnxid,tbl_t;
			CONTINUE;
		END IF;
		execute 'select reverse from blagnydatasettable where tablename = '''||tbl_t||''' and cnxid = '||row.cnxid||' ' into rev;
		IF rev is null THEN
			dir_t := 0;
		ELSE
			dir_t := 1;
		END IF;
		flag_pres := 0;
		FOR row2 in execute 'SELECT COUNT(*) from lossburst where tablename = '''||tbl_t||''' and cnxid = '||row.cnxid||' ' LOOP
			IF row2.count > 0 THEN
--				RAISE NOTICE 'Connection % from table % (dir %) already treated',row.cnxid,tbl_t,dir_t;
				flag_pres := 1;
			END IF;
		END LOOP;
		
		IF flag_pres = 1 THEN
			CONTINUE;
		ELSE
			cid_t := row.cnxid;
			execute 'select '''||tbl_t||'''||''_''||cast('||cid_t||' as VARCHAR)||''_lossview'' ' into viewname;
			execute 'select count(*) from pg_tables where schemaname = ''public'' and tablename = '''||viewname||''' ' into presview;
			IF presview > 0 THEN
				RAISE NOTICE 'About to drop table % for % rows detected',viewname,presview;
				execute 'DROP TABLE '||viewname||' ';
			END IF;
			IF dir_t = 0 THEN
				execute 'CREATE TABLE '||viewname||' as (select l.ts,interpacket,startseq,endseq,ipid from lossstats l, '||tbl_t||' t where l.cnxid = '||cid_t||' and t.cnxid = '||cid_t||' and t.ts = l.ts and reverse is null)';
			ELSE
				execute 'CREATE TABLE '||viewname||' as (select l.ts,interpacket,startseq,endseq,ipid from lossstats l, '||tbl_t||' t where l.cnxid = '||cid_t||' and t.cnxid = '||cid_t||' and t.ts = l.ts and reverse is not null)';
			END IF;
			execute 'select count(*) from '||viewname||' ' into presview;
			IF presview = 0 THEN
				RAISE NOTICE 'The connection % could not be treated time mismatching check lossstats table',row.cnxid;
				counteruntreated := counteruntreated+1;
				CONTINUE;
			END IF;
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

			execute 'SELECT max(ts) from '||viewname||' ' into endts;

			FOR row in execute 'select * from '||viewname||' where ts > '''||beg||''' ' LOOP
				--new burst for ip distance
				IF row.ipid - previous > 5000 OR previous - row.ipid > 5000 THEN
					execute 'select ipid from '||viewname||' where ts > '''||row.ts||''' order by ts limit 1' into nextipid;
					--Avoid TCP SN wrap up pb
					if nextipid is null OR nextipid-row.ipid > 5000 or row.ipid-nextipid > 5000 THEN
						RAISE NOTICE 'The loss of connection % happening at ts % with ipid % is an unclassified loss',cid_t,row.ts,row.ipid;
						CONTINUE;
					end if;
				END IF;
				IF row.ipid - previous > 2 THEN
					IF counter = 1 THEN
						fin := beg;
						endip = begip;
						RAISE NOTICE 'New burst for ipid difference at ts %',row.ts;
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
				IF row.ts = endts THEN
					RAISE NOTICE 'Last loss ends the burst at ts % for cnxid %',row.ts,cid_t;
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
				END IF;
			END LOOP;
			RAISE NOTICE '% has been treated',cid_t;
		END IF;
		countertreated := countertreated+1;
		execute 'DROP TABLE '||viewname||' ';
	END LOOP;
	RETURN 'Burst gathering for table '''||tbl_t||''' has been done with '||countertreated||' connection successful and '||counteruntreated||' failures';
END

$BODY$
language 'plpgsql';


