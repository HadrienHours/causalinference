CREATE OR REPLACE FUNCTION  function_server_stats_btid(INTEGER, VARCHAR) RETURNS TEXT AS

$BODY$
DECLARE
	btid_t ALIAS for $1;
	tableinfos ALIAS for $2;
	row RECORD;
	row2 RECORD;
	begin_t timestamp;
	end_t timestamp;
	viewname VARCHAR;
	duration_f float;
	tablename_t VARCHAR;
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

BEGIN
	for row in execute 'select count(*) from pg_tables where  schemaname = ''public'' and tablename =  ''ftpserverstatisticsaggregate'' ' LOOP
		if row.count = 0 then
			execute 'CREATE TABLE ftpserverstatisticsaggregate
			(
				tid	integer,
				tablename	varchar,
				cnxid	INTEGER,
				reverse	BIT(1),
				btid	INTEGER,
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

	for row in execute 'select * from bulk_transfer where btid = '||btid_t||' ' LOOP
		begin_t := row.start;
		execute 'select timestamp '''||row.start||''' + interval '''||row.duration||''' ' into end_t;
		execute 'select replace(replace(replace(''serverinfo_'' || cast('''||begin_t||''' as VARCHAR) || ''_'' || cast('''||end_t||'''),'' '',''_''),''.'',''_''),'':'',''_'') ' into viewname;
		execute 'CREATE TEMP VIEW '||viewname||' AS select  * from '||tableinfos||' where ts >= timestamp '''||begin_t||''' and ts <= timestamp '''||end_t||''' ';
		execute 'select extract(MINUTES from max(ts) - min(ts))*60 + extract(SECONDS from max(ts) - min(ts)) from '||view_name||' ' into duration_f;
		execute 'select (sum(cpu0_user_value)+sum(cpu1_user_value))/'||duration_f||' from '||view_name||' ' into cpu_user_t;
		execute 'select (sum(cpu0_idle_value)+sum(cpu1_idle_value))/'||duration_f||' from '||view_name||' ' into cpu_idle_t;
		execute 'select (sum(cpu0_system_value)+sum(cpu1_system_value))/'||duration_f||' from '||view_name||' ' into cpu_system_t;
		execute 'select (sum(cpu0_wait_value)+sum(cpu1_wait_value))/'||duration_f||' from '||view_name||' ' into cpu_wait_t;
		execute 'select sum(disk_octets_read)/'||duration_f||' from '||view_name||' ' into disk_octets_read_t;
		execute 'select sum(disk_operations_write)/'||duration_f||' from '||view_name||' ' into disk_operations_write_t;
		execute 'select sum(disk_operations_read)/'||duration_f||' from '||view_name||' ' into disk_operations_read_t;
		execute 'select sum(disk_octets_write)/'||duration_f||' from '||view_name||' ' into disk_octets_write_t;
		execute 'select sum(interface_error_rx)/'||duration_f||' from '||view_name||' ' into interface_error_rx_t;
		execute 'select sum(interface_error_tx)/'||duration_f||' from '||view_name||' ' into interface_error_tx_t;
		execute 'select sum(interface_packets_rx/'||duration_f||' from '||view_name||' ' into interface_packets_rx_t;
		execute 'select sum(interface_packets_tx/'||duration_f||' from '||view_name||' ' into interface_packets_tx_t;
		execute 'select sum(interface_octets_rx/'||duration_f||' from '||view_name||' ' into interface_octets_rx_t;
		execute 'select sum(interface_octets_tx/'||duration_f||' from '||view_name||' ' into interface_octets_tx_t;
		execute 'select sum(load_shortterm/'||duration_f||' from '||view_name||' ' into load_shortterm_t;
		execute 'select sum(load_midterm/'||duration_f||' from '||view_name||' ' into load_midterm_t;
		execute 'select sum(load_longterm/'||duration_f||' from '||view_name||' ' into load_longterm_t;
		execute 'select sum(memory_used_value/'||duration_f||' from '||view_name||' ' into memory_used_value_t;
		execute 'select sum(memory_buffered_value/'||duration_f||' from '||view_name||' ' into memory_buffered_value_t;
		execute 'select sum(memory_cached_value/'||duration_f||' from '||view_name||' ' into memory_cached_value_t;
		execute 'select sum(memory_free_value/'||duration_f||' from '||view_name||' ' into memory_free_value_t;
		execute 'select sum(tcp_close_wait_value/'||duration_f||' from '||view_name||' ' into tcp_close_wait_value_t;
		execute 'select sum(tcp_closed_value/'||duration_f||' from '||view_name||' ' into tcp_closed_value_t;
		execute 'select sum(tcp_closing_value/'||duration_f||' from '||view_name||' ' into tcp_closing_value_t;
		execute 'select sum(tcp_established_value/'||duration_f||' from '||view_name||' ' into tcp_established_value_t;
		execute 'select sum(tcp_fin_wait1_value/'||duration_f||' from '||view_name||' ' into tcp_fin_wait1_value_t;
		execute 'select sum(tcp_fin_wait2_value/'||duration_f||' from '||view_name||' ' into tcp_fin_wait2_value_t;
		execute 'select sum(tcp_last_ack_value/'||duration_f||' from '||view_name||' ' into tcp_last_ack_value_t;
		execute 'select sum(tcp_listen_value/'||duration_f||' from '||view_name||' ' into tcp_listen_value_t;
		execute 'select sum(tcp_syn_recv_value/'||duration_f||' from '||view_name||' ' into tcp_syn_recv_value_t;
		execute 'select sum(tcp_syn_sent_value/'||duration_f||' from '||view_name||' ' into tcp_syn_sent_value_t;
		execute 'select sum(tcp_time_wait_value/'||duration_f||' from '||view_name||' ' into tcp_time_wait_value_t;
		execute 'select packets from traces where pkt_tid = '||row.tid||' ' into tablename_t;

		if reverse is not null then
			execute 'insert into ftpserverstatisticsaggregate (tid ,tablename ,cnxid ,reverse ,btid  ,duration_serverlogs ,cpu_user_value ,cpu_idle_value ,cpu_system_value ,cpu_wait_value ,disk_octets_read ,disk_octets_write ,disk_operations_read ,disk_operations_write ,interface_error_rx ,interface_error_tx ,interface_packets_rx ,interface_packets_tx ,interface_octets_rx ,interface_octets_tx ,load_shortterm ,load_midterm ,load_longterm ,memory_used_value ,memory_buffered_value ,memory_cached_value ,memory_free_value ,tcp_close_wait_value ,tcp_closed_value ,tcp_closing_value ,tcp_established_value ,tcp_fin_wait1_value ,tcp_fin_wait2_value ,tcp_last_ack_value ,tcp_listen_value ,tcp_syn_recv_value ,tcp_syn_sent_value ,tcp_time_wait_value) VALUES ('||row.tid||' ,'''||tablename_t||''' ,'||row.cnxid||' ,'||row.reverse||' ,'||row.btid||' ,'||duration_f||' ,'||cpu_user_value_t||' ,'||cpu_idle_value_t||' ,'||cpu_system_value_t||' ,'||cpu_wait_value_t||' ,'||disk_octets_read_t||' ,'||disk_octets_write_t||' ,'||disk_operations_read_t||' ,'||disk_operations_write_t||' ,'||interface_error_rx_t||' ,'||interface_error_tx_t||' ,'||interface_packets_rx_t||' ,'||interface_packets_tx_t||' ,'||interface_octets_rx_t||' ,'||interface_octets_tx_t||' ,'||load_shortterm_t||' ,'||load_midterm_t||' ,'||load_longterm_t||' ,'||memory_used_value_t||' ,'||memory_buffered_value_t||' ,'||memory_cached_value_t||' ,'||memory_free_value_t||' ,'||tcp_close_wait_value_t||' ,'||tcp_closed_value_t||' ,'||tcp_closing_value_t||' ,'||tcp_established_value_t||' ,'||tcp_fin_wait1_value_t||' ,'||tcp_fin_wait2_value_t||' ,'||tcp_last_ack_value_t||' ,'||tcp_listen_value_t||' ,'||tcp_syn_recv_value_t||' ,'||tcp_syn_sent_value_t||' ,'||tcp_time_wait_value_t||')';
		else
			execute 'insert into ftpserverstatisticsaggregate (tid ,tablename ,cnxid ,btid  ,duration_serverlogs ,cpu_user_value ,cpu_idle_value ,cpu_system_value ,cpu_wait_value ,disk_octets_read ,disk_octets_write ,disk_operations_read ,disk_operations_write ,interface_error_rx ,interface_error_tx ,interface_packets_rx ,interface_packets_tx ,interface_octets_rx ,interface_octets_tx ,load_shortterm ,load_midterm ,load_longterm ,memory_used_value ,memory_buffered_value ,memory_cached_value ,memory_free_value ,tcp_close_wait_value ,tcp_closed_value ,tcp_closing_value ,tcp_established_value ,tcp_fin_wait1_value ,tcp_fin_wait2_value ,tcp_last_ack_value ,tcp_listen_value ,tcp_syn_recv_value ,tcp_syn_sent_value ,tcp_time_wait_value) VALUES ('||row.tid||' ,'''||tablename_t||''' ,'||row.cnxid||', '||row.btid||' ,'||duration_f||' ,'||cpu_user_value_t||' ,'||cpu_idle_value_t||' ,'||cpu_system_value_t||' ,'||cpu_wait_value_t||' ,'||disk_octets_read_t||' ,'||disk_octets_write_t||' ,'||disk_operations_read_t||' ,'||disk_operations_write_t||' ,'||interface_error_rx_t||' ,'||interface_error_tx_t||' ,'||interface_packets_rx_t||' ,'||interface_packets_tx_t||' ,'||interface_octets_rx_t||' ,'||interface_octets_tx_t||' ,'||load_shortterm_t||' ,'||load_midterm_t||' ,'||load_longterm_t||' ,'||memory_used_value_t||' ,'||memory_buffered_value_t||' ,'||memory_cached_value_t||' ,'||memory_free_value_t||' ,'||tcp_close_wait_value_t||' ,'||tcp_closed_value_t||' ,'||tcp_closing_value_t||' ,'||tcp_established_value_t||' ,'||tcp_fin_wait1_value_t||' ,'||tcp_fin_wait2_value_t||' ,'||tcp_last_ack_value_t||' ,'||tcp_listen_value_t||' ,'||tcp_syn_recv_value_t||' ,'||tcp_syn_sent_value_t||' ,'||tcp_time_wait_value_t||')';
		end if;
	end loop;

	RETURN 'The server statistics corresponding to period of the bulk '||btid_t||' are stored in the table ftpserverstatisticsaggregate';
END
$BODY$

language 'plpgsql';
