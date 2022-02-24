drop table TRUNCATETABLES;
CREATE TABLE "JPACPR"."reiwa_mask_truncatetables" 
(	"TABLENAME" VARCHAR2(100 CHAR)
 )
 /
-- The package definition------------------------------------------------
create or replace package reiwa_mask as
procedure rm_truncatetables(schema_name IN VARCHAR2, howmanytotruncate OUT NUMBER, howmanyfailedtotruncate OUT NUMBER);
end;
/
-- The package body definition------------------------------------------------
create or replace package body reiwa_mask as 

--------- Procedure to truncate tables.
procedure rm_truncatetables(schema_name IN VARCHAR2
,howmanytotruncate          OUT NUMBER
,howmanyfailedtotruncate    OUT NUMBER
)
is
countException number :=0;
begin
EXECUTE IMMEDIATE  'select count(1) from ' ||schema_name||'.reiwa_mask_truncatetables' into howmanytotruncate;
for c in (select tablename from schema_name.reiwa_mask_truncatetables )
loop
begin
EXECUTE IMMEDIATE 'truncate table '||c.tablename;
exception 
when others then
   countException := countException +  1; 
end;
end loop;
howmanyfailedtotruncate := countException;
end rm_truncatetables;

end reiwa_mask;
/

drop package BODY reiwa_mask;
drop package reiwa_mask;
-------------------

---test
/
set SERVEROUTPUT ON
declare
ct number;
notTruncCount number;
begin
 jpacpr.reiwa_mask.rm_truncatetables('JPACPR',ct,notTruncCount);
 DBMS_OUTPUT.PUT_LINE('how many to truncate Count:'|| ct || ' Not Truncated Count:' || notTruncCount);
end;
/
