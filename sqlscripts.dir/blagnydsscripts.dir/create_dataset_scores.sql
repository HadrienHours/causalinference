CREATE OR REPLACE FUNCTION create_dataset_scores(VARCHAR(50),NUMERIC) RETURNS text AS

$BODY$
DECLARE
	tbl_t ALIAS for $1;
	n_lim_t ALIAS for $2;
	row RECORD;
	row2 RECORD;
	tid_t integer;
	capacity_t integer;
	ps_ratio_t numeric;
	ps_mass_t numeric;
	retr_score_t numeric;
	reorder_t numeric;
	rwnd_score_t numeric;
	b_score_t numeric;
	rwin_avg_t integer;
	rwin_stddev_t integer;
	rwin_meandev_t integer;
	rtt_t float;
	duration_t float;
	presence integer;
	COUNTER integer;
	d_score_t numeric;
	retrp integer;
	rwndp integer;
	bnbwp integer;
	presg integer;
	

--bscore 
--	y is the time the sender waits because it has exhausted the receiver window
--	x is the time it takes to send a receiver advertised window full of packets
--	b_score = 1 - x/(x+y)
--		= 1 - {(Wr - 1)*(MSS/C)}/RTT
--
--dscore
--	1 - tput/C
--
--The retransmission score for a bulk transfer period is computed as the ratio of the amount of data retransmitted divided by the total amount of data transmitted during this period

BEGIN
	RAISE NOTICE 'ENTERING create_dataset_scores function';
	for row in execute 'select count(*) from pg_tables where schemaname = ''public'' and tablename = ''datasetintrabase_scores'' ' LOOP
		if row.count = 0 THEN
			execute 'CREATE TABLE datasetintrabase_scores
			(
				tablename VARCHAR,
				tid		integer,
				cnxid		integer,
				reverse 	integer,
				btid		bigint,
				n_lim 		float,
				bytes		bigint,
				duration	float,
				rtt		float,
				d_score 	numeric,
				retr_score	numeric,
				reorder		numeric,
				rwin_avg	integer,
				rwin_stddev	integer,
				rwin_meandev	integer,
				rwin_score	numeric,
				b_score		numeric,
				capacity	integer,
				ps_ratio	numeric,
				ps_mass		numeric,
				mss		smallint,
				tput		integer,
				class		integer
			)';
		RAISE NOTICE 'Table datasetintrabase_scores created';
		end if;
	end loop;

	for row in execute 'select count(*) from datasetintrabase_scores where tablename = '''||tbl_t||''' and n_lim = '||n_lim_t||' ' LOOP
		if row.count > 0 then
			RETURN 'Table '||tbl_t||' already present in datasetintrabase_scores for n_lim = '||n_lim_t||' ';
		end if;
	end loop;

	execute 'select distinct(tid) from '||tbl_t||' ' into tid_t;

	execute 'select count(*) from bulk_transfer where tid = '||tid_t||' and n_lim = '||n_lim_t||' ' into presence;
	if presence = 0 then
		RAISE NOTICE 'Launching run_tests for table % with n_lim % as not present in bulk_transfer',tbl_t,n_lim_t;
		execute 'select run_tests('''||tbl_t||''','||n_lim_t||')';
	else
		RAISE NOTICE 'CONTROLLING PRESENCE OF TABLE TID % IN retr_test,rwnd_test,bnbw_test for n_lim %',tid_t,n_lim_t;
		execute 'select count(*) from retr_test where btid in (select btid from bulk_transfer where tid = '||tid_t||' and n_lim = '||n_lim_t||') ' into retrp;
		execute 'select count(*) from rwnd_test where btid in (select btid from bulk_transfer where tid = '||tid_t||' and n_lim = '||n_lim_t||') ' into rwndp;
		execute 'select count(*) from bnbw_test where btid in (select btid from bulk_transfer where tid = '||tid_t||' and n_lim = '||n_lim_t||') ' into bnbwp;
		if retrp = 0 OR rwndp = 0 or bnbwp = 0 then
			RAISE NOTICE 'Launching run_tests for table % with n_lim % as the tables retr_test, rwnd_test and bnbw_test are not populated',tbl_t,n_lim_t;
			execute 'select run_tests('''||tbl_t||''','||n_lim_t||')';
		else
			RAISE NOTICE 'Table retr_test, rwnd_test, bnbw_test already populated';
		end if;
	end if;
	
	COUNTER:= 0;
	for row in execute 'select cnxid,reverse,btid,duration,rtt,tput,mss,bytes,class from bulk_transfer where tid = '||tid_t||' and n_lim = '||n_lim_t||' ' LOOP
		RAISE NOTICE 'Working on btid %',row.btid;
		execute 'select c from bnbw_test where btid = '||row.btid||' ' into capacity_t;
		execute 'select ps_ratio from bnbw_test where btid = '||row.btid||' ' into ps_ratio_t;
		execute 'select ps_mass from bnbw_test where btid = '||row.btid||' ' into ps_mass_t;
		execute 'select score from retr_test where btid = '||row.btid||' ' into retr_score_t;
		execute 'select reordered from retr_test where btid = '||row.btid||' ' into reorder_t;
		execute 'select score from rwnd_test where btid = '||row.btid||' ' into rwnd_score_t;
		execute 'select b_score from rwnd_test where btid = '||row.btid||'  ' into b_score_t;
		execute 'select rwnd_avg from rwnd_test where btid = '||row.btid||' ' into rwin_avg_t;
		execute 'select rwnd_stddev from rwnd_test where btid = '||row.btid||' ' into rwin_stddev_t;
		execute 'select rwnd_meandev from rwnd_test where btid = '||row.btid||' ' into rwin_meandev_t;
		execute 'select extract(MINUTES from interval '''||row.rtt||''')*60 + extract(SECONDS from interval '''||row.rtt||''') ' into rtt_t;
		execute 'select extract(MINUTES from interval '''||row.duration||''')*60 + extract(SECONDS from interval '''||row.duration||''') ' into duration_t;

		if capacity_t is null then
			capacity_t := 0;
		end if;

		if capacity_t != 0 then
			execute 'select 1-cast('||row.tput||' as float)/cast('||capacity_t||' as float) ' into d_score_t;
		else
			d_score_t := 0.0;
		--	RAISE NOTICE 'D_score set to 0 as capacity is null';
		end if;

		if rwin_avg_t is null then
			rwin_avg_t := 0;
		end if;

		if rwin_stddev_t is null then
			rwin_stddev_t := 0;
		end if;

		if rwin_meandev_t is null then
			rwin_meandev_t := 0;
		end if; 

		if ps_ratio_t is null then
			ps_ratio_t := 0;
		end if;

		if ps_mass_t is null then
			ps_mass_t := 0;
		end if;

		RAISE NOTICE 'About to insert the values table %, tid %, cnxid %, btid %, n_lim %, bytes %, duration %, rtt %, d_score %, retr_score %, reorder %, rwin_avg %, rwin_stddev %, rwin_meandev %, rwin_score %, b_score %, capacity %, ps_ratio %, ps_mass %, mss %, tput %, class %',tbl_t, tid_t, row.cnxid, row.btid, n_lim_t, row.bytes, duration_t, rtt_t, d_score_t, retr_score_t, reorder_t, rwin_avg_t, rwin_stddev_t, rwin_meandev_t, rwnd_score_t, b_score_t, capacity_t, ps_ratio_t, ps_mass_t, row.mss, row.tput, row.class;

		if row.reverse is not null then
			execute 'insert into datasetintrabase_scores (tablename, tid, cnxid, reverse, btid, n_lim, bytes, duration, rtt, d_score, retr_score, reorder, rwin_avg, rwin_stddev, rwin_meandev, rwin_score, b_score, capacity, ps_ratio, ps_mass, mss, tput, class) VALUES ('''||tbl_t||''', '||tid_t||', '||row.cnxid||', '''||row.reverse||''', '||row.btid||', '||n_lim_t||', '||row.bytes||', '||duration_t||','||rtt_t||', '||d_score_t||', '||retr_score_t||', '||reorder_t||', '||rwin_avg_t||', '||rwin_stddev_t||', '||rwin_meandev_t||', '||rwnd_score_t||', '||b_score_t||', '||capacity_t||', '||ps_ratio_t||', '||ps_mass_t||', '||row.mss||', '||row.tput||', '||row.class||') ';
		else
			execute 'insert into datasetintrabase_scores (tablename, tid, cnxid, btid, n_lim, bytes, duration, rtt, d_score, retr_score, reorder, rwin_avg, rwin_stddev, rwin_meandev, rwin_score, b_score, capacity, ps_ratio, ps_mass, mss, tput, class) VALUES ('''||tbl_t||''', '||tid_t||', '||row.cnxid||', '||row.btid||', '||n_lim_t||', '||row.bytes||', '||duration_t||', '||rtt_t||', '||d_score_t||', '||retr_score_t||', '||reorder_t||', '||rwin_avg_t||', '||rwin_stddev_t||', '||rwin_meandev_t||', '||rwnd_score_t||', '||b_score_t||', '||capacity_t||', '||ps_ratio_t||', '||ps_mass_t||', '||row.mss||', '||row.tput||', '||row.class||') ';
		end if;

		COUNTER:=COUNTER+1;
	end loop; 
	RETURN ''||COUNTER||' lines added for the table '''||tbl_t||''' in datasetintrabase_scores';
END

$BODY$
language 'plpgsql';

