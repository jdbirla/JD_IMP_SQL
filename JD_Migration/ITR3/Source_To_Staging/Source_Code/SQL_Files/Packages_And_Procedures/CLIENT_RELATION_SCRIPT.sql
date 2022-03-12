set head on
set echo on
set feed on
set termout on
set NUMWIDTH 10
set AUTOCOMMIT OFF
spool 'H:\SIT_STAGE_DATA\Phase-2\ITR3_FT\Dev\SEARCH_POL\CLINT_RELATIONSHIP.csv';

delete from CLNT_RELATION;
insert into CLNT_RELATION  (select A.*,b.apc6cd,b.APA2DT, b.APBEDT, b.APEVST,b.APBLST from 
(SELECT iscucd,  iscicd,  isa4st
FROM zmris00 
WHERE ISCICD IN
  (SELECT ISCICD FROM
    (SELECT (SUBSTR(ISCICD, 1,8) || SUBSTR(ISCICD, -2)) AS Policy_Insured,
      ISCICD,
      ISA4ST
    FROM zmris00
    WHERE (SUBSTR(ISCICD, 1,8)|| SUBSTR(ISCICD, -2)) IN
      (SELECT a FROM
          (SELECT a, COUNT(b)
               FROM
                ( SELECT DISTINCT SUBSTR(ISCICD, 1,8) || SUBSTR(ISCICD, -2) AS a, ISA4ST AS b
                    FROM stagedbusr2.zmris00 )
            GROUP BY a
            HAVING COUNT(b) > 1
        )
      )
    )
  ))A inner join zmrap00 B on A.iscucd = B.APCUCD);
  Commit;

select * from ASRF_RNW_DTRM where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from ASRF_RNW_INTERMEDIATE where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from BTDATE_PTDATE_LIST where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from DMPR where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from DMPR1 where REFNUM in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from DPNTNO_TABLE where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from MAXPOLNUM where APCUCD in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from MEM_IND_POLHIST_SSPLAN_INTRMDT where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from MEMPOL where REFNO in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from MIPHSTDB where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from PERSNL_CLNT_FLG where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from PJ_TITDMGCOLRES where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from POLICY_STATCODE where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from RENEW_AS_IS where APCUCD in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from RND_COVERAGE_TABLE where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from SOURCE_COVERAGE_RESULTS where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from SRCNAYOSETBL where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGAPIRNO where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGAPIRNO_LOG where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGBILL1 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGBILL2 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGCLNTBANK  where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGCLNTMAP  where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGCLTRNHIS  where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGCLTRNHIS_INT  where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGCOLRES where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGLETTER where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGMBRINDP1 where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGMBRINDP2 where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGMBRINDP3 where OLDPOLNUM in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGPOLTRNH where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGREF1 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGREF2 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGRNWDT1 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TITDMGRNWDT2 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from TRANNOTBL where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from ZMRAP00 where  SUBSTR(APCUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from ZMREI00 where  SUBSTR(EICUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from ZMRIC00 where  SUBSTR(ICCUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from ZMRIS00 where  SUBSTR(ISCUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from ZMRISA00 where  SUBSTR(ISACUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
select * from ZMRLH00 where  SUBSTR(LHCUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );

/*Check selected record and exract data from CLNT_RELATION table for Z-BIZ and get the confirmation and then delete the records from below table
Delete from ASRF_RNW_DTRM where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from ASRF_RNW_INTERMEDIATE where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from BTDATE_PTDATE_LIST where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from DMPR where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from DMPR1 where REFNUM in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from DPNTNO_TABLE where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from MAXPOLNUM where APCUCD in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from MEM_IND_POLHIST_SSPLAN_INTRMDT where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from MEMPOL where REFNO in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from MIPHSTDB where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from PERSNL_CLNT_FLG where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from PJ_TITDMGCOLRES where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from POLICY_STATCODE where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from RENEW_AS_IS where APCUCD in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from RND_COVERAGE_TABLE where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from SOURCE_COVERAGE_RESULTS where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from SRCNAYOSETBL where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGAPIRNO where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGAPIRNO_LOG where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGBILL1 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGBILL2 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGCLNTBANK  where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGCLNTMAP  where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGCLTRNHIS  where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGCLTRNHIS_INT  where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGCOLRES where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGLETTER where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGMBRINDP1 where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGMBRINDP2 where SUBSTR(REFNUM,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGMBRINDP3 where OLDPOLNUM in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGPOLTRNH where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGREF1 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGREF2 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGRNWDT1 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TITDMGRNWDT2 where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from TRANNOTBL where chdrnum in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from ZMRAP00 where  SUBSTR(APCUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from ZMREI00 where  SUBSTR(EICUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from ZMRIC00 where  SUBSTR(ICCUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from ZMRIS00 where  SUBSTR(ISCUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from ZMRISA00 where  SUBSTR(ISACUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
Delete from ZMRLH00 where  SUBSTR(LHCUCD,1,8) in ( select substr(ISCUCD,1,8) from CLNT_RELATION  );
*/
spool off;
