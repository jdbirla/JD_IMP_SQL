---------------------------------------------------------------------------------------
-- File Name	: Insert into IGNAYOSEVIEW , DMPANAYOSEVIEW and DMIGTITNYCLT
-- Description	: Insert into IGNAYOSEVIEW , DMPANAYOSEVIEW and DMIGTITNYCLT
-- Author       : jitendra Birla
---------------------------------------------------------------------------------------


DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"
 /********************************* ******************************************************************
  * Amenment History: CL Nayose Personal Client
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CP1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * JAN12    JDB       NP1   PA New implementation for Nayose
  * NOV16    JDB       NP2   CLTPHONE01 is not mandatory 
  *****************************************************************************************************/

column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo off
set feed off
set termout off


spool "&SQL_LOG_PATH.\PRE_NAYOSE_STEP&log_date_text..txt"


set trimspool on 
set pages 0 
set head off 
set lines 2000 
set serveroutput on
SET VERIFY OFF

set feed on
set echo on
set termout on



--Create backup table before migration 
drop table DM_clntpf_bkp;
create table DM_clntpf_bkp as select * from clntpf;
drop table DM_audit_clntpf_bkp;
create table DM_audit_clntpf_bkp as select * from audit_clntpf;
drop table DM_clexpf_bkp;
create table DM_clexpf_bkp as select * from clexpf;
drop table DM_audit_clexpf_bkp;
create table DM_audit_clexpf_bkp as select * from audit_clexpf;
drop table DM_zclnpf_bkp;
create table DM_zclnpf_bkp as select * from zclnpf;

DECLARE 
  cnt number(2,1) :=0;
   p_exitcode      number;
  p_exittext      varchar2(200);
BEGIN  



---insert record into DMIG table for Client History

DELETE /*+ PARALLEL(DMIGTITDMGCLTRNHIS) */ FROM Jd1dta.DMIGTITDMGCLTRNHIS;
Commit;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGCLTRNHIS 
SELECT RECIDXCLHIS, REFNUM, ZSEQNO, EFFDATE, LSURNAME, LGIVNAME, ZKANAGIVNAME, ZKANASURNAME, ZKANASNMNOR, ZKANAGNMNOR, CLTPCODE, CLTADDR01, CLTADDR02, CLTADDR03, ZKANADDR01, ZKANADDR02, CLTSEX, ADDRTYPE, CLTPHONE01, CLTPHONE02, OCCPCODE, CLTDOB, ZOCCDSC, ZWORKPLCE, ZALTRCDE01, TRANSHIST, ZENDCDE, CLNTROLEFLG,
policystatus,policytype,priorty,
(select min(RECIDXCLHIS) from STAGEDBUSR.TITDMGCLTRNHIS@DMSTAGEDBLINK b where  a.REFNUM= b.REFNUM) AS REFNUMCHUNK
FROM stagedbusr.TITDMGCLTRNHIS@DMSTAGEDBLINK a;
COMMIT;


----Insert SHI clients from IG DB to IGNAYOSEVIEW based on priorty
DELETE /*+ PARALLEL(IGNAYOSEVIEW) */ FROM Jd1dta.IGNAYOSEVIEW;
COMMIT;

INSERT /*+ PARALLEL(IGNAYOSEVIEW,DEFAULT, DEFAULT) */  INTO Jd1dta.IGNAYOSEVIEW (
ZENDCDE,
CLNTNUM,
ZKANASNMNOR,
ZKANAGNMNOR,
CLTSEX,
CLTDOB,
CLTPCODE,
RMBLPHONE,
CHDRNUM,
STATCODE,
ZPLANCLS,
PRIORITY,
ROW_NUM
)
select ZENDCDE,
CLNTNUM,
ZKANASNMNOR,
ZKANAGNMNOR,
CLTSEX,
CLTDOB,
CLTPCODE,
RMBLPHONE,
CHDRNUM,
STATCODE,
ZPLANCLS,
PRIORTY,
row_num
from (
select *
from 
 ( SELECT
    "ZENDCDE",
    "CLNTNUM",
    "ZKANASNMNOR",
    "ZKANAGNMNOR",
    "CLTSEX",
    "CLTDOB",
    "CLTPCODE",
    "RMBLPHONE",
    "CHDRNUM",
    "STATCODE",
    "ZPLANCLS",
    "PRIORTY",
     ROW_NUMBER() OVER(
        PARTITION BY "ZENDCDE", "ZKANASNMNOR", "ZKANAGNMNOR", "CLTSEX", "CLTDOB", "CLTPCODE", "RMBLPHONE"
        ORDER BY
            priorty ASC, clntnum DESC
    ) row_num
FROM
    (
        SELECT
            rtrim(zendcde) AS zendcde,
            rtrim(CL_CLNTNUM) AS CLNTNUM,
            rtrim(zkanasnmnor) AS zkanasnmnor,
            rtrim(zkanagnmnor) AS zkanagnmnor,
            rtrim(cltsex) AS cltsex,
            rtrim(cltdob) AS cltdob,
            rtrim(cltpcode) AS cltpcode,
            --rtrim(rmblphone) AS rmblphone,  --NP2
			NVL(REGEXP_REPLACE(rmblphone,'[^0-9]'),'                ') AS rmblphone,--NP2
            chdrnum,
            statcode,
            zplancls,
            (
                  CASE
                    WHEN ( (statcode = 'IF' or statcode = 'XN')
                           AND zplancls = 'PP' ) THEN
                        '1'
                    WHEN ( (statcode = 'IF' or statcode = 'XN')
                           AND zplancls = 'FP' ) THEN
                        '2'
                    WHEN ( (statcode = 'CA'  or statcode = 'LA')
                           AND zplancls = 'PP' ) THEN
                        '3'
                    WHEN ((statcode = 'CA'  or statcode = 'LA')
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
                    clnt.clntnum CL_CLNTNUM,
                  --  ( regexp_replace(clnt.zkanasnmnor, ' ', '') ) AS zkanasnmnor,
               --     ( regexp_replace(clnt.zkanagnmnor, ' ', '') ) AS zkanagnmnor,
                   clnt.zkanasnmnor AS zkanasnmnor,
                    clnt.zkanagnmnor AS zkanagnmnor,
                    clnt.cltsex,
                    clnt.cltdob,
                    
					 REGEXP_REPLACE(clnt.cltpcode,'[^0-9]')	AS cltpcode,
                    --REGEXP_REPLACE(clex.rmblphone,'[^0-9]')	AS rmblphone  -- NP2
				  NVL(REGEXP_REPLACE(clex.rmblphone,'[^0-9]'),'                ')  	AS rmblphone  -- NP2

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
                 select * from(SELECT
                    gchd.chdrnum,
                    gchd.statcode,
                    gchp.zplancls,
                    gchd.cownnum as POL_CLNTNUM
                   
                FROM
                    gchd     gchd
                    INNER JOIN gchppf   gchp ON gchd.chdrnum = gchp.chdrnum
                    LEFT OUTER JOIN GMHDPF gmhd on gchd.chdrnum =gmhd.chdrnum 
                     UNION 
                    SELECT
                    gchd.chdrnum,
                    gchd.statcode,
                    gchp.zplancls,
                    gmhd.clntnum as POL_CLNTNUM
                    
                FROM
                    gchd     gchd
                    INNER JOIN gchppf   gchp ON gchd.chdrnum = gchp.chdrnum
                    LEFT OUTER JOIN GMHDPF gmhd on gchd.chdrnum =gmhd.chdrnum) 
                    where chdrnum  not in (select polnum from  Jd1dta.pazdrppf )
            ) pol ON cl.CL_CLNTNUM = pol.POL_CLNTNUM
    )
)
WHERE
    row_num = 1);
COMMIT;

----Insert PA clients from IG DB to DMPANAYOSEVIEW based on priorty

Delete /*+ PARALLEL(DMPANAYOSEVIEW) */ from Jd1dta.DMPANAYOSEVIEW;
COMMIT;
INSERT /*+ PARALLEL(DMPANAYOSEVIEW,DEFAULT, DEFAULT) */ INTO Jd1dta.DMPANAYOSEVIEW (
ZENDCDE,
CLNTNUM,
ZKANASNMNOR,
ZKANAGNMNOR,
CLTSEX,
CLTDOB,
CLTPCODE,
RMBLPHONE,
CHDRNUM,
STATCODE,
ZPLANCLS,
PRIORITY,
ROW_NUM
)
select ZENDCDE,
CLNTNUM,
ZKANASNMNOR,
ZKANAGNMNOR,
CLTSEX,
CLTDOB,
CLTPCODE,
RMBLPHONE,
CHDRNUM,
STATCODE,
ZPLANCLS,
PRIORTY,
row_num
from (
select *
from 
 ( SELECT
    "ZENDCDE",
    "CLNTNUM",
    "ZKANASNMNOR",
    "ZKANAGNMNOR",
    "CLTSEX",
    "CLTDOB",
    "CLTPCODE",
    "RMBLPHONE",
    "CHDRNUM",
    "STATCODE",
    "ZPLANCLS",
    "PRIORTY",
     ROW_NUMBER() OVER(
        PARTITION BY "ZENDCDE", "ZKANASNMNOR", "ZKANAGNMNOR", "CLTSEX", "CLTDOB", "CLTPCODE", "RMBLPHONE"
        ORDER BY
            priorty ASC, clntnum DESC
    ) row_num
FROM
    (
        SELECT
            rtrim(zendcde) AS zendcde,
            rtrim(CL_CLNTNUM) AS CLNTNUM,
            rtrim(zkanasnmnor) AS zkanasnmnor,
            rtrim(zkanagnmnor) AS zkanagnmnor,
            rtrim(cltsex) AS cltsex,
            rtrim(cltdob) AS cltdob,
            rtrim(cltpcode) AS cltpcode,
            --rtrim(rmblphone) AS rmblphone,   --NP2
			NVL(rmblphone,'                ') AS rmblphone,  --NP2
            chdrnum,
            statcode,
            zplancls,
            (
                  CASE
                    WHEN ( (statcode = 'IF' or statcode = 'XN')
                           AND zplancls = 'PP' ) THEN
                        '1'
                    WHEN ( (statcode = 'IF' or statcode = 'XN')
                           AND zplancls = 'FP' ) THEN
                        '2'
                    WHEN ( (statcode = 'CA'  or statcode = 'LA')
                           AND zplancls = 'PP' ) THEN
                        '3'
                    WHEN ((statcode = 'CA'  or statcode = 'LA')
                           AND zplancls = 'FP' ) THEN
                        '4'
                    ELSE
                        '9'
                END
            ) AS priorty
        FROM
            
            (
                 select * from(SELECT
                  /*+ PARALLEL(gchd ,DEFAULT, DEFAULT) PARALLEL(gchppf ,DEFAULT, DEFAULT) PARALLEL(GMHDPF ,DEFAULT, DEFAULT)*/
                    gchd.chdrnum,
                    gchd.statcode,
                    gchp.zplancls,
                    gchd.cownnum as POL_CLNTNUM
                   
                FROM
                    gchd     gchd
                    INNER JOIN gchppf   gchp ON gchd.chdrnum = gchp.chdrnum
                    LEFT OUTER JOIN GMHDPF gmhd on gchd.chdrnum =gmhd.chdrnum 
                     UNION 
                    SELECT
                    gchd.chdrnum,
                    gchd.statcode,
                    gchp.zplancls,
                    gmhd.clntnum as POL_CLNTNUM
                    
                FROM
                    gchd     gchd
                    INNER JOIN gchppf   gchp ON gchd.chdrnum = gchp.chdrnum
                    LEFT OUTER JOIN GMHDPF gmhd on gchd.chdrnum =gmhd.chdrnum) B
                    where   exists  (select 1 from  Jd1dta.pazdrppf A where A.polnum=B.chdrnum)
                  and exists  (select 1 from  Jd1dta.pazdnypf C where C.ZIGVALUE=B.POL_CLNTNUM and C.DM_OR_IG = 'DMPA')
            ) pol
             INNER JOIN
            (
                 SELECT
                 /*+ PARALLEL(clntpf ,DEFAULT, DEFAULT) PARALLEL(zcelinkpf ,DEFAULT, DEFAULT) PARALLEL(clexpf ,DEFAULT, DEFAULT)*/
                    zcel.zendcde,
                    clnt.clntnum CL_CLNTNUM,
                  --  ( regexp_replace(clnt.zkanasnmnor, ' ', '') ) AS zkanasnmnor,
               --     ( regexp_replace(clnt.zkanagnmnor, ' ', '') ) AS zkanagnmnor,
                   clnt.zkanasnmnor AS zkanasnmnor,
                    clnt.zkanagnmnor AS zkanagnmnor,
                    clnt.cltsex,
                    clnt.cltdob,
					 REGEXP_REPLACE(clnt.cltpcode,'[^0-9]')	AS cltpcode,
					--REGEXP_REPLACE(clex.rmblphone,'[^0-9]')	AS rmblphone    --NP2
					NVL(REGEXP_REPLACE(clex.rmblphone,'[^0-9]'),'                ') AS rmblphone
                FROM
                    (select * from Jd1dta.clntpf  WHERE
                    validflag = 1
                    AND clttype = 'P')      clnt
                    INNER JOIN Jd1dta.zcelinkpf   zcel ON zcel.clntnum = clnt.clntnum
                    left outer
                    JOIN Jd1dta.clexpf clex ON clex.clntnum = clnt.clntnum
               
            ) cl
             ON cl.CL_CLNTNUM = pol.POL_CLNTNUM
    )
)
WHERE
    row_num = 1);
COMMIT;


---Search into IGNAYOSEVIEW and then DMPANAYOSEVIEW and get the client and status

DELETE /*+ PARALLEL(DMIGTITNYCLT) */ FROM Jd1dta.DMIGTITNYCLT;
COMMIT;
INSERT /*+ PARALLEL(DMIGTITNYCLT,DEFAULT, DEFAULT) */  INTO Jd1dta.DMIGTITNYCLT (
REFNUM,
DM_OR_IG,
CLNTSTAS,
IS_UPDATE_REQ,
IG_CLNTNUM,
DCH_ZENDCDE,
DCH_ZKANASNMNOR,
DCH_ZKANAGNMNOR,
DCH_CLTDOB,
DCH_CLTPCODE,
DCH_CLTSEX,
DCH_CLTPHONE01,
DCH_PRIORITY,
NV_PRIORITY
   )
WITH igdata AS (
SELECT
        *
    FROM
        (
            SELECT
           /*+ PARALLEL(dmigtitdmgcltrnhis ,DEFAULT, DEFAULT) PARALLEL(ignayoseview ,DEFAULT, DEFAULT)*/
                refnum,
                nvl2(ig_clntnum, 'IG', 'ST') dm_or_ig,
                nvl2(ig_clntnum, 'EX', 'ST') clntstas,
                nvl2(ig_clntnum, 'N', 'ST') is_update_req,
                ig_clntnum,
                dch_zendcde,
                dch_zkanasnmnor,
                dch_zkanagnmnor,
                dch_cltdob,
                dch_cltpcode,
                dch_cltsex,
                dch_cltphone01,
                dch_priority,
                nv_priority
            FROM
                (
                    SELECT
                        dch.refnum,
                        rtrim(dch.zendcde) AS dch_zendcde,
                        rtrim((regexp_replace(dch.zkanasnmnor, ' ', ''))) AS dch_zkanasnmnor,
                    rtrim((regexp_replace(dch.zkanagnmnor, ' ', ''))) AS dch_zkanagnmnor
                        ,
                        rtrim(dch.cltdob) AS dch_cltdob,
                        regexp_replace(dch.cltpcode, '[^0-9]') AS dch_cltpcode,
                        rtrim(dch.cltsex) AS dch_cltsex,
                      --  regexp_replace(dch.cltphone01, '[^0-9]') AS dch_cltphone01,  --NP2
						NVL(regexp_replace(dch.cltphone01, '[^0-9]') ,'                ') AS dch_cltphone01,  --NP2
                        dch.priorty      dch_priority,
                        nv.clntnum       AS ig_clntnum,
                        rtrim(nv.zendcde) AS ig_zendcde,
                        nv.zkanasnmnor   AS ig_zkanasnmnor,
                        nv.zkanagnmnor   AS ig_zkanagnmnor,
                        nv.cltdob        AS ig_cltdob,
                        regexp_replace(nv.cltpcode, '[^0-9]') AS ig_cltpcode,
                        nv.cltsex        AS ig_cltsex,
                        -- regexp_replace(nv.rmblphone, '[^0-9]') AS ig_rmblphone,  --NP2
						NVL(regexp_replace(nv.rmblphone, '[^0-9]') ,'                ') AS ig_rmblphone, --NP2
                        nv.priority      nv_priority
                    FROM
                        (
                            SELECT
                                *
                            FROM
                                Jd1dta.dmigtitdmgcltrnhis
                            WHERE
                                transhist = '1'
                        ) dch
                        LEFT OUTER JOIN ignayoseview nv ON rtrim(nv.zendcde) = rtrim(dch.zendcde)
                                                           AND rtrim((regexp_replace(nv.zkanasnmnor, ' ', ''))) = rtrim((regexp_replace
                                                           (dch.zkanasnmnor, ' ', '')))
                                                           AND rtrim((regexp_replace(nv.zkanagnmnor, ' ', ''))) = rtrim((regexp_replace
                                                           (dch.zkanagnmnor, ' ', '')))
                                                           AND nv.cltdob = dch.cltdob
                                                           AND nv.cltsex = dch.cltsex
                                                           AND regexp_replace(nv.cltpcode, '[^0-9]') = regexp_replace(dch.cltpcode, '[^0-9]')
                                                          -- AND regexp_replace(nv.rmblphone, '[^0-9]') = regexp_replace(dch.cltphone01, '[^0-9]')  --NP2
														  AND NVL(REGEXP_REPLACE(nv.rmblphone,'[^0-9]'),'                ')= NVL(regexp_replace(dch.cltphone01, '[^0-9]'),'                ')  --NP2
                )
        )
), dmpadata AS (
    SELECT
        *
    FROM
        (
                  /*+ PARALLEL(dmigtitdmgcltrnhis ,DEFAULT, DEFAULT) PARALLEL(dmpanayoseview ,DEFAULT, DEFAULT)*/
            SELECT
                refnum,
                'DMPA' AS dm_or_ig,
                nvl2(ig_clntnum, 'EX', 'NW') clntstas,
                (
                    CASE
                        WHEN ( dch_priority < nv_priority ) THEN
                            'Y'
                        WHEN ( dch_priority > nv_priority ) THEN
                            'N'
                        ELSE
                            'N'
                    END
                ) AS is_update_req,
                dch_priority,
                nv_priority,
                ig_clntnum,
                dch_zendcde,
                dch_zkanasnmnor,
                dch_zkanagnmnor,
                dch_cltdob,
                dch_cltpcode,
                dch_cltsex,
                dch_cltphone01
            FROM
                (
                    SELECT
                        dch.refnum,
                        rtrim(dch.zendcde) AS dch_zendcde,
                        rtrim((regexp_replace(dch.zkanasnmnor, ' ', ''))) AS dch_zkanasnmnor,
                        rtrim((regexp_replace(dch.zkanagnmnor, ' ', ''))) AS dch_zkanagnmnor,
                        rtrim(dch.cltdob) AS dch_cltdob,
                        regexp_replace(dch.cltpcode, '[^0-9]') AS dch_cltpcode,
                        rtrim(dch.cltsex) AS dch_cltsex,
                        -- regexp_replace(dch.cltphone01, '[^0-9]') AS dch_cltphone01,
						NVL(regexp_replace(dch.cltphone01, '[^0-9]'),'                ') AS dch_cltphone01,  --NP2
                        dch.priorty      dch_priority,
                        nv.clntnum       AS ig_clntnum,
                        rtrim(nv.zendcde) AS ig_zendcde,
                        nv.zkanasnmnor   AS ig_zkanasnmnor,
                        nv.zkanagnmnor   AS ig_zkanagnmnor,
                        nv.cltdob        AS ig_cltdob,
                        regexp_replace(nv.cltpcode, '[^0-9]') AS ig_cltpcode,
                        nv.cltsex        AS ig_cltsex,
                       -- regexp_replace(nv.rmblphone, '[^0-9]') AS ig_rmblphone,
						NVL(regexp_replace(nv.rmblphone, '[^0-9]'),'                ') AS ig_rmblphone,  --NP2
                        nv.priority      nv_priority
                    FROM
                        (
                            SELECT
                                *
                            FROM
                                Jd1dta.dmigtitdmgcltrnhis
                            WHERE
                                transhist = '1'
                        ) dch
                        LEFT OUTER JOIN dmpanayoseview nv ON rtrim(nv.zendcde) = rtrim(dch.zendcde)
                                                             AND rtrim((regexp_replace(nv.zkanasnmnor, ' ', ''))) = rtrim((regexp_replace
                                                             (dch.zkanasnmnor, ' ', '')))
                                                             AND rtrim((regexp_replace(nv.zkanagnmnor, ' ', ''))) = rtrim((regexp_replace
                                                             (dch.zkanagnmnor, ' ', '')))
                                                             AND nv.cltdob = rtrim(dch.cltdob)
                                                             AND nv.cltsex = rtrim(dch.cltsex)
                                                             AND regexp_replace(nv.cltpcode, '[^0-9]') = regexp_replace(dch.cltpcode
                                                             , '[^0-9]')
                                                             --AND regexp_replace(nv.rmblphone, '[^0-9]') = regexp_replace(dch.cltphone01, '[^0-9]')   --NP2
															  AND NVL(REGEXP_REPLACE(nv.rmblphone,'[^0-9]'),'                ')= NVL(regexp_replace(dch.cltphone01, '[^0-9]'),'                ')  --NP2
                )
        )
)
SELECT
    ig.refnum AS refnum,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dm_or_ig
            ELSE
                dm.dm_or_ig
        END
    ) AS dm_or_ig,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG'
                   AND ig.clntstas = 'EX' ) THEN
                ig.clntstas
            ELSE
                dm.clntstas
        END
    ) AS clntstas,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG'
                   AND ig.clntstas = 'N' ) THEN
                ig.is_update_req
            ELSE
                dm.is_update_req
        END
    ) AS is_update_req,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.ig_clntnum
            ELSE
                dm.ig_clntnum
        END
    ) AS ig_clntnum,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dch_zendcde
            ELSE
                dm.dch_zendcde
        END
    ) AS dch_zendcde,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dch_zkanasnmnor
            ELSE
                dm.dch_zkanasnmnor
        END
    ) AS dch_zkanasnmnor,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dch_zkanagnmnor
            ELSE
                dm.dch_zkanagnmnor
        END
    ) AS dch_zkanagnmnor,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dch_cltdob
            ELSE
                dm.dch_cltdob
        END
    ) AS dch_cltdob,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dch_cltpcode
            ELSE
                dm.dch_cltpcode
        END
    ) AS dch_cltpcode,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dch_cltsex
            ELSE
                dm.dch_cltsex
        END
    ) AS dch_cltsex,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dch_cltphone01
            ELSE
                dm.dch_cltphone01
        END
    ) AS dch_cltphone01,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.dch_priority
            ELSE
                dm.dch_priority
        END
    ) AS dch_priority,
    (
        CASE
            WHEN ( ig.dm_or_ig = 'IG' ) THEN
                ig.nv_priority
            ELSE
                dm.nv_priority
        END
    ) AS nv_priority
FROM
    igdata     ig
    INNER JOIN dmpadata   dm ON ig.refnum = dm.refnum
ORDER BY
    ig.refnum;
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'PRE_NAYOSE_STEP : ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
  
    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      ('G1ZDNAYCLT', 000, p_exitcode, p_exittext, sysdate);
    commit;
     raise;

COMMIT;
  
END;

/
