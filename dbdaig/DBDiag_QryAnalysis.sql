select * from DBA_2PC_PENDING;-- where state='prepared';
select * from dba_2pc_neighbors;
--commit force 'trxid'-- trxid from aove queries
--rollback force 'trxid'--
----------------------------------------------------------------------- Session what is going on--------------------------------
select TO_CHAR(a.SQL_EXEC_START, 'DD-MON-YYYY HH24:MI:SS') SQL_ST,
a.*,b.* from v$session a , v$process b
where a.paddr=b.addr  and a.username='VM1DTA'
and status='ACTIVE'
;
------------------------------------------------------------------------ dbms_xplan.display_cursor for query--------------------
select * from table(dbms_xplan.display_cursor());
select * from table(dbms_xplan.display_cursor(sql_id=>'3w0rq4gd36d7'));
-- more detail analysis: in the target query add hint GATHER_PLAN_STATISTICS
select /*+ GATHER_PLAN_STATISTICS */ * from all_tab_statistics where owner='VM1DTA'
and STALE_STATS = 'YES'; -- find stale stats
select * from user_indexes where table_name='CHDRPF';
-- more detail analysis: in the display_cursor add format=>'ALLSTATS LAST' +cost +bytes
select * from table(dbms_xplan.display_cursor(sql_id=>'cywys509a23kb',format=>'ALLSTATS LAST +cost +bytes '));
select * from table(dbms_xplan.display_cursor());
-- more detail analysis: in the display_cursor add format=> PEEKED_BINDS to see the bind variable values.
select * from table(dbms_xplan.display_cursor(sql_id=>'',format=>'+PEEKED_BINDS'));
                                              
------------------------------------------------------- All queries executed within certaing time -----------------------------
With T as (
select * from dba_hist_active_sess_history a 
where a.sample_time > '21-10-16 14:38:00' --- start time
and a.sample_time < '21-10-16 14:58:00'------ end time
and sql_id is not null
order by a.sample_time desc 
)
,
B as (
select distinct(CURRENT_OBJ#) as obid from T, v$sqltext b
where T.sql_id = b.sql_id
and PROGRAM like  'JDBC Thin Client%'
) select * from dba_objects d , B where d.object_id=B.obid  and d.object_type = 'TABLE'
;

                                              
--------------- Find the query which is causing the leak of connection or cursor----------
select  sql_text, count(*) as "OPEN CURSORS", user_name 
from v$open_cursor  where user_name = 'VM1DTA'
group by sql_text, user_name  order by count(*) desc;                                              


-------------------- Esimate query completion time --------------------------------------
SELECT SID, SERIAL#, CONTEXT, SOFAR, TOTALWORK,
ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM V$SESSION_LONGOPS
WHERE TOTALWORK != 0
AND SOFAR != TOTALWORK

------------------- Current executing query details--------------------------------------
select a.inst_id,a.sid,a.username,b.PARSING_SCHEMA_NAME,a.module,a.sql_id,a.sql_child_number child,b.hash_value,to_char (a.sql_exec_start, 'dd-Mon-yyyy hh24:mi:ss') sql_exec_start,(sysdate-sql_exec_start)*24*60*60 SECS,b.rows_processed,a.status,substr(b.sql_text,1,50) sql_text
from gv$session a,gv$sqlarea b
where a.sql_hash_value = b.hash_value
and a.sql_address = b.address
and a.module not like '%emagent%'
and a.module not like '%oraagent.bin%'
and a.username is not null
order by a.status;







