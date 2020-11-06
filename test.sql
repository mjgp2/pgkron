CREATE TABLE pgkron.test( id serial primary key, value text not null );
insert into pgkron.job(sql, run_at, interval) VALUES ( 'INSERT INTO pgkron.test (value) VALUES (now()::text)', now(), '1 millisecond');
insert into pgkron.job(sql, run_at, interval) VALUES ( 'bad sql', now(), '1 hour');

-- run any pending jobs
CALL pgkron.run();

-- should have a couple of results in here now
select * from pgkron.job_log;

-- this time only the ok sql should run
CALL pgkron.run();

-- we will have 3 results in here now because the bad SQL will not need re-running
select * from pgkron.job_log;
