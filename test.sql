CREATE TABLE pgkron.test( id serial primary key, value text not null );

insert into pgkron.job(name, sql, run_at, interval) VALUES ( 'OK', 'INSERT INTO pgkron.test (value) VALUES (''ok'')', now(), '1 hour');
insert into pgkron.job(name, sql, run_at, interval) VALUES ( 'OK then FAIL', 'INSERT INTO pgkron.test (value) VALUES (''fail''); bad sql', now(), '1 hour');
insert into pgkron.job(name, sql, run_at, interval) VALUES ( 'FAIL', 'bad sql', now(), '1 hour');

insert into pgkron.job(name, sql, run_at, interval) VALUES ( 'DOUBLE', $$
INSERT INTO pgkron.test (value) VALUES ('two-1');
INSERT INTO pgkron.test (value) VALUES ('two-2');
$$, now(), '1 hour');

-- run any pending jobs
CALL pgkron.run();

-- should have a row for each job
select * from pgkron.job_log;

-- have the single ok, and the two rows from double
select * from pgkron.test;

-- this time only the ok sql should run
CALL pgkron.run();

select * from pgkron.job_log;
select * from pgkron.test;