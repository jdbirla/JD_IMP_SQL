---------------------------------------------------------------------------------------
-- File Name	: Insert into DMIGTITNYCLT
-- Description	: Insert into DMIGTITNYCLT
-- Author       : jbirla
---------------------------------------------------------------------------------------


DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"


column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo on
set feed off
set termout off


spool "&SQL_LOG_PATH.\INSRT_INTO_DMIGTITNYCLT&log_date_text..txt"


DECLARE 
  cnt number(2,1) :=0;
BEGIN  

DELETE FROM Jd1dta.DMIGTITNYCLT;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITNYCLT (refnum, ig_clntnum,
                   dch_zendcde,
                   dch_zkanasnmnor,
                   dch_zkanagnmnor,
                   dch_cltdob,
                   dch_cltpcode,
                   dch_cltsex,
                   dch_cltphone01)
select *
      from (SELECT refnum,
                   nvl(ig_clntnum,'NEWCLNT')ig_clntnum,
                   dch_zendcde,
                   dch_zkanasnmnor,
                   dch_zkanagnmnor,
                   dch_cltdob,
                   dch_cltpcode,
                   dch_cltsex,
                   dch_cltphone01
              FROM (SELECT dch.refnum,
                           rtrim(dch.zendcde) AS dch_zendcde,
                           rtrim((regexp_replace(dch.zkanasnmnor, ' ', ''))) AS dch_zkanasnmnor,
                           rtrim((regexp_replace(dch.zkanagnmnor, ' ', ''))) AS dch_zkanagnmnor,
                           rtrim(dch.cltdob) AS dch_cltdob,
                           rtrim(dch.cltpcode) AS dch_cltpcode,
                           rtrim(dch.cltsex) AS dch_cltsex,
                           replace(rtrim(dch.cltphone01), '-') AS dch_cltphone01,
                           nv.clntnum AS ig_clntnum,
                           rtrim(nv.zendcde) AS ig_zendcde,
                           nv.zkanasnmnor AS ig_zkanasnmnor,
                           nv.zkanagnmnor AS ig_zkanagnmnor,
                           nv.cltdob AS ig_cltdob,
                           nv.cltpcode AS ig_cltpcode,
                           nv.cltsex AS ig_cltsex,
                           nv.rmblphone AS ig_rmblphone
                      FROM (SELECT *
                              FROM Jd1dta.dmigtitdmgcltrnhis
                             WHERE transhist = '1') dch
                      LEFT OUTER JOIN dmviewnayose nv
                        ON rtrim(nv.zendcde) = rtrim(dch.zendcde)
                       AND nv.zkanasnmnor =
                           rtrim((regexp_replace(dch.zkanasnmnor, ' ', '')))
                       AND nv.zkanagnmnor =
                           rtrim((regexp_replace(dch.zkanagnmnor, ' ', '')))
                       AND nv.cltdob = rtrim(dch.cltdob)
                       AND nv.cltsex = rtrim(dch.cltsex)
                       AND nv.cltpcode = rtrim(dch.cltpcode)
                       AND nv.rmblphone = replace(rtrim(dch.cltphone01), '-'))
            );

  
END;
/
