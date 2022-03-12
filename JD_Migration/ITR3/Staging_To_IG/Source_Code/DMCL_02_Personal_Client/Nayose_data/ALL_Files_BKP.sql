
--All_views
---------------------------------------------------------------
--   DDL for view of PAZDNYPF
--------------------------------------------------------------------     
   CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."VIEW_DM_PAZDNYPF"  ("PREFIX", "CLNTSTAS","ZENTITY","ZIGVALUE","JOBNUM","JOBNAME")AS
SELECT  
  "PREFIX", 
  "CLNTSTAS",
  "ZENTITY",
  "ZIGVALUE", 
  "JOBNUM",
  "JOBNAME"
FROM Jd1dta.PAZDNYPF;
------------------------
--DDL for DMVIEWNAYOSE
----------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "Jd1dta"."DMVIEWNAYOSE" ("ROW_NUM", "ZENDCDE", "CLNTNUM", "ZKANASNMNOR", "ZKANAGNMNOR", "CLTSEX", "CLTDOB", "CLTPCODE", "RMBLPHONE", "CHDRNUM", "COWNNUM", "STATCODE", "ZPLANCLS", "PRIORTY") AS 
  select 
 "ROW_NUM", "ZENDCDE", "CLNTNUM", "ZKANASNMNOR", "ZKANAGNMNOR", "CLTSEX", "CLTDOB", "CLTPCODE", "RMBLPHONE", "CHDRNUM", "COWNNUM", "STATCODE", "ZPLANCLS", "PRIORTY"
from 
 ( SELECT
    ROW_NUMBER() OVER(
        PARTITION BY "ZENDCDE", "ZKANASNMNOR", "ZKANAGNMNOR", "CLTSEX", "CLTDOB", "CLTPCODE", "RMBLPHONE"
        ORDER BY
            priorty ASC, clntnum DESC
    ) row_num,
    "ZENDCDE",
    "CLNTNUM",
    "ZKANASNMNOR",
    "ZKANAGNMNOR",
    "CLTSEX",
    "CLTDOB",
    "CLTPCODE",
    "RMBLPHONE",
    "CHDRNUM",
    "COWNNUM",
    "STATCODE",
    "ZPLANCLS",
    "PRIORTY"
FROM
    (
        SELECT
            rtrim(zendcde) AS zendcde,
            rtrim(clntnum) AS clntnum,
            rtrim(zkanasnmnor) AS zkanasnmnor,
            rtrim(zkanagnmnor) AS zkanagnmnor,
            rtrim(cltsex) AS cltsex,
            rtrim(cltdob) AS cltdob,
            rtrim(cltpcode) AS cltpcode,
            rtrim(rmblphone) AS rmblphone,
            chdrnum,
            cownnum,
            statcode,
            zplancls,
            (
                  CASE
                    WHEN ( statcode = 'IF' or statcode = 'XN'
                           AND zplancls = 'PP' ) THEN
                        '1'
                    WHEN (statcode = 'IF' or statcode = 'XN'
                           AND zplancls = 'FP' ) THEN
                        '2'
                    WHEN ( statcode = 'CA'
                           AND zplancls = 'PP' ) THEN
                        '3'
                    WHEN ( statcode = 'CA'
                           AND zplancls = 'FP' ) THEN
                        '4'
                    ELSE
                        '9'
                END
            ) AS priorty
        FROM
            (
                SELECT
                    zcel.zendcde,
                    clnt.clntnum,
                    ( regexp_replace(clnt.zkanasnmnor, ' ', '') ) AS zkanasnmnor,
                    ( regexp_replace(clnt.zkanagnmnor, ' ', '') ) AS zkanagnmnor,
                    clnt.cltsex,
                    clnt.cltdob,
                    clnt.cltpcode,
                    replace(rtrim(clex.rmblphone), '-') AS rmblphone
                FROM
                    Jd1dta.clntpf      clnt
                    INNER JOIN Jd1dta.zcelinkpf   zcel ON zcel.clntnum = clnt.clntnum
                    left outer
                    JOIN Jd1dta.clex ON clex.clntnum = clnt.clntnum
                WHERE
                    clnt.validflag = '1'
                    AND clnt.clttype = 'P'
            ) cl
            INNER JOIN (
                SELECT
                    gchd.chdrnum,
                    gchd.cownnum,
                    gchd.statcode,
                    gchp.zplancls
                FROM
                    gchd     gchd
                    INNER JOIN gchppf   gchp ON gchd.chdrnum = gchp.chdrnum
            ) pol ON cl.clntnum = pol.cownnum
    )
)
WHERE
    row_num = 1;
	
	
	
	
	-----
	--DM_IG_tables
	---------------------------------------------------------------
--   DDL for table PAZDNYPF
--------------------------------------------------------------------   

  CREATE TABLE "Jd1dta"."PAZDNYPF" 
   (	
    "UNIQUEID" NUMBER(*,0) GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 3405289 CACHE 20 NOORDER  NOCYCLE , 
	"PREFIX" VARCHAR2(2 CHAR), 
    "CLNTSTAS" VARCHAR2(2 CHAR),
	"ZENTITY" VARCHAR2(50 CHAR), 
	"ZIGVALUE" VARCHAR2(50 CHAR), 
	"JOBNUM" NUMBER(8,0), 
	"JOBNAME" VARCHAR2(10 CHAR)
   );
     CREATE UNIQUE INDEX "Jd1dta"."UNI_NY_ZENT" ON "Jd1dta"."PAZDNYPF" ("ZENTITY") ;

   
--------------
--DMIGTITNYCLT
----------------

CREATE TABLE "Jd1dta"."DMIGTITNYCLT" 
   (	"UNIQUEID" NUMBER(*,0) GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 3405289 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"REFNUM" VARCHAR2(8 CHAR), 
	"IG_CLNTNUM" VARCHAR2(8 CHAR), 
	"DCH_ZENDCDE" VARCHAR2(20 CHAR), 
	"DCH_ZKANASNMNOR" VARCHAR2(4000 CHAR), 
	"DCH_ZKANAGNMNOR" VARCHAR2(4000 CHAR), 
	"DCH_CLTDOB" VARCHAR2(40 BYTE), 
	"DCH_CLTPCODE" VARCHAR2(10 CHAR), 
	"DCH_CLTSEX" VARCHAR2(1 CHAR), 
	"DCH_CLTPHONE01" VARCHAR2(64 BYTE)
   ) ;

  CREATE UNIQUE INDEX "Jd1dta"."UNI_NY_REFNUM" ON "Jd1dta"."DMIGTITNYCLT" ("REFNUM") ;
   
----------------------------------
--ZDMBKPZCLN
--------------------------------------
 CREATE TABLE "Jd1dta"."ZDMBKPZCLN" 
   (	"CLNTNUM" CHAR(8 CHAR), 
	"EFFDATE" NUMBER(8,0)
   )  ;

  CREATE UNIQUE INDEX "Jd1dta"."UNI_CLNUM" ON "Jd1dta"."ZDMBKPZCLN" ("CLNTNUM") 
 ;   
 
 
 --------------
 