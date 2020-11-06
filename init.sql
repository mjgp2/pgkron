CREATE SCHEMA pgkron;
CREATE TABLE pgkron.job( id serial primary key, name text not null unique, sql text not null, run_at timestamp with time zone not null, interval text not null);
CREATE TABLE pgkron.job_log( id serial primary key, job_id int not null references pgkron.job(id), run_at timestamp with time zone not null, sql text not null, row_count int, error boolean not null );

CREATE OR REPLACE PROCEDURE pgkron.run()
AS $$
DECLARE
   job_id integer; 
   job_sql text;
   job_run_at timestamp with time zone;
   job_interval text;
   row_count int;
   error boolean;
   max_jobs integer;
   jobs integer := 0;
   job_ids int[] := ARRAY[]::int[];
BEGIN

select count(*) into max_jobs from pgkron.job;

while jobs < max_jobs loop

  row_count := null;
  error := false;

  BEGIN
    select id, sql, run_at, interval into job_id, job_sql, job_run_at, job_interval from pgkron.job where run_at < now() and not ( id = any(job_ids) ) order by run_at limit 1 for update skip locked;
    if job_id is null then
      return;
    END IF;

    BEGIN
      RAISE DEBUG 'pgkron: sql running: %', job_sql;
      EXECUTE job_sql;
      GET DIAGNOSTICS row_count = ROW_COUNT;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE 'pgkron: sql failed: %', job_sql;
        error:=true;
    END;

    INSERT INTO pgkron.job_log ( job_id, run_at, row_count, error, sql ) VALUES ( job_id, job_run_at, row_count, error, job_sql );
    UPDATE pgkron.job SET run_at = now() + job_interval::interval where id = job_id;
    COMMIT; 
  END; -- end job execution
  jobs := jobs + 1;
  job_ids := job_ids || job_id;
END LOOP;

RAISE DEBUG 'pgkron: run % jobs', jobs;
END;
$$
LANGUAGE plpgsql;