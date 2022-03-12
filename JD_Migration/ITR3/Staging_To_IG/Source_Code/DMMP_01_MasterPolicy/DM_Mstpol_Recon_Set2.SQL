create or replace PROCEDURE        DM_Mstpol_Recon_Set2 (
   p_detail_batch_id     IN  VARCHAR2,
   p_summary_batch_id     IN  VARCHAR2
)  IS

    PRAGMA AUTONOMOUS_TRANSACTION;

/******************************************************************************************************
  * Amenment History: Reconciliation for Group Master Policy
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CC1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * DEC13    HOD       CC1   Initial version
  * MAR08    ABG       CC1   Recon validation for 24 D category attributes
 *******************************************************************************************************/
    
    ---- constants and variables -----
    c_module_name      CONSTANT VARCHAR2(50) := 'DM_Mstpol_Recon_Set2';
    c_created_by       CONSTANT VARCHAR2(50) := 'JPATHZ';
    c_job_name         CONSTANT VARCHAR2(50) := 'DM_Mstpol_Recon_Set2';
    c_eff_desc         CONSTANT VARCHAR2(100) := 'ccdate';
    c_filter_modname   CONSTANT VARCHAR2(50) := 'Master Policy';
	c_limit            PLS_INTEGER   := 1000;
	p_exitcode         NUMBER;
    p_exittext         VARCHAR2(2000);
    v_counter          PLS_INTEGER;
        
    obj_dm_master_pol_recon_det          Jd1dta.dm_master_pol_recon_det%rowtype;
   
	
--------- Cursor 1 for 1-8 attributes ---------
CURSOR cur_d1query IS  
      SELECT
      src_CHDRNUM ---#1
     ,src_CNTTYPE ---#2
     ,src_STATCODE ---#3
     ,src_OCCDATE 
     ,src_PNDATE ---#4
     ,src_ZENDCDE ---#5
     ,src_RRA2IG ---#6
     ,src_B8TJIG ---#7
     ,src_zpenddt ---#8
     ,src_CCDATE
	 ,stg_CHDRNUM ---#1
     ,stg_CNTTYPE ---#2
     ,stg_STATCODE ---#3
     ,stg_OCCDATE 
     ,stg_PNDATE ---#4
     ,stg_ZENDCDE ---#5
     ,stg_RRA2IG ---#6
     ,stg_B8TJIG ---#7
     ,stg_zpenddt ---#8
     ,stg_CCDATE
	 ,gchd_CHDRNUM ---#1
     ,gchd_CNTTYPE ---#2
     ,gchd_STATCODE ---#3
     ,gchd_OCCDATE 
     ,gchd_PNDATE ---#4
     ,gchppf_ZENDCDE ---#5
     ,gchppf_PETNAME ---#6
     ,gchppf_ZGRPCLS ---#7
     ,gchppf_zpenddt ---#8
FROM
     (
      SELECT
            TRIM(src1.chdrnum)  src_CHDRNUM ---#1
           ,TRIM(src1.CNTTYPE)  src_CNTTYPE     ---#2
           ,TRIM(src1.STATCODE) src_STATCODE     ---#3
           ,TRIM(src2.MIN_OCCDATE)  src_OCCDATE     
           ---,TRIM(src2.MAX_OCCDATE)  src_MAX_OCCDATE     ---#4
           ,TRIM(src1.PNDATE)   src_PNDATE     ---#4
           ,TRIM(src1.ZENDCDE)  src_ZENDCDE     ---#5
           ,TRIM(src1.RRA2IG)   src_RRA2IG     ---#6
           ,TRIM(src1.B8TJIG)   src_B8TJIG     ---#7
           ,TRIM(src1.zpenddt)   src_zpenddt     ---#8
		   ,TRIM(src1.CCDATE)   src_CCDATE       
      FROM
           (
            SELECT
                  CASE LENGTH(TRIM(chdrnum)) 
                       WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                       ELSE TRIM(chdrnum)
                  END chdrnum  ---#1
                 ,CNTTYPE      ---#2
                 ,STATCODE     ---#3
                 ,OCCDATE      
                 ,PNDATE       ---#4
                 ,ZENDCDE      ---#5
                 ,RRA2IG       ---#6
                 ,B8TJIG       ---#7
                 ,zpenddt      ---#8
				 ,CCDATE
            FROM
                 STAGEDBUSR2.TITDMGMASPOL@dmstgusr2dblink
           )  src1
           INNER JOIN
          (
           SELECT
                CHDRNUM 
               ,CNTTYPE
               ,MAX(OCCDATE) MAX_OCCDATE
               ,MIN(OCCDATE) MIN_OCCDATE
           FROM
               (
                SELECT
                     CASE LENGTH(TRIM(chdrnum)) 
                          WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                          ELSE TRIM(chdrnum)          
                     END chdrnum       
                    ,CNTTYPE
                    ,OCCDATE
                FROM
                    STAGEDBUSR2.TITDMGMASPOL@dmstgusr2dblink
               ) 
           GROUP BY
                CHDRNUM 
               ,CNTTYPE
          ) src2
      ON
          TRIM(src1.CHDRNUM) = TRIM(src2.CHDRNUM)
      AND TRIM(src1.CNTTYPE) = TRIM(src2.CNTTYPE)
      AND TRIM(src1.OCCDATE) = TRIM(src2.MAX_OCCDATE)
     ) src
INNER JOIN STAGEDBUSR2.DM_POLICY_RECON@dmstgusr2dblink recon
ON TRIM(src.src_CHDRNUM) = TRIM(recon.V_POLICY_NO)
LEFT JOIN (
      SELECT
            TRIM(stg1.chdrnum)  stg_CHDRNUM ---#1
           ,TRIM(stg1.CNTTYPE)  stg_CNTTYPE     ---#2
           ,TRIM(stg1.STATCODE) stg_STATCODE     ---#3
           ,TRIM(stg2.MIN_OCCDATE)  stg_OCCDATE     
           ---,TRIM(stg2.MAX_OCCDATE)  stg_MAX_OCCDATE     ---#4
           ,TRIM(stg1.PNDATE)   stg_PNDATE     ---#4
           ,TRIM(stg1.ZENDCDE)  stg_ZENDCDE     ---#5
           ,TRIM(stg1.RRA2IG)   stg_RRA2IG     ---#6
           ,TRIM(stg1.B8TJIG)   stg_B8TJIG     ---#7
           ,TRIM(stg1.zpenddt)   stg_zpenddt     ---#8
		   ,TRIM(stg1.CCDATE)   stg_CCDATE       
      FROM
           (
            SELECT
                  CASE LENGTH(TRIM(chdrnum)) 
                       WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                       ELSE TRIM(chdrnum)
                  END chdrnum  ---#1
                 ,CNTTYPE      ---#2
                 ,STATCODE     ---#3
                 ,OCCDATE     
                 ,PNDATE       ---#4
                 ,ZENDCDE      ---#5
                 ,RRA2IG       ---#6
                 ,B8TJIG       ---#7
                 ,zpenddt      ---#8
				 ,CCDATE
            FROM
                 STAGEDBUSR.TITDMGMASPOL@dmstagedblink
           )  stg1
           INNER JOIN
          (
           SELECT
                CHDRNUM 
               ,CNTTYPE
               ,MAX(OCCDATE) MAX_OCCDATE
               ,MIN(OCCDATE) MIN_OCCDATE
           FROM
               (
                SELECT
                     CASE LENGTH(TRIM(chdrnum)) 
                          WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                          ELSE TRIM(chdrnum)          
                     END chdrnum       
                    ,CNTTYPE
                    ,OCCDATE
                FROM
                    STAGEDBUSR.TITDMGMASPOL@dmstagedblink
               ) 
           GROUP BY
                CHDRNUM 
               ,CNTTYPE
          ) stg2
      ON
          TRIM(stg1.CHDRNUM) = TRIM(stg2.CHDRNUM)
      AND TRIM(stg1.CNTTYPE) = TRIM(stg2.CNTTYPE)
      AND TRIM(stg1.OCCDATE) = TRIM(stg2.MAX_OCCDATE)
     ) stg
ON TRIM(src.src_CHDRNUM) = TRIM(stg.stg_CHDRNUM) 
LEFT JOIN 
    (
     SELECT
           TRIM(CHDRNUM)  gchd_CHDRNUM
          ,TRIM(CNTTYPE)  gchd_CNTTYPE
          ,TRIM(STATCODE) gchd_STATCODE
          ,TRIM(OCCDATE)  gchd_OCCDATE
          ,TRIM(PNDATE)  gchd_PNDATE
     FROM
          Jd1dta.GCHD
     WHERE
          CHDRNUM = MPLNUM
     AND  JOBNM = 'G1ZDMSTPOL'
     ) gchd
ON gchd.gchd_CHDRNUM = src.src_CHDRNUM
LEFT JOIN
    (
     SELECT
           TRIM(CHDRNUM)  gchppf_CHDRNUM
          ,TRIM(ZENDCDE)  gchppf_ZENDCDE
          ,TRIM(PETNAME)  gchppf_PETNAME
          ,TRIM(ZGRPCLS) gchppf_ZGRPCLS
          ,TRIM(zpenddt) gchppf_zpenddt
     FROM
         Jd1dta.GCHPPF
     WHERE
         JOBNM = 'G1ZDMSTPOL'
    ) gchppf
ON gchppf.gchppf_CHDRNUM = src.src_CHDRNUM
WHERE
    src.src_CHDRNUM <> gchd.gchd_chdrnum OR src.src_CHDRNUM <> stg.stg_CHDRNUM
OR  src.src_CNTTYPE <> gchd.gchd_CNTTYPE OR src.src_CNTTYPE <> stg.stg_CNTTYPE
OR  src.src_STATCODE <> gchd.gchd_STATCODE OR src.src_STATCODE <> stg.stg_STATCODE
OR  src.src_PNDATE <> gchd.gchd_PNDATE OR src.src_PNDATE <> stg.stg_PNDATE 
OR  src.src_ZENDCDE <> gchppf.gchppf_ZENDCDE OR src.src_ZENDCDE <> stg.stg_ZENDCDE
OR  src.src_RRA2IG <> gchppf.gchppf_PETNAME OR src.src_RRA2IG <> stg.stg_RRA2IG
OR  src.src_B8TJIG <> gchppf.gchppf_ZGRPCLS OR src.src_B8TJIG <> stg.stg_B8TJIG
OR  src.src_zpenddt <> gchppf.gchppf_zpenddt OR src.src_zpenddt <> stg.stg_zpenddt
;
	  
	TYPE typ_cur_d1query IS TABLE OF cur_d1query%ROWTYPE;
    cur_d1query_list typ_cur_d1query;

--------- Cursor 2 for 9-16 attributes ----------
CURSOR cur_d2query IS  
      SELECT
      src_CHDRNUM
     ,src_CNTTYPE
     ,src_STATCODE
     ,src_EFFDATE   --- #9
     ,src_CCDATE   --- #10
     ,src_ZAGPTNUM   --- #11
     ,src_ZBLNKPOL   --- #12
     ,src_ZNBALTPR   --- #13
     ,src_ZBLADCD   --- #14
     ,src_ZCCDE  --- #15
     ,src_ZCONSGNM  ---#16
	 ,src_RPTFPST
	 ,stg_CHDRNUM
     ,stg_CNTTYPE
     ,stg_STATCODE
     ,stg_EFFDATE   --- #9
     ,stg_CCDATE   --- #10
     ,stg_ZAGPTNUM   --- #11
     ,stg_ZBLNKPOL   --- #12
     ,stg_ZNBALTPR   --- #13
     ,stg_ZBLADCD   --- #14
     ,stg_ZCCDE  --- #15
     ,stg_ZCONSGNM  ---#16
     ,gchipf_EFFDATE   --- #9
     ,gchipf_CCDATE   --- #10
     ,gchipf_ZAGPTNUM   --- #11
     ,ztgmpf_ZBLNKPOL   --- #12
     ,ztgmpf_ZNBALTPR   --- #13
     ,zenctpf_ZBLADCD   --- #14
     ,zenctpf_ZCCDE  --- #15
     ,zenctpf_ZCONSGNM  ---#16
	 ,gchppf_ZCOLMCLS
FROM
     (
      SELECT
           CASE LENGTH(TRIM(chdrnum)) 
                WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                ELSE TRIM(chdrnum)
           END src_chdrnum
		  ,TRIM(CNTTYPE)  src_CNTTYPE
          ,TRIM(STATCODE) src_STATCODE
          ,TRIM(EFFDATE) src_EFFDATE
          ,TRIM(CCDATE) src_CCDATE
          ,TRIM(ZAGPTNUM) src_ZAGPTNUM
          ,TRIM(ZBLNKPOL) src_ZBLNKPOL
          ,TRIM(ZNBALTPR) src_ZNBALTPR
          ,TRIM(ZBLADCD) src_ZBLADCD
          ,TRIM(ZCCDE) src_ZCCDE
          ,TRIM(ZCONSGNM) src_ZCONSGNM
		  ,TRIM(RPTFPST) src_RPTFPST
      FROM
          STAGEDBUSR2.TITDMGMASPOL@dmstgusr2dblink
     ) src
INNER JOIN STAGEDBUSR2.DM_POLICY_RECON@dmstgusr2dblink recon
ON TRIM(src.src_CHDRNUM) = TRIM(recon.V_POLICY_NO)	 
LEFT JOIN (
      SELECT
           CASE LENGTH(TRIM(chdrnum)) 
                WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                ELSE TRIM(chdrnum)
           END stg_chdrnum
		  ,TRIM(CNTTYPE)  stg_CNTTYPE
          ,TRIM(STATCODE) stg_STATCODE
          ,TRIM(EFFDATE) stg_EFFDATE
          ,TRIM(CCDATE) stg_CCDATE
          ,TRIM(ZAGPTNUM) stg_ZAGPTNUM
          ,TRIM(ZBLNKPOL) stg_ZBLNKPOL
          ,TRIM(ZNBALTPR) stg_ZNBALTPR
          ,TRIM(ZBLADCD) stg_ZBLADCD
          ,TRIM(ZCCDE) stg_ZCCDE
          ,TRIM(ZCONSGNM) stg_ZCONSGNM
      FROM
          STAGEDBUSR.TITDMGMASPOL@dmstagedblink
     ) stg
ON TRIM(src.src_CHDRNUM) = TRIM(stg.stg_CHDRNUM)	 
LEFT JOIN
    (
     SELECT
           TRIM(chdrnum) gchipf_chdrnum
          ,TRIM(EFFDATE) gchipf_EFFDATE
          ,TRIM(CCDATE) gchipf_CCDATE
          ,TRIM(ZAGPTNUM) gchipf_ZAGPTNUM
     FROM
          Jd1dta.GCHIPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
    ) gchipf
ON 
    TRIM(src.src_chdrnum) = TRIM(gchipf.gchipf_chdrnum)
AND TRIM(src.src_CCDATE) = TRIM(gchipf.gchipf_CCDATE)
LEFT JOIN
    (
     SELECT
           TRIM(chdrnum) ztgmpf_chdrnum
          ,TRIM(ZBLNKPOL) ztgmpf_ZBLNKPOL
          ,TRIM(ZNBALTPR) ztgmpf_ZNBALTPR
          ,TRIM(EFFDATE) ztgmpf_EFFDATE
     FROM
          Jd1dta.ZTGMPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
    ) ztgmpf
ON 
    TRIM(src.src_chdrnum) = TRIM(ztgmpf.ztgmpf_chdrnum)
AND TRIM(src.src_CCDATE) = TRIM(ztgmpf.ztgmpf_EFFDATE)
LEFT JOIN
    (
     SELECT
           TRIM(ZPOLNMBR) zenctpf_chdrnum
          ,TRIM(ZBLADCD) zenctpf_ZBLADCD
          ,TRIM(ZCCDE) zenctpf_ZCCDE
          ,TRIM(ZCONSGNM) zenctpf_ZCONSGNM
     FROM
          Jd1dta.ZENCTPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
    ) zenctpf
ON 
    TRIM(src.src_chdrnum) = TRIM(zenctpf.zenctpf_chdrnum)
LEFT JOIN
    (
     SELECT
	       TRIM(CHDRNUM) gchppf_chdrnum
          ,TRIM(ZCOLMCLS) gchppf_ZCOLMCLS
     FROM
          Jd1dta.GCHPPF
    ) gchppf
ON 
    TRIM(src.src_chdrnum) = TRIM(gchppf.gchppf_chdrnum)	
WHERE
    src_EFFDATE <> stg_EFFDATE
OR  src_CCDATE <> stg_CCDATE
OR  src_ZAGPTNUM <> stg_ZAGPTNUM
OR  DECODE(src_ZBLNKPOL,NULL,' ',src_ZBLNKPOL) <> DECODE(stg_ZBLNKPOL,NULL,' ',stg_ZBLNKPOL)
OR  DECODE(src_ZNBALTPR,NULL,' ',src_ZNBALTPR) <> DECODE(stg_ZNBALTPR,NULL,' ',stg_ZNBALTPR)
OR  DECODE(src_ZBLADCD,NULL,' ',src_ZBLADCD) <> DECODE(stg_ZBLADCD,NULL,' ',stg_ZBLADCD)
OR  DECODE(src_ZCCDE,NULL,' ',src_ZCCDE) <> DECODE(stg_ZCCDE,NULL,' ',stg_ZCCDE)
OR  DECODE(src_ZCONSGNM,NULL,' ',src_ZCONSGNM) <> DECODE(stg_ZCONSGNM,NULL,' ',stg_ZCONSGNM)
OR  src_EFFDATE <> gchipf_EFFDATE
OR  src_CCDATE <> gchipf_CCDATE
OR  src_ZAGPTNUM <> gchipf_ZAGPTNUM
OR  DECODE(src_ZBLNKPOL,NULL,' ',src_ZBLNKPOL) <> DECODE(ztgmpf_ZBLNKPOL,NULL,' ',ztgmpf_ZBLNKPOL)
OR  DECODE(src_ZNBALTPR,NULL,' ',src_ZNBALTPR) <> DECODE(ztgmpf_ZNBALTPR,NULL,' ',ztgmpf_ZNBALTPR)
OR  DECODE(src_ZBLADCD,NULL,' ',src_ZBLADCD) <> DECODE(zenctpf_ZBLADCD,NULL,' ',zenctpf_ZBLADCD)
OR  DECODE(src_ZCCDE,NULL,' ',src_ZCCDE) <> DECODE(zenctpf_ZCCDE,NULL,' ',zenctpf_ZCCDE)
OR  DECODE(src_ZCONSGNM,NULL,' ',src_ZCONSGNM) <> DECODE(zenctpf_ZCONSGNM,NULL,' ',zenctpf_ZCONSGNM)
;
	 
	TYPE typ_cur_d2query IS TABLE OF cur_d2query%ROWTYPE;
    cur_d2query_list typ_cur_d2query;

--------- Cursor 3 for 17-24 attributes -----------
CURSOR cur_d3query IS  
      SELECT
      src_CHDRNUM
     ,src_CNTTYPE
     ,src_STATCODE
     ,src_CCDATE
     ,src_ZCRDTYPE   --- #17
     ,src_ZCNBRFRM   --- #18
     ,src_ZCNBRTO   --- #19
     ,src_ZMSTID   --- #20
     ,src_ZMSTSNME   --- #21
     ,src_ZMSTIDV   --- #22
     ,src_ZMSTSNMEV   --- #23
     ,src_ZCARDDC   --- #24
	 ,stg_CHDRNUM
     ,stg_CNTTYPE
     ,stg_STATCODE
     ,stg_CCDATE
     ,stg_ZCRDTYPE   --- #17
     ,stg_ZCNBRFRM   --- #18
     ,stg_ZCNBRTO   --- #19
     ,stg_ZMSTID   --- #20
     ,stg_ZMSTSNME   --- #21
     ,stg_ZMSTIDV   --- #22
     ,stg_ZMSTSNMEV   --- #23
     ,stg_ZCARDDC   --- #24
     ,zenctpf_ZCRDTYPE   --- #17
     ,zenctpf_ZCNBRFRM   --- #18
     ,zenctpf_ZCNBRTO   --- #19
     ,zenctpf_ZMSTID   --- #20
     ,zenctpf_ZMSTSNME   --- #21
     ,zenctpf_ZMSTIDV   --- #22
     ,zenctpf_ZMSTSNMEV   --- #23
     ,zenctpf_ZCARDDC   --- #24
FROM
     (
      SELECT
           CASE LENGTH(TRIM(src1.chdrnum)) 
                WHEN 11 THEN SUBSTR(TRIM(src1.chdrnum),4,8)
                ELSE TRIM(src1.chdrnum)
           END src_CHDRNUM
          ,TRIM(src1.ZCRDTYPE) src_ZCRDTYPE
          ,TRIM(src1.ZCNBRFRM) src_ZCNBRFRM
          ,TRIM(src1.ZCNBRTO) src_ZCNBRTO
          ,TRIM(src1.ZMSTID) src_ZMSTID
          ,TRIM(src1.ZMSTSNME) src_ZMSTSNME
          ,TRIM(src1.ZMSTIDV) src_ZMSTIDV
          ,TRIM(src1.ZMSTSNMEV) src_ZMSTSNMEV
          ,TRIM(src1.ZCARDDC) src_ZCARDDC
		  ,TRIM(src3.CNTTYPE) src_CNTTYPE
          ,TRIM(src3.STATCODE) src_STATCODE
		  ,TRIM(src3.CCDATE) src_CCDATE
          ---,TRIM(src3.ZFACTHUS) ZFACTHUS  ---@@
          ----,TRIM(src3.zcolmcls) zcolmcls  ---@@
      FROM
          STAGEDBUSR2.TITDMGENDCTPF@dmstgusr2dblink src1
      INNER JOIN
           (
            SELECT
                  CASE LENGTH(TRIM(mstpol.chdrnum)) 
                       WHEN 11 THEN SUBSTR(TRIM(mstpol.chdrnum),4,8)
                       ELSE TRIM(mstpol.chdrnum)
                  END chdrnum
				 ,TRIM(mstpol.CNTTYPE) CNTTYPE
				 ,TRIM(mstpol.STATCODE) STATCODE
				 ,TRIM(mstpol.CCDATE) CCDATE
                 ,TRIM(mstpol.ZENDCDE) ZENDCDE
                 ,TRIM(src2.ZFACTHUS) ZFACTHUS
                 ,TRIM(src2.zcolmcls) zcolmcls
            FROM
                 STAGEDBUSR2.TITDMGMASPOL@dmstgusr2dblink mstpol
            LEFT JOIN
                 ( 
                  SELECT
                        TRIM(zendrpf.ZENDCDE) ZENDCDE
                       ,TRIM(zendrpf.ZFACTHUS) ZFACTHUS
                       ,itempf.zcolmcls zcolmcls
                  FROM
                         Jd1dta.ZENDRPF zendrpf
                  INNER JOIN
                       (
                        SELECT
                              TRIM(itemitem) itemitem
                             ,SUBSTR(utl_raw.cast_to_varchar2(itempf.genarea),196,1) zcolmcls
                        FROM
                              Jd1dta.ITEMPF
                        WHERE
                              TRIM(itemtabl) = 'T3684'
                        AND   TRIM(itemcoy) IN (1, 9)
                        AND   TRIM(itempfx) = 'IT'
                        AND   TRIM(validflag)= '1'
                       ) itempf
                   ON TRIM(zendrpf.ZFACTHUS) = TRIM(itempf.itemitem)
                  ) src2
            ON TRIM(mstpol.ZENDCDE) = TRIM(src2.ZENDCDE)
           ) src3
           ON 
               TRIM(src1.chdrnum) = TRIM(src3.chdrnum)
           AND TRIM(src3.zcolmcls) = 'C'
     ) src
INNER JOIN STAGEDBUSR2.DM_POLICY_RECON@dmstgusr2dblink recon
ON TRIM(src.src_CHDRNUM) = TRIM(recon.V_POLICY_NO)	 
LEFT JOIN (
      SELECT
           CASE LENGTH(TRIM(stg1.chdrnum)) 
                WHEN 11 THEN SUBSTR(TRIM(stg1.chdrnum),4,8)
                ELSE TRIM(stg1.chdrnum)
           END stg_chdrnum
          ,TRIM(stg1.ZCRDTYPE) stg_ZCRDTYPE
          ,TRIM(stg1.ZCNBRFRM) stg_ZCNBRFRM
          ,TRIM(stg1.ZCNBRTO) stg_ZCNBRTO
          ,TRIM(stg1.ZMSTID) stg_ZMSTID
          ,TRIM(stg1.ZMSTSNME) stg_ZMSTSNME
          ,TRIM(stg1.ZMSTIDV) stg_ZMSTIDV
          ,TRIM(stg1.ZMSTSNMEV) stg_ZMSTSNMEV
          ,TRIM(stg1.ZCARDDC) stg_ZCARDDC
		  ,TRIM(stg3.CNTTYPE) stg_CNTTYPE
          ,TRIM(stg3.STATCODE) stg_STATCODE
		  ,TRIM(stg3.CCDATE) stg_CCDATE
          ---,TRIM(stg3.ZFACTHUS) ZFACTHUS  ---@@
          ----,TRIM(stg3.zcolmcls) zcolmcls  ---@@
      FROM
          STAGEDBUSR.TITDMGENDCTPF@dmstagedblink stg1
      INNER JOIN
           (
            SELECT
                  CASE LENGTH(TRIM(mstpol.chdrnum)) 
                       WHEN 11 THEN SUBSTR(TRIM(mstpol.chdrnum),4,8)
                       ELSE TRIM(mstpol.chdrnum)
                  END chdrnum
				 ,TRIM(mstpol.CNTTYPE) CNTTYPE
				 ,TRIM(mstpol.STATCODE) STATCODE
				 ,TRIM(mstpol.CCDATE) CCDATE
                 ,TRIM(mstpol.ZENDCDE) ZENDCDE
                 ,TRIM(stg2.ZFACTHUS) ZFACTHUS
                 ,TRIM(stg2.zcolmcls) zcolmcls
            FROM
                 STAGEDBUSR.TITDMGMASPOL@dmstagedblink mstpol
            LEFT JOIN
                 ( 
                  SELECT
                        TRIM(zendrpf.ZENDCDE) ZENDCDE
                       ,TRIM(zendrpf.ZFACTHUS) ZFACTHUS
                       ,itempf.zcolmcls zcolmcls
                  FROM
                         Jd1dta.ZENDRPF zendrpf
                  INNER JOIN
                       (
                        SELECT
                              TRIM(itemitem) itemitem
                             ,SUBSTR(utl_raw.cast_to_varchar2(itempf.genarea),196,1) zcolmcls
                        FROM
                              Jd1dta.ITEMPF
                        WHERE
                              TRIM(itemtabl) = 'T3684'
                        AND   TRIM(itemcoy) IN (1, 9)
                        AND   TRIM(itempfx) = 'IT'
                        AND   TRIM(validflag)= '1'
                       ) itempf
                   ON TRIM(zendrpf.ZFACTHUS) = TRIM(itempf.itemitem)
                  ) stg2
            ON TRIM(mstpol.ZENDCDE) = TRIM(stg2.ZENDCDE)
           ) stg3
           ON 
               TRIM(stg1.chdrnum) = TRIM(stg3.chdrnum)
           AND TRIM(stg3.zcolmcls) = 'C'
     ) stg
ON 
    TRIM(src.src_CHDRNUM) = TRIM(stg.stg_CHDRNUM)
AND DECODE(src_ZCRDTYPE,NULL,' ',src_ZCRDTYPE) = DECODE(stg_ZCRDTYPE,NULL,' ',stg_ZCRDTYPE)
AND DECODE(src_ZCNBRFRM,NULL,' ',src_ZCNBRFRM) = DECODE(stg_ZCNBRFRM,NULL,' ',stg_ZCNBRFRM)
AND DECODE(src_ZCNBRTO,NULL,' ',src_ZCNBRTO) = DECODE(stg_ZCNBRTO,NULL,' ',stg_ZCNBRTO)
AND DECODE(src_ZMSTID,NULL,' ',src_ZMSTID) = DECODE(stg_ZMSTID,NULL,' ',stg_ZMSTID)
AND DECODE(src_ZMSTSNME,NULL,' ',src_ZMSTSNME) = DECODE(stg_ZMSTSNME,NULL,' ',stg_ZMSTSNME)
AND DECODE(src_ZMSTIDV,NULL,' ',src_ZMSTIDV) = DECODE(stg_ZMSTIDV,NULL,' ',stg_ZMSTIDV)
AND DECODE(src_ZMSTSNMEV,NULL,' ',src_ZMSTSNMEV) = DECODE(stg_ZMSTSNMEV,NULL,' ',stg_ZMSTSNMEV)
AND DECODE(src_ZCARDDC,NULL,' ',src_ZCARDDC) = DECODE(stg_ZCARDDC,NULL,' ',stg_ZCARDDC)	 
LEFT JOIN
    (
     SELECT
          TRIM(ZPOLNMBR) zenctpf_chdrnum
         ,TRIM(ZCRDTYPE) zenctpf_ZCRDTYPE
         ,TRIM(ZCNBRFRM) zenctpf_ZCNBRFRM
         ,TRIM(ZCNBRTO) zenctpf_ZCNBRTO
         ,TRIM(ZMSTID) zenctpf_ZMSTID
         ,TRIM(ZMSTSNME) zenctpf_ZMSTSNME
         ,TRIM(ZMSTIDV) zenctpf_ZMSTIDV
         ,TRIM(ZMSTSNMEV) zenctpf_ZMSTSNMEV
         ,TRIM(ZCARDDC) zenctpf_ZCARDDC
     FROM
         Jd1dta.ZENCTPF
     WHERE
          JOBNM = 'G1ZDMSTPOL'
   ) zenctpf
ON
    TRIM(src.src_CHDRNUM) = TRIM(zenctpf.zenctpf_chdrnum)
AND DECODE(src_ZCRDTYPE,NULL,' ',src_ZCRDTYPE) = DECODE(zenctpf_ZCRDTYPE,NULL,' ',zenctpf_ZCRDTYPE)
AND DECODE(src_ZCNBRFRM,NULL,' ',src_ZCNBRFRM) = DECODE(zenctpf_ZCNBRFRM,NULL,' ',zenctpf_ZCNBRFRM)
AND DECODE(src_ZCNBRTO,NULL,' ',src_ZCNBRTO) = DECODE(zenctpf_ZCNBRTO,NULL,' ',zenctpf_ZCNBRTO)
AND DECODE(src_ZMSTID,NULL,' ',src_ZMSTID) = DECODE(zenctpf_ZMSTID,NULL,' ',zenctpf_ZMSTID)
AND DECODE(src_ZMSTSNME,NULL,' ',src_ZMSTSNME) = DECODE(zenctpf_ZMSTSNME,NULL,' ',zenctpf_ZMSTSNME)
AND DECODE(src_ZMSTIDV,NULL,' ',src_ZMSTIDV) = DECODE(zenctpf_ZMSTIDV,NULL,' ',zenctpf_ZMSTIDV)
AND DECODE(src_ZMSTSNMEV,NULL,' ',src_ZMSTSNMEV) = DECODE(zenctpf_ZMSTSNMEV,NULL,' ',zenctpf_ZMSTSNMEV)
AND DECODE(src_ZCARDDC,NULL,' ',src_ZCARDDC) = DECODE(zenctpf_ZCARDDC,NULL,' ',zenctpf_ZCARDDC)
WHERE
    DECODE(src_ZCRDTYPE,NULL,' ',src_ZCRDTYPE) <> DECODE(stg_ZCRDTYPE,NULL,' ',stg_ZCRDTYPE)
OR  DECODE(src_ZCNBRFRM,NULL,' ',src_ZCNBRFRM) <> DECODE(stg_ZCNBRFRM,NULL,' ',stg_ZCNBRFRM)
OR  DECODE(src_ZCNBRTO,NULL,' ',src_ZCNBRTO) <> DECODE(stg_ZCNBRTO,NULL,' ',stg_ZCNBRTO)
OR  DECODE(src_ZMSTID,NULL,' ',src_ZMSTID) <> DECODE(stg_ZMSTID,NULL,' ',stg_ZMSTID)
OR  DECODE(src_ZMSTSNME,NULL,' ',src_ZMSTSNME) <> DECODE(stg_ZMSTSNME,NULL,' ',stg_ZMSTSNME)
OR  DECODE(src_ZMSTIDV,NULL,' ',src_ZMSTIDV) <> DECODE(stg_ZMSTIDV,NULL,' ',stg_ZMSTIDV)
OR  DECODE(src_ZMSTSNMEV,NULL,' ',src_ZMSTSNMEV) <> DECODE(stg_ZMSTSNMEV,NULL,' ',stg_ZMSTSNMEV)
OR  DECODE(src_ZCARDDC,NULL,' ',src_ZCARDDC) <> DECODE(stg_ZCARDDC,NULL,' ',stg_ZCARDDC)
OR  DECODE(src_ZCRDTYPE,NULL,' ',src_ZCRDTYPE) <> DECODE(zenctpf_ZCRDTYPE,NULL,' ',zenctpf_ZCRDTYPE)
OR  DECODE(src_ZCNBRFRM,NULL,' ',src_ZCNBRFRM) <> DECODE(zenctpf_ZCNBRFRM,NULL,' ',zenctpf_ZCNBRFRM)
OR  DECODE(src_ZCNBRTO,NULL,' ',src_ZCNBRTO) <> DECODE(zenctpf_ZCNBRTO,NULL,' ',zenctpf_ZCNBRTO)
OR  DECODE(src_ZMSTID,NULL,' ',src_ZMSTID) <> DECODE(zenctpf_ZMSTID,NULL,' ',zenctpf_ZMSTID)
OR  DECODE(src_ZMSTSNME,NULL,' ',src_ZMSTSNME) <> DECODE(zenctpf_ZMSTSNME,NULL,' ',zenctpf_ZMSTSNME)
OR  DECODE(src_ZMSTIDV,NULL,' ',src_ZMSTIDV) <> DECODE(zenctpf_ZMSTIDV,NULL,' ',zenctpf_ZMSTIDV)
OR  DECODE(src_ZMSTSNMEV,NULL,' ',src_ZMSTSNMEV) <> DECODE(zenctpf_ZMSTSNMEV,NULL,' ',zenctpf_ZMSTSNMEV)
OR  DECODE(src_ZCARDDC,NULL,' ',src_ZCARDDC) <> DECODE(zenctpf_ZCARDDC,NULL,' ',zenctpf_ZCARDDC)
;	
	  
	TYPE typ_cur_d3query IS TABLE OF cur_d3query%ROWTYPE;
    cur_d3query_list typ_cur_d3query;
	
	TYPE attribute_names_array IS VARRAY(8) OF VARCHAR2(20);
    attribute_name attribute_names_array;
	
	TYPE src_values_array IS VARRAY(8) OF VARCHAR2(1000);
    src_value src_values_array;
  
    TYPE stg_values_array IS VARRAY(8) OF VARCHAR2(1000);
    stg_value stg_values_array;
  
    TYPE ig_values_array IS VARRAY(8) OF VARCHAR2(1000);
    ig_value ig_values_array;
  
    
BEGIN
 
/********************************************** ITR3 Changes **************************************************************
***************************************************************************************************************************
***************************************************************************************************************************/ 
------------------------------ START - MSTPOL 02 : Reconciliation for 24 D category attributes -----------------------------

 --------------------- START - Recon for 1-8 attributes -----------------------	
	    	 	
	OPEN cur_d1query;
	LOOP
    FETCH cur_d1query BULK COLLECT INTO cur_d1query_list LIMIT c_limit;
    FOR i IN 1..cur_d1query_list.COUNT LOOP 
	
	attribute_name     := attribute_names_array();
	src_value          := src_values_array();
	stg_value          := stg_values_array();
	ig_value           := ig_values_array();
	v_counter          := 0;
	
	
	----- (1)- CHDRNUM
	IF(cur_d1query_list(i).src_CHDRNUM != cur_d1query_list(i).stg_CHDRNUM OR cur_d1query_list(i).src_CHDRNUM != cur_d1query_list(i).gchd_CHDRNUM)  THEN
	v_counter                     := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)     := 'CHDRNUM';
	src_value(v_counter)          := cur_d1query_list(i).src_chdrnum;
	stg_value(v_counter)          := cur_d1query_list(i).stg_CHDRNUM;
	ig_value(v_counter)           := cur_d1query_list(i).gchd_CHDRNUM;
	END IF;
	
	----- (2)- CNTTYPE
	IF(cur_d1query_list(i).src_CNTTYPE != cur_d1query_list(i).stg_CNTTYPE OR cur_d1query_list(i).src_CNTTYPE != cur_d1query_list(i).gchd_CNTTYPE)  THEN
	v_counter                     := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)     := 'CNTTYPE';
	src_value(v_counter)          := cur_d1query_list(i).src_CNTTYPE;
	stg_value(v_counter)          := cur_d1query_list(i).stg_CNTTYPE;
	ig_value(v_counter)           := cur_d1query_list(i).gchd_CNTTYPE;
	END IF;
	
	----- (3)- STATCODE
	IF(cur_d1query_list(i).src_STATCODE != cur_d1query_list(i).stg_STATCODE OR cur_d1query_list(i).src_STATCODE != cur_d1query_list(i).gchd_STATCODE)  THEN
	v_counter                     := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)     := 'STATCODE';
	src_value(v_counter)          := cur_d1query_list(i).src_STATCODE;
	stg_value(v_counter)          := cur_d1query_list(i).stg_STATCODE;
	ig_value(v_counter)           := cur_d1query_list(i).gchd_STATCODE;
	END IF;
	
	----- (4)- PNDATE
	IF(cur_d1query_list(i).src_PNDATE != cur_d1query_list(i).stg_PNDATE OR cur_d1query_list(i).src_PNDATE != cur_d1query_list(i).gchd_PNDATE)  THEN
	v_counter                     := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)     := 'PNDATE';
	src_value(v_counter)          := cur_d1query_list(i).src_PNDATE;
	stg_value(v_counter)          := cur_d1query_list(i).stg_PNDATE;
	ig_value(v_counter)           := cur_d1query_list(i).gchd_PNDATE;
	END IF;
	
	----- (5)- ZENDCDE
	IF(cur_d1query_list(i).src_ZENDCDE != cur_d1query_list(i).stg_ZENDCDE OR cur_d1query_list(i).src_ZENDCDE != cur_d1query_list(i).gchppf_ZENDCDE)  THEN
	v_counter                     := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)     := 'ZENDCDE';
	src_value(v_counter)          := cur_d1query_list(i).src_ZENDCDE;
	stg_value(v_counter)          := cur_d1query_list(i).stg_ZENDCDE;
	ig_value(v_counter)           := cur_d1query_list(i).gchppf_ZENDCDE;
	END IF;
	
	----- (6)- PETNAME
	IF(cur_d1query_list(i).src_RRA2IG != cur_d1query_list(i).stg_RRA2IG OR cur_d1query_list(i).src_RRA2IG != cur_d1query_list(i).gchppf_PETNAME)  THEN
	v_counter                     := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)     := 'PETNAME';
	src_value(v_counter)          := cur_d1query_list(i).src_RRA2IG;
	stg_value(v_counter)          := cur_d1query_list(i).stg_RRA2IG;
	ig_value(v_counter)           := cur_d1query_list(i).gchppf_PETNAME;
	END IF;
		
	----- (7)- ZGRPCLS
	IF(cur_d1query_list(i).src_B8TJIG != cur_d1query_list(i).stg_B8TJIG OR cur_d1query_list(i).src_B8TJIG != cur_d1query_list(i).gchppf_ZGRPCLS)  THEN
	v_counter                     := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)     := 'ZGRPCLS';
	src_value(v_counter)          := cur_d1query_list(i).src_B8TJIG;
	stg_value(v_counter)          := cur_d1query_list(i).stg_B8TJIG;
	ig_value(v_counter)           := cur_d1query_list(i).gchppf_ZGRPCLS;
	END IF;
	
	----- (8)- ZPENDDT
	IF(cur_d1query_list(i).src_zpenddt != cur_d1query_list(i).stg_zpenddt OR cur_d1query_list(i).src_zpenddt != cur_d1query_list(i).gchppf_zpenddt)  THEN
	v_counter                     := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)     := 'ZPENDDT';
	src_value(v_counter)          := cur_d1query_list(i).src_zpenddt;
	stg_value(v_counter)          := cur_d1query_list(i).stg_zpenddt;
	ig_value(v_counter)           := cur_d1query_list(i).gchppf_zpenddt;
	END IF;
	

  ----------------- Insert data into recon detail table i.e. dm_master_pol_recon_det ------------------
	
	FOR j IN 1..attribute_name.count 
	LOOP
	INSERT INTO Jd1dta.dm_master_pol_recon_det (
                                    v_batch_id   -- (1)
                                   ,v_policy_no  -- (2)
                                   ,v_prod_cde  -- (3)
                                   ,v_pol_commdt  -- (4)
                                   ,v_attrib_name  -- (5)
                                   ,v_pol_status  -- (6)
                                   ,v_module_name  -- (7)
                                   ,v_eff_date  -- (8)
                                   ,v_eff_desc  -- (9)
                                   ,v_src_val  -- (10)
                                   ,v_stg_val -- (11)
                                   ,v_ig_val  -- (12)
                                   ,v_summary_batch_id  -- (13)
                                   ,d_created_on  -- (14)
                                   ,v_created_by  -- (15)
                                   ,v_job_name  -- (16)
                                   )
                            values (
                                   p_detail_batch_id -- (1)
                                  ,cur_d1query_list(i).src_CHDRNUM -- (2)
                                  ,cur_d1query_list(i).src_CNTTYPE -- (3)
                                  ,cur_d1query_list(i).src_CCDATE -- (4)
                                  ,attribute_name(j) -- (5)
                                  ,cur_d1query_list(i).src_STATCODE -- (6)
                                  ,c_module_name -- (7)
                                  ,cur_d1query_list(i).src_CCDATE ----v_eff_date -- (8)
                                  ,c_eff_desc ----v_eff_desc -- (9)
                                  ,src_value(j) -- (10)
                                  ,stg_value(j) -- (11)
                                  ,ig_value(j) -- (12)
                                  ,p_summary_batch_id -- (13)
                                  ,SYSDATE -- (14)
                                  ,c_created_by -- (15)
                                  ,c_job_name -- (16)
                                   );
								   
	END LOOP;				
    END LOOP;
    EXIT WHEN cur_d1query%notfound; 
    COMMIT;
    END LOOP;
    COMMIT;					
	
	CLOSE cur_d1query;
 --------------------- END - Recon for 1-8 attributes -----------------------	
	
 --------------------- START - Recon for 9-16 attributes -----------------------
	
	OPEN cur_d2query;
	LOOP
    FETCH cur_d2query BULK COLLECT INTO cur_d2query_list LIMIT c_limit;
    FOR i IN 1..cur_d2query_list.COUNT LOOP 
	
	attribute_name     := attribute_names_array();
	src_value          := src_values_array();
	stg_value          := stg_values_array();
	ig_value           := ig_values_array();
	v_counter          := 0;
	
	----- (9)- EFFDATE
	IF((cur_d2query_list(i).src_EFFDATE IS NULL AND (cur_d2query_list(i).stg_EFFDATE IS NOT NULL OR cur_d2query_list(i).gchipf_EFFDATE IS NOT NULL)) OR (cur_d2query_list(i).src_EFFDATE IS NOT NULL AND (cur_d2query_list(i).stg_EFFDATE IS NULL OR cur_d2query_list(i).gchipf_EFFDATE IS NULL)) OR cur_d2query_list(i).src_EFFDATE != cur_d2query_list(i).stg_EFFDATE OR cur_d2query_list(i).src_EFFDATE != cur_d2query_list(i).gchipf_EFFDATE)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'EFFDATE';
	src_value(v_counter)        := cur_d2query_list(i).src_EFFDATE;
	stg_value(v_counter)        := cur_d2query_list(i).stg_EFFDATE;
	ig_value(v_counter)         := cur_d2query_list(i).gchipf_EFFDATE;
	END IF;
	
	----- (10)- CCDATE
	IF(cur_d2query_list(i).src_CCDATE != cur_d2query_list(i).stg_CCDATE OR cur_d2query_list(i).src_CCDATE != cur_d2query_list(i).gchipf_CCDATE)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'CCDATE';
	src_value(v_counter)        := cur_d2query_list(i).src_CCDATE;
	stg_value(v_counter)        := cur_d2query_list(i).stg_CCDATE;
	ig_value(v_counter)         := cur_d2query_list(i).gchipf_CCDATE;
	END IF;
	
	----- (11)- ZAGPTNUM
	IF(cur_d2query_list(i).src_ZAGPTNUM != cur_d2query_list(i).stg_ZAGPTNUM OR cur_d2query_list(i).src_ZAGPTNUM != cur_d2query_list(i).gchipf_ZAGPTNUM)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZAGPTNUM';
	src_value(v_counter)        := cur_d2query_list(i).src_ZAGPTNUM;
	stg_value(v_counter)        := cur_d2query_list(i).stg_ZAGPTNUM;
	ig_value(v_counter)         := cur_d2query_list(i).gchipf_ZAGPTNUM;
	END IF;
		
	----- (12)- ZBLNKPOL
	IF(cur_d2query_list(i).src_ZBLNKPOL != cur_d2query_list(i).stg_ZBLNKPOL OR cur_d2query_list(i).src_ZBLNKPOL != cur_d2query_list(i).ztgmpf_ZBLNKPOL)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZBLNKPOL';
	src_value(v_counter)        := cur_d2query_list(i).src_ZBLNKPOL;
	stg_value(v_counter)        := cur_d2query_list(i).stg_ZBLNKPOL;
	ig_value(v_counter)         := cur_d2query_list(i).ztgmpf_ZBLNKPOL;
	END IF;
	
	----- (13)- ZNBALTPR
	IF((cur_d2query_list(i).src_ZNBALTPR IS NULL AND (cur_d2query_list(i).stg_ZNBALTPR IS NOT NULL OR cur_d2query_list(i).ztgmpf_ZNBALTPR IS NOT NULL)) OR (cur_d2query_list(i).src_ZNBALTPR IS NOT NULL AND (cur_d2query_list(i).stg_ZNBALTPR IS NULL OR cur_d2query_list(i).ztgmpf_ZNBALTPR IS NULL)) OR cur_d2query_list(i).src_ZNBALTPR != cur_d2query_list(i).stg_ZNBALTPR OR cur_d2query_list(i).src_ZNBALTPR != cur_d2query_list(i).ztgmpf_ZNBALTPR)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZNBALTPR';
	src_value(v_counter)        := cur_d2query_list(i).src_ZNBALTPR;
	stg_value(v_counter)        := cur_d2query_list(i).stg_ZNBALTPR;
	ig_value(v_counter)         := cur_d2query_list(i).ztgmpf_ZNBALTPR;
	END IF;
	
	----- (14)- ZBLADCD
	IF((cur_d2query_list(i).src_ZBLADCD IS NULL AND (cur_d2query_list(i).stg_ZBLADCD IS NOT NULL OR cur_d2query_list(i).zenctpf_ZBLADCD IS NOT NULL)) OR (cur_d2query_list(i).src_ZBLADCD IS NOT NULL AND (cur_d2query_list(i).stg_ZBLADCD IS NULL OR cur_d2query_list(i).zenctpf_ZBLADCD IS NULL)) OR cur_d2query_list(i).src_ZBLADCD != cur_d2query_list(i).stg_ZBLADCD OR cur_d2query_list(i).src_ZBLADCD != cur_d2query_list(i).zenctpf_ZBLADCD)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZBLADCD';
	src_value(v_counter)        := cur_d2query_list(i).src_ZBLADCD;
	stg_value(v_counter)        := cur_d2query_list(i).stg_ZBLADCD;
	ig_value(v_counter)         := cur_d2query_list(i).zenctpf_ZBLADCD;
	END IF;
	
	----- (15)- ZCCDE
	IF((cur_d2query_list(i).gchppf_ZCOLMCLS = 'C' AND cur_d2query_list(i).zenctpf_ZCCDE IS NOT NULL) OR (cur_d2query_list(i).gchppf_ZCOLMCLS = 'F' AND cur_d2query_list(i).src_RPTFPST = 'P' AND (cur_d2query_list(i).src_ZCCDE != cur_d2query_list(i).stg_ZCCDE OR cur_d2query_list(i).src_ZCCDE != cur_d2query_list(i).zenctpf_ZCCDE)) OR (cur_d2query_list(i).gchppf_ZCOLMCLS = 'F' AND cur_d2query_list(i).src_RPTFPST = 'F' AND cur_d2query_list(i).src_ZCCDE IS NULL AND cur_d2query_list(i).zenctpf_ZCCDE != '9') OR (cur_d2query_list(i).gchppf_ZCOLMCLS = 'F' AND cur_d2query_list(i).src_RPTFPST = 'F' AND cur_d2query_list(i).src_ZCCDE IS NOT NULL AND (cur_d2query_list(i).src_ZCCDE != cur_d2query_list(i).stg_ZCCDE OR cur_d2query_list(i).src_ZCCDE != cur_d2query_list(i).zenctpf_ZCCDE))) THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZCCDE';
	src_value(v_counter)        := cur_d2query_list(i).src_ZCCDE;
	stg_value(v_counter)        := cur_d2query_list(i).stg_ZCCDE;
	ig_value(v_counter)         := cur_d2query_list(i).zenctpf_ZCCDE;
	END IF;
		
	----- (16)- ZCONSGNM
	IF((cur_d2query_list(i).gchppf_ZCOLMCLS = 'C' AND cur_d2query_list(i).zenctpf_ZCONSGNM IS NOT NULL) OR (cur_d2query_list(i).gchppf_ZCOLMCLS = 'F' AND cur_d2query_list(i).src_RPTFPST = 'P' AND (cur_d2query_list(i).src_ZCONSGNM != cur_d2query_list(i).stg_ZCONSGNM OR cur_d2query_list(i).src_ZCONSGNM != cur_d2query_list(i).zenctpf_ZCONSGNM)) OR (cur_d2query_list(i).gchppf_ZCOLMCLS = 'F' AND cur_d2query_list(i).src_RPTFPST = 'F' AND cur_d2query_list(i).src_ZCONSGNM IS NULL AND cur_d2query_list(i).zenctpf_ZCONSGNM != '9') OR (cur_d2query_list(i).gchppf_ZCOLMCLS = 'F' AND cur_d2query_list(i).src_RPTFPST = 'F' AND cur_d2query_list(i).src_ZCONSGNM IS NOT NULL AND (cur_d2query_list(i).src_ZCONSGNM != cur_d2query_list(i).stg_ZCONSGNM OR cur_d2query_list(i).src_ZCONSGNM != cur_d2query_list(i).zenctpf_ZCONSGNM))) THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZCONSGNM';
	src_value(v_counter)        := cur_d2query_list(i).src_ZCONSGNM;
	stg_value(v_counter)        := cur_d2query_list(i).stg_ZCONSGNM;
	ig_value(v_counter)         := cur_d2query_list(i).zenctpf_ZCONSGNM;
	END IF;

  ----------------- Insert data into recon detail table i.e. dm_master_pol_recon_det ------------------
	
	FOR j IN 1..attribute_name.count 
	LOOP
	INSERT INTO Jd1dta.dm_master_pol_recon_det (
                                    v_batch_id   -- (1)
                                   ,v_policy_no  -- (2)
                                   ,v_prod_cde  -- (3)
                                   ,v_pol_commdt  -- (4)
                                   ,v_attrib_name  -- (5)
                                   ,v_pol_status  -- (6)
                                   ,v_module_name  -- (7)
                                   ,v_eff_date  -- (8)
                                   ,v_eff_desc  -- (9)
                                   ,v_src_val  -- (10)
                                   ,v_stg_val -- (11)
                                   ,v_ig_val  -- (12)
                                   ,v_summary_batch_id  -- (13)
                                   ,d_created_on  -- (14)
                                   ,v_created_by  -- (15)
                                   ,v_job_name  -- (16)
                                   )
                            values (
                                   p_detail_batch_id -- (1)
                                  ,cur_d2query_list(i).src_CHDRNUM -- (2)
                                  ,cur_d2query_list(i).src_CNTTYPE -- (3)
                                  ,cur_d2query_list(i).src_CCDATE -- (4)
                                  ,attribute_name(j) -- (5)
                                  ,cur_d2query_list(i).src_STATCODE -- (6)
                                  ,c_module_name -- (7)
                                  ,cur_d2query_list(i).src_CCDATE ----v_eff_date -- (8)
                                  ,c_eff_desc ----v_eff_desc -- (9)
                                  ,src_value(j) -- (10)
                                  ,stg_value(j) -- (11)
                                  ,ig_value(j) -- (12)
                                  ,p_summary_batch_id -- (13)
                                  ,SYSDATE -- (14)
                                  ,c_created_by -- (15)
                                  ,c_job_name -- (16)
                                   );
					
    END LOOP;
	END LOOP;
    EXIT WHEN cur_d2query%notfound; 
    COMMIT;
    END LOOP;
    COMMIT;					
	
	CLOSE cur_d2query;
 --------------------- END - Recon for 9-16 attributes -----------------------
 
 --------------------- START - Recon for 17-24 attributes -----------------------    
	
	OPEN cur_d3query;
	LOOP
    FETCH cur_d3query BULK COLLECT INTO cur_d3query_list LIMIT c_limit;
    FOR i IN 1..cur_d3query_list.COUNT LOOP 
	
	attribute_name     := attribute_names_array();
	src_value          := src_values_array();
	stg_value          := stg_values_array();
	ig_value           := ig_values_array();
	v_counter          := 0;
	
	----- (17)- ZCRDTYPE
	IF(cur_d3query_list(i).src_ZCRDTYPE != cur_d3query_list(i).stg_ZCRDTYPE OR cur_d3query_list(i).src_ZCRDTYPE != cur_d3query_list(i).zenctpf_ZCRDTYPE)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZCRDTYPE';
	src_value(v_counter)        := cur_d3query_list(i).src_ZCRDTYPE;
	stg_value(v_counter)        := cur_d3query_list(i).stg_ZCRDTYPE;
	ig_value(v_counter)         := cur_d3query_list(i).zenctpf_ZCRDTYPE;
	END IF;
	
	----- (18)- ZCNBRFRM
	IF(cur_d3query_list(i).src_ZCNBRFRM != cur_d3query_list(i).stg_ZCNBRFRM OR cur_d3query_list(i).src_ZCNBRFRM != cur_d3query_list(i).zenctpf_ZCNBRFRM)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZCNBRFRM';
	src_value(v_counter)        := cur_d3query_list(i).src_ZCNBRFRM;
	stg_value(v_counter)        := cur_d3query_list(i).stg_ZCNBRFRM;
	ig_value(v_counter)         := cur_d3query_list(i).zenctpf_ZCNBRFRM;
	END IF;
	
	----- (19)- ZCNBRTO
	IF(cur_d3query_list(i).src_ZCNBRTO != cur_d3query_list(i).stg_ZCNBRTO OR cur_d3query_list(i).src_ZCNBRTO != cur_d3query_list(i).zenctpf_ZCNBRTO)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZCNBRTO';
	src_value(v_counter)        := cur_d3query_list(i).src_ZCNBRTO;
	stg_value(v_counter)        := cur_d3query_list(i).stg_ZCNBRTO;
	ig_value(v_counter)         := cur_d3query_list(i).zenctpf_ZCNBRTO;
	END IF;
		
	----- (20)- ZMSTID
	IF(cur_d3query_list(i).src_ZMSTID != cur_d3query_list(i).stg_ZMSTID OR cur_d3query_list(i).src_ZMSTID != cur_d3query_list(i).zenctpf_ZMSTID)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZMSTID';
	src_value(v_counter)        := cur_d3query_list(i).src_ZMSTID;
	stg_value(v_counter)        := cur_d3query_list(i).stg_ZMSTID;
	ig_value(v_counter)         := cur_d3query_list(i).zenctpf_ZMSTID;
	END IF;
	
	----- (21)- ZMSTSNME
	IF(cur_d3query_list(i).src_ZMSTSNME != cur_d3query_list(i).stg_ZMSTSNME OR cur_d3query_list(i).src_ZMSTSNME != cur_d3query_list(i).zenctpf_ZMSTSNME)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZMSTSNME';
	src_value(v_counter)        := cur_d3query_list(i).src_ZMSTSNME;
	stg_value(v_counter)        := cur_d3query_list(i).stg_ZMSTSNME;
	ig_value(v_counter)         := cur_d3query_list(i).zenctpf_ZMSTSNME;
	END IF;
	
	----- (22)- ZMSTIDV
	IF(cur_d3query_list(i).src_ZMSTIDV != cur_d3query_list(i).stg_ZMSTIDV OR cur_d3query_list(i).src_ZMSTIDV != cur_d3query_list(i).zenctpf_ZMSTIDV)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZMSTIDV';
	src_value(v_counter)        := cur_d3query_list(i).src_ZMSTIDV;
	stg_value(v_counter)        := cur_d3query_list(i).stg_ZMSTIDV;
	ig_value(v_counter)         := cur_d3query_list(i).zenctpf_ZMSTIDV;
	END IF;
	
	----- (23)- ZMSTSNMEV
	IF(cur_d3query_list(i).src_ZMSTSNMEV != cur_d3query_list(i).stg_ZMSTSNMEV OR cur_d3query_list(i).src_ZMSTSNMEV != cur_d3query_list(i).zenctpf_ZMSTSNMEV)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZMSTSNMEV';
	src_value(v_counter)        := cur_d3query_list(i).src_ZMSTSNMEV;
	stg_value(v_counter)        := cur_d3query_list(i).stg_ZMSTSNMEV;
	ig_value(v_counter)         := cur_d3query_list(i).zenctpf_ZMSTSNMEV;
	END IF;
		
	----- (24)- ZCARDDC
	IF(cur_d3query_list(i).src_ZCARDDC != cur_d3query_list(i).stg_ZCARDDC OR cur_d3query_list(i).src_ZCARDDC != cur_d3query_list(i).zenctpf_ZCARDDC)  THEN
	v_counter                   := v_counter + 1;
	attribute_name.extend;
	src_value.extend;
	stg_value.extend;
	ig_value.extend;
	attribute_name(v_counter)   := 'ZCARDDC';
	src_value(v_counter)        := cur_d3query_list(i).src_ZCARDDC;
	stg_value(v_counter)        := cur_d3query_list(i).stg_ZCARDDC;
	ig_value(v_counter)         := cur_d3query_list(i).zenctpf_ZCARDDC;
	END IF;

  ----------------- Insert data into recon detail table i.e. dm_master_pol_recon_det ------------------
	
	FOR j IN 1..attribute_name.count 
	LOOP
	INSERT INTO Jd1dta.dm_master_pol_recon_det (
                                    v_batch_id   -- (1)
                                   ,v_policy_no  -- (2)
                                   ,v_prod_cde  -- (3)
                                   ,v_pol_commdt  -- (4)
                                   ,v_attrib_name  -- (5)
                                   ,v_pol_status  -- (6)
                                   ,v_module_name  -- (7)
                                   ,v_eff_date  -- (8)
                                   ,v_eff_desc  -- (9)
                                   ,v_src_val  -- (10)
                                   ,v_stg_val -- (11)
                                   ,v_ig_val  -- (12)
                                   ,v_summary_batch_id  -- (13)
                                   ,d_created_on  -- (14)
                                   ,v_created_by  -- (15)
                                   ,v_job_name  -- (16)
                                   )
                            values (
                                   p_detail_batch_id -- (1)
                                  ,cur_d3query_list(i).src_CHDRNUM -- (2)
                                  ,cur_d3query_list(i).src_CNTTYPE -- (3)
                                  ,cur_d3query_list(i).src_CCDATE -- (4)
                                  ,attribute_name(j) -- (5)
                                  ,cur_d3query_list(i).src_STATCODE -- (6)
                                  ,c_module_name -- (7)
                                  ,cur_d3query_list(i).src_CCDATE ----v_eff_date -- (8)
                                  ,c_eff_desc ----v_eff_desc -- (9)
                                  ,src_value(j) -- (10)
                                  ,stg_value(j) -- (11)
                                  ,ig_value(j) -- (12)
                                  ,p_summary_batch_id -- (13)
                                  ,SYSDATE -- (14)
                                  ,c_created_by -- (15)
                                  ,c_job_name -- (16)
                                   );
					
    END LOOP;
	END LOOP;
    EXIT WHEN cur_d3query%notfound; 
    COMMIT;
    END LOOP;
    COMMIT;
	
	CLOSE cur_d3query;
	
 --------------------- END - Recon for 17-24 attributes -----------------------
------------------------------ END - MSTPOL 02 : Reconciliation for 24 D category attributes -----------------------------
	
EXCEPTION
  WHEN OTHERS THEN
  
    p_exitcode := SQLCODE;
    p_exittext := ' Master Policy Reconciliation ' || ' ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;    

    insert_error_log (
                  in_error_code  =>  p_exitcode
                 ,in_error_message  => p_exittext
                 ,in_prog  => c_module_name
                 );
                 
   raise_application_error(-20001, p_exitcode || p_exittext);  
 
END DM_Mstpol_Recon_Set2;