set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/DTVHPF.sql;
select /*+ paralle(10) */'"'||UNIQUE_NUMBER||'","'||VIEWNAME||'","'||RECFORMAT||'","'||FILN||'","'||KEYFMT||'","'||FLDPFX||'","'||ACPTHMAINT||'","'||CMTCTL||'","'||SUBSYS||'","'||JOINDFTVAL||'","'||USRPRF||'","'||JOBNM||'","'||DATIME||'","'||VIEWDESC||'","'||OBJECT||'","'||LIB||'","'||DYNSLT||'"' from  VM1DTA.DTVHPF;
spool off;
