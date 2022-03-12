select * from pazdclpf where prefix='CB' and substr(zentity,0,8) in (select refnum from dmigtitdmgclntbank);
select * from Jd1dta.clbapf where clntnum in (select substr(zigvalue,0,8) from pazdclpf where prefix='CB' and substr(zentity,0,8) in (select refnum from dmigtitdmgclntbank));
select * from Jd1dta.clrrpf where clntnum in (select substr(zigvalue,0,8) from pazdclpf where prefix='CB' and substr(zentity,0,8) in (select refnum from dmigtitdmgclntbank));
select * from Jd1dta.audit_clrrpf where newclntnum in (select substr(zigvalue,0,8) from pazdclpf where prefix='CB' and substr(zentity,0,8) in (select refnum from dmigtitdmgclntbank));


delete Jd1dta.clbapf where usrprf='JBIRLA' and jobnm='G1ZDCLTBNK';
delete Jd1dta.clrrpf where usrprf='JBIRLA' and jobnm='G1ZDCLTBNK';
delete Jd1dta.audit_clrrpf where newusrprf='JBIRLA' and newjobnm='G1ZDCLTBNK';
delete from pazdclpf where prefix='CB' and substr(zentity,0,8) in (select refnum from dmigtitdmgclntbank);
