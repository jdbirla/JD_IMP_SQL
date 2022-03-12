--- All below views are comments as no longer required and the pkg is re-written without the views.

 /*CREATE OR REPLACE FORCE EDITIONABLE VIEW "STAGEDBUSR2"."V_ZMRHR00" ("CHDRNUM", "MATURITY_DATE", "INS", "INS_NAME", "INS_GEN", "INS_AGE", "INS_DOB", "TOT_PREM_AF_REN", "DIS_PREM_AF_REN", "DIS_PREM_B4_REN") AS 
  (
select "CHDRNUM","MATURITY_DATE","INS","INS_NAME","INS_GEN","INS_AGE","INS_DOB","TOT_PREM_AF_REN","DIS_PREM_AF_REN","DIS_PREM_B4_REN" from (
select substr(ins01.hrcucd,1,8) chdrnum,
hrbedt maturity_date,
substr(ins01.hrcicd1,-2) ins,
ins01.hrbvig1 ins_name,
ins01.hra3st1 ins_gen,
ins01.hrbonb1 ins_age,
ins01.hratdt1 ins_dob,
ins01.hrcvva1 tot_prem_af_ren,
ins01.hrb3vao1 dis_prem_af_ren,
ins01.hrb3van1 dis_prem_b4_ren
from zmrhr00 ins01
union 
select substr(ins02.hrcucd,1,8) chdrnum,
hrbedt maturity_date,
substr(ins02.hrcicd2,-2) ins,
ins02.hrbvig2 ins_name,
ins02.hra3st2 ins_gen,
ins02.hrbonb2 ins_age,
ins02.hratdt2 ins_dob,
ins02.hrcvva2 tot_prem_af_ren,
ins02.hrb3vao2 dis_prem_af_ren,
ins02.hrb3van2 dis_prem_b4_ren
from zmrhr00 ins02
where trim(ins02.hrcicd2) is not null
order by  chdrnum,ins)
);


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STAGEDBUSR2"."P1_RECORD" ("CHDRNUM", "RECIDXMBINP1", "CLIENT_CATEGORY", "REFNUM", "MBRNO", "ZINSROLE", "TRANNOMIN", "TRANNOMAX", "CLIENTNO", "OCCDATE", "GPOLTYPE", "ZENDCDE", "ZCMPCODE", "MPOLNUM", "EFFDATE", "ZPOLPERD", "ZMARGNFLG", "ZDFCNCY", "DOCRCVDT", "HPROPDTE", "ZTRXSTAT", "ZSTATRESN", "ZANNCLDT", "ZCPNSCDE02", "ZSALECHNL", "ZSOLCTFLG", "CLTRELN", "ZPLANCDE", "CRDTCARD", "PREAUTNO", "BNKACCKEY01", "ZENSPCD01", "ZENSPCD02", "ZCIFCODE", "DTETRM", "CRDATE", "CNTTYPIND", "PTDATE", "BTDATE", "STATCODE", "ZWAITPEDT", "ZCONVINDPOL", "ZPOLTDATE", "OLDPOLNUM", "ZPGPFRDT", "ZPGPTODT", "SINSTNO", "TREFNUM", "ENDSERCD", "ISSDATE", "ZPDATATXFLG", "ZRWNLAGE", "ZNBMNAGE", "TERMAGE", "ZBLNKPOL", "PLNCLASS") AS 
  (
select distinct substr(a.refnum,1,8) chdrnum,
a."RECIDXMBINP1",a."CLIENT_CATEGORY",a."REFNUM",a."MBRNO",a."ZINSROLE",a."TRANNOMIN",a."TRANNOMAX",a."CLIENTNO",a."OCCDATE",a."GPOLTYPE",a."ZENDCDE",a."ZCMPCODE",a."MPOLNUM",a."EFFDATE",a."ZPOLPERD",a."ZMARGNFLG",a."ZDFCNCY",a."DOCRCVDT",a."HPROPDTE",a."ZTRXSTAT",a."ZSTATRESN",a."ZANNCLDT",a."ZCPNSCDE02",a."ZSALECHNL",a."ZSOLCTFLG",a."CLTRELN",a."ZPLANCDE",a."CRDTCARD",a."PREAUTNO",a."BNKACCKEY01",a."ZENSPCD01",a."ZENSPCD02",a."ZCIFCODE",a."DTETRM",a."CRDATE",a."CNTTYPIND",a."PTDATE",a."BTDATE",a."STATCODE",a."ZWAITPEDT",a."ZCONVINDPOL",a."ZPOLTDATE",a."OLDPOLNUM",a."ZPGPFRDT",a."ZPGPTODT",a."SINSTNO",a."TREFNUM",a."ENDSERCD",a."ISSDATE",a."ZPDATATXFLG",a."ZRWNLAGE",a."ZNBMNAGE",a."TERMAGE",a."ZBLNKPOL",a."PLNCLASS" 
from titdmgmbrindp1 a,
v_zmrhr00 b
where substr(a.refnum,1,8) = b.chdrnum
and a.client_category = '0'
and a.effdate = (select max(c.effdate) from titdmgmbrindp1 c where substr(c.refnum,1,8) = b.chdrnum
                and a.client_category = a.client_category)
);




  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STAGEDBUSR2"."P1_REN_RECORD" ("CHDRNUM", "RECIDXMBINP1", "CLIENT_CATEGORY", "REFNUM", "MBRNO", "ZINSROLE", "TRANNOMIN", "TRANNOMAX", "CLIENTNO", "OCCDATE", "GPOLTYPE", "ZENDCDE", "ZCMPCODE", "MPOLNUM", "EFFDATE", "ZPOLPERD", "ZMARGNFLG", "ZDFCNCY", "DOCRCVDT", "HPROPDTE", "ZTRXSTAT", "ZSTATRESN", "ZANNCLDT", "ZCPNSCDE02", "ZSALECHNL", "ZSOLCTFLG", "CLTRELN", "ZPLANCDE", "CRDTCARD", "PREAUTNO", "BNKACCKEY01", "ZENSPCD01", "ZENSPCD02", "ZCIFCODE", "DTETRM", "CRDATE", "CNTTYPIND", "PTDATE", "BTDATE", "STATCODE", "ZWAITPEDT", "ZCONVINDPOL", "ZPOLTDATE", "OLDPOLNUM", "ZPGPFRDT", "ZPGPTODT", "SINSTNO", "TREFNUM", "ENDSERCD", "ISSDATE", "ZPDATATXFLG", "ZRWNLAGE", "ZNBMNAGE", "TERMAGE", "ZBLNKPOL", "PLNCLASS") AS 
  (
select distinct substr(a.refnum,1,8) chdrnum,
a."RECIDXMBINP1",a."CLIENT_CATEGORY",a."REFNUM",a."MBRNO",a."ZINSROLE",a."TRANNOMIN",a."TRANNOMAX",a."CLIENTNO",a."OCCDATE",a."GPOLTYPE",a."ZENDCDE",a."ZCMPCODE",a."MPOLNUM",a."EFFDATE",a."ZPOLPERD",a."ZMARGNFLG",a."ZDFCNCY",a."DOCRCVDT",a."HPROPDTE",a."ZTRXSTAT",a."ZSTATRESN",a."ZANNCLDT",a."ZCPNSCDE02",a."ZSALECHNL",a."ZSOLCTFLG",a."CLTRELN",a."ZPLANCDE",a."CRDTCARD",a."PREAUTNO",a."BNKACCKEY01",a."ZENSPCD01",a."ZENSPCD02",a."ZCIFCODE",a."DTETRM",a."CRDATE",a."CNTTYPIND",a."PTDATE",a."BTDATE",a."STATCODE",a."ZWAITPEDT",a."ZCONVINDPOL",a."ZPOLTDATE",a."OLDPOLNUM",a."ZPGPFRDT",a."ZPGPTODT",a."SINSTNO",a."TREFNUM",a."ENDSERCD",a."ISSDATE",a."ZPDATATXFLG",a."ZRWNLAGE",a."ZNBMNAGE",a."TERMAGE",a."ZBLNKPOL",a."PLNCLASS" 
from titdmgmbrindp1 a,
renew_as_is b
where substr(a.refnum,1,8) = b.apcucd
and a.client_category = '0'
and a.effdate = (select max(c.effdate) from titdmgmbrindp1 c where substr(c.refnum,1,8) = b.apcucd
                and a.client_category = a.client_category)
);

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STAGEDBUSR2"."P2_RECORDS" ("RECIDXMBINDP2", "REFNUM", "MBRNO", "DPNTNO", "PRODTYP", "EFFDATE", "APREM", "HSUMINSU", "ZTAXFLG", "NDRPREM", "PRODTYP02", "ZINSTYPE") AS 
  (

select distinct indp2."RECIDXMBINDP2",indp2."REFNUM",indp2."MBRNO",indp2."DPNTNO",indp2."PRODTYP",indp2."EFFDATE",indp2."APREM",indp2."HSUMINSU",indp2."ZTAXFLG",indp2."NDRPREM",indp2."PRODTYP02",indp2."ZINSTYPE"
from trnh_records tr,
titdmgmbrindp2 indp2
where tr.Chdrnum = indp2.REFNUM
and tr.mbrno = indp2.mbrno
and tr.effdate = indp2.effdate);




  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STAGEDBUSR2"."P2_REN_RECORDS" ("RECIDXMBINDP2", "REFNUM", "MBRNO", "DPNTNO", "PRODTYP", "EFFDATE", "APREM", "HSUMINSU", "ZTAXFLG", "NDRPREM", "PRODTYP02", "ZINSTYPE") AS 
  (

select distinct indp2."RECIDXMBINDP2",indp2."REFNUM",indp2."MBRNO",indp2."DPNTNO",indp2."PRODTYP",indp2."EFFDATE",indp2."APREM",indp2."HSUMINSU",indp2."ZTAXFLG",indp2."NDRPREM",indp2."PRODTYP02",indp2."ZINSTYPE"
from trnh_ren_records tr,
titdmgmbrindp2 indp2
where tr.Chdrnum = indp2.REFNUM
and tr.mbrno = indp2.mbrno
and tr.effdate = indp2.effdate);


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STAGEDBUSR2"."TRNH_RECORDS" ("ZPLANCDE", "INS_NO", "RECIDXPHIST", "CHDRNUM", "ZSEQNO", "EFFDATE", "CLIENT_CATEGORY", "MBRNO", "CLTRELN", "ZINSROLE", "CLIENTNO", "ZALTREGDAT", "ZALTRCDE01", "ZINHDSCLM", "ZUWREJFLG", "ZSTOPBPJ", "ZTRXSTAT", "ZSTATRESN", "ZACLSDAT", "APPRDTE", "ZPDATATXDTE", "ZPDATATXFLG", "ZREFUNDAM", "ZPAYINREQ", "CRDTCARD", "PREAUTNO", "BNKACCKEY01", "ZENSPCD01", "ZENSPCD02", "ZCIFCODE", "ZDDREQNO", "ZWORKPLCE2", "BANKACCDSC01", "BANKKEY", "BNKACTYP01", "CURRTO", "B1_ZKNJFULNM", "B2_ZKNJFULNM", "B3_ZKNJFULNM", "B4_ZKNJFULNM", "B5_ZKNJFULNM", "B1_CLTADDR01", "B2_CLTADDR01", "B3_CLTADDR01", "B4_CLTADDR01", "B5_CLTADDR01", "B1_BNYPC", "B2_BNYPC", "B3_BNYPC", "B4_BNYPC", "B5_BNYPC", "B1_BNYRLN", "B2_BNYRLN", "B3_BNYRLN", "B4_BNYRLN", "B5_BNYRLN") AS 
  (
select indp1.zplancde,indp1.mbrno ins_no,trnh."RECIDXPHIST",trnh."CHDRNUM",trnh."ZSEQNO",trnh."EFFDATE",trnh."CLIENT_CATEGORY",trnh."MBRNO",trnh."CLTRELN",trnh."ZINSROLE",trnh."CLIENTNO",trnh."ZALTREGDAT",trnh."ZALTRCDE01",trnh."ZINHDSCLM",trnh."ZUWREJFLG",trnh."ZSTOPBPJ",trnh."ZTRXSTAT",trnh."ZSTATRESN",trnh."ZACLSDAT",trnh."APPRDTE",trnh."ZPDATATXDTE",trnh."ZPDATATXFLG",trnh."ZREFUNDAM",trnh."ZPAYINREQ",trnh."CRDTCARD",trnh."PREAUTNO",trnh."BNKACCKEY01",trnh."ZENSPCD01",trnh."ZENSPCD02",trnh."ZCIFCODE",trnh."ZDDREQNO",trnh."ZWORKPLCE2",trnh."BANKACCDSC01",trnh."BANKKEY",trnh."BNKACTYP01",trnh."CURRTO",trnh."B1_ZKNJFULNM",trnh."B2_ZKNJFULNM",trnh."B3_ZKNJFULNM",trnh."B4_ZKNJFULNM",trnh."B5_ZKNJFULNM",trnh."B1_CLTADDR01",trnh."B2_CLTADDR01",trnh."B3_CLTADDR01",trnh."B4_CLTADDR01",trnh."B5_CLTADDR01",trnh."B1_BNYPC",trnh."B2_BNYPC",trnh."B3_BNYPC",trnh."B4_BNYPC",trnh."B5_BNYPC",trnh."B1_BNYRLN",trnh."B2_BNYRLN",trnh."B3_BNYRLN",trnh."B4_BNYRLN",trnh."B5_BNYRLN"
from titdmgpoltrnh trnh,
P1_record p1,
titdmgmbrindp1 indp1
where trnh.chdrnum = p1.chdrnum
and trnh.chdrnum = substr(indp1.refnum,1,8)
and substr(trnh.mbrno,-2) = indp1.mbrno
and to_date(trnh.effdate,'yyyymmdd') = to_date(p1.effdate,'yyyymmdd')
and indp1.client_category = '1');


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STAGEDBUSR2"."TRNH_REN_RECORDS" ("ZPLANCDE", "INS_NO", "MATURITY_DATE", "RECIDXPHIST", "CHDRNUM", "ZSEQNO", "EFFDATE", "CLIENT_CATEGORY", "MBRNO", "CLTRELN", "ZINSROLE", "CLIENTNO", "ZALTREGDAT", "ZALTRCDE01", "ZINHDSCLM", "ZUWREJFLG", "ZSTOPBPJ", "ZTRXSTAT", "ZSTATRESN", "ZACLSDAT", "APPRDTE", "ZPDATATXDTE", "ZPDATATXFLG", "ZREFUNDAM", "ZPAYINREQ", "CRDTCARD", "PREAUTNO", "BNKACCKEY01", "ZENSPCD01", "ZENSPCD02", "ZCIFCODE", "ZDDREQNO", "ZWORKPLCE2", "BANKACCDSC01", "BANKKEY", "BNKACTYP01", "CURRTO", "B1_ZKNJFULNM", "B2_ZKNJFULNM", "B3_ZKNJFULNM", "B4_ZKNJFULNM", "B5_ZKNJFULNM", "B1_CLTADDR01", "B2_CLTADDR01", "B3_CLTADDR01", "B4_CLTADDR01", "B5_CLTADDR01", "B1_BNYPC", "B2_BNYPC", "B3_BNYPC", "B4_BNYPC", "B5_BNYPC", "B1_BNYRLN", "B2_BNYRLN", "B3_BNYRLN", "B4_BNYRLN", "B5_BNYRLN") AS 
  (
select indp1.zplancde,indp1.mbrno ins_no,p1.crdate maturity_date,trnh."RECIDXPHIST",trnh."CHDRNUM",trnh."ZSEQNO",trnh."EFFDATE",trnh."CLIENT_CATEGORY",trnh."MBRNO",trnh."CLTRELN",trnh."ZINSROLE",trnh."CLIENTNO",trnh."ZALTREGDAT",trnh."ZALTRCDE01",trnh."ZINHDSCLM",trnh."ZUWREJFLG",trnh."ZSTOPBPJ",trnh."ZTRXSTAT",trnh."ZSTATRESN",trnh."ZACLSDAT",trnh."APPRDTE",trnh."ZPDATATXDTE",trnh."ZPDATATXFLG",trnh."ZREFUNDAM",trnh."ZPAYINREQ",trnh."CRDTCARD",trnh."PREAUTNO",trnh."BNKACCKEY01",trnh."ZENSPCD01",trnh."ZENSPCD02",trnh."ZCIFCODE",trnh."ZDDREQNO",trnh."ZWORKPLCE2",trnh."BANKACCDSC01",trnh."BANKKEY",trnh."BNKACTYP01",trnh."CURRTO",trnh."B1_ZKNJFULNM",trnh."B2_ZKNJFULNM",trnh."B3_ZKNJFULNM",trnh."B4_ZKNJFULNM",trnh."B5_ZKNJFULNM",trnh."B1_CLTADDR01",trnh."B2_CLTADDR01",trnh."B3_CLTADDR01",trnh."B4_CLTADDR01",trnh."B5_CLTADDR01",trnh."B1_BNYPC",trnh."B2_BNYPC",trnh."B3_BNYPC",trnh."B4_BNYPC",trnh."B5_BNYPC",trnh."B1_BNYRLN",trnh."B2_BNYRLN",trnh."B3_BNYRLN",trnh."B4_BNYRLN",trnh."B5_BNYRLN"
from titdmgpoltrnh trnh,
P1_ren_record p1,
titdmgmbrindp1 indp1,
renew_as_is rai
where trnh.chdrnum = p1.chdrnum
and trnh.chdrnum = substr(indp1.refnum,1,8)
and substr(trnh.mbrno,-2) = indp1.mbrno
and trim(rai.apcucd) = substr(indp1.refnum,1,8)--- this will take only the specific policy available in the renew as is
and trim(rai.icicd) = trim(indp1.mbrno)--- this will take only the specific insured available in the renew as is
and to_date(trnh.effdate,'yyyymmdd') = to_date(p1.effdate,'yyyymmdd')
and indp1.client_category = '1');
*/