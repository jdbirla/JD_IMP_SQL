set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ASRFTYPE_ACUM_TEMP.sql;
select /*+ paralle(10) */'"'||CLNTNUM||'","'||ASRF01||'","'||ASRF02||'","'||ASRF03||'","'||ASRF04||'","'||ASRF05||'","'||ASRF06||'","'||ASRF07||'","'||ASRF08||'","'||ASRF09||'","'||ASRF10||'","'||ASRF11||'","'||ASRF12||'","'||ASRF13||'","'||ASRF14||'","'||ASRF15||'","'||ASRF16||'","'||ASRF17||'","'||ASRF18||'","'||ASRF19||'","'||ASRF20||'","'||ASRF21||'","'||ASRF22||'","'||ASRF23||'","'||ASRF24||'","'||ASRF25||'","'||ASRF26||'","'||ASRF27||'","'||ASRF28||'","'||ASRF29||'","'||ASRF30||'","'||DATIME||'"' from  VM1DTA.ASRFTYPE_ACUM_TEMP;
spool off;
