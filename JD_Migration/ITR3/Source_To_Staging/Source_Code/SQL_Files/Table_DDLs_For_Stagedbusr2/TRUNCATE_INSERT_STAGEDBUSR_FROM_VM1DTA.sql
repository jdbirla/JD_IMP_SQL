truncate table STAGEDBUSR.ZSLPPF;
truncate table STAGEDBUSR.ZSLPHPF;
truncate table STAGEDBUSR.ZENDRPF;
truncate table STAGEDBUSR.ZESDPF;
truncate table STAGEDBUSR.ITEMPF;
truncate table STAGEDBUSR.BUSDPF;

insert into STAGEDBUSR.ZSLPPF select * from ZSLPPF@IGCOREDBLINK;
commit;
insert into STAGEDBUSR.ZSLPHPF select * from ZSLPHPF@IGCOREDBLINK;
commit;

insert into STAGEDBUSR.ZENDRPF select * from ZENDRPF@IGCOREDBLINK;
commit;

insert into STAGEDBUSR.ZESDPF select * from ZESDPF@IGCOREDBLINK;
commit;

insert into STAGEDBUSR.ITEMPF select * from ITEMPF@IGCOREDBLINK;
COMMIT;

insert into STAGEDBUSR.BUSDPF select * from BUSDPF@IGCOREDBLINK WHERE TRIM(company) = '1';
COMMIT;


