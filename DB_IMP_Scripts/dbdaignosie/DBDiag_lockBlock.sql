WITH A AS (
select * from v$session where schemaname='VM1DTA' --and OSUSER like 'was%'
), 
B AS (
select * from v$process 
)
select * from A,B 
where A.PADDR = B.ADDR
and A.STATUS='ACTIVE'
;---------------------------- Get about sessions.

select * from v$lock;

--------------------- Blocking sessions......................
select
   blocking_session,
   sid,
   serial#,
   wait_class,
   seconds_in_wait
from
   v$session
where
   blocking_session is not NULL
order by
   blocking_session;
   
------
select SID,SADDR,TADDR,SQL_ID,PREV_SQL_ID,a.* from v$session where sid in (774);--- can get sqlid


select * from v$session_event where sid =774 and wait_class= 'Configuration';--------- this will give the event id.

select * from v$sql where sql_id in ('0tz37yb37kqwv');--- b00jwzmt8sgnx = select g.* | b56n6dvrk3aby = insert into zirh_tmp

select * from v$lock where sid in (770,869,1059);

--------------- From eventid get the sql.
select sql_id, event_id from v$active_session_history where event_id = '281768874';--- 0tz37yb37kqwv	281768874

select  a.* from v$transaction a;

