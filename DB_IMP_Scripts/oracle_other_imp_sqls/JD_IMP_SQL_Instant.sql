-----===========================ORACLE==========================================================
--Oralce information queries 
select * from v$sql order by FIRST_LOAD_TIME desc ;
SELECT * FROM USER_SYS_PRIVS; 
SELECT * FROM USER_TAB_PRIVS; 
SELECT * FROM USER_ROLE_PRIVS;
select * from all_tab_modifications where table_owner='STAGEDBUSR2';
select * from v$parameter;
show parameter parallel;
show PARAMETERS;
show parameter CPU_COUNT;
--Flash back data fetch
select chdrnum, CCDATE, CRDATE from gchipf as of TIMESTAMP TO_TIMESTAMP('2020-10-07 09:00:00','YYYY-MM-DD HH:MI:SS') where chdrnum ='05009031';
select 'New',c.* from clntpf c where clntnum='10000002'
union
select 'Old',c.* from clntpf as of timestamp to_timestamp('2021-07-01 17:40:00','YYYY-MM-DD HH24:MI:SS') c where clntnum='10000002';
---Monitoring
select * from v$sql ;
select SQL_TEXT,CPU_TIME, ELAPSED_TIME,MODULE,FIRST_LOAD_TIME,last_active_time,last_load_time from v$sql where SQL_TEXT not  like '%ZDOEBL%' order by LAST_LOAD_TIME desc ,ELAPSED_TIME desc ;
select name, value
from v$statname n, v$sesstat t
where n.statistic# = t.statistic#
and t.sid = ( select sid from v$mystat where rownum = 1 )
and n.name in
('session pga memory', 'session pga memory max','session uga memory', 'session uga memory max');
--PGA Memory

select NAME,ROUND((VALUE)/1024/1024,1) MB , round(VALUE/POWER(1024,3),1)  GB  from v$pgastat;
show PARAMETERS PGA;
/*
aggregate PGA target parameter	17408	17
aggregate PGA auto target	15211.7	14.9
global memory bound	100	0.1
total PGA inuse	687.1	0.7
total PGA allocated	2321.5	2.3
maximum PGA allocated	22751.4	22.2
*/
--============================================================================================
-- Query to Get List of all locked objects
SELECT B.Owner, B.Object_Name, A.Oracle_Username, A.OS_User_Name,a.session_id ,a.object_id
FROM V$Locked_Object A, All_Objects B
WHERE A.Object_ID = B.Object_ID ; 
-- and A.OS_USER_NAME = 'mahendar' 
-- Query to Get List of locked sessions        
select SID,SERIAL#,INST_ID from gv$session a  where a.osuser='JPAJBI';

-- and osuser =  'mahendar';
-- o/p: 314 26513   1
-- Statement to Kill the session [pass values in the same order and append @ for inst_id]
alter system kill session '106,44953,@1';

--Kill paralle threads session
select 'alter system kill session ''' || s.sid ||',' || s.serial# || ''';'
                                        from gv$session s,gv$sql q
                            where s.sql_address = q.address
                                         and s.sql_hash_value = q.hash_value
                                         and s.sql_child_number = q.child_number
                                         AND s.status = 'ACTIVE'
                                         and s.module = 'DBMS_SCHEDULER';
										 
--============================================================================================

--CREATE DATABASE LINK DMSTAGEDBLINK CONNECT TO STAGEDBUSR IDENTIFIED BY  USING '';
--CREATE DATABASE LINK DMSTGUSR2DBLINK CONNECT TO STAGEDBUSR2 IDENTIFIED BY  USING '';

select itemitem,  SUBSTR(utl_raw.cast_to_varchar2(genarea),9,7) from itempf where itemtabl='TQ9FK';

alter table STAGEDBUSR2.ALTER_REASON_CODE nologging;
alter table STAGEDBUSR2.KANJI_ADDRESS_LIST_TMP MOVE INITRANS 5;
----Rebuild---
alter index PERSNL_CLNT_FLG_APCUCD_IDX1 rebuild;

--ALTER SESSION SET CURRENT_SCHEMA =jdVM1DTA;



--============================================================================================
select 'alter index '|| 'jdVM1DTA.' 
            ||INDEX_NAME||' rebuild ;' from user_indexes where STATUS!='VALID';
--Granted Roles:

SELECT * 
  FROM DBA_ROLE_PRIVS 
 WHERE GRANTEE = 'USER';
--Privileges Granted Directly To User:

SELECT * 
  FROM DBA_TAB_PRIVS 
 WHERE GRANTEE = 'USER';
--Privileges Granted to Role Granted to User:

SELECT * 
  FROM DBA_TAB_PRIVS  
 WHERE GRANTEE IN (SELECT granted_role 
                     FROM DBA_ROLE_PRIVS 
                    WHERE GRANTEE = 'USER');
--Granted System Privileges:

SELECT * 
  FROM DBA_SYS_PRIVS 
 WHERE GRANTEE = 'USER';
--If you want to lookup for the user you are currently connected as, you can replace DBA in the table name with USER and remove the WHERE clause.

-------------------------
----All tables counts in one select query

select 
( SELECT             COUNT(*)         FROM             stagedbusr2.ALTER_REASON_CODE  ) AS 			ALTER_REASON_CODE,
( SELECT             COUNT(*)         FROM             stagedbusr2.BTDATE_PTDATE_LIST  ) AS         BTDATE_PTDATE_LIST,
( SELECT             COUNT(*)         FROM             stagedbusr2.asrf_rnw_dtrm  ) AS                   asrf_rnw_dtrm

from dual;
----------------------------------------------


