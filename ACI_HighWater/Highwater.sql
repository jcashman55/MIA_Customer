-- use micstats;

-- truncate table taskevents

-- insert into taskevents (eventtime,eventtype,taskid,nominalstart,cost) 
 -- select TimeStarted as eventtime,'TaskStart' as EventType, taskid, nominalstart, 1 from taskruns;

-- insert into taskevents (eventtime,eventtype,taskid,nominalstart,cost) 
-- select TimeEnded as eventtime,'TaskEnd' as EventType, taskid, nominalstart, -1 from taskruns;

-- delete from taskevents where taskid=222300
-- delete from taskevents where eventtime is null


-- select * from taskevents where eventtime is null order by eventtime asc;
-- delete from taskevents where taskid = 444006166 and nominalstart = '2021-10-18 20:55:00.000'
-- select * from taskruns order by taskid asc

-- select * from taskevents order by eventtime asc

-- select * from taskevents  where taskid in (
-- select te.taskid  from taskevents te
-- group by te.taskid,te.nominalstart
-- having count(*) != 2)

-- select eventtime, eventtype, taskid, nominalstart, cost, sum(cost) over (order by eventtime) as TasksRunning from taskevents
-- select eventtime, eventtype, taskid, nominalstart, cost from taskevents order by eventtime asc

-- One full run....
/*
use micstats;
truncate table taskevents;

insert into taskevents (eventtime,eventtype,taskid,nominalstart,taskname,cost) 
select TimeStarted as eventtime,'TaskStart' as EventType, taskid, nominalstart, taskname, 1 from taskruns;

insert into taskevents (eventtime,eventtype,taskid,nominalstart,taskname, cost) 
select TimeEnded as eventtime,'TaskEnd' as EventType, taskid, nominalstart, taskname, -1 from taskruns;

-- may need to add the delete logic to delete any transactions that don't have a start AND an end.
delete from taskevents where taskid=222300;
delete from taskevents where eventtime is null;

select eventtime, eventtype, taskid, nominalstart, taskname, cost, sum(cost) over (order by eventtime) as TasksRunning from taskevents;

*/
10:14:34	truncate table taskevents  insert into taskevents (eventtime,eventtype,taskid,nominalstart,cost)  select TimeStarted as eventtime,'TaskStart' as EventType, taskid, nominalstart, 1 from taskruns	Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'insert into taskevents (eventtime,eventtype,taskid,nominalstart,cost)  select Ti' at line 3	0.000 sec
