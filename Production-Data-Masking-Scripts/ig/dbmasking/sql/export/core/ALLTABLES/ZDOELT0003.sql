set pagesize 0 trimspool on linesize 32700 underline off term off feed off
spool /opt/ig/hitoku/user/input/ALLTABLEDATA/ZDOELT0003.sql;
select /*+ paralle(10) */'"'||SYS_STS28MIETSU_2$Y35GXNK00QZT||'","'||EROR02||'","'||ERRMESS02||'","'||ERORFLD02||'","'||FLDVALU02||'","'||ERORPROG02||'","'||EROR03||'","'||ERRMESS03||'","'||ERORFLD03||'","'||FLDVALU03||'","'||ERORPROG03||'","'||EROR04||'","'||ERRMESS04||'","'||ERORFLD04||'","'||FLDVALU04||'","'||ERORPROG04||'","'||EROR05||'","'||ERRMESS05||'","'||ERORFLD05||'","'||FLDVALU05||'","'||ERORPROG05||'","'||JOBNUM||'","'||INDIC||'","'||RECIDXOKEROR||'","'||RECSTATUS||'","'||ZREFKEY||'","'||ZFILENME||'","'||EROR01||'","'||ERRMESS01||'","'||ERORFLD01||'","'||FLDVALU01||'","'||ERORPROG01||'"' from  VM1DTA.ZDOELT0003;
spool off;
