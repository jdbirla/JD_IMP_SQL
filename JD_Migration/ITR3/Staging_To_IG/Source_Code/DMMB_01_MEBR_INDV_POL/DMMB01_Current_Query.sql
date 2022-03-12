select * from fldtpf;
select * from zdoemb0021;
select * from zdoein0021;
select * from stagedbusr.titdmgmbrindp1;
select * from DMPVALPF ;
select * from dmbargspf;
select * from dmbmonpf;
select * from dmberpf;
select * from dmdefvalpf;
select * from user_parallel_execute_chunks;
select * from user_parallel_execute_tasks;

--REG
select * from Jd1dta.PAZDRPPF where chdrnum in  (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1);
--Owner
select * from Jd1dta.gchd where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
select * from Jd1dta.GCHPPF where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
select * from Jd1dta.GCHIPF where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
select * from Jd1dta.zclepf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )) and jobnm ='G1ZDMBRIND';
select * from Jd1dta.zcelinkpf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )) and jobnm ='G1ZDMBRIND';
select * from Jd1dta.clrrpf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )) and jobnm ='G1ZDMBRIND' and clrrrole in ('MP','OW');
select * from Jd1dta.audit_clrrpf where newclntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )) and newjobnm ='G1ZDMBRIND' and newclrrrole in ('MP','OW');
---INS
select * from Jd1dta.gmhdpf where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='1' );
select * from Jd1dta.gmhipf where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='1' );
select * from Jd1dta.clrrpf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='1' )) and jobnm ='G1ZDMBRIND' and clrrrole in ('LF');
select * from Jd1dta.audit_clrrpf where newclntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='1' )) and newjobnm ='G1ZDMBRIND' and newclrrrole in ('LF');
select * from Jd1dta.zcelinkpf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='1' )) and jobnm ='G1ZDMBRIND';


--Delete migrated data
--REG
Delete from Jd1dta.PAZDRPPF where chdrnum in  (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1);
--Owner
delete  from Jd1dta.gchd where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
delete  from Jd1dta.GCHPPF where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
delete  from Jd1dta.GCHIPF where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
delete  from Jd1dta.zclepf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )) and jobnm ='G1ZDMBRIND';
delete  from Jd1dta.zcelinkpf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )) and jobnm ='G1ZDMBRIND';
delete  from Jd1dta.clrrpf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )) and jobnm ='G1ZDMBRIND' and clrrrole in ('MP','OW');
delete  from Jd1dta.audit_clrrpf where newclntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )) and newjobnm ='G1ZDMBRIND' and newclrrrole in ('MP','OW');
---INS
delete  from Jd1dta.gmhdpf where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='1' );
delete  from Jd1dta.gmhipf where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='1' );
delete  from Jd1dta.clrrpf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='1' )) and jobnm ='G1ZDMBRIND' and clrrrole in ('LF');
delete  from Jd1dta.audit_clrrpf where newclntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='1' )) and newjobnm ='G1ZDMBRIND' and newclrrrole in ('LF');
delete  from Jd1dta.zcelinkpf where clntnum in ( select zigvalue from Jd1dta.pazdclpf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='1' )) and jobnm ='G1ZDMBRIND';



