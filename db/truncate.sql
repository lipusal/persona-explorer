--Based off of to http://stackoverflow.com/a/2829485/2333689
--Usage: SELECT truncate_tables('persona');
CREATE OR REPLACE FUNCTION truncate_tables(username IN VARCHAR) RETURNS void AS $$
DECLARE
    statements CURSOR FOR
    SELECT tablename FROM pg_tables
    WHERE tableowner = username AND schemaname = 'public';
BEGIN
  FOR stmt IN statements LOOP
    IF stmt.tablename != 'schema_migrations' THEN
      EXECUTE 'TRUNCATE TABLE ' || quote_ident(stmt.tablename) || ' RESTART IDENTITY CASCADE;';
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
