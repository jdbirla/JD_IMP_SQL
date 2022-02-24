set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/BSSCPF.sql;
select /*+ paralle(10) */'"'||SYS_STS09VTYEU1CRYFEY3#$O23B7E||'","'||UNIQUE_NUMBER||'","'||BSCHEDNAM||'","'||BSCHEDNUM||'","'||BSHDSTATUS||'","'||BCURNOTHDS||'","'||BREQNOTHDS||'","'||BSUSERNAME||'","'||BSDATMINTD||'","'||BSDATMSTRT||'","'||BSDATMENDD||'","'||BPRCEFFDAT||'","'||BPRCACCYR||'","'||BPRCACCMTH||'","'||LANGUAGE||'","'||BSHDINITBR||'","'||BSPRSABORT||'","'||BSPRSFAILD||'","'||BSPSCMPLTD||'","'||BSPRSCANC||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'"' from  VM1DTA.BSSCPF;
spool off;
