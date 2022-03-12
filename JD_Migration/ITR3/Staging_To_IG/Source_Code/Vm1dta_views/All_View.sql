--------------------------------------------------------
--  DDL for View VIEW_DM_ZALTPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZALTPF" ("CHDRNUM", "TRANNO", "COWNNUM", "ZCMPCODE", "ZCPNSCDE", "ZCONVPOLNO", "ZSALECHNL", "ZSOLCTFLG", "CRDTCARD", "BNKACCKEY01", "ZENSPCD01", "ZENSPCD02", "ZCIFCODE", "USRPRF", "JOBNM", "DATIME", "ZPGPFRDT", "ZPGPTODT", "ZWORKPLCE1", "BANKKEY", "PREAUTNO", "MTHTO", "YEARTO", "BANKACCDSC01", "ZRECEPFG", "ZPOLPERD", "ZSLPTYP") AS 
  SELECT "CHDRNUM",
    "TRANNO",
    "COWNNUM",
    "ZCMPCODE",
    "ZCPNSCDE",
	"ZCONVPOLNO",
    "ZSALECHNL",
    "ZSOLCTFLG",
    "CRDTCARD",
	"BNKACCKEY01",
    "ZENSPCD01",
    "ZENSPCD02",
    "ZCIFCODE",
    "USRPRF",
    "JOBNM",
    "DATIME",
    "ZPGPFRDT",
    "ZPGPTODT",
    "ZWORKPLCE1",
    "BANKKEY",
    "PREAUTNO",
    "MTHTO",
    "YEARTO",
    "BANKACCDSC01",
    "ZRECEPFG",
    "ZPOLPERD",
    "ZSLPTYP"
  FROM Jd1dta.ZALTPF;

--------------------------------------------------------
--  DDL for View VIEW_DM_ZALTPF_1
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZALTPF_1" ("ZPGPFRDT", "ZPGPTODT") AS 
  SELECT ZPGPFRDT
, ZPGPTODT

FROM zaltpf
;
--------------------------------------------------------
--  DDL for View VIEW_DM_ZCELINKPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZCELINKPF" ("CLNTCOY", "CLNTPFX", "CLNTNUM", "ZENDCDE", "USRPRF", "JOBNM", "DATIME") AS 
  SELECT
"CLNTCOY",
"CLNTPFX",
"CLNTNUM",
"ZENDCDE",
"USRPRF",
"JOBNM",
"DATIME"
	FROM Jd1dta.ZCELINKPF
;
--------------------------------------------------------
--  DDL for View VIEW_DM_ZTEMPCOVPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZTEMPCOVPF" ("CHDRCOY", "CHDRNUM", "ALTQUOTENO", "TRANNO", "MBRNO", "DPNTNO", "PRODTYP", "EFFDATE", "DTEATT", "DTETRM", "SUMINS", "DPREM", "ZWPENDDT", "ZCHGTYPE", "DSUMIN", "ZSALPLAN", "USRPRF", "JOBNM", "DATIME", "ZINSTYPE", "ZCVGSTRTDT", "ZCVGENDDT", "ZINSROLE", "ZTRXSTSIND", "ZRFNDSDT", "ZSMANDTE") AS 
  SELECT "CHDRCOY",
    "CHDRNUM",
    "ALTQUOTENO",
    "TRANNO",
    "MBRNO",
    "DPNTNO",
    "PRODTYP",
    "EFFDATE",
    "DTEATT",
    "DTETRM",
    "SUMINS",
    "DPREM",
    "ZWPENDDT",
    "ZCHGTYPE",
    "DSUMIN",
    "ZSALPLAN",
    "USRPRF",
    "JOBNM",
    "DATIME",
    "ZINSTYPE",
    "ZCVGSTRTDT",
    "ZCVGENDDT",
    "ZINSROLE",
    "ZTRXSTSIND",
    "ZRFNDSDT",
	"ZSMANDTE"
  FROM Jd1dta.ZTEMPCOVPF;

--------------------------------------------------------
--  DDL for View VIEW_DM_ZTEMPTIERPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZTEMPTIERPF" ("CHDRCOY", "CHDRNUM", "ALTQUOTENO", "MBRNO", "DPNTNO", "PRODTYP", "TRANNO", "EFFDATE", "ZTIERNO", "DTETRM", "DTEATT", "SUMINSU", "DPREM", "ZVIOLTYP", "ZCVGSTRTDT", "ZCVGENDDT", "USRPRF", "JOBNM", "DATIME", "REFNUM", "XTRANNO", "ZCHGTYPE", "ZWAITPERD") AS 
  SELECT
"CHDRCOY",
"CHDRNUM",
"ALTQUOTENO",
"MBRNO",
"DPNTNO",
"PRODTYP",
"TRANNO",
"EFFDATE",
"ZTIERNO",
"DTETRM",
"DTEATT",
"SUMINSU",
"DPREM",
"ZVIOLTYP",
"ZCVGSTRTDT",--MB16--Renamed column from EFDATE TO ZCVGSTRTDT
"ZCVGENDDT",--MB16--Renamed column from ZMDDVDT TO ZCVGENDDT
"USRPRF",
"JOBNM",
"DATIME",
"REFNUM",
"XTRANNO",
"ZCHGTYPE",
"ZWAITPERD"--MB16--Added new column
FROM Jd1dta.ZTEMPTIERPF
;
--------------------------------------------------------
--  DDL for View VIEW_DM_ZTIERPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZTIERPF" ("CHDRCOY", "CHDRNUM", "MBRNO", "DPNTNO", "PRODTYP", "TRANNO", "EFFDATE", "ZTIERNO", "DTETRM", "DTEATT", "SUMINSU", "DPREM", "ZVIOLTYP", "ZCVGSTRTDT", "ZCVGENDDT", "USRPRF", "JOBNM", "DATIME", "ZREINDT", "ZWAITPERD") AS 
  SELECT
"CHDRCOY",
"CHDRNUM",
"MBRNO",
"DPNTNO",
"PRODTYP",
"TRANNO",
"EFFDATE",
"ZTIERNO",
"DTETRM",
"DTEATT",
"SUMINSU",
"DPREM",
"ZVIOLTYP",
"ZCVGSTRTDT",--MB16--Renamed column from EFDATE TO ZCVGSTRTDT
"ZCVGENDDT",--MB16--Renamed column from ZMDDVDT TO ZCVGENDDT
"USRPRF",
"JOBNM" ,
"DATIME",
"ZREINDT",
"ZWAITPERD"--MB16--Added new column
	FROM Jd1dta.ZTIERPF
;
--------------------------------------------------------
--  DDL for View VIEW_DM_ZTRAPF
--------------------------------------------------------
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZTRAPF" ("ALTQUOTENO", "APPRDTE", "CHDRCOY", "CHDRNUM", "DATIME", "DOCRCDTE", "EFDATE", "EFFDATE", "HPROPDTE", "JOBNM", "STATCODE", "TRANCDE", "TRANNO", "UNIQUE_NUMBER_01", "USRPRF", "ZACLSDAT", "ZALTRCDE01", "ZALTRCDE02", "ZALTRCDE03", "ZALTRCDE04", "ZALTRCDE05", "ZALTREGDAT", "ZCLMRECD", "ZCSTPBIL", "ZDFCNCY", "ZFINALBYM", "ZFINANCFLG", "ZINHDSCLM", "ZLOGALTDT", "ZMARGNFLG", "ZPAYINREQ", "ZPDATATXDAT", "ZPDATATXFLG", "ZPOLDATE", "ZQUOTIND", "ZREFUNDAM", "ZRVTRANNO", "ZSALPLNCHG", "ZSTATRESN", "ZSTOPBPJ", "ZSURCHRGE", "ZTRXSTAT", "ZVIOLTYP", "ZVLDTRXIND", "ZCPMCPNCDE", "ZCPMPLANCD", "ZBLTRANNO", "ZDFBLIND", "ZRCALTTY") AS 
  SELECT "ALTQUOTENO",
    "APPRDTE",
    "CHDRCOY",
    "CHDRNUM",
    "DATIME",
    "DOCRCDTE",
    "EFDATE",
    "EFFDATE",
    "HPROPDTE",
    "JOBNM",
    "STATCODE",
    "TRANCDE",
    "TRANNO",
    "UNIQUE_NUMBER_01",
    "USRPRF",
    "ZACLSDAT",
    "ZALTRCDE01",
    "ZALTRCDE02",
    "ZALTRCDE03",
    "ZALTRCDE04",
    "ZALTRCDE05",
    "ZALTREGDAT",
    "ZCLMRECD",
    "ZCSTPBIL",
    "ZDFCNCY",
    "ZFINALBYM",
    "ZFINANCFLG",
    "ZINHDSCLM",
    "ZLOGALTDT",
    "ZMARGNFLG",
    "ZPAYINREQ",
    "ZPDATATXDAT",
    "ZPDATATXFLG",
    "ZPOLDATE",
    "ZQUOTIND",
    "ZREFUNDAM",
    "ZRVTRANNO",
    "ZSALPLNCHG",
    "ZSTATRESN",
    "ZSTOPBPJ",
    "ZSURCHRGE",
    "ZTRXSTAT",
    "ZVIOLTYP",
    "ZVLDTRXIND",
	"ZCPMCPNCDE", 
	"ZCPMPLANCD",
	"ZBLTRANNO", 
	"ZDFBLIND",
    "ZRCALTTY"
  FROM Jd1dta.ZTRAPF
;

--------------------------------------------------------
--  DDL for View VIEW_ZCLNPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZCLNPF" ( "CLNTPFX", "CLNTCOY", "CLNTNUM", "CLTDOB", "LSURNAME", "LGIVNAME", "ZKANASNM", "ZKANAGNM", "CLTSEX", "CLTPCODE", "ZKANADDR01", "ZKANADDR02", "ZKANADDR03", "ZKANADDR04", "CLTADDR01", "CLTADDR02", "CLTADDR03", "CLTADDR04", "CLTPHONE01", "CLTPHONE02", "ZWORKPLCE", "OCCPCODE", "OCCPCLAS", "ZOCCDSC", "CLTDOBFLAG", "LSURNAMEFLAG", "LGIVNAMEFLAG", "ZKANASNMFLAG", "ZKANAGNMFLAG", "CLTSEXFLAG", "CLTPCODEFLAG", "ZKANADDR01FLAG", "ZKANADDR02FLAG", "ZKANADDR03FLAG", "ZKANADDR04FLAG", "CLTADDR01FLAG", "CLTADDR02FLAG", "CLTADDR03FLAG", "CLTADDR04FLAG", "CLTPHONE01FLAG", "CLTPHONE02FLAG", "ZWORKPLCEFLAG", "OCCPCODEFLAG", "OCCPCLASFLAG", "ZOCCDSCFLAG", "EFFDATE", "DATIME", "JOBNM", "USRPRF") AS 
  SELECT 
  "CLNTPFX", 
	"CLNTCOY", 
	"CLNTNUM",
	"CLTDOB", 
	"LSURNAME",
	"LGIVNAME",
	"ZKANASNM",
	"ZKANAGNM",
	"CLTSEX", 
	"CLTPCODE",
	"ZKANADDR01",
	"ZKANADDR02",
	"ZKANADDR03",
	"ZKANADDR04",
	"CLTADDR01",
	"CLTADDR02",
	"CLTADDR03",
	"CLTADDR04",
	"CLTPHONE01",
	"CLTPHONE02",
	"ZWORKPLCE",
	"OCCPCODE",
	"OCCPCLAS",
	"ZOCCDSC",
	"CLTDOBFLAG",
	"LSURNAMEFLAG",
	"LGIVNAMEFLAG",
	"ZKANASNMFLAG",
	"ZKANAGNMFLAG",
	"CLTSEXFLAG",
	"CLTPCODEFLAG",
	"ZKANADDR01FLAG",
	"ZKANADDR02FLAG",
	"ZKANADDR03FLAG",
	"ZKANADDR04FLAG",
	"CLTADDR01FLAG",
	"CLTADDR02FLAG",
	"CLTADDR03FLAG",
	"CLTADDR04FLAG",
	"CLTPHONE01FLAG",
	"CLTPHONE02FLAG",
	"ZWORKPLCEFLAG",
	"OCCPCODEFLAG",
	"OCCPCLASFLAG",
	"ZOCCDSCFLAG",
	"EFFDATE",
    "DATIME",
    "JOBNM",
    "USRPRF"
	FROM Jd1dta.ZCLNPF
;
--------------------------------------------------------
--  DDL for View VIEW_ZREPPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZREPPF" ("CHDRNUM", "EFFDATE", "TRANNO", "ZALTRCDE01", "ZREFUNDAM", "ZREFMTCD", "ZREFUNDBE", "ZREFUNDBZ", "ZRFDST", "ZENRFDST", "ZZHRFDST", "CLNTNUM", "BANKKEY", "BANKACOUNT", "BANKACCDSC", "BNKACTYP", "ZPBCODE", "ZPBACNO", "ZPBCTYPE", "CURRFROM", "ZRQBKRDF", "REQDATE", "USRPRF", "JOBNM", "DATIME", "ZCOLFLAG", "PTDATE", "BTDATE","ZREFLIST") AS 
  SELECT
	"CHDRNUM",
	"EFFDATE",
	"TRANNO",
	"ZALTRCDE01",
	"ZREFUNDAM",
	"ZREFMTCD",
	"ZREFUNDBE",
	"ZREFUNDBZ",
	"ZRFDST",
	"ZENRFDST",
	"ZZHRFDST",
	"CLNTNUM",
	"BANKKEY",
	"BANKACOUNT",
	"BANKACCDSC",
	"BNKACTYP",
	"ZPBCODE",
	"ZPBACNO",
	"ZPBCTYPE",
	"CURRFROM",
	"ZRQBKRDF",
	"REQDATE",
	"USRPRF",
	"JOBNM", 
	"DATIME",
	"ZCOLFLAG",
	"PTDATE",
	"BTDATE",
	"ZREFLIST"
  FROM Jd1dta.ZREPPF;

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_PAZDCLPF" ("RECSTATUS", "PREFIX", "ZENTITY", "ZIGVALUE", "JOBNUM", "JOBNAME") AS 
  SELECT  
  "RECSTATUS", 
  "PREFIX", 
  "ZENTITY",
  "ZIGVALUE", 
  "JOBNUM",
  "JOBNAME"
FROM Jd1dta.PAZDCLPF;


 CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDROPF" ("RECSTATUS", "PREFIX", "ZENTITY", "ZIGVALUE", "JOBNUM", "JOBNAME") AS 
  SELECT  
  "RECSTATUS", 
  "PREFIX", 
  "ZENTITY",
  "ZIGVALUE", 
  "JOBNUM",
  "JOBNAME"
FROM Jd1dta.PAZDROPF;
/

CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDCLPF" ("RECSTATUS", "PREFIX", "ZENTITY", "ZIGVALUE", "JOBNUM", "JOBNAME") AS 
  SELECT  
  "RECSTATUS", 
  "PREFIX", 
  "ZENTITY",
  "ZIGVALUE", 
  "JOBNUM",
  "JOBNAME"
FROM Jd1dta.PAZDCLPF;

/


  CREATE OR REPLACE FORCE EDITIONABLE VIEW Jd1dta.VIEW_DM_DMPVALPF ("SCHEDULE_NAME", "SCHEDULE_NUM", "REFKEY", "REFTAB", "ERRMESS01", "ERORFLD", "FLDVALUE", "VALDNO", "DATIME") AS 
  SELECT  
"SCHEDULE_NAME",
"SCHEDULE_NUM", 
"REFKEY",       
"REFTAB",       
"ERRMESS01",    
"ERORFLD",      
"FLDVALUE",     
"VALDNO",       
"DATIME"   
FROM Jd1dta.dmpvalpf;
/



CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDCHPF" ("RECSTATUS", "ZENTITY", "ZIGVALUE","EFFDATE","ZSEQNO", "ZCLNUNINO","ZCLREL", "JOBNUM", "JOBNAME") AS 
  SELECT  
  "RECSTATUS", 
  "ZENTITY",
  "ZIGVALUE", 
  "EFFDATE",
  "ZSEQNO", 
  "ZCLNUNINO",
  "ZCLREL", 
  "JOBNUM", 
  "JOBNAME"
FROM Jd1dta.PAZDCHPF;
/

--------------------------------------------------------
--  DDL for View VIEW_DM_ZCPNPF
--------------------------------------------------------
CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZCPNPF" ("ZCMPCODE", "ZPETNAME", "ZENDCDE", "CHDRNUM", "GPLOTYP", "ZAGPTID","RCDATE", 
	"ZCMPFRM" , 
	"ZCMPTO" , 
	"ZMAILDAT" , 
	"ZACLSDAT" , 
	"ZDLVCDDT" , 
	"ZVEHICLE" , 
	"ZSTAGE" , 
	"ZSCHEME01", 
	"ZSCHEME02", 
	"USRPRF", 
	"JOBNM", 
	"DATIME" , 
	"ZPOLCLS" , 
	"EFFDATE", 
	"ZCRTUSR", 
	"ZAPPDATE", 
	"ZCCODIND", 
	"STATUS" 
	 ) AS 
	 SELECT "ZCMPCODE", "ZPETNAME", "ZENDCDE", "CHDRNUM", "GPLOTYP", "ZAGPTID","RCDATE", 
	"ZCMPFRM" , 
	"ZCMPTO" , 
	"ZMAILDAT" , 
	"ZACLSDAT" , 
	"ZDLVCDDT" , 
	"ZVEHICLE" , 
	"ZSTAGE" , 
	"ZSCHEME01", 
	"ZSCHEME02", 
	"USRPRF", 
	"JOBNM", 
	"DATIME" , 
	"ZPOLCLS" , 
	"EFFDATE", 
	"ZCRTUSR", 
	"ZAPPDATE", 
	"ZCCODIND", 
	"STATUS" 
	FROM Jd1dta.ZCPNPF;

-----------------------------------------------------
------VIEW_DM_PAZDRFPF ------------------------------
-----------------------------------------------------
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDRFPF" ("RECSTATUS", "ZENTITY", "CHDRNUM", "ZREFMTCD", "ZIGVALUE", "JOBNUM", "JOBNAME", "ZPDATATXFLG") AS 
  SELECT  
  "RECSTATUS", 
  "ZENTITY", 
  "CHDRNUM", 
  "ZREFMTCD", 
  "ZIGVALUE", 
  "JOBNUM", 
  "JOBNAME", 
  "ZPDATATXFLG"
FROM Jd1dta.PAZDRFPF;
/

-----------------------------------------------------
------VIEW_DM_PAZDRBPF ------------------------------
-----------------------------------------------------
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDRBPF" 
 ("PREFIX", "ZENTITY", "CHDRNUM", "ZIGVALUE", "JOBNUM", "JOBNAME", "PRBILFDT", "PRBILTDT", "ZPDATATXFLG") AS 
  SELECT  
  "PREFIX", 
  "ZENTITY", 
  "CHDRNUM", 
  "ZIGVALUE", 
  "JOBNUM", 
  "JOBNAME", 
  "PRBILFDT", 
  "PRBILTDT", 
  "ZPDATATXFLG"
FROM Jd1dta.PAZDRBPF;
/

--------------------------------------------------------
--  DDL for View VIEW_DM_GBIHPF
--------------------------------------------------------
CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_GBIHPF" ("UNIQUE_NUMBER", "BILLNO", "CHDRCOY", "CHDRNUM", "SUBSCOY", "SUBSNUM", "MBRNO","BILLTYP", 
	"PRBILFDT" , 
	"PRBILTDT" , 
	"INSTNO" , 
	"PBILLNO" , 
	"TERMID" , 
	"TRDT" , 
	"TRTM" , 
	"TRANNO", 
	"GRPGST", 
	"GRPSDUTY", 
	"VALIDFLAG", 
	"BILFLAG",
	"NRFLG",
	"TGTPCNT",
	"PREMOUT",
	"BILLDUEDT",
	"REVFLAG",
	"USER_T",
	"ZGSTAFEE",
	"ZGSTCOM",
	"ZCOLFLAG",
	"ZACMCLDT" , 
	"PAYDATE" , 
	"ZPOSBDSM" , 
	"ZPOSBDSY" , 
	"RDOCPFX" , 
	"RDOCCOY" , 
	"RDOCNUM" ,
	"DATIME" , 
	"JOBNM", 
	"USRPRF", 
	"ZBKTRFDT", 
	"ZSTPBLYN", 
	"PPMCCOST" 
	 ) AS 
	 SELECT "UNIQUE_NUMBER", "BILLNO", "CHDRCOY", "CHDRNUM", "SUBSCOY", "SUBSNUM", "MBRNO","BILLTYP", 
	"PRBILFDT" , 
	"PRBILTDT" , 
	"INSTNO" , 
	"PBILLNO" , 
	"TERMID" , 
	"TRDT" , 
	"TRTM" , 
	"TRANNO", 
	"GRPGST", 
	"GRPSDUTY", 
	"VALIDFLAG",
	"BILFLAG",
	"NRFLG",
	"TGTPCNT",
	"PREMOUT",
	"BILLDUEDT",
	"REVFLAG",
	"USER_T",
	"ZGSTAFEE",
	"ZGSTCOM",
	"ZCOLFLAG",
	"ZACMCLDT" , 
	"PAYDATE" , 
	"ZPOSBDSM" , 
	"ZPOSBDSY" , 
	"RDOCPFX" , 
	"RDOCCOY" , 
	"RDOCNUM" ,
	"DATIME" , 
	"JOBNM", 
	"USRPRF", 
	"ZBKTRFDT", 
	"ZSTPBLYN", 
	"PPMCCOST" 
	FROM Jd1dta.GBIHPF;
	
--
--------------------------------------------------------
--  DDL for View VIEW_DM_GBIDPF
--------------------------------------------------------
CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_GBIDPF" ("UNIQUE_NUMBER", "BADVRFUND", "BATCACTMN", "BATCACTYR", "BATCBATCH", "BATCBRN", "BATCCOY", "BATCTRCDE", 
	"BCOMM" , 
	"BEXTPRM" , 
	"BILLNO" , 
	"BOVCOMM01" , 
	"BOVCOMM02" , 
	"BPREM" , 
	"CHDRCOY" , 
	"CLASSINS", 
	"DATIME", 
	"DISCAMT", 
	"DISCAMT1", 
	"DISCAMT2",
	"DISCRATE",
	"DISCRATE1",
	"DISCRATE2",
	"FEES",
	"GSTCOM1",
	"GSTCOM2",
	"JOBNM",
	"PLANNO",
	"PRODTYP",
	"RIBFEE" , 
	"RIBFGST" , 
	"TERMID" , 
	"TRANNO" , 
	"TRDT" , 
	"TRTM" , 
	"USER_T" ,
	"USRPRF", 
	"VALIDFLAG", 
	"WKLADM", 
	"ZCTAXAMT01" , 
	"ZCTAXAMT02", 
	"ZCTAXAMT03" 
	 ) AS 
	 SELECT "UNIQUE_NUMBER", "BADVRFUND", "BATCACTMN", "BATCACTYR", "BATCBATCH", "BATCBRN", "BATCCOY","BATCTRCDE", 
	"BCOMM" , 
	"BEXTPRM" , 
	"BILLNO" , 
	"BOVCOMM01" , 
	"BOVCOMM02" , 
	"BPREM" , 
	"CHDRCOY" , 
	"CLASSINS", 
	"DATIME", 
	"DISCAMT", 
	"DISCAMT1",
	"DISCAMT2",
	"DISCRATE",
	"DISCRATE1",
	"DISCRATE2",
	"FEES",
	"GSTCOM1",
	"GSTCOM2",
	"JOBNM",
	"PLANNO",
	"PRODTYP",
	"RIBFEE" , 
	"RIBFGST" , 
	"TERMID" , 
	"TRANNO" , 
	"TRDT" , 
	"TRTM" , 
	"USER_T" ,
	"USRPRF", 
	"VALIDFLAG", 
	"WKLADM", 
	"ZCTAXAMT01" , 
	"ZCTAXAMT02", 
	"ZCTAXAMT03" 
	FROM Jd1dta.GBIDPF;
	
--------------------------------------------------------
--  DDL for View VIEW_DM_GPMDPF
--------------------------------------------------------
CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_GPMDPF" ("UNIQUE_NUMBER", "BATCACTMN", "BATCACTYR", "BATCBATCH", "BATCBRN", "BATCCOY", "BATCTRCD", 
	"BBJOBNO" , 
	"BILLNO" , 
	"BILLTYP" , 
	"CHDRCOY" , 
	"CHDRNUM",
	"DATIME" , 
	"DPNTNO" , 
	"EFFDATE" , 
	"EVNTFEE" , 
	"FEES", 
	"FLATFEE", 
	"HEADCNTIND", 
	"INSTNO",
	"JOBNM",
	"JOBNOISS",
	"JOBNOTPA",
	"JOBNOUD",
	"MBRNO",
	"MFJOBNO",
	"MMIND",
	"PEMXTPRM",
	"PLANNO",
	"PNIND",
	"POAXTPRM" , 
	"PPREM" , 
	"PRMFRDT" , 
	"PRMTODT" , 
	"PRODTYP" , 
	"RECNO" , 
	"RECTYPE" ,
	"SRCDATA" ,
	"SUBSCOY", 
	"SUBSNUM", 
	"THREADNO", 
	"TRANNO", 
	"USRPRF" 
	 ) AS 
	 SELECT "UNIQUE_NUMBER", "BATCACTMN", "BATCACTYR", "BATCBATCH", "BATCBRN", "BATCCOY", "BATCTRCD", 
	"BBJOBNO" , 
	"BILLNO" , 
	"BILLTYP" , 
	"CHDRCOY" , 
	"CHDRNUM",
	"DATIME" , 
	"DPNTNO" , 
	"EFFDATE" , 
	"EVNTFEE" , 
	"FEES", 
	"FLATFEE", 
	"HEADCNTIND", 
	"INSTNO",
	"JOBNM",
	"JOBNOISS",
	"JOBNOTPA",
	"JOBNOUD",
	"MBRNO",
	"MFJOBNO",
	"MMIND",
	"PEMXTPRM",
	"PLANNO",
	"PNIND",
	"POAXTPRM" , 
	"PPREM" , 
	"PRMFRDT" , 
	"PRMTODT" , 
	"PRODTYP" , 
	"RECNO" , 
	"RECTYPE" ,
	"SRCDATA" ,
	"SUBSCOY", 
	"SUBSNUM", 
	"THREADNO", 
	"TRANNO", 
	"USRPRF" 
	FROM Jd1dta.GPMDPF;
	
	
--------------------------------------------------------
--  DDL for View VIEW_DM_ZRFDPF
--------------------------------------------------------
CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZRFDPF" ("BILLNO",  "CHDRNUM", "DATIME", "EFFDATE", "JOBNM","TRANNO", 
	"USRPRF" , 
	"ZREFMTCD" , 
	"ZREFUNDAM" 
	 ) AS 
	 SELECT "BILLNO",  "CHDRNUM", "DATIME", "EFFDATE", "JOBNM","TRANNO", 
	"USRPRF" , 
	"ZREFMTCD" , 
	"ZREFUNDAM"  
	FROM Jd1dta.ZRFDPF;
	
	--------------------------------------------------------
--  DDL for View VIEW_DM_PAZDCRPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDCRPF" ("ZENTITY", "ZIGVALUE", "JOBNUM", "JOBNAME") AS 
  SELECT
	"ZENTITY",
	"ZIGVALUE",
	"JOBNUM",
	"JOBNAME"
	FROM Jd1dta.PAZDCRPF;

--------------------------------------------------------
--  DDL for View VIEW_DM_ZCRHPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZCRHPF" ("CHDRCOY", "CHDRPFX",	"CHDRNUM", "BILLNO", "TFRDATE", "DSHCDE", "USRPRF", "JOBNM", "DATIME", "LNBILLNO") AS 
  SELECT
	"CHDRCOY",
	"CHDRPFX",
	"CHDRNUM",
	"BILLNO",
	"TFRDATE",
	"DSHCDE",
	"USRPRF",
	"JOBNM",
	"DATIME",
	"LNBILLNO"
	FROM Jd1dta.ZCRHPF;
	
	--------------------------------------------------------
--  DDL for View VIEW_PAZDCLPF
--------------------------------------------------------
	
	  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_PAZDCLPF" ("RECSTATUS", "PREFIX", "ZENTITY", "ZIGVALUE", "JOBNUM", "JOBNAME") AS 
  SELECT  
  "RECSTATUS", 
  "PREFIX", 
  "ZENTITY",
  "ZIGVALUE", 
  "JOBNUM",
  "JOBNAME"
FROM Jd1dta.PAZDCLPF;

	--------------------------------------------------------
--  DDL for View VIEW_ZCLNPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_ZCLNPF" ("CLNTPFX", "CLNTCOY", "CLNTNUM", "CLTDOB", "LSURNAME", "LGIVNAME", "ZKANASNM", "ZKANAGNM", "CLTSEX", "CLTPCODE", "ZKANADDR01", "ZKANADDR02", "ZKANADDR03", "ZKANADDR04", "CLTADDR01", "CLTADDR02", "CLTADDR03", "CLTADDR04", "CLTPHONE01", "CLTPHONE02", "ZWORKPLCE", "OCCPCODE", "OCCPCLAS", "ZOCCDSC", "CLTDOBFLAG", "LSURNAMEFLAG", "LGIVNAMEFLAG", "ZKANASNMFLAG", "ZKANAGNMFLAG", "CLTSEXFLAG", "CLTPCODEFLAG", "ZKANADDR01FLAG", "ZKANADDR02FLAG", "ZKANADDR03FLAG", "ZKANADDR04FLAG", "CLTADDR01FLAG", "CLTADDR02FLAG", "CLTADDR03FLAG", "CLTADDR04FLAG", "CLTPHONE01FLAG", "CLTPHONE02FLAG", "ZWORKPLCEFLAG", "OCCPCODEFLAG", "OCCPCLASFLAG", "ZOCCDSCFLAG", "EFFDATE", "USRPRF", "JOBNM", "DATIME") AS 
  SELECT "CLNTPFX", 
 "CLNTCOY", 
 "CLNTNUM",
 "CLTDOB", 
 "LSURNAME",
 "LGIVNAME",
 "ZKANASNM",
 "ZKANAGNM",
 "CLTSEX", 
 "CLTPCODE",
 "ZKANADDR01",
 "ZKANADDR02",
 "ZKANADDR03",
 "ZKANADDR04",
 "CLTADDR01",
 "CLTADDR02",
 "CLTADDR03",
 "CLTADDR04",
 "CLTPHONE01",
 "CLTPHONE02",
 "ZWORKPLCE",
 "OCCPCODE",
 "OCCPCLAS",
 "ZOCCDSC",
 "CLTDOBFLAG",
 "LSURNAMEFLAG",
 "LGIVNAMEFLAG",
 "ZKANASNMFLAG",
 "ZKANAGNMFLAG",
 "CLTSEXFLAG",
 "CLTPCODEFLAG",
 "ZKANADDR01FLAG",
 "ZKANADDR02FLAG",
 "ZKANADDR03FLAG",
 "ZKANADDR04FLAG",
 "CLTADDR01FLAG",
 "CLTADDR02FLAG",
 "CLTADDR03FLAG",
 "CLTADDR04FLAG",
 "CLTPHONE01FLAG",
 "CLTPHONE02FLAG",
 "ZWORKPLCEFLAG",
 "OCCPCODEFLAG",
 "OCCPCLASFLAG",
 "ZOCCDSCFLAG",
 "EFFDATE",
 "USRPRF" ,
 "JOBNM" ,
 "DATIME"
 FROM Jd1dta.ZCLNPF;

--------------------------------------------------------
--  DDL for View VIEW_ZDCLPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_ZDCLPF" ("RECSTATUS", "PREFIX", "ZENTITY", "ZIGVALUE", "JOBNUM", "JOBNAME") AS 
  SELECT  
  "RECSTATUS", 
  "PREFIX", 
  "ZENTITY",
  "ZIGVALUE", 
  "JOBNUM",
  "JOBNAME"
FROM Jd1dta.ZDCLPF;


--------------------------------------------------------
--  DDL for View VIEW_DM_PAZDPDPF
--------------------------------------------------------

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDPDPF" ("OLDCHDRNUM", "NEWCHDRNUM", "JOBNUM", "JOBNAME", "USRPRF", "DATIME") AS 
  SELECT
	"OLDCHDRNUM",
	"NEWCHDRNUM",
	"JOBNUM",
	"JOBNAME",
  "USRPRF",
  "DATIME"
	FROM Jd1dta.PAZDPDPF;

--------------------------------------------------------
--  DDL for View VIEW_DM_ZINSDTLSPF
--------------------------------------------------------
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZINSDTLSPF" ("CHDRCOY", "CHDRNUM", "TRANNO", "MBRNO", "DPNTNO", "CLNTNUM", "UNIQUE_NUMBER_02", "ZORIGSALP", "CLTRELN", "ZPLANCDE", "DCLDATE", "ZWORKPLCE2", "EFFDATE", "DTETRM", "ALTQUOTENO", "DTEATT", "USRPRF", "JOBNM", "DATIME", "ZTRXSTSIND", "ZINSROLE","ZINSDTHD", "ZRTRANNO", "TERMDTE", "OCCPCODE")
	AS
  SELECT "CHDRCOY",
    "CHDRNUM",
    "TRANNO",
    "MBRNO",
    "DPNTNO",
    "CLNTNUM",
    "UNIQUE_NUMBER_02",
    "ZORIGSALP",
    "CLTRELN",
    "ZPLANCDE",
    "DCLDATE",
    "ZWORKPLCE2",
    "EFFDATE",
    "DTETRM",
    "ALTQUOTENO",
    "DTEATT",
    "USRPRF",
    "JOBNM",
    "DATIME",
    "ZTRXSTSIND",
    "ZINSROLE",
	"ZINSDTHD",
    "ZRTRANNO",
    "TERMDTE",
    "OCCPCODE"
  FROM Jd1dta.ZINSDTLSPF;

--------------------------------------------------------
--  DDL for View VIEW_DM_PAZDPTPF
--------------------------------------------------------
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDPTPF" ("ZENTITY", "ZSEQNO", "TRANNO", "EFFDATE", "MBRNO", "ZINSROLE", "JOBNUM", "JOBNAME")
	AS
  SELECT "ZENTITY",
    "ZSEQNO",
    "TRANNO",
    "EFFDATE",
    "MBRNO",
    "ZINSROLE",
    "JOBNUM",
	"JOBNAME"
  FROM Jd1dta.PAZDPTPF;  
 
--------------------------------------------------------
--  DDL for View VIEW_DM_ZBENFDTLSPF
-------------------------------------------------------- 
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZBENFDTLSPF" ("CHDRCOY", "CHDRNUM", "ALTQUOTENO", "MBRNO", "DPNTNO", "SEQNUMB", "TRANNO", "EFFDATE", "DTETRM", "ZKNJFULNM", "CLTADDR01", "BNYPC", "BNYRLN", "ZTRXSTSIND", "USRPRF", "JOBNM", "DATIME")
  AS
  SELECT "CHDRCOY",
    "CHDRNUM",
    "ALTQUOTENO",
    "MBRNO",
    "DPNTNO",
    "SEQNUMB",
    "TRANNO",
    "EFFDATE",
    "DTETRM",
    "ZKNJFULNM",
    "CLTADDR01",
    "BNYPC",
    "BNYRLN",
    "ZTRXSTSIND",
    "USRPRF",
    "JOBNM",
    "DATIME"
  FROM Jd1dta.ZBENFDTLSPF;
 
--------------------------------------------------------
--  DDL for View VIEW_DM_ZSUBCOVDTLS
--------------------------------------------------------  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZSUBCOVDTLS"( "CHDRCOY", "CHDRNUM", "ALTQUOTENO", "MBRNO", "DPNTNO", "TRANNO", "EFFDATE", "PRODTYP01", "PRODTYP02", "DPREM", "ZTRXSTSIND", "USRPRF", "JOBNM", "DATIME")
  AS
  SELECT "CHDRCOY",
    "CHDRNUM",
    "ALTQUOTENO",
    "MBRNO",
    "DPNTNO",
    "TRANNO",
    "EFFDATE",
    "PRODTYP01",
    "PRODTYP02",
    "DPREM",
    "ZTRXSTSIND",
    "USRPRF",
    "JOBNM",
    "DATIME"
  FROM Jd1dta.ZSUBCOVDTLS;
  
--------------------------------------------------------
--  DDL for View VIEW_DM_PAZDPCPF
--------------------------------------------------------
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDPCPF" ("ZENTITY", "MBRNO", "DPNTNO", "PRODTYP", "EFFDATE", "JOBNUM", "JOBNAME")
	AS
  SELECT "ZENTITY",
    "MBRNO",
    "DPNTNO",
    "PRODTYP",
    "EFFDATE",
    "JOBNUM",
    "JOBNAME"
  FROM Jd1dta.PAZDPCPF;    

--------------------------------------------------------
--  DDL for View VIEW_DM_PAZDRNPF
--------------------------------------------------------  
 CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDRNPF" ("ZENTITY", "MBRNO", "ZINSTYPE", "ZAPIRNO", "FULLKANJINAME", "JOBNUM", "JOBNAME")
 AS
  SELECT "ZENTITY",
    "MBRNO",
    "ZINSTYPE",
    "ZAPIRNO",
    "FULLKANJINAME",
    "JOBNUM",
    "JOBNAME"
  FROM Jd1dta.PAZDRNPF; 
  
--------------------------------------------------------
--  DDL for VIEW VIEW_DM_ZAPIRNOPF
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_ZAPIRNOPF" ("CHDRCOY", "CHDRNUM", "ZINSTYPE", "ZAPIRNO", "MBRNO", "TRANNO", "EFFDATE", "DTETRM", "USRPRF", "JOBNM", "DATIME") AS 
  SELECT "CHDRCOY",
    "CHDRNUM",
    "ZINSTYPE",
    "ZAPIRNO",
    "MBRNO",
    "TRANNO",
    "EFFDATE",
    "DTETRM",
    "USRPRF",
    "JOBNM",
    "DATIME"
  FROM Jd1dta.ZAPIRNOPF;
  
--------------------------------------------------------
--  DDL for VIEW VIEW_DM_BILLINST_RECON_DET
--------------------------------------------------------

 CREATE OR REPLACE FORCE EDITIONABLE VIEW Jd1dta.VIEW_DM_BILLINST_RECON_DET
 (v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_attrib_name, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, d_created_on, v_created_by, v_job_name)
  AS 
  SELECT v_batch_id, v_policy_no, v_prod_cde, v_pol_commdt, v_attrib_name, v_pol_status, v_module_name, v_eff_date, v_eff_desc, v_src_val, v_stg_val, v_ig_val, v_summary_batch_id, d_created_on, v_created_by, v_job_name
    FROM Jd1dta.DM_BILLINST_RECON_DET;
	
--------------------------------------------------------
--  DDL for VIEW view_dm_pol_mihis_recon_det
--------------------------------------------------------	
CREATE OR REPLACE FORCE EDITIONABLE VIEW Jd1dta.view_dm_pol_mihis_recon_det (V_MODULE_NAME, V_ATTRIB_NAME, V_POLICY_NO, V_POL_STATUS, V_PROD_CDE, V_POL_COMMDT, V_SRC_VAL, V_STG_VAL, V_IG_VAL, V_EFF_DATE, V_EFF_DESC, V_JOB_NAME, V_BATCH_ID, V_SUMMARY_BATCH_ID, V_CREATED_BY, D_CREATED_ON)
AS
    SELECT
        v_module_name,
        v_attrib_name,
        v_policy_no,
        v_pol_status,
        v_prod_cde,
        v_pol_commdt,
        v_src_val,
        v_stg_val,
        v_ig_val,
        v_eff_date,
        v_eff_desc,
        v_job_name,
        v_batch_id,
        v_summary_batch_id,
        v_created_by,
        d_created_on
    FROM Jd1dta.dm_pol_mihis_recon_det;
	
CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDNYPF"  ("PREFIX", "DM_OR_IG", "CLNTSTAS", "IS_UPDATE_REQ","ZENTITY","ZIGVALUE","JOBNUM","JOBNAME")AS
SELECT  
  "PREFIX", 
  "DM_OR_IG",
  "CLNTSTAS", 
  "IS_UPDATE_REQ",
  "ZENTITY",
  "ZIGVALUE", 
  "JOBNUM",
  "JOBNAME"
FROM Jd1dta.PAZDNYPF;