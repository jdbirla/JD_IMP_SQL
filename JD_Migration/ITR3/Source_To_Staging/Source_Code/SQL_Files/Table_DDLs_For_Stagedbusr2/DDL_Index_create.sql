--------------------------------------------------------
--  File created - Tuesday-June-26-2018   
--------------------------------------------------------

--------------------------------------------------------
--  DDL for Index PK1_SPPLANCONVERTION
--------------------------------------------------------

--  CREATE UNIQUE INDEX "STAGEDBUSR2"."PK1_SPPLANCONVERTION" ON "STAGEDBUSR2"."SPPLANCONVERTION" ("OLDZSALPLAN", "NEWZSALPLAN");
--------------------------------------------------------
--  DDL for Index PK1_TITDMGREF1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK1_TITDMGREF1" ON "STAGEDBUSR2"."TITDMGREF1" ("REFNUM", "CHDRNUM", "ZREFMTCD");
--------------------------------------------------------
--  DDL for Index TMP_IND
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."TMP_IND" ON "STAGEDBUSR2"."TEMP1" ("ISA3ST", "ISB0NB", "ICB0VA", "ICBMST", TO_NUMBER("APLACD")*12);
--------------------------------------------------------
--  DDL for Index KANJI_IDEX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."KANJI_IDEX" ON "STAGEDBUSR2"."KANJI_ADDRESS_LIST" ("APCUCD");

--------------------------------------------------------
--  DDL for Index KANA_IDEX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."KANA_IDEX" ON "STAGEDBUSR2"."KANA_ADDRESS_LIST" ("POSTALCD");

--------------------------------------------------------
--  DDL for Index PK_TITDMGPOLTRNH
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGPOLTRNH" ON "STAGEDBUSR2"."TITDMGPOLTRNH" ("CHDRNUM", "ZSEQNO", "EFFDATE");

--------------------------------------------------------
--  DDL for Index ZMRLH00_SUBLHCUCD_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRLH00_SUBLHCUCD_IDX" ON "STAGEDBUSR2"."ZMRLH00" (SUBSTR("LHCUCD",1,8));

--------------------------------------------------------
--  DDL for Index ZMRAPOO_IDX2
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAPOO_IDX2" ON "STAGEDBUSR2"."ZMRAP00" ("APCUCD", "APC2CD", "APC6CD", "APC7CD", "APC8CD");

--------------------------------------------------------
--  DDL for Index ZMRAP00_TSUBAPYOB6_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_TSUBAPYOB6_IDX" ON "STAGEDBUSR2"."TMP_ZMRAP00" (SUBSTR("APYOB6",5,8));

--------------------------------------------------------
--  DDL for Index PK_TITDMGCLNTCORP
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGCLNTCORP" ON "STAGEDBUSR2"."TITDMGCLNTCORP" ("CLNTKEY");

--------------------------------------------------------
--  DDL for Index ZMRAP00_TSUB_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_TSUB_IDX" ON "STAGEDBUSR2"."TMP_ZMRAP00" (SUBSTR("APCUCD",1,8));

--------------------------------------------------------
--  DDL for Index MPOL_ID2
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."MPOL_ID2" ON "STAGEDBUSR2"."MEMPOL" ("IP");

--------------------------------------------------------
--  DDL for Index MEMPOL_IDX1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."MEMPOL_IDX1" ON "STAGEDBUSR2"."MEMPOL" ("MP");

--------------------------------------------------------
--  DDL for Index CARD_END_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."CARD_END_IDX" ON "STAGEDBUSR2"."CARD_ENDORSER_LIST" ("ENDORSERCODE");

--------------------------------------------------------
--  DDL for Index MAXPOLNUM_ID3
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."MAXPOLNUM_ID3" ON "STAGEDBUSR2"."MAXPOLNUM" ("MAXAPCUCD");

--------------------------------------------------------
--  DDL for Index ZMRFCT00_IDX1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRFCT00_IDX1" ON "STAGEDBUSR2"."ZMRFCT00" ("FCTCUCD");

--------------------------------------------------------
--  DDL for Index PK_TITDMGCLTRNHIS
--------------------------------------------------------

--  CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGCLTRNHIS" ON "STAGEDBUSR2"."TITDMGCLTRNHIS" ("REFNUM", "ZSEQNO", "EFFDATE");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGSALEPLN1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGSALEPLN1" ON "STAGEDBUSR2"."TMP_TITDMGSALEPLN1" ("ZSALPLAN", "ZINSTYPE", "PRODTYP");

--------------------------------------------------------
--  DDL for Index ZMRAP00_SUBAPYOB6_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_SUBAPYOB6_IDX" ON "STAGEDBUSR2"."ZMRAP00" (SUBSTR("APYOB6",5,8));

--------------------------------------------------------
--  DDL for Index ZMRAP00_SUB_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_SUB_IDX" ON "STAGEDBUSR2"."ZMRAP00" (SUBSTR("APCUCD",1,8));

--------------------------------------------------------
--  DDL for Index PK_TITDMGCLNTBANK
--------------------------------------------------------

--  CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGCLNTBANK" ON "STAGEDBUSR2"."TITDMGCLNTBANK" ("REFNUM", "SEQNO");
	CREATE INDEX "STAGEDBUSR2"."TITDMGCLNTBANK_I1" ON "STAGEDBUSR2"."TITDMGCLNTBANK" ("REFNUM", "BANKCD", "BRANCHCD", "BANKACCKEY", "BNKACTYP") TABLESPACE STAGEDBTS; --#ZJNPG-9739

--------------------------------------------------------
--  DDL for Index PK_TITDMGMBRINDP1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGMBRINDP1" ON "STAGEDBUSR2"."TITDMGMBRINDP1" ("REFNUM");
  CREATE INDEX "STAGEDBUSR2"."MEMPOL1_ID" ON "STAGEDBUSR2"."TITDMGMBRINDP1" ("ZPGPTODT", "ZPGPFRDT") ;
  CREATE INDEX "STAGEDBUSR2"."NOUNI_IDX1" ON "STAGEDBUSR2"."TITDMGMBRINDP1" ("REFNUM");
  CREATE UNIQUE INDEX "STAGEDBUSR2"."UNI_IDX1" ON "STAGEDBUSR2"."TITDMGMBRINDP1" ("REFNUM", "ZINSROLE");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGCLNTCORP
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGCLNTCORP" ON "STAGEDBUSR2"."TMP_TITDMGCLNTCORP" ("CLNTKEY");

--------------------------------------------------------
--  DDL for Index PK_TITDMGLETTER
--------------------------------------------------------

 -- CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGLETTER" ON "STAGEDBUSR2"."TITDMGLETTER" ("CHDRNUM", "LETTYPE", "LREQDATE");

--------------------------------------------------------
--  DDL for Index MEMPOL1_ID
--------------------------------------------------------

  --CREATE INDEX "STAGEDBUSR2"."MEMPOL1_ID" ON "STAGEDBUSR2"."TITDMGMBRINDP1" ("ZPGPTODT", "ZPGPFRDT");
--------------------------------------------------------
--  DDL for Index PK_TITDMGBILL1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGBILL1" ON "STAGEDBUSR2"."TITDMGBILL1" ("TRREFNUM", "CHDRNUM", "PRBILFDT");

--------------------------------------------------------
--  DDL for Index PK_TITDMGREF1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGREF1" ON "STAGEDBUSR2"."TITDMGREF1" ("REFNUM", "CHDRNUM", "ZREFMTCD");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGBILL1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGBILL1" ON "STAGEDBUSR2"."TMP_TITDMGBILL1" ("TRREFNUM", "CHDRNUM", "PRBILFDT");

--------------------------------------------------------
--  DDL for Index ZMRAP00_TSUBSEQ_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_TSUBSEQ_IDX" ON "STAGEDBUSR2"."TMP_ZMRAP00" (SUBSTR("APCUCD",-3));

--------------------------------------------------------
--  DDL for Index PK_TITDMGREF2
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGREF2" ON "STAGEDBUSR2"."TITDMGREF2" ("TRREFNUM", "CHDRNUM", "ZREFMTCD", "PRODTYP");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGMBRINDP3
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGMBRINDP3" ON "STAGEDBUSR2"."TMP_TITDMGMBRINDP3" ("OLDPOLNUM");

--------------------------------------------------------
--  DDL for Index PK_TITDMGCAMPCDE
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGCAMPCDE" ON "STAGEDBUSR2"."TITDMGCAMPCDE" ("ZCMPCODE");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGSALEPLN2
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGSALEPLN2" ON "STAGEDBUSR2"."TMP_TITDMGSALEPLN2" ("ZCMPCODE", "ZSALPLAN");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGCAMPCDE
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGCAMPCDE" ON "STAGEDBUSR2"."TMP_TITDMGCAMPCDE" ("ZCMPCODE");

--------------------------------------------------------
--  DDL for Index PK_TITDMGCOLRES
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGCOLRES" ON "STAGEDBUSR2"."TITDMGCOLRES" ("CHDRNUM", "TRREFNUM", "TFRDATE", "PRBILFDT");

--------------------------------------------------------
--  DDL for Index PK_TITDMGMBRINDP3
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGMBRINDP3" ON "STAGEDBUSR2"."TITDMGMBRINDP3" ("OLDPOLNUM");

--------------------------------------------------------
--  DDL for Index ZMRAP00_TSUBAPYOB4_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_TSUBAPYOB4_IDX" ON "STAGEDBUSR2"."TMP_ZMRAP00" (SUBSTR("APYOB4",1,6));

--------------------------------------------------------
--  DDL for Index PK_TITDMGREF2
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGREF2" ON "STAGEDBUSR2"."TITDMGREF2" ("TRREFNUM", "CHDRNUM", "ZREFMTCD", "PRODTYP");

--------------------------------------------------------
--  DDL for Index PK_TITDMGMBRINDP2
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGMBRINDP2" ON "STAGEDBUSR2"."TITDMGMBRINDP2" ("REFNUM", "PRODTYP");

--------------------------------------------------------
--  DDL for Index ID22
--------------------------------------------------------

  --CREATE INDEX "STAGEDBUSR2"."ID22" ON "STAGEDBUSR2"."ZMRIS00" ("ISCUCD", "ISCJCD");

--------------------------------------------------------
--  DDL for Index ZMRAP00_SUBAPDLCD_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_SUBAPDLCD_IDX" ON "STAGEDBUSR2"."ZMRAP00" (SUBSTR("APDLCD",1,1));

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGBILL2
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGBILL2" ON "STAGEDBUSR2"."TMP_TITDMGBILL2" ("TRREFNUM", "CHDRNUM", "PRODTYP", "MBRNO", "DPNTNO", "PRBILFDT");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGCLTRNHIS
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGCLTRNHIS" ON "STAGEDBUSR2"."TMP_TITDMGCLTRNHIS" ("REFNUM", "ZSEQNO", "EFFDATE");

--------------------------------------------------------
--  DDL for Index ZMRAP00_SUBSEQ_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_SUBSEQ_IDX" ON "STAGEDBUSR2"."ZMRAP00" (SUBSTR("APCUCD",-3));

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGPOLTRNH
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGPOLTRNH" ON "STAGEDBUSR2"."TMP_TITDMGPOLTRNH" ("CHDRNUM", "ZSEQNO", "EFFDATE");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGAGENTPJ
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGAGENTPJ" ON "STAGEDBUSR2"."TMP_TITDMGAGENTPJ" ("ZAREFNUM");

--------------------------------------------------------
--  DDL for Index ZMREI00_IDX1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMREI00_IDX1" ON "STAGEDBUSR2"."ZMREI00" ("EICUCD");

--------------------------------------------------------
--  DDL for Index MAXPOL_IND2
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."MAXPOL_IND2" ON "STAGEDBUSR2"."MAXPOLNUM" ("MINAPCUCD");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGREF1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGREF1" ON "STAGEDBUSR2"."TMP_TITDMGREF1" ("REFNUM", "CHDRNUM", "ZREFMTCD");

--------------------------------------------------------
--  DDL for Index PK_TITDMGAGENTPJ
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGAGENTPJ" ON "STAGEDBUSR2"."TITDMGAGENTPJ" ("ZAREFNUM");

--------------------------------------------------------
--  DDL for Index TEMP1_IDX1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."TEMP1_IDX1" ON "STAGEDBUSR2"."TEMP1" ("ICCICD", "ICBMST", "ICJGCD");
  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_IDX3" ON "STAGEDBUSR2"."ZMRAP00" ("APC6CD", "APC1CD") TABLESPACE STAGEDBTS;  --#ZJNPG-9739

--------------------------------------------------------
--  DDL for Index PK_TITDMGSALEPLN1
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGSALEPLN1" ON "STAGEDBUSR2"."TITDMGSALEPLN1" ("ZSALPLAN", "ZINSTYPE", "PRODTYP");

--------------------------------------------------------
--  DDL for Index PK_TMP_PJ_TITDMGCOLRES
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_PJ_TITDMGCOLRES" ON "STAGEDBUSR2"."TMP_PJ_TITDMGCOLRES" ("CHDRNUM", "TRREFNUM", "TFRDATE", "PRBILFDT");

--------------------------------------------------------
--  DDL for Index ZMRIS00_IDX1
--------------------------------------------------------

  --CREATE INDEX "STAGEDBUSR2"."ZMRIS00_IDX1" ON "STAGEDBUSR2"."ZMRIS00" ("ISCUCD");

--------------------------------------------------------
--  DDL for Index MP1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."MP1" ON "STAGEDBUSR2"."MEMPOL_VIEW1" ("MP");

--------------------------------------------------------
--  DDL for Index BTDATE_PTDATE_LIST_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."BTDATE_PTDATE_LIST_IDX" ON "STAGEDBUSR2"."BTDATE_PTDATE_LIST" ("CHDRNUM");

--------------------------------------------------------
--  DDL for Index ZMRAP00_SUBAPYOB4_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_SUBAPYOB4_IDX" ON "STAGEDBUSR2"."ZMRAP00" (SUBSTR("APYOB4",1,6));

--------------------------------------------------------
--  DDL for Index ZMRRS00_IDX1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRRS00_IDX1" ON "STAGEDBUSR2"."ZMRRS00" ("RSBVCD", "RSFOCD", "RSBTCD", "RSBUCD");

--------------------------------------------------------
--  DDL for Index MAXPOL_IND
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."MAXPOL_IND" ON "STAGEDBUSR2"."MAXPOLNUM" ("APCUCD");

--------------------------------------------------------
--  DDL for Index POLTN_ID1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."POLTN_ID1" ON "STAGEDBUSR2"."TITDMGPOLTRNH" ("CHDRNUM"||"ZSEQNO");

--------------------------------------------------------
--  DDL for Index ZMRAPOO_IDX1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAPOO_IDX1" ON "STAGEDBUSR2"."ZMRAP00" ("APCUCD", "APC6CD", "APDLCD");

--------------------------------------------------------
--  DDL for Index ZMRAP00_TSUBAPDLCD_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_TSUBAPDLCD_IDX" ON "STAGEDBUSR2"."TMP_ZMRAP00" (SUBSTR("APDLCD",1,1));

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGCOLRES
--------------------------------------------------------

--  CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGCOLRES" ON "STAGEDBUSR2"."TMP_TITDMGCOLRES" ("CHDRNUM", "TRREFNUM", "TFRDATE", "PRBILFDT");

--------------------------------------------------------
--  DDL for Index PK_PJ_TITDMGCOLRES
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_PJ_TITDMGCOLRES" ON "STAGEDBUSR2"."PJ_TITDMGCOLRES" ("CHDRNUM", "TRREFNUM", "TFRDATE", "PRBILFDT");

--------------------------------------------------------
--  DDL for Index SPLN_IDX
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."SPLN_IDX" ON "STAGEDBUSR2"."SPLN" ("AGE", "ZSUMINS", "SRCD", "DURPOL");

--------------------------------------------------------
--  DDL for Index PK_TITDMGBILL2
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGBILL2" ON "STAGEDBUSR2"."TITDMGBILL2" ("TRREFNUM", "CHDRNUM", "PRODTYP", "MBRNO", "DPNTNO", "PRBILFDT");

--------------------------------------------------------
--  DDL for Index ZMRIC00_IDX1
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRIC00_IDX1" ON "STAGEDBUSR2"."ZMRIC00" ("ICCUCD");

--------------------------------------------------------
--  DDL for Index PK_TITDMGSALEPLN2
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TITDMGSALEPLN2" ON "STAGEDBUSR2"."TITDMGSALEPLN2" ("ZCMPCODE", "ZSALPLAN");

--------------------------------------------------------
--  DDL for Index PK_TMP_TITDMGREF2
--------------------------------------------------------

  --CREATE UNIQUE INDEX "STAGEDBUSR2"."PK_TMP_TITDMGREF2" ON "STAGEDBUSR2"."TMP_TITDMGREF2" ("TRREFNUM", "CHDRNUM", "ZREFMTCD", "PRODTYP");

--------------------------------------------------------
--  DDL for Index ZMRAP00_APCUCD
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ZMRAP00_APCUCD" ON "STAGEDBUSR2"."ZMRAP00" ("APCUCD");

--------------------------------------------------------
--  DDL for Index ICCUCD_ID
--------------------------------------------------------

  CREATE INDEX "STAGEDBUSR2"."ICCUCD_ID" ON "STAGEDBUSR2"."ZMRIC00" (SUBSTR("ICCUCD",1,8));
--------------------------------------------------------
-- DDL for Index SPPLANCONVERTION
---------------------------------------------------------
--CREATE UNIQUE INDEX "STAGEDBUSR2"."PK1_SPPLANCONVERTION" ON "STAGEDBUSR2"."SPPLANCONVERTION" ("OLDZSALPLAN", "NEWZSALPLAN");

---------------------------------------------------------
-- DDL For Index SOLICITATION_FLG_LIST
--------------------------------------------------------
create index STAGEDBUSR2.IDX_SOLICITATION_PRODCODE on STAGEDBUSR2.SOLICITATION_FLG_LIST("PRODUCT_CODE");

create index STAGEDBUSR2.IDX_SOLICITATION_RCODE on STAGEDBUSR2.DECLINE_REASON_CODE("DM_R_CODE");


--CREATE UNIQUE INDEX "STAGEDBUSR2"."PK1_TMP_SPPLANCONVERTION" ON "STAGEDBUSR2"."TMP_SPPLANCONVERTION" ("OLDZSALPLAN", "NEWZSALPLAN");
--CREATE UNIQUE INDEX "STAGEDBUSR2"."PK1_SPPLANCONVERTION" ON "STAGEDBUSR2"."SPPLANCONVERTION" ("OLDZSALPLAN", "NEWZSALPLAN");

CREATE  INDEX "STAGEDBUSR2"."TRANNOTBL_INDEX1" ON "STAGEDBUSR2"."TRANNOTBL"("CHDRNUM");


--------------------------------------------------------
-- DDL For Index POLICY_STATCODE
--------------------------------------------------------
CREATE INDEX STAGEDBUSR2.IDX_POLICY_STATCODE ON STAGEDBUSR2.POLICY_STATCODE("CHDRNUM");

CREATE INDEX "STAGEDBUSR2"."ULAC6CD_INDX" ON "STAGEDBUSR2"."ZMRULA00" ("ULAC6CD") ;
CREATE INDEX "STAGEDBUSR2"."TMP_ULAC6CD_INDX" ON "STAGEDBUSR2"."TMP_ZMRULA00" ("ULAC6CD") ;

CREATE INDEX "STAGEDBUSR2"."PERSNL_CLNT_FLG_APCUCD_IDX1" ON "STAGEDBUSR2"."PERSNL_CLNT_FLG" ("APCUCD") ;

--------------------------------------------------------
-- DDL For Index DMPACLJOBCDE 									--Ticket #ZJNPG-10273  : Client Hist - Job Code patch
--------------------------------------------------------
CREATE INDEX "STAGEDBUSR2"."DMPACLJOBCDE_1" ON "STAGEDBUSR2"."DMPACLJOBCDE"("REFNUM","STAGECLNTNO");

--------------------------------------------------------
-- DDL For Index titdmgapirno
--------------------------------------------------------
CREATE INDEX titdmgapirno_i_1
ON STAGEDBUSR2.titdmgapirno(chdrnum);

CREATE INDEX titdmgapirno_i_2
ON STAGEDBUSR2.titdmgapirno(recidxapirno);

 CREATE INDEX TITDMGBILL_COMB_I1 ON TITDMGBILL_COMB(CHDRNUM);
 
  CREATE INDEX "STAGEDBUSR2"."TITDMGBILL_COM_BILL_I1" ON "STAGEDBUSR2"."TITDMGBILL_COM_BILL" ("CHDRNUM") ;
  
CREATE INDEX "STAGEDBUSR2"."ZMRAP00_I1" ON "STAGEDBUSR2"."ZMRAP00" (SUBSTR("APCUCD",-1))  ;
CREATE INDEX "STAGEDBUSR2"."ZMRIS00_JD1" ON "STAGEDBUSR2"."ZMRIS00" (SUBSTR("ISCICD",-2))  ;
CREATE INDEX "STAGEDBUSR2"."ZMRIC00_JD1" ON "STAGEDBUSR2"."ZMRIC00" (SUBSTR("ICCICD",-2)) ;
CREATE INDEX "STAGEDBUSR2"."ZMRIC00_JD2" ON "STAGEDBUSR2"."ZMRIC00" (SUBSTR("ICCICD",-1))  ;
CREATE INDEX "STAGEDBUSR2"."TITDMGSUMINSFACTOR_JD1" ON "STAGEDBUSR2"."TITDMGSUMINSFACTOR" ("ZINSTYPE", "DM_PRODTYP")  ;
CREATE INDEX "STAGEDBUSR2"."MEM_IND_POLHIST_SSPLAN_INTRMDT_JD1" ON "STAGEDBUSR2"."MEM_IND_POLHIST_SSPLAN_INTRMDT" ("APCUCD")  ;
CREATE INDEX "STAGEDBUSR2"."DPNTNO_TABLE_IDX1" ON "STAGEDBUSR2"."DPNTNO_TABLE" ("CHDRNUM", "MBRNO")  TABLESPACE "STAGEDBTS" ; --Ticket #ZJNPG-9739 
CREATE INDEX "STAGEDBUSR2"."MEM_IND_POLHIST_SSPLAN_INTRMDT_I2" ON "STAGEDBUSR2"."MEM_IND_POLHIST_SSPLAN_INTRMDT" ("NEWZSALPLAN") TABLESPACE "STAGEDBTS" ; --Ticket #ZJNPG-9739 
CREATE INDEX STAGEDBUSR2.TITDMGBILL1_idx1 on STAGEDBUSR2.TITDMGBILL1(CHDRNUM, PRBILFDT);--Ticket #ZJNPG-9739 
CREATE INDEX STAGEDBUSR2.TITDMGBILL1_idx2 on STAGEDBUSR2.TITDMGBILL1(CHDRNUM, recidxbill1); --Ticket #ZJNPG-9739 
CREATE INDEX STAGEDBUSR2.TITDMGBILL1_idx3 on STAGEDBUSR2.TITDMGBILL1(CHDRNUM); --Ticket #ZJNPG-9739 
CREATE INDEX STAGEDBUSR2.TITDMGBILL1_idx4 on STAGEDBUSR2.TITDMGBILL1(CHDRNUM, zposbdsy, zposbdsm);--Ticket #ZJNPG-9739 

-- started ZJNPG-10201
create index STAGEDBUSR2.indx_rd1 on stagedbusr2.renew_as_is (APCUCD, ICICD);
create index STAGEDBUSR2.indx_rd2 on stagedbusr2.titdmgmbrindp1 (substr(refnum,1,8));
create index STAGEDBUSR2.indx_rd4 on stagedbusr2.titdmgpoltrnh (chdrnum);
create index STAGEDBUSR2.indx_rd5 on stagedbusr2.titdmgpoltrnh (effdate);
create index STAGEDBUSR2.indx_rd6 on stagedbusr2.titdmgmbrindp2 (refnum);  
-- Ended ZJNPG-10201


----Rebuild---
alter index PERSNL_CLNT_FLG_APCUCD_IDX1 rebuild;
alter index ULAC6CD_INDX rebuild;
alter index TMP_ULAC6CD_INDX rebuild;
alter index IDX_SOLICITATION_PRODCODE rebuild;
alter index PK_TITDMGCLNTMAP rebuild;
alter index PK_SRCNAYOSETBL rebuild;
alter index PK_TITDMGCLTRNHIS_INT rebuild;
alter index UK_POLICY_STATCODE rebuild;
alter index IDX_POLICY_STATCODE rebuild;
alter index BTDATE_PTDATE_LIST_IDX rebuild;
alter index CARD_END_IDX rebuild;
alter index IDX_SOLICITATION_RCODE rebuild;
alter index KANA_IDEX rebuild;
alter index KANJI_IDEX rebuild;
alter index PK_MAXPOLNUM rebuild;
alter index MAXPOLNUM_ID3 rebuild;
alter index MAXPOL_IND2 rebuild;
alter index MAXPOL_IND rebuild;
alter index MPOL_ID2 rebuild;
alter index MEMPOL_IDX1 rebuild;
alter index MP1 rebuild;
alter index PK_PJ_TITDMGCOLRES rebuild;
alter index SPLN_IDX rebuild;
alter index TMP_IND rebuild;
alter index TEMP1_IDX1 rebuild;
alter index PK_TITDMGAGENTPJ rebuild;
alter index PK_TITDMGBILL1 rebuild;
alter index PK_TITDMGBILL2 rebuild;
alter index PK1_TITDMGCAMPCDE rebuild;
alter index PK_TITDMGCLNTCORP rebuild;
alter index PK_TITDMGCLTRNHIS rebuild;
alter index PK_TITDMGCOLRES rebuild;
alter index PK_TITDMGMBRINDP2 rebuild;
alter index PK_TITDMGMBRINDP3 rebuild;
alter index POLTN_ID1 rebuild;
alter index PK_TITDMGPOLTRNH rebuild;
alter index PK_TITDMGREF1 rebuild;
alter index PK_TITDMGREF2 rebuild;
alter index PK_TITDMGSALEPLN1 rebuild;
alter index PK_TITDMGZCSLPF rebuild;
alter index PK_TMP_PJ_TITDMGCOLRES rebuild;
alter index PK_TMP_TITDMGAGENTPJ rebuild;
alter index PK_TMP_TITDMGBILL1 rebuild;
alter index PK_TMP_TITDMGBILL2 rebuild;
alter index PK1_TMP_TITDMGCAMPCDE rebuild;
alter index PK_TMP_TITDMGCLNTCORP rebuild;
alter index PK_TMP_TITDMGCLTRNHIS rebuild;
alter index PK_TMP_TITDMGMBRINDP3 rebuild;
alter index PK_TMP_TITDMGPOLTRNH rebuild;
alter index PK_TMP_TITDMGREF1 rebuild;
alter index PK_TMP_TITDMGREF2 rebuild;
alter index PK_TMP_TITDMGSALEPLN1 rebuild;
alter index PK_TMP_TITDMGZCSLPF rebuild;
alter index ZMRAP00_TSUBSEQ_IDX rebuild;
alter index ZMRAP00_TSUBAPDLCD_IDX rebuild;
alter index ZMRAP00_TSUB_IDX rebuild;
alter index ZMRAP00_TSUBAPYOB6_IDX rebuild;
alter index ZMRAP00_TSUBAPYOB4_IDX rebuild;
alter index TMP_ISCJCD_IDX rebuild;
alter index TMP_ZMRIS00_IDX1 rebuild;
alter index TMP_ID22 rebuild;
alter index TMP_ZMRIS00_ISCICD_IDX1 rebuild;
alter index ZMRAP00_APCUCD rebuild;
alter index ZMRAP00_SUBAPYOB6_IDX rebuild;
alter index ZMRAP00_SUBSEQ_IDX rebuild;
alter index ZMRAP00_SUB_IDX rebuild;
alter index ZMRAPOO_IDX2 rebuild;
alter index ZMRAP00_SUBAPDLCD_IDX rebuild;
alter index ZMRAP00_SUBAPYOB4_IDX rebuild;
alter index ZMRAPOO_IDX1 rebuild;
alter index ZMREI00_IDX1 rebuild;
alter index ZMRFCT00_IDX1 rebuild;
alter index ZMRIC00_IDX1 rebuild;
alter index ICCUCD_ID rebuild;
alter index ZMRIS00_ISCICD_IDX1 rebuild;
alter index ISCJCD_IDX rebuild;
alter index ZMRIS00_IDX1 rebuild;
alter index ID22 rebuild;
alter index ZMRLH00_SUBLHCUCD_IDX rebuild;
alter index ZMRRS00_IDX1 rebuild;
alter index PK_MSTPOLDB rebuild;
alter index PK_TMP_MSTPOLDB rebuild;
alter index PK_MSTPOLGRP rebuild;
alter index PK_TMP_MSTPOLGRP rebuild;
alter index PK_TITDMGMASPOL rebuild;
alter index PK_TMP_TITDMGMASPOL rebuild;
--alter index PK_TITDMGENDCTPF rebuild;
--alter index PK_TMP_TITDMGENDCTPF rebuild;
alter index PK_TITDMGINSSTPL rebuild;
alter index PK_TMP_TITDMGINSSTPL rebuild;
alter index TRANNOTBL_INDEX1 rebuild;
alter index PK_RNWDT1 rebuild;
alter index PK_RNWDT2 rebuild;
alter index PK1_SPPLANCONVERTION rebuild;
alter index PK1_TMP_SPPLANCONVERTION rebuild;
alter index PK_TITDMGSALEPLN2 rebuild;
alter index PK_TMP_TITDMGSALEPLN2 rebuild;
alter index MEMPOL1_ID rebuild;
alter index UNI_IDX1 rebuild;
alter index NOUNI_IDX1 rebuild;
alter index ZMRAP00_IDX3 rebuild; --Ticket #ZJNPG-9739 
alter index TITDMGBILL_COMB_I1 rebuild; --Ticket #ZJNPG-9739 
alter index TITDMGBILL_COM_BILL_I1 rebuild; --Ticket #ZJNPG-9739 
alter index ZMRAP00_I1 rebuild; --Ticket #ZJNPG-9739 
alter index ZMRIS00_JD1 rebuild; --Ticket #ZJNPG-9739 
alter index ZMRIC00_JD1 rebuild; --Ticket #ZJNPG-9739 
alter index ZMRIC00_JD2 rebuild; --Ticket #ZJNPG-9739 
alter index TITDMGSUMINSFACTOR_JD1 rebuild; --Ticket #ZJNPG-9739 
alter index MEM_IND_POLHIST_SSPLAN_INTRMDT_JD1 rebuild; --Ticket #ZJNPG-9739 
alter index TITDMGCLNTBANK_I1 rebuild; --Ticket #ZJNPG-9739 
alter index DPNTNO_TABLE_IDX1 rebuild; --Ticket #ZJNPG-9739 
alter index MEM_IND_POLHIST_SSPLAN_INTRMDT_I2 rebuild; --Ticket #ZJNPG-9739 
alter index TITDMGBILL1_idx1 rebuild; --Ticket #ZJNPG-9739 
alter index TITDMGBILL1_idx2 rebuild; --Ticket #ZJNPG-9739
alter index TITDMGBILL1_idx3 rebuild; --Ticket #ZJNPG-9739
alter index TITDMGBILL1_idx4 rebuild; --Ticket #ZJNPG-9739
alter index indx_rd1 rebuild; --Ticket #ZJNPG-10201
alter index indx_rd2 rebuild; --Ticket #ZJNPG-10201
alter index indx_rd4 rebuild; --Ticket #ZJNPG-10201
alter index indx_rd5 rebuild; --Ticket #ZJNPG-10201
alter index indx_rd6 rebuild; --Ticket #ZJNPG-10201
alter index DMPACLJOBCDE_1 rebuild; --Ticket #ZJNPG-10273  : Client Hist - Job Code patch



---------Rebuild:end