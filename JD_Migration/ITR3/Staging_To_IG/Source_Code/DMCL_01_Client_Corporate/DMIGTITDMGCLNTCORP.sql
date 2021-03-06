  CREATE TABLE "Jd1dta"."DMIGTITDMGCLNTCORP" 
   (    "RECIDXCLCORP" NUMBER(*,0) NOT NULL ENABLE, 
    "CLTTYPE" VARCHAR2(1 CHAR), 
    "CLTADDR01" VARCHAR2(30 CHAR) NOT NULL ENABLE, 
    "CLTADDR02" VARCHAR2(30 CHAR) NOT NULL ENABLE, 
    "CLTADDR03" VARCHAR2(30 CHAR), 
    "CLTADDR04" VARCHAR2(30 CHAR), 
    "ZKANADDR01" VARCHAR2(30 CHAR) NOT NULL ENABLE, 
    "ZKANADDR02" VARCHAR2(30 CHAR) NOT NULL ENABLE, 
    "ZKANADDR03" VARCHAR2(30 CHAR), 
    "ZKANADDR04" VARCHAR2(30 CHAR), 
    "CLTPCODE" VARCHAR2(10 CHAR) NOT NULL ENABLE, 
    "CLTPHONE01" VARCHAR2(16 CHAR), 
    "CLTPHONE02" VARCHAR2(16 CHAR), 
    "CLTDOBX" NUMBER(8,0), 
    "CLTSTAT" VARCHAR2(2 CHAR), 
    "FAXNO" VARCHAR2(16 CHAR), 
    "LSURNAME" VARCHAR2(60 CHAR) NOT NULL ENABLE, 
    "ZKANASNM" VARCHAR2(60 CHAR) NOT NULL ENABLE, 
    "CLNTKEY" VARCHAR2(12 CHAR) NOT NULL ENABLE, 
    "AGNTNUM" CHAR(8 BYTE), 
    "MPLNUM" CHAR(8 BYTE),
    "CLNTNUM" CHAR(8 BYTE),
    "IND"     CHAR(1 BYTE))
  SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
  NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;