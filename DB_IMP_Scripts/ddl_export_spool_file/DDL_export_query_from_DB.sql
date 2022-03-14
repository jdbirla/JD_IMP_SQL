
set pagesize 0
set long 90000
set feedback off
set echo off 

spool H:\SIT_STAGE_DATA\Phase-2\ITR3_PT\Execution\STG_TO_IG\stagedbusr_DDL.sql 

--connect scott/tiger;

SELECT DBMS_METADATA.GET_DDL('TABLE',u.table_name)
     FROM USER_TABLES u where u.table_name in ('BUSDPF',
'ITEMPF'
);

SELECT DBMS_METADATA.GET_DDL('INDEX',u.index_name)
     FROM USER_INDEXES u where u.table_name in ('BUSDPF',
'ITEMPF'
);

spool off;