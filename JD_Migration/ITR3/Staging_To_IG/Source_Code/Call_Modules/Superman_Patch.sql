---------------------------------------------------------------------------------------
-- File Name	: Superman patch.sql
-- Description	: To fetch the refunds that are not exists in GBIHPF and insert into zsmandtlpf
-- Author       : Lakshmanaprabu K
-- Date 	: 2/3/2022
---------------------------------------------------------------------------------------



declare

cursor c_get_smdtl
is
select distinct '1' CHDRCOY,a.chdrnum, b.tranno,'  ' Altquoteno, min(a.prbilfdt) over (partition by trim(a.chdrnum)) zsmandte,
sum(a.zrefundbz) over (partition by trim(a.chdrnum) ) zsmanamt,
'Y' pflag,
a.rdocnum,
'JBIRLA' usrprf,
'JBIRLA' jobnm,
sysdate datime
from 
stagedbusr2.titdmgref1_sm@stagedblink a,
ztrapf b
where a.chdrnum = b.chdrnum
and b.statcode = 'CA'
and b.zrcaltty = 'TERM'
and a.zrefmtcd = '001';


begin

for c_fet_smandtl in c_get_smdtl loop

insert into Jd1dta.zsmandtlpf
(CHDRCOY, CHDRNUM, TRANNO, ALTQUOTENO, ZSMANDTE, ZSMANAMT, PFLAG, RDOCNUM, USRPRF, JOBNM, DATIME)
values (c_fet_smandtl.CHDRCOY,
c_fet_smandtl.CHDRNUM,
c_fet_smandtl.TRANNO,
c_fet_smandtl.ALTQUOTENO,
c_fet_smandtl.ZSMANDTE,
c_fet_smandtl.ZSMANAMT,
c_fet_smandtl.PFLAG,
c_fet_smandtl.RDOCNUM,
c_fet_smandtl.USRPRF,
c_fet_smandtl.JOBNM,
c_fet_smandtl.DATIME
);

update Jd1dta.ztempcovpf set ZSMANDTE = c_fet_smandtl.ZSMANDTE,USRPRF = 'JBIRLA', JOBNM = 'G1ZDMSPMAN', DATIME = sysdate
where chdrnum = c_fet_smandtl.CHDRNUM
and TRANNO  = c_fet_smandtl.TRANNO;


end loop;

commit;

end;