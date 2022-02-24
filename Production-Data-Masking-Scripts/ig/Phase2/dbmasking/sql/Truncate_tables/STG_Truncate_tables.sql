
declare
countException number :=0;
rc number :=0;
begin
for c in (select TABLE_NAME from user_tables where TABLE_NAME NOT IN ('BUSDPF','ITEMPF','ZENDRPF','ZESDPF','ZSLPHPF','ZSLPPF') )
loop
 begin
  EXECUTE IMMEDIATE 'truncate table stagedbusr.'||c.TABLE_NAME;
  EXECUTE IMMEDIATE 'select count(1) from stagedbusr.' || c.TABLE_NAME into rc;
    if rc > 0 then
      DBMS_OUTPUT.put_line('Table name:' || c.TABLE_NAME || ' record count:' || rc);
    end if;
 vm1dta.log_bat_status@IGCOREDBLINK('MASK_TruncStage '||c.TABLE_NAME || ' CntAfterTrunc:' || rc) ; 
 exception 
 when others then
   countException := countException +  1; 
 end;
end loop;
if countException > 0  then
 DBMS_OUTPUT.put_line('failed to truncate count:' || countException );
end if;
DBMS_OUTPUT.put_line('Truncate stagedb tables done!');
end;
/
