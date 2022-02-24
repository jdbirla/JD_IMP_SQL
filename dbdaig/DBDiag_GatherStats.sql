---------------------------------------------------------------------  STATS and INDEX last Analyzed---------------------------
select TO_CHAR(LAST_ANALYZED,'DD-MON-YYYY HH24:MI:SS') as last_ana, a.* from all_tab_statistics a where a.owner='VM1DTA'
and a.STALE_STATS = 'YES';  -- find stale stats
select * from user_indexes where table_name='CHDRPF'; -- see the index stats of a table.

exec dbms_stats.gather_schema_stats(ownname=>'VM1DTA',block_sample=>true, degree=>20);  
select * from DBA_TAB_MODIFICATIONS where TABLE_OWNER =  'VM1DTA'; 

exec dbms_stats.gather_schema_stats(ownname=>'VM1DTA', options=>'GATHER STALE');
EXEC DBMS_STATS.gather_table_stats('VM1DTA', 'ZALTPF'); --- gather stats of a table.
exec DBMS_STATS.GATHER_TABLE_STATS (ownname => 'VM1DTA' , tabname => 'ZALTPF',cascade => true, 
estimate_percent => 10,method_opt=>'for all indexed columns size 1', granularity => 'ALL', degree => 10);
