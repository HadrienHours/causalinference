CREATE OR REPLACE FUNCTION create_dataset_noserverinfo_2(VARCHAR(50),INTEGER) RETURNS text AS

$BODY$
DECLARE
	tbl_t ALIAS for $1;
	thr_t ALIAS for $2;
	row RECORD;
	row2 RECORD;
	view_name VARCHAR;
	stringsearch VARCHAR;
	gename VARCHAR;
	nlim_tn VARCHAR;
	flag INTEGER;
	last_t timestamp;
	win_t integer;
	wscale INTEGER;
	posscale INTEGER;
	win_min_t INTEGER;
	win_max_t INTEGER;
	win_mean_t INTEGER;
	win_var_t bigint;
	win_min INTEGER;
	win_max INTEGER;
	win_mean INTEGER;
	win_var bigint;
	rtt_tcp_hs FLOAT;
	rtt_loss FLOAT;
	retr FLOAT;
	tput FLOAT;
	srcip inet;
	dstip inet;
	srcport integer;
	dstport integer;
	gmt integer;
	dist integer;
	begining24 float;
	ending24 float;
	ack_f bigint;
	flag_treated INTEGER;
	flag_win INTEGER;
	dirwin INTEGER;
	dirsyn INTEGER;
	COUNTER INTEGER;
	ts_syn timestamp;
	ts_synack timestamp;
	ts_synackack timestamp;
	ts_get timestamp;
	ts_getack timestamp;
	ts_getdata timestamp;
	delta_synack interval;
	delta_synack_f float;
	delta_get interval;
	delta_get_f float;
	processing interval;
	processing_f float;
	retrieving_be interval;
	retrieving_be_f float;
	get_seqn	bigint;
	nbbytes_getack	smallint;
	flag_junk integer;
	flag_reuse_cid integer;
	possget integer;
	tcphs interval;
	tcphs_f float;
	tcpend timestamp;
	tcpclose timestamp;
	tcpclosure_f float;
	data_f float;

BEGIN
--	RAISE NOTICE 'Entering function create_dataset_noserverinfo_2 with parameters %,%',tbl_t,thr_t;
	for row in execute 'select count(*) from pg_tables where schemaname = ''public'' and tablename = ''datasetglobal_noserverinfo'' ' LOOP
		if row.count = 0 THEN
			execute 'CREATE TABLE datasetglobal_noserverinfo
			(
				tablename VARCHAR,
				tid	INTEGER,
				cnxid	INTEGER,
				reverse	BIT(1),
				threshold integer,
				wscale integer,
				begining	timestamp,
				ending	timestamp,
				begining24 float,
				ending24 float,
				duration	float,
				beginseq	bigint,
				endseq	bigint,
				nbpkts bigint,
				nbbytes	integer,
				rtt_tcp_hs float,
				rtt_loss  float,
				minwin	integer,
				maxwin	integer,
				avgwin	float,
				varwin bigint,
				loss	float,
				tput	float,
				srcip    inet,
				dstip    inet,
				srcport  integer,
				dstport  integer,
				ts_syn		timestamp,
				ts_synack	timestamp,
				ts_synackack	timestamp,
				ts_get		timestamp,
				ts_getack	timestamp,
				ts_getdata	timestamp,
				delta_synack 	interval,
				delta_synack_f float,
				delta_get interval,
				delta_get_f float,
				processing interval,
				processing_f float,
				retrieving_be interval,
				retrieving_be_f float,
				tcphs_f float,
				data_f float,
				tcpclosure_f float
			)';
			--RAISE NOTICE 'Table datasetglobal_noserverinfo created'; 
		end if;
	end loop;


	for row in execute 'select count(*) from datasetglobal_noserverinfo where tablename = '''||tbl_t||''' and threshold = '||thr_t||' ' LOOP
		if row.count > 0 then
			RETURN 'Table '||tbl_t||' already present in datasetglobal_noserverinfo for threshold '||thr_t||' ';
		end if;
	end loop;

	COUNTER := 0;
	for row in execute 'select '''||tbl_t||''',tid,cnxid,reverse, min(ts) as begining, max(ts) as ending, max(ts) - min(ts) as duration_t, extract(MINUTES from max(ts) - min(ts))*60 + extract(SECONDS from max(ts) - min(ts)) as duration, min(startseq) as startseq, max(endseq) as endseq, count(*) as nbpkts, sum(nbbytes) as nbbytes from '||tbl_t||' group by tid,cnxid,reverse having sum(nbbytes) > '||thr_t||' ' LOOP
--TRADE OFF : BELOW WE WORK WITH THE REAL NUMBER OF APPLICATION BYTES EXCHANGED BUT THE DURATION IS WRONG AS WELL AS BEGINING AND ENDING, ABOVE VERSION WE TAKE INTO ACCOUNT THE RETRANSMISSIONS
--	for row in execute 'select '''||tbl_t||''',tid,cnxid,reverse, min(ts) as begining, max(ts) as ending, max(ts) - min(ts) as duration_t, extract(MINUTES from max(ts) - min(ts))*60 + extract(SECONDS from max(ts) - min(ts)) as duration, min(startseq) as startseq, max(endseq) as endseq, count(*) as nbpkts, sum(nbbytes) as nbbytes from '||tbl_t||' where flags != ''S'' group by tid,cnxid,reverse having max(endseq) - min(startseq)  > '||thr_t||' ' LOOP
		COUNTER=COUNTER+1;
		--RAISE NOTICE 'Counter value %',COUNTER;
		if COUNTER%100=1 then 
			RAISE NOTICE 'STARTING CNXID %',row.cnxid;
		end if;	

		--Check for the presence of this connection already in the table
		flag_treated := 0;
		if row.reverse is null THEN
			for row2 in execute 'select count(*) from datasetglobal_noserverinfo where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is null and threshold = '||thr_t||' ' LOOP
				if row2.count > 0 THEN
					flag_treated := 1;
				end if;
			end loop;
		else
			for row2 in execute 'select count(*) from datasetglobal_noserverinfo where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is not null and threshold = '||thr_t||' ' LOOP
                                if row2.count > 0 THEN
                                        flag_treated := 1;
                                end if;
                        end loop;
		end if;
		--if yes jump to the next one
		if flag_treated > 0 then
			if row.reverse is null then
				RAISE NOTICE 'Tid %, Connection %, direction 0 already present in table akamaidataset_table',row.tid, row.cnxid;
			else
				RAISE NOTICE 'Tid %, Connection %, direction 1 is already present in the table akamaidataset_table',row.tid, row.cnxid;
			end if;
			CONTINUE;
		end if;

		--TIME ELAPSED SINCE 00:00:00 for time of the day correlation
		 execute 'select extract(hours from timestamp '''||row.begining||''') * 3600 + extract(minutes from timestamp '''||row.begining||''')*60 + extract(seconds from timestamp '''||row.begining||''')' into begining24;
		 execute 'select extract(hours from timestamp '''||row.ending||''') * 3600 + extract(minutes from timestamp '''||row.ending||''')*60 + extract(seconds from timestamp '''||row.ending||''')' into ending24;


		--WINDOWS SCALE FACTOR
		--As the direction is the one where the number of bytes is more important it means that it's Client to Server , client being receiver we want this value for Window Scale
		flag_win := 0;
		flag_reuse_cid := 0;

		execute 'select count(*) from '||tbl_t||' where cnxid = '||row.cnxid||' and flags = ''S'' ' into flag_win;
		flag_win := flag_win - 1;

		if flag_win < 0 then
			flag_win := 0;
		else
			flag_win = 1;
		end if;	

		if flag_win > 0 then
			flag_win := 0;
			execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and flags = ''S'' ' into ts_syn;
			execute 'select reverse from '||tbl_t||' where cnxid = '||row.cnxid||' and flags = ''S'' and ts = timestamp '''||ts_syn||''' ' into dirsyn;

			-- Here the client is downloading file from FTP server so, the SYN is from the client, being the receiver, so the WSCALE in the SYN is the one we are interested in

			if dirsyn is null then
				for row2 in execute 'select max(ts) as maxts, max(ts) - min(ts) as diff from '||tbl_t||' where cnxid = '||row.cnxid||' and flags = ''S'' and reverse is null' LOOP
					--if > 5 seconds, we suppose it cannot be a retransmission. Should be compared with the rtt/
					if row2.diff > interval '00:00:05' then
						flag_reuse_cid := 1;
					else
						if row2.diff > '00:00:00' then
							RAISE NOTICE 'Two SYN packets separated by less than 5s for cnxid % (max %)',row.cnxid,row2.maxts;
						end if;
						--If retransmission we use the last syn packet
						execute 'select position(''wscale'' in options) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' and ts = timestamp '''||row2.maxts||''' ' into posscale;
						if posscale is null then
							flag_win := 1;
						else
							--wscale_NB so we shift position 7 letters
							posscale := posscale + 7;
							execute 'select CAST( substring(options from '||posscale||' for 1) as INT)  from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' ' into wscale;
							--RAISE NOTICE 'Wscale found is %',wscale;
						end if;
					end if;
				end loop;
			else
				for row2 in execute 'select max(ts) as maxts, max(ts) - min(ts) as diff from '||tbl_t||' where cnxid = '||row.cnxid||' and flags = ''S'' and reverse is not null' LOOP
                                        --if > 5 seconds, we suppose it cannot be a retransmission. Should be compared with the rtt/
                                        if row2.diff > interval '00:00:05' then
                                                flag_reuse_cid := 1;
                                        else
                                                if row2.diff > '00:00:00' then
                                                        --RAISE NOTICE 'Two SYN packets separated by less than 5s for cnxid % (max %)',row.cnxid,row2.maxts;
                                                end if;
                                                --If retransmission we use the last syn packet
                                                execute 'select position(''wscale'' in options) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' and ts = timestamp '''||row2.maxts||''' ' into posscale;
                                                if posscale is null then
                                                        flag_win := 1;
                                                else
                                                        --wscale_NB so we shift position 7 letters
                                                        posscale := posscale + 7;
                                                        execute 'select CAST( substring(options from '||posscale||' for 1) as INT)  from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' ' into wscale;
                                                        --RAISE NOTICE 'Wscale found is %',wscale;
                                                end if;
                                        end if;
                                end loop;

			end if;
		else
			flag_win := 1;
		end if;


		--if row.reverse is not null then
		--	--Solve the bug of connection reuse
		--	execute 'select count(*) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' ' into flag_win;
		--	if flag_win > 0 then
		--		flag_win := 0;
		--		for row2 in execute 'select max(ts) as maxts, max(ts) - min(ts) as diff from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' ' LOOP
		--			if row2.diff > interval '00:00:05' then
		--				flag_reuse_cid := 1;
		--			else
		--				if row2.diff > '00:00:00' then
		--					RAISE NOTICE 'Two SYN packets separated by less than 5s for cnxid % (max %)',row.cnxid,row2.maxts;
		--				end if;
		--				execute 'select position(''wscale'' in options) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' and ts = timestamp '''||row2.maxts||''' ' into posscale;
		--				if posscale is null then
		--					flag_win := 1;
		--				else
		--					--wscale_NB so we shift position 7 letters
		--					posscale := posscale + 7;
		--					execute 'select CAST( substring(options from '||posscale||' for 1) as INT)  from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' ' into wscale;
		--					--RAISE NOTICE 'Wscale found is %',wscale;
		--				end if;
		--			end if;
		--		end loop;
		--	else
		--		flag_win := 1;
		--	end if;
		--else
		--	execute 'select count(*) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' ' into flag_win;
		--	if flag_win > 0 then
		--		flag_win := 0;
		--		for row2 in execute 'select max(ts) as maxts, max(ts) - min(ts) as diff from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' ' LOOP
		--			if row2.diff > interval '00:00:05' then
		--				flag_reuse_cid := 1;
		--			else
		--				if row2.diff > interval '00:00:00' then
		--					RAISE NOTICE 'Two SYN packets separated by less than 5s for cnxid % (max %)',row.cnxid,row2.maxts;
		--				end if;
		--				execute 'select position(''wscale'' in options) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' and ts = timestamp '''||row2.maxts||''' ' into posscale;
		--				if posscale is null then
		--					flag_win := 1;
		--				else	
		--					--wscale_NB so we shift position 7 letters
		--					posscale := posscale + 7;
		--					execute 'select CAST( substring(options from '||posscale||' for 1) as INT)  from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' ' into wscale;
		--					--RAISE NOTICE 'Wscale found is %',wscale;
		--				end if;
		--			end if;
		--		end loop;
		--	else
		--		flag_win := 1;
		--	end if;
		--end if;

		if flag_reuse_cid > 0 then
			if row.reverse is null then
                                dirwin := 0;
                        else
                                dirwin := 1;
                        end if;
                        --RAISE NOTICE 'There were more than one  tcphandshake packet for connection %, direction %. [%, %, %] will not be treated (port reuse, wrong cnxid labelisation)',row.cnxid,dirwin,tbl_t,row.cnxid,dirwin;
                        CONTINUE;
		end if;

		if flag_win > 0 THEN
			if row.reverse is null then
				dirwin := 0;
			else
				dirwin := 1;
			end if;
			--RAISE NOTICE 'The tcphandshake packet was not found for connection %, direction %. [%, %, %] will not be treated',row.cnxid,dirwin,tbl_t,row.cnxid,dirwin;
			CONTINUE;
		end if;

		-- computing the advertised window
		if row.reverse is not null THEN
			execute 'select min(win) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags != ''S'' ' into win_min_t;
			execute 'select max(win) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags != ''S'' ' into win_max_t;
			execute 'select cast(avg(win) AS INTEGER) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags != ''S'' ' into win_mean_t;
			execute 'select cast(variance(win) AS bigint) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags != ''S'' ' into win_var_t;
			execute 'select '||win_min_t||' << '||wscale||' ' into win_min;
			execute 'select '||win_max_t||' << '||wscale||' ' into win_max;
			execute 'select '||win_mean_t||' << '||wscale||' ' into win_mean;
--			RAISE NOTICE 'Before first window scaling variance window is % (wscale %)',win_var_t,wscale;
			execute 'select cast('||win_var_t||' as bigint) << '||wscale||' ' into win_var;
--			RAISE NOTICE 'After first scaling the value of window variance is %',win_var;
			--var(rX) = r2var(x)
			execute 'select cast('||win_var||' as bigint) << '||wscale||' ' into win_var_t;
--			RAISE NOTICE 'Before re assignment the value of win var is %',win_var_t;
			win_var := win_var_t;
--			RAISE NOTICE 'The final value of the receiver window variance is %',win_var;
		else
			execute 'select min(win) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags != ''S'' ' into win_min_t;
--			RAISE NOTICE 'select min(win) from % where cnxid = % and reverse is not null',tbl_t,row.cnxid;
                        execute 'select max(win) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags != ''S'' ' into win_max_t;
--                      RAISE NOTICE 'select avg(win) from % where cnxid = % and reverse is not null',tbl_t,row.cnxid;
                        execute 'select cast(avg(win) AS INTEGER) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags != ''S'' ' into win_mean_t;
--			RAISE NOTICE 'select avg(win) from % where cnxid = % and reverse is not null',tbl_t,row.cnxid;
                        execute 'select cast(variance(win) AS bigint) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags != ''S'' ' into win_var_t;
--			RAISE NOTICE 'select variance(win) from % where cnxid = % and reverse is not null',tbl_t,row.cnxid;
--			RAISE NOTICE 'About to be launched: select % << %',win_min_t,wscale;
                        execute 'select '||win_min_t||' << '||wscale||' ' into win_min;
--			RAISE NOTICE 'select % << %',win_min,wscale;
                        execute 'select '||win_max_t||' << '||wscale||' ' into win_max;
                        execute 'select '||win_mean_t||' << '||wscale||' ' into win_mean;
--			RAISE NOTICE 'Before first window scaling variance window is % (wscale %)',win_var_t,wscale;
                        execute 'select cast('||win_var_t||' as bigint) << '||wscale||' ' into win_var;
--			RAISE NOTICE 'After first scaling the value of window variance is %',win_var;
                        --var(rX) = r2var(x)
                        execute 'select cast('||win_var||' as bigint) << '||wscale||' ' into win_var_t;
--			RAISE NOTICE 'Before the re assignement the value of win var is %',win_var_t;
                        win_var := win_var_t;
--			RAISE NOTICE 'The final value of the receiver window variance is %',win_var;

		end if;

		--computing the rtt
		execute 'select extract(SECONDS from rtt_synack) as rtt_tcp_hs from rtt_synack('||row.cnxid||','''||tbl_t||''')' into rtt_tcp_hs;
		execute 'select extract(SECONDS from rtt) as rtt_loss from rtt_loss('||row.cnxid||','''||tbl_t||''') as t(rtt interval, m smallint, f numeric)' into rtt_loss;

		--computing the loss
		if row.reverse is not null then
			execute 'select t1 from retr_rate('||row.cnxid||',1,'''||tbl_t||''',timestamp '''||row.begining||''', interval '''||row.duration_t||''') as r(t1 numeric, t2 numeric, t3 numeric)' into retr;
		else
			execute 'select t1 from retr_rate('||row.cnxid||',0,'''||tbl_t||''',timestamp '''||row.begining||''', interval '''||row.duration_t||''') as r(t1 numeric, t2 numeric, t3 numeric)' into retr;
		end if;

		--extracting ip and ports
		if row.reverse is not null then
			execute 'select srcip from cid2tuple where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is not null' into srcip;
			execute 'select dstip from cid2tuple where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is not null' into dstip;
			execute 'select srcport from cid2tuple where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is not null' into srcport;
			execute 'select dstport from cid2tuple where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is not null' into dstport;
		else
			execute 'select srcip from cid2tuple where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is null' into srcip;
                        execute 'select dstip from cid2tuple where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is null' into dstip;
                        execute 'select srcport from cid2tuple where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is null' into srcport;
                        execute 'select dstport from cid2tuple where tid = '||row.tid||' and cnxid = '||row.cnxid||' and reverse is null' into dstport;
		end if;

		if dirsyn is null then
			if row.reverse is not null then
			--	RAISE NOTICE 'Starting computation befe time for studied direction 1 cnxid %, dirsyn 0',row.cnxid;
			else
			--	RAISE NOTICE 'Starting computation befe time for studied direction 0 cnxid %, dirsyn 0',row.cnxid;
			end if;
			execute 'select count(*) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' ' into flag_win;
			if flag_win is not null then
				--RAISE NOTICE 'Found the packet with S flags cnxid %',row.cnxid;
				execute 'select ts from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' ' into ts_syn;
				execute 'select ts from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' 'into ts_synack;
				execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and ack is not null ' into ts_synackack;
			--	RAISE NOTICE 'Acks and synacks found: s = %, sa = %, saa = %',ts_syn, ts_synack, ts_synackack;


				-- using wget the first packet sent by the client with some payload is the GET method from HTTP
--				execute 'select count(*) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and nbbytes > 0' into possget;
--				if possget > 0 then
--					execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and nbbytes > 0 ' into ts_get;
--					execute 'select endseq from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and ts = '''||ts_get||''' ' into get_seqn;
--					execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and ack = '||get_seqn||' ' into ts_getack;
--					execute 'select nbbytes from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and ts = '''||ts_getack||''' ' into nbbytes_getack;
--					--RAISE NOTICE 'Time and sizes got';
--					if nbbytes_getack is null then
--						--RAISE NOTICE 'For table %, connection % and direction 1 the first server ack has no data',tbl_t,row.cnxid;
--						-- Here we take the first datapacket with an ack >= GET SN in case the client sent other data before receiving some from server (unlikely)
--						execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and ack >= '||get_seqn||' and nbbytes > 0' into ts_getdata;
--					else
--						--data sent with the ACK
--						ts_getdata := ts_getack;
--					end if;
--					RAISE NOTICE 'The ts for ts_get %, ts_getack %',ts_get,ts_getack;
--					RAISE NOTICE 'The ts get data found for studying cnxid % in table % for direction 1 is %',row.cnxid,tbl_t,ts_getdata;
--				end if;
			end if;

			ts_get := timestamp '1970-01-01 00:00:01';
			ts_getack := timestamp '1970-01-01 00:00:01';
			ts_getdata := timestamp '1970-01-01 00:00:01';

		else
			if row.reverse is null then
			--	RAISE NOTICE 'Starting computation befe time for studied direction 0, cnxid %, dirsyn 0',row.cnxid;
			else
			--	RAISE NOTICE 'Starting computation befe time for studied direction 1, cnxid %, dirsyn 0',row.cnxid;
			end if;
			execute 'select count(*) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' ' into flag_win;
			if flag_win is not null then
				execute 'select ts from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and flags = ''S'' ' into ts_syn;
				execute 'select ts from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and flags = ''S'' 'into ts_synack;
				execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and ack is not null ' into ts_synackack;
			--	RAISE NOTICE 'Acks and synacks found: s = %, sa = %, saa = %',ts_syn, ts_synack, ts_synackack;

--				-- using wget the first packet sent by the client with some payload is the GET method from HTTP
--				execute 'select count(*) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and nbbytes > 0' into possget;
--				if possget > 0 then
--					execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and nbbytes > 0 ' into ts_get;
--					execute 'select endseq from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and ts = '''||ts_get||''' ' into get_seqn;
--					execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and ack = '||get_seqn||' ' into ts_getack;
--					execute 'select nbbytes from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and ts = '''||ts_getack||''' ' into nbbytes_getack;
--					if nbbytes_getack is null then
--						--RAISE NOTICE 'For table %, connection % and direction 0 the first server ack has no data',tbl_t,row.cnxid;
--						-- Here we take the first datapacket with an ack >= GET SN in case the client sent other data before receiving some from server (unlikely)
--						execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and ack >= '||get_seqn||' and nbbytes > 0 ' into ts_getdata;
--					else
--						ts_getdata := ts_getack;
--					end if;
--					RAISE NOTICE 'The ts for ts_get %, ts_getack %',ts_get,ts_getack;
--					RAISE NOTICE 'The ts get data found for studying cnxid % in table % for direction 0 is %',row.cnxid,tbl_t,ts_getdata;
--				end if;
			end if;

			ts_get := timestamp '1970-01-01 00:00:01';
                        ts_getack := timestamp '1970-01-01 00:00:01';
                        ts_getdata := timestamp '1970-01-01 00:00:01';
		end if;

		possget := 0;

		if flag_win is null then
			RAISE NOTICE 'No packet found for flag S in the opposite direction for compute retrieving be for cnxid %',row.cnxid;
			CONTINUE;
		end if;

		if possget = 0 then
--	               RAISE NOTICE 'The syn was found at %, the syn ack at % , the syn ack ack at %, the get at %, the get_ack at % and the get_data at % for table %, connection %. The number of bytes in the ack is %',ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, tbl_t, row.cnxid, nbbytes_getack;
        	        delta_synack := ts_synack - ts_syn;
			execute 'select extract(SECONDS from interval '''||delta_synack||''') ' into delta_synack_f;
			if row.reverse is not null then
				RAISE NOTICE 'No get packet found for cnxid % and direction 1. No server computing time',row.cnxid;
			else
				RAISE NOTICE 'No get packet found for cnxid % and direction 0. No server computing time',row.cnxid;
			end if;
			delta_get_f := 0;
			processing_f := 0;
			retrieving_be_f := 0;
			execute 'select cast(''1970-01-01 00:00:00'' as timestamp)' into ts_get;
			execute 'select cast(''1970-01-01 00:00:00'' as timestamp)' into ts_getack;
			execute 'select cast(''1970-01-01 00:00:00'' as timestamp)' into ts_getdata;
			execute 'select cast(''00:00:00'' as interval)' into processing;
			execute 'select cast(''00:00:00'' as interval)' into retrieving_be;
			execute 'select cast(''00:00:00'' as interval)' into delta_get;

		else 
			 --computing the delay from previous time stamps
                        delta_get := ts_getack - ts_get;
        	        execute 'select extract(SECONDS from interval '''||delta_get||''') ' into  delta_get_f;
	                processing := delta_get - delta_synack;
        	        execute 'select extract(SECONDS from interval '''||processing||''')' into processing_f;
                	retrieving_be := ts_getdata- ts_getack;
	                execute 'select extract(SECONDS from interval '''||retrieving_be||''') ' into retrieving_be_f;

			CONTINUE;
		end if;

--		RAISE NOTICE 'For cnxid % the delta_get_f is %, the processing_f is %, the retrieving_be_f is %',row.cnxid,delta_get_f,processing_f,retrieving_be_f;


		--computing the delay from previous time stamps
--		RAISE NOTICE 'The syn was found at %, the syn ack at % , the syn ack ack at %, the get at %, the get_ack at % and the get_data at % for table %, connection %. The number of bytes in the ack is %',ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, tbl_t, row.cnxid, nbbytes_getack;
--		delta_synack := ts_synack - ts_syn;
--	        execute 'select extract(SECONDS from interval '''||delta_synack||''') ' into delta_synack_f;
--        	delta_get := ts_getack - ts_get;
--	        execute 'select extract(SECONDS from interval '''||delta_get||''') ' into  delta_get_f;
--        	processing := delta_get - delta_synack;
--	        execute 'select extract(SECONDS from interval '''||processing||''')' into processing_f;
--        	retrieving_be := ts_getdata- ts_getack;
--	        execute 'select extract(SECONDS from interval '''||retrieving_be||''') ' into retrieving_be_f;

		--computing throughput as size/time
		execute 'select '||row.nbbytes||'/'||row.duration||' ' into tput;

--		RAISE NOTICE 'The tput for cnxid % is %', row.cnxid,tput;

		--computing the data transfer time, tcp handshake time, tcp closure time
		-- TCP HANDSHAKE
		execute 'select timestamp '''||ts_synackack||''' - timestamp '''||ts_syn||''' ' into tcphs;
		execute 'select extract(MINUTES from interval '''||tcphs||''')*60 + extract(SECONDS from interval '''||tcphs||''') ' into tcphs_f;

		--DATA TRANSFER
		if row.reverse is null then
			execute 'select extract(MINUTES from max(ts) - min(ts))*60 + extract(SECONDS from max(ts) - min(ts)) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is null and nbbytes > 0' into data_f;
		else
                        execute 'select extract(MINUTES from max(ts) - min(ts))*60 + extract(SECONDS from max(ts) - min(ts)) from '||tbl_t||' where cnxid = '||row.cnxid||' and reverse is not null and nbbytes > 0' into data_f;
		end if;

		--TCP CLOSURE
		execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and flags = ''F'' ' into tcpclose;
		if tcpclose is null then
--			RAISE NOTICE 'For connection % no flag FIN found',row.cnxid;
			execute 'select min(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' and flags = ''R'' ' into tcpclose;
		end if;
		if tcpclose is null then
--			RAISE NOTICE 'For connection % no reset found either, end of tcp connection taken as last TCP packet',row.cnxid;
			execute 'select max(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' ' into tcpclose;
		end if; 
		execute 'select max(ts) from '||tbl_t||' where cnxid = '||row.cnxid||' ' into tcpend;
		execute 'select extract(MINUTES from timestamp '''||tcpend||''' - timestamp '''||tcpclose||''')*60 + extract(SECONDS from timestamp '''||tcpend||''' - timestamp '''||tcpclose||''') ' into tcpclosure_f;

--		RAISE NOTICE 'The time for opening tcp connection is %, for the data transfer % and for the closing of the connection is %', tcphs_f,data_f,tcpclosure_f;

		--insert the value in the table
		if row.reverse is not null then
			RAISE NOTICE 'execute INSERT INTO datasetglobal_noserverinfo (tablename, tid, cnxid, reverse, threshold, wscale, begining , ending, begining24, ending24, duration, beginseq, endseq, nbpkts, nbbytes, rtt_tcp_hs, rtt_loss, minwin, maxwin, avgwin, varwin, loss, tput, srcip, dstip, srcport, dstport, ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, delta_synack, delta_synack_f, delta_get, delta_get_f, processing, processing_f, retrieving_be, retrieving_be_f, tcphs_f, data_f, tcpclosure_f) VALUES (%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%)',tbl_t, row.tid, row.cnxid, row.reverse, thr_t, wscale, row.begining, row.ending, begining24, ending24,row.duration, row.startseq, row.endseq, row.nbpkts, row.nbbytes, rtt_tcp_hs, rtt_loss, win_min, win_max, win_mean, win_var, retr, tput, srcip, dstip, srcport, dstport, ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, delta_synack, delta_synack_f, delta_get, delta_get_f, processing, processing_f, retrieving_be, retrieving_be_f, tcphs_f, data_f, tcpclosure_f;

			execute 'INSERT INTO datasetglobal_noserverinfo (tablename, tid, cnxid, reverse, threshold, wscale, begining , ending, begining24, ending24, duration, beginseq, endseq, nbpkts, nbbytes, rtt_tcp_hs, rtt_loss, minwin, maxwin, avgwin, varwin, loss, tput, srcip, dstip, srcport, dstport, ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, delta_synack, delta_synack_f, delta_get, delta_get_f, processing, processing_f, retrieving_be, retrieving_be_f, tcphs_f, data_f, tcpclosure_f) VALUES ('''||tbl_t||''', '||row.tid||', '||row.cnxid||', '''||row.reverse||''', '||thr_t||', '||wscale||', '''||row.begining||''', '''||row.ending||''', '||begining24||', '||ending24||','||row.duration||', '||row.startseq||', '||row.endseq||', '||row.nbpkts||', '||row.nbbytes||', '||rtt_tcp_hs||', '||rtt_loss||', '||win_min||', '||win_max||', '||win_mean||', '||win_var||', '||retr||', '||tput||', '''||srcip||''', '''||dstip||''', '||srcport||', '||dstport||', '''||ts_syn||''', '''||ts_synack||''', '''||ts_synackack||''', '''||ts_get||''', '''||ts_getack||''', '''||ts_getdata||''', '''||delta_synack||''', '||delta_synack_f||', '''||delta_get||''', '||delta_get_f||', '''||processing||''', '||processing_f||', '''||retrieving_be||''', '||retrieving_be_f||', '||tcphs_f||', '||data_f||', '||tcpclosure_f||') ';
		--RAISE NOTICE 'LINE ADDED IN datasetglobal_noserverinfo for table %, cnxid %, reverse 1',tbl_t,row.cnxid;
		else
			RAISE NOTICE 'execute INSERT INTO datasetglobal_noserverinfo (tablename, tid, cnxid, reverse, threshold, wscale, begining , ending, begining24, ending24, duration, beginseq, endseq, nbpkts, nbbytes, rtt_tcp_hs, rtt_loss, minwin, maxwin, avgwin, varwin, loss, tput, srcip, dstip, srcport, dstport, ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, delta_synack, delta_synack_f, delta_get, delta_get_f, processing, processing_f, retrieving_be, retrieving_be_f, tcphs_f, data_f, tcpclosure_f) VALUES (%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%,%)',tbl_t, row.tid, row.cnxid, 0, thr_t, wscale, row.begining, row.ending, begining24, ending24,row.duration, row.startseq, row.endseq, row.nbpkts, row.nbbytes, rtt_tcp_hs, rtt_loss, win_min, win_max, win_mean, win_var, retr, tput, srcip, dstip, srcport, dstport, ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, delta_synack, delta_synack_f, delta_get, delta_get_f, processing, processing_f, retrieving_be, retrieving_be_f, tcphs_f, data_f, tcpclosure_f;
			execute 'INSERT INTO datasetglobal_noserverinfo (tablename, tid, cnxid, threshold, wscale, begining , ending, begining24, ending24, duration, beginseq, endseq, nbpkts, nbbytes, rtt_tcp_hs, rtt_loss, minwin, maxwin, avgwin, varwin, loss, tput, srcip, dstip, srcport, dstport, ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, delta_synack, delta_synack_f, delta_get, delta_get_f, processing, processing_f, retrieving_be, retrieving_be_f, tcphs_f, data_f, tcpclosure_f) VALUES ('''||tbl_t||''', '||row.tid||', '||row.cnxid||', '||thr_t||', '||wscale||', '''||row.begining||''', '''||row.ending||''', '||begining24||', '||ending24||', '||row.duration||', '||row.startseq||', '||row.endseq||', '||row.nbpkts||', '||row.nbbytes||', '||rtt_tcp_hs||', '||rtt_loss||', '||win_min||', '||win_max||', '||win_mean||', '||win_var||', '||retr||', '||tput||', '''||srcip||''', '''||dstip||''', '||srcport||', '||dstport||', '''||ts_syn||''', '''||ts_synack||''', '''||ts_synackack||''', '''||ts_get||''', '''||ts_getack||''', '''||ts_getdata||''', '''||delta_synack||''', '||delta_synack_f||', '''||delta_get||''', '||delta_get_f||', '''||processing||''', '||processing_f||', '''||retrieving_be||''', '||retrieving_be_f||', '||tcphs_f||', '||data_f||', '||tcpclosure_f||') ';
		--RAISE NOTICE 'LINE ADDED IN datasetglobal_noserverinfo for table %, cnxid %, reverse 0',tbl_t,row.cnxid;
		end if;

		--COUNTER := COUNTER+1;
		if COUNTER%100 = 0 then
			RAISE NOTICE '% connections treated',COUNTER;
		end if;
	end loop;

	RETURN ''||COUNTER||' lines added for the table '''||tbl_t||''' in datasetglobal_noserverinfo'; 
END

$BODY$
language 'plpgsql';
