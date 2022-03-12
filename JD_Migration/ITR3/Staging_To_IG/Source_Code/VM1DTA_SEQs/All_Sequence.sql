
--------------------------------------------------------
--  DDL for Sequence BILSEQ1
--------------------------------------------------------

   --CREATE SEQUENCE  "Jd1dta"."BILSEQ1"  MINVALUE 1 MAXVALUE 12000000 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE   ;
--------------------------------------------------------
--  DDL for Sequence DM_LETCSEQ
--------------------------------------------------------

  -- CREATE SEQUENCE  "Jd1dta"."DM_LETCSEQ"  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE   ;


   --CREATE SEQUENCE  "Jd1dta"."TEMP_BILL_SEQ1"  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE   ;
--------------------------------------------------------
--  DDL for Sequence TEMP_BILL_SEQ2
--------------------------------------------------------

   --CREATE SEQUENCE  "Jd1dta"."TEMP_BILL_SEQ2"  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE   ;
--------------------------------------------------------
--  DDL for Sequence TEMP_DM_SEQ1
--------------------------------------------------------

  -- CREATE SEQUENCE  "Jd1dta"."TEMP_DM_SEQ1"  MINVALUE 1 MAXVALUE 9999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE   ;
--------------------------------------------------------
--  DDL for Sequence TEMP_DM_SEQ2
--------------------------------------------------------

   --CREATE SEQUENCE  "Jd1dta"."TEMP_DM_SEQ2"  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE   ;
--------------------------------------------------------
--  DDL for Sequence TEMP_DM_SEQ3
--------------------------------------------------------

  -- CREATE SEQUENCE  "Jd1dta"."TEMP_DM_SEQ3"  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE   ;
--------------------------------------------------------
--  DDL for Sequence TEMP_SEQ
--------------------------------------------------------

  -- CREATE SEQUENCE  "Jd1dta"."TEMP_SEQ"  MINVALUE 1 MAXVALUE 99999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE   ;
---------
create sequence Jd1dta.SEQ_ZDOEPF
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;

----
create sequence Jd1dta.SEQANUMPF
minvalue 1
maxvalue 99999999999999999999999999
start with 1
increment by 1
cache 20;

---
/*
create sequence Jd1dta.SEQ_ZCLN_ZDCH
minvalue 1
maxvalue 99999999999999999999999999
start with 1
increment by 1
cache 20;
*/
------------------------------------------------
--------Create Sequence for BILLNO Generation
-------------------------------------------------
drop sequence  SEQ_BILLNO;
create sequence Jd1dta.SEQ_BILLNO
minvalue 1
maxvalue 999999999
start with 1
increment by 1
cache 20;

------------------------------------------------
--------Added for ZJNPG-8428 Create Sequence for Error log generation Generation
-------------------------------------------------
drop SEQUENCE error_log_seq;
CREATE SEQUENCE Jd1dta.error_log_seq
       INCREMENT BY 1
       START WITH 1
       MINVALUE 1
       MAXVALUE 9999999999999999999
       NOCACHE
       NOORDER
       NOCYCLE;
	   
	   
-----Cahce size increase---
ALTER SEQUENCE SEQ_CHDRPF		 cache 1000;
ALTER SEQUENCE SEQ_GCHIPF       cache 1000;
ALTER SEQUENCE SEQ_GCHPPF       cache 1000;
ALTER SEQUENCE SEQ_CLRRPF       cache 1000;
ALTER SEQUENCE SEQANUMPF        cache 1000;
ALTER SEQUENCE SEQ_CLEXPF       cache 1000;
ALTER SEQUENCE SEQ_CLNTPF       cache 1000;
ALTER SEQUENCE SEQ_CLNTPF       cache 1000;
ALTER SEQUENCE SEQ_VERSIONPF    cache 1000;
ALTER SEQUENCE SEQ_ZCSLPF       cache 1000;
ALTER SEQUENCE SEQ_CLBAPF       cache 1000;
ALTER SEQUENCE SEQ_ZMCIPF       cache 1000;
ALTER SEQUENCE SEQ_GXHIPF       cache 1000;
ALTER SEQUENCE SEQ_CLRRPF       cache 1000;
ALTER SEQUENCE SEQ_GMHDPF       cache 1000;
ALTER SEQUENCE SEQ_GMHIPF       cache 1000;
ALTER SEQUENCE SEQ_ZCLEPF       cache 1000;
ALTER SEQUENCE SEQ_ZUCLPF       cache 1000;
ALTER SEQUENCE SEQ_BILLNO       cache 1000;
ALTER SEQUENCE SEQ_GBIHPF       cache 1000;
ALTER SEQUENCE SEQ_GPMDPF       cache 1000;
ALTER SEQUENCE SEQ_GBIDPF       cache 1000;
ALTER SEQUENCE SEQ_ZDOEPF       cache 1000;
ALTER SEQUENCE SEQ_LETCPF       cache 1000;

-----Cahce size increase---