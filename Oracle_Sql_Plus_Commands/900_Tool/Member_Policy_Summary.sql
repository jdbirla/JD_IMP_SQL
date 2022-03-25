PROMPT ****************************************
PROMPT Policy Header GCHD ,GCHPPF and OWNER
PROMPT ****************************************

SELECT
    gchd.chdrnum,
    gchp.zendcde,
    gchd.statcode,
    gchd.occdate,
    gchd.cnttype,
    gchd.mplnum,
    gchd.zprvchdr,
    gchd.cownnum,
    gchd.btdate,
    gchd.ptdate,
    gchd.tranno,
    gchd.tranid,
    gchd.effdcldt,
    gchd.zrwnlage,
    gchp.zprdctg,
    gchp.zplancls,
    gchp.zcolmcls,
    gchp.zpgpfrdt,
    gchp.zpgptodt,
    gchp.zpenddt,
    gchp.zpoltdate,
    gchp.zgporipcls,
    gchp.znbmnage,
    gchp.zlaptrx,
    gchp.usrprf,
    gchp.datime,
    gchp.jobnm
       --RTRIM(OWN.SURNAME)||' '|| RTRIM(OWN.GIVNAME) "Owner Name",
       --RTRIM(OWN.ZKANASNM) ||' '|| RTRIM(OWN.ZKANAGNM) "Owner Kana Name"
FROM
    vm1dta.gchd   gchd,
    vm1dta.gchppf gchp,
    vm1dta.clntpf own
WHERE
        gchd.chdrnum = gchp.chdrnum
    AND gchd.cownnum = own.clntnum
    AND gchd.CHDRNUM in ('&1');

PROMPT ****************************************
PROMPT Policy Header History (GCHIPF)
PROMPT ****************************************

SELECT GCHI.CHDRNUM, 
       GCHI.EFFDATE,
       GCHI.TRANNO,
       GCHI.CCDATE, 
       GCHI.CRDATE, 
       GCHI.INSENDTE,
       GCHI.NRISDATE,
       GCHI.BILLFREQ,
       GCHI.TIMECH01,
       GCHI.TIMECH02,
       GCHI.DOCRCDTE,
       GCHI.ZAGPTNUM,
       GCHI.ZPSTDDT,
       GCHI.ZPENDDT,
       GCHI.ZCMPCODE,
       GCHI.ZSOLCTFLG,
       GCHI.COWNNUM,
       GCHI.USRPRF,
       GCHI.JOBNM,
       GCHI.DATIME
FROM VM1DTA.GCHIPF GCHI
where GCHI.CHDRNUM in ('&1')
order by GCHI.TRANNO;



PROMPT ********************************************************************************
PROMPT Member Policy Insured header GMHD and GMHI
PROMPT ********************************************************************************

SELECT
    gmhd.chdrnum,
    gmhd.mbrno,
    gmhd.dpntno,
    gmhd.zanncldt,
    gmhd.tranno gmhd_tranno,
    gmhd.dteatt,
    gmhd.termid,
    gmhd.age,
    gmhd.clntnum,
    gmhd.cltreln,
    gmhi.effdate,
    gmhi.dtetrm,
    gmhi.tranno gmhi_tranno,
    gmhi.ztrxstat,
    gmhi.zplancde,
    gmhi.usrprf,
    gmhi.jobnm,
    gmhi.datime     
      -- RTRIM(INS.SURNAME)||' '|| RTRIM(INS.GIVNAME) "Insured Name",
      -- RTRIM(INS.ZKANASNM) ||' '|| RTRIM(INS.ZKANAGNM) "Insured Kana Name"
FROM
    vm1dta.gmhdpf gmhd,
    vm1dta.gmhipf gmhi,
    vm1dta.clntpf ins
WHERE
        gmhd.chdrnum = gmhi.chdrnum
    AND gmhd.mbrno = gmhi.mbrno
    AND gmhd.clntnum = ins.clntnum
     and GMHD.CHDRNUM in ('&1')
ORDER BY
    gmhi.mbrno,
    gmhi.tranno;



PROMPT *****
PROMPT Member Policy Issue date (GIDTPF)
PROMPT *****
select * from VM1DTA.GIDTPF where CHDRNUM = '&1'
order by TRANNO;
