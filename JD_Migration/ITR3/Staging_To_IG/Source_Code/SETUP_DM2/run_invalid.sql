set heading off;
set feedback off;
set echo off;
Set lines 999;

Spool re_run_invalid_obj.sql

select
'ALTER ' || OBJECT_TYPE || ' ' ||
OWNER || '.' || OBJECT_NAME || ' COMPILE;'
from
dba_objects
where
status = 'INVALID'
and
object_type in ('PACKAGE','FUNCTION','PROCEDURE')
and OWNER='Jd1dta'
;
spool off;
set heading on;
set feedback on;
set echo on;

--@run_invalid_obj.sql