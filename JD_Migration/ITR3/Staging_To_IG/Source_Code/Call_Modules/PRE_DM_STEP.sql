 ---------------------------------------------------------------------------------------
-- File Name	: PRE_DM_STEP.sql
-- Description	: Insert into all DMIGTIT* tables
-- Author       : Jitendra Birla
---------------------------------------------------------------------------------------


DEFINE SQL_LOG_PATH = "C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Execution\Logs"


column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo off
set feed off
set termout off


spool "&SQL_LOG_PATH.\PRE_DM_STEP&log_date_text..txt"


set trimspool on 
set pages 0 
set head off 
set lines 2000 
set serveroutput on
SET VERIFY OFF

set feed on
set echo on
set termout on



DECLARE 
  cnt number(2,1) :=0;
   p_exitcode      number;
  p_exittext      varchar2(200);
  TAB_NAME  varchar2(200);
  ROW_COUNT number;
    v_sqlQuery2       VARCHAR2(500);
	SCHEDULE_NAME VARCHAR2(200 CHAR) := '&1';

BEGIN  

dbms_output.put_line('******************DMIGTIT* table insertion : START******************************');

---------CORPORATE_CLEINT:START------------------
IF(SCHEDULE_NAME='G1ZDCOPCLT')THEN
v_sqlQuery2 := 'select ''TITDMGCLNTCORP'' ,count(*)  from stagedbusr.TITDMGCLNTCORP@DMSTAGEDBLINK';
EXECUTE IMMEDIATE v_sqlQuery2
into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='TITDMGCLNTCORP';
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'TITDMGCLNTCORP' ,count(*)  from stagedbusr.TITDMGCLNTCORP@DMSTAGEDBLINK;
COMMIT;

END IF;
---------CORPORATE_CLEINT:END----------------------


---------AGENCY:START------------------
IF(SCHEDULE_NAME='G1ZDAGENCY')THEN
delete from Jd1dta.DMIGTITDMGAGENTPJ;
COMMIT;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGAGENTPJ SELECT * FROM stagedbusr.TITDMGAGENTPJ@DMSTAGEDBLINK;
COMMIT;

 v_sqlQuery2 := 'select ''DMIGTITDMGAGENTPJ'' ,count(*)  from Jd1dta.DMIGTITDMGAGENTPJ';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGAGENTPJ';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGAGENTPJ' ,count(*)  from Jd1dta.DMIGTITDMGAGENTPJ;
COMMIT;

END IF;
---------AGENCY:END----------------------


---------Master_Policy:START------------------
IF(SCHEDULE_NAME='G1ZDMSTPOL')THEN
v_sqlQuery2 := 'select ''TITDMGMASPOL'' ,count(*)  from stagedbusr.TITDMGMASPOL@DMSTAGEDBLINK';
EXECUTE IMMEDIATE v_sqlQuery2
into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

v_sqlQuery2 := 'select ''TITDMGINSSTPL'' ,count(*)  from stagedbusr.TITDMGINSSTPL@DMSTAGEDBLINK';
EXECUTE IMMEDIATE v_sqlQuery2
into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

v_sqlQuery2 := 'select ''TITDMGENDCTPF'' ,count(*)  from stagedbusr.TITDMGENDCTPF@DMSTAGEDBLINK';
EXECUTE IMMEDIATE v_sqlQuery2
into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='TITDMGMASPOL';
delete from DM2_DMIG_DATA_CNT where TAB_NAME='TITDMGINSSTPL';
delete from DM2_DMIG_DATA_CNT where TAB_NAME='TITDMGENDCTPF';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'TITDMGMASPOL' ,count(*)  from stagedbusr.TITDMGMASPOL@DMSTAGEDBLINK;
COMMIT;

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'TITDMGINSSTPL' ,count(*)  from stagedbusr.TITDMGINSSTPL@DMSTAGEDBLINK;
COMMIT;

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'TITDMGENDCTPF' ,count(*)  from stagedbusr.TITDMGENDCTPF@DMSTAGEDBLINK;
COMMIT;

END IF;

---------Master_Policy:END----------------------



---------CAMP:START------------------
IF(SCHEDULE_NAME='G1ZDCAMPCD')THEN



DELETE FROM Jd1dta.DMIGTITDMGCAMPCDE;
COMMIT;
INSERT /*+ APPEND*/ INTO Jd1dta.DMIGTITDMGCAMPCDE
 SELECT RECIDXCAMP, ZCMPCODE, ZPETNAME, ZPOLCLS, ZENDCODE, CHDRNUM, GPOLTYP, ZAGPTID, RCDATE, ZCMPFRM, ZCMPTO, ZMAILDAT, ZACLSDAT, 
        ZDLVCDDT, ZVEHICLE, ZSTAGE, ZSCHEME01, ZSCHEME02, ZCRTUSR, ZAPPDATE, ZCCODIND, EFFDATE, STATUS, GC_CHDRNUM, ZEN_ZENDCDE, ZAGPTNUM
 FROM (
   SELECT cmp.*, 
   gc.chdrnum gc_chdrnum,
   zn.zendcde zen_zendcde,
   za.zagptnum 
   FROM STAGEDBUSR.TITDMGCAMPCDE@DMSTAGEDBLINK cmp
   LEFT OUTER JOIN Jd1dta.gchd    gc ON gc.chdrnum = cmp.chdrnum AND TRIM(gc.chdrpfx) = TRIM('CH') AND TRIM(gc.chdrcoy) = TRIM('1')
   LEFT OUTER JOIN Jd1dta.zendrpf zn ON TRIM(zn.zendcde) = TRIM(cmp.zendcode)
   LEFT OUTER JOIN Jd1dta.zagppf  za ON TRIM(za.zagptpfx) = TRIM('AP') AND TRIM(za.zagptnum) = TRIM(cmp.zagptid) AND TRIM(za.zagptcoy) = 1 AND TRIM(za.validflag) = TRIM('1')
 )ORDER BY RECIDXCAMP;
COMMIT;

DELETE FROM Jd1dta.DMIGTITDMGZCSLPF;
COMMIT;
INSERT /*+ APPEND*/ INTO Jd1dta.DMIGTITDMGZCSLPF
 SELECT a.RECIDXSLPL2, a.ZCMPCODE, a.OLD_ZSALPLAN, a.ZSALPLAN,
  zs.zsalplan zsl_zsalplan,
  NVL((select recidxcamp from Jd1dta.dmigtitdmgcampcde b where a.zcmpcode = b.zcmpcode), (select MAX(recidxcamp) from Jd1dta.dmigtitdmgcampcde)) RECCHUNKNUM
 FROM stagedbusr.titdmgzcslpf@DMSTAGEDBLINK a
 LEFT OUTER JOIN (select distinct zsalplan from Jd1dta.zslppf) zs ON TRIM(zs.zsalplan) = TRIM(a.zsalplan);
COMMIT;    

v_sqlQuery2 := 'select ''DMIGTITDMGCAMPCDE'' ,count(*)  from Jd1dta.DMIGTITDMGCAMPCDE';
EXECUTE IMMEDIATE v_sqlQuery2
into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

v_sqlQuery2 := 'select ''DMIGTITDMGZCSLPF'' ,count(*)  from Jd1dta.DMIGTITDMGZCSLPF';
EXECUTE IMMEDIATE v_sqlQuery2
into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGCAMPCDE';
COMMIT;
delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGZCSLPF';
COMMIT;
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGCAMPCDE' ,count(*)  from Jd1dta.DMIGTITDMGCAMPCDE;
COMMIT;

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGZCSLPF' ,count(*)  from Jd1dta.DMIGTITDMGZCSLPF;
COMMIT;

END IF;
---------CAMP:END----------------------


---------NAYOSE_AND_PERSONAL_CLIENT:START------------------
IF(SCHEDULE_NAME='G1ZDNAYCLT')THEN
 v_sqlQuery2 := 'select ''DMIGTITDMGCLTRNHIS'' ,count(*)  from Jd1dta.DMIGTITDMGCLTRNHIS';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGCLTRNHIS' ,count(*)  from Jd1dta.DMIGTITDMGCLTRNHIS;

COMMIT;

v_sqlQuery2 := 'select ''DMIGTITNYCLT'' ,count(*)  from Jd1dta.DMIGTITNYCLT';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );
delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITNYCLT';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITNYCLT' ,count(*)  from Jd1dta.DMIGTITNYCLT;
COMMIT;
END IF;
---------NAYOSE_AND_PERSONAL_CLIENT:END------------------


---------CLIENT_BANK:START------------------
IF(SCHEDULE_NAME='G1ZDCLTBNK')THEN

DELETE FROM Jd1dta.DMIGTITDMGCLNTBANK;
COMMIT;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGCLNTBANK
SELECT RECIDXCLBK, REFNUM, SEQNO, CURRTO, BANKCD, BRANCHCD, FACTHOUS, BANKACCKEY, CRDTCARD, BANKACCDSC, BNKACTYP, TRANSHIST, BANKKEY, ZENTITY, ZIGVALUE, CLB_CLNTNUM
FROM (
  select tit.*, ba.bankkey, cl.zentity , cl.zigvalue, clb.clntnum clb_clntnum
  from stagedbusr.titdmgclntbank@DMSTAGEDBLINK tit
  left outer join Jd1dta.babrpf   ba ON ba.bankkey = (tit.bankcd || '   ' || tit.branchcd)
  left outer join Jd1dta.pazdclpf cl ON cl.zentity = tit.refnum AND cl.prefix = 'CP'
  left outer join Jd1dta.CLBAPF clb ON  clb.clntnum = cl.zigvalue AND RTRIM(clb.BANKKEY) = (tit.bankcd || '   ' || tit.branchcd)
    AND RTRIM(clb.BANKACCKEY) = (TRIM(tit.BANKACCKEY) || TRIM(tit.CRDTCARD))
   AND clb.Clntpfx = 'CN' AND CLNTCOY=9 and clb.validflag = 1  
)
order by RECIDXCLBK;

COMMIT;


 v_sqlQuery2 := 'select ''DMIGTITDMGCLNTBANK'' ,count(*)  from Jd1dta.DMIGTITDMGCLNTBANK';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );
delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGCLNTBANK';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGCLNTBANK' ,count(*)  from Jd1dta.DMIGTITDMGCLNTBANK;
COMMIT;

END IF;
---------CLIENT_BANK:END----------------------


---------MEM_IND_POL:START------------------
IF(SCHEDULE_NAME='G1ZDMBRIND')THEN
delete from Jd1dta.DMIGTITDMGMBRINDP1;
COMMIT;
INSERT /*+ APPEND */ INTO  Jd1dta.DMIGTITDMGMBRINDP1  
	SELECT  
    RECIDXMBINP1, CLIENT_CATEGORY, REFNUM, MBRNO, ZINSROLE, TRANNOMIN,TRANNONBRN,TRANNOMAX, CLIENTNO, OCCDATE, GPOLTYPE, ZENDCDE, ZCMPCODE, MPOLNUM, EFFDATE, ZPOLPERD, ZMARGNFLG, ZDFCNCY, DOCRCVDT, HPROPDTE, ZTRXSTAT, ZSTATRESN, ZANNCLDT, ZCPNSCDE02, ZSALECHNL, ZSOLCTFLG, CLTRELN, ZPLANCDE, CRDTCARD, PREAUTNO, BNKACCKEY01, ZENSPCD01, ZENSPCD02, ZCIFCODE, DTETRM, CRDATE, CNTTYPIND, PTDATE, BTDATE, STATCODE, ZWAITPEDT, ZCONVINDPOL, ZPOLTDATE, OLDPOLNUM, ZPGPFRDT, ZPGPTODT, SINSTNO, TREFNUM, ENDSERCD, ISSDATE, ZPDATATXFLG, ZRWNLAGE, ZNBMNAGE, TERMAGE, ZBLNKPOL, PLNCLASS,ZRNWCNT,ZLAPTRX,PERIOD_NO,TOTAL_PERIOD_COUNT,LAST_TRXS,
		(select min(RECIDXMBINP1) from STAGEDBUSR.TITDMGMBRINDP1@DMSTAGEDBLINK b where  substr(a.REFNUM,1,8)= substr(b.REFNUM,1,8)) AS REFNUMCHUNK,SUBSTR(REFNUM,1,8)
	FROM  STAGEDBUSR.TITDMGMBRINDP1@DMSTAGEDBLINK a; 
COMMIT;

 v_sqlQuery2 := 'select ''DMIGTITDMGMBRINDP1'' ,count(*)  from Jd1dta.DMIGTITDMGMBRINDP1';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );


delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGMBRINDP1';
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGMBRINDP1' ,count(*)  from Jd1dta.DMIGTITDMGMBRINDP1;
COMMIT;

END IF;
---------MEM_IND_POL:END----------------------


---------POL_HIS:START------------------
  IF(SCHEDULE_NAME='G1ZDPOLHST')THEN
DELETE FROM Jd1dta.DM_TEMP_POLHIST;
COMMIT;

INSERT /*+ APPEND */ INTO Jd1dta.DM_TEMP_POLHIST
SELECT RECIDXPHIST, CHDRNUM, ZSEQNO, EFFDATE, CLIENT_CATEGORY, MBRNO, CLTRELN, ZINSROLE, CLIENTNO, ZALTREGDAT, ZALTRCDE01, ZINHDSCLM, ZUWREJFLG, ZSTOPBPJ, ZTRXSTAT, ZSTATRESN, ZACLSDAT, APPRDTE, ZPDATATXDTE, ZPDATATXFLG, 
      ZREFUNDAM, ZPAYINREQ, CRDTCARD, PREAUTNO, BNKACCKEY01, ZENSPCD01, ZENSPCD02, ZCIFCODE, ZDDREQNO, ZWORKPLCE2, BANKACCDSC01, BANKKEY, BNKACTYP01, CURRTO, B1_ZKNJFULNM, B2_ZKNJFULNM, B3_ZKNJFULNM, B4_ZKNJFULNM, B5_ZKNJFULNM, 
      B1_CLTADDR01, B2_CLTADDR01, B3_CLTADDR01, B4_CLTADDR01, B5_CLTADDR01, B1_BNYPC, B2_BNYPC, B3_BNYPC, B4_BNYPC, B5_BNYPC, B1_BNYRLN, B2_BNYRLN, B3_BNYRLN, B4_BNYRLN, B5_BNYRLN, ZSOLCTFLG, ZPLANCDE, ZCMPCODE, ZCPNSCDE, ZSALECHNL, 
      TRANCDE, TRANNO, MINTRANNO, BTDATE, INTREFUND, RECCHUNKSNUM, CCDATE, CRDATE, ZPOLPERD, AGNTNUM, STATCODE, COWNNUM, TRANLUSED, BTDATE_GCHD, EFFDCLDT, OCCDATE, UNIQDATE, MPLNUM, ZCPMCPNCDE, ZCPMPLANCD,  ZTRGTFLG, ZENDCDE, ZPGPFRDT, ZPGPTODT, ZPOLTDATE, 
      ZPLANCLS, CLNTNUM, ZBNKFLAG, ZCCFLAG, ZENDSCID, ZSLPTYP, SEQNUMB, 
      ZRCALTTY 
    FROM (
      SELECT his.*,
          (SELECT MIN(chk.RECIDXPHIST) FROM stagedbusr.titdmgpoltrnh@dmstagedblink chk WHERE chk.chdrnum = his.chdrnum) recchunksnum,
          gchi.ccdate,
          gchi.crdate,
          gchi.zpolperd,
          gchi.agntnum,
          gchd.statcode,
          gchd.cownnum,
          gchd.tranlused,
          gchd.btdate AS btdate_gchd,
          gchd.effdcldt,
          gchd.occdate,
          gchd.uniqdate,
          gchd.mplnum,
          ntry.zcmpcode AS zcpmcpncde,
          ntry.zplancde AS zcpmplancd,
          agnt.ztrgtflg,
          gchp.zendcde,
          gchp.zpgpfrdt,
          gchp.zpgptodt,
          gchp.zpoltdate,
          gchp.zplancls,
          --zcln1.unique_number AS unique_number01,
          --zcln1.zworkplce,
          --zcln2.unique_number AS unique_number02,
          --zcln2.occpcode,
          clnt.zigvalue AS clntnum,
          zenc.zbnkflag,
          zenc.zccflag,
          zend.zendscid,
          --spp.zsalplan,
          zslp.zslptyp,
          --zcle.unique_number as zcle_data,
          NVL(zben.seqnumb,0) seqnumb,
          SUBSTR(utl_raw.cast_to_varchar2(c.genarea),6,4) zrcaltty
        FROM stagedbusr.titdmgpoltrnh@dmstagedblink his
        LEFT OUTER JOIN Jd1dta.itempf c ON RTRIM(c.itemitem) = RTRIM(his.zaltrcde01) AND RTRIM(c.itemtabl) = 'TQ9MP' AND RTRIM(c.itemcoy) IN (1, 9) AND RTRIM(c.itempfx) = 'IT' AND RTRIM(c.validflag)= '1'
        LEFT OUTER JOIN
          ( SELECT DISTINCT g.ccdate,
            g.crdate,
            g.zpolperd,
            g.agntnum,
            h.chdrnum,
            h.zseqno
          FROM stagedbusr.titdmgpoltrnh@dmstagedblink h LEFT OUTER JOIN Jd1dta.gchipf g ON h.chdrnum = g.chdrnum AND h.effdate = g.ccdate AND g.chdrcoy IN ('1', '9')
          WHERE SUBSTR(h.zseqno,-1) = '0'
          ) gchi ON gchi.chdrnum = his.chdrnum AND SUBSTR(gchi.zseqno,1,2) = SUBSTR(his.zseqno,1,2)
        LEFT OUTER JOIN Jd1dta.agntpf agnt ON agnt.agntnum = gchi.agntnum
        LEFT OUTER JOIN
          ( SELECT DISTINCT h.chdrnum,
            h.zseqno,
            CASE
              WHEN h.effdate < h.zaltregdat
              THEN h.zaltregdat
              ELSE h.effdate
            END AS uniqdate,
            g.statcode,
            g.cownnum,
            g.tranlused,
            g.btdate,
            g.effdcldt,
            g.occdate,
            g.mplnum
          FROM stagedbusr.titdmgpoltrnh@dmstagedblink h LEFT OUTER JOIN Jd1dta.gchd g ON h.chdrnum = g.chdrnum AND RTRIM(g.chdrpfx) = 'CH' AND RTRIM(g.validflag) = '1' AND RTRIM(g.chdrcoy) IN ('1', '9')
          ) gchd ON RTRIM(gchd.chdrnum) = RTRIM(his.chdrnum) AND RTRIM(gchd.zseqno) = RTRIM(his.zseqno)
        LEFT OUTER JOIN Jd1dta.gchppf gchp ON RTRIM(gchp.chdrnum) = RTRIM(his.chdrnum) AND RTRIM(gchp.chdrcoy) IN (1, 9) 
        LEFT OUTER JOIN Jd1dta.pazdclpf clnt ON RTRIM(his.clientno) = RTRIM(clnt.zentity) AND RTRIM(clnt.prefix) = RTRIM('CP')
        --LEFT OUTER JOIN (
        --    select unique_number, zworkplce, clntnum, effdate, row_number() over(partition by clntnum order by effdate) rn from Jd1dta.zclnpf 
        -- ) zcln1 ON RTRIM(zcln1.clntnum) = RTRIM(gchd.cownnum) AND RTRIM(zcln1.effdate) <= RTRIM(gchd.uniqdate) and zcln1.rn = 1
        --LEFT OUTER JOIN (
        --    select unique_number, occpcode, clntnum, effdate, row_number() over(partition by clntnum order by effdate) rn from Jd1dta.zclnpf 
        -- ) zcln2 ON RTRIM(zcln2.clntnum) = RTRIM(clnt.zigvalue) AND RTRIM(zcln2.effdate) <= RTRIM(gchd.uniqdate) and zcln2.rn = 1
        LEFT OUTER JOIN Jd1dta.zencipf zenc ON RTRIM(zenc.zendcde) = RTRIM(gchp.zendcde)
        LEFT OUTER JOIN Jd1dta.zendrpf zend ON RTRIM(zend.zendcde) = RTRIM(gchp.zendcde)
          --LEFT OUTER JOIN (SELECT DISTINCT(zsalplan) FROM Jd1dta.zslppf) spp ON RTRIM(his.ZPLANCDE) = RTRIM(spp.zsalplan)
        LEFT OUTER JOIN Jd1dta.gchd p13 ON p13.zprvchdr = his.chdrnum AND p13.zprvchdr IS NOT NULL
        LEFT OUTER JOIN stagedbusr.titdmgpoltrnh@dmstagedblink ntry ON ntry.chdrnum = p13.chdrnum AND ntry.tranno = 1 AND ntry.ZINSROLE = '1' 
        LEFT OUTER JOIN Jd1dta.ZSLPHPF zslp ON RTRIM(zslp.zsalplan) = RTRIM(his.zplancde)
        LEFT OUTER JOIN (  
          SELECT MAX(seqnumb) seqnumb, chdrnum, mbrno FROM Jd1dta.zbenfdtlspf  group by chdrnum, mbrno
        ) zben ON TRIM(zben.chdrnum) = TRIM(his.chdrnum) AND TRIM(zben.mbrno) = TRIM(his.mbrno)
          --LEFT OUTER JOIN Jd1dta.zclepf zcle ON TRIM(zcle.clntnum) = RTRIm(gchd.cownnum) AND RTRIM(zcle.zendcde) = RTRIM(gchp.zendcde)
          --AND RTRIM(zcle.zenspcd01) = RTRIM(his.zenspcd01) AND RTRIM(zcle.zenspcd02) = RTRIM(his.zenspcd02) AND RTRIM(zcle.zcifcode) = RTRIM(his.zcifcode)
        ) 
        ORDER BY LPAD(chdrnum, 8, '0') ASC ,
        LPAD(mbrno, 5, '0') ASC ,
        tranno ASC;  
COMMIT;

DELETE FROM Jd1dta.DMIGTITDMGPOLTRNH;
COMMIT;

INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGPOLTRNH
SELECT RECIDXPHIST, CHDRNUM, ZSEQNO, EFFDATE, CLIENT_CATEGORY, MBRNO, CLTRELN, ZINSROLE, CLIENTNO, ZALTREGDAT, ZALTRCDE01, ZINHDSCLM, ZUWREJFLG, ZSTOPBPJ, ZTRXSTAT, ZSTATRESN, ZACLSDAT, APPRDTE, ZPDATATXDTE, ZPDATATXFLG,
      ZREFUNDAM, ZPAYINREQ, CRDTCARD, PREAUTNO, BNKACCKEY01, ZENSPCD01, ZENSPCD02, ZCIFCODE, ZDDREQNO, ZWORKPLCE2, BANKACCDSC01, BANKKEY, BNKACTYP01, CURRTO, B1_ZKNJFULNM, B2_ZKNJFULNM, B3_ZKNJFULNM, B4_ZKNJFULNM, B5_ZKNJFULNM,
      B1_CLTADDR01, B2_CLTADDR01, B3_CLTADDR01, B4_CLTADDR01, B5_CLTADDR01, B1_BNYPC, B2_BNYPC, B3_BNYPC, B4_BNYPC, B5_BNYPC, B1_BNYRLN, B2_BNYRLN, B3_BNYRLN, B4_BNYRLN, B5_BNYRLN, ZSOLCTFLG, ZPLANCDE, ZCMPCODE, ZCPNSCDE, ZSALECHNL,
      TRANCDE, TRANNO, MINTRANNO, BTDATE, INTREFUND, RECCHUNKSNUM, CCDATE, CRDATE, ZPOLPERD, AGNTNUM, STATCODE, COWNNUM, TRANLUSED, BTDATE_GCHD, EFFDCLDT, OCCDATE, UNIQDATE, MPLNUM, ZCPMCPNCDE, ZCPMPLANCD,  ZTRGTFLG, ZENDCDE, ZPGPFRDT, ZPGPTODT, ZPOLTDATE,
      ZPLANCLS, CLNTNUM, ZBNKFLAG, ZCCFLAG, ZENDSCID, ZSLPTYP, UNIQUE_NUMBER01, ZWORKPLCE, UNIQUE_NUMBER02, OCCPCODE, SEQNUMB, ZACMCLDT, ZCN_ZCMPCODE, CLB_BANKKEY, PAZ_REC,
      ZRCALTTY
    FROM (
      SELECT his.*,
             zcln1.unique_number AS unique_number01,
             zcln1.zworkplce AS zworkplce,
             zcln2.unique_number02 AS unique_number02,
             trim(zcln2.occpcode) AS occpcode,
             zesd.zacmcldt AS zacmcldt,
             zcn.ZCMPCODE AS zcn_zcmpcode,
             clb.bankkey AS clb_bankkey,
             paz.zentity AS paz_rec
        FROM Jd1dta.dm_temp_polhist his
        LEFT OUTER JOIN (
          select a.recidxphist, max(b.unique_number) unique_number, max(b.zworkplce) zworkplce
          from Jd1dta.dm_temp_polhist a, Jd1dta.zclnpf b
          where RTRIM(b.clntnum) = RTRIM(a.cownnum) AND RTRIM(b.effdate) <= RTRIM(a.uniqdate)
          group by a.recidxphist
        ) zcln1 ON his.recidxphist = zcln1.recidxphist
        LEFT OUTER JOIN (
          select a.recidxphist, max(b.unique_number) unique_number02, max(b.occpcode) occpcode
          from Jd1dta.dm_temp_polhist a, Jd1dta.zclnpf b
          where RTRIM(b.clntnum) = RTRIM(a.clntnum) AND RTRIM(b.effdate) <= RTRIM(a.uniqdate)
          group by a.recidxphist
        ) zcln2 ON his.recidxphist = zcln2.recidxphist
        LEFT OUTER JOIN (
          select a.recidxphist, min(b.zacmcldt)  zacmcldt
          from Jd1dta.dm_temp_polhist a, Jd1dta.zesdpf b
          where TRIM(b.zendscid)=TRIM(a.zendscid) and TRIM(b.zacmcldt) >= a.apprdte
          group by a.recidxphist
        ) zesd ON his.recidxphist = zesd.recidxphist
        LEFT JOIN Jd1dta.zcpnpf zcn ON RTRIM(zcn.ZCMPCODE) = RTRIM(his.ZCMPCODE)
        LEFT JOIN (
            select distinct bankacckey, bankkey from Jd1dta.clbapf --select is required as data are getting dulpicated
        ) clb ON RTRIM(clb.bankacckey) = (RTRIM(his.bnkacckey01) || RTRIM(his.crdtcard))
                                               AND RTRIM(clb.bankkey) = RTRIM(his.bankkey)
        LEFT JOIN Jd1dta.pazdptpf paz ON paz.zentity=his.chdrnum AND paz.zseqno=his.zseqno AND paz.tranno=his.tranno AND paz.effdate=his.effdate AND paz.mbrno=his.mbrno AND paz.zinsrole=his.zinsrole                                
    )
    ORDER BY LPAD(chdrnum, 8, '0') ASC,
    LPAD(mbrno, 5, '0') ASC ,
    tranno ASC;    
COMMIT;

DELETE FROM MB01_POLHIST_RANGE;
COMMIT;

INSERT INTO MB01_POLHIST_RANGE (SELECT MIN(chdrnum), MAX(chdrnum) FROM Jd1dta.DMIGTITDMGPOLTRNH);
COMMIT;

v_sqlQuery2 := 'select ''DMIGTITDMGPOLTRNH'' ,count(*)  from Jd1dta.DMIGTITDMGPOLTRNH';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

v_sqlQuery2 := 'select ''MB01_POLHIST_RANGE'' ,count(*)  from Jd1dta.MB01_POLHIST_RANGE';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='MB01_POLHIST_RANGE';

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGPOLTRNH';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'MB01_POLHIST_RANGE' ,count(*)  from Jd1dta.MB01_POLHIST_RANGE;
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGPOLTRNH' ,count(*)  from Jd1dta.DMIGTITDMGPOLTRNH;

COMMIT;

END IF;
---------POL_HIS:END------------------


---------POL_COV:START------------------

IF(SCHEDULE_NAME='G1ZDPOLCOV')THEN
DELETE FROM Jd1dta.DMIGTITDMGMBRINDP2; 
COMMIT;

INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGMBRINDP2
SELECT p2.RECIDXMBINDP2, p2.REFNUM, p2.ZSEQNO, p2.MBRNO, p2.DPNTNO, p2.PRODTYP, p2.EFFDATE, p2.ZINSTYPE, p2.APREM, p2.HSUMINSU, p2.ZTAXFLG, p2.NDRPREM, 
  p2.PRODTYP02, p2.TRANNO, p2.ZPLANCDE, p2.CCDATE, p2.CRDATE, p2.ZSLPTYP, p2.zinsrole, p2.effdcldt, p2.statcode, p2.zpoltdate, p2.PAZ_REC, p2.PERIODNO,
  MAX(p2.periodno) OVER(PARTITION BY p2.refnum) AS periodcnt,
  (SELECT MIN(m.RECIDXMBINDP2) FROM stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK m  WHERE p2.refnum = m.refnum) RECCHUNCKBINDP2
FROM
  (
  SELECT tit.*, gchi.ccdate, gchi.crdate, zslp.zslptyp, zins.zinsrole, gchd.effdcldt, gchd.statcode, gchp.zpoltdate, 
      paz.zentity as paz_rec,  
      DENSE_RANK() OVER(PARTITION BY tit.refnum ORDER BY tit.refnum || tit.zseqno ) AS periodno 
   FROM stagedbusr.TITDMGMBRINDP2@DMSTAGEDBLINK tit
   LEFT OUTER JOIN Jd1dta.gchipf gchi ON tit.refnum = gchi.chdrnum  AND tit.effdate = gchi.ccdate
   LEFT OUTER JOIN Jd1dta.zslphpf zslp ON RTRIM(zslp.zsalplan) = RTRIM(tit.zplancde)
   LEFT OUTER JOIN Jd1dta.zinsdtlspf zins ON zins.chdrnum = tit.refnum AND zins.mbrno = tit.mbrno AND zins.dpntno = tit.dpntno AND zins.tranno = tit.tranno
   LEFT OUTER JOIN Jd1dta.gchd gchd ON gchd.chdrnum = tit.refnum 
   LEFT OUTER JOIN Jd1dta.gchppf gchp ON gchp.chdrnum = tit.refnum
   LEFT OUTER JOIN Jd1dta.pazdpcpf paz ON paz.zentity=tit.refnum AND paz.mbrno=tit.mbrno AND paz.dpntno=tit.dpntno AND paz.prodtyp=tit.prodtyp AND paz.effdate=tit.effdate  --Ticket #ZJNPG-9739
  ) p2
ORDER BY refnum ASC, mbrno ASC, dpntno ASC, tranno ASC;
COMMIT;


 v_sqlQuery2 := 'select ''DMIGTITDMGMBRINDP2'' ,count(*)  from Jd1dta.DMIGTITDMGMBRINDP2';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );
delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGMBRINDP2';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGMBRINDP2' ,count(*)  from Jd1dta.DMIGTITDMGMBRINDP2;
COMMIT;



END IF;

---------POL_COV:END------------------

---------G1ZDAPIRNO:START------------------

IF(SCHEDULE_NAME='G1ZDAPIRNO')THEN

DELETE FROM Jd1dta.DMIGTITDMGAPIRNO;
COMMIT;

INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGAPIRNO
SELECT tit.recidxapirno, tit.chdrnum, tit.mbrno, tit.zinstype, tit.zapirno, tit.fullkanjiname, tit.tranno ,gm.dteatt, gc.chdrnum gc_chdrnum, paz.zentity PAZ_REC
FROM  stagedbusr.titdmgapirno@DMSTAGEDBLINK tit
    LEFT OUTER JOIN Jd1dta.gchd gc ON gc.chdrnum = tit.chdrnum
    LEFT OUTER JOIN (
      SELECT chdrnum, mbrno, min(dteatt) dteatt
      FROM Jd1dta.gmhdpf
      WHERE TRIM(chdrcoy) IN (1, 9)
      GROUP BY chdrnum, mbrno
    ) gm ON gc.chdrnum = gm.chdrnum AND tit.mbrno = gm.mbrno
    LEFT OUTER JOIN Jd1dta.pazdrnpf paz ON paz.zentity = tit.chdrnum AND paz.mbrno = tit.mbrno AND paz.zinstype = tit.zinstype AND paz.zapirno = tit.zapirno AND paz.fullkanjiname = tit.fullkanjiname --Ticket #ZJNPG-9739
ORDER BY tit.chdrnum, tit.mbrno;

COMMIT;

 v_sqlQuery2 := 'select ''DMIGTITDMGAPIRNO'' ,count(*)  from Jd1dta.DMIGTITDMGAPIRNO';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGAPIRNO';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGAPIRNO' ,count(*)  from Jd1dta.DMIGTITDMGAPIRNO;
COMMIT;

END IF;

---------G1ZDAPIRNO:END------------------


---------BILL_HIS:START------------------
IF(SCHEDULE_NAME='G1ZDBILLIN')THEN
delete from Jd1dta.DMIGTITDMGBILL1;
COMMIT;


INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGBILL1 
      (RECIDXBILL1, TRREFNUM, CHDRNUM, PRBILFDT, PRBILTDT, PREMOUT, ZCOLFLAG, ZACMCLDT, ZPOSBDSM, ZPOSBDSY, ENDSERCD,
       TFRDATE, POSTING, NRFLAG, ZPDATATXFLG, TRANNO, REFNUMCHUNK)
SELECT RECIDXBILL1, TRREFNUM, CHDRNUM, PRBILFDT, PRBILTDT, PREMOUT, ZCOLFLAG, ZACMCLDT, ZPOSBDSM, ZPOSBDSY, ENDSERCD,
       TFRDATE, POSTING, NRFLAG, ZPDATATXFLG, TRANNO,
       (SELECT MAX(RECIDXBILL1) FROM stagedbusr.TITDMGBILL1@DMSTAGEDBLINK b WHERE b.CHDRNUM = a.CHDRNUM) AS REFNUMCHUNK
FROM stagedbusr.TITDMGBILL1@DMSTAGEDBLINK a;
COMMIT;

delete from Jd1dta.DMIGTITDMGBILL2;
COMMIT;

INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGBILL2
	   (RECIDXBILL2, TRREFNUM, CHDRNUM, TRANNO, PRODTYP, BPREM, GAGNTSEL01, GAGNTSEL02, GAGNTSEL03, GAGNTSEL04, GAGNTSEL05,
	    CMRATE01, CMRATE02, CMRATE03, CMRATE04, CMRATE05, COMMN01, COMMN02, COMMN03, COMMN04, COMMN05,
	    ZAGTGPRM01, ZAGTGPRM02, ZAGTGPRM03, ZAGTGPRM04, ZAGTGPRM05, ZCOLLFEE01, MBRNO, DPNTNO, PRBILFDT, REFNUMCHUNK)
SELECT  a.RECIDXBILL2, a.TRREFNUM, a.CHDRNUM, a.TRANNO, a.PRODTYP, a.BPREM, a.GAGNTSEL01, a.GAGNTSEL02, a.GAGNTSEL03, a.GAGNTSEL04, 
        a.GAGNTSEL05, a.CMRATE01, a.CMRATE02, a.CMRATE03, a.CMRATE04, a.CMRATE05, a.COMMN01, a.COMMN02, a.COMMN03, a.COMMN04, a.COMMN05,
		a.ZAGTGPRM01, a.ZAGTGPRM02, a.ZAGTGPRM03, a.ZAGTGPRM04, a.ZAGTGPRM05, a.ZCOLLFEE01, a.MBRNO, a.DPNTNO, a.PRBILFDT, b.REFNUMCHUNK
FROM Jd1dta.DMIGTITDMGBILL1 b, stagedbusr.TITDMGBILL2@DMSTAGEDBLINK a
WHERE a.CHDRNUM = b.CHDRNUM
AND a.TRREFNUM = b.TRREFNUM
AND a.PRBILFDT = b.PRBILFDT;
COMMIT;
v_sqlQuery2 := 'select ''DMIGTITDMGBILL1'' ,count(*)  from Jd1dta.DMIGTITDMGBILL1';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

 v_sqlQuery2 := 'select ''DMIGTITDMGBILL2'' ,count(*)  from Jd1dta.DMIGTITDMGBILL2';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );
delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGBILL1';
delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGBILL2';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGBILL1' ,count(*)  from Jd1dta.DMIGTITDMGBILL1;
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGBILL2' ,count(*)  from Jd1dta.DMIGTITDMGBILL2;
COMMIT;

END IF;
 

---------BILL_HIS:END----------------------



---------BILL_REFUND:START------------------
IF(SCHEDULE_NAME='G1ZDBILLRF')THEN

delete from Jd1dta.DMIGTITDMGREF1;
COMMIT;

INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGREF1 
      (RECIDXREFB1, REFNUM, CHDRNUM, ZREFMTCD, EFFDATE, PRBILFDT, PRBILTDT, ZPOSBDSM, ZPOSBDSY, ZALTRCDE01, ZREFUNDBE, ZREFUNDBZ,
	   ZENRFDST, ZZHRFDST, BANKKEY, BANKACOUNT, BANKACCDSC, BNKACTYP, ZRQBKRDF, REQDATE, ZCOLFLAG, PAYDATE, RDOCPFX, RDOCCOY,
	   RDOCNUM, ZPDATATXFLG, TRANNO, NRFLAG, REFNUMCHUNK)
SELECT RECIDXREFB1, REFNUM, CHDRNUM, ZREFMTCD, EFFDATE, PRBILFDT, PRBILTDT, ZPOSBDSM, ZPOSBDSY, ZALTRCDE01, ZREFUNDBE, ZREFUNDBZ,
	   ZENRFDST, ZZHRFDST, BANKKEY, BANKACOUNT, BANKACCDSC, BNKACTYP, ZRQBKRDF, REQDATE, ZCOLFLAG, PAYDATE, RDOCPFX, RDOCCOY,
	   RDOCNUM, ZPDATATXFLG, TRANNO, NRFLAG,
       (SELECT MAX(RECIDXREFB1) FROM stagedbusr.TITDMGREF1@DMSTAGEDBLINK b WHERE b.CHDRNUM = a.CHDRNUM) AS REFNUMCHUNK
FROM stagedbusr.TITDMGREF1@DMSTAGEDBLINK a;
COMMIT;


delete from Jd1dta.DMIGTITDMGREF2;
COMMIT;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGREF2 SELECT * FROM stagedbusr.TITDMGREF2@DMSTAGEDBLINK;
COMMIT;

-- update REFNUMCHUNK for parallel execution of second table DMIGTITDMGBILL2
UPDATE Jd1dta.DMIGTITDMGREF2 B SET REFNUMCHUNK = (SELECT REFNUMCHUNK 
													 FROM Jd1dta.DMIGTITDMGREF1 A
													WHERE trim(A.CHDRNUM) = trim(B.CHDRNUM)
													  AND to_number(A.REFNUM) = to_number(B.TRREFNUM)
													  AND trim(A.ZREFMTCD) = trim(B.ZREFMTCD));
COMMIT;

 v_sqlQuery2 := 'select ''DMIGTITDMGREF1'' ,count(*)  from Jd1dta.DMIGTITDMGREF1';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

 v_sqlQuery2 := 'select ''DMIGTITDMGREF2'' ,count(*)  from Jd1dta.DMIGTITDMGREF2';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGREF1';

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGREF2';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGREF1' ,count(*)  from Jd1dta.DMIGTITDMGREF1;
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGREF2' ,count(*)  from Jd1dta.DMIGTITDMGREF2;
COMMIT;

END IF;
---------BILL_REFUND:END----------------------


---------BILL_COLRES:START------------------
IF(SCHEDULE_NAME='G1ZDCOLRES')THEN
delete from Jd1dta.DMIGTITDMGCOLRES;
COMMIT;

INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGCOLRES 
       (RECIDXCAMP,   
        CHDRNUM, 
        TRREFNUM, 
        TFRDATE, 
        DSHCDE,
        PRBILFDT,
        CHUNKSNUM,
        PAZ_REC) --Ticket #ZJNPG-9739
SELECT  RECIDXCAMP,   
        CHDRNUM, 
        TRREFNUM, 
        TFRDATE, 
        DSHCDE,
        PRBILFDT,
        (SELECT MAX(RECIDXCAMP) FROM stagedbusr.TITDMGCOLRES@DMSTAGEDBLINK b WHERE b.CHDRNUM = a.CHDRNUM) AS CHUNKSNUM,
        ZIGVALUE as PAZ_REC --Ticket #ZJNPG-9739
FROM stagedbusr.TITDMGCOLRES@DMSTAGEDBLINK a
LEFT OUTER JOIN Jd1dta.pazdcrpf paz ON paz.zentity = (a.chdrnum || '-' || a.trrefnum || '-' || a.prbilfdt || '-' || a.tfrdate); --Ticket #ZJNPG-9739
COMMIT;

 v_sqlQuery2 := 'select ''DMIGTITDMGCOLRES'' ,count(*)  from Jd1dta.DMIGTITDMGCOLRES';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGCOLRES';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGCOLRES' ,count(*)  from Jd1dta.DMIGTITDMGCOLRES;
COMMIT;

END IF;
---------BILL_COLRES:END----------------------


---------BILL_DISHONOR:START------------------
IF(SCHEDULE_NAME='G1ZDPOLDSH')THEN
delete from Jd1dta.DMIGTITDMGMBRINDP3;
INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGMBRINDP3 SELECT * FROM stagedbusr.TITDMGMBRINDP3@DMSTAGEDBLINK;
COMMIT;

 v_sqlQuery2 := 'select ''DMIGTITDMGMBRINDP3'' ,count(*)  from Jd1dta.DMIGTITDMGMBRINDP3';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGMBRINDP3';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGMBRINDP3' ,count(*)  from Jd1dta.DMIGTITDMGMBRINDP3;
COMMIT;

END IF;
---------BILL_DISHONOR:END----------------------


---------LETTER:START------------------
IF(SCHEDULE_NAME='G1ZDLETR')THEN
DELETE FROM Jd1dta.DMIGTITDMGLETTER;
COMMIT;


INSERT /*+ APPEND */ INTO Jd1dta.DMIGTITDMGLETTER
SELECT RECIDXLETR, CHDRNUM, LETTYPE, LREQDATE, ZDSPCATG, ZLETVERN, ZLETDEST, ZCOMADDR, ZLETCAT, ZAPSTMPD, ZDESPER, ZLETEFDT, ZLETTRNO, STAGECLNTNO,
(select min(RECIDXLETR) from stagedbusr.titdmgletter@DMSTAGEDBLINK a where tit.lettype = a.lettype and tit.stageclntno = a.stageclntno) refnumchunk
FROM stagedbusr.titdmgletter@DMSTAGEDBLINK tit
ORDER BY refnumchunk;

Commit;

 v_sqlQuery2 := 'select ''DMIGTITDMGLETTER'' ,count(*)  from Jd1dta.DMIGTITDMGLETTER';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );
delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGLETTER';
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGLETTER' ,count(*)  from Jd1dta.DMIGTITDMGLETTER;
COMMIT;

END IF;

---------LETTER:END----------------------

----- Renewal Determination : START ------------
IF(SCHEDULE_NAME='G1ZDRNWDTM')THEN
DELETE FROM  Jd1dta.DMIGTITDMGRNWDT1;
COMMIT;

INSERT  /*+ APPEND PARALLEL(DMIGTITDMGRNWDT1)  */ INTO Jd1dta.DMIGTITDMGRNWDT1
         ( CHDRNUM, MBRNO, ZRNDTFRM, ZRNDTTO, ZALTRCDE, ZRNDTREG, ZRNDTAPP, ZINSROLE, STAGECLNTNO
         , ZTERMFLG, ZSALPLAN, ZRNDTRCD, ZINSRNWAGE, INPUT_SOURCE_TABLE)
SELECT /*+  PARALLEL  */
         CHDRNUM, MBRNO, ZRNDTFRM, ZRNDTTO, ZALTRCDE, ZRNDTREG, ZRNDTAPP, ZINSROLE, STAGECLNTNO
          , ZTERMFLG, ZSALPLAN, ZRNDTRCD, ZINSRNWAGE, INPUT_SOURCE_TABLE
FROM  STAGEDBUSR.TITDMGRNWDT1@DMSTAGEDBLINK
 ;
COMMIT;

v_sqlQuery2 := 'select ''DMIGTITDMGRNWDT1'' ,count(*)  from Jd1dta.DMIGTITDMGRNWDT1';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );


DELETE FROM   Jd1dta.DMIGTITDMGRNWDT2; 
COMMIT;

INSERT  /*+ APPEND PARALLEL(DMIGTITDMGRNWDT2)  */ INTO DMIGTITDMGRNWDT2
	  ( CHDRNUM, MBRNO, DPNTNO, PRODTYP, SUMINS, DPREM, ZINSTYPE,PRODTYP02,NDR_DPREM, INPUT_SOURCE_TABLE)
SELECT /*+  PARALLEL  */
	  CHDRNUM, MBRNO, DPNTNO, PRODTYP, SUMINS, DPREM, ZINSTYPE, TRIM(PRODTYP02),NDR_DPREM,INPUT_SOURCE_TABLE
FROM  STAGEDBUSR.TITDMGRNWDT2@DMSTAGEDBLINK
;
COMMIT;

v_sqlQuery2 := 'select ''DMIGTITDMGRNWDT2'' ,count(*)  from Jd1dta.DMIGTITDMGRNWDT2';
 EXECUTE IMMEDIATE v_sqlQuery2
     into TAB_NAME, ROW_COUNT ;
dbms_output.put_line(TAB_NAME ||  ' => ' ||ROW_COUNT );

delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGRNWDT1';
delete from DM2_DMIG_DATA_CNT where TAB_NAME='DMIGTITDMGRNWDT2';

Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGRNWDT1' ,count(*)  from Jd1dta.DMIGTITDMGRNWDT1;
Insert into DM2_DMIG_DATA_CNT (TAB_NAME,ROW_COUNT) select 'DMIGTITDMGRNWDT2' ,count(*)  from Jd1dta.DMIGTITDMGRNWDT2;
COMMIT;

END IF;
----- Renewal Determination : END ------------


COMMIT;
dbms_output.put_line('******************DMIGTIT* table insertion : END******************************');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'PRE_DM_STEP : ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
  
    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      ('PRE_DM_STEP', 000, p_exitcode, p_exittext, sysdate);
    commit;
     raise;

COMMIT;
  

END;
/



