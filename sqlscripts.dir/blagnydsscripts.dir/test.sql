CREATE OR REPLACE FUNCTION test_exeption() RETURNS TEXT AS

$BODY$

DECLARE


BEGIN
	BEGIN
		EXECUTE 'DROP VIEW testexecption';
	EXCEPTION
	WHEN no_data THEN
		RAISE NOTICE 'Exception no_data caught';
	WHEN data_exception THEN
		RAISE NOTICE 'Excption data_exception';
	END;	

	EXECUTE 'CREATE TEMP VIEW testexecption as select * from ftpblagnyinfos_2013_05_23_1369260000_2013_05_23_1369346399 where ts >= ''2013-05-23 23:18:24.167006'' and ts <= ''2013-05-23 23:20:33.868273'' ';

	RETURN 'Function finished';
END

$BODY$

language 'plpgsql';
