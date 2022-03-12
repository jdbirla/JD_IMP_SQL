delete from Jd1dta.PAZDROPF where JOBNAME = 'G1ZDCAMPCD' and PREFIX = 'CM';
delete from Jd1dta.ZCPNPF where substr(trim(ZCMPCODE),1,5) in (select trim(ZCMPCODE) from STAGEDBUSR.TITDMGCAMPCDE@DMSTAGEDBLINK);
delete from Jd1dta.ZCSLPF where substr(trim(ZCMPCODE),1,5) in (select trim(ZCMPCODE) from STAGEDBUSR.TITDMGZCSLPF@DMSTAGEDBLINK);
commit;