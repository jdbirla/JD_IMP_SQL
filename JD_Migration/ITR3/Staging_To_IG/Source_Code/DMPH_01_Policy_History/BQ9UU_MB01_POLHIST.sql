create or replace PROCEDURE                                                                "BQ9UU_MB01_POLHIST" (i_scheduleName   IN VARCHAR2, 
                                                i_scheduleNumber IN VARCHAR2,
                                                i_zprvaldYN      IN VARCHAR2,
                                                i_company        IN VARCHAR2,
                                                i_usrprf         IN VARCHAR2,
                                                i_branch         IN VARCHAR2,
                                                i_transCode      IN VARCHAR2,
                                                i_vrcmTermid     IN VARCHAR2,
                                                i_array_size     IN PLS_INTEGER DEFAULT 1000,
                                                start_id         IN NUMBER,
                                                end_id           IN NUMBER)
 AUTHID current_user AS 
  /***************************************************************************************************
  * Amenment History: MB01 Policy Transaction
  * Date    Init   Tag   		Decription
  * -----   -----  ---   		---------------------------------------------------------------------------
  * MMMDD    XXX   PH1   		XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0501     SC    PH2   		Performance change for Dm rehearsal.
  * 0502     SC    PH3   		LOGIC CHANGED TO GET UNIQUE_NUMBER FROM PAZDCHPF(PREVIOUSLY ZCLNPF).
  * 0504     PS    PH4   		Bank Desc , Bank Key and Bank Acct Type for Credit Card needs to be taken from CLBAPF
  *                      		when Credit Card Number field is not null. TRANCDE must be set to T902 for first transation
  *                      		otherwise, it must be set to T912.
  * 0504     SC    PH5   		CHANGED FOR #7685 - [functional issue]screen validation incorrect. 
  * 0505     SC    PH6   		Length of columns ZCNBRFRM and ZCNBRTO of ZENCTPF is increased from 6 to 20.
  * 0505     SC    PH7   		Change for Tciket #7843 -Incorrect Fields on ZALTPF
  * 0507     SC    PH8   		ITR4 - LOT2 Changes
  * 0508     SC    PH9   		Changes For Ticket #7852 -Incorrect Fields on ZTRAPF
  * 0511     RC    PH10  		Data Verification Changes
  * 0512     PS    PH11  		Data Verification Changes
  * 0516     SJ    PH12  		Removed unused fields like company   
  * 0517     SJ    PH13  		Added check for ZCARDDC(card digit count) on ZENCTPF to get card type
  * 0528     SC    PH14  		ZDDREQNO field added in Policy History trsanction Module.
  * 0710     RC    PH15  		EFDATE for ZTRAPF
  * 1107     JDB   PH16  		Solution for converted policy
  * 0518     SK    PH17  		Implemented Logic to fetch limited records to avoid PGA memory issue   
  * 0721     PS    PH18  		PREAUTNO to accept null values
  ****************************************************************************************************
  *********  FOR PA DEVELOPMENT  *********************************************************************
  * AUG07    MKS   PH19  		PA development implementation
  * OCT30	 MKS   ZJNPG-8294 	Revmove extra space for OCCPCODE data if column has data.
  * NOV12	 MKS   ZJNPG-8385   Use the EFFDATE of latest TERMINATION transaction to identify value for ZVLDTRXIND instead of GCHD.EFFCLDT.
  * JAN26	 MKS   ZJNPG-8922   ITR2 DEFECT- Input 0 to ztrapf.ZREFUNDAM if no refund retrieved from titdmgref1
  *****************************************************************************************************
  *********  ITR3 PA DEVELOPMENT  *********************************************************************
  * FEB01    MKS   PH20  		ITR3PA development implementation
  * FEB11    MKS   PH21  		ITR2 Defect P2-5650 implementation
  * FEB16	 MKS   PH22         Fix for P2-5569 - removal of su-campain in gmhd AND fix for P2-5681 (yearto and monthto)
  * MAR02    MKS   PH23         Fix for P2-1739, validation for workplace 1 and 2 has been removed in IG
  * MAR03    MKS   PH24         Fix for ZJNPG-9103 post validation issues.
  * MAR12    MKS   PH25         Fix for ZJNPG-9718 EFDATE and ZLOGALTDT issue.  
  * MAR17    MKS   PH26         Fix for P2-5704 zinsdtlspf.ZINSDTHD defaulft value.
  * APR28	 MKS   PH27			Fix for ZJNPG-9443 - PJ Transfer Date issue.
  *****************************************************************************************************
  * FEB08	 MKS   PH28			Fix for ZJNPG-10343 and ZJNPG-10273 (P2-19319)
  * FEB28	 MKS   PH29			Code Change for ZJNPG-10449 - New Alter Reason Code mapping
  *****************************************************************************************************/
  ----------------------------VARIABLES DECLARATION START-----------------------------------------------
  v_timestart       NUMBER := dbms_utility.get_time; --Timecheck
  v_chdrnum         DMIGTITDMGPOLTRNH.CHDRNUM%TYPE;
  v_zseqno          DMIGTITDMGPOLTRNH.ZSEQNO%TYPE;
  v_effdate         DMIGTITDMGPOLTRNH.EFFDATE%TYPE;
  v_zaltregdat      DMIGTITDMGPOLTRNH.ZALTREGDAT%TYPE;
  v_zaltrcde01      DMIGTITDMGPOLTRNH.ZALTRCDE01%TYPE;
  v_zinhdsclm       DMIGTITDMGPOLTRNH.ZINHDSCLM%TYPE;
--v_zuwrejflg       DMIGTITDMGPOLTRNH.ZUWREJFLG%TYPE; -- PH20 - ITR3 - This column is removed in IG ztrapf table.
  v_ztrxstat        DMIGTITDMGPOLTRNH.ZTRXSTAT%TYPE;
  v_zstatresn       DMIGTITDMGPOLTRNH.ZSTATRESN%TYPE;
  v_zaclsdat        DMIGTITDMGPOLTRNH.ZACLSDAT%TYPE;
  v_apprdte         DMIGTITDMGPOLTRNH.APPRDTE%TYPE;     
  v_zpdatatxflg     DMIGTITDMGPOLTRNH.ZPDATATXFLG%TYPE;
  v_zrefundam       DMIGTITDMGPOLTRNH.ZREFUNDAM%TYPE;
  v_preautno        DMIGTITDMGPOLTRNH.PREAUTNO%TYPE;
  v_bnkacckey01     DMIGTITDMGPOLTRNH.BNKACCKEY01%TYPE;
  v_zenspcd01       DMIGTITDMGPOLTRNH.ZENSPCD01%TYPE;
  v_zenspcd02       DMIGTITDMGPOLTRNH.ZENSPCD02%TYPE;
  v_zcifcode        DMIGTITDMGPOLTRNH.ZCIFCODE%TYPE;
  v_bankaccdsc01    DMIGTITDMGPOLTRNH.BANKACCDSC01%TYPE;
  v_currto          DMIGTITDMGPOLTRNH.CURRTO%TYPE;
  v_mbrno           DMIGTITDMGPOLTRNH.MBRNO%TYPE;
  v_bankkey         DMIGTITDMGPOLTRNH.BANKKEY%TYPE;
  v_bnkactyp        DMIGTITDMGPOLTRNH.BNKACTYP01%TYPE;
  v_cltreln         DMIGTITDMGPOLTRNH.CLTRELN%TYPE;
  v_zworkplce2      DMIGTITDMGPOLTRNH.ZWORKPLCE2%TYPE;
  v_zinsrole        DMIGTITDMGPOLTRNH.ZINSROLE%TYPE;
  v_clientno        DMIGTITDMGPOLTRNH.CLIENTNO%TYPE;
  v_zddreqno        DMIGTITDMGPOLTRNH.ZDDREQNO%TYPE;
--  v_zconvpolno		DMIGTITDMGPOLTRNH.ZCONVPOLNO%TYPE;
  v_trancde			DMIGTITDMGPOLTRNH.TRANCDE%TYPE;
  v_zpdatatxdte		NUMBER(8,0);

  v_crdtcard        varchar2(16 char);
  v_temp_crdtcard 	varchar2(16 char);
  v_bnypcsum        NUMBER(5,2);
--i_text            DMLOG.LTEXT%type;
  v_zendcde         GCHPPF.ZENDCDE%type;
  v_zccflag         ZENCIPF.ZCCFLAG%type;
  v_zbnkflag        ZENCIPF.ZBNKFLAG%type;
  v_clientnum       PAZDCLPF.ZIGVALUE%type;
  v_bankaccdsc      CLBAPF.Bankaccdsc%type;
--v_bnkactyp        CLBAPF.Bnkactyp%type; PH19 : This will be direct mapping
--v_bankkey       	CLBAPF.Bankkey%type;  PH19 : This will be direct mapping
  v_mthto           CLBAPF.Mthto%type := 0;
  v_yearto          CLBAPF.Yearto%type := 0;
  v_zcrdtype        ZENCTPF.ZCRDTYPE%type;
  v_tranno          ZTRAPF.TRANNO%type;
  v_canctranno		ZTRAPF.TRANNO%type;
  i_fsucompany      CLBAPF.CLNTCOY%type := 9;
  v_unique_number01 NUMBER(18, 0) DEFAULT 0;
  v_unique_number02 NUMBER(18, 0) DEFAULT 0;  
  v_prv_polnum      ZTRAPF.CHDRNUM%type;
  v_last_tranno     ZTRAPF.TRANNO%type;
  v_isrecordexixts  NUMBER(1) DEFAULT 0;
  v_statcode        GCHD.STATCODE%type;
  v_mplnum          GCHD.MPLNUM%type;
  v_cownnum         GCHD.COWNNUM%type;
  v_refkey          VARCHAR2(50 CHAR);
  v_errorcount      NUMBER(1) DEFAULT 0;
  v_isvalid         NUMBER(1) DEFAULT 0;
  v_isdatevalid     VARCHAR2(20 CHAR);
  v_isduplicate     NUMBER(1) DEFAULT 0;
  v_isexist         NUMBER(1) DEFAULT 0;
  v_isanyerror      VARCHAR2(1) DEFAULT 'N';
  v_migrationprefix VARCHAR2(2);
  v_chdrpfx         VARCHAR2(20 CHAR);
  v_space           VARCHAR2(2) DEFAULT ' ';
  v_zero            NUMBER(2) DEFAULT 0;
  v_maxdate         NUMBER(8) DEFAULT 99999999;
  v_last_rowcnt     NUMBER DEFAULT 0;
--v_zigvalue        PAZDPTPF.ZIGVALUE%type;
  v_zcmpcode        GCHIPF.ZCMPCODE%type;
  v_agntnum         GCHIPF.AGNTNUM%type;
  v_zcpnscde       	DMIGTITDMGPOLTRNH.ZCPNSCDE%type; --PH22 : P2-5569
--v_zconvindpol   	GCHPPF.ZCONVINDPOL%type; PH19 : Default Null;
  v_zsalechnl      	GCHPPF.ZSALECHNL%type;
  v_zsolctflg      	GCHIPF.ZSOLCTFLG%type;
  v_ztrgtflg        AGNTPF.ZTRGTFLG%type;
  v_zplancde       	GMHIPF.ZPLANCDE%type;
--v_dcldate        	GMHIPF.DCLDATE%type;    PH19: moved to ZINSDTLSPF table
--v_zdclitem01     	GMHIPF.ZDCLITEM01%type; PH19: moved to ZINSDTLSPF table
--v_zdclitem02     	GMHIPF.ZDCLITEM02%type; PH19: moved to ZINSDTLSPF table
--v_zdeclcat       	GMHIPF.ZDECLCAT%type;   PH19: moved to ZINSDTLSPF table
  v_tranlused      	GCHD.TRANLUSED%type;
  v_effdcldt        GCHD.EFFDCLDT%type;
  v_ccdate         	gchipf.ccdate%type;
  v_efdatetemp     	ZTRAPF.EFDATE%type;
  v_daytempccdate  	VARCHAR(2);
  v_daytempeffdate 	VARCHAR(2);
  v_yearmonthtemp  	NUMBER(6);
  v_efdatefinal    	ZTRAPF.EFDATE%type;
  v_zrcaltty        ZTRAPF.ZRCALTTY%type;
  v_newefdate 	   	ZTRAPF.EFDATE%type;
  v_uniqdate        ZTRAPF.EFDATE%type;
  v_zvldtrxind      VARCHAR2(1) DEFAULT null;
  v_zplancls       	GCHPPF.ZPLANCLS%type; --TICKET- #7540- DM REHEARSAL-------
--v_temp_cownum     GCHD.COWNNUM%type;
--v_temp_effdate    ZTRAPF.EFFDATE%type;
--v_seqno_cl2       NUMBER DEFAULT 0;
--v_temp_seqno_cl2 	NUMBER DEFAULT 0;
  v_btdate          GCHD.BTDATE%type;       
--v_zdfcncy         GMHIPF.ZDFCNCY%type;  PH19: Not required
--v_zmargnflg       GMHIPF.ZMARGNFLG%type; PH19: Not required
  v_zpgpfrdt        GCHPPF.ZPGPFRDT%type;
  v_zpgptodt        GCHPPF.ZPGPTODT%type; 
--v_cltreln         GMHDPF.CLTRELN%type; PA: Removed Column      
  v_range_from      GCHD.chdrnum%type;
  v_range_to        GCHD.chdrnum%type;
--v_validflag       VARCHAR2(20 CHAR);
--v_zquotind        VARCHAR2(20 CHAR);
  v_dpntno          VARCHAR2(20 CHAR);
  v_gchieffdate     GCHIPF.EFFDATE%type;
  v_zpolperd        GCHIPF.ZPOLPERD%type;  
  v_zpoltdate       GCHPPF.ZPOLTDATE%type;
  v_occdate			GCHD.OCCDATE%type;  
  v_cltdob          CLNTPF.CLTDOB%type; 
  v_startdateMM     NUMBER(4);
  v_enddateMM       NUMBER(4);
  v_startdateYY     NUMBER(4);
  v_enddateYY       NUMBER(4);
  v_migdate			NUMBER(8,0);
--v_age             ZTRAPF.AGE%type; PH19: Removed in PA
  v_zworkplce1      ZCLNPF.ZWORKPLCE%type;
  v_dteatt          GCHIPF.CCDATE%type;
  v_clntnum         PAZDCLPF.ZIGVALUE%type;
  v_occpcode        VARCHAR2(4 CHAR) DEFAULT ' ';
  v_seqnumb         ZBENFDTLSPF.SEQNUMB%type;
  v_ztrxstsind      ZBENFDTLSPF.ZTRXSTSIND%type;
  v_tranbtdate      ZTRAPF.EFFDATE%type;
  v_zslptyp         ZSLPHPF.ZSLPTYP%type;
  v_zendscid		ZENDRPF.ZENDSCID%type;
  v_zacmcldt1		ZESDPF.ZACMCLDT%type;
  v_zacmcldt2		ZESDPF.ZACMCLDT%type;
  v_zbstcsdt03		ZESDPF.ZBSTCSDT03%type;
  v_zbstcsdt02  	ZESDPF.ZBSTCSDT02%type;
  v_canceffdate		ZTRAPF.EFFDATE%type;
  v_zsalplan		ZSLPPF.ZSALPLAN%type;
  v_old_pol         VARCHAR2(10);
  v_pkzmcipf		NUMBER(18,0);
  p_exitcode        NUMBER;
  p_exittext        VARCHAR2(1000);  

  ---PH20: New Variables--
  v_oldchdrnum		DMIGTITDMGPOLTRNH.CHDRNUM%TYPE;
  v_oldmbrno		DMIGTITDMGPOLTRNH.MBRNO%TYPE;
  v_oldzsalplan		ZSLPPF.ZSALPLAN%TYPE;
  v_bankdtls		VARCHAR2(40);
  v_endrsrdtls		VARCHAR2(200);
  v_mintranno		NUMBER(8,0);
  v_benoldpol		DMIGTITDMGPOLTRNH.CHDRNUM%TYPE;
  v_seqnum01		NUMBER(8,0);
  v_seqnum02		NUMBER(8,0);
----------------------------VARIABLES DECLARATION END----------------------------------------------------------------

  ----------------------------OBJECT FOR IG TABLES START----------------------------------------------------------
  obj_ztrapf        Jd1dta.VIEW_DM_ZTRAPF%rowtype;
  obj_zmcipf      	Jd1dta.ZMCIPF%rowtype;
  obj_pazdptpf    	Jd1dta.VIEW_DM_PAZDPTPF%rowtype;
  obj_zaltpf      	Jd1dta.VIEW_DM_ZALTPF%rowtype;
  obj_zinsdtlspf    Jd1dta.VIEW_DM_ZINSDTLSPF%rowtype;
  obj_zbenfdtlspf   Jd1dta.VIEW_DM_ZBENFDTLSPF%rowtype;
--obj_gchd        	pkg_common_dmmb_phst.OBJ_GCHD;
--obj_gchi        	pkg_common_dmmb_phst.OBJ_GCHI;
--obj_gmhi        	pkg_common_dmmb_phst.OBJ_GMHI;
--obj_gchp        	pkg_common_dmmb_phst.OBJ_GCHP;
--obj_gmhd        	pkg_common_dmmb_phst.OBJ_GMHD;
--obj_zencipf       pkg_common_dmmb_phst.OBJ_ZENCIPF;--PH2:CHANGE---
--obj_pazdclpf      pkg_common_dmmb_phst.OBJ_PAZDCLPF;
  obj_tq9mp         pkg_common_dmmb_phst.OBJ_TQ9MP;
--obj_zrefundam		pkg_common_dmmb_phst.OBJ_ZREFUNDAM;
  obj_canctran		pkg_common_dmmb_phst.OBJ_CANCTRAN; 
  obj_zesdpf		pkg_common_dmmb_phst.OBJ_ZESDPF;
  obj_zesdpf_bd		pkg_common_dmmb_phst.OBJ_ZESDPF_BD;
--obj_agntflg		pkg_common_dmmb_phst.OBJ_AGNTFLG;
--obj_zdchpf        pkg_common_dmmb_phst.OBJ_ZDCHPF;
--obj_clbapf_cc     pkg_common_dmmb_phst.OBJ_CLBAPF_CC;
--obj_clbapf_bn     pkg_common_dmmb_phst.OBJ_CLBAPF_BN;
  ----------------------------OBJECT FOR IG TABLES END------------------------------------------------------------

  --------------------------------CONSTANTS-----------------------------------------------------------------------
  c_prefix 	   CONSTANT VARCHAR2(2) := get_migration_prefix('PHST', i_company); /* Policy Transaction History  */
  C_limit	   PLS_INTEGER := i_array_size;
  -----------------------------ERROR CONSTANTS START--------------------------------------------------------------
  c_errorcount CONSTANT NUMBER := 5;
  c_Z101       CONSTANT VARCHAR2(4) := 'RQO7'; /*Policy not in IG */ --
  c_Z099       CONSTANT VARCHAR2(4) := 'RQO6'; /*Duplicated record found*/ --
  c_Z013       CONSTANT VARCHAR2(4) := 'RQLT'; /*Invalid Date*/--
  c_Z104       CONSTANT VARCHAR2(4) := 'RQOA'; /*Invalid Altr Reason code */--
  c_Z007       CONSTANT VARCHAR2(4) := 'RQLN'; /*Transaction Status not in TQ9FT*/ --
  c_Z008       CONSTANT VARCHAR2(4) := 'RQLO'; /*Status Reason not in TQ9FU */ --
  c_Z011       CONSTANT VARCHAR2(4) := 'RQQ1'; /*Credit Card No/Bank Account No/ Endorser specific code is blank*/ --
  c_Z075       CONSTANT VARCHAR2(4) := 'RQNJ'; /*Credit card is mandatory */ -- 
  c_RFTQ       CONSTANT VARCHAR2(4) := 'RFTQ'; /*Invalid Credit Card No*/ ---> striked out
  c_Z076       CONSTANT VARCHAR2(4) := 'RQNK'; /* PREAUTNO is mandatory */
  c_Z077       CONSTANT VARCHAR2(4) := 'RQNL'; /*BANKACCNO is mandatory*/ --
  c_RQLM       CONSTANT VARCHAR2(4) := 'RQLM'; /*Relation not in T3584*/ --   
  c_F826       CONSTANT VARCHAR2(4) := 'F826'; /*Bank account not on file */ ---> striked out
  c_RQNY       CONSTANT VARCHAR2(4) := 'RQNY'; /*ZCMPCODE is mandatory*/
  c_RQM1       CONSTANT VARCHAR2(4) := 'RQM1'; /*Campaign Code not valid*/
  c_E186       CONSTANT VARCHAR2(4) := 'E186'; /*Field must be entered*/
  c_RQLL       CONSTANT VARCHAR2(4) := 'RQLL'; /*Sales plan not in TQ9FW*/
  c_E631  	   CONSTANT VARCHAR2(4) := 'E631'; /*% must total 100%*/
  C_RSAZ 	   CONSTANT VARCHAR2(4) := 'RSAZ'; /*Only 2 Named Ins Allowd*/
  c_bq9uu      CONSTANT VARCHAR2(5) := 'BQ9UU';
  c_bq9sc      CONSTANT VARCHAR2(5) := 'BQ9SC';
  c_RQLI	   CONSTANT VARCHAR2(4) := 'RQLI'; /*Client not yet migrated*/
  c_RQLP       CONSTANT VARCHAR2(4) := 'RQLP'; /*Sales Plan not valid*/  
  -----------------------------ERROR CONSTANTS END----------------------------------------------------------------

  --------------------------COMMON FUNCTION START-----------------------------------------------------------------
  v_tablenametemp 	VARCHAR2(10);
  v_tablename     	VARCHAR2(10);
  itemexist       	pkg_dm_common_operations.itemschec;
  o_errortext     	pkg_dm_common_operations.errordesc;
  i_zdoe_info     	pkg_dm_common_operations.obj_zdoe;
  o_defaultvalues 	pkg_dm_common_operations.defaultvaluesmap;
--getclbaforcc    	pkg_common_dmmb_phst.clbatype;
--getclbaforbnk   	pkg_common_dmmb_phst.clbatype1;
--checkzdclpf       pkg_common_dmmb_phst.pazdclpftype;
--getgchd           pkg_common_dmmb_phst.gchdtype1;
--getgchipf         pkg_common_dmmb_phst.gchItype1;
--getgmhipf         pkg_common_dmmb_phst.gmhitype;
--getgchppf         pkg_common_dmmb_phst.gchptype;
--getgmhdpf         pkg_common_dmmb_phst.gmhdtype;
--getzdchpf         pkg_common_dmmb_phst.zdchpftype;
--getzencipf        pkg_common_dmmb_phst.zencipftype;
--checkdupl         pkg_common_dmmb_phst.phduplicate;        --Ticket #ZJNPG-9739 : RUAT perf improvement
--checkbank         pkg_common_dmmb_phst.bankdetails_type;   --Ticket #ZJNPG-9739 : RUAT perf improvement
--checkendorser		pkg_common_dmmb_phst.endorserdetails_type; --Ticket #ZJNPG-9739 : RUAT perf improvement
--clntdob           pkg_common_dmmb_phst.getclntdob;
--campcode          pkg_common_dmmb_phst.checkcampcode; --Ticket #ZJNPG-9739 : RUAT perf improvement
--gettq9mp          pkg_common_dmmb_phst.tq9mptype;
--getrefundam		pkg_common_dmmb_phst.zrefundamtype;
  getcanctran		pkg_common_dmmb_phst.canctrantype;
  getdzesdpf		pkg_common_dmmb_phst.zesdpftype;
  getdzesdpf_bd		pkg_common_dmmb_phst.zesdpftype_bd;
--getagntflg        pkg_common_dmmb_phst.getagntflg_type;


  TYPE ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  TYPE errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  TYPE errormsg_tab IS TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  TYPE errorfieldvalue_tab IS TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  TYPE errorprogram_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorprogram errorprogram_tab;
  --------------------------COMMON FUNCTION END-------------------------------------------------------------------

/* PH19: Not required for PA  
  getconpol      PKG_COMMON_DMMB_PHST.conpoltype; --PH16
  obj_getconpol  CONV_POL_HIST%rowtype; --PH16
  v_isconvpol    VARCHAR2(1 CHAR); --PH16
  v_ispolchnaged VARCHAR2(1 CHAR); --PH16
  v_prevpolno    DMIGTITDMGPOLTRNH.CHDRNUM%TYPE; --PH16
  TYPE checkstat IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50); --PH16
  a_checkpolst	 checkstat; --PH16
  v_splfound   	 VARCHAR2(1 CHAR); --PH16
  v_onlyspl		 VARCHAR2(1 CHAR); --PH16
  ----------------------------------------------------------------------------------------------------------------*/
  CURSOR cur_pol_hist IS
  ---START: PH20 - ITR3 Update CURSOR select statement for performance.---
  /*
	SELECT A.*, SUBSTR(utl_raw.cast_to_varchar2(C.GENAREA),6,4) ZRCALTTY
	 FROM Jd1dta.DMIGTITDMGPOLTRNH A 
     LEFT OUTER JOIN Jd1dta.ITEMPF C ON TRIM(C.ITEMITEM)=TRIM(A.ZALTRCDE01) AND  TRIM(C.ITEMTABL) = 'TQ9MP' 
		AND TRIM(C.ITEMCOY) IN (1, 9) AND TRIM(C.ITEMPFX) = 'IT' AND TRIM(C.VALIDFLAG)= '1'
	WHERE A.RECCHUNKSNUM BETWEEN start_id and end_id
	ORDER BY LPAD(A.CHDRNUM, 8, '0') ASC, LPAD(A.TRANNO, 3, '0') ASC; */
  ---START: PH20 - ITR3 Update CURSOR select statement for performance.---	
	SELECT * FROM Jd1dta.dmigtitdmgpoltrnh 
    WHERE recchunksnum BETWEEN start_id AND end_id
    ORDER BY LPAD(chdrnum, 8, '0') ASC ,
    LPAD(mbrno, 5, '0') ASC ,
    tranno ASC ;
  ---END: PH20 - ITR3 Update CURSOR select statement for performance.---	

  obj_polhistobj cur_pol_hist%rowtype; 
  TYPE t_polhist_list IS TABLE OF cur_pol_hist%rowtype;
  polhst_list t_polhist_list;

 BEGIN
/* PH19: We dont have converted policy for PA
 -------PH16:START------------
  DELETE FROM CONV_POL_HIST;
  INSERT INTO CONV_POL_HIST
    select *
      from ((select DISTINCT (chdrnum) as PH_CHDRNUM
               from titdmgpoltrnh@dmstagedblink) PH INNER JOIN
            (select chdrnum as GC_CHDRNUM, ZPRVCHDR
               from gchd
              where TRIM(ZPRVCHDR) is not null) GC on
            PH.PH_CHDRNUM = GC.GC_CHDRNUM)
     order by PH_CHDRNUM asc;
  PKG_COMMON_DMMB_PHST.getconpolinfo(getconpol => getconpol);
*/
  -------PH16:END------------
  --------------------------COMMON FUNCTION CALLING START-----------------------------------------------------------------------

  pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9UU,
                                     o_defaultvalues => o_defaultvalues);
  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMPH',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMPH',
                                        o_errortext   => o_errortext);
--pkg_common_dmmb_phst.checkgchppf(i_company    => i_company,         ---DM REHEARSAL PERFORMANCE----
--                                   checkZendcde => checkZendcde);     ---DM REHEARSAL PERFORMANCE----
--pkg_common_dmmb_phst.checkzdclpf(checkzdclpf => checkzdclpf); --PH12 commented as not required: discussed with Patrice May16
--pkg_common_dmmb_phst.getclbaforcc(getclbaforcc => getclbaforcc);
--pkg_common_dmmb_phst.getclbaforbnk(getclbaforbnk => getclbaforbnk);
--pkg_common_dmmb_phst.getgchd(getgchd => getgchd);
--pkg_common_dmmb_phst.getgchipf(getgchipf => getgchipf);
--pkg_common_dmmb_phst.getgmhipf(getgmhipf => getgmhipf);
--pkg_common_dmmb_phst.getgchppf(getgchppf => getgchppf);
--pkg_common_dmmb_phst.getgmhdpf(getgmhdpf => getgmhdpf);
--pkg_common_dmmb_phst.gettq9mp(gettq9mp => gettq9mp);
--pkg_common_dmmb_phst.getrefundam(getrefundam => getrefundam);
--pkg_common_dmmb_phst.checkcampcde(campcode => campcode); --Ticket #ZJNPG-9739 : RUAT perf improvement
  pkg_common_dmmb_phst.getcanctran(getcanctran => getcanctran);
  pkg_common_dmmb_phst.getdzesdpf(getdzesdpf => getdzesdpf);
  pkg_common_dmmb_phst.getdzesdpf_bd(getdzesdpf_bd => getdzesdpf_bd);
--pkg_common_dmmb_phst.getagntflg(getagntflg => getagntflg);

-------------PH3:START---------------------------------------------------------------------
----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF:  DM_REHEARSAL_PERFORMANCE: START------
--pkg_common_dmmb_phst.getzdchpf(getzdchpf => getzdchpf);
----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF:  DM_REHEARSAL_PERFORMANCE: END--------
-------------PH3:END---------------------------------------------------------------------
-------------PH2:START---------------------------------------------------------------------
--pkg_common_dmmb_phst.getzencipf(getzencipf => getzencipf);
-------------PH2:END-----------------------------------------------------------------------
-------------PH9: START-------------------------------------------------------------------  
--pkg_common_dmmb_phst.checkclntdob(clntdob => clntdob);
-------------PH9: END-------------------------------------------------------------------
--pkg_common_dmmb_phst.checkcpdup(checkdupl => checkdupl); --Ticket #ZJNPG-9739 : RUAT perf improvement
--pkg_common_dmmb_phst.checkbank(checkbank => checkbank);  --Ticket #ZJNPG-9739 : RUAT perf improvement
--pkg_common_dmmb_phst.checkendorser(checkendorser => checkendorser); --Ticket #ZJNPG-9739 : RUAT perf improvement
  v_tablenametemp := 'ZDOE' || trim(c_prefix) ||
                     lpad(trim(i_schedulenumber), 4, '0');
  v_tablename := trim(v_tablenametemp);
--pkg_dm_common_operations.createzdoepf(i_tablename => v_tablename);

---- [START] PH17  Implemented Logic to fetch limited records to avoid PGA memory issue
--  Select CHDRNUM_FROM, CHDRNUM_TO into v_range_from, v_range_to 
--      FROM MB01_POLHIST_RANGE;
---- [END] PH17  Implemented Logic to fetch limited records to avoid PGA memory issue
  --------------------------COMMON FUNCTION CALLING END-----------------------------------------------------------------------

  ------------------FETCH ALL DEFAULT ITEM FROM BQ9UU-----------------------------------------------------
  v_old_pol   := 'XX';
  v_dpntno    := o_defaultvalues('DPNTNO');
  v_benoldpol := 'XX';
  SELECT busdate INTO v_migdate FROM Jd1dta.busdpf WHERE company = '1';

  -----------------------------OPEN CURSOR------------------------------------------------------------------------------------
  OPEN cur_pol_hist;
  LOOP
  FETCH cur_pol_hist BULK COLLECT INTO polhst_list LIMIT C_limit;

  <<skiprecord>>
  	FOR i IN 1 .. polhst_list.COUNT LOOP

    obj_polhistobj := polhst_list(i);
    ---------------------------INITIALIZATION START----------------------------------------------------------------------------
    ----------------------------------------------------------
    v_chdrnum     	:= RTRIM(obj_polhistobj.CHDRNUM);
    v_zseqno      	:= RTRIM(obj_polhistobj.ZSEQNO);
    v_effdate     	:= RTRIM(obj_polhistobj.EFFDATE);
    v_zaltregdat  	:= RTRIM(obj_polhistobj.ZALTREGDAT);
    --TICKET- #7544- DM REHEARSAL STARTS-------------------
    v_zaltrcde01  	:= RTRIM(obj_polhistobj.ZALTRCDE01);
    --TICKET- #7544- DM REHEARSAL ENDS---------------------
    v_zinhdsclm   	:= RTRIM(obj_polhistobj.ZINHDSCLM);
--  v_zuwrejflg   	:= RTRIM(obj_polhistobj.ZUWREJFLG); -- PH20 - ITR3 - This column is removed in IG ztrapf table.
    v_ztrxstat    	:= RTRIM(obj_polhistobj.ZTRXSTAT);
    v_zstatresn   	:= RTRIM(obj_polhistobj.ZSTATRESN);
    v_zaclsdat    	:= RTRIM(obj_polhistobj.ZACLSDAT);
    v_apprdte     	:= RTRIM(obj_polhistobj.APPRDTE);
    v_zpdatatxdte 	:= RTRIM(obj_polhistobj.ZPDATATXDTE);
    v_zpdatatxflg 	:= RTRIM(obj_polhistobj.ZPDATATXFLG);
--- v_zpayinreq   	:= RTRIM(obj_polhistobj.ZPAYINREQ);
    v_crdtcard    	:= RTRIM(obj_polhistobj.CRDTCARD);
    v_preautno    	:= RTRIM(obj_polhistobj.PREAUTNO);
    v_bnkacckey01 	:= RTRIM(obj_polhistobj.BNKACCKEY01);
    v_zenspcd01   	:= RTRIM(obj_polhistobj.ZENSPCD01);
    v_zenspcd02   	:= RTRIM(obj_polhistobj.ZENSPCD02);
    v_zcifcode    	:= RTRIM(obj_polhistobj.ZCIFCODE);
    v_bankaccdsc01 	:= RTRIM(obj_polhistobj.BANKACCDSC01);
    v_currto		:= RTRIM(obj_polhistobj.CURRTO);
    v_mbrno			:= RTRIM(obj_polhistobj.MBRNO);
    v_bankkey		:= RTRIM(obj_polhistobj.BANKKEY);
    v_bnkactyp		:= RTRIM(obj_polhistobj.BNKACTYP01);
    v_cltreln		:= RTRIM(obj_polhistobj.CLTRELN);
    v_zworkplce2	:= RTRIM(obj_polhistobj.ZWORKPLCE2);
    v_zinsrole		:= RTRIM(obj_polhistobj.ZINSROLE);
    v_clientno		:= RTRIM(obj_polhistobj.CLIENTNO);
    v_tranno      	:= RTRIM(obj_polhistobj.TRANNO);
    v_tranbtdate	:= RTRIM(obj_polhistobj.BTDATE);
    v_zrcaltty		:= RTRIM(obj_polhistobj.ZRCALTTY);
	v_zrefundam   	:= RTRIM(obj_polhistobj.INTREFUND);
--	v_zconvpolno	:= RTRIM(obj_polhistobj.ZCONVPOLNO);
    v_zddreqno      := RTRIM(obj_polhistobj.ZDDREQNO);
    v_mthto			:= null;
    v_yearto        := null;

-------START: PH20 - ITR3 DATA from Source --------------------
    v_mintranno		:= RTRIM(obj_polhistobj.MINTRANNO);
	v_trancde   	:= RTRIM(obj_polhistobj.TRANCDE);
	v_clntnum   	:= RTRIM(obj_polhistobj.CLNTNUM);
	v_zsalplan  	:= RTRIM(obj_polhistobj.ZPLANCDE);
	--v_zsalplan		:= RTRIM(obj_polhistobj.ZSALPLAN);
	v_dteatt		:= RTRIM(obj_polhistobj.CCDATE);
	v_zcmpcode		:= RTRIM(obj_polhistobj.ZCMPCODE);
	v_zcpnscde		:= RTRIM(obj_polhistobj.ZCPNSCDE);
	v_zsalechnl		:= RTRIM(obj_polhistobj.ZSALECHNL);
	v_zsolctflg		:= RTRIM(obj_polhistobj.ZSOLCTFLG);
	v_zpolperd		:= RTRIM(obj_polhistobj.ZPOLPERD);
	v_zendcde		:= RTRIM(obj_polhistobj.ZENDCDE);
	v_zplancls		:= RTRIM(obj_polhistobj.ZPLANCLS); 
	v_zpgpfrdt    	:= RTRIM(obj_polhistobj.ZPGPFRDT); 
	v_zpgptodt    	:= RTRIM(obj_polhistobj.ZPGPTODT);
	v_cownnum   	:= RTRIM(obj_polhistobj.COWNNUM);
	v_statcode  	:= RTRIM(obj_polhistobj.STATCODE);
	v_tranlused 	:= RTRIM(obj_polhistobj.TRANLUSED);
	v_btdate    	:= RTRIM(obj_polhistobj.BTDATE_GCHD);  
	v_effdcldt  	:= RTRIM(obj_polhistobj.EFFDCLDT); 
	v_agntnum     	:= RTRIM(obj_polhistobj.AGNTNUM);
	v_zbnkflag  	:= RTRIM(obj_polhistobj.ZBNKFLAG);
	v_zccflag   	:= RTRIM(obj_polhistobj.ZCCFLAG);
	v_ztrgtflg  	:= RTRIM(obj_polhistobj.ZTRGTFLG);
	v_occdate		:= RTRIM(obj_polhistobj.OCCDATE);
	v_uniqdate		:= RTRIM(obj_polhistobj.UNIQDATE);
	v_zslptyp		:= RTRIM(obj_polhistobj.ZSLPTYP);
    v_zworkplce1 	:= RTRIM(obj_polhistobj.ZWORKPLCE);
	v_occpcode		:= RTRIM(obj_polhistobj.OCCPCODE);
	v_zendscid		:= RTRIM(obj_polhistobj.ZENDSCID);
    v_ccdate        := RTRIM(obj_polhistobj.CCDATE);
    v_zpoltdate     := RTRIM(obj_polhistobj.ZPOLTDATE);
	v_unique_number01 := RTRIM(obj_polhistobj.UNIQUE_NUMBER01);	
	v_unique_number02 := RTRIM(obj_polhistobj.UNIQUE_NUMBER02);

-------END: PH20 - ITR3 DATA from Source --------------------


    ----REFERENCE KEY FOR POLHIST WILL BE THE COMBINATION OF  CHDRNUM + ?g-?g + ZSEQNO + ?g-?g + EFFDATE FIELDS------
    v_refkey	  := v_chdrnum || '-' || v_zseqno || '-' || v_tranno || '-' || v_effdate || '-' || v_mbrno || '-' || v_zinsrole;
    --v_zigvalue	:= v_chdrnum || '-' || v_tranno || '-' || v_effdate;
    v_bnypcsum    := NVL(obj_polhistobj.B1_BNYPC, 0) + NVL(obj_polhistobj.B2_BNYPC, 0) + NVL(obj_polhistobj.B3_BNYPC, 0) +
					 NVL(obj_polhistobj.B4_BNYPC, 0) + NVL(obj_polhistobj.B5_BNYPC, 0);
    v_errorcount  := 0;
    t_ercode(1)   := NULL;
    t_ercode(2)   := NULL;
    t_ercode(3)   := NULL;
    t_ercode(4)   := NULL;
    t_ercode(5)   := NULL;

    v_isanyerror := 'N';
    i_zdoe_info              := NULL;
    i_zdoe_info.i_zfilename  := 'TITDMGPOLTRNH';
    i_zdoe_info.i_prefix     := c_prefix;
    i_zdoe_info.i_scheduleno := i_schedulenumber;
    i_zdoe_info.i_refkey     := v_refkey;
    i_zdoe_info.i_tablename  := v_tablename;
    ---------------------------INITIALIZATION END-------------------------------------------------------------------------------

/*	PH19: Converted Policy is not inscope for PA
    ----------------------PH16:START---------------------------------------
    v_onlyspl := 'F';
    IF (getconpol.exists(TRIM(v_chdrnum))) THEN
      v_isconvpol := 'T';
    else
      v_isconvpol := 'F';
    END IF;

    IF (a_checkpolst.exists(TRIM(v_chdrnum))) THEN
      v_ispolchnaged := 'F';
    else
      v_ispolchnaged := 'T';
      v_splfound     := 'F';

    END IF;
    a_checkpolst(TRIM(v_chdrnum)) := TRIM(v_chdrnum);
*/
/* -- PH19: Not required for PA
    ----CASE1:  New Business (when ZPRVCHDR is spaces) Transfer Flg N
    IF ((v_isconvpol = 'F') and (TRIM(v_zseqno) = '000') and
       (TRIM(v_zpdatatxflg) != 'Y')) THEN
      v_zpdatatxdte := null;
      v_zpdatatxflg := ' ';
    END IF;
*/
/* PH19: Not required for PA => new logic
    ----CASE2: New Business Policy - due to alteration ((‘P04’,‘P06’,‘P08’) and Transfer Flg N
    IF ((v_isconvpol = 'T') and
       ((TRIM(v_zaltrcde01) = 'P04') OR (TRIM(v_zaltrcde01) = 'P06') OR
       (TRIM(v_zaltrcde01) = 'P08')) and ((TRIM(v_zpdatatxflg) != 'Y'))) then
      v_zpdatatxdte := null;
      v_zpdatatxflg := ' ';
      v_splfound := 'T';
      v_onlyspl  := 'T';
    END IF;

    IF (v_splfound = 'T') then
      v_zpdatatxdte := null;
      v_zpdatatxflg := ' ';
      --  v_trancde     := 'T912';
      --  v_zquotind1   := 'A';
    END IF;

    ----CASE3:  New Business (when ZPRVCHDR is spaces) Transfer Flg  Y

    ----CASE4:New Business Policy - due to alteration ((‘P04’,‘P06’,‘P08’) and Transfer Flg Y

    ----------------------PH16:END---------------------------------------
*/	
    ---------------------------------------FETCH VALUES FROM COMMON FUNCTION-----------------------------------------------
/*	--TICKET- #7540- DM REHEARSAL STARTS-----------------------------
    IF (getgchppf.exists(v_chdrnum)) THEN
      obj_gchp      := getgchppf(v_chdrnum); --PH12
      --v_zconvindpol := obj_gchp.zconvindpol; PH:19 Default Null
      v_zendcde		:= obj_gchp.zendcde;
      v_zplancls	:= obj_gchp.zplancls; 
      v_zpgpfrdt    := obj_gchp.zpgpfrdt; 
      v_zpgptodt    := obj_gchp.zpgptodt;
      v_zpoltdate	:= obj_gchp.zpoltdate;
      --PH20 v_zsalechnl   := obj_gchp.zsalechnl; --PH19: get from gchppf
    END IF;
	--TICKET- #7540- DM REHEARSAL ENDS-------------------------------*/ --PH20: add to cursor

----------DM REHEARSAL PERFORMANCE: END------------------------------------------------------
/*    IF (getgchd.exists(v_chdrnum)) THEN
      obj_gchd    := getgchd(v_chdrnum); --PH12
      --v_clientnum := obj_gchd.cownnum; -- PH12 
      v_cownnum   := obj_gchd.cownnum;
      v_statcode  := obj_gchd.statcode;
      v_tranlused := obj_gchd.tranlused;
      v_btdate    := obj_gchd.btdate;  -- PH5
      v_effdcldt  := obj_gchd.effdcldt; -- PH19
    END IF; */ --PH20 - Add to cursor

-------------PH2:START-------------------------------------------------------------------
 /*   IF (RTRIM(v_zendcde) IS NOT NULL) THEN
        IF (getzencipf.exists(v_zendcde)) THEN
          obj_zencipf := getzencipf(v_zendcde);
          v_zbnkflag  := obj_zencipf.ZBNKFLAG;
          v_zccflag   := obj_zencipf.ZCCFLAG;
        END IF;
    END IF;*/ --PH20 - Add to cursor
-------------PH2:END---------------------------------------------------------------------

/*    --SIT CHNAGE START---
    IF (getgchipf.exists(v_chdrnum)) THEN
      obj_gchi		:= getgchipf(v_chdrnum); --PH12
      --PH20 v_zcmpcode	:= obj_gchi.zcmpcode;
      --PH20 v_zsolctflg	:= obj_gchi.zsolctflg;
      --PH20 v_ccdate		:= obj_gchi.ccdate;
      --PH20 v_zpolperd	:= obj_gchi.zpolperd;-- PH19
      v_agntnum     := obj_gchi.agntnum;-- PH19
    END IF; */ --PH20 - Add to cursor

	/*
    IF (getgmhipf.exists(v_chdrnum||v_mbrno)) THEN
      obj_gmhi := getgmhipf(v_chdrnum||v_mbrno); --PH12
   -- v_zcpnscde   := obj_gmhi.zcpnscde; --PH19
   --PH20   v_zplancde   := obj_gmhi.zplancde;
   -- v_dcldate    := obj_gmhi.dcldate;    PH19: Default Max date
   -- v_zdclitem01 := obj_gmhi.zdclitem01; PH19: Default null
   -- v_zdclitem02 := obj_gmhi.zdclitem02; PH19: Default null
   -- v_zdeclcat   := obj_gmhi.zdeclcat;
   -----------PH4: START------------------------- 
   -- v_zdfcncy    := obj_gmhi.zdfcncy;
   -- v_zmargnflg  := obj_gmhi.zmargnflg;
   -----------PH4: START------------------------- 
    END IF;
    */  --PH20 - Add to cursor
	/*
    IF (getagntflg.exists(TRIM(v_agntnum))) THEN
        obj_agntflg := getagntflg(TRIM(v_agntnum));
        v_ztrgtflg  := obj_agntflg.ZTRGTFLG;
    END IF; */  --PH20 - Add to cursor
	/*
    IF (getgmhdpf.exists(v_chdrnum || v_mbrno)) THEN
      obj_gmhd		:= getgmhdpf(v_chdrnum || v_mbrno); --PH12
    --PH20  v_zcpnscde	:= obj_gmhd.ZCPNSCDE;
    --PH20  v_dteatt		:= obj_gmhd.DTEATT;
    --  v_cltreln		:= obj_gmhd.CLTRELN;---PH7: New Column Added "CLTRELN" PH19: Removed Column
    END IF;
	*/
    --SIT CHNAGE END---  
	--unique_number01 determination logic
	/*
    IF v_effdate < v_zaltregdat THEN
      v_uniqdate 	:= v_zaltregdat;
    ELSE
      v_uniqdate	:= v_effdate;
    END IF;*/  --PH20 - Add to cursor

	/* PH20: ITR3 - Join pazdclpf direcltly in TITDMGPOLTRNH to get the data.
    IF checkzdclpf.exists(TRIM(v_clientno)) THEN
      obj_pazdclpf := checkzdclpf(TRIM(v_clientno));
      v_clntnum	:= TRIM(obj_pazdclpf.ZIGVALUE);
    END IF;	
	*/
/*	
    SELECT MIN(UNIQUE_NUMBER), MIN(ZWORKPLCE) into v_unique_number01, v_zworkplce1 
    FROM Jd1dta.zclnpf WHERE TRIM(CLNTNUM) = TRIM(v_cownnum) AND TRIM(EFFDATE) <= TRIM(v_uniqdate) AND ROWNUM = '1';

    SELECT MIN(UNIQUE_NUMBER), MIN(OCCPCODE) into v_unique_number02, v_occpcode
    FROM Jd1dta.zclnpf WHERE TRIM(CLNTNUM) = v_clntnum AND TRIM(EFFDATE) <= TRIM(v_uniqdate) AND ROWNUM = '1';
*/
	--SELECT ZENDSCID INTO v_zendscid FROM Jd1dta.ZENDRPF WHERE TRIM(ZENDCDE) = TRIM(v_zendcde); --PH20 - Add to cursor

	/*ZJNPG-8385 = incorrect logic as per IG.
    -- Valid transaction indicator determination logic
    IF v_effdate >= v_effdcldt THEN
      v_zvldtrxind := 'Y';
    ELSE
      v_zvldtrxind := null;
    END IF;
	*/

    -- Month To and Year To determination (Direct mapping from CURRTO)
	--Start PH22: P2-5681 fix for yearto and monthto--
	IF v_currto <> v_maxdate THEN
		v_mthto 	:= TO_NUMBER(SUBSTR(v_currto,5,2));
		v_yearto	:= TO_NUMBER(SUBSTR(v_currto,3,2));
	ELSE
		v_mthto		:= o_defaultvalues('MTHTO');
		v_yearto	:= o_defaultvalues('YEARTO');
	END IF;
	--END PH22: P2-5681 fix for yearto and monthto--

	IF (TRIM(v_crdtcard) IS NOT NULL) THEN
      BEGIN
        IF (v_chdrnum IS NOT NULL) THEN
          --IF (getgchd.exists(v_chdrnum)) THEN  --PH12
          --  obj_gchd := getgchd(v_chdrnum);  --PH12
            v_mplnum := obj_polhistobj.mplnum;
          --END IF;
        END IF;

        v_temp_crdtcard := v_crdtcard;
        IF (TRIM(v_mplnum) IS NOT NULL) THEN   
          SELECT DISTINCT ZCRDTYPE
            into v_zcrdtype
            FROM ZENCTPF
           WHERE TRIM(ZPOLNMBR) = TRIM(v_mplnum)
             and ((TRIM(ZCNBRFRM) < TRIM(v_temp_crdtcard) and
                  TRIM(ZCNBRTO) > TRIM(v_temp_crdtcard)) OR
                  TRIM(ZCNBRFRM) = TRIM(v_temp_crdtcard) and
                  TRIM(ZCNBRTO) = TRIM(v_temp_crdtcard)) AND 
                  ZCARDDC = length(v_temp_crdtcard);
        ELSE
          SELECT DISTINCT ZCRDTYPE
            into v_zcrdtype
            FROM ZENCTPF
           WHERE TRIM(ZENDCDE) = TRIM(v_zendcde) --get the value of this zendcode from map
             AND ((TRIM(ZCNBRFRM) < TRIM(v_temp_crdtcard) and
                  TRIM(ZCNBRTO) > TRIM(v_temp_crdtcard)) OR
                  TRIM(ZCNBRFRM) = TRIM(v_temp_crdtcard) OR
                  TRIM(ZCNBRTO) = TRIM(v_temp_crdtcard))
              AND ZCARDDC = length(v_temp_crdtcard)
			  AND RTRIM(ZPOLNMBR) IS NULL; --jTicket #ZJNPG-9739:  Zpolnmbr must be null for selection. 
        END IF;

      EXCEPTION
        WHEN No_data_found THEN  
          v_zcrdtype := null;
      END;
    ELSE
      v_zcrdtype := ' ';
    END IF;

	--START - PH20: Intialization for Bank Details Validation 
	v_bankdtls := NULL;
	IF TRIM(v_bnkacckey01) IS NOT NULL THEN
		v_bankdtls := TRIM(v_bnkacckey01) || '-' || TRIM(v_bankkey);
	END IF;

	IF TRIM(v_crdtcard) IS NOT NULL THEN
		v_bankdtls := TRIM(v_crdtcard) || '-' || TRIM(v_bankkey);
	END IF;
	--END - PH20: Intialization Bank Details Validation 

	--START - PH20: Intialization for Endorser Details Validation 
	v_endrsrdtls := NULL;
	IF (TRIM(v_zenspcd01) IS NOT NULL) OR (TRIM(v_zenspcd02) IS NOT NULL) OR (TRIM(v_zcifcode) IS NOT NULL) THEN
		v_endrsrdtls := TRIM(v_cownnum) || '-' || TRIM(v_zendcde) || '-' || TRIM(v_zenspcd01) || '-' || TRIM(v_zenspcd02) || '-' || TRIM(v_zcifcode);
	END IF;		
	--END - PH20: Intialization forEndorser Details Validation 

    -----------------------------------------------------------------------------------------------------------------------
    --[START] VALIDATE ALL FIELDS COMING FROM STAGE DB - TITDMGPOLTRNH-----------------------------------------------------
    ------VALIDATION - CHDRNUM "Policy Number must be already migrated". --------------------------------------------------
    IF TRIM(v_statcode) IS NULL THEN --PH12 --PH20-check if policy exist in gchd
      v_isAnyError 					:= 'Y';
      v_errorCount 					:= v_errorCount + 1;
      t_ercode(v_errorCount) 		:= c_Z101;
      t_errorfield(v_errorCount) 	:= 'CHDRNUM';
      t_errormsg(v_errorCount) 		:= o_errortext(c_Z101);
      t_errorfieldval(v_errorCount) := v_chdrnum;
      t_errorprogram(v_errorCount) 	:= i_scheduleName;
      IF v_errorCount >= C_ERRORCOUNT THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ------VALIDATION -CHDRNUM +TRANNO + ZALTREGDAT "Check duplicate record." ----------------------------------------------------------
    --IF (checkdupl.exists(TRIM(v_refkey))) THEN      --Ticket #ZJNPG-9739 : RUAT perf improvement
    IF TRIM(obj_polhistobj.PAZ_REC) IS NOT NULL THEN  --Ticket #ZJNPG-9739 : RUAT perf improvement - move to cursor
      v_isanyerror                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := c_Z099;
      i_zdoe_info.i_errormsg01     := o_errortext(c_Z099);
      i_zdoe_info.i_errorfield01   := 'REFKEY';
      i_zdoe_info.i_fieldvalue01   := v_refkey;
      i_zdoe_info.i_errorprogram01 := i_schedulename;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skiprecord;
    END IF;

    ------VALIDATION - EFFDATE "Must be a valid date and in correct format YYYYMMDD"----------------------------------------------------------
    v_isdatevalid := validate_date(v_effdate);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_Z013;
      t_errorfield(v_errorcount) 	:= 'EFFDATE';
      t_errormsg(v_errorcount) 		:= o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_effdate;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ------VALIDATION - ZALTREGDAT "Must be a valid date and in correct format YYYYMMDD"----------------------------------------------------------
    v_isdatevalid := validate_date(v_zaltregdat);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_Z013;
      t_errorfield(v_errorcount) 	:= 'ZALTREGDAT';
      t_errormsg(v_errorcount) 		:= o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_zaltregdat;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ------VALIDATION - ZALTRCDE01 "Must be in TQ9MP"----------------------------------------------------------

    /*IF (v_zaltrcde01 IS NULL) THEN
        IF (TO_NUMBER(v_zseqno) <> 0) THEN
          v_isanyerror := 'Y';
          v_errorcount := v_errorcount + 1;
          t_ercode(v_errorcount) := c_Z104;
          t_errorfield(v_errorcount) := 'ZALTRCDE01';
          t_errormsg(v_errorcount) := o_errortext(c_Z104);
          t_errorfieldval(v_errorcount) := v_zaltrcde01;
          t_errorprogram(v_errorcount) := i_schedulename;
         IF v_errorcount >= c_errorcount THEN
            GOTO insertzdoe;
         END IF;
         END IF;
    ELSE  */
    ---01/03/2018 Chage suggested by abhishek done by birla

-------------PH2:START-------------------------------------------------------------------
--TICKET- #7544 DM REHEARSAL START----------------------------------------------------------------

--    IF (v_zaltrcde01 IS NOT NULL) THEN
--      IF NOT
--          (itemexist.EXISTS(trim('TQ9MP') || trim(v_zaltrcde01) || i_company)) THEN
--        v_isanyerror := 'Y';
--        v_errorcount := v_errorcount + 1;
--        t_ercode(v_errorcount) := c_Z104;
--        t_errorfield(v_errorcount) := 'ZALTRCDE01';
--        t_errormsg(v_errorcount) := o_errortext(c_Z104);
--        t_errorfieldval(v_errorcount) := v_zaltrcde01;
--        t_errorprogram(v_errorcount) := i_schedulename;
--        IF v_errorcount >= c_errorcount THEN
--          GOTO insertzdoe;
--        END IF;
--      END IF;
--    END IF;

    IF (TRIM(v_zaltrcde01) IS NOT NULL) THEN
      IF NOT
          (itemexist.EXISTS(trim('TQ9MP') || trim(v_zaltrcde01) || i_company)) THEN
        v_isanyerror 					:= 'Y';
        v_errorcount 					:= v_errorcount + 1;
        t_ercode(v_errorcount) 			:= c_Z104;
        t_errorfield(v_errorcount) 		:= 'ZALTRCDE01';
        t_errormsg(v_errorcount) 		:= o_errortext(c_Z104);
        t_errorfieldval(v_errorcount) 	:= v_zaltrcde01;
        t_errorprogram(v_errorcount) 	:= i_schedulename;
        IF v_errorcount >= c_errorcount THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;

--TICKET- #7544 DM REHEARSAL END--------------------------------------------------------------- 
-------------PH2:END-------------------------------------------------------------------

    ------VALIDATION - ZTRXSTAT "Must be in TQ9FT"----------------------------------------------------------
    IF NOT
        (itemexist.EXISTS(trim('TQ9FT') || trim(v_ztrxstat) || i_company)) THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_Z007;
      t_errorfield(v_errorcount) 	:= 'ZTRXSTAT';
      t_errormsg(v_errorcount) 		:= o_errortext(c_Z007);
      t_errorfieldval(v_errorcount) := v_ztrxstat;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ------VALIDATION - ZSTATRESN "Must be in TQ9FU"---------------------------------------------------------- 

    IF (v_zstatresn IS NOT NULL) THEN
      IF NOT
          (itemexist.EXISTS(trim('TQ9FU') || trim(v_zstatresn) || i_company)) THEN
        v_isanyerror 					:= 'Y';
        v_errorcount 					:= v_errorcount + 1;
        t_ercode(v_errorcount) 			:= c_Z008;
        t_errorfield(v_errorcount) 		:= 'ZSTATRESN';
        t_errormsg(v_errorcount) 		:= o_errortext(c_Z008);
        t_errorfieldval(v_errorcount) 	:= v_zstatresn;
        t_errorprogram(v_errorcount) 	:= i_schedulename;
        IF v_errorcount >= c_errorcount THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;

	IF (TRIM(v_zplancls) = 'FP') THEN  
      IF ((v_crdtcard IS NULL) AND (v_zenspcd01 IS NULL) AND
       (v_zenspcd02 IS NULL) AND (TRIM(v_zcifcode) IS NULL)) THEN
        v_isAnyError 					:= 'Y';
        v_errorCount 					:= v_errorCount + 1;
        t_ercode(v_errorCount) 			:= c_Z011;
        t_errorfield(v_errorCount) 		:= 'CRDTCARD';
        t_errormsg(v_errorCount) 		:= o_errortext(c_Z011);
        t_errorfieldval(v_errorCount) := v_crdtcard;
        t_errorprogram(v_errorCount) 	:= i_scheduleName;
        IF v_errorCount >= C_ERRORCOUNT THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;
    ------VALIDATION - CRDTCARD "At least one of the 3 fields (Credit Card No, Bank Account No and Endorser Specific Code) is mandatory."-----
    --COMBINING ALL THREE VALIDATION RATHER THAN CHECKING INDIVIDUALLY---
    --VALIDATION - CRDTCARD + VALIDATION - BNKACCKEY01 + VALIDATION - ZENSPCD01----------
    IF (TRIM(v_zplancls) <> 'FP') THEN  
      IF ((v_crdtcard IS NULL) AND (v_bnkacckey01 IS NULL) AND
       (v_zenspcd01 IS NULL)) THEN
        v_isAnyError 					:= 'Y';
        v_errorCount 					:= v_errorCount + 1;
        t_ercode(v_errorCount) 		:= c_Z011;
        t_errorfield(v_errorCount) 	:= 'CRDTCARD';
        t_errormsg(v_errorCount) 		:= o_errortext(c_Z011);
        t_errorfieldval(v_errorCount) := v_crdtcard;
        t_errorprogram(v_errorCount) 	:= i_scheduleName;
        IF v_errorCount >= C_ERRORCOUNT THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;

-------------PH2:START-------------------------------------------------------------------    
-----------------TICKET- #7540- DM REHEARSAL STARTS-----------------------------   
	------VALIDATION - ZENDCDE and CRDTCARD "Check if Credit Card is Mandatory as per Endorser"----------------------------------
    IF (TRIM(v_zplancls) <> 'FP') THEN  --FOR FREE PLAN DO NOT PERFORM VALIDATION
      IF (RTRIM(v_zccflag) IS NOT NULL) THEN
        IF (RTRIM(v_zccflag) = 'Y' AND v_crdtcard IS NULL) THEN
          v_isAnyError 					:= 'Y';
          v_errorCount 					:= v_errorCount + 1;
          t_ercode(v_errorCount) 		:= c_Z075;
          t_errorfield(v_errorCount) 	:= 'CRDTCARD';
          t_errormsg(v_errorCount) 		:= o_errortext(c_Z075);
          t_errorfieldval(v_errorCount) := v_crdtcard;
          t_errorprogram(v_errorCount) 	:= i_scheduleName;
          IF v_errorCount >= C_ERRORCOUNT THEN
            GOTO insertzdoe;
          END IF;
        END IF;
      END IF;
    END IF;
----------------TICKET- #7540- DM REHEARSAL ENDS-----------------------------
-------------PH2:END-------------------------------------------------------------------
/* PH19: This validation is striked out for PA
    ------VALIDATION - CRDTCARD "If Credit card is not blank, it must be already present in Client bank database (CLBAPF)."----
    IF (v_crdtcard IS NOT NULL) THEN
      IF NOT (getclbaforcc.EXISTS(v_crdtcard || v_clientnum)) THEN  --PH12
        v_isAnyError 					:= 'Y';
        v_errorCount 					:= v_errorCount + 1;
        t_ercode(v_errorCount) 			:= c_RFTQ;
        t_errorfield(v_errorCount) 		:= 'CRDTCARD';
        t_errormsg(v_errorCount) 		:= o_errortext(c_RFTQ);
        t_errorfieldval(v_errorCount) 	:= v_crdtcard;
        t_errorprogram(v_errorCount) 	:= i_scheduleName;
        IF v_errorCount >= C_ERRORCOUNT THEN
          GOTO insertzdoe;
        END IF;
      END IF;
      -- END IF;
    END IF; */
    ------- PH 18 START -----------
    ------VALIDATION - PREAUTNO "CRDTCARD (Credit card) is not blank, but PREAUTNO (Card Approval No.) is blank"---------------
    --IF ((v_crdtcard IS NOT NULL) AND (v_preautno IS NULL)) THEN
    --  v_isAnyError := 'Y';
    --  v_errorCount := v_errorCount + 1;
    --  t_ercode(v_errorCount) := c_Z076;
    --  t_errorfield(v_errorCount) := 'PREAUTNO';
    --  t_errormsg(v_errorCount) := o_errortext(c_Z076);
    --  t_errorfieldval(v_errorCount) := v_preautno;
    --  t_errorprogram(v_errorCount) := i_scheduleName;
    --  IF v_errorCount >= C_ERRORCOUNT THEN
    --    GOTO insertzdoe;
    --  END IF;
    --END IF;
    ------- PH 18 END -----------
-------------PH2:START-------------------------------------------------------------------    
--------------------TICKET- #7540- DM REHEARSAL STARTS----------------------------- 
------VALIDATION - ZENDCDE and BNKACCKEY01 "Check if Bank Account No is Mandatory as per Endorser"---------------
    IF (TRIM(v_zplancls) <> 'FP') THEN  --FOR FREE PLAN DO NOT PERFORM VALIDATION
      IF (RTRIM(v_zbnkflag) IS NOT NULL) THEN
        IF (RTRIM(v_zbnkflag) = 'Y' AND v_bnkacckey01 IS NULL) THEN
          v_isAnyError 					:= 'Y';
          v_errorCount 					:= v_errorCount + 1;
          t_ercode(v_errorCount) 		:= c_Z077;
          t_errorfield(v_errorCount) 	:= 'BNKACCKEY1'; -- changed "BNKACCKEY01"  to "BNKACCKEY1" as max field length is 10.
          t_errormsg(v_errorCount) 		:= o_errortext(c_Z077);
          t_errorfieldval(v_errorCount) := v_bnkacckey01;
          t_errorprogram(v_errorCount) 	:= i_scheduleName;
          IF v_errorCount >= C_ERRORCOUNT THEN
            GOTO insertzdoe;
          END IF;
        END IF;
      END IF;
    END IF;  
-------------------------TICKET- #7540- DM REHEARSAL ENDS-----------------------------    
-------------PH2:END-------------------------------------------------------------------
/* PH:19 Not required for PA
    ------VALIDATION - BNKACCKEY01 "If Bank Account No is not blank, it must be already present in Client bank database (CLBAPF)."---PH19PRE
    IF (v_bnkacckey01 IS NOT NULL) THEN
      IF NOT (getclbaforbnk.EXISTS(v_bnkacckey01 || v_clientnum)) THEN --PH12
        v_isAnyError := 'Y';
        v_errorCount := v_errorCount + 1;
        t_ercode(v_errorCount) := c_F826;
        t_errorfield(v_errorCount) := 'BNKACCKEY1'; -- changed "BNKACCKEY01"  to "BNKACCKEY1" as max field length is 10.
        t_errormsg(v_errorCount) := o_errortext(c_F826);
        t_errorfieldval(v_errorCount) := v_bnkacckey01;
        t_errorprogram(v_errorCount) := i_scheduleName;
        IF v_errorCount >= C_ERRORCOUNT THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF; */

    ------VALIDATION - ZACLSDAT "Must be a valid date and in correct format YYYYMMDD"-----------------------------
    v_isdatevalid := validate_date(v_zaclsdat);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_Z013;
      t_errorfield(v_errorcount) 	:= 'ZACLSDAT';
      t_errormsg(v_errorcount) 		:= o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_zaclsdat;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ------VALIDATION - APPRDTE "Must be a valid date and in correct format YYYYMMDD"-----------------------------
    v_isdatevalid := validate_date(v_apprdte);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_Z013;
      t_errorfield(v_errorcount) 	:= 'APPRDTE';
      t_errormsg(v_errorcount) 		:= o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_apprdte;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ------VALIDATION - ZPDATATXDTE "Must be a valid date and in correct format YYYYMMDD"-----------------------------
    v_isdatevalid := validate_date(v_zpdatatxdte);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_Z013;
      t_errorfield(v_errorcount) 	:= 'ZPDATATXDT'; -- changed "ZPDATATXDTE"  to "ZPDATATXDT" as max field length is 10.
      t_errormsg(v_errorcount) 		:= o_errortext(c_Z013);
      t_errorfieldval(v_errorcount) := v_zpdatatxdte;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

	--Client Relation Validation:
    IF (TRIM(v_cltreln) IS NOT NULL) THEN
      IF NOT
          (itemexist.EXISTS(trim('T3584') || trim(v_cltreln) || i_company)) THEN
        v_isanyerror 					:= 'Y';
        v_errorcount 					:= v_errorcount + 1;
        t_ercode(v_errorcount) 			:= c_Z104;
        t_errorfield(v_errorcount) 		:= 'CLTRELN';
        t_errormsg(v_errorcount) 		:= o_errortext(c_RQLM);
        t_errorfieldval(v_errorcount) 	:= v_cltreln;
        t_errorprogram(v_errorcount) 	:= i_schedulename;
        IF v_errorcount >= c_errorcount THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;

	--INSURED WORKPLACE validation:
/*	IF TRIM(v_cownnum) <> TRIM(v_clntnum) THEN
      IF TRIM(v_zworkplce2) IS NULL THEN
        v_isanyerror 					:= 'Y';
        v_errorcount 					:= v_errorcount + 1;
        t_ercode(v_errorcount) 			:= c_E186;
        t_errorfield(v_errorcount) 		:= 'ZWORKPLCE2';
        t_errormsg(v_errorcount) 		:= o_errortext(c_E186);
        t_errorfieldval(v_errorcount) 	:= v_zworkplce2;
        t_errorprogram(v_errorcount) 	:= i_schedulename;
        IF v_errorcount >= c_errorcount THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF; */

    --Start PH23: P2-1739 below validation is already removed in IG.
	/*
    IF TRIM(v_ztrgtflg) = 'Y' THEN
      IF TRIM(v_zworkplce1) IS NULL THEN
        v_isanyerror 					:= 'Y';
        v_errorcount 					:= v_errorcount + 1;
        t_ercode(v_errorcount) 			:= c_E186;
        t_errorfield(v_errorcount) 		:= 'ZWORKPLCE1';
        t_errormsg(v_errorcount) 		:= o_errortext(c_E186);
        t_errorfieldval(v_errorcount) 	:= v_zworkplce1 || '-' || v_cownnum;
        t_errorprogram(v_errorcount) 	:= i_schedulename;
        IF v_errorcount >= c_errorcount THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;

    IF TRIM(v_ztrgtflg) = 'Y' THEN
      IF TRIM(v_zworkplce2) IS NULL THEN
        v_isanyerror 					:= 'Y';
        v_errorcount 					:= v_errorcount + 1;
        t_ercode(v_errorcount) 			:= c_E186;
        t_errorfield(v_errorcount) 		:= 'ZWORKPLCE2';
        t_errormsg(v_errorcount) 		:= o_errortext(c_E186);
        t_errorfieldval(v_errorcount) 	:= v_zworkplce2 || '-' || v_clntnum;
        t_errorprogram(v_errorcount) 	:= i_schedulename;
        IF v_errorcount >= c_errorcount THEN
          GOTO insertzdoe;
        END IF;
      END IF;
    END IF;
	*/
	--END PH23: P2-1739 below validation is already removed in IG.

	--Campaign Code 1st Validation: Null or Zero
	IF (TRIM(v_zcmpcode) IS NULL) OR (TRIM(v_zcmpcode) = '0') THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_RQNY;
      t_errorfield(v_errorcount) 	:= 'ZCMPCODE';
      t_errormsg(v_errorcount) 		:= o_errortext(c_RQNY);
      t_errorfieldval(v_errorcount) := v_zcmpcode;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;	

	--Campaign Code 2st Validation: not present in Zcpnpf
	IF RTRIM(obj_polhistobj.ZCN_ZCMPCODE) IS NULL THEN --Ticket #ZJNPG-9739 : RUAT perf improvement - move to pre-dm
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_RQM1;
      t_errorfield(v_errorcount) 	:= 'ZCMPCODE';
      t_errormsg(v_errorcount) 		:= o_errortext(c_RQM1);
      t_errorfieldval(v_errorcount) := v_zcmpcode;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;	

	--PH20: Introduce Client Validation
	IF TRIM(v_clntnum) IS NULL THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_RQLI;
      t_errorfield(v_errorcount) 	:= 'CLIENTNO';
      t_errormsg(v_errorcount) 		:= 'Client not yet migrated';
      t_errorfieldval(v_errorcount) := v_clientno;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;		

	--PH20: Sales Plan Validation
	IF TRIM(v_zslptyp) IS NULL THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_RQLP;
      t_errorfield(v_errorcount) 	:= 'ZPLANCDE';
      t_errormsg(v_errorcount) 		:= 'Sales Plan not valid';
      t_errorfieldval(v_errorcount) := v_zsalplan;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;	

	--PH20: Bank Details Validation
	IF TRIM(v_bankdtls) IS NOT NULL THEN
	  IF RTRIM(obj_polhistobj.CLB_BANKKEY) IS NULL THEN -- Ticket #ZJNPG-9739 : Ruat perf inprovement - move to pre-dm
		  v_isanyerror 					:= 'Y';
		  v_errorcount 					:= v_errorcount + 1;
		  t_ercode(v_errorcount) 		:= 'PA01';
		  t_errorfield(v_errorcount) 	:= 'BANKACCKEY';
		  t_errormsg(v_errorcount) 		:= 'BANKACCKEY-BANKKEY does not exist in CLBAPF.';
		  t_errorfieldval(v_errorcount) := v_bankdtls;
		  t_errorprogram(v_errorcount) 	:= i_schedulename;
		  IF v_errorcount >= c_errorcount THEN
			GOTO insertzdoe;
		  END IF;
	  END IF;
	END IF;		

/*
	--PH20: Endorser Details Validation
	IF (v_mbrno = '00001') AND (v_zinsrole = 1)  AND (TRIM(v_endrsrdtls) IS NOT NULL) THEN
		IF NOT (checkendorser.EXISTS(v_endrsrdtls)) THEN
			v_isanyerror 					:= 'Y';
			v_errorcount 					:= v_errorcount + 1;
			t_ercode(v_errorcount) 			:= 'PA02';
			t_errorfield(v_errorcount) 		:= 'ZENDCDE';
			t_errormsg(v_errorcount) 		:= 'Client-Endorser details does not exist in ZCLEPF';
			t_errorfieldval(v_errorcount) 	:= v_endrsrdtls;
			t_errorprogram(v_errorcount) 	:= i_schedulename;
			IF v_errorcount >= c_errorcount THEN
				GOTO insertzdoe;
			END IF;
		END IF;
	END IF;		

	--1st Validation for ZSALECHNL: null or blank
	IF (TRIM(v_zsalechnl) IS NULL) OR (v_zcmpcode = ' ') THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_E186;
      t_errorfield(v_errorcount) 	:= 'ZSALECHNL';
      t_errormsg(v_errorcount) 		:= o_errortext(c_E186);
      t_errorfieldval(v_errorcount) := v_zsalechnl;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;
*/
	IF (v_unique_number01 IS NULL) AND (TRIM(v_cownnum) IS NOT NULL) THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_E186;
      t_errorfield(v_errorcount) 	:= 'UNQ_NMBR01';
      t_errormsg(v_errorcount) 		:= o_errortext(c_E186);
      t_errorfieldval(v_errorcount) := v_unique_number01;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;	

	IF (v_unique_number02 IS NULL) AND (TRIM(v_clntnum) IS NOT NULL)  THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_E186;
      t_errorfield(v_errorcount) 	:= 'UNQ_NMBR02';
      t_errormsg(v_errorcount) 		:= o_errortext(c_E186);
      t_errorfieldval(v_errorcount) := v_clntnum;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;	    

	--PH21: Validation for cancel and Re-entry transaction
	IF (v_mbrno = '00001') AND (v_zinsrole = 1) AND (v_zaltrcde01 = 'ZC6') THEN -- PH29: Change P13 to ZC6 as per new Alter_Reason_Code mapping. 
		IF (RTRIM(obj_polhistobj.ZCPMCPNCDE) IS NULL) OR (RTRIM(obj_polhistobj.ZCPMPLANCD) IS NULL) THEN
		  v_isanyerror 					:= 'Y';
		  v_errorcount 					:= v_errorcount + 1;
		  t_ercode(v_errorcount) 		:= c_E631;
		  t_errorfield(v_errorcount) 	:= 'ZCPMCPNCDE';
		  t_errormsg(v_errorcount) 		:= 'Missing campaign code for P13';
		  t_errorfieldval(v_errorcount) := v_chdrnum;
		  t_errorprogram(v_errorcount) 	:= i_schedulename;
		  IF v_errorcount >= c_errorcount THEN
			GOTO insertzdoe;
		  END IF;
		END IF;
	END IF;

	--Validation for ZSALECHNL: Sales Channel not in TQ9FW
	IF TRIM(v_zsalechnl) IS NOT NULL THEN 
		IF NOT (itemexist.EXISTS(TRIM('TQ9FW') || TRIM(v_zsalechnl) || i_company)) THEN
		  v_isanyerror 					:= 'Y';
		  v_errorcount 					:= v_errorcount + 1;
		  t_ercode(v_errorcount) 		:= c_RQLL;
		  t_errorfield(v_errorcount) 	:= 'ZSALECHNL';
		  t_errormsg(v_errorcount) 		:= o_errortext(c_RQLL);
		  t_errorfieldval(v_errorcount) := v_zsalechnl;
		  t_errorprogram(v_errorcount) 	:= i_schedulename;
		  IF v_errorcount >= c_errorcount THEN
			GOTO insertzdoe;
		  END IF;
		END IF;
	END IF;

	--Split ratio Validation: Sum is not equal to 100%
	IF NOT ((v_bnypcsum = 0) OR (v_bnypcsum = 100)) THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_E631;
      t_errorfield(v_errorcount) 	:= 'BNYPC';
      t_errormsg(v_errorcount) 		:= o_errortext(c_E631);
      t_errorfieldval(v_errorcount) := v_bnypcsum;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;

	--SIT Defect- Introduce validation for Card Type if CreditCard exists.
	IF v_zcrdtype IS NULL THEN
      v_isanyerror 					:= 'Y';
      v_errorcount 					:= v_errorcount + 1;
      t_ercode(v_errorcount) 		:= c_E186;
      t_errorfield(v_errorcount) 	:= 'ZCRDTYPE';
      t_errormsg(v_errorcount) 		:= 'Credit Card not in range in ZENCTPF table';
      t_errorfieldval(v_errorcount) := v_crdtcard;
      t_errorprogram(v_errorcount) 	:= i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
	END IF;		
    ----[END] VALIDATE ALL FIELDS COMING FROM STAGE DB - TITDMGPOLTRNH---------------------------------------------------------

    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF--------------------------------------------------------
    <<insertzdoe>>
    IF (v_isanyerror = 'Y') THEN
      IF TRIM(t_ercode(1)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error01        := t_ercode(1);
        i_zdoe_info.i_errormsg01     := t_errormsg(1);
        i_zdoe_info.i_errorfield01   := t_errorfield(1);
        i_zdoe_info.i_fieldvalue01   := t_errorfieldval(1);
        i_zdoe_info.i_errorprogram01 := t_errorprogram(1);
      END IF;

      IF TRIM(t_ercode(2)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error02        := t_ercode(2);
        i_zdoe_info.i_errormsg02     := t_errormsg(2);
        i_zdoe_info.i_errorfield02   := t_errorfield(2);
        i_zdoe_info.i_fieldvalue02   := t_errorfieldval(2);
        i_zdoe_info.i_errorprogram02 := t_errorprogram(2);
      END IF;

      IF TRIM(t_ercode(3)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error03        := t_ercode(3);
        i_zdoe_info.i_errormsg03     := t_errormsg(3);
        i_zdoe_info.i_errorfield03   := t_errorfield(3);
        i_zdoe_info.i_fieldvalue03   := t_errorfieldval(3);
        i_zdoe_info.i_errorprogram03 := t_errorprogram(3);
      END IF;

      IF TRIM(t_ercode(4)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error04        := t_ercode(4);
        i_zdoe_info.i_errormsg04     := t_errormsg(4);
        i_zdoe_info.i_errorfield04   := t_errorfield(4);
        i_zdoe_info.i_fieldvalue04   := t_errorfieldval(4);
        i_zdoe_info.i_errorprogram04 := t_errorprogram(4);
      END IF;

      IF TRIM(t_ercode(5)) IS NOT NULL THEN
        i_zdoe_info.i_indic          := 'E';
        i_zdoe_info.i_error05        := t_ercode(5);
        i_zdoe_info.i_errormsg05     := t_errormsg(5);
        i_zdoe_info.i_errorfield05   := t_errorfield(5);
        i_zdoe_info.i_fieldvalue05   := t_errorfieldval(5);
        i_zdoe_info.i_errorprogram05 := t_errorprogram(5);
      END IF;

      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skiprecord;
    END IF;

	--Insert record in ZDOE table for successfuly validated records.
    IF (v_isanyerror = 'N') THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    END IF;

    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF---------------------------------------------------------

    --------IF PRE-VALIDATION IS NO - INSERT INTO "ZDPTPF" REGISTRY TABLE--------------------------------------------------------

    IF i_zprvaldyn = 'N' AND v_isanyerror = 'N' THEN

	  -- insert into Registry table
--    obj_pazdptpf.ZENTITY 	:= v_refKey;
--    obj_pazdptpf.ZIGVALUE	:= v_zigvalue; --'v_chdrnum || '-' || v_tranno || '-' || v_effdate,' --ZTRAPF.CHDRNUM + ?g-?g + ZTRAPF.TRANNO + ?g-?g + ZTRAPF.EFFDATE---HERE TRANNO WILL BE SEQNO+1
      obj_pazdptpf.ZENTITY	:= v_chdrnum;
	  obj_pazdptpf.ZSEQNO	:= v_zseqno;
	  obj_pazdptpf.TRANNO	:= v_tranno;
	  obj_pazdptpf.EFFDATE	:= v_effdate;
	  obj_pazdptpf.MBRNO	:= v_mbrno; 
	  obj_pazdptpf.ZINSROLE	:= v_zinsrole;
	  obj_pazdptpf.JOBNUM 	:= i_scheduleNumber;
      obj_pazdptpf.JOBNAME 	:= i_scheduleName;

      INSERT INTO Jd1dta.VIEW_DM_PAZDPTPF VALUES obj_pazdptpf;

      ---------------------- INSERT ZTRAPF START--------------------------------------------------------------------------------------------------
      /*
	  --IF (gettq9mp.exists(TRIM(v_zaltrcde01))) THEN 
        obj_tq9mp 	:= gettq9mp(v_zaltrcde01);
        v_zrcaltty	:= obj_tq9mp.ZRCALTTY;
      END IF; */

      --FREE PLAN POLICY
      IF TRIM(v_zplancls) = 'FP' THEN
        v_zpdatatxdte	:= v_maxdate;	
        IF TRIM(v_zaltrcde01) in ('ZTB','ZTD','ZTF','ZTZ','ZT4','ZT8') THEN -- PH29: Set T series with ZT as per new Alter_Reason_Code mapping
          v_zaltrcde01	:= 'OT4';
        END IF;
      END IF;

      --Transaction Status Indicator Determination
      IF TRIM(v_ztrxstat) = 'AP' THEN
          v_ztrxstsind	:= 1;
      END IF;

      IF TRIM(v_ztrxstat) = 'RJ' THEN
        v_ztrxstsind	:= 4;
      END IF;	 

      --Insert only Main insured in ZTRAPF
      IF (v_mbrno = '00001') AND (v_zinsrole = 1) THEN 
        -- SET COMMON VALUES IN OBJECT FOR ZTRAPF
        obj_ztrapf.CHDRCOY    		:= i_company;
        obj_ztrapf.CHDRNUM    		:= v_chdrnum;
        obj_ztrapf.TRANNO     		:= v_tranno; ---- TO BE UPDATED
        obj_ztrapf.EFFDATE    		:= v_effdate; 
        obj_ztrapf.ZALTREGDAT 		:= v_zaltregdat;
        obj_ztrapf.ZALTRCDE02 		:= v_space;
        obj_ztrapf.ZALTRCDE03 		:= v_space;
        obj_ztrapf.ZALTRCDE04 		:= v_space;
        obj_ztrapf.ZALTRCDE05 		:= v_space;
        obj_ztrapf.ZCLMRECD   		:= v_maxdate;
        obj_ztrapf.ZINHDSCLM  		:= v_zinhdsclm;
        --obj_ztrapf.ZUWREJFLG  		:= v_zuwrejflg; -- PH20 - ITR3 - This column is removed in IG ztrapf table.
        obj_ztrapf.ZVIOLTYP   		:= v_space;
        obj_ztrapf.ZSTOPBPJ   		:= 'N';
        obj_ztrapf.UNIQUE_NUMBER_01	:= v_unique_number01;
        obj_ztrapf.ALTQUOTENO  		:= v_space;
        obj_ztrapf.ZREFUNDAM   		:= v_zero;
        obj_ztrapf.ZSURCHRGE   		:= v_zero;
        obj_ztrapf.ZSALPLNCHG  		:= v_space;
        obj_ztrapf.ZPAYINREQ   		:= 'N';
        obj_ztrapf.USRPRF      		:= i_usrprf;
        obj_ztrapf.JOBNM       		:= i_schedulename;
        obj_ztrapf.DATIME      		:= CAST(sysdate AS TIMESTAMP);
        obj_ztrapf.ZFINALBYM   		:= v_zero;
        obj_ztrapf.ZDFCNCY        	:= 'N';
        obj_ztrapf.ZMARGNFLG		:= 'N';	  
        obj_ztrapf.DOCRCDTE       	:= v_zaclsdat;
        obj_ztrapf.HPROPDTE       	:= v_zaclsdat;
        obj_ztrapf.ZTRXSTAT  		:= v_ztrxstat;
        obj_ztrapf.ZSTATRESN 		:= NVL(v_zstatresn, ' '); --ITR3 UAT postval
        obj_ztrapf.ZACLSDAT  		:= v_zaclsdat;
        obj_ztrapf.APPRDTE   		:= v_apprdte;
        obj_ztrapf.ZRVTRANNO   		:= v_zero;
        obj_ztrapf.ZCSTPBIL       	:= 'N';
        obj_ztrapf.ZALTRCDE01 		:= NVL(v_zaltrcde01, ' '); --ITR3 UAT postval
        --obj_ztrapf.ZPDATATXDAT		:= v_zpdatatxdte;
        obj_ztrapf.ZRCALTTY			:= v_zrcaltty;
		obj_ztrapf.TRANCDE			:= v_trancde; --PH20 - get from source.	
		obj_ztrapf.ZCPMCPNCDE		:= null; --PH21: Cancel and Re-entry
		obj_ztrapf.ZCPMPLANCD		:= null; --PH21: Cancel and Re-entry
		obj_ztrapf.ZBLTRANNO 		:= v_zero; --PH24 : ZJNPG-9103 Post Validation Fix
		obj_ztrapf.ZDFBLIND			:= 'N'; --PH24 : ZJNPG-9103 Post Validation Fix

		--Start: PH21-Cancel and Re-entry
		IF (v_zaltrcde01 = 'ZC6') THEN  -- PH29: Change P13 to ZC6 as per new Alter_Reason_Code mapping
			obj_ztrapf.ZCPMCPNCDE	:= RTRIM(obj_polhistobj.ZCPMCPNCDE);
			obj_ztrapf.ZCPMPLANCD	:= RTRIM(obj_polhistobj.ZCPMPLANCD);
		END IF; 
		--End: PH21-Cancel and Re-entry

	  /* PA change converted policy logic is not required and TRANNO is already determined in TRANNOTBL
      IF (TRIM(v_zseqno) = '000' or v_onlyspl = 'T') THEN     ---PH16
        obj_ztrapf.ZQUOTIND 	:= v_space;
        obj_ztrapf.TRANCDE		:= 'T902';     -- PH4
		obj_ztrapf.ZFINANCFLG	:= 'Y'; */

	  -- NEW BUSINESS:
        IF (TRIM(v_zseqno) = '000') THEN     ---PH19 --need to update for Minimum tranno within the policyy  --ITR3 UAT postval
          obj_ztrapf.ZQUOTIND 	:= v_space;
          --obj_ztrapf.TRANCDE	:= 'T902'; -- PH20 - get from source.	
          obj_ztrapf.ZFINANCFLG	:= 'Y';
          obj_ztrapf.ZLOGALTDT	:= v_maxdate;
          obj_ztrapf.EFDATE 	:= v_effdate;
          obj_ztrapf.ZVLDTRXIND	:= null;
		  obj_ztrapf.ZPOLDATE	:= v_maxdate;
		  obj_ztrapf.STATCODE 	:= 'IF';
		  obj_ztrapf.ZSTATRESN  := NVL(v_zstatresn, ' '); --PH24 : ZJNPG-9103 Post Validation Fix
		  obj_ztrapf.ZALTRCDE01 := NVL(v_zaltrcde01, ' '); --PH24 : ZJNPG-9103 Post Validation Fix 

		  IF TRIM(v_ztrxstat) = 'RJ' THEN 
            obj_ztrapf.STATCODE := 'CA';
          END IF;

        ELSE
          obj_ztrapf.ZQUOTIND	:= 'A';
          --obj_ztrapf.TRANCDE 	:= 'T912'; -- PH20 - get from source.	
          obj_ztrapf.ZFINANCFLG	:= 'N';
          obj_ztrapf.ZVLDTRXIND	:= null; --ZJNPG-8385 this should be null if there is no cancellation
		  obj_ztrapf.ZPOLDATE	:= v_maxdate;
		  obj_ztrapf.STATCODE	:= v_statcode;

		  IF getcanctran.EXISTS(TRIM(v_chdrnum)) THEN
			obj_canctran := getcanctran(v_chdrnum);
			v_canctranno	:= obj_canctran.TRANNO;
			v_canceffdate	:= obj_canctran.EFFDATE;
			-- Transactions after cancellation
			IF v_tranno > v_canctranno THEN
		      obj_ztrapf.ZPOLDATE	:= v_zpoltdate;
		      obj_ztrapf.STATCODE 	:= 'CA';
		    END IF;

			--Start: ZJNPG-8385 = correct identification for ZVLDTRXIND column.
			IF (v_tranno <> v_canctranno) AND (v_effdate >= v_canceffdate) THEN
				obj_ztrapf.ZVLDTRXIND	:= 'Y';
			ELSE
				obj_ztrapf.ZVLDTRXIND	:= null;
			END IF;
			--End: ZJNPG-8385

		  END IF;

          -- Calculation Base Date EFDATE Determination Logic
          v_daytempccdate  := substr(v_ccdate, 7, 2); --PH25:  from (7,8) to (7,2)
          v_daytempeffdate := substr(v_effdate, 7, 2); --PH25: from (7,8) to (7,2)
          IF (v_daytempccdate = v_daytempeffdate) THEN
            obj_ztrapf.EFDATE := v_effdate;
          ELSE
            v_efdatetemp      := DATCONOPERATION('MONTH', v_effdate);
            v_yearmonthtemp   := substr(v_efdatetemp, 1, 6);
            v_efdatefinal     := v_yearmonthtemp || v_daytempccdate;
            obj_ztrapf.EFDATE := v_efdatefinal;
          END IF;

          IF v_effdate >= NVL(v_tranbtdate,0) THEN 
            obj_ztrapf.ZLOGALTDT := obj_ztrapf.EFDATE;
          ELSE
            obj_ztrapf.ZLOGALTDT := TO_NUMBER(TO_CHAR(TO_DATE(v_tranbtdate, 'yyyymmdd') + 1, 'yyyymmdd'));
          END IF;
        END IF;

	    --Cancellation:
		--IF (gettq9mp.exists(TRIM(v_zaltrcde01)))
	    IF TRIM(v_zrcaltty) = 'TERM' THEN 
          obj_ztrapf.ZFINANCFLG	:= 'Y';		
		  obj_ztrapf.ZPOLDATE	:= v_zpoltdate;
		  obj_ztrapf.STATCODE 	:= 'CA';
		  obj_ztrapf.ZREFUNDAM 	:= NVL(v_zrefundam,0); --ZJNPG-8922 input 0 if there was no refund retrieved in titdmgref1
        END IF;	  

		--POLICY DATA TRANSFER  Determinatio logic
		IF (TRIM(v_zplancls) = 'PP')  AND (TRIM(v_zpdatatxdte) IS NULL) THEN --PH27: PJ Transferdate calculation if trx is not yet transfered to PJ in DM side.
			IF TRIM(v_old_pol) <> TRIM(v_chdrnum) THEN --Incase same policy in CASE4 is being processed.

				--SELECT MIN(ZACMCLDT) INTO v_zacmcldt1  -- Back Dated QUERY
				--FROM ZESDPF WHERE TRIM(ZENDSCID)=TRIM(v_zendscid) AND TRIM(ZACMCLDT) >= obj_ztrapf.APPRDTE;
				v_zacmcldt1 := RTRIM(obj_polhistobj.ZACMCLDT);

				--Policy Transfer Date determination 
				--CASE1&2: if future dated or backdated
				IF obj_ztrapf.ZLOGALTDT > obj_ztrapf.EFDATE THEN -- Back Dated logic
					IF getdzesdpf_bd.EXISTS(TRIM(v_zendscid) || TRIM(v_zacmcldt1)) THEN -- Back Dated QUERY
						obj_zesdpf_bd := getdzesdpf_bd(TRIM(v_zendscid) || TRIM(v_zacmcldt1));
						v_zbstcsdt03 	:= obj_zesdpf_bd.ZBSTCSDT03;
						v_zbstcsdt02	:= obj_zesdpf_bd.ZBSTCSDT02;
					END IF;
					obj_ztrapf.ZPDATATXDAT	:= v_zacmcldt1;
				ELSE											 -- Future Dated logic

					IF getdzesdpf.EXISTS(TRIM(v_zendscid) || TRIM(obj_ztrapf.EFDATE)) THEN -- Future Dated QUERY
						obj_zesdpf := getdzesdpf(TRIM(v_zendscid) || TRIM(obj_ztrapf.EFDATE));
						v_zacmcldt2	:= obj_zesdpf.ZACMCLDT;
						v_zbstcsdt03 	:= obj_zesdpf.ZBSTCSDT03;
						v_zbstcsdt02	:= obj_zesdpf.ZBSTCSDT02;
					END IF;

					IF v_zacmcldt2 < obj_ztrapf.APPRDTE THEN
						obj_ztrapf.ZPDATATXDAT	:= v_zacmcldt1;
					ELSE
						obj_ztrapf.ZPDATATXDAT	:= v_zacmcldt2;
					END IF;		
				END IF;

				--CASE4: If new business
				IF (TRIM(v_zseqno) = '000') AND  --ITR3 UAT postval
					(obj_ztrapf.ZPDATATXDAT >= v_migdate) AND (v_effdcldt = v_occdate) THEN
					obj_ztrapf.ZPDATATXDAT	:= v_maxdate;
					v_old_pol  := v_chdrnum;
				END IF;

				--CASE3: Cancellation transaction with PGP Date (Ztrapf.ZALTRCDE01 (First character) = 'T')
				IF SUBSTR(obj_ztrapf.ZALTRCDE01,1,2) = 'ZT' THEN  -- PH29: Change T series to ZT series as per new Alter_Reason_Code mapping
					IF v_zbstcsdt03 <> v_maxdate THEN
						obj_ztrapf.ZPDATATXDAT	:= v_zbstcsdt03;
					ELSIF v_zbstcsdt02 <> v_maxdate THEN
						obj_ztrapf.ZPDATATXDAT	:= v_zbstcsdt02;
					ELSE
						obj_ztrapf.ZPDATATXDAT	:= obj_ztrapf.ZPDATATXDAT;
					END IF;
				END IF;
			ELSE 
				obj_ztrapf.ZPDATATXDAT	:= v_maxdate;
			END IF;

			IF obj_ztrapf.ZPDATATXDAT >= v_migdate THEN 
			  obj_ztrapf.ZPDATATXFLG	:= ' '; --ITR3 UAT postval
			ELSE
			  obj_ztrapf.ZPDATATXFLG	:= 'Y'; --ITR3 UAT postval
			END IF;
		ELSIF (TRIM(v_zplancls) = 'PP')  AND (TRIM(v_zpdatatxdte) IS NOT NULL) THEN --PH27: PJ Transferdate is set directly from source if alreadey transfered in DM side.
			obj_ztrapf.ZPDATATXDAT	:= v_zpdatatxdte; 								--PH27: PJ Transferdate is set directly from source if alreadey transfered in DM side.
			obj_ztrapf.ZPDATATXFLG	:= 'Y';											--PH27: PJ Transferdate is set directly from source if alreadey transfered in DM side.
		ELSE -- IF Free Plan
			obj_ztrapf.ZPDATATXDAT	:= v_maxdate;
			obj_ztrapf.ZPDATATXFLG	:= v_space;
		END IF;

------------- PH15: START---------------
        IF TRIM(v_zpdatatxflg) = 'N' AND v_btdate <> '99999999' THEN
          SELECT to_number(TO_CHAR(to_date(v_btdate, 'yyyymmdd') + 1, 'yyyymmdd'))
          INTO v_newefdate
          FROM dual;
          obj_ztrapf.EFDATE := v_newefdate;
        END IF;
------------- PH15: END---------------	  			

/*  PH19: Not required for PA => New logic
	  --Logical Altertation Date Determination LOGIC
      IF (v_tranno = v_tranlused) THEN      
        obj_ztrapf.ZLOGALTDT  := v_btdate;--GET IT FROM GCHD
       ELSE 
        obj_ztrapf.ZLOGALTDT  := 0;       
      END IF;
*/
/*-- PH19: Not required for PA  
      IF (getgmhipf.exists(v_chdrnum)) THEN
        obj_gmhi            := getgmhipf(v_chdrnum); --PH12
        obj_ztrapf.DOCRCDTE := obj_gmhi.docrcdte;
        obj_ztrapf.HPROPDTE := obj_gmhi.hpropdte;
      END IF;
*/
/* PH19: Not required in PA
----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: START------      
      IF (getzdchpf.exists(TRIM(v_cownnum) || TRIM(v_seqno_cl2) || TRIM(v_effdate))) THEN  
        obj_zdchpf         := getzdchpf(TRIM(v_cownnum) || TRIM(v_seqno_cl2) || TRIM(v_effdate));
        v_unique_number01  := obj_zdchpf.RECIDXCLNTHIS;
        v_temp_cownum      := trim(v_cownnum);
        v_temp_effdate     := trim(v_effdate);
        v_temp_seqno_cl2   := trim(v_seqno_cl2);
      ELSE
        obj_zdchpf         := getzdchpf(TRIM(v_temp_cownum) || TRIM(v_temp_seqno_cl2) || TRIM(v_temp_effdate));
        v_unique_number01  := obj_zdchpf.RECIDXCLNTHIS;
      END IF;
----Get RECIDXCLNTHIS(UNIQUE_NUMBER) from PAZDCHPF: DM_REHEARSAL_PERFORMANCE: END--------
*/

----------------PH9: START------------------------------------------------
-------------CHANGE FOR ZTRAPF COLUMN "ZPOLDATE"----------------

/* -- PH19: Not required for PA
    IF (v_tranno = 1) THEN
        obj_ztrapf.ZPOLDATE    :=NULL;
    ELSE
        IF ((v_zpoltdate <> 0) AND (v_zpoltdate IS NOT NULL) ) THEN
          obj_ztrapf.ZPOLDATE   := v_zpoltdate;
        ELSE
          obj_ztrapf.ZPOLDATE   := v_maxdate;
        END IF;
    END IF;
*/


/* PH19: AGE column is removed in PA
------------CHANGE FOR ZTRAPF COLUMN "AGE"--------------------------   

    IF (clntdob.exists(TRIM(v_clientnum))) THEN
         v_cltdob    := clntdob(TRIM(v_clientnum));
    END IF;

    IF((TRIM(v_cltdob) IS NOT NULL) AND (TRIM(v_cltdob) <> 0) AND (TRIM(v_cltdob) <> 99999999)) THEN
         v_startdateMM := SUBSTR(TRIM(v_cltdob), 5, 8);
         v_enddateMM   := SUBSTR(TRIM(v_effdate), 5, 8);
         v_startdateYY := SUBSTR(TRIM(v_cltdob), 1, 4);
         v_enddateYY   := SUBSTR(TRIM(v_effdate), 1, 4);

      IF(v_startdateMM <= v_enddateMM)  THEN
         v_age         	:= (v_enddateYY) - (v_startdateYY) ;
         obj_ztrapf.AGE	:= v_age;
      END IF; 

      IF(v_startdateMM > v_enddateMM) THEN
         v_age         	:= (v_enddateYY - v_startdateYY) - 1 ;
         obj_ztrapf.AGE	:= v_age;
      END IF;
    ELSE
         obj_ztrapf.AGE	:= v_zero;
    END IF;
*/
----------------PH9: END-------------------------------------------------- 
/* -- PH19: Not required for PAs
--------- PH10 Start -------------
--- Set STATCODE = STATCODE in GCHD | For future dates cancellation, STATCODE = "CA"
    obj_ztrapf.STATCODE := v_statcode;
    IF ((v_zpoltdate <> 0) AND (v_zpoltdate IS NOT NULL) AND (v_zpoltdate = v_maxdate)) AND v_statcode = 'IF' THEN
       obj_ztrapf.STATCODE := 'CA';
    END IF;

  --IF TRIM(obj_ztrapf.TRANCDE) = 'T902' THEN
  --  obj_ztrapf.STATCODE := 'XN';
  --ELSE
  --  obj_ztrapf.STATCODE := v_statcode;
  --END IF;
--------- PH10 End ---------------*/
 /*
	IF SUBSTR(OBJ_ZTRAPF.ZALTRCDE01,1,1) = 'T' THEN
		OBJ_ZTRAPF.ZCSTPBIL := 'Y';
	END IF;
 */
        -- INSERT INTO IG TARGET TABLE ZTRAPF
	    INSERT INTO Jd1dta.VIEW_DM_ZTRAPF VALUES obj_ztrapf;
	  END IF;
 ---------------------- INSERT ZTRAPF END--------------------------------------------------------------------------------------------------

 -----------------------INSERT ONLY Main Insured to ZALTPF START--------------------------------------------------------------------------------
      IF (v_mbrno = '00001') AND (v_zinsrole = 1) THEN

        IF (v_tranno = v_tranlused) THEN
          obj_zaltpf.ZPGPFRDT    := v_zpgpfrdt;--GET IT FROM GCHPPF
          obj_zaltpf.ZPGPTODT    := v_zpgptodt;--GET IT FROM GCHPPF
        ELSE 
          obj_zaltpf.ZPGPFRDT    := v_maxdate;
          obj_zaltpf.ZPGPTODT    := v_maxdate;
        END IF;

        -- SET OTHER VALUES IN OBJECT FOR ZTRAPF
        --SELECT ZSLPTYP INTO v_zslptyp FROM Jd1dta.ZSLPHPF WHERE TRIM(ZSALPLAN) = v_zplancde; 
        obj_zaltpf.CHDRNUM		  	:= v_chdrnum;
        obj_zaltpf.TRANNO  		  	:= v_tranno;
        obj_zaltpf.COWNNUM  	  	:= v_cownnum; --need to fetch again either from PAZDCLPF or GCHD
        obj_zaltpf.ZCMPCODE 	  	:= v_zcmpcode;
        obj_zaltpf.ZCPNSCDE 	  	:= v_zcpnscde;
        obj_zaltpf.ZCONVPOLNO 		:= null;
        obj_zaltpf.ZSALECHNL        := v_zsalechnl;
        obj_zaltpf.ZSOLCTFLG        := v_zsolctflg;
        --obj_zaltpf.ZPLANCDE    	:= v_zplancde; PH19: Moved to ZINSDTLSPF
        obj_zaltpf.CRDTCARD    		:= v_crdtcard; --currently getting from TITDMGPOLTRNH might be changed
        obj_zaltpf.BNKACCKEY01 		:= v_bnkacckey01; --currently getting from TITDMGPOLTRNH might be changed
        obj_zaltpf.ZENSPCD01 	  	:= v_zenspcd01; --currently getting from TITDMGPOLTRNH might be changed
        obj_zaltpf.ZENSPCD02 	  	:= v_zenspcd02; --currently getting from TITDMGPOLTRNH might be changed
        obj_zaltpf.ZCIFCODE  	  	:= v_zcifcode; --currently getting from TITDMGPOLTRNH might be changed
        --obj_zaltpf.DCLDATE    	:= v_dcldate;  PH19: Moved to ZINSDTLSPF
        --obj_zaltpf.ZDCLITEM01 	:= v_zdclitem01; --not sure of the value PH19: Moved to ZINSDTLSPF
        --obj_zaltpf.ZDCLITEM02 	:= v_zdclitem02; --not sure of the value PH19: Moved to ZINSDTLSPF
        obj_zaltpf.USRPRF     		:= i_usrprf;
        obj_zaltpf.JOBNM      		:= i_schedulename;
        obj_zaltpf.DATIME     		:= CAST(sysdate AS TIMESTAMP);
        --obj_zaltpf.ZDECLCAT   	:= v_zdeclcat; PH19: Moved to ZINSDTLSPF
        obj_zaltpf.ZRECEPFG		  	:= 'N';
        obj_zaltpf.BANKACCDSC01		:= NVL(v_bankaccdsc01, '              ');  --PH24 : ZJNPG-9103 Post Validation Fix 
        obj_zaltpf.ZPOLPERD		  	:= v_zpolperd; -- Directly from GCHIPF
        obj_zaltpf.ZWORKPLCE1	  	:= v_zworkplce1;
        obj_zaltpf.ZSLPTYP		  	:= v_zslptyp;
        obj_zaltpf.MTHTO            := v_mthto;
        obj_zaltpf.YEARTO           := v_yearto;
        obj_zaltpf.BANKKEY		  	:= v_bankkey;
        obj_zaltpf.PREAUTNO     	:= v_preautno;

        ----INSERT INTO IG TARGET TABLE ZALTPF	
        INSERT INTO Jd1dta.VIEW_DM_ZALTPF VALUES obj_zaltpf;
      END IF;
 -----------------------INSERT ONLY Main Insured to ZALTPF START--------------------------------------------------------------------------------

 ---------------------- INSERT ZMCIPF START-----------------------------------------------------------------------------------------------------
    -- IF v_zaltrcde01 = 'M04' OR v_zaltrcde01 = 'M01' THEN

      IF ((TRIM(v_mbrno) = '00001') AND (v_zinsrole = 1) AND ((v_mintranno = v_tranno AND ((TRIM(v_zenspcd01) IS NOT NULL) OR
         (TRIM(v_zenspcd02) IS NOT NULL) OR
         (TRIM(v_crdtcard) 	IS NOT NULL) OR
         (TRIM(v_bnkacckey01) IS NOT NULL) OR      -- PH14: new line --------
         (TRIM(v_zddreqno) 	IS NOT NULL) OR
		 (TRIM(v_zcifcode) 	IS NOT NULL))) OR (
         (TRIM(v_zaltrcde01) = 'M04') OR (TRIM(v_zaltrcde01) = 'M01') OR (TRIM(v_zaltrcde01) = 'M02')))) THEN    -- PH14: new line --------

		--select SEQ_ZMCIPF.nextval into v_pkzmcipf from dual;
        v_pkzmcipf := SEQ_ZMCIPF.nextval; --PerfImprov
		obj_zmcipf.UNIQUE_NUMBER  := v_pkzmcipf;
        obj_zmcipf.CHDRNUM 		  := v_chdrnum;
        obj_zmcipf.TRANNO 		  := v_tranno;
        obj_zmcipf.ZENDCDE 		  := v_zendcde;
        obj_zmcipf.ZENSPCD01 	  := v_zenspcd01;
        obj_zmcipf.ZENSPCD02 	  := v_zenspcd02;
        obj_zmcipf.ZCIFCODE 	  := v_zcifcode;
        obj_zmcipf.CRDTCARD       := v_crdtcard;
        obj_zmcipf.BANKACCKEY01   := v_bnkacckey01;

      /* PH19: All columns for this logic will be direct mapping
          IF (v_bnkacckey01 IS NOT NULL) THEN
            IF (getclbaforbnk.exists(v_bnkacckey01 || TRIM(v_clientnum))) THEN --PH12
              obj_clbapf_bn   := getclbaforbnk(v_bnkacckey01 || TRIM(v_clientnum)); --PH12
              v_bankaccdsc 	:= obj_clbapf_bn.bankaccdsc;
              --v_bnkactyp   	:= obj_clbapf_bn.bnkactyp; PH19: Direct Mapping from stagedb
              v_bankkey    	:= obj_clbapf_bn.bankkey;
            END IF;
          END IF;

          -- PH4 START --
          IF (v_crdtcard IS NOT NULL) THEN
            IF (getclbaforbnk.exists(v_crdtcard || TRIM(v_clientnum))) THEN  --PH12
              obj_clbapf_bn   := getclbaforbnk(v_crdtcard || TRIM(v_clientnum));  --PH12
              --v_bankaccdsc 	:= obj_clbapf_bn.bankaccdsc; PH:19 This should be direct mapping
              --v_bnkactyp   	:= obj_clbapf_bn.bnkactyp;
              --v_bankkey    	:= obj_clbapf_bn.bankkey; PH:19 This should be direct mapping
            END IF;
          END IF;   
          -- PH4 END -- */

          obj_zmcipf.BANKACCDSC01 := NVL(v_bankaccdsc01, '              ' );  --PH24 : ZJNPG-9103 Post Validation Fix 
          obj_zmcipf.BNKACTYP01   := v_bnkactyp;
          obj_zmcipf.BANKKEY      := v_bankkey;
          obj_zmcipf.BANKACCKEY02 := v_space;
          obj_zmcipf.BANKACCDSC02 := v_space;
          obj_zmcipf.BNKACTYP02   := v_space;
          obj_zmcipf.ZPBCTYPE     := v_space;
          obj_zmcipf.ZPBCODE      := v_space;
          obj_zmcipf.PREAUTNO     := v_preautno;

      /* PH19: Month to and Year to will be direct mapping
          IF (v_crdtcard IS NOT NULL) THEN
            IF (getclbaforcc.exists(v_crdtcard || TRIM(v_clientnum))) THEN --PH12
              obj_clbapf_cc := getclbaforcc(v_crdtcard || TRIM(v_clientnum));  --PH12
              v_mthto    := obj_clbapf_cc.mthto;
              v_yearto   := obj_clbapf_cc.yearto;
            END IF;
          END IF;*/

          obj_zmcipf.MTHTO  		:= v_mthto;
          obj_zmcipf.YEARTO 		:= v_yearto;
          obj_zmcipf.DATIME 		:= CAST(sysdate AS TIMESTAMP);
          obj_zmcipf.JOBNM  		:= i_schedulename;
          obj_zmcipf.CARDTYP 		:= v_zcrdtype;
          obj_zmcipf.effdate 		:= obj_ztrapf.EFDATE; -- v_effdate; PH28: Fix for CR - ZJNPG-10343 ZMCIPF.EFFDATE should be same as ztrapf.efdate instead of ztrapf.effdate.
          obj_zmcipf.USRPRF 		:= i_usrprf;
  ------------------------PH14-START----------------------------
          obj_zmcipf.ZDDREQNO := NVL(v_zddreqno, '        '); --PH24 : ZJNPG-9103 Post Validation Fix 
  ------------------------PH14-END------------------------------

        ----INSERT INTO IG TARGET TABLE ZTRAPF
        INSERT INTO Jd1dta.ZMCIPF VALUES obj_zmcipf;
      END IF;
 ---------------------- INSERT ZTRAPF END-------------------------------------------------------------------------------------------------------	  

 ---------------------- INSERT ZINSDTLSPF START-------------------------------------------------------------------------------------------------
      obj_zinsdtlspf.CHDRCOY           := i_company;
      obj_zinsdtlspf.CHDRNUM           := v_chdrnum;
      obj_zinsdtlspf.TRANNO            := v_tranno;
      obj_zinsdtlspf.MBRNO             := v_mbrno;
      obj_zinsdtlspf.DPNTNO            := v_dpntno;
      obj_zinsdtlspf.CLNTNUM           := v_clntnum;
      obj_zinsdtlspf.UNIQUE_NUMBER_02  := v_unique_number02;
      --obj_zinsdtlspf.ZORIGSALP         := v_zplancde; --PH20: ITR3 need to change logic for renewed data with salesplan change.
      obj_zinsdtlspf.CLTRELN           := v_cltreln;
      obj_zinsdtlspf.ZPLANCDE          := v_zsalplan;
      obj_zinsdtlspf.DCLDATE           := v_maxdate;
      obj_zinsdtlspf.ZWORKPLCE2        := v_zworkplce2;
      obj_zinsdtlspf.EFFDATE           := v_effdate;
      obj_zinsdtlspf.ALTQUOTENO        := v_space;
      obj_zinsdtlspf.DTEATT            := v_dteatt; -- PH20: retrieved from GCHIPF
      obj_zinsdtlspf.USRPRF            := i_usrprf;
      obj_zinsdtlspf.JOBNM             := i_schedulename;
      obj_zinsdtlspf.DATIME            := CAST(sysdate AS TIMESTAMP);
      obj_zinsdtlspf.ZINSROLE          := v_zinsrole;
      obj_zinsdtlspf.ZINSDTHD          := NULL; --PH26: P2-5704 should be null in case there is no Cancellation by Death of Insured
      obj_zinsdtlspf.ZRTRANNO          := v_zero;

	  --START: PH20- Logic for ZORIGSALP
	  IF (v_chdrnum = v_oldchdrnum) AND (v_mbrno = v_oldmbrno) THEN
		IF (v_zsalplan <> v_oldzsalplan) THEN
			obj_zinsdtlspf.ZORIGSALP	:= v_oldzsalplan;
			v_oldchdrnum := v_chdrnum;
			v_oldmbrno := v_mbrno;
			v_oldzsalplan := v_zsalplan;
		ELSE
			obj_zinsdtlspf.ZORIGSALP	:= v_zsalplan;
			v_oldchdrnum := v_chdrnum;
			v_oldmbrno := v_mbrno;
			v_oldzsalplan := v_zsalplan;
		END IF;
	  ELSE
		obj_zinsdtlspf.ZORIGSALP		:= v_zsalplan;
		v_oldchdrnum := v_chdrnum;
		v_oldmbrno := v_mbrno;
		v_oldzsalplan := v_zsalplan;
	  END IF;
	  --END: PH20- Logic for ZORIGSALP

	  --Start: ZJNPG-8294 
	  IF TRIM(v_occpcode) IS NULL THEN
		obj_zinsdtlspf.OCCPCODE          := v_occpcode;
	  ELSE
		obj_zinsdtlspf.OCCPCODE          := TRIM(v_occpcode);
	  END IF;
	  --End : ZJNPG-8294 
      obj_zinsdtlspf.ZTRXSTSIND        := v_ztrxstsind;

      -- CANCELLATION:
      --IF (gettq9mp.exists(TRIM(v_zaltrcde01))) THEN
	  IF TRIM(v_zrcaltty) = 'TERM' THEN 
        obj_zinsdtlspf.DTETRM	:= obj_ztrapf.EFDATE; -- PH28: Fix for ZJNPG-10273 (P2-19319) - obj_zinsdtlspf.DTETRM should be same as ztrapf.efdate instead of ztrapf.effdate.
        obj_zinsdtlspf.TERMDTE	:= v_effdate;
        --Insured Death date determination
        IF (TRIM(v_zaltrcde01) IN ('ZD1', 'ZD3')) AND (v_zinsrole = 1) THEN -- PH29: Change D01,D03 to ZD1,ZD3  as per new Alter_Reason_Code mapping
          obj_zinsdtlspf.ZINSDTHD	:= v_effdate;
        END IF;

        IF TRIM(v_zaltrcde01) = 'ZD2' THEN -- PH29: Change D02 to ZD2  as per new Alter_Reason_Code mapping
          obj_zinsdtlspf.ZINSDTHD	:= v_effdate;
        END IF;

        IF (TRIM(v_zaltrcde01) IN ('ZD4', 'P12', 'DM3')) AND (v_zinsrole <> 1) THEN -- PH29: Change D04 to ZD4  as per new Alter_Reason_Code mapping
          obj_zinsdtlspf.ZINSDTHD	:= v_effdate;
        END IF;				
      ELSE
        obj_zinsdtlspf.DTETRM	:= v_maxdate;
        obj_zinsdtlspf.TERMDTE	:= v_maxdate;
      END IF;   

      -- insert into ZINSDTLSPF
      INSERT INTO VIEW_DM_ZINSDTLSPF VALUES obj_zinsdtlspf;
 ---------------------- INSERT ZINSDTLSPF END---------------------------------------------------------------------------------------------------

 ---------------------- INSERT/UPDATE ZBENFDTLSPF START-----------------------------------------------------------------------------------------
      IF (v_mintranno = v_tranno) OR (TRIM(v_zaltrcde01) = 'N10') THEN

        obj_zbenfdtlspf.CHDRCOY     := i_company;
        obj_zbenfdtlspf.CHDRNUM     := v_chdrnum;
        obj_zbenfdtlspf.ALTQUOTENO	:= v_space;
        obj_zbenfdtlspf.MBRNO       := v_mbrno;
        obj_zbenfdtlspf.DPNTNO      := v_dpntno;
        obj_zbenfdtlspf.EFFDATE     := v_effdate;
        obj_zbenfdtlspf.TRANNO      := v_tranno;
        --obj_zbenfdtlspf.SEQNUMB     := v_seqnumb;
        obj_zbenfdtlspf.USRPRF      := i_usrprf;
        obj_zbenfdtlspf.JOBNM       := i_schedulename;
        obj_zbenfdtlspf.DATIME      := CAST(sysdate AS TIMESTAMP);
        obj_zbenfdtlspf.ZTRXSTSIND  := v_ztrxstsind;
        obj_zbenfdtlspf.DTETRM      := v_maxdate;

        IF (TRIM(v_zaltrcde01) = 'N10') THEN
          UPDATE Jd1dta.zbenfdtlspf SET DTETRM = TRIM(v_effdate) 
          WHERE CHDRNUM = v_chdrnum --Ticket #ZJNPG-9739 : RUAT perf improvment - remove trim
          AND MBRNO = v_mbrno --Ticket #ZJNPG-9739 : RUAT perf improvment - remove trim
          AND DTETRM = v_maxdate
          AND TRANNO < v_tranno;
        END IF;		

		--SELECT NVL(MAX(SEQNUMB),0)  INTO v_seqnumb  FROM Jd1dta.ZBENFDTLSPF WHERE TRIM(CHDRNUM) = TRIM(v_chdrnum) AND TRIM(MBRNO) = TRIM(v_mbrno);

		IF v_benoldpol = v_chdrnum THEN
			IF v_mbrno = '00001' THEN
				v_seqnumb := v_seqnum01;
			ELSE --v_mbrno = '00002'
				v_seqnumb := obj_polhistobj.SEQNUMB;
			END IF;
		ELSE
			v_seqnumb := v_zero;
		END IF;

        IF TRIM(obj_polhistobj.B1_ZKNJFULNM) IS NOT NULL THEN
          v_seqnumb := v_seqnumb + 1;
          obj_zbenfdtlspf.SEQNUMB   := v_seqnumb;
          obj_zbenfdtlspf.ZKNJFULNM	:= obj_polhistobj.B1_ZKNJFULNM;
          obj_zbenfdtlspf.CLTADDR01	:= obj_polhistobj.B1_CLTADDR01;
          obj_zbenfdtlspf.BNYPC     := obj_polhistobj.B1_BNYPC;
          obj_zbenfdtlspf.BNYRLN    := obj_polhistobj.B1_BNYRLN;
          INSERT INTO VIEW_DM_ZBENFDTLSPF VALUES obj_zbenfdtlspf;
        END IF;

        IF TRIM(obj_polhistobj.B2_ZKNJFULNM) IS NOT NULL THEN
          v_seqnumb := v_seqnumb + 1;
          obj_zbenfdtlspf.SEQNUMB   := v_seqnumb;
          obj_zbenfdtlspf.ZKNJFULNM	:= obj_polhistobj.B2_ZKNJFULNM;
          obj_zbenfdtlspf.CLTADDR01	:= obj_polhistobj.B2_CLTADDR01;
          obj_zbenfdtlspf.BNYPC     := obj_polhistobj.B2_BNYPC;
          obj_zbenfdtlspf.BNYRLN    := obj_polhistobj.B2_BNYRLN;
          INSERT INTO VIEW_DM_ZBENFDTLSPF VALUES obj_zbenfdtlspf;
        END IF;		

        IF TRIM(obj_polhistobj.B3_ZKNJFULNM) IS NOT NULL THEN
          v_seqnumb := v_seqnumb + 1;
          obj_zbenfdtlspf.SEQNUMB   := v_seqnumb;
          obj_zbenfdtlspf.ZKNJFULNM	:= obj_polhistobj.B3_ZKNJFULNM;
          obj_zbenfdtlspf.CLTADDR01	:= obj_polhistobj.B3_CLTADDR01;
          obj_zbenfdtlspf.BNYPC     := obj_polhistobj.B3_BNYPC;
          obj_zbenfdtlspf.BNYRLN    := obj_polhistobj.B3_BNYRLN;
          INSERT INTO VIEW_DM_ZBENFDTLSPF VALUES obj_zbenfdtlspf;
        END IF;

        IF TRIM(obj_polhistobj.B4_ZKNJFULNM) IS NOT NULL THEN
          v_seqnumb := v_seqnumb + 1;
          obj_zbenfdtlspf.SEQNUMB   := v_seqnumb;
          obj_zbenfdtlspf.ZKNJFULNM	:= obj_polhistobj.B4_ZKNJFULNM;
          obj_zbenfdtlspf.CLTADDR01	:= obj_polhistobj.B4_CLTADDR01;
          obj_zbenfdtlspf.BNYPC     := obj_polhistobj.B4_BNYPC;
          obj_zbenfdtlspf.BNYRLN    := obj_polhistobj.B4_BNYRLN;
          INSERT INTO VIEW_DM_ZBENFDTLSPF VALUES obj_zbenfdtlspf;
        END IF;

        IF TRIM(obj_polhistobj.B5_ZKNJFULNM) IS NOT NULL THEN
          v_seqnumb := v_seqnumb + 1;
          obj_zbenfdtlspf.SEQNUMB   := v_seqnumb;
          obj_zbenfdtlspf.ZKNJFULNM	:= obj_polhistobj.B5_ZKNJFULNM;
          obj_zbenfdtlspf.CLTADDR01	:= obj_polhistobj.B5_CLTADDR01;
          obj_zbenfdtlspf.BNYPC     := obj_polhistobj.B5_BNYPC;
          obj_zbenfdtlspf.BNYRLN    := obj_polhistobj.B5_BNYRLN;
          INSERT INTO VIEW_DM_ZBENFDTLSPF VALUES obj_zbenfdtlspf;
        END IF;	

		v_benoldpol := v_chdrnum;
		IF v_mbrno = '00001' THEN
			v_seqnum01 := v_seqnumb;
		ELSE --v_mbrno = '00002'
			v_seqnum02 := v_seqnumb;
		END IF;		

      END IF;
 ---------------------- INSERT/UPDATE ZBENFDTLSPF END------------------------------------------------------------------------------------------- 
    END IF;
  END LOOP;
  EXIT WHEN cur_pol_hist%notfound;
 -- COMMIT;  --JD EXP1
  END LOOP;
  CLOSE cur_pol_hist;
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);
  dbms_output.put_line('End execution of BQ9UU_MB01_POLHIST, SC NO:  ' ||
                        i_scheduleNumber || ' Flag :' || i_zprvaldYN);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      p_exitcode := SQLCODE;
      p_exittext := 'BQ9UU_MB01_POLHIST : ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm || '-' || v_refkey;

      INSERT INTO Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      VALUES
        (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

      COMMIT;
      RAISE;

 END BQ9UU_MB01_POLHIST;