select * from fldtpf;
select * from zdoemb0026;
select * from zdoein0019;
show PARAMETERS;
select * from v$parameter;
show parameter parallel;


select * from dmigtitdmgmbrindp1;
select * from STAGEDBUSR.titdmgmbrindp1;
select * from DMPVALPF ;
select * from DMPRFXPF;
select * from dmbargspf;
select * from dmbmonpf;
select * from dmberpf;
select * from dmdefvalpf;
select * from dmpvalpf;
select * from user_parallel_execute_chunks where task_name = 'DM2_G1ZDMBRIND_PARALLEL_TASK';
select * from user_parallel_execute_tasks  where task_name = 'DM2_G1ZDMBRIND_PARALLEL_TASK';
select * from pazdclpf;

--REG
select * from Jd1dta.PAZDRPPF where chdrnum in  (select refnum from stagedbusr.titdmgmbrindp1);
--Owner
select *  from Jd1dta.gchd where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
select *  from Jd1dta.GCHPPF where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
select *  from Jd1dta.GCHIPF where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
select *  from Jd1dta.zclepf where clntnum in ( select zigvalue from Jd1dta.pazdnypf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' ) and CLNTSTAS='NW') and jobnm ='G1ZDMBRIND';
select *  from Jd1dta.zcelinkpf where clntnum in ( select zigvalue from Jd1dta.pazdnypf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )and CLNTSTAS='NW') and jobnm ='G1ZDMBRIND';
select *  from Jd1dta.clrrpf where  trim(forenum)  in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' ) ;
select *  from Jd1dta.audit_clrrpf  where trim(newforenum)  in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' ) ;
---INS
select *  from Jd1dta.gmhdpf where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='1' );
select *  from Jd1dta.gmhipf where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='1' );
select *  from Jd1dta.zcelinkpf where clntnum in ( select zigvalue from Jd1dta.pazdnypf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='1' )and CLNTSTAS='NW') and jobnm ='G1ZDMBRIND';


--Delete migrated data
--REG
Delete from Jd1dta.PAZDRPPF where chdrnum in  (select refnum from stagedbusr.titdmgmbrindp1);
--Owner
delete  from Jd1dta.gchd where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
delete  from Jd1dta.GCHPPF where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
delete  from Jd1dta.GCHIPF where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' );
delete  from Jd1dta.zclepf where clntnum in ( select zigvalue from Jd1dta.pazdnypf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' ) and CLNTSTAS='NW') and jobnm ='G1ZDMBRIND';
delete  from Jd1dta.zcelinkpf where clntnum in ( select zigvalue from Jd1dta.pazdnypf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='0' )and CLNTSTAS='NW') and jobnm ='G1ZDMBRIND';
delete  from Jd1dta.clrrpf where  trim(forenum)  in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' ) ;
delete  from Jd1dta.audit_clrrpf  where trim(newforenum)  in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='0' ) ;
---INS
delete  from Jd1dta.gmhdpf where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='1' );
delete  from Jd1dta.gmhipf where chdrnum in (select substr(refnum,1,8) from stagedbusr.titdmgmbrindp1 where client_category='1' );
delete  from Jd1dta.zcelinkpf where clntnum in ( select zigvalue from Jd1dta.pazdnypf where zentity in ( select stagedbusr.titdmgmbrindp1.clientno from stagedbusr.titdmgmbrindp1 where client_category='1' )and CLNTSTAS='NW') and jobnm ='G1ZDMBRIND';


      
      -------
 

