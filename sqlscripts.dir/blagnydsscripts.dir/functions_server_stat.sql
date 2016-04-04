CREATE OR REPLACE FUNCTION  function_server_stats(INTEGER, VARCHAR) RETURNS TEXT AS

$BODY$
DECLARE
	cid_t ALIAS for $1;
	tbl_t ALIAS for $2;
	row RECORD;
	row2 RECORD;
	begin_t timestamp;
	end_t timestamp;
	viewname VARCHAR;
	duration_f float;
	tablename_t VARCHAR;
	tid_t INTEGER;
	-- Metrics for the final values of stats once aggregated
	cpu_user_t float;
	cpu_idle_t float;
	cpu_system_t float;
	cpu_wait_t float;
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
	date_s VARCHAR;
	tblstat_t VARCHAR;
	beg_c timestamp;
	end_c timestamp;
	dayp integer;
	pattern VARCHAR;
	tbl_stat_t VARCHAR;
	begmonth VARCHAR;
	endmonth VARCHAR;
	month_s	VARCHAR;
	month2_s VARCHAR;
	day_s VARCHAR;
	day2_s VARCHAR;
	beg_s varchar;
	end_s varchar;
	countview integer;
	presenceview integer;

BEGIN
	for row in execute 'select count(*) from pg_tables where  schemaname = ''public'' and tablename =  ''ftpserverstatisticsaggregate'' ' LOOP
		if row.count = 0 then
			execute 'CREATE TABLE ftpserverstatisticsaggregate
			(
				tid	integer,
				tablename	varchar,
				cnxid	INTEGER,
				duration_serverlogs float,
				cpu_user_value float,
				cpu_idle_value float,
				cpu_system_value float,
				cpu_wait_value float,
				disk_octets_read float,
				disk_octets_write float,
				disk_operations_read float,
				disk_operations_write float,
				interface_error_rx float,
				interface_error_tx float,
				interface_packets_rx float,
				interface_packets_tx float,
				interface_octets_rx float,
				interface_octets_tx float,
				load_shortterm double precision,
				load_midterm double precision,
				load_longterm double precision,
				memory_used_value float,
				memory_buffered_value float,
				memory_cached_value float,
				memory_free_value float,
				tcp_close_wait_value float,
				tcp_closed_value float,
				tcp_closing_value float,
				tcp_established_value float,
				tcp_fin_wait1_value float,
				tcp_fin_wait2_value float,
				tcp_last_ack_value float,
				tcp_listen_value float,
				tcp_syn_recv_value float,
				tcp_syn_sent_value float,
				tcp_time_wait_value float
			)';
		end if;
	end loop;
	execute 'select extract(day from max(ts)) -  extract(day from min(ts)) from '||tbl_t||' where cnxid = '||cid_t||' ' into dayp;
	execute 'select min(ts) from '||tbl_t||' where cnxid = '||cid_t||' ' into beg_c;
	execute 'select max(ts) from '||tbl_t||' where cnxid = '||cid_t||' ' into end_c;
	execute 'select 1+strpos(cast('''||beg_c||''' as VARCHAR),''-'') ' into begmonth;
	execute 'select 1+strpos(cast('''||end_c||''' as VARCHAR),''-'') ' into endmonth;
	execute 'select substr(cast('''||beg_c||''' as VARCHAR),'||begmonth||',2) ' into month_s;
	execute 'select substr(cast('''||end_c||''' as VARCHAR),'||endmonth||',2) ' into month2_s;
	execute 'select substr(cast('''||beg_c||''' as VARCHAR),'||begmonth||'+3,2) ' into day_s;
	execute 'select substr(cast('''||end_c||''' as VARCHAR),'||endmonth||'+3,2) ' into day2_s;

	execute 'select extract(year from min(ts))||''_''||'''||month_s||'''||''_''||'''||day_s||''' from '||tbl_t||' where cnxid = '||cid_t||' ' into date_s;
	execute 'select ''ftpblagnyinfos_''||'''||date_s||'''||''%'' ' into pattern;

	RAISE NOTICE 'The pattern to match is %',pattern;

	execute 'select tablename from pg_tables where schemaname = ''public'' and tablename like '''||pattern||''' ' into tblstat_t;

	RAISE NOTICE 'Table found for the date % corresponding to table % cid % is %',date_s,tbl_t,cid_t,tblstat_t;


	execute 'select cast(extract(year from timestamp '''||beg_c||''' ) as varchar) ||''_''||'''||month_s||'''||''_''||'''||day_s||''' ' into beg_s;
        execute 'select cast(extract(year from timestamp '''||end_c||''' ) as varchar) ||''_''||'''||month2_s||'''||''_''||'''||day2_s||''' ' into end_s;

	execute 'select replace(replace(replace(replace(''serverinfo_'' || cast('''||beg_s||''' as VARCHAR) || ''_'' || cast('''||end_s||''' as VARCHAR),'' '',''_''),''.'',''_''),'':'',''_''),''-'',''_'')' into viewname;

--	BEGIN
--		execute 'DROP TABLE '||viewname||' ';
--	EXCEPTION
--		WHEN 
--	END;

--	execute 'select count(*) from pg_tables where tablename = '''||viewname||''' ' into presenceview;
--        if presenceview = 0 then
	execute 'CREATE TEMP TABLE '||viewname||' AS select  * from '||tblstat_t||' where ts >= timestamp '''||beg_c||''' and ts <= timestamp '''||end_c||''' ';
--	end if;

--	RAISE NOTICE 'CREATE TEMP TABLE % AS select  * from % where ts >= timestamp %  and ts <= timestamp %',viewname,tblstat_t,beg_c,end_c;

	RAISE NOTICE 'TABLE created as %',viewname;


	if dayp > 1 then 
		RAISE NOTICE 'More than one day to be covered for cnxid %',cid_t;
--		execute 'select 1+strpos(cast('''||beg_c||''' as VARCHAR),''-'') ' into begmonth;
--		execute 'select substr(cast('''||beg_c||''' as VARCHAR),'||begmonth||',2) ' into month_s;
--		execute 'select substr(cast('''||beg_c||''' as VARCHAR),'||begmonth||'+3,2) ' into day_s;
--	        execute 'select substr(cast('''||end_c||''' as VARCHAR),'||endmonth||'+3,2) ' into day2_s;
--		execute 'select extract(year from min(ts))||''_''||'''||month_s||'''||''_''||'''||day_s||''' from '||tbl_t||' where cnxid = '||cid_t||' ' into date_s;
--		execute 'select ''ftpblagnyinfos_''||'''||date_s||'''||''%'' ' into pattern;
--		execute 'select tablename from pg_tables where schemaname = ''public'' and tablename like '''||pattern||''' ' into tblstat_t;

	--        execute 'select tablename from pg_tables where schemaname = ''public'' and tablename like ''ftpblagnyinfos_''||'''||date_s||'''||''%'' ' into tblstat_t;
--		execute 'select replace(replace(replace(''serverinfo_'' || cast('''||beg_c||''' as VARCHAR) || ''_'' || cast('''||end_c||'''),'' '',''_''),''.'',''_''),'':'',''_'') ' into viewname;
--		execute 'select count(*) from pg_tables where tablename = '''||viewname||''' ' into presenceview;
--		if presenceview = 0 then
--			execute 'CREATE TEMP TABLE '||viewname||' AS select  * from '||tblstat_t||' where ts >= timestamp '''||beg_c||''' and ts <= timestamp '''||end_c||''' ';
--		end if;
		
--		RAISE NOTICE 'Table created as %',viewname;

		FOR i IN 1..dayp LOOP
			execute 'select substring(cast(date_trunc(''day'',min(ts)) + interval '' '||i||' day'' as VARCHAR),1,10) from '||tbl_t||' where cnxid = '||cid_t||' ' into date_s;
			RAISE NOTICE 'For day +% the date to match is %',i,date_s;
			execute 'select tablename from pg_tables where schemaname = ''public'' and tablename like ''ftpblagnyinfos_''||'''||date_s||'''||''%'' ' into tblstat_t;
			RAISE NOTICE 'The corresponding table found is %',tbl_stat_t;
			execute 'INSERT into '||viewname||' (ts, cpu0_user_value, cpu1_user_value, cpu0_idle_value, cpu1_idle_value, cpu0_system_value, cpu1_system_value, cpu0_wait_value, cpu1_wait_value, disk_octets_read, disk_octets_write, disk_operations_read, disk_operations_write, interface_error_rx, interface_error_tx, interface_packets_rx, interface_packets_tx, interface_octets_rx, interface_octets_tx, load_shortterm, load_midterm, load_longterm, memory_used_value, memory_buffered_value, memory_cached_value, memory_free_value, tcp_close_wait_value, tcp_closed_value, tcp_closing_value, tcp_established_value, tcp_fin_wait1_value, tcp_fin_wait2_value, tcp_last_ack_value, tcp_listen_value, tcp_syn_recv_value, tcp_syn_sent_value, tcp_time_wait_value) select * from '||tblstat_t||' where ts >= timestamp '''||beg_c||''' and ts <= timestamp '''||end_c||''' ';
		end loop;

	end if;

--	BEGIN
		execute 'select count(*) from '||viewname||' 'into countview;
		RAISE NOTICE 'The view contains % lines',countview;
--	EXCEPTION
--		WHEN 
--
--	END


	--if only one line no period on which computing
	if countview < 2 then
		RAISE NOTICE 'No matching found for the date % and % corresponding to cnxid % in table %, please check the collectd logs and regenerate the ftpserverinfo table',beg_c,end_c,cid_t,tblstat_t;
		duration_f := 0.00000000000001;
		cpu_user_t := 0.0;
		cpu_idle_t := 0.0;
		cpu_system_t := 0.0;
		cpu_wait_t := 0.0;
		disk_octets_read_t := 0.0;
		disk_operations_write_t := 0.0;
		disk_operations_read_t := 0.0;
		disk_octets_write_t := 0.0;
		interface_error_rx_t := 0.0;
		interface_error_tx_t := 0.0;
		interface_packets_rx_t := 0.0;
		interface_packets_tx_t := 0.0;
		interface_octets_rx_t := 0.0;
		interface_octets_tx_t := 0.0;
		load_shortterm_t := 0.0;
		load_midterm_t := 0.0;
		load_longterm_t := 0.0;
		memory_used_value_t := 0.0;
		memory_buffered_value_t := 0.0;
		memory_cached_value_t := 0.0;
		memory_free_value_t := 0.0;
		tcp_close_wait_value_t := 0.0;
		tcp_closed_value_t := 0.0;
		tcp_closing_value_t := 0.0;
		tcp_established_value_t := 0.0;
		tcp_fin_wait1_value_t := 0.0;
		tcp_fin_wait2_value_t := 0.0;
		tcp_last_ack_value_t := 0.0;
		tcp_listen_value_t := 0.0;
		tcp_syn_recv_value_t := 0.0;
		tcp_syn_sent_value_t := 0.0;
		tcp_time_wait_value_t := 0.0;
	else
		execute 'select extract(MINUTES from max(ts) - min(ts))*60 + extract(SECONDS from max(ts) - min(ts)) from '||viewname||' ' into duration_f;
		RAISE NOTICE 'Duration found is %',duration_f;
		execute 'select (sum(cpu0_user_value)+sum(cpu1_user_value))/'||duration_f||' from '||viewname||' ' into cpu_user_t;
		execute 'select (sum(cpu0_idle_value)+sum(cpu1_idle_value))/'||duration_f||' from '||viewname||' ' into cpu_idle_t;
		execute 'select (sum(cpu0_system_value)+sum(cpu1_system_value))/'||duration_f||' from '||viewname||' ' into cpu_system_t;
		execute 'select (sum(cpu0_wait_value)+sum(cpu1_wait_value))/'||duration_f||' from '||viewname||' ' into cpu_wait_t;
		execute 'select sum(disk_octets_read)/'||duration_f||' from '||viewname||' ' into disk_octets_read_t;
		execute 'select sum(disk_operations_write)/'||duration_f||' from '||viewname||' ' into disk_operations_write_t;
		execute 'select sum(disk_operations_read)/'||duration_f||' from '||viewname||' ' into disk_operations_read_t;
		execute 'select sum(disk_octets_write)/'||duration_f||' from '||viewname||' ' into disk_octets_write_t;
		execute 'select sum(interface_error_rx)/'||duration_f||' from '||viewname||' ' into interface_error_rx_t;
		execute 'select sum(interface_error_tx)/'||duration_f||' from '||viewname||' ' into interface_error_tx_t;
		execute 'select sum(interface_packets_rx)/'||duration_f||' from '||viewname||' ' into interface_packets_rx_t;
		execute 'select sum(interface_packets_tx)/'||duration_f||' from '||viewname||' ' into interface_packets_tx_t;
		execute 'select sum(interface_octets_rx)/'||duration_f||' from '||viewname||' ' into interface_octets_rx_t;
		execute 'select sum(interface_octets_tx)/'||duration_f||' from '||viewname||' ' into interface_octets_tx_t;
		execute 'select sum(load_shortterm)/'||duration_f||' from '||viewname||' ' into load_shortterm_t;
		execute 'select sum(load_midterm)/'||duration_f||' from '||viewname||' ' into load_midterm_t;
		execute 'select sum(load_longterm)/'||duration_f||' from '||viewname||' ' into load_longterm_t;
		execute 'select sum(memory_used_value)/'||duration_f||' from '||viewname||' ' into memory_used_value_t;
		execute 'select sum(memory_buffered_value)/'||duration_f||' from '||viewname||' ' into memory_buffered_value_t;
		execute 'select sum(memory_cached_value)/'||duration_f||' from '||viewname||' ' into memory_cached_value_t;
		execute 'select sum(memory_free_value)/'||duration_f||' from '||viewname||' ' into memory_free_value_t;
		execute 'select sum(tcp_close_wait_value)/'||duration_f||' from '||viewname||' ' into tcp_close_wait_value_t;
		execute 'select sum(tcp_closed_value)/'||duration_f||' from '||viewname||' ' into tcp_closed_value_t;
		execute 'select sum(tcp_closing_value)/'||duration_f||' from '||viewname||' ' into tcp_closing_value_t;
		execute 'select sum(tcp_established_value)/'||duration_f||' from '||viewname||' ' into tcp_established_value_t;
		execute 'select sum(tcp_fin_wait1_value)/'||duration_f||' from '||viewname||' ' into tcp_fin_wait1_value_t;
		execute 'select sum(tcp_fin_wait2_value)/'||duration_f||' from '||viewname||' ' into tcp_fin_wait2_value_t;
		execute 'select sum(tcp_last_ack_value)/'||duration_f||' from '||viewname||' ' into tcp_last_ack_value_t;
		execute 'select sum(tcp_listen_value)/'||duration_f||' from '||viewname||' ' into tcp_listen_value_t;
		execute 'select sum(tcp_syn_recv_value)/'||duration_f||' from '||viewname||' ' into tcp_syn_recv_value_t;
		execute 'select sum(tcp_syn_sent_value)/'||duration_f||' from '||viewname||' ' into tcp_syn_sent_value_t;
		execute 'select sum(tcp_time_wait_value)/'||duration_f||' from '||viewname||' ' into tcp_time_wait_value_t;
	end if;
	execute 'select pkt_tid from traces where packets = '''||tbl_t||''' ' into tid_t;

--	if reverse is not null then
		execute 'insert into ftpserverstatisticsaggregate (tid ,tablename ,cnxid ,duration_serverlogs ,cpu_user_value ,cpu_idle_value ,cpu_system_value ,cpu_wait_value ,disk_octets_read ,disk_octets_write ,disk_operations_read ,disk_operations_write ,interface_error_rx ,interface_error_tx ,interface_packets_rx ,interface_packets_tx ,interface_octets_rx ,interface_octets_tx ,load_shortterm ,load_midterm ,load_longterm ,memory_used_value ,memory_buffered_value ,memory_cached_value ,memory_free_value ,tcp_close_wait_value ,tcp_closed_value ,tcp_closing_value ,tcp_established_value ,tcp_fin_wait1_value ,tcp_fin_wait2_value ,tcp_last_ack_value ,tcp_listen_value ,tcp_syn_recv_value ,tcp_syn_sent_value ,tcp_time_wait_value) VALUES ('||tid_t||' ,'''||tbl_t||''' ,'||cid_t||' ,'||duration_f||' ,'||cpu_user_t||' ,'||cpu_idle_t||' ,'||cpu_system_t||' ,'||cpu_wait_t||' ,'||disk_octets_read_t||' ,'||disk_octets_write_t||' ,'||disk_operations_read_t||' ,'||disk_operations_write_t||' ,'||interface_error_rx_t||' ,'||interface_error_tx_t||' ,'||interface_packets_rx_t||' ,'||interface_packets_tx_t||' ,'||interface_octets_rx_t||' ,'||interface_octets_tx_t||' ,'||load_shortterm_t||' ,'||load_midterm_t||' ,'||load_longterm_t||' ,'||memory_used_value_t||' ,'||memory_buffered_value_t||' ,'||memory_cached_value_t||' ,'||memory_free_value_t||' ,'||tcp_close_wait_value_t||' ,'||tcp_closed_value_t||' ,'||tcp_closing_value_t||' ,'||tcp_established_value_t||' ,'||tcp_fin_wait1_value_t||' ,'||tcp_fin_wait2_value_t||' ,'||tcp_last_ack_value_t||' ,'||tcp_listen_value_t||' ,'||tcp_syn_recv_value_t||' ,'||tcp_syn_sent_value_t||' ,'||tcp_time_wait_value_t||')';
--	else
--		execute 'insert into ftpserverstatisticsaggregate (tid ,tablename, cnxid, duration_serverlogs ,cpu_user_value ,cpu_idle_value ,cpu_system_value ,cpu_wait_value ,disk_octets_read ,disk_octets_write ,disk_operations_read ,disk_operations_write ,interface_error_rx ,interface_error_tx ,interface_packets_rx ,interface_packets_tx ,interface_octets_rx ,interface_octets_tx ,load_shortterm ,load_midterm ,load_longterm ,memory_used_value ,memory_buffered_value ,memory_cached_value ,memory_free_value ,tcp_close_wait_value ,tcp_closed_value ,tcp_closing_value ,tcp_established_value ,tcp_fin_wait1_value ,tcp_fin_wait2_value ,tcp_last_ack_value ,tcp_listen_value ,tcp_syn_recv_value ,tcp_syn_sent_value ,tcp_time_wait_value) VALUES ('||tid_t||' ,'''||tbl_t||''' ,'||cid_t||', '||duration_f||' ,'||cpu_user_value_t||' ,'||cpu_idle_value_t||' ,'||cpu_system_value_t||' ,'||cpu_wait_value_t||' ,'||disk_octets_read_t||' ,'||disk_octets_write_t||' ,'||disk_operations_read_t||' ,'||disk_operations_write_t||' ,'||interface_error_rx_t||' ,'||interface_error_tx_t||' ,'||interface_packets_rx_t||' ,'||interface_packets_tx_t||' ,'||interface_octets_rx_t||' ,'||interface_octets_tx_t||' ,'||load_shortterm_t||' ,'||load_midterm_t||' ,'||load_longterm_t||' ,'||memory_used_value_t||' ,'||memory_buffered_value_t||' ,'||memory_cached_value_t||' ,'||memory_free_value_t||' ,'||tcp_close_wait_value_t||' ,'||tcp_closed_value_t||' ,'||tcp_closing_value_t||' ,'||tcp_established_value_t||' ,'||tcp_fin_wait1_value_t||' ,'||tcp_fin_wait2_value_t||' ,'||tcp_last_ack_value_t||' ,'||tcp_listen_value_t||' ,'||tcp_syn_recv_value_t||' ,'||tcp_syn_sent_value_t||' ,'||tcp_time_wait_value_t||')';
--	end if;

	execute 'DROP TABLE '||viewname||' ';
	
	RETURN 'The server statistics corresponding to period of the connection '||cid_t||' of the table '||tbl_t||' (tid '||tid_t||')are stored in the table ftpserverstatisticsaggregate';
END
$BODY$

language 'plpgsql';
