-------------------------------------------------------------------
drop table "STAGEDBUSR"."ZSLPPF" cascade constraints;
drop table "STAGEDBUSR"."ZSLPHPF" cascade constraints;
drop table "STAGEDBUSR"."ZENDRPF" cascade constraints;
drop table "STAGEDBUSR"."ZESDPF" cascade constraints;
drop table "STAGEDBUSR"."ITEMPF" cascade constraints;
drop table "STAGEDBUSR"."BUSDPF" cascade constraints;

------------------------------------------------------------------
--DDL For Table ZSLPPF
------------------------------------------------------------------

  CREATE TABLE "STAGEDBUSR"."ZSLPPF" 
   (	"ZSALPLAN" VARCHAR2(30 CHAR), 
	"ZINSTYPE" VARCHAR2(3 BYTE), 
	"PRODTYP" VARCHAR2(4 BYTE), 
	"SUMINS" NUMBER(17,2), 
	"USRPRF" CHAR(10 CHAR), 
	"JOBNM" CHAR(10 CHAR), 
	"DATIME" TIMESTAMP (6), 
	"ZCOVRID" VARCHAR2(1 BYTE), 
	"ZIMBRPLO" VARCHAR2(1 BYTE), 
	"ZSUMINUSP" NUMBER(17,2), 
	"ZSUMINURV" NUMBER(17,2)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 0 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 COMPRESS BASIC LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "STAGEDBTS" ;
  
   CREATE INDEX "STAGEDBUSR"."ZSLPPF_IDX1" ON "STAGEDBUSR"."ZSLPPF" ("ZSALPLAN") TABLESPACE "STAGEDBTS" ; --Ticket #ZJNPG-9739 

   COMMENT ON COLUMN "STAGEDBUSR"."ZSLPPF"."ZSUMINUSP" IS 'It will hold sum insured for spouse';
   COMMENT ON COLUMN "STAGEDBUSR"."ZSLPPF"."ZSUMINURV" IS 'It will hold sum insured for relative';

----------------------------------------------------------------
--DDL For Table ZSLPHPF
----------------------------------------------------------------
  CREATE TABLE "STAGEDBUSR"."ZSLPHPF" 
   (	"ZSALPLAN" VARCHAR2(30 CHAR), 
	"ZSLPTYP" VARCHAR2(1 CHAR), 
	"USRPRF" NCHAR(10), 
	"JOBNM" NCHAR(10), 
	"DATIME" TIMESTAMP (6), 
	 CONSTRAINT "PK_ZSLPHPF" PRIMARY KEY ("ZSALPLAN")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "STAGEDBTS" ;

   COMMENT ON COLUMN "STAGEDBUSR"."ZSLPHPF"."ZSALPLAN" IS 'This field will hold the salesplan code';
   COMMENT ON COLUMN "STAGEDBUSR"."ZSLPHPF"."ZSLPTYP" IS 'It will hold Named/Unnamed for a sales plan';
   COMMENT ON COLUMN "STAGEDBUSR"."ZSLPHPF"."USRPRF" IS 'USER NAME';
   COMMENT ON COLUMN "STAGEDBUSR"."ZSLPHPF"."JOBNM" IS 'JOB NAME';
   COMMENT ON COLUMN "STAGEDBUSR"."ZSLPHPF"."DATIME" IS 'DATE TIME';

------------------------------------------------------------------
--DDL Fro Table ZENDRPF
-----------------------------------------------------------------


  CREATE TABLE "STAGEDBUSR"."ZENDRPF" 
   (	"ZENDCDE" VARCHAR2(20 CHAR) NOT NULL ENABLE, 
	"ZENDCDST" VARCHAR2(2 CHAR) NOT NULL ENABLE, 
	"ZENCDEDT" NUMBER(8,0) NOT NULL ENABLE, 
	"ZENCDSDT" NUMBER(8,0) NOT NULL ENABLE, 
	"ZFACTHUS" VARCHAR2(2 CHAR) NOT NULL ENABLE, 
	"ZPRMFQ" NUMBER(2,0), 
	"ZBINCD" CHAR(8 CHAR), 
	"ZENDSCID" VARCHAR2(8 CHAR) NOT NULL ENABLE, 
	"ZENDFH" VARCHAR2(2 CHAR), 
	"ZCOLM" VARCHAR2(2 CHAR), 
	"CRUSER" VARCHAR2(10 CHAR), 
	"ZAPPUSR" VARCHAR2(10 CHAR), 
	"ZCLNTID" VARCHAR2(8 CHAR), 
	"ZPODEXT" VARCHAR2(6 CHAR), 
	"USRPRF" CHAR(10 CHAR), 
	"JOBNM" CHAR(10 CHAR), 
	"DATIME" TIMESTAMP (6), 
	"ZACSHED" VARCHAR2(1 CHAR), 
	"ZGTIPIND" VARCHAR2(1 CHAR), 
	 CONSTRAINT "PK_ZENDRPF" PRIMARY KEY ("ZENDCDE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "STAGEDBTS"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "STAGEDBTS" ;

   COMMENT ON COLUMN "STAGEDBUSR"."ZENDRPF"."CRUSER" IS 'Registered By';
   COMMENT ON COLUMN "STAGEDBUSR"."ZENDRPF"."ZAPPUSR" IS 'Approved By';
   COMMENT ON COLUMN "STAGEDBUSR"."ZENDRPF"."USRPRF" IS 'User Profile';
   COMMENT ON COLUMN "STAGEDBUSR"."ZENDRPF"."JOBNM" IS 'Job Name';
   COMMENT ON COLUMN "STAGEDBUSR"."ZENDRPF"."DATIME" IS 'Date Time';

CREATE INDEX "STAGEDBUSR"."ZENDRPF_PT_ZENDCDE" ON "STAGEDBUSR"."ZENDRPF" (RTRIM("ZENDCDE"))  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "STAGEDBTS" ;
CREATE INDEX "STAGEDBUSR"."ZENDRPF_IDX1_NIR" ON "STAGEDBUSR"."ZENDRPF" ("ZENDSCID", "ZENDCDE") tablespace users; --#ZJNPG-9739
-----------------------------------------------------------------
--DDL For Table ZESDPF
----------------------------------------------------------------

  CREATE TABLE "STAGEDBUSR"."ZESDPF" 
   (	"ZENDSCID" VARCHAR2(8 CHAR) NOT NULL ENABLE, 
	"ZSCHYEAR" NUMBER(4,0), 
	"ZSCHMONTH" NUMBER(2,0), 
	"ZANNCLDTNB" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZINTRNDT01" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZCOVCMDT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZANNCLDTCA" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZSLSTRNF" NUMBER(8,0) NOT NULL ENABLE, 
	"ZCMPENDT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZANNCLDTBAC" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZALTRNDTBAC" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZANNCLDTAL" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZLTRPADT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZINTRNDT02" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZALTRNDTAL" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZVALDDDT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZVALDRDT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZACMCLDT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZBILDDDT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZBKTRFDT" NUMBER(8,0), 
	"ZBILDTDT" NUMBER(8,0) NOT NULL ENABLE, 
	"ZPOSBDSY" NUMBER(4,0) NOT NULL ENABLE, 
	"ZPOSBDSM" NUMBER(2,0) NOT NULL ENABLE, 
	"ZBSTCSDT01" NUMBER(8,0) NOT NULL ENABLE, 
	"ZBSTPJDT01" NUMBER(8,0) NOT NULL ENABLE, 
	"ZBSTSYIM01" CHAR(1 CHAR) NOT NULL ENABLE, 
	"ZBSTCSDT02" NUMBER(8,0) NOT NULL ENABLE, 
	"ZBSTPJDT02" NUMBER(8,0) NOT NULL ENABLE, 
	"ZBSTCSDT03" NUMBER(8,0) NOT NULL ENABLE, 
	"ZBSTPJDT03" NUMBER(8,0) NOT NULL ENABLE, 
	"ZBSTSYIM02" CHAR(1 CHAR) NOT NULL ENABLE, 
	"ZPOLDDDT" NUMBER(8,0) NOT NULL ENABLE, 
	"ZTEMIRDT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"ZFNLIRDT" NUMBER(8,0) DEFAULT 99999999 NOT NULL ENABLE, 
	"USRPRF" CHAR(10 CHAR), 
	"JOBNM" CHAR(10 CHAR), 
	"DATIME" TIMESTAMP (6), 
	"ZBDCRDT" NUMBER(8,0), 
	"ZBDAGRDT" NUMBER(8,0), 
	"ZBDSLDT" NUMBER(8,0), 
	 CONSTRAINT "PK_ZESDPF" PRIMARY KEY ("ZENDSCID", "ZSCHYEAR", "ZSCHMONTH")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "STAGEDBTS"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 0 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 COMPRESS BASIC LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "STAGEDBTS" ;

   COMMENT ON COLUMN "STAGEDBUSR"."ZESDPF"."ZSLSTRNF" IS 'Last Tran Flag';
   COMMENT ON COLUMN "STAGEDBUSR"."ZESDPF"."USRPRF" IS 'User Profile';
   COMMENT ON COLUMN "STAGEDBUSR"."ZESDPF"."JOBNM" IS 'Job Name';
   COMMENT ON COLUMN "STAGEDBUSR"."ZESDPF"."DATIME" IS 'Date Time';
   COMMENT ON COLUMN "STAGEDBUSR"."ZESDPF"."ZBDCRDT" IS 'Billing data-create date';
   COMMENT ON COLUMN "STAGEDBUSR"."ZESDPF"."ZBDAGRDT" IS 'Billing data – aggregation date';
   COMMENT ON COLUMN "STAGEDBUSR"."ZESDPF"."ZBDSLDT" IS 'Billing data – sales date';

  CREATE INDEX "STAGEDBUSR"."J_PI_ZESDPF_ZBSTCSDT" ON "STAGEDBUSR"."ZESDPF" ("ZBSTCSDT02", "ZBSTCSDT03")   PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "STAGEDBTS" ;

  CREATE INDEX "STAGEDBUSR"."J_PI_ZESDPF_ZBSTCSDT03" ON "STAGEDBUSR"."ZESDPF" ("ZBSTCSDT03")   PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "STAGEDBTS" ;
 
 CREATE INDEX "STAGEDBUSR"."ZESDPF_IDX1_NIR" ON "STAGEDBUSR"."ZESDPF" ("ZENDSCID", "ZCOVCMDT") tablespace users; --#ZJNPG-9739
--------------------------------------------------------------------------------------------
--DDL For Table ITEMPF
-------------------------------------------------------------------------------------------

  CREATE TABLE "STAGEDBUSR"."ITEMPF" 
   (	"UNIQUE_NUMBER" NUMBER(18,0), 
	"ITEMPFX" CHAR(2 CHAR), 
	"ITEMCOY" CHAR(1 CHAR), 
	"ITEMTABL" CHAR(5 CHAR), 
	"ITEMITEM" CHAR(8 CHAR), 
	"ITEMSEQ" CHAR(2 CHAR), 
	"TRANID" CHAR(14 CHAR), 
	"TABLEPROG" CHAR(6 CHAR), 
	"VALIDFLAG" CHAR(1 CHAR), 
	"ITMFRM" NUMBER(8,0), 
	"ITMTO" NUMBER(8,0), 
	"GENAREA" RAW(2000), 
	"USRPRF" CHAR(10 CHAR), 
	"JOBNM" CHAR(10 CHAR), 
	"DATIME" TIMESTAMP (6), 
	"GENAREAJ" VARCHAR2(4000 BYTE), 
	 CONSTRAINT "PK_ITEMPF" PRIMARY KEY ("UNIQUE_NUMBER")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 589824 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 0 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 COMPRESS BASIC LOGGING
  STORAGE(INITIAL 14680064 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "STAGEDBTS"  ENABLE ROW MOVEMENT ;

   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."ITEMPFX" IS 'ITEM PREFIX';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."ITEMCOY" IS 'ITEM COMPANY';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."ITEMTABL" IS 'ITEM TABLE';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."ITEMITEM" IS 'ITEM ITEM';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."ITEMSEQ" IS 'ITEM SEQUENCE';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."TRANID" IS 'TRAN ID';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."TABLEPROG" IS 'EXTRA DATA SCREEN PROGRAM FOR TABLE';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."VALIDFLAG" IS 'VALID FLAG';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."ITMFRM" IS 'ITEM FROM DATE';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."ITMTO" IS 'ITEM TO DATE';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."GENAREA" IS 'GENERAL AREA';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."USRPRF" IS 'USER PROFILE';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."JOBNM" IS 'JOB NAME';
   COMMENT ON COLUMN "STAGEDBUSR"."ITEMPF"."DATIME" IS 'TIMESTAMP';
   COMMENT ON TABLE "STAGEDBUSR"."ITEMPF"  IS 'PHYSICAL FILE: SMART TABLE REFERENCE DA';

  CREATE INDEX "STAGEDBUSR"."BENCH_ITEM" ON "STAGEDBUSR"."ITEMPF" ("VALIDFLAG", "ITEMITEM")   PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)   TABLESPACE "STAGEDBTS";

  CREATE INDEX "STAGEDBUSR"."IDX_ITEMPF" ON "STAGEDBUSR"."ITEMPF" ("ITEMPFX", "ITEMTABL", "VALIDFLAG", "ITEMCOY", "ITMFRM", "ITEMITEM", "ITEMSEQ")   PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "STAGEDBTS";

  CREATE INDEX "STAGEDBUSR"."IDX_ITEMPF_PT" ON "STAGEDBUSR"."ITEMPF" (RTRIM("ITEMTABL"), RTRIM("ITEMITEM")) PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "STAGEDBTS";

  CREATE INDEX "STAGEDBUSR"."ITDM" ON "STAGEDBUSR"."ITEMPF" ("ITEMCOY", "ITEMTABL", "ITEMITEM", "ITMFRM" DESC, "UNIQUE_NUMBER")   PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "STAGEDBTS";

  CREATE INDEX "STAGEDBUSR"."ITDMPRM" ON "STAGEDBUSR"."ITEMPF" ("ITEMPFX", "ITEMCOY", "ITEMTABL", "ITEMITEM", "ITMFRM" DESC, "UNIQUE_NUMBER")   PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "STAGEDBTS";

  CREATE INDEX "STAGEDBUSR"."ITEM" ON "STAGEDBUSR"."ITEMPF" ("ITEMPFX", "ITEMCOY", "ITEMTABL", "ITEMITEM", "ITEMSEQ", "UNIQUE_NUMBER" DESC)   PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  TABLESPACE "STAGEDBTS";

-------------------------------------------------------------------------------------------
--DDL For Table BUSDPF
-------------------------------------------------------------------------------------------
--drop table "STAGEDBUSR"."BUSDPF" cascade constraints;
  CREATE TABLE "STAGEDBUSR"."BUSDPF" 
   (	"UNIQUE_NUMBER" NUMBER(18,0) NOT NULL ENABLE, 
	"BUSDKEY" CHAR(4 CHAR), 
	"BUSDATE" NUMBER(8,0), 
	"USRPRF" CHAR(10 CHAR), 
	"JOBNM" CHAR(10 CHAR), 
	"DATIME" TIMESTAMP (6), 
	"COMPANY" CHAR(1 CHAR)
   )NOCOMPRESS NOLOGGING;
   
 -------------------------------------------------------------------------------------------
--GRANTS for STAGEDBUSR2 to access STAGEDBUSR tables
-------------------------------------------------------------------------------------------  
 GRANT ALL ON STAGEDBUSR.ZSLPPF TO stagedbusr2;
 GRANT ALL ON STAGEDBUSR.ZSLPHPF TO stagedbusr2;
 GRANT ALL ON STAGEDBUSR.ZENDRPF TO stagedbusr2;
 GRANT ALL ON STAGEDBUSR.ZESDPF TO stagedbusr2;
 GRANT ALL ON STAGEDBUSR.ITEMPF TO stagedbusr2;
 GRANT ALL ON STAGEDBUSR.BUSDPF TO stagedbusr2;

