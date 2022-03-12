select * from v$session; -- Didicated server or shared?
show parameter sga;-------- SGA_TARGET value 
select OPER_MODE, a.* from v$memory_resize_ops a;--- OPER_MODE: DEFERRED or IMMEDIATE

select  a.* from v$sga_resize_ops a;
select  a.* from v$sga_current_resize_ops a;
show parameter LOG_BUFFER;--- Redologbufer size (should be close to 500MB).
show parameter STATISTICS_LEVEL;-- Should be TYPICAL or ALL for ASMM to work.

show parameter shared_POOL;
show parameter large_POOL;
show parameter db_cache_size;
select maxbytes/(1024*1024*1024) GB,  a.* from dba_data_files a;
select maxbytes/(1024*1024*1024) GB,  a.* from dba_temp_files a;
select * from v$logfile;---REDO LOGFILE

select * from v$log;

---------------------------------------------------
SELECT 
         sga.allo sgaInGb,
         pga.allo pgaInGb,
         (sga.allo + pga.allo) totGb,
         TRUNC (SN.END_INTERVAL_TIME, 'mi') time
    FROM (  SELECT snap_id,
                   INSTANCE_NUMBER,
                   ROUND (SUM (bytes) / 1024 / 1024 / 1024, 3) allo
              FROM DBA_HIST_SGASTAT
          GROUP BY snap_id, INSTANCE_NUMBER) sga,
         (  SELECT snap_id,
                   INSTANCE_NUMBER,
                   ROUND (SUM (VALUE) / 1024 / 1024 / 1024, 3) allo
              FROM DBA_HIST_PGASTAT
             WHERE name = 'total PGA allocated'
          GROUP BY snap_id, INSTANCE_NUMBER) pga,
         dba_hist_snapshot sn
   WHERE     sn.snap_id = sga.snap_id
         AND sn.INSTANCE_NUMBER = sga.INSTANCE_NUMBER
         AND sn.snap_id = pga.snap_id
         AND sn.INSTANCE_NUMBER = pga.INSTANCE_NUMBER
	ORDER BY sn.snap_id DESC, sn.INSTANCE_NUMBER;
