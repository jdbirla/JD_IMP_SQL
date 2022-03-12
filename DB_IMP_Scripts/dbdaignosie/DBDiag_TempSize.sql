show parameter workarea;
select inst_id, tablespace_name,total_blocks, used_blocks, free_blocks from gv$sort_segment;
alter tablespace temp shrink space;
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' SIZE 100M AUTOEXTEND ON MAXSIZE 32767M;
--------------------------------------------------------------------------------------------
-- Total Temp Space
--------------------------------------------------------------------------------------------
SELECT   A.tablespace_name tablespace, D.mb_total,SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,(
SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
FROM     v$tablespace B, v$tempfile C
WHERE    B.ts#= C.ts#
GROUP BY B.name, C.block_size
) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;

--------------------------------------------------------------------------------------------
-- Which Session Is Using How Much Temp Space
--------------------------------------------------------------------------------------------
SELECT   S.sid || ',' || S.serial# sid_serial, S.username, S.osuser, P.spid, S.module,
S.program, SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
COUNT(*) sort_ops
FROM     v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE    T.session_addr = S.saddr
AND      S.paddr = P.addr
AND      T.tablespace = TBS.tablespace_name
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module,
S.program, TBS.block_size, T.tablespace ORDER BY sid_serial;

--------------------------------------------------------------------------------------------
-- Which Statement (Query) By Who, Is Using How Much Temp Space
--------------------------------------------------------------------------------------------
SELECT   S.sid || ',' || S.serial# sid_serial, S.username,
T.blocks * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
T.sqladdr address, Q.hash_value, Q.sql_text
FROM     v$sort_usage T, v$session S, v$sqlarea Q, dba_tablespaces TBS
WHERE    T.session_addr = S.saddr
AND      T.sqladdr = Q.address (+)
AND      T.tablespace = TBS.tablespace_name
ORDER BY S.sid;