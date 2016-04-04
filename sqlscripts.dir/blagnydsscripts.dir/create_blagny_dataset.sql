CREATE or REPLACE function create_blagny_dataset(VARCHAR,INTEGER,FLOAT) RETURNS TEXT AS

$BODY$

DECLARE
	tbl_t ALIAS for $1;
	thr_t ALIAS for $2;
	nlim_t ALIAS for $3;
	row RECORD;
	row2 RECORD;
	countercnxs integer;
	totalcnxs integer;
	presence_t integer;
	tid_t integer;
	totalbulks float;
	totalapps float;
	d_score_t float;
	retr_score_t numeric;
	reorder_t numeric;
	rwin_avg_t numeric;
	rwin_stddev_t numeric;
	rwin_meandev_t numeric;
	rwin_score_t numeric;
	b_score_t numeric;
	capacity_t  numeric;
	ps_ratio_t numeric;
	ps_mass_t numeric;
	rtt_t float;
	mss_t float;
	tput_t float;
	bulkcount integer;
	bulkduration float;
	appcount integer;
	appduration float;
	fracbulks float;
	class_t integer;
	srcip inet;
	dstip inet;
	srcport integer;
	dstport integer;
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
	tcphs_f float;
	data_f float;
	tcpclosure_f float;
	begining_t timestamp;
	ending_t timestamp;
	ts_f float;
	duration_t float;
	nbbytes_t bigint;
	nbpkts_t bigint;
	beginseq_t bigint;
	endseq_t bigint;
	wscale_t bigint;
	duration_serverlogs_t float;
	cpu_user_value_t float;
	cpu_idle_value_t float;
	cpu_system_value_t float;
	cpu_wait_value_t float;
	disk_octets_read_t float;
	disk_octets_write_t float;
	disk_operations_read_t float;
	disk_operations_write_t float;
	interface_error_rx_t float;
	interface_error_tx_t float;
	interface_packets_rx_t float;
	interface_packets_tx_t float;
	interface_octets_rx_t float;
	interface_octets_tx_t float;
	load_shortterm_t double precision;
	load_midterm_t double precision;
	load_longterm_t double precision;
	memory_used_value_t float;
	memory_buffered_value_t float;
	memory_cached_value_t float;
	memory_free_value_t float;
	tcp_close_wait_value_t float;
	tcp_closed_value_t float;
	tcp_closing_value_t float;
	tcp_established_value_t float;
	tcp_fin_wait1_value_t float;
	tcp_fin_wait2_value_t float;
	tcp_last_ack_value_t float;
	tcp_listen_value_t float;
	tcp_syn_recv_value_t float;
	tcp_syn_sent_value_t float;
	tcp_time_wait_value_t float;
	presence	integer;
	

BEGIN
	RAISE NOTICE 'HELLO';
	for row in execute 'select count(*) from pg_tables where schemaname = ''public'' and tablename = ''blagnydatasettable'' ' LOOP
		if row.count = 0 then
			execute 'CREATE TABLE blagnydatasettable
			(
				tid			INTEGER,
				tablename		VARCHAR,
				cnxid			INTEGER,
				reverse			BIT(1),
				nlim			float,
				threshold		integer,
                                srcip    		inet,
                                dstip    		inet,
                                srcport  		integer,
                                dstport  		integer,
				start			timestamp,
				finish			timestamp,
				ts			float,
				duration		float,
				duration_serverlogs 	float,
				bulks_number		integer,
				apps_number		integer,
				duration_bulks		float,
				duration_apps		float,
                                cpu_user_value 		float,
                                cpu_idle_value 		float,
                                cpu_system_value 	float,
                                cpu_wait_value 		float,
                                disk_octets_read 	float,
                                disk_octets_write 	float,
                                disk_operations_read 	float,
                                disk_operations_write 	float,
                                interface_error_rx 	float,
                                interface_error_tx 	float,
                                interface_packets_rx 	float,
                                interface_packets_tx 	float,
                                interface_octets_rx 	float,
                                interface_octets_tx 	float,
                                load_shortterm double 	precision,
                                load_midterm double 	precision,
                                load_longterm double 	precision,
                                memory_used_value 	float,
                                memory_buffered_value 	float,
                                memory_cached_value 	float,
                                memory_free_value 	float,
                                tcp_close_wait_value 	float,
                                tcp_closed_value 	float,
                                tcp_closing_value 	float,
                                tcp_established_value 	float,
                                tcp_fin_wait1_value 	float,
                                tcp_fin_wait2_value 	float,
                                tcp_last_ack_value 	float,
                                tcp_listen_value 	float,
                                tcp_syn_recv_value 	float,
                                tcp_syn_sent_value 	float,
                                tcp_time_wait_value 	float,
				beginseq                bigint,
                                endseq                  bigint,
				wscale                  integer,
				nbbytes           	bigint,
				nbpkts			bigint,
                                rtt             	float,
                                d_score         	numeric,
                                retr_score      	numeric,
                                reorder         	numeric,
                                rwin_avg        	float,
                                rwin_stddev     	float,
                                rwin_meandev    	float,
                                rwin_score      	numeric,
                                b_score         	numeric,
                                capacity        	float,
                                ps_ratio        	numeric,
                                ps_mass         	numeric,
                                mss             	float,
                                tput            	float,
                                class           	integer,
                                ts_syn          	timestamp,
                                ts_synack       	timestamp,
                                ts_synackack    	timestamp,
                                ts_get          	timestamp,
                                ts_getack       	timestamp,
                                ts_getdata      	timestamp,
                                delta_synack    	interval,
                                delta_synack_f 		float,
                                delta_get 		interval,
                                delta_get_f 		float,
                                processing 		interval,
                                processing_f 		float,
                                retrieving_be 		interval,
                                retrieving_be_f 	float,
                                tcphs_f 		float,
                                data_f 			float,
                                tcpclosure_f 		float
			)';
			RAISE NOTICE 'TABLE blagnydatasettable created';
		--'
		end if;
	end loop;

	--for row in execute 'select count(*) from blagnydatasettable where tablename = '''||tbl_t||''' and threshold = '||thr_t||' and nlim = '||nlim_t||' ' LOOP
	--	if row.count > 0 then
	--		RETURN 'Trace '||tbl_t||' already treated for threshold '||thr_t||' and n_lim '||nlim_t||' ';
	--	end if;
	--end loop;


	execute 'select create_dataset_noserverinfo_2('''||tbl_t||''','||thr_t||')';
	RAISE NOTICE 'dataset_noserverinfo populated';
	execute 'select create_dataset_scores('''||tbl_t||''','||nlim_t||')';
	RAISE NOTICE 'Dataset for the scores populated';
	execute 'select pkt_tid from traces where packets = '''||tbl_t||''' ' into tid_t;
	RAISE NOTICE 'About to query bulk_transfer with tid % and n_lim %',tid_t,nlim_t;
	execute 'select count(*) from bulk_transfer where tid = '||tid_t||' and n_lim = '||nlim_t||' ' into totalcnxs;
	RAISE NOTICE 'About to start the computations for % cnxs',totalcnxs;
	countercnxs := 0;
	for row in execute 'select cnxid,reverse from bulk_transfer where tid = '||tid_t||' and n_lim = '||nlim_t||' 'LOOP
		execute 'select count(*) from blagnydatasettable where tid = '||tid_t||' and nlim = '||nlim_t||' and threshold= '||thr_t||' and cnxid = '||row.cnxid||' ' into presence;
		if presence > 0 then
			RAISE NOTICE 'Cnxid % already treated',row.cnxid;
			CONTINUE;
		end if;
		countercnxs := countercnxs+1;
		if countercnxs%100=1 then
			RAISE NOTICE '% cnx being treated, total = %',countercnxs,totalcnxs;
		end if;
		execute 'select count(*) from datasetglobal_noserverinfo where cnxid = '||row.cnxid||' ' into presence_t;
		if presence_t != 0 then
			execute 'select extract(MINUTES from sum(duration))*60 + extract(SECONDS from sum(duration)) from bulk_transfer where tid = '||tid_t||' and cnxid = '||row.cnxid||' and n_lim = '||nlim_t||' ' into totalbulks;
			execute 'select extract(MINUTES from sum(duration))*60 + extract(SECONDS from sum(duration)) from app_period where tid = '||tid_t||' and cnxid = '||row.cnxid||' and n_lim = '||nlim_t||' ' into totalapps;
			d_score_t := 0.0;
			retr_score_t := 0.0;
			reorder_t := 0.0;
			rwin_avg_t := 0.0;
			rwin_stddev_t := 0.0;
			rwin_meandev_t := 0.0;
			rwin_score_t := 0.0;
			b_score_t := 0.0;
			capacity_t := 0.0;
			ps_ratio_t := 0.0;
			ps_mass_t := 0.0;
			rtt_t := 0.0;
			mss_t := 0.0;
			tput_t := 0.0;
			bulkcount := 0;
			bulkduration := 0.0;
			appcount := 0;
			appduration := 0.0;
			for row2 in execute 'select * from  bulk_transfer where tid = '||tid_t||' and cnxid = '||row.cnxid||' and n_lim = '||nlim_t||' 'LOOP
				bulkcount := bulkcount+1;
				execute 'select '||bulkduration||' + extract(MINUTES from interval '''||row2.duration||''')*60 + extract(SECONDS from interval '''||row2.duration||''') from datasetintrabase_scores where btid = '||row2.btid||' ' into bulkduration;
				execute 'select (extract(MINUTES from interval '''||row2.duration||''')*60 + extract(SECONDS from interval '''||row2.duration||'''))/'||totalbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into fracbulks;
				execute 'select '||d_score_t||' + d_score/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into d_score_t;
				execute 'select '||retr_score_t||'+ retr_score/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into retr_score_t;
				execute 'select '||reorder_t||'+ reorder/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into reorder_t;
				execute 'select '||rwin_avg_t||'+ rwin_avg/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into rwin_avg_t;
				execute 'select '||rwin_stddev_t||'+ rwin_stddev/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into rwin_stddev_t;
				execute 'select '||rwin_meandev_t||'+ rwin_meandev/('||fracbulks||'^2) from datasetintrabase_scores where btid = '||row2.btid||' ' into rwin_meandev_t;
				execute 'select '||rwin_score_t||'+ rwin_score/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into rwin_score_t;
				execute 'select '||b_score_t||' + b_score/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into b_score_t;
				execute 'select '||capacity_t||' + capacity/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into capacity_t;
				execute 'select '||ps_ratio_t||' + ps_ratio/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into ps_ratio_t;
				execute 'select '||ps_mass_t||' + ps_mass/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into ps_mass_t;
				execute 'select '||rtt_t||' + rtt/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into rtt_t;
				execute 'select '||mss_t||' + mss/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into mss_t;
				execute 'select '||tput_t||' + tput/'||fracbulks||' from datasetintrabase_scores where btid = '||row2.btid||' ' into tput_t;
				class_t := row2.class;
			end loop;
			
			--RAISE NOTICE 'd_score_t = %, retr_score_t = %, reorder_t = %, rwin_avg_t = %, rwin_stddev_t = %, rwin_meandev_t = %, rwin_score_t = %, b_score_t = %, capacity_t = %, ps_ratio_t = %, ps_mass_t = %, rtt_t = %, mss_t = %, tput_t = %',d_score_t,retr_score_t,reorder_t,rwin_avg_t,rwin_stddev_t,rwin_meandev_t,rwin_score_t,b_score_t,capacity_t,ps_ratio_t,ps_mass_t,rtt_t,mss_t,tput_t;

			for row2 in execute 'select * from app_period where tid = '||tid_t||' and cnxid = '||row.cnxid||' and n_lim = '||nlim_t||' ' LOOP
				appcount := appcount + 1;
				execute 'select '||appduration||' + extract(MINUTES from interval '''||row2.duration||''')*60 + extract(SECONDS from interval '''||row2.duration||''') ' into appduration;
			end loop;
			for row2 in execute 'select * from datasetglobal_noserverinfo where cnxid = '||row.cnxid||' and tid = '||tid_t||' ' LOOP
				srcip := row2.srcip;
                                dstip := row2.dstip;
                                srcport := row2.srcport;
                                dstport := row2.dstport;
                                ts_syn := row2.ts_syn;
                                ts_synack := row2.ts_synack;
                                ts_synackack := row2.ts_synackack;
                                ts_get := row2.ts_get;
                                ts_getack := row2.ts_getack;
                                ts_getdata := row2.ts_getdata;
                                delta_synack := row2.delta_synack;
                                delta_synack_f := row2.delta_synack_f;
                                delta_get := row2.delta_get;
                                delta_get_f := row2.delta_get_f;
                                processing := row2.processing;
                                processing_f := row2.processing_f;
                                retrieving_be := row2.retrieving_be;
                                retrieving_be_f := row2.retrieving_be_f;
                                tcphs_f := row2.tcphs_f;
                                data_f := row2.data_f;
                                tcpclosure_f := row2.tcpclosure_f;
				begining_t := row2.begining;
				ending_t := row2.ending;
				ts_f := row2.begining24;
				duration_t := row2.duration;
				nbbytes_t := row2.nbbytes;
				nbpkts_t := row2.nbpkts;
				beginseq_t := row2.beginseq;
				endseq_t := row2.endseq;
				wscale_t := row2.wscale;
			end loop;
--			RAISE NOTICE 'About to start function server stats for cid % of table %',row.cnxid,tbl_t;
			--BUG ?
			execute 'select function_server_stats('||row.cnxid||', '''||tbl_t||''') ';
--			RAISE NOTICE 'Function server stats finished';
			execute 'select duration_serverlogs from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into duration_serverlogs_t;
			execute 'select cpu_user_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into cpu_user_value_t;
			execute 'select cpu_idle_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into cpu_idle_value_t;
			execute 'select cpu_system_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into cpu_system_value_t;
			execute 'select cpu_wait_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into cpu_wait_value_t;
			execute 'select disk_octets_read from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into disk_octets_read_t;
			execute 'select disk_octets_write from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into disk_octets_write_t;
			execute 'select disk_operations_read from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into disk_operations_read_t;
			execute 'select disk_operations_write from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into disk_operations_write_t;
			execute 'select interface_error_rx from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into interface_error_rx_t;
			execute 'select interface_error_tx from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into interface_error_tx_t;
			execute 'select interface_packets_rx from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into interface_packets_rx_t;
			execute 'select interface_packets_tx from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into interface_packets_tx_t;
			execute 'select interface_octets_rx from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into interface_octets_rx_t;
			execute 'select interface_octets_tx from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into interface_octets_tx_t;
			execute 'select load_shortterm from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into load_shortterm_t;
			execute 'select load_midterm from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into load_midterm_t;
			execute 'select load_longterm from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into load_longterm_t;
			execute 'select memory_used_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into memory_used_value_t;
			execute 'select memory_buffered_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into memory_buffered_value_t;
			execute 'select memory_cached_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into memory_cached_value_t;
			execute 'select memory_free_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into memory_free_value_t;
			execute 'select tcp_close_wait_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_close_wait_value_t;
			execute 'select tcp_closed_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_closed_value_t;
			execute 'select tcp_closing_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_closing_value_t;
			execute 'select tcp_established_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_established_value_t;
			execute 'select tcp_fin_wait1_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_fin_wait1_value_t;
			execute 'select tcp_fin_wait2_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_fin_wait2_value_t;
			execute 'select tcp_last_ack_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_last_ack_value_t;
			execute 'select tcp_listen_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_listen_value_t;
			execute 'select tcp_syn_recv_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_syn_recv_value_t;
			execute 'select tcp_syn_sent_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_syn_sent_value_t;
			execute 'select tcp_time_wait_value from ftpserverstatisticsaggregate where cnxid = '||row.cnxid||' ' into tcp_time_wait_value_t;

			if rwin_stddev_t is null then
				rwin_stddev_t := 0;
			end if;
			if rwin_meandev_t is null then
				rwin_meandev_t := 0;
			end if;

			if bulkcount > 1 then
				class_t := 0;
			else
				if class_t is null then
					class_t := 0;
				end if;
			end if;

			if row.reverse is not null then
				execute 'INSERT into blagnydatasettable (tid, tablename, cnxid, reverse, nlim, threshold, srcip, dstip, srcport, dstport, start, finish, ts, duration, duration_serverlogs, bulks_number, apps_number, duration_bulks, duration_apps, cpu_user_value, cpu_idle_value, cpu_system_value, cpu_wait_value, disk_octets_read, disk_octets_write, disk_operations_read, disk_operations_write, interface_error_rx, interface_error_tx, interface_packets_rx, interface_packets_tx, interface_octets_rx, interface_octets_tx, load_shortterm, load_midterm, load_longterm, memory_used_value, memory_buffered_value, memory_cached_value, memory_free_value, tcp_close_wait_value, tcp_closed_value, tcp_closing_value, tcp_established_value, tcp_fin_wait1_value, tcp_fin_wait2_value, tcp_last_ack_value, tcp_listen_value, tcp_syn_recv_value, tcp_syn_sent_value, tcp_time_wait_value, beginseq, endseq, wscale, nbbytes, nbpkts, rtt, d_score, retr_score, reorder, rwin_avg, rwin_stddev, rwin_meandev, rwin_score, b_score, capacity, ps_ratio, ps_mass, mss, tput, class, ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, delta_synack, delta_synack_f, delta_get, delta_get_f, processing, processing_f, retrieving_be, retrieving_be_f, tcphs_f, data_f, tcpclosure_f) VALUES ('||tid_t||', '''||tbl_t||''','||row.cnxid||', '''||row.reverse||''', '||nlim_t||', '||thr_t||', '''||srcip||''', '''||dstip||''', '||srcport||', '||dstport||', timestamp '''||begining_t||''', timestamp '''||ending_t||''', '||ts_f||', '||duration_t||', '||duration_serverlogs_t||', '||bulkcount||', '||appcount||', '||bulkduration||', '||appduration||', '||cpu_user_value_t||', '||cpu_idle_value_t||', '||cpu_system_value_t||', '||cpu_wait_value_t||', '||disk_octets_read_t||', '||disk_octets_write_t||', '||disk_operations_read_t||', '||disk_operations_write_t||', '||interface_error_rx_t||', '||interface_error_tx_t||', '||interface_packets_rx_t||', '||interface_packets_tx_t||', '||interface_octets_rx_t||', '||interface_octets_tx_t||', '||load_shortterm_t||', '||load_midterm_t||', '||load_longterm_t||', '||memory_used_value_t||', '||memory_buffered_value_t||', '||memory_cached_value_t||', '||memory_free_value_t||', '||tcp_close_wait_value_t||', '||tcp_closed_value_t||', '||tcp_closing_value_t||', '||tcp_established_value_t||', '||tcp_fin_wait1_value_t||', '||tcp_fin_wait2_value_t||', '||tcp_last_ack_value_t||', '||tcp_listen_value_t||', '||tcp_syn_recv_value_t||', '||tcp_syn_sent_value_t||', '||tcp_time_wait_value_t||', '||beginseq_t||', '||endseq_t||', '||wscale_t||', '||nbbytes_t||', '||nbpkts_t||', '||rtt_t||', '||d_score_t||', '||retr_score_t||', '||reorder_t||', '||rwin_avg_t||', '||rwin_stddev_t||', '||rwin_meandev_t||', '||rwin_score_t||', '||b_score_t||', '||capacity_t||', '||ps_ratio_t||', '||ps_mass_t||', '||mss_t||', '||tput_t||', '||class_t||', '''||ts_syn||''', '''||ts_synack||''', '''||ts_synackack||''', '''||ts_get||''', '''||ts_getack||''', '''||ts_getdata||''', '''||delta_synack||''', '||delta_synack_f||', '''||delta_get||''', '||delta_get_f||', '''||processing||''', '||processing_f||', '''||retrieving_be||''', '||retrieving_be_f||', '||tcphs_f||', '||data_f||', '||tcpclosure_f||') ' ;
			else
				execute 'INSERT into blagnydatasettable (tid, tablename, cnxid, nlim, threshold, srcip, dstip, srcport, dstport, start, finish, ts, duration, duration_serverlogs, bulks_number, apps_number, duration_bulks, duration_apps, cpu_user_value, cpu_idle_value, cpu_system_value, cpu_wait_value, disk_octets_read, disk_octets_write, disk_operations_read, disk_operations_write, interface_error_rx, interface_error_tx, interface_packets_rx, interface_packets_tx, interface_octets_rx, interface_octets_tx, load_shortterm, load_midterm, load_longterm, memory_used_value, memory_buffered_value, memory_cached_value, memory_free_value, tcp_close_wait_value, tcp_closed_value, tcp_closing_value, tcp_established_value, tcp_fin_wait1_value, tcp_fin_wait2_value, tcp_last_ack_value, tcp_listen_value, tcp_syn_recv_value, tcp_syn_sent_value, tcp_time_wait_value, beginseq, endseq, wscale, nbbytes, nbpkts, rtt, d_score, retr_score, reorder, rwin_avg, rwin_stddev, rwin_meandev, rwin_score, b_score, capacity, ps_ratio, ps_mass, mss, tput, class, ts_syn, ts_synack, ts_synackack, ts_get, ts_getack, ts_getdata, delta_synack, delta_synack_f, delta_get, delta_get_f, processing, processing_f, retrieving_be, retrieving_be_f, tcphs_f, data_f, tcpclosure_f) VALUES ('||tid_t||', '''||tbl_t||''','||row.cnxid||', '||nlim_t||', '||thr_t||', '''||srcip||''', '''||dstip||''', '||srcport||', '||dstport||', timestamp '''||begining_t||''', timestamp '''||ending_t||''', '||ts_f||', '||duration_t||', '||duration_serverlogs_t||', '||bulkcount||', '||appcount||', '||bulkduration||', '||appduration||', '||cpu_user_value_t||', '||cpu_idle_value_t||', '||cpu_system_value_t||', '||cpu_wait_value_t||', '||disk_octets_read_t||', '||disk_octets_write_t||', '||disk_operations_read_t||', '||disk_operations_write_t||', '||interface_error_rx_t||', '||interface_error_tx_t||', '||interface_packets_rx_t||', '||interface_packets_tx_t||', '||interface_octets_rx_t||', '||interface_octets_tx_t||', '||load_shortterm_t||', '||load_midterm_t||', '||load_longterm_t||', '||memory_used_value_t||', '||memory_buffered_value_t||', '||memory_cached_value_t||', '||memory_free_value_t||', '||tcp_close_wait_value_t||', '||tcp_closed_value_t||', '||tcp_closing_value_t||', '||tcp_established_value_t||', '||tcp_fin_wait1_value_t||', '||tcp_fin_wait2_value_t||', '||tcp_last_ack_value_t||', '||tcp_listen_value_t||', '||tcp_syn_recv_value_t||', '||tcp_syn_sent_value_t||', '||tcp_time_wait_value_t||', '||beginseq_t||', '||endseq_t||', '||wscale_t||', '||nbbytes_t||', '||nbpkts_t||', '||rtt_t||', '||d_score_t||', '||retr_score_t||', '||reorder_t||', '||rwin_avg_t||', '||rwin_stddev_t||', '||rwin_meandev_t||', '||rwin_score_t||', '||b_score_t||', '||capacity_t||', '||ps_ratio_t||', '||ps_mass_t||', '||mss_t||', '||tput_t||', '||class_t||', '''||ts_syn||''', '''||ts_synack||''', '''||ts_synackack||''', '''||ts_get||''', '''||ts_getack||''', '''||ts_getdata||''', '''||delta_synack||''', '||delta_synack_f||', '''||delta_get||''', '||delta_get_f||', '''||processing||''', '||processing_f||', '''||retrieving_be||''', '||retrieving_be_f||', '||tcphs_f||', '||data_f||', '||tcpclosure_f||') ' ;
			end if;
		else
			RAISE NOTICE '% for table % was not present in datasetglobal_noserverinfo so not treated while being present in bulk_transfer',row.cnxid,tbl_t;
		end if;
		if countercnxs%10=1 then
			RAISE NOTICE 'Finish treating % cnx (on a total of %)',countercnxs,totalcnxs;
		end if;
	end loop; 
	RETURN 'DATASET CORRESPONDING TO TRACE '||tbl_t||' WAS COMPUTED AND STORED IN blagnydatasettable ';


END
$BODY$

language 'plpgsql';
