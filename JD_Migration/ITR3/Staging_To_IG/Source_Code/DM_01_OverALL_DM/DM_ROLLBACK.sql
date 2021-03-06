--DROP COMMON FUNCTION---				
DROP FUNCTION GET_MIGRATION_PREFIX;
/
DROP TABLE ZDOEPF;
/
DROP SEQUENCE SEQ_ZDOEPF;
/
DROP PACKAGE PKG_DM_COMMON_OPERATIONS;
/
DROP FUNCTION VALIDATE_DATE;
/
DROP FUNCTION DATCONOPERATION;
/
DROP FUNCTION DATEDIFF;
/
DROP FUNCTION VALIDATE_JAPANESE_TEXT;
/
DROP FUNCTION GET_STAGE_TABLE_NAME;
/
DROP PROCEDURE BQ9SS_DM01_OVERALLDM;
/

--------DMAG-------------------------
DROP TABLE STAGEDBUSR.TITDMGAGENTPJ;
/
DROP TABLE PAZDROPF;
/
DROP PACKAGE PKG_DM_AGENCY;
/
DROP PROCEDURE BQ9S5_AG01_AGENCY;
/
--DMBL-------------------------------
DROP TABLE STAGEDBUSR.TITDMGCOLRES;
/
DROP TABLE STAGEDBUSR.TITDMGBILL1;
/
DROP TABLE STAGEDBUSR.TITDMGBILL2;
/
DROP TABLE STAGEDBUSR.TITDMGREF1;
/
DROP TABLE STAGEDBUSR.TITDMGREF2;
/
DROP TABLE PAZDCRPF;
/
DROP TABLE PAZDRBPF;
/
DROP TABLE PAZDRFPF;
/
DROP PACKAGE PKG_COMMON_DMBL;
/
DROP PROCEDURE BQ9TL_BL01_COLLRSLT;
/
DROP PROCEDURE BQ9TK_BL01_BILLHIST;
/
DROP PROCEDURE BQ9UX_BL01_REFUNDBL;
/
DROP VIEW VIEW_ZREPPF;
/

--DMCB---------------------------------
DROP TABLE STAGEDBUSR.TITDMGCLNTBANK;
/
DROP PROCEDURE BQ9RU_CB01_CLTBNK;
/
DROP PACKAGE PKG_COMMON_DMCB;
/
--DMCL----------------------------------
DROP TABLE STAGEDBUSR.TITDMGCLNTCORP;
/
DROP TABLE PAZDCLPF;
/
DROP VIEW VIEW_ZCLNPF;
/
DROP PROCEDURE BQ9Q7_CL01_CORPCLT;
/
DROP SEQUENCE SEQANUMPF;
/
--DMCP---------------------------------
DROP TABLE STAGEDBUSR.TITDMGCLNTPRSN;
/
DROP TABLE STAGEDBUSR.TITDMGCLTRNHIS;
/
DROP TABLE PAZDCHPF;
/
DROP PROCEDURE BQ9Q6_CL02_PERCLT;
/
DROP PROCEDURE BQ9TV_CL02_2_CLNTHIST;
/
--DMCM--------------------------------------
DROP TABLE STAGEDBUSR.TITDMGCAMPCDE;
/
DROP PACKAGE PKG_COMMON_DMCM;
/
DROP PROCEDURE BQ9S8_CM01_CAMPCD;
/
--DMLT--------------------------------------
DROP TABLE STAGEDBUSR.TITDMGLETTER;
/
DROP TABLE PAZDLTPF;
/
DROP PROCEDURE BQ9RF_LT01_LETR;
/
--DMMB---------------------------------------
DROP TABLE STAGEDBUSR.TITDMGMBRINDP1;
/
DROP TABLE STAGEDBUSR.TITDMGMBRINDP2;
/
DROP TABLE STAGEDBUSR.TITDMGMBRINDP3;
/
DROP TABLE STAGEDBUSR.TITDMGPOLTRNH;
/
DROP TABLE PAZDPTPF;
/
DROP TABLE PAZDRPPF;
/
DROP PACKAGE PKG_COMMON_DMMB;
/
DROP PACKAGE PKG_COMMON_DMMB_PDSH;
/
DROP PACKAGE PKG_COMMON_DMMB_PHST;
/
DROP PROCEDURE BQ9SC_MB01_MBRIND;
/
DROP PROCEDURE BQ9UT_MB01_DISHONOR;
/
DROP PROCEDURE BQ9UU_MB01_POLHIST;
/
DROP PROCEDURE VIEW_DM_ZTIERPF;
/
DROP PROCEDURE VIEW_DM_ZTRAPF;
/

--DMMB_Index_Drop.sql
--Sales----------------------------------------
DROP TABLE STAGEDBUSR.TITDMGSALEPLN1;
/
DROP TABLE STAGEDBUSR.TITDMGSALEPLN2;
/
DROP PROCEDURE BQ9SF_SP01_SALPLN;
-----------------------------------------------
COMMIT;