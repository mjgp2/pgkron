# pgkron - an RDS compatible alternative to pg_cron

RDS does not support pg_cron :(

Specify jobs as SQL to run with an interval (i.e. schedule the next run for a specific interval after the current job execution finishes).

You need to set up an external source (such as cron on a management box or a lambda) to run `CALL pgkron.run();` on whatever interval you want.

Each job will execute at most once in one call of `CALL pgkron.run();`.

It is perfectly safe to have multiple callers calling `CALL pgkron.run();` - non-blocking locks are used to ensure that only one instance of a job is executing at any time.

See [test.sql](./test.sql) for setup and [test.sql](./test.sql) for example usage.

Requires postgres 11+

<3