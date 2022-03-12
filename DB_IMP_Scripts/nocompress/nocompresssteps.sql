Related to P2-17397 needs to apply no compress to 5 tables:


---------------1. Check the size ------------------------------
select segment_name , sum(bytes/1024/1024)MB from dba_segments where segment_name in ('ZTIERPF','ZUCLPF','ZCRHPF','GBIHPF','ZTRAPF') group by segment_name order by 1;
--
tablename sizemb 
GBIHPF 592 
ZCRHPF 368 
ZTIERPF 192
ZTRAPF 160
ZUCLPF 2

----------------2. Check the count-----------------------------
select count(1) from gbihpf;--15838475 as on 20210902 10:28AM
select count(1) from zcrhpf;---9447793 as on 20210902 10:28AM
select count(1) from ZTIERPF;--7523751 as on 20210902 10:28AM
select count(1) from ZTRAPF;---4245655 as on 20210902 10:28AM
select count(1) from ZUCLPF;-----50928 as on 20210902 10:28AM

--------- Check the index status before compress--------------
select status,last_analyzed,user_indexes.* from user_indexes where TABLE_NAME  in ('ZTIERPF','ZUCLPF','ZCRHPF','GBIHPF','ZTRAPF');--38 indexes
select compression,compress_for, user_tables.* from user_tables where TABLE_NAME  in ('ZTIERPF','ZUCLPF','ZCRHPF','GBIHPF','ZTRAPF');-- checking tables status

--------3. apply no compress------------------------------------
set serveroutput on
declare
begin
for c in ( select TABLE_NAME from user_indexes where TABLE_NAME  in ('ZTIERPF','ZUCLPF','ZCRHPF','GBIHPF','ZTRAPF') )
loop
execute immediate 'alter table ' || c.TABLE_NAME ||' move nocompress ';
dbms_output.put_line('no compress done: '||c.TABLE_NAME);
end loop;
end;
/


--- 4. procedure to loop through all indexes--------------------
set serveroutput on
declare  
begin
--for c in ( select * from user_indexes where TABLE_NAME  in ('ZTIERPF','ZUCLPF','ZCRHPF','GBIHPF','ZTRAPF') )
for c in ( select * from user_indexes where TABLE_NAME  in ('ZUCLPF') )
loop
 dbms_output.put_line('IndexName ' || c.index_name || ' status: ' || c.status);
 execute immediate 'alter index ' || c.index_name || ' rebuild parallel';
 dbms_output.put_line('IndexName ' || c.index_name || ' status: ' || c.status || 'Rebuild done');

end loop;
end;
/

---- Measure the size after no compress using first command------------

