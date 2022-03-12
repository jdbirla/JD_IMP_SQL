--------------------------------------------------------
--  File created - Friday-July-09-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure BQ9EC_MP01_MSTRPL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."BQ9EC_MP01_MSTRPL" (
    i_schedulename     IN   VARCHAR2,
    i_schedulenumber   IN   VARCHAR2,
    i_zprvaldyn        IN   VARCHAR2,
    i_company          IN   VARCHAR2,
    i_usrprf           IN   VARCHAR2,
    i_branch           IN   VARCHAR2,
    i_transcode        IN   VARCHAR2,
    i_vrcmtermid       IN   VARCHAR2
)
    AUTHID current_user
AS
/***************************************************************************************************
  * Amenment History: MP01 Group Master Policy
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       MP1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * APRIL07            MP1   Initial version
  * SEPT0923           MP2   TRIM added:TRIM(v_insSetPlan_tab(indexSetPlan1).zinstype(indexInsTypes1)) || TRIM(i_company);
  * SEPT0924           MP3   If Collection method is 'DB', zcolmcls to be 'C'
  * SEPT0924           MP4   Added code to get sequence number for enabled trigger
  * SEPT0925           MP5   Added code to populate PAZDMPPF
  * SEPT1001           MP6   set default value to Consignor of free plan
  * SEPT1003           MP6   the default value to zrreffdt changed to 99999999
  * OCTOBER1023        MP7   the definition of altquoteno value changed to 1 space
  * DECEMBER1222       MP8   Iteration 3 functionality
  * FEBRARY0208        MP9   zuwrejflg to be removed
  * MAR02              MP10  Post validation changes
  * JUN10    MKS       MP11  ZJNPG-9664 : Start Time and End Time change in GCHIPF for CR P2-9351 implementation. 
  * OCT110    JD       MP12  ZJNPG-10085 [IG logic change], for FP master policy ZPOLTDATE should be max date and policy will be laspe based on CRDATE/INSENDTE
  *****************************************************************************************************/

    v_timestart                 NUMBER := dbms_utility.get_time;
    p_exitcode                  NUMBER;
    p_exittext                  VARCHAR2(4000);
    errorcount                  NUMBER(1) DEFAULT 0;
    v_y                         VARCHAR2(1 CHAR);
    b_isnoerror                 BOOLEAN := true;
    b_isnoerror_01              BOOLEAN;
    b_isnoerror_02            BOOLEAN;
    b_isnoerror_03              BOOLEAN;
    b_isnoerror_04              BOOLEAN;
    b_isnoerror_05              BOOLEAN;
    b_isnoerror_06              BOOLEAN;
    b_isnoerror_07              BOOLEAN;
    b_isnoerror_08              BOOLEAN;
    b_isnoerror_09              BOOLEAN;
    b_isnoerror_10              BOOLEAN;
    b_isnoerror_11              BOOLEAN;
    b_isnoerror_12              BOOLEAN;
    b_isnoerror_13              BOOLEAN;
    b_isnoerror_14              BOOLEAN;
    b_isnoerror_15              BOOLEAN;
    b_isnoerror_16              BOOLEAN;
    b_isnoerror_17              BOOLEAN;
    b_isnoerror_18              BOOLEAN;
    b_isnoerror_19              BOOLEAN;
    b_isnoerror_20              BOOLEAN;
    b_isnoerror_21              BOOLEAN;
    b_isnoerror_22              BOOLEAN;
    b_isnoerror_23              BOOLEAN;
    b_isnoerror_24              BOOLEAN;
    b_isnoerror_25              BOOLEAN;
    b_isnoerror_26              BOOLEAN;
    b_isnoerror_27              BOOLEAN;
    b_isnoerror_28              BOOLEAN;
    b_isnoerror_29              BOOLEAN;
--- MP8
    b_isnoerror_45              BOOLEAN;
    b_isnoerror_46              BOOLEAN;
    b_chdrnum_isnoerror         BOOLEAN;
    b_createpostvalidation      BOOLEAN;
--- MP8
    v_gchipf_cnt                NUMBER(5, 0);
    v_clrrpf_cnt                NUMBER(5, 0);
    v_zfacthus                  VARCHAR2(2);
    v_crdatesub1d               NUMBER(8, 0);
    v_ccdatesub1m               NUMBER(8, 0);
    v_ccdateadd1m               NUMBER(8, 0);
    v_zpenddtsub1d              NUMBER(8, 0);
    v_zpolperd                  NUMBER(3, 0);
    v_zplancls                  CHAR(2);
    v_cownnum                   CHAR(8);
    v_agtype                    CHAR(2);
    v_agntnum                   CHAR(8);
    v_instypset                 VARCHAR2(12);
    v_sv_mspol_chdrnum          CHAR(8);
    i_chdrnum_break             BOOLEAN;
    v_tranid                    VARCHAR2(14 CHAR);
    v_migration_date            CHAR(8);
    v_cnt_policy                NUMBER(2, 0);
    v_pkvalue                   NUMBER;
    ---Variables for T-table
    t_itemval                   pkg_dm_mastpolicy.itemval_tab;
    r_itemval                   pkg_dm_mastpolicy.itemval_r_val;
    i_key_itemval               VARCHAR2(14);
    ---Variables for DFPOPF
    t_dfpopfval                 pkg_dm_mastpolicy.dfpopf_tab;
    i_key_dfpopval              VARCHAR2(9);
    r_dfpopval                  dfpopf%rowtype;
    ---ClientNumber
    t_clntno                    pkg_dm_mastpolicy.clntno_tab;

    -- PKG_DM_MASTPOLICY.validDateVal --
    v_validdateval              BOOLEAN;
    -- PKG_DM_MASTPOLICY.chkAllHalfSizeChar --
    v_chkallhalfsizechar        BOOLEAN;

    ---Variables for Error message
    o_errortext                 pkg_dm_mastpolicy.errordesc;
    ---Variables for ZDOEMPnnnn
    i_zdoe_info                 pkg_dm_common_operations.obj_zdoe;
    v_tablenametemp             VARCHAR2(10);
    v_tablename                 VARCHAR2(10);
    v_zcolmcls                  CHAR(1);
    v_zcolmcls_org              CHAR(1);
    v_mspol_chdrnum             CHAR(8);
    v_zwavgflg                  VARCHAR2(1);
    v_timech01                  CHAR(8);
    v_timech02                  CHAR(8);
    v_zrnwabl                   VARCHAR2(1);
    v_template                  CHAR(8);
    v_instype1                  CHAR(3);
    v_instype2                  CHAR(3);
    v_instype3                  CHAR(3);
    v_instype4                  CHAR(3);
    v_instypst                  VARCHAR2(50);
    v_busdate                   busdpf.busdate%TYPE;  --- MP8
    v_i_date   number(6);
    -- Constant values
    c_prefix                    CONSTANT VARCHAR2(2) := get_migration_prefix('MSTR', i_company);  --- 'MP'
    c_bq9ec                     CONSTANT VARCHAR2(5) := 'BQ9EC';
    c_h366                      CONSTANT VARCHAR2(5) := 'H366';
    c_h357                      CONSTANT VARCHAR2(5) := 'H357';
    c_e177                      CONSTANT VARCHAR2(5) := 'E177';
    c_e767                      CONSTANT VARCHAR2(5) := 'E767';
    c_rqx4                      CONSTANT VARCHAR2(5) := 'RQX4';
    c_rpmy                      CONSTANT VARCHAR2(5) := 'RPMY';
    c_rfq9                      CONSTANT VARCHAR2(5) := 'RFQ9';
    c_f596                      CONSTANT VARCHAR2(5) := 'F596';
    c_e315                      CONSTANT VARCHAR2(5) := 'E315';
    c_e999                      CONSTANT VARCHAR2(5) := 'E999';
    c_rg11                      CONSTANT VARCHAR2(5) := 'RG11';
    c_w219                      CONSTANT VARCHAR2(5) := 'W219';
    c_rptj                      CONSTANT VARCHAR2(5) := 'RPTJ';
    c_rr99                      CONSTANT VARCHAR2(5) := 'RR99';
    c_rgig                      CONSTANT VARCHAR2(5) := 'RGIG';
    c_rqm9                      CONSTANT VARCHAR2(5) := 'RQM9';
    c_e725                      CONSTANT VARCHAR2(5) := 'E725';
    c_w266                      CONSTANT VARCHAR2(5) := 'W226';
    c_rfzw                      CONSTANT VARCHAR2(5) := 'RFZW';
    c_rqsq                      CONSTANT VARCHAR2(5) := 'RQSQ';
    c_ev02                      CONSTANT VARCHAR2(5) := 'EV02';
    c_rqya                      CONSTANT VARCHAR2(5) := 'RQYA';
    c_rrym                      CONSTANT VARCHAR2(5) := 'RRYM';
    c_e456                      CONSTANT VARCHAR2(5) := 'E456';
    c_e048                      CONSTANT VARCHAR2(5) := 'E048';
    c_rqwl                      CONSTANT VARCHAR2(5) := 'RQWL';
    ---- MP8 ---
    c_d041                      CONSTANT VARCHAR2(5) := 'D041';
    c_g532                      CONSTANT VARCHAR2(5) := 'G532';
    c_rfaa                      CONSTANT VARCHAR2(5) := 'RFAA';
    ---- MP8 ---
    c_sts_xn                    CONSTANT CHAR(2) := 'XN';
    c_sts_if                    CONSTANT CHAR(2) := 'IF';
    c_sts_ca                    CONSTANT CHAR(2) := 'CA';
    c_sts_la                    CONSTANT CHAR(2) := 'LA';   ---MP8
    c_zendcdst                  CONSTANT CHAR(2) := 'AP';
    c_zcolmcls_fh               CONSTANT CHAR(1) := 'F';
    c_zcolmcls_cd               CONSTANT CHAR(1) := 'C';
    c_colmethod_db              CONSTANT CHAR(2) := 'DB';
    c_rptfpst_free              CONSTANT CHAR(1) := 'F';
    c_rptfpst_paid              CONSTANT CHAR(1) := 'P';
    c_zplancls_free             CONSTANT CHAR(2) := 'FP';
    c_zplancls_paid             CONSTANT CHAR(2) := 'PP';
    c_zblnkpol                  CONSTANT CHAR(1) := 'Y';
    c_nozblnkpol                CONSTANT CHAR(1) := 'N';
    c_weightedaverage           CONSTANT CHAR(1) := 'Y';
    c_nonweightedaverage        CONSTANT CHAR(1) := 'N';
    c_zwavg                     CONSTANT VARCHAR2(1) := '1';
    c_nonzwavg                  CONSTANT VARCHAR2(1) := '0';
    c_zagptpfx                  CONSTANT CHAR(2) := 'AP';
    c_agntpfx                   CONSTANT CHAR(2) := 'AG';
    c_zagpt_aprv                CONSTANT CHAR(2) := 'AP';
    c_t9799                     CONSTANT VARCHAR2(5) := 'T9799';
    c_t3684                     CONSTANT VARCHAR2(5) := 'T3684';
    c_tq9gx                     CONSTANT VARCHAR2(5) := 'TQ9GX';
    c_tq9fk                     CONSTANT VARCHAR2(5) := 'TQ9FK';
    c_tq9e4                     CONSTANT VARCHAR2(5) := 'TQ9E4';
    c_tw966                     CONSTANT VARCHAR2(5) := 'TW966';
    c_tq9e6                     CONSTANT VARCHAR2(5) := 'TQ9E6';
    c_tq9b6                     CONSTANT VARCHAR2(5) := 'TQ9B6';
    c_itemcoy_9                 CONSTANT CHAR(1) := '9';
    c_nbtrncd                   CONSTANT VARCHAR2(4) := 'T902';  ---NB
    c_cntrncd                   CONSTANT VARCHAR2(4) := 'T912';  ---CANCELLATION,LAPSE
    c_rntrncd                   CONSTANT VARCHAR2(4) := 'T918';  ---RENEWAL

  ---- constant for fields default value  start ------------
    c_gchd_recode               CONSTANT CHAR(2) := NULL;
    c_gchd_currfrom             CONSTANT NUMBER(8, 0) := 0;
    c_gchd_currto               CONSTANT NUMBER(8, 0) := 0;
    c_gchd_proctrancd           CONSTANT CHAR(4) := NULL;
    c_gchd_procflag             CONSTANT CHAR(2) := NULL;
    c_gchd_procid               CONSTANT CHAR(14) := '              ';
    c_gchd_statreasn            CONSTANT CHAR(2) := NULL;
    c_gchd_statdate             CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_stattran             CONSTANT NUMBER(5, 0) := NULL;
    c_gchd_tranlused            CONSTANT NUMBER(5, 0) := 1;
    c_gchd_ccdate               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_crdate               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_annamt01             CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_annamt02             CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_annamt03             CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_annamt04             CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_annamt05             CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_annamt06             CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_rnltype              CONSTANT CHAR(2) := NULL;
    c_gchd_rnlnots              CONSTANT CHAR(2) := NULL;
    c_gchd_rnlattn              CONSTANT CHAR(2) := NULL;
    c_gchd_rnldurn              CONSTANT NUMBER(2, 0) := NULL;
    c_gchd_reptype              CONSTANT CHAR(2) := '  ';
    c_gchd_repnum               CONSTANT CHAR(25) := '                         ';
    c_gchd_jownnum              CONSTANT CHAR(8) := NULL;
    c_gchd_payrpfx              CONSTANT CHAR(2) := '  ';
    c_gchd_payrcoy              CONSTANT CHAR(1) := ' ';
    c_gchd_payrnum              CONSTANT CHAR(8) := '        ';
    c_gchd_desppfx              CONSTANT CHAR(2) := '  ';
    c_gchd_despcoy              CONSTANT CHAR(1) := ' ';
    c_gchd_despnum              CONSTANT CHAR(8) := '        ';
    c_gchd_asgnpfx              CONSTANT CHAR(2) := NULL;
    c_gchd_asgncoy              CONSTANT CHAR(1) := NULL;
    c_gchd_asgnnum              CONSTANT CHAR(8) := NULL;
    c_gchd_cntbranch            CONSTANT CHAR(2) := NULL;
    c_gchd_agntpfx              CONSTANT CHAR(2) := NULL;
    c_gchd_agntcoy              CONSTANT CHAR(1) := NULL;
    c_gchd_agntnum              CONSTANT CHAR(8) := NULL;
    c_gchd_acctccy              CONSTANT CHAR(3) := NULL;
    c_gchd_crate                CONSTANT NUMBER(18, 9) := NULL;
    c_gchd_payplan              CONSTANT CHAR(6) := NULL;
    c_gchd_acctmeth             CONSTANT CHAR(1) := NULL;
    c_gchd_billfreq             CONSTANT CHAR(2) := NULL;
    c_gchd_billchnl             CONSTANT CHAR(2) := NULL;
    c_gchd_collchnl             CONSTANT CHAR(2) := NULL;
    c_gchd_billday              CONSTANT CHAR(2) := NULL;
    c_gchd_billmonth            CONSTANT CHAR(2) := NULL;
    c_gchd_billcd               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_btdate               CONSTANT NUMBER(8, 0) := 99999999;
    c_gchd_ptdate               CONSTANT NUMBER(8, 0) := 99999999;
    c_gchd_payflag              CONSTANT CHAR(1) := NULL;
    c_gchd_sinstfrom            CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_sinstto              CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_sinstamt01           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_sinstamt02           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_sinstamt03           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_sinstamt04           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_sinstamt05           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_sinstamt06           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_instfrom             CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_instto               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_instbchnl            CONSTANT CHAR(2) := NULL;
    c_gchd_instcchnl            CONSTANT CHAR(2) := NULL;
    c_gchd_instfreq             CONSTANT CHAR(2) := NULL;
    c_gchd_insttot01            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_insttot02            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_insttot03            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_insttot04            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_insttot05            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_insttot06            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_instpast01           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_instpast02           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_instpast03           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_instpast04           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_instpast05           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_instpast06           CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_instjctl             CONSTANT CHAR(24) := NULL;
    c_gchd_nofoutinst           CONSTANT NUMBER(3, 0) := NULL;
    c_gchd_outstamt             CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_billdate01           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_billdate02           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_billdate03           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_billdate04           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_billamt01            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_billamt02            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_billamt03            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_billamt04            CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_facthous             CONSTANT CHAR(2) := NULL;
    c_gchd_bankkey              CONSTANT CHAR(10) := NULL;
    c_gchd_bankacckey           CONSTANT CHAR(20) := NULL;
    c_gchd_discode01            CONSTANT CHAR(1) := NULL;
    c_gchd_discode02            CONSTANT CHAR(1) := NULL;
    c_gchd_discode03            CONSTANT CHAR(1) := NULL;
    c_gchd_discode04            CONSTANT CHAR(1) := NULL;
    c_gchd_grupkey              CONSTANT CHAR(12) := NULL;
    c_gchd_membsel              CONSTANT CHAR(10) := NULL;
    c_gchd_aplsupr              CONSTANT CHAR(1) := NULL;
    c_gchd_aplspfrom            CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_aplspto              CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_billsupr             CONSTANT CHAR(1) := NULL;
    c_gchd_billspfrom           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_billspto             CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_commsupr             CONSTANT CHAR(1) := NULL;
    c_gchd_commspfrom           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_commspto             CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_lapssupr             CONSTANT CHAR(1) := NULL;
    c_gchd_lapsspfrom           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_lapsspto             CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_mailsupr             CONSTANT CHAR(1) := NULL;
    c_gchd_mailspfrom           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_mailspto             CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_notssupr             CONSTANT CHAR(1) := NULL;
    c_gchd_notsspfrom           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_notsspto             CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_rnwlsupr             CONSTANT CHAR(1) := NULL;
    c_gchd_rnwlspfrom           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_rnwlspto             CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_campaign             CONSTANT CHAR(6) := NULL;
    c_gchd_nofrisks             CONSTANT NUMBER(4, 0) := NULL;
    c_gchd_jacket               CONSTANT CHAR(8) := NULL;
    c_gchd_isam01               CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_isam02               CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_isam03               CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_isam04               CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_isam05               CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_isam06               CONSTANT NUMBER(17, 2) := NULL;
    c_gchd_pstcde               CONSTANT CHAR(2) := NULL;
    c_gchd_pstrsn               CONSTANT CHAR(2) := NULL;
    c_gchd_psttrn               CONSTANT NUMBER(5, 0) := NULL;
    c_gchd_pstdat               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_pdind                CONSTANT CHAR(2) := NULL;
    c_gchd_reg                  CONSTANT CHAR(3) := NULL;
    c_gchd_stca                 CONSTANT CHAR(3) := NULL;
    c_gchd_stcb                 CONSTANT CHAR(3) := NULL;
    c_gchd_stcc                 CONSTANT CHAR(3) := NULL;
    c_gchd_stcd                 CONSTANT CHAR(3) := NULL;
    c_gchd_stce                 CONSTANT CHAR(3) := NULL;
    c_gchd_mplpfx               CONSTANT CHAR(2) := '  ';
    c_gchd_poapfx               CONSTANT CHAR(2) := NULL;
    c_gchd_poacoy               CONSTANT CHAR(1) := NULL;
    c_gchd_poanum               CONSTANT CHAR(8) := NULL;
    c_gchd_finpfx               CONSTANT CHAR(2) := NULL;
    c_gchd_fincoy               CONSTANT CHAR(1) := NULL;
    c_gchd_finnum               CONSTANT CHAR(8) := NULL;
    c_gchd_wvfdat               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_wvtdat               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_wvfind               CONSTANT CHAR(1) := NULL;
    c_gchd_clupfx               CONSTANT CHAR(2) := NULL;
    c_gchd_clucoy               CONSTANT CHAR(1) := NULL;
    c_gchd_clunum               CONSTANT CHAR(8) := NULL;
    c_gchd_polpln               CONSTANT CHAR(10) := NULL;
    c_gchd_chgflag              CONSTANT CHAR(1) := NULL;
    c_gchd_laprind              CONSTANT CHAR(1) := NULL;
    c_gchd_specind              CONSTANT CHAR(1) := ' ';
    c_gchd_dueflg               CONSTANT CHAR(1) := NULL;
    c_gchd_bfcharge             CONSTANT CHAR(1) := NULL;
    c_gchd_dishnrcnt            CONSTANT NUMBER(2, 0) := NULL;
    c_gchd_pdtype               CONSTANT CHAR(1) := NULL;
    c_gchd_dishnrdte            CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_stmpdtyamt           CONSTANT NUMBER(15, 2) := NULL;
    c_gchd_stmpdtydte           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_polinc               CONSTANT NUMBER(4, 0) := NULL;
    c_gchd_polsum               CONSTANT NUMBER(4, 0) := NULL;
    c_gchd_nxtsfx               CONSTANT NUMBER(4, 0) := NULL;
    c_gchd_avlisu               CONSTANT CHAR(1) := ' ';
    c_gchd_stmdte               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_tfrswused            CONSTANT NUMBER(4, 0) := NULL;
    c_gchd_tfrswleft            CONSTANT NUMBER(4, 0) := NULL;
    c_gchd_lastswdate           CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_mandref              CONSTANT CHAR(5) := NULL;
    c_gchd_cntiss               CONSTANT NUMBER(8, 0) := 0;
    c_gchd_cntrcv               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_coppn                CONSTANT NUMBER(11, 8) := NULL;
    c_gchd_cotype               CONSTANT CHAR(1) := NULL;
    c_gchd_covernt              CONSTANT CHAR(8) := '        ';
    c_gchd_docnum               CONSTANT CHAR(8) := NULL;
    c_gchd_dtecan               CONSTANT NUMBER(8, 0) := NULL;
    c_gchd_quoteno              CONSTANT CHAR(8) := NULL;
    c_gchd_rnlsts               CONSTANT CHAR(2) := NULL;
    c_gchd_sustrcde             CONSTANT CHAR(4) := NULL;
    c_gchd_bankcode             CONSTANT CHAR(2) := NULL;
    c_gchd_subsflg              CONSTANT CHAR(1) := ' ';
    c_gchd_hrskind              CONSTANT CHAR(1) := 'N';
    c_gchd_slrypflg             CONSTANT CHAR(1) := NULL;
    c_gchd_takovrflg            CONSTANT CHAR(1) := ' ';
    c_gchd_gprnltyp             CONSTANT CHAR(1) := 'Y';
    c_gchd_gprmnths             CONSTANT NUMBER(2, 0) := 2;
    c_gchd_coysrvac             CONSTANT CHAR(3) := '   ';
    c_gchd_mrksrvac             CONSTANT CHAR(3) := '   ';
    c_gchd_adjdate              CONSTANT NUMBER(8, 0) := 99999999;
    c_gchd_ptdateab             CONSTANT NUMBER(8, 0) := 99999999;
    c_gchd_lmbrno               CONSTANT NUMBER(5, 0) := 0;
    c_gchd_lheadno              CONSTANT NUMBER(5, 0) := 0;
    c_gchd_effdcldt             CONSTANT NUMBER(8, 0) := 99999999;
    c_gchd_agedef               CONSTANT CHAR(1) := ' ';
    c_gchd_personcov            CONSTANT CHAR(1) := ' ';
    c_gchd_dtlsind              CONSTANT CHAR(1) := NULL;
    c_gchd_zrenno               CONSTANT NUMBER(5, 0) := NULL;
    c_gchd_zendno               CONSTANT NUMBER(3, 0) := NULL;
    c_gchd_zresnpd              CONSTANT CHAR(2) := NULL;
    c_gchd_zrepolno             CONSTANT CHAR(20) := NULL;
    c_gchd_zcomtyp              CONSTANT CHAR(1) := NULL;
    c_gchd_zrinum               CONSTANT CHAR(16) := NULL;
    c_gchd_zschprt              CONSTANT CHAR(1) := NULL;
    c_gchd_zpaymode             CONSTANT CHAR(2) := NULL;
    c_gchd_quotetype            CONSTANT CHAR(2) := '0 ';
    c_gchd_zmandref             CONSTANT CHAR(5) := NULL;
    c_gchd_reqntype             CONSTANT CHAR(1) := NULL;
    c_gchd_payclt               CONSTANT CHAR(8) := NULL;
    c_gchd_midjoin              CONSTANT NCHAR(1) := ' ';
    c_gchd_igrasp               CONSTANT NCHAR(1) := ' ';
    c_gchd_iexplain             CONSTANT NCHAR(1) := ' ';
    c_gchd_idate                CONSTANT NUMBER(8, 0) := 99999999;
    c_gchd_cvisaind             CONSTANT NCHAR(1) := ' ';
    c_gchd_suprflg              CONSTANT NCHAR(1) := NULL;
    c_gchd_iendno               CONSTANT NUMBER(3, 0) := NULL;
    c_gchd_peiendind            CONSTANT NCHAR(1) := NULL;
    c_gchd_duedte               CONSTANT NUMBER(38, 0) := NULL;
    c_gchd_schmno               CONSTANT NCHAR(8) := '        ';
    c_gchd_jobnum               CONSTANT NUMBER(38, 0) := NULL;
    c_gchd_nlgflg               CONSTANT NCHAR(1) := NULL;
    c_gchd_zrwnlage             CONSTANT NUMBER(3, 0) := NULL;
    c_gchd_zprvchdr             CONSTANT VARCHAR2(8) := NULL;
    c_gchd_rtgrante             CONSTANT NCHAR(1) := ' ';
    c_gchd_rtgrantedate         CONSTANT NUMBER(38, 0) := 0;
    c_gchd_cpiincrind           CONSTANT NCHAR(1) := ' ';
    c_gchd_superflag            CONSTANT NCHAR(1) := ' ';
    c_gchipf_payrpfx            CONSTANT CHAR(2) := NULL;
    c_gchipf_payrcoy            CONSTANT CHAR(1) := NULL;
    c_gchipf_payrnum            CONSTANT CHAR(8) := NULL;
    c_gchipf_stcb               CONSTANT CHAR(3) := '   ';
    c_gchipf_stcc               CONSTANT CHAR(3) := NULL;
    c_gchipf_stcd               CONSTANT CHAR(3) := NULL;
    c_gchipf_stce               CONSTANT CHAR(3) := NULL;
    c_gchipf_btdatenr           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchipf_nrisdate           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchipf_user_t             CONSTANT NUMBER(6, 0) := 0;
    c_gchipf_trdt               CONSTANT NUMBER(6, 0) := 0;
    c_gchipf_trtm               CONSTANT NUMBER(6, 0) := 0;
    c_gchipf_tranno             CONSTANT NUMBER(5, 0) := 1;
    c_gchipf_crate              CONSTANT NUMBER(18, 9) := 0;
    c_gchipf_ternmprm           CONSTANT NUMBER(2, 0) := 0;
    c_gchipf_surgschmv          CONSTANT CHAR(3) := '   ';
    c_gchipf_areacdemv          CONSTANT CHAR(3) := '   ';
    c_gchipf_medprvdr           CONSTANT CHAR(10) := '          ';
    c_gchipf_spsmbr             CONSTANT CHAR(1) := ' ';
    c_gchipf_childmbr           CONSTANT CHAR(1) := ' ';
    c_gchipf_spsmed             CONSTANT CHAR(1) := ' ';
    c_gchipf_childmed           CONSTANT CHAR(1) := ' ';
    c_gchipf_bankcode           CONSTANT CHAR(2) := '  ';
    c_gchipf_billchnl           CONSTANT CHAR(2) := 'C ';
    c_gchipf_mandref            CONSTANT CHAR(5) := NULL;
    c_gchipf_rimthvcd           CONSTANT CHAR(2) := '  ';
    c_gchipf_prmrvwdt           CONSTANT NUMBER(8, 0) := 0;
    c_gchipf_appltyp            CONSTANT CHAR(2) := '  ';
    c_gchipf_cflimit            CONSTANT NUMBER(13, 0) := 0;
    c_gchipf_polbreak           CONSTANT CHAR(1) := NULL;
    c_gchipf_cftype             CONSTANT CHAR(3) := NULL;
    c_gchipf_lmtdrl             CONSTANT CHAR(6) := NULL;
    c_gchipf_nofclaim           CONSTANT NUMBER(6, 0) := 0;
    c_gchipf_tpa                CONSTANT CHAR(8) := NULL;
    c_gchipf_wkladrt            CONSTANT NUMBER(5, 2) := 0;
    c_gchipf_wklcmrt            CONSTANT NUMBER(5, 2) := 0;
    c_gchipf_nofmbr             CONSTANT NUMBER(7, 0) := 0;
    c_gchipf_ecnv               CONSTANT CHAR(1) := ' ';
    c_gchipf_cvntype            CONSTANT CHAR(2) := NULL;
    c_gchipf_covernt            CONSTANT CHAR(8) := '        ';
    c_gchipf_tpaflg             CONSTANT NCHAR(1) := NULL;
    c_gchipf_docrcdte           CONSTANT NUMBER(38, 0) := 99999999;
    c_gchipf_insstdte           CONSTANT CHAR(10) := NULL;
    c_gchipf_zcmpcode           CONSTANT VARCHAR2(6) := NULL;
    c_gchipf_zsolctflg          CONSTANT VARCHAR2(1) := NULL;
    c_gchipf_hpropdte           CONSTANT NUMBER(8, 0) := NULL;
    c_gchipf_zcedtime           CONSTANT TIMESTAMP(6) := NULL;
    c_gchipf_zcstime            CONSTANT VARCHAR2(6) := NULL;
    c_gchipf_cownnum            CONSTANT VARCHAR2(8) := NULL;
    c_gchipf_zrnwcnt            CONSTANT NUMBER(3, 0) := 0; --- MP8
    c_gchppf_exbrknm            CONSTANT CHAR(47) := '                                               ';
    c_gchppf_exundnm            CONSTANT CHAR(47) := '                                               ';
    c_gchppf_brksrvac           CONSTANT CHAR(50) := '                                                  ';
    c_gchppf_refno              CONSTANT CHAR(20) := '                    ';
    c_gchppf_mbrdata            CONSTANT CHAR(2) := '  ';
    c_gchppf_defplandi          CONSTANT CHAR(6) := '      ';
    c_gchppf_empgrp             CONSTANT CHAR(2) := '  ';
    c_gchppf_inwinctyp          CONSTANT CHAR(2) := '  ';
    c_gchppf_areacod            CONSTANT CHAR(6) := '      ';
    c_gchppf_industry           CONSTANT CHAR(6) := '      ';
    c_gchppf_majormet           CONSTANT CHAR(2) := '  ';
    c_gchppf_ffeewhom           CONSTANT CHAR(10) := NULL;
    c_gchppf_feelvl             CONSTANT CHAR(1) := ' ';
    c_gchppf_ctbeffdt           CONSTANT CHAR(2) := '  ';
    c_gchppf_exbfml             CONSTANT CHAR(2) := '  ';
    c_gchppf_exbldays           CONSTANT NUMBER(3, 0) := 0;
    c_gchppf_ctbfml             CONSTANT CHAR(2) := '  ';
    c_gchppf_ctbndays           CONSTANT NUMBER(3, 0) := 0;
    c_gchppf_efais              CONSTANT CHAR(5) := '     ';
    c_gchppf_efadp              CONSTANT CHAR(5) := '     ';
    c_gchppf_norem              CONSTANT NUMBER(1, 0) := 0;
    c_gchppf_fstrmfml           CONSTANT CHAR(2) := '  ';
    c_gchppf_fstrmday           CONSTANT NUMBER(3, 0) := 0;
    c_gchppf_sndrmfml           CONSTANT CHAR(2) := '  ';
    c_gchppf_sndrmday           CONSTANT NUMBER(3, 0) := 0;
    c_gchppf_trdrmfml           CONSTANT CHAR(2) := '  ';
    c_gchppf_trdrmday           CONSTANT NUMBER(3, 0) := 0;
    c_gchppf_exbduedt           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_ctbduedt           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_lstexbfr           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_lstexbto           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_lstctbfr           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_lstctbto           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_lstebpdt           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_fstrmpdt           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_sndrmpdt           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_trdrmpdt           CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_polanv             CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_ctbrule            CONSTANT CHAR(5) := '     ';
    c_gchppf_acblrule           CONSTANT CHAR(5) := '     ';
    c_gchppf_fmcrule            CONSTANT CHAR(3) := '   ';
    c_gchppf_swtranno           CONSTANT NUMBER(8, 0) := 0;
    c_gchppf_feewho             CONSTANT CHAR(1) := ' ';
    c_gchppf_zsrcebus           CONSTANT CHAR(8) := NULL;
    c_gchppf_agebasis           CONSTANT CHAR(1) := ' ';
    c_gchppf_fcllvl             CONSTANT CHAR(3) := 'N.A';
    c_gchppf_prmpyopt           CONSTANT CHAR(3) := '   ';
    c_gchppf_prmbrlvl           CONSTANT CHAR(1) := ' ';
    c_gchppf_tolrule            CONSTANT CHAR(1) := ' ';
    c_gchppf_swcflg             CONSTANT CHAR(1) := ' ';
    c_gchppf_certinfm           CONSTANT CHAR(8) := '        ';
    c_gchppf_fmc2rule           CONSTANT CHAR(3) := '   ';
    c_gchppf_lmbrpfx            CONSTANT CHAR(4) := NULL;
    c_gchppf_loybnflg           CONSTANT CHAR(1) := ' ';
    c_gchppf_autornw            CONSTANT CHAR(1) := ' ';
    c_gchppf_gaplpfx            CONSTANT CHAR(2) := '  ';
    c_gchppf_nmlvar             CONSTANT CHAR(3) := '   ';
    c_gchppf_extfmly            CONSTANT CHAR(1) := ' ';
    c_gchppf_pinfdte            CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_cashless           CONSTANT CHAR(1) := NULL;
    c_gchppf_location           CONSTANT CHAR(6) := NULL;
    c_gchppf_sublocn            CONSTANT CHAR(6) := NULL;
    c_gchppf_ttdate             CONSTANT NUMBER(8, 0) := 99999999;
    c_gchppf_optautornw         CONSTANT NCHAR(1) := NULL;
    c_gchppf_ocallvsa           CONSTANT NCHAR(8) := NULL;
    c_gchppf_zaplfod            CONSTANT NUMBER(8, 0) := 0;  --MP10
    c_gchppf_zgporipcls         CONSTANT CHAR(8) := NULL;
    c_gchppf_matage             CONSTANT NUMBER(3, 0) := NULL;
    c_gchppf_stmpdutyexe        CONSTANT NCHAR(1) := NULL;
    c_gchppf_zismbrpol          CONSTANT CHAR(1) := NULL;
    c_gchppf_zinsrendt          CONSTANT NUMBER(8, 0) := NULL;
    c_gchppf_zconvindpol        CONSTANT VARCHAR2(8) := NULL;
    c_gchppf_zpoltdate          CONSTANT NUMBER(8, 0) := 99999999;  -- MP8
    c_gchppf_hldcount           CONSTANT NUMBER(1, 0) := NULL;
    c_gchppf_sinstno            CONSTANT NUMBER(3, 0) := NULL;
    c_gchppf_zpgpfrdt           CONSTANT NUMBER(8, 0) := NULL;
    c_gchppf_zpgptodt           CONSTANT NUMBER(8, 0) := NULL;
    c_gchppf_znbmnage           CONSTANT NUMBER(3, 0) := NULL;
    c_gchppf_zsalechnl          CONSTANT VARCHAR2(2) := NULL;
    c_gchppf_zgrpcls            CONSTANT CHAR(8) := '        ';
    c_zenctpf_zprefix           CONSTANT VARCHAR2(2) := NULL;
    c_zenctpf_seqno             CONSTANT NUMBER(2, 0) := NULL;
    c_zenctpf_zcrdtype          CONSTANT VARCHAR2(1) := ' ';--MP10
    c_zenctpf_zcnbrfrm          CONSTANT VARCHAR2(16) := ' '; --MP10
    c_zenctpf_zcnbrto           CONSTANT VARCHAR2(16) := ' '; --MP10
    c_zenctpf_zmstid            CONSTANT CHAR(15) := NULL;
    c_zenctpf_zmstsnme          CONSTANT CHAR(60) := NULL;
    c_zenctpf_zmstidv           CONSTANT VARCHAR2(15) := NULL;
    c_zenctpf_zmstsnmev         CONSTANT VARCHAR2(60) := ' ';--MP10
    c_zenctpf_zcarddc           CONSTANT NUMBER(2, 0) := 0; --MP10
    c_zenctpf_zccde             CONSTANT CHAR(15) := NULL;
    c_zenctpf_zconsgnm          CONSTANT CHAR(60) := NULL;
    c_zenctpf_zccde_free        CONSTANT CHAR(15) := '9';
    c_zenctpf_zconsgnm_free     CONSTANT CHAR(60) := '9';
    c_ztgmpf_tranno             CONSTANT NUMBER(5, 0) := 1;
    c_ztgmpf_zgrpdtrt           CONSTANT NUMBER(3, 2) := NULL;
    ---MP6
    c_ztgmpf_zrreffdt           CONSTANT NUMBER(8, 0) := 99999999;
    c_ztrapf_tranno             CONSTANT NUMBER(5, 0) := 1;
    c_ztrapf_efdate             CONSTANT NUMBER(8, 0) := NULL;
    c_ztrapf_zlogaltdt          CONSTANT NUMBER(8, 0) := 99999999;
    c_ztrapf_zaltrcde01         CONSTANT VARCHAR2(3) := '   ';
    c_ztrapf_zaltrcde02         CONSTANT VARCHAR2(3) := '   ';
    c_ztrapf_zaltrcde03         CONSTANT VARCHAR2(3) := '   ';
    c_ztrapf_zaltrcde04         CONSTANT VARCHAR2(3) := '   ';
    c_ztrapf_zaltrcde05         CONSTANT VARCHAR2(3) := '   ';
    c_ztrapf_zfinancflg         CONSTANT VARCHAR2(1) := ' ';
    c_ztrapf_zclmrecd           CONSTANT NUMBER(8, 0) := 99999999;
    c_ztrapf_zinhdsclm          CONSTANT VARCHAR2(1) := ' ';
    c_ztrapf_zfinalbym          CONSTANT NUMBER(6, 0) := NULL;
    c_ztrapf_zuwrejflg          CONSTANT VARCHAR2(1) := ' ';
    c_ztrapf_zvioltyp           CONSTANT VARCHAR2(4) := '    ';
    c_ztrapf_zstopbpj           CONSTANT VARCHAR2(1) := ' ';
    c_ztrapf_zdfcncy            CONSTANT VARCHAR2(1) := ' ';
    c_ztrapf_zmargnflg          CONSTANT VARCHAR2(1) := ' ';
    c_ztrapf_docrcdte           CONSTANT NUMBER(8, 0) := NULL;
    c_ztrapf_hpropdte           CONSTANT NUMBER(8, 0) := NULL;
    c_ztrapf_zstatresn          CONSTANT VARCHAR2(4) := '    ';
    c_ztrapf_zaclsdat           CONSTANT NUMBER(8, 0) := NULL;
    c_ztrapf_zpoldate           CONSTANT NUMBER(8, 0) := NULL;
    c_ztrapf_unique_number_01   CONSTANT NUMBER(18, 0) := NULL;
    -- MP7
    c_ztrapf_altquoteno         CONSTANT VARCHAR2(8) := ' ';
    c_ztrapf_zpdatatxdat        CONSTANT NUMBER(8, 0) := 99999999;
    c_ztrapf_zpdatatxflg        CONSTANT VARCHAR2(1) := ' ';
    c_ztrapf_zrefundam          CONSTANT NUMBER(17, 2) := 0;
    c_ztrapf_zsurchrge          CONSTANT NUMBER(17, 2) := 0;
    c_ztrapf_zsalplnchg         CONSTANT VARCHAR2(1) := ' ';
    c_ztrapf_zcpmtddt           CONSTANT NUMBER(8, 0) := NULL;
    c_ztrapf_zshftpgp           CONSTANT VARCHAR2(1) := NULL;
    c_ztrapf_zcstpbil           CONSTANT VARCHAR2(1) := NULL;
    c_ztrapf_zcpmcpncde         CONSTANT VARCHAR2(6) := NULL;
    c_ztrapf_zcpmplancd         CONSTANT VARCHAR2(30) := NULL;
    c_ztrapf_zcpmbilamt         CONSTANT NUMBER(15, 2) := NULL;
    c_ztrapf_zbdpgpset          CONSTANT VARCHAR2(1) := NULL;
    c_ztrapf_zrvtranno          CONSTANT NUMBER(5, 0) := 0;
    c_ztrapf_zbltranno          CONSTANT NUMBER(5, 0) := 0;
    c_ztrapf_zvldtrxind         CONSTANT CHAR(1) := NULL;
    c_ztrapf_statcode_if        CONSTANT CHAR(2) := 'IF';
    c_ztrapf_statcode_ca        CONSTANT CHAR(2) := 'CA';
    c_ztrapf_zaltrcde01_pc      CONSTANT CHAR(3) := 'GC1';  --- Paid Cancellation  MP8
    c_ztrapf_zaltrcde01_fc      CONSTANT CHAR(3) := 'OT4';  --- Free Cancellation  MP8
    c_ztrapf_zaltrcde01_la      CONSTANT CHAR(3) := 'GC3';  --- Lapse  MP8
    c_ztrapf_zrcaltty           CONSTANT VARCHAR2(4 CHAR) := ' '; --- MP8
    c_audit_clrrpf_action       CONSTANT CHAR(10) := 'INSERT';
    c_clrrpf_used2b             CONSTANT CHAR(1) := ' ';
  ---- constant for fields default value  end ------------
  --------------Common Function Start---------
    o_defaultvalues             pkg_dm_common_operations.defaultvaluesmap;

  ------IG table obj start---
    obj_gchd                    gchd%rowtype;
    obj_gchipf                  gchipf%rowtype;
    obj_gchppf                  gchppf%rowtype;
    obj_zenctpf                 zenctpf%rowtype;
    obj_ztgmpf                  ztgmpf%rowtype;
    obj_ztrapf                  ztrapf%rowtype;
    obj_clrrpf                  clrrpf%rowtype;
    obj_audit_clrrpf            audit_clrrpf%rowtype;
  -------- Variables for testing ---------------
    tst_reccnt                  NUMBER(4, 0);

  --error cont start
    t_index                     PLS_INTEGER;
    TYPE ercode_tab IS
        TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
    t_ercode                    ercode_tab;
    TYPE errorfield_tab IS
        TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
    t_errorfield                errorfield_tab;
    TYPE errormsg_tab IS
        TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
    t_errormsg                  errormsg_tab;
    TYPE errorfieldvalue_tab IS
        TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
    t_errorfieldval             errorfieldvalue_tab;
    TYPE i_errorprogram_tab IS
        TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
    t_errorprogram              i_errorprogram_tab;
    TYPE v_array_titdmginsstpl IS
        TABLE OF titdmginsstpl@dmstagedblink%rowtype;
    titdmginsstpl_list          v_array_titdmginsstpl;
    TYPE v_array_titdmgendctpf IS
        TABLE OF titdmgendctpf@dmstagedblink%rowtype;
    titdmgendctpf_list          v_array_titdmgendctpf;
    TYPE t_instypes IS
        TABLE OF CHAR(3) INDEX BY BINARY_INTEGER;   -- one insurance plan
    TYPE r_inssetplan IS RECORD (
        recidxmpistp          NUMBER(38, 0),
        chdrnum               VARCHAR2(11),
        plnsetnum             NUMBER(1, 0),
        zinstype              t_instypes,
        cmbinssetplan         VARCHAR2(15),
        sortedcmbinssetplan   VARCHAR2(12)
    );
    TYPE t_inssetplan IS
        TABLE OF r_inssetplan INDEX BY BINARY_INTEGER;   -- Insurance set plans
    v_inssetplan_tab            t_inssetplan;
    ix_instypes                 PLS_INTEGER;
    ix_inssetplan               PLS_INTEGER;
    obj_dmigtitdmgmaspol        dmigtitdmgmaspol%rowtype;
  --------------Staging table cursor---------
    CURSOR maspol_cursor IS
    SELECT
        ms1.*,
        DECODE(ms1.stdchdrnum, NULL, 1, ROW_NUMBER() OVER(
            PARTITION BY ms1.stdchdrnum
            ORDER BY
                ms1.crdate || ms1.recidxmpmspol
        )) period_num  --- MP8
        ,
        DECODE(ms2.cnt_policy, NULL, 1, ms2.cnt_policy) cnt_policy
    FROM
        (
            SELECT
                titdmgmaspol.*,
                CASE length(TRIM(chdrnum))
                    WHEN 11 THEN
                        substr(TRIM(chdrnum), 4, 8)
                    ELSE
                        TRIM(chdrnum)
                END stdchdrnum
            FROM
                titdmgmaspol@dmstagedblink
        ) ms1
        LEFT JOIN (
            SELECT
                stdchdrnum,
                COUNT(*) cnt_policy
            FROM
                (
                    SELECT
                        CASE length(TRIM(chdrnum))
                            WHEN 11 THEN
                                substr(TRIM(chdrnum), 4, 8)
                            ELSE
                                TRIM(chdrnum)
                        END stdchdrnum
                    FROM
                        titdmgmaspol@dmstagedblink
                )
            GROUP BY
                stdchdrnum
        ) ms2 ON ms1.stdchdrnum = ms2.stdchdrnum
    ORDER BY
        CASE length(TRIM(ms1.chdrnum))
            WHEN 11 THEN
                substr(TRIM(ms1.chdrnum), 4, 8)
            ELSE
                TRIM(ms1.chdrnum)
        END,
        TRIM(ms1.ccdate);

    obj_maspol                  maspol_cursor%rowtype;
BEGIN
    pkg_dm_common_operations.getdefval(i_module_name => c_bq9ec, o_defaultvalues => o_defaultvalues);  -- get default values to be populated to IG tables.
    pkg_dm_mastpolicy.getitemvalues(itemvalues => t_itemval);   -- get values from T-table.
    pkg_dm_mastpolicy.getdfpopfvalues(dfpopfvalues => t_dfpopfval);   -- get values from DFPOPF.
    pkg_dm_mastpolicy.geterrordesc(o_errortext => o_errortext);
    pkg_dm_mastpolicy.getclientnumber(clientnumber => t_clntno);
    v_tablenametemp := 'ZDOE'
                       || trim(c_prefix)
                       || lpad(trim(i_schedulenumber), 4, '0');

    v_tablename := trim(v_tablenametemp);
    pkg_dm_common_operations.createzdoepf(i_tablename => v_tablename);
    v_tranid := concat('QPAD', TO_CHAR(SYSDATE, 'YYMMDDHHMM'));
    v_migration_date := TO_CHAR(SYSDATE, 'YYYYMMDD');
    DELETE FROM dmigtitdmgmaspol;

    v_sv_mspol_chdrnum := NULL;

--- MP8 --
    SELECT
        TRIM(busdate)
    INTO v_busdate
    FROM
        busdpf
    WHERE
        TRIM(company) = TRIM(i_company);
--- MP8 --

    OPEN maspol_cursor;
    << skiprecord >> LOOP
        FETCH maspol_cursor INTO obj_maspol;
        EXIT WHEN maspol_cursor%notfound;

    -- Initialize error  variables start
        t_ercode(1) := ' ';
        t_ercode(2) := ' ';
        t_ercode(3) := ' ';
        t_ercode(4) := ' ';
        t_ercode(5) := ' ';
        i_zdoe_info := NULL;
        i_zdoe_info.i_zfilename := 'TITDMGMASPOL';
        i_zdoe_info.i_prefix := c_prefix;
        i_zdoe_info.i_scheduleno := i_schedulenumber;
        i_zdoe_info.i_tablename := v_tablename;
        ---i_zdoe_info.i_refkey := trim(obj_maspol.chdrnum) || ', ' || trim(obj_maspol.ccdate); recidxmpmspol
        i_zdoe_info.i_refkey := obj_maspol.chdrnum;
        v_zfacthus := NULL;
        v_crdatesub1d := NULL;
        v_zpenddtsub1d := NULL;
        v_zpolperd := NULL;
        v_zplancls := NULL;
        v_cownnum := NULL;
        v_zcolmcls := NULL;
        v_zcolmcls_org := NULL;
        v_mspol_chdrnum := NULL;
        v_zwavgflg := NULL;
        v_timech01 := NULL;
        v_timech02 := NULL;
        errorcount := 0;
        v_y := 'Y';
        b_isnoerror := true;
        b_isnoerror_01 := false;
        b_isnoerror_02 := false;
        b_isnoerror_03 := false;
        b_isnoerror_04 := false;
        b_isnoerror_05 := false;
        b_isnoerror_06 := false;
        b_isnoerror_07 := false;
        b_isnoerror_08 := false;
        b_isnoerror_09 := false;
        b_isnoerror_10 := false;
        b_isnoerror_11 := false;
        b_isnoerror_12 := false;
        b_isnoerror_13 := false;
        b_isnoerror_14 := false;
        b_isnoerror_15 := false;
        b_isnoerror_16 := false;
        b_isnoerror_17 := false;
        b_isnoerror_18 := false;
        b_isnoerror_19 := false;
        b_isnoerror_20 := false;
        b_isnoerror_21 := false;
        b_isnoerror_22 := false;
        b_isnoerror_23 := false;
        b_isnoerror_24 := false;
        b_isnoerror_25 := false;
        b_isnoerror_26 := false;
        b_isnoerror_27 := false;
        b_isnoerror_28 := false;
        b_isnoerror_29 := false;
---- MP8 ---
        b_isnoerror_45 := false;
        b_isnoerror_46 := false;
---- MP8 ---

    -- Initialize error  variables end
        b_createpostvalidation := true;
    /******** Validation Check 1 *******/

    ---dbms_output.put_line('[hoge]obj_maspol.chdrnum: ' || obj_maspol.chdrnum);  ----@@@ debug

    -- check #1 --
        IF TRIM(obj_maspol.chdrnum) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'chdrnum';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.chdrnum);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.cnttype) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'cnttype';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.cnttype);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.statcode) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'statcode';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.statcode);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.zagptnum) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'zagptnum';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.zagptnum);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.ccdate) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'ccdate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.ccdate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.crdate) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'crdate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.crdate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.rptfpst) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'rptfpst';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.rptfpst);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.zendcde) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'zendcde';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.zendcde);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.rra2ig) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'rra2ig';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.rra2ig);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.zblnkpol) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'zblnkpol';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.zblnkpol);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ---ELSIF TRIM(obj_maspol.zblnkpol) = c_nozblnkpol AND TRIM(obj_maspol.b8tjig) IS NULL THEN
        ELSIF TRIM(obj_maspol.b8tjig) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'b8tjig';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.b8tjig);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        --- ELSIF TRIM(obj_maspol.b8gpst) IS NULL THEN  ---FT?f?[?^?E�fl?E?��?I???s?A?R???�g?g?A?E?g
        ---     b_isnoerror := false;
        ---     i_zdoe_info.i_indic := 'E';
        ---     i_zdoe_info.i_error01 := c_h366;
        ---     i_zdoe_info.i_errormsg01 := o_errortext(c_h366) || ' [#1]';
        ---     i_zdoe_info.i_errorfield01 := 'b8gpst';
        ---     i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.b8gpst);
        ---     i_zdoe_info.i_errorprogram01 := i_schedulename;
        ---     PKG_DM_COMMON_OPERATIONS.insertintozdoe(i_zdoe_info => i_zdoe_info);
        ---     --GOTO createPostvalidation;;
        ELSIF TRIM(obj_maspol.b8gost) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'b8gost';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.b8gost);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.pndate) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'pndate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.pndate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.occdate) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'occdate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.occdate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.insendte) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'insendte';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.insendte);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        ELSIF TRIM(obj_maspol.zpenddt) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'zpenddt';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.zpenddt);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        ELSIF TRIM(obj_maspol.clntnum) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' [#1]';
            i_zdoe_info.i_errorfield01 := 'clntnum';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.clntnum);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        b_isnoerror_01 := true;
       --- values editing --
        IF length(trim(obj_maspol.chdrnum)) = 11 THEN
            v_mspol_chdrnum := substr(trim(obj_maspol.chdrnum), 4, 8);
        ELSE
            v_mspol_chdrnum := trim(obj_maspol.chdrnum);
        END IF;

       ----DBMS_Output.PUT_LINE('v_mspol_chdrnum : ' || v_mspol_chdrnum || ', obj_maspol.ccdate : ' || obj_maspol.ccdate);  ---@@@test
       --- values editing --
    -- check #1 --

    -- check #2 --

        pkg_dm_mastpolicy.validdateval(i_date => TRIM(obj_maspol.ccdate), results => v_validdateval);

        IF v_validdateval = false THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_rqx4;
            i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                        || ' [#2]';
            i_zdoe_info.i_errorfield01 := 'ccdate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.ccdate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        pkg_dm_mastpolicy.validdateval(i_date => TRIM(obj_maspol.crdate), results => v_validdateval);

        IF v_validdateval = false THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_rqx4;
            i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                        || ' [#2]';
            i_zdoe_info.i_errorfield01 := 'crdate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.crdate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;
        --- get crdate - 1 day ---

        pkg_dm_mastpolicy.shiftdateval(i_dm => 'D', i_date => TO_CHAR(TRIM(obj_maspol.crdate)), i_increment => - 1, o_date => v_crdatesub1d

        );

        IF TRIM(obj_maspol.b8o9nb) IS NOT NULL THEN
        if(length(obj_maspol.b8o9nb) = 6)then
        
        v_i_date := 20;
        elsif(length(obj_maspol.b8o9nb) = 5)THEN
                v_i_date := 200;

                elsif(length(obj_maspol.b8o9nb) = 4)THEN
        v_i_date := 2000;
        elsif(length(obj_maspol.b8o9nb) = 3)THEN
v_i_date := 20000;
else
v_i_date := 200000;

end if;
            pkg_dm_mastpolicy.validdateval(i_date => v_i_date || RTRIM(obj_maspol.b8o9nb), results => v_validdateval);

            IF v_validdateval = false THEN
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_rqx4;
                i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                            || ' [#2]';
                i_zdoe_info.i_errorfield01 := 'b8o9nb';
                i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.b8o9nb);
                i_zdoe_info.i_errorprogram01 := i_schedulename;
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
               --GOTO createPostvalidation;
                GOTO insertzdoe;
            END IF;

        END IF;

        pkg_dm_mastpolicy.validdateval(i_date => TRIM(obj_maspol.effdate), results => v_validdateval);

        IF v_validdateval = false THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_rqx4;
            i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                        || ' [#2]';
            i_zdoe_info.i_errorfield01 := 'effdate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.effdate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        pkg_dm_mastpolicy.validdateval(i_date => TRIM(obj_maspol.pndate), results => v_validdateval);

        IF v_validdateval = false THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_rqx4;
            i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                        || ' [#2]';
            i_zdoe_info.i_errorfield01 := 'pndate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.pndate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        pkg_dm_mastpolicy.validdateval(i_date => TRIM(obj_maspol.occdate), results => v_validdateval);

        IF v_validdateval = false THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_rqx4;
            i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                        || ' [#2]';
            i_zdoe_info.i_errorfield01 := 'occdate';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.occdate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        pkg_dm_mastpolicy.validdateval(i_date => TRIM(obj_maspol.insendte), results => v_validdateval);

        IF v_validdateval = false THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_rqx4;
            i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                        || ' [#2]';
            i_zdoe_info.i_errorfield01 := 'insendte';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.insendte);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        pkg_dm_mastpolicy.validdateval(i_date => TRIM(obj_maspol.zpenddt), results => v_validdateval);

        IF v_validdateval = false THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_rqx4;
            i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                        || ' [#2]';
            i_zdoe_info.i_errorfield01 := 'zpenddt';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.zpenddt);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;
        --- get crdate - 1 day ---

        pkg_dm_mastpolicy.shiftdateval(i_dm => 'D', i_date => TO_CHAR(TRIM(obj_maspol.zpenddt)), i_increment => - 1, o_date => v_zpenddtsub1d

        );

        b_isnoerror_02 := true;
    -- check #2 --

    -- check #8 --


SELECT
           COUNT(*)
        INTO v_gchipf_cnt
        FROM
            gchipf A inner join GChppf B

            on A.chdrnum=b.chdrnum and b.ZPRDCTG='PA'
        WHERE
              A.chdrnum = v_mspol_chdrnum
            AND A.ccdate = obj_maspol.ccdate;
       ---DBMS_Output.PUT_LINE(v_mspol_chdrnum || ', ' || obj_maspol.ccdate);   ---@@@test

        IF v_gchipf_cnt > 0 THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h357;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h357)
                                        || ' [#8]';
            i_zdoe_info.i_errorfield01 := 'chdrnum';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.chdrnum);
            i_zdoe_info.i_errormsg02 := o_errortext(c_h357);
            i_zdoe_info.i_errorfield02 := 'ccdate';
            i_zdoe_info.i_fieldvalue02 := trim(obj_maspol.ccdate);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        b_isnoerror_08 := true;
    -- check #8 --

    -- check #6 --
        SELECT
            *
        BULK COLLECT
        INTO titdmginsstpl_list
        FROM
            titdmginsstpl@dmstagedblink
        WHERE
            TRIM(chdrnum) = v_mspol_chdrnum
        ORDER BY
            plnsetnum;

        IF titdmginsstpl_list.count = 0 THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_e177;
            i_zdoe_info.i_errormsg01 := o_errortext(c_e177)
                                        || ' : '
                                        || 'insstpl'
                                        || ' [#6]';

            i_zdoe_info.i_errorfield01 := 'chdrnum';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.chdrnum);
            i_zdoe_info.i_fieldvalue01 := v_mspol_chdrnum;
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        b_isnoerror_06 := true;
        -- check #6 --

        -- check #7 --
        v_inssetplan_tab.DELETE;
        ix_inssetplan := 0;
        FOR indexitems IN 1..titdmginsstpl_list.count LOOP
            IF TRIM(titdmginsstpl_list(indexitems).plnsetnum) IS NULL THEN
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_h366;
                i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                            || ' : '
                                            || 'insstpl ('
                                            || titdmginsstpl_list(indexitems).recidxmpistp
                                            || ')'
                                            || ' [#7]';

                i_zdoe_info.i_errorfield01 := 'plnsetnum';
                i_zdoe_info.i_fieldvalue01 := trim(titdmginsstpl_list(indexitems).plnsetnum);
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
               --GOTO createPostvalidation;
                GOTO insertzdoe;
            END IF;

            IF TRIM(titdmginsstpl_list(indexitems).zinstype1) IS NULL THEN
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_h366;
                i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                            || ' : '
                                            || 'insstpl ('
                                            || titdmginsstpl_list(indexitems).recidxmpistp
                                            || ')';

                i_zdoe_info.i_errorfield01 := 'zinstype1';
                i_zdoe_info.i_fieldvalue01 := trim(titdmginsstpl_list(indexitems).zinstype1);
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
               --GOTO createPostvalidation;
                GOTO insertzdoe;
            END IF;

            ix_inssetplan := ix_inssetplan + 1;
            ix_instypes := 0;
            v_inssetplan_tab(ix_inssetplan).cmbinssetplan := NULL;
            v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan := NULL;
            v_inssetplan_tab(ix_inssetplan).recidxmpistp := titdmginsstpl_list(indexitems).recidxmpistp;
            v_inssetplan_tab(ix_inssetplan).chdrnum := trim(titdmginsstpl_list(indexitems).chdrnum);
            v_inssetplan_tab(ix_inssetplan).plnsetnum := titdmginsstpl_list(indexitems).plnsetnum;
            ix_instypes := ix_instypes + 1;
            v_inssetplan_tab(ix_inssetplan).zinstype(ix_instypes) := trim(titdmginsstpl_list(indexitems).zinstype1);

            v_inssetplan_tab(ix_inssetplan).cmbinssetplan := v_inssetplan_tab(ix_inssetplan).cmbinssetplan
                                                             || trim(titdmginsstpl_list(indexitems).zinstype1);

            v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan := v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan
                                                                   || trim(titdmginsstpl_list(indexitems).zinstype1);

            IF TRIM(titdmginsstpl_list(indexitems).zinstype2) IS NOT NULL THEN
                ix_instypes := ix_instypes + 1;
                v_inssetplan_tab(ix_inssetplan).zinstype(ix_instypes) := trim(titdmginsstpl_list(indexitems).zinstype2);

                v_inssetplan_tab(ix_inssetplan).cmbinssetplan := v_inssetplan_tab(ix_inssetplan).cmbinssetplan
                                                                 || ','
                                                                 || trim(titdmginsstpl_list(indexitems).zinstype2);

                v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan := v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan
                                                                       || trim(titdmginsstpl_list(indexitems).zinstype2);

            END IF;

            IF TRIM(titdmginsstpl_list(indexitems).zinstype3) IS NOT NULL THEN
                ix_instypes := ix_instypes + 1;
                v_inssetplan_tab(ix_inssetplan).zinstype(ix_instypes) := trim(titdmginsstpl_list(indexitems).zinstype3);

                v_inssetplan_tab(ix_inssetplan).cmbinssetplan := v_inssetplan_tab(ix_inssetplan).cmbinssetplan
                                                                 || ','
                                                                 || trim(titdmginsstpl_list(indexitems).zinstype3);

                v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan := v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan
                                                                       || trim(titdmginsstpl_list(indexitems).zinstype3);

            END IF;

            IF TRIM(titdmginsstpl_list(indexitems).zinstype4) IS NOT NULL THEN
                ix_instypes := ix_instypes + 1;
                v_inssetplan_tab(ix_inssetplan).zinstype(ix_instypes) := trim(titdmginsstpl_list(indexitems).zinstype4);

                v_inssetplan_tab(ix_inssetplan).cmbinssetplan := v_inssetplan_tab(ix_inssetplan).cmbinssetplan
                                                                 || ','
                                                                 || trim(titdmginsstpl_list(indexitems).zinstype4);

                v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan := v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan
                                                                       || trim(titdmginsstpl_list(indexitems).zinstype4);

            END IF;

            pkg_dm_mastpolicy.sortstrings(i_string => v_inssetplan_tab(ix_inssetplan).sortedcmbinssetplan, o_string => v_inssetplan_tab

            (ix_inssetplan).sortedcmbinssetplan);

        END LOOP;

        b_isnoerror_07 := true;
        -- check #7 --

        -- check #11 --
        IF TRIM(obj_maspol.statcode) NOT IN (
            c_sts_xn,
            c_sts_if,
            c_sts_ca,
            c_sts_la
        ) THEN  --- MP8
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_e767;
            i_zdoe_info.i_errormsg01 := o_errortext(c_e767)
                                        || ' [#11]';
            i_zdoe_info.i_errorfield01 := 'statcode';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.statcode);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
---- MP8 -----
        ELSIF TRIM(obj_maspol.statcode) IN (
            c_sts_ca,
            c_sts_la
        ) AND obj_maspol.period_num <> obj_maspol.cnt_policy THEN  --- Not the latest policy with CA, LA error
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_e767;
            i_zdoe_info.i_errormsg01 := o_errortext(c_e767)
                                        || '('
                                        || obj_maspol.statcode
                                        || ') Not latest policy[#11]';

            i_zdoe_info.i_errorfield01 := 'statcode';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.statcode)
                                          || '('
                                          || obj_maspol.period_num
                                          || '/'
                                          || obj_maspol.cnt_policy
                                          || ')';

            i_zdoe_info.i_errorprogram01 := i_schedulename;
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            --GOTO createPostvalidation;
            GOTO insertzdoe;
---- MP8 -----
        END IF;

        b_isnoerror_11 := true;

        -- check #11 --

        -- check #15 --
        BEGIN
            SELECT
                zfacthus
            INTO v_zfacthus
            FROM
                Jd1dta.zendrpf
            WHERE
                TRIM(zendcde) = TRIM(obj_maspol.zendcde)
                AND TRIM(zendcdst) = c_zendcdst
                AND TRIM(zencdsdt) <= TRIM(obj_maspol.effdate)
                AND TRIM(zencdedt) >= TRIM(obj_maspol.effdate)
                AND TRIM(zencdsdt) <= TRIM(obj_maspol.crdate)
                AND TRIM(zencdedt) >= TRIM(obj_maspol.crdate);

        EXCEPTION
            WHEN no_data_found THEN
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_rpmy;
                i_zdoe_info.i_errormsg01 := o_errortext(c_rpmy)
                                            || ' [#15]';
                i_zdoe_info.i_errorfield01 := 'zendcde';
                i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.zendcde);
                i_zdoe_info.i_errorprogram01 := i_schedulename;
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                --GOTO createPostvalidation;
                GOTO insertzdoe;
        END;

        i_key_itemval := trim(c_t3684
                              || trim(v_zfacthus)
                              || c_itemcoy_9);
                 --   IF (t_itemval.exists(TRIM(i_key_itemval))) THEN
        r_itemval := t_itemval(i_key_itemval);

       -- end if;
        v_zcolmcls := r_itemval.itemval1;
        v_zcolmcls_org := r_itemval.itemval1;
        --- MP3
        IF v_zcolmcls = c_zcolmcls_fh AND r_itemval.itemval2 = c_colmethod_db THEN
            v_zcolmcls := c_zcolmcls_cd;
        END IF;

        b_isnoerror_15 := true;
        -- check #15 --

        -- check #4 --
        IF v_zcolmcls = c_zcolmcls_fh AND trim(obj_maspol.rptfpst) = c_rptfpst_paid THEN
            IF TRIM(obj_maspol.zccde) IS NULL THEN
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_h366;
                i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                            || ' [#4]';
                i_zdoe_info.i_errorfield01 := 'zccde';
                i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.zccde);
                i_zdoe_info.i_errorprogram01 := i_schedulename;
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
               --GOTO createPostvalidation;
                GOTO insertzdoe;
            ELSIF TRIM(obj_maspol.zconsgnm) IS NULL THEN
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_h366;
                i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                            || ' [#4]';
                i_zdoe_info.i_errorfield01 := 'zconsgnm';
                i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.zconsgnm);
                i_zdoe_info.i_errorprogram01 := i_schedulename;
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
               --GOTO createPostvalidation;
                GOTO insertzdoe;
            END IF;
        END IF;

        b_isnoerror_04 := true;
        -- check #4 --

        -- check #5 --
        IF v_zcolmcls = c_zcolmcls_cd THEN
            SELECT
                *
            BULK COLLECT
            INTO titdmgendctpf_list
            FROM
                titdmgendctpf@dmstagedblink
            WHERE
                TRIM(chdrnum) = v_mspol_chdrnum
            ORDER BY
                recidxmpgctpf;

            IF titdmgendctpf_list.count = 0 THEN
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_e177;
                i_zdoe_info.i_errormsg01 := o_errortext(c_e177)
                                            || ' : '
                                            || ' titdmgendctpf'
                                            || ' [#5]';

                i_zdoe_info.i_errorfield01 := 'chdrnum';
                i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.chdrnum);
                i_zdoe_info.i_errorprogram01 := i_schedulename;
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
              --GOTO createPostvalidation;
                GOTO insertzdoe;
            END IF;

            FOR indexitems IN 1..titdmgendctpf_list.count LOOP
                IF TRIM(titdmgendctpf_list(indexitems).zcrdtype) IS NULL THEN
                    b_isnoerror := false;
                    i_zdoe_info.i_indic := 'E';
                    i_zdoe_info.i_error01 := c_h366;
                    i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                                || ' : '
                                                || 'endctpf ('
                                                || titdmgendctpf_list(indexitems).recidxmpgctpf
                                                || ')'
                                                || ' [#5]';

                    i_zdoe_info.i_errorfield01 := 'zcrdtype';
                    i_zdoe_info.i_fieldvalue01 := trim(titdmgendctpf_list(indexitems).zcrdtype);
                    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                 --GOTO createPostvalidation;
                    GOTO insertzdoe;
                END IF;

                IF TRIM(titdmgendctpf_list(indexitems).zcarddc) IS NULL THEN
                    b_isnoerror := false;
                    i_zdoe_info.i_indic := 'E';
                    i_zdoe_info.i_error01 := c_h366;
                    i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                                || ' : '
                                                || 'endctpf ('
                                                || titdmgendctpf_list(indexitems).recidxmpgctpf
                                                || ')'
                                                || ' [#5]';

                    i_zdoe_info.i_errorfield01 := 'zcarddc';
                    i_zdoe_info.i_fieldvalue01 := trim(titdmgendctpf_list(indexitems).zcarddc);
                    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                 --GOTO createPostvalidation;
                    GOTO insertzdoe;
                END IF;

                IF TRIM(titdmgendctpf_list(indexitems).zcnbrfrm) IS NULL THEN
                    b_isnoerror := false;
                    i_zdoe_info.i_indic := 'E';
                    i_zdoe_info.i_error01 := c_h366;
                    i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                                || ' : '
                                                || 'endctpf ('
                                                || titdmgendctpf_list(indexitems).recidxmpgctpf
                                                || ')'
                                                || ' [#5]';

                    i_zdoe_info.i_errorfield01 := 'zcnbrfrm';
                    i_zdoe_info.i_fieldvalue01 := trim(titdmgendctpf_list(indexitems).zcnbrfrm);
                    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                 --GOTO createPostvalidation;
                    GOTO insertzdoe;
                END IF;

                IF TRIM(titdmgendctpf_list(indexitems).zcnbrto) IS NULL THEN
                    b_isnoerror := false;
                    i_zdoe_info.i_indic := 'E';
                    i_zdoe_info.i_error01 := c_h366;
                    i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                                || ' : '
                                                || 'endctpf ('
                                                || titdmgendctpf_list(indexitems).recidxmpgctpf
                                                || ')'
                                                || ' [#5]';

                    i_zdoe_info.i_errorfield01 := 'zcnbrto';
                    i_zdoe_info.i_fieldvalue01 := trim(titdmgendctpf_list(indexitems).zcnbrto);
                    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                 --GOTO createPostvalidation;
                    GOTO insertzdoe;
                END IF;

                IF TRIM(titdmgendctpf_list(indexitems).zmstid) IS NULL THEN
                    b_isnoerror := false;
                    i_zdoe_info.i_indic := 'E';
                    i_zdoe_info.i_error01 := c_h366;
                    i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                                || ' : '
                                                || 'endctpf ('
                                                || titdmgendctpf_list(indexitems).recidxmpgctpf
                                                || ')'
                                                || ' [#5]';

                    i_zdoe_info.i_errorfield01 := 'zmstid';
                    i_zdoe_info.i_fieldvalue01 := trim(titdmgendctpf_list(indexitems).zmstid);
                    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                 --GOTO createPostvalidation;
                    GOTO insertzdoe;
                END IF;

                IF TRIM(titdmgendctpf_list(indexitems).zmstsnme) IS NULL THEN
                    b_isnoerror := false;
                    i_zdoe_info.i_indic := 'E';
                    i_zdoe_info.i_error01 := c_h366;
                    i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                                || ' : '
                                                || 'endctpf ('
                                                || titdmgendctpf_list(indexitems).recidxmpgctpf
                                                || ')'
                                                || ' [#5]';

                    i_zdoe_info.i_errorfield01 := 'zmstsnme';
                    i_zdoe_info.i_fieldvalue01 := trim(titdmgendctpf_list(indexitems).zmstsnme);
                    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                 --GOTO createPostvalidation;
                    GOTO insertzdoe;
                END IF;

                IF TRIM(titdmgendctpf_list(indexitems).zmstidv) IS NULL THEN
                    b_isnoerror := false;
                    i_zdoe_info.i_indic := 'E';
                    i_zdoe_info.i_error01 := c_h366;
                    i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                                || ' : '
                                                || 'endctpf ('
                                                || titdmgendctpf_list(indexitems).recidxmpgctpf
                                                || ')'
                                                || ' [#5]';

                    i_zdoe_info.i_errorfield01 := 'zmstidv';
                    i_zdoe_info.i_fieldvalue01 := trim(titdmgendctpf_list(indexitems).zmstidv);
                    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                 --GOTO createPostvalidation;
                    GOTO insertzdoe;
                END IF;

                IF TRIM(titdmgendctpf_list(indexitems).zmstsnmev) IS NULL THEN
                    b_isnoerror := false;
                    i_zdoe_info.i_indic := 'E';
                    i_zdoe_info.i_error01 := c_h366;
                    i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                                || ' : '
                                                || 'endctpf ('
                                                || titdmgendctpf_list(indexitems).recidxmpgctpf
                                                || ')'
                                                || ' [#5]';

                    i_zdoe_info.i_errorfield01 := 'zmstsnmev';
                    i_zdoe_info.i_fieldvalue01 := trim(titdmgendctpf_list(indexitems).zmstsnmev);
                    pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                 --GOTO createPostvalidation;
                    GOTO insertzdoe;
                END IF;

            END LOOP;

        END IF;

        b_isnoerror_05 := true;
        -- check #5 --

        -- check #3 --
        --- MP8 ---
        IF TRIM(obj_maspol.canceldt) IS NOT NULL THEN
            pkg_dm_mastpolicy.validdateval(i_date => TRIM(obj_maspol.canceldt), results => v_validdateval);

            IF v_validdateval = false THEN
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_rqx4;
                i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                            || ' (invalid value)'
                                            || ' [#3]';
                i_zdoe_info.i_errorfield01 := 'canceldt';
                i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.canceldt);
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
              --GOTO createPostvalidation;
                GOTO insertzdoe;
            END IF;

            IF obj_maspol.period_num <> obj_maspol.cnt_policy THEN  --- not the latest policy error
                b_isnoerror := false;
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_rqx4;
                i_zdoe_info.i_errormsg01 := o_errortext(c_rqx4)
                                            || ' (not the latest policy)'
                                            || ' [#3]';
                i_zdoe_info.i_errorfield01 := 'canceldt';
                i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.canceldt);
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
              --GOTO createPostvalidation;
                GOTO insertzdoe;
            END IF;

        ELSIF trim(obj_maspol.statcode) = c_sts_ca THEN --- TRIM(obj_maspol.canceldt) IS NULL
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h366;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h366)
                                        || ' (empty for CA)'
                                        || ' [#3]';
            i_zdoe_info.i_errorfield01 := 'canceldt';
            i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.canceldt);
            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
              --GOTO createPostvalidation;
            GOTO insertzdoe;
        END IF;

        b_isnoerror_03 := true;
        --- MP8 ---
        -- check #3 --
        b_createpostvalidation := false;

    /******** Validation Check 1 *******/

    /******** Validation Check 2 *******/
    -- check #28 --
        b_isnoerror_28 := true;
        pkg_dm_mastpolicy.calcmonths(i_fmdate => TO_CHAR(TRIM(obj_maspol.ccdate)), i_todate => TO_CHAR(v_crdatesub1d), o_month =>
        v_zpolperd);

        IF v_zpolperd < 1 THEN
            b_isnoerror := false;
            b_isnoerror_28 := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_rfq9;
            t_errorfield(errorcount) := 'zpolperd';
            t_errormsg(errorcount) := o_errortext(c_rfq9)
                                      || '('
                                      || obj_maspol.ccdate
                                      || ' - '
                                      || obj_maspol.crdate
                                      || ')'
                                      || ' [#28]';

            t_errorfieldval(errorcount) := v_zpolperd;
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- check #28 --

    -- check #14 --

        b_isnoerror_14 := true;
        IF trim(obj_maspol.rptfpst) = c_rptfpst_free THEN
            v_zplancls := c_zplancls_free;
        ELSIF trim(obj_maspol.rptfpst) = c_rptfpst_paid THEN
            v_zplancls := c_zplancls_paid;
        ELSE
            b_isnoerror := false;
            b_isnoerror_14 := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_f596;
            t_errorfield(errorcount) := 'rptfpst';
            t_errormsg(errorcount) := o_errortext(c_f596)
                                      || ' [#14]';
            t_errorfieldval(errorcount) := trim(obj_maspol.rptfpst);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- check #14 --

    -- check #24 --

        b_isnoerror_24 := true;
        IF trim(obj_maspol.zblnkpol) <> c_zblnkpol AND trim(obj_maspol.zblnkpol) <> c_nozblnkpol THEN
            b_isnoerror := false;
            b_isnoerror_24 := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_e315;
            t_errorfield(errorcount) := 'zblnkpol';
            t_errormsg(errorcount) := o_errortext(c_e315)
                                      || ' [#24]';
            t_errorfieldval(errorcount) := trim(obj_maspol.zblnkpol);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- check #24 --

    -- check #29 --

        b_isnoerror_29 := true;
        IF trim(obj_maspol.b8gost) = c_weightedaverage THEN
            v_zwavgflg := c_zwavg;
        ELSIF trim(obj_maspol.b8gost) = c_nonweightedaverage THEN
            v_zwavgflg := c_nonzwavg;
        ELSE
            b_isnoerror := false;
            b_isnoerror_29 := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_e999;
            t_errorfield(errorcount) := 'b8gost';
            t_errormsg(errorcount) := o_errortext(c_e999)
                                      || ' [#29]';
            t_errorfieldval(errorcount) := trim(obj_maspol.b8gost);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- check #29 --

    -- check #9 --

        b_isnoerror_09 := true;
        i_key_itemval := c_t9799
                         || trim(obj_maspol.cnttype)
                         || i_company;
        IF t_itemval.EXISTS(i_key_itemval) THEN
            r_itemval := t_itemval(i_key_itemval);
            IF obj_maspol.effdate >= r_itemval.itmfrm AND obj_maspol.effdate <= r_itemval.itmto THEN
                i_key_itemval := c_tq9gx
                                 || trim(obj_maspol.cnttype)
                                 || c_nbtrncd
                                 || i_company;

                IF t_itemval.EXISTS(i_key_itemval) THEN
                    r_itemval := t_itemval(i_key_itemval);
                    v_timech01 := r_itemval.itemval1;
                    v_timech02 := r_itemval.itemval2;
                ELSE
                    b_isnoerror := false;
                    b_isnoerror_09 := false;
                    errorcount := errorcount + 1;
                    t_ercode(errorcount) := c_rptj;
                    t_errorfield(errorcount) := 'cnttype';
                    t_errormsg(errorcount) := o_errortext(c_rptj)
                                              || ' [#9]';
                    t_errorfieldval(errorcount) := trim(obj_maspol.cnttype);
                    t_errorprogram(errorcount) := i_schedulename;
                    IF errorcount >= 5 THEN
                        GOTO insertzdoe;
                    END IF;
                END IF;

            ELSE
                b_isnoerror := false;
                b_isnoerror_09 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_w219;
                t_errorfield(errorcount) := 'cnttype';
                t_errormsg(errorcount) := o_errortext(c_w219)
                                          || ' [#9]';
                t_errorfieldval(errorcount) := trim(obj_maspol.cnttype);
                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;

        ELSE
            b_isnoerror := false;
            b_isnoerror_09 := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_rg11;
            t_errorfield(errorcount) := 'cnttype';
            t_errormsg(errorcount) := o_errortext(c_rg11)
                                      || ' [#9]';
            t_errorfieldval(errorcount) := trim(obj_maspol.cnttype);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- check #9 --

    -- check #10 --

        IF b_isnoerror_14 = true AND b_isnoerror_09 = true THEN
            b_isnoerror_10 := true;
            i_key_itemval := c_tq9fk
                             || trim(obj_maspol.cnttype)
                             || trim(v_zplancls)
                             || trim(i_company);

            IF NOT t_itemval.EXISTS(i_key_itemval) THEN
                b_isnoerror := false;
                b_isnoerror_10 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_rr99;
                t_errorfield(errorcount) := 'cnttype';
                t_errormsg(errorcount) := o_errortext(c_rr99)
                                          || ' (cnttype, zplancls)'
                                          || ' [#10]';
                t_errorfieldval(errorcount) := trim(obj_maspol.cnttype)
                                               || ','
                                               || trim(v_zplancls);

                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            ELSE
          --- get template ---
                r_itemval := t_itemval(i_key_itemval);
                v_template := r_itemval.itemval3;
          --DBMS_Output.PUT_LINE('**** v_template:' || v_template);   ----@@@@test
            IF NOT t_dfpopfval.EXISTS(trim(v_template)
                                      || trim(o_defaultvalues('CHDRCOY'))) THEN


                        b_isnoerror := false;
                b_isnoerror_10 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_rr99;
                t_errorfield(errorcount) := 'DPFO';
                t_errormsg(errorcount) := 'template not avlb';
                t_errorfieldval(errorcount) := v_template;
                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;               
            END IF;
            end if;

        ELSE
            b_isnoerror_10 := false;
        END IF;

    -- check #10 --

    -- check #27 --

        b_isnoerror_27 := true;
        IF t_clntno.EXISTS(trim(obj_maspol.clntnum)) THEN
            v_cownnum := t_clntno(trim(obj_maspol.clntnum)).zigvalue;
        ELSE
            b_isnoerror := false;
            b_isnoerror_27 := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_rgig;
            t_errorfield(errorcount) := 'clntnum';
            t_errormsg(errorcount) := o_errortext(c_rgig)
                                      || ' [#27]';
            t_errorfieldval(errorcount) := trim(obj_maspol.clntnum);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- check #27 --

    -- check #16 --

        b_isnoerror_16 := true;
        IF trim(obj_maspol.zblnkpol) = c_nozblnkpol THEN
            i_key_itemval := c_tq9e4
                             || trim(obj_maspol.b8tjig)
                             || i_company;
            IF NOT t_itemval.EXISTS(i_key_itemval) THEN
                b_isnoerror := false;
                b_isnoerror_16 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_rqm9;
                t_errorfield(errorcount) := 'b8tjig';
                t_errormsg(errorcount) := o_errortext(c_rqm9)
                                          || ' [#16]';
                t_errorfieldval(errorcount) := trim(obj_maspol.b8tjig);
                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;

        END IF;
    -- check #16 --

    -- check #25 --

        b_isnoerror_25 := true;
        IF ( TRIM(obj_maspol.b8o9nb) IS NULL AND TRIM(obj_maspol.znbaltpr) IS NULL ) OR ( TRIM(obj_maspol.b8o9nb) IS NOT NULL AND
        TRIM(obj_maspol.znbaltpr) IS NOT NULL ) OR ( TRIM(obj_maspol.b8o9nb) IS NOT NULL AND TRIM(obj_maspol.znbaltpr) IS NULL ) THEN
            IF TRIM(obj_maspol.b8o9nb) IS NOT NULL AND TRIM(obj_maspol.znbaltpr) IS NOT NULL THEN
                i_key_itemval := c_tw966
                                 || trim(obj_maspol.znbaltpr)
                                 || i_company;
                IF NOT t_itemval.EXISTS(i_key_itemval) THEN
                    b_isnoerror := false;
                    b_isnoerror_25 := false;
                    errorcount := errorcount + 1;
                    t_ercode(errorcount) := c_w266;
                    t_errorfield(errorcount) := 'znbaltpr';
                    t_errormsg(errorcount) := o_errortext(c_w266)
                                              || ' [#25]';
                    t_errorfieldval(errorcount) := trim(obj_maspol.znbaltpr);
                    t_errorprogram(errorcount) := i_schedulename;
                    IF errorcount >= 5 THEN
                        GOTO insertzdoe;
                    END IF;
                END IF;

            END IF;
        ELSE
            b_isnoerror := false;
            b_isnoerror_25 := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_e725;
            t_errorfield(errorcount) := 'znbaltpr';
            t_errormsg(errorcount) := o_errortext(c_e725)
                                      || ' (znbaltpr,b8o9nb)'
                                      || ' [#25]';
            t_errorfieldval(errorcount) := trim(obj_maspol.znbaltpr)
                                           || ','
                                           || trim(obj_maspol.b8o9nb);

            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- check #25 --

    -- check #13 --

        b_isnoerror_13 := true;
        BEGIN
            SELECT
                t2.agtype,
                t2.agntnum
            INTO
                v_agtype,
                v_agntnum
            FROM
                zagppf   t1
                INNER JOIN agntpf   t2 ON TRIM(t1.gagntsel01) = TRIM(t2.agntnum)
            WHERE
                TRIM(t1.zagptpfx) = c_zagptpfx
                AND TRIM(t1.zagptcoy) = TRIM(i_company)
                AND TRIM(t1.provstat) = c_zagpt_aprv
                AND TRIM(t1.validflag) = '1'
                AND TRIM(t1.zagptnum) = TRIM(obj_maspol.zagptnum)
                AND TRIM(t1.effdate) <= TRIM(obj_maspol.effdate)
                AND TRIM(t2.agntpfx) = c_agntpfx
                AND TRIM(t2.validflag) = '1'
                AND TRIM(t2.agntcoy) = TRIM(i_company);

        EXCEPTION
            WHEN no_data_found THEN
                b_isnoerror := false;
                b_isnoerror_13 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_rfzw;
                t_errorfield(errorcount) := 'zagptnum';
                t_errormsg(errorcount) := o_errortext(c_rfzw)
                                          || ' (zagptnum,effdate)'
                                          || ' [#13]';
                t_errorfieldval(errorcount) := trim(obj_maspol.zagptnum)
                                               || ','
                                               || trim(obj_maspol.effdate);

                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
        END;
    -- check #13 --

---- MP8 ---
     -- check #45 --

        b_isnoerror_45 := true;
        IF trim(obj_maspol.rptfpst) = c_rptfpst_free THEN
            IF obj_maspol.cnt_policy > 1 THEN
                b_isnoerror := false;
                b_isnoerror_45 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_d041;
                t_errorfield(errorcount) := 'rptfpst';
                t_errormsg(errorcount) := o_errortext(c_d041)
                                          || ' [#45]';
                t_errorfieldval(errorcount) := obj_maspol.chdrnum
                                               || ' ('
                                               || obj_maspol.cnt_policy
                                               || ')';

                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
        END IF;
     -- check #45 --

     -- check #46 --

        b_isnoerror_46 := true;
        IF b_isnoerror_14 = true THEN
            pkg_dm_mastpolicy.getrenewal(i_zplancls => v_zplancls, i_zblnkpol => TRIM(obj_maspol.zblnkpol), i_b8gpst => TRIM(obj_maspol
            .b8gpst), i_b8o9nb => TRIM(obj_maspol.b8o9nb), i_company => i_company, o_zrnwabl => v_zrnwabl);

            IF v_zrnwabl = 'N' AND obj_maspol.cnt_policy > 1 AND trim(obj_maspol.ccdate) > v_busdate THEN  -- non renewable and future dataed renewal poicy
                b_isnoerror := false;
                b_isnoerror_46 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_g532;
                t_errorfield(errorcount) := 'ccdate';
                t_errormsg(errorcount) := o_errortext(c_g532)
                                          || ' [#46]';
                t_errorfieldval(errorcount) := obj_maspol.crdate
                                               || ' ('
                                               || obj_maspol.cnt_policy
                                               || ')';

                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;

        END IF;

     -- check #46 --

---- MP8 ---

        IF v_zcolmcls = c_zcolmcls_fh THEN
            GOTO fact_house;
        ELSE
            GOTO credit_cd;
        END IF;
        << fact_house >>
    -- check #21 --
         b_isnoerror_21 := true;
        pkg_dm_mastpolicy.chkallhalfsizechar(i_charactors => obj_maspol.zconsgnm, results => v_chkallhalfsizechar);
        IF v_chkallhalfsizechar = false THEN
            b_isnoerror := false;
            b_isnoerror_21 := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_rqsq;
            t_errorfield(errorcount) := 'zconsgnm';
            t_errormsg(errorcount) := o_errortext(c_rqsq)
                                      || ' [#21]';
            t_errorfieldval(errorcount) := trim(obj_maspol.zconsgnm);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- check #21 --

        GOTO insertzdoe;
        << credit_cd >>

    -- check #17, #23, #18, #19 --
         FOR indexitems IN 1..titdmgendctpf_list.count LOOP
            b_isnoerror_17 := true;
            b_isnoerror_23 := true;
            b_isnoerror_18 := true;
            b_isnoerror_19 := true;
            i_key_itemval := c_tq9e6
                             || trim(titdmgendctpf_list(indexitems).zcrdtype)
                             || i_company;
        -- check #17 --

            IF NOT t_itemval.EXISTS(i_key_itemval) THEN
                b_isnoerror := false;
                b_isnoerror_17 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_rqwl;
                t_errorfield(errorcount) := 'zcrdtype';
                t_errormsg(errorcount) := o_errortext(c_rqwl)
                                          || ' : '
                                          || 'endctpf ('
                                          || titdmgendctpf_list(indexitems).recidxmpgctpf
                                          || ')'
                                          || ' [#17]';

                t_errorfieldval(errorcount) := trim(titdmgendctpf_list(indexitems).zcrdtype);
                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
        -- check #17 --
        -- check #23 --

            IF titdmgendctpf_list(indexitems).zcarddc <= 0 THEN
                b_isnoerror := false;
                b_isnoerror_23 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_ev02;
                t_errorfield(errorcount) := 'zcarddc';
                t_errormsg(errorcount) := o_errortext(c_ev02)
                                          || ' : '
                                          || 'endctpf ('
                                          || titdmgendctpf_list(indexitems).recidxmpgctpf
                                          || ')'
                                          || ' [#23]';

                t_errorfieldval(errorcount) := trim(titdmgendctpf_list(indexitems).zcarddc);
                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
        -- check #23 --

            IF b_isnoerror_23 = true THEN
           -- check #18 --
                IF titdmgendctpf_list(indexitems).zcarddc <> length(trim(titdmgendctpf_list(indexitems).zcnbrfrm)) THEN
                    b_isnoerror := false;
                    b_isnoerror_18 := false;
                    errorcount := errorcount + 1;
                    t_ercode(errorcount) := c_rqya;
                    t_errorfield(errorcount) := 'zcnbrfrm';
                    t_errormsg(errorcount) := o_errortext(c_rqya)
                                              || ' : '
                                              || 'endctpf ('
                                              || titdmgendctpf_list(indexitems).recidxmpgctpf
                                              || ')'
                                              || ' [#18]';

                    t_errorfieldval(errorcount) := trim(titdmgendctpf_list(indexitems).zcnbrfrm)
                                                   || ' (zcarddc:'
                                                   || titdmgendctpf_list(indexitems).zcarddc
                                                   || ')';

                    t_errorprogram(errorcount) := i_schedulename;
                    IF errorcount >= 5 THEN
                        GOTO insertzdoe;
                    END IF;
                END IF;
           -- check #18 --
           -- check #19 --

                IF titdmgendctpf_list(indexitems).zcarddc <> length(trim(titdmgendctpf_list(indexitems).zcnbrto)) THEN
                    b_isnoerror := false;
                    b_isnoerror_19 := false;
                    errorcount := errorcount + 1;
                    t_ercode(errorcount) := c_rqya;
                    t_errorfield(errorcount) := 'zcnbrto';
                    t_errormsg(errorcount) := o_errortext(c_rqya)
                                              || ' : '
                                              || 'endctpf ('
                                              || titdmgendctpf_list(indexitems).recidxmpgctpf
                                              || ')'
                                              || ' [#19]';

                    t_errorfieldval(errorcount) := trim(titdmgendctpf_list(indexitems).zcnbrto)
                                                   || ' (zcarddc:'
                                                   || titdmgendctpf_list(indexitems).zcarddc
                                                   || ')';

                    t_errorprogram(errorcount) := i_schedulename;
                    IF errorcount >= 5 THEN
                        GOTO insertzdoe;
                    END IF;
                END IF;
           -- check #19 --

            END IF;
    -- check #17, #23, #18, #19 --

        -- check #20 --

            b_isnoerror_20 := true;
            pkg_dm_mastpolicy.chkallhalfsizechar(i_charactors => titdmgendctpf_list(indexitems).zmstsnme, results => v_chkallhalfsizechar
            );

            IF v_chkallhalfsizechar = false THEN
                b_isnoerror := false;
                b_isnoerror_20 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_rqsq;
                t_errorfield(errorcount) := 'zmstsnme';
                t_errormsg(errorcount) := o_errortext(c_rqsq)
                                          || ' : '
                                          || 'endctpf ('
                                          || titdmgendctpf_list(indexitems).recidxmpgctpf
                                          || ')'
                                          || ' [#20]';

                t_errorfieldval(errorcount) := titdmgendctpf_list(indexitems).zmstsnme;
                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
        -- check #20 --
        -- check #22 --

            b_isnoerror_22 := true;
            pkg_dm_mastpolicy.chkallhalfsizechar(i_charactors => titdmgendctpf_list(indexitems).zmstsnmev, results => v_chkallhalfsizechar
            );

            IF v_chkallhalfsizechar = false THEN
                b_isnoerror := false;
                b_isnoerror_22 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_rqsq;
                t_errorfield(errorcount) := 'zmstsnmev';
                t_errormsg(errorcount) := o_errortext(c_rqsq)
                                          || ' : '
                                          || 'endctpf ('
                                          || titdmgendctpf_list(indexitems).recidxmpgctpf
                                          || ')'
                                          || ' [#22]';

                t_errorfieldval(errorcount) := titdmgendctpf_list(indexitems).zmstsnmev;
                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
        -- check #22 --

        END LOOP;

    -- check #26 --

        b_isnoerror_26 := true;
        FOR indexsetplan1 IN 1..v_inssetplan_tab.count LOOP
            FOR indexinstypes1 IN 1..v_inssetplan_tab(indexsetplan1).zinstype.count LOOP

             -- Must be in TQ9B6 (RRYM)
             -- MP2
                i_key_itemval := c_tq9b6
                                 || trim(v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1))
                                 || trim(i_company);

                IF NOT t_itemval.EXISTS(i_key_itemval) THEN
                    b_isnoerror := false;
                    b_isnoerror_26 := false;
                    errorcount := errorcount + 1;
                    t_ercode(errorcount) := c_rrym;
                    t_errorfield(errorcount) := 'zinstype';
                    t_errormsg(errorcount) := o_errortext(c_rrym)
                                              || ' : '
                                              || 'insstpl ('
                                              || v_inssetplan_tab(indexsetplan1).recidxmpistp
                                              || ')'
                                              || ' [#26]';

                    t_errorfieldval(errorcount) := v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1);
                    t_errorprogram(errorcount) := i_schedulename;
                    IF errorcount >= 5 THEN
                        GOTO insertzdoe;
                    END IF;
                END IF;
             -- Must be in TQ9B6

             -- SHI can not coexists with other insurence type (E456)

                IF v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1) = 'SHI' AND v_inssetplan_tab(indexsetplan1).zinstype

                .count > 1 THEN
                    b_isnoerror := false;
                    b_isnoerror_26 := false;
                    errorcount := errorcount + 1;
                    t_ercode(errorcount) := c_e456;
                    t_errorfield(errorcount) := 'zinstype';
                    t_errormsg(errorcount) := o_errortext(c_e456)
                                              || ' : '
                                              || 'insstpl ('
                                              || v_inssetplan_tab(indexsetplan1).recidxmpistp
                                              || ')'
                                              || ' [#26]';

                    t_errorfieldval(errorcount) := v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1);
                    t_errorprogram(errorcount) := i_schedulename;
                    IF errorcount >= 5 THEN
                        GOTO insertzdoe;
                    END IF;
                END IF;
             -- SHI can not coexists with other insurence type

             -- duplicate insurance type check in one silgle insurence set (E048)---

                FOR indexinstypes2 IN indexinstypes1 + 1..v_inssetplan_tab(indexsetplan1).zinstype.count LOOP IF v_inssetplan_tab

                (indexsetplan1).zinstype(indexinstypes1) = v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes2) THEN -- duplicated
                    b_isnoerror := false;
                    b_isnoerror_26 := false;
                    errorcount := errorcount + 1;
                    t_ercode(errorcount) := c_e048;
                    t_errorfield(errorcount) := 'zinstype';
                    t_errormsg(errorcount) := o_errortext(c_e048)
                                              || ' : '
                                              || 'insstpl ('
                                              || v_inssetplan_tab(indexsetplan1).recidxmpistp
                                              || ')'
                                              || ' [#26]';

                    t_errorfieldval(errorcount) := v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1);
                    t_errorprogram(errorcount) := i_schedulename;
                    IF errorcount >= 5 THEN
                        GOTO insertzdoe;
                    END IF;
                END IF;
                END LOOP;
             -- duplicate insurance type check in one silgle insurence set---

            END LOOP;

        -- duplicate insurance set check with other insurence set (E048)---

            FOR indexsetplan2 IN indexsetplan1 + 1..v_inssetplan_tab.count LOOP IF v_inssetplan_tab(indexsetplan1).sortedcmbinssetplan

            = v_inssetplan_tab(indexsetplan2).sortedcmbinssetplan THEN
                b_isnoerror := false;
                b_isnoerror_26 := false;
                errorcount := errorcount + 1;
                t_ercode(errorcount) := c_e048;
                t_errorfield(errorcount) := 'zinstype';
                t_errormsg(errorcount) := o_errortext(c_e048)
                                          || ' : '
                                          || 'insstpl ('
                                          || v_inssetplan_tab(indexsetplan1).recidxmpistp
                                          || ','
                                          || v_inssetplan_tab(indexsetplan2).recidxmpistp
                                          || ')'
                                          || ' [#26]';

                t_errorfieldval(errorcount) := v_inssetplan_tab(indexsetplan1).cmbinssetplan;
                t_errorprogram(errorcount) := i_schedulename;
                IF errorcount >= 5 THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
            END LOOP;
        -- duplicate insurance set check with other insurence set---

        END LOOP;
     -- check #26 --

        GOTO insertzdoe;

    /***** Validation Check 2 *******/
        << insertzdoe >>

    -- Determination of Policy Number break
         IF TRIM(obj_maspol.chdrnum) IS NOT NULL THEN
            IF v_sv_mspol_chdrnum IS NULL THEN
                i_chdrnum_break := true;
                v_sv_mspol_chdrnum := v_mspol_chdrnum;
                v_cnt_policy := 1;
            ELSIF v_mspol_chdrnum = v_sv_mspol_chdrnum THEN
                i_chdrnum_break := false;
                v_cnt_policy := v_cnt_policy + 1;
            ELSE
                i_chdrnum_break := true;
                v_sv_mspol_chdrnum := v_mspol_chdrnum;
                v_cnt_policy := 1;
            END IF;
        ELSE
            i_chdrnum_break := true;
            v_sv_mspol_chdrnum := v_mspol_chdrnum;
            v_cnt_policy := 1;
        END IF;

    -- If one of the same Policy Number records is an error, the following same Policy Number records must be an error.

        IF i_chdrnum_break = true THEN
            b_chdrnum_isnoerror := true;
        END IF;
        IF b_isnoerror = false THEN
            b_chdrnum_isnoerror := false;
        END IF;
        IF b_createpostvalidation = true THEN -- IF jumped from serious error GOTO createPostvalidation
            GOTO createpostvalidation;
        END IF;

    -- if the current record is an error, an error log will be outputted
        IF ( b_isnoerror = false ) THEN
            IF TRIM(t_ercode(1)) IS NOT NULL THEN
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := t_ercode(1);
                i_zdoe_info.i_errormsg01 := t_errormsg(1);
                i_zdoe_info.i_errorfield01 := t_errorfield(1);
                i_zdoe_info.i_fieldvalue01 := t_errorfieldval(1);
                i_zdoe_info.i_errorprogram01 := t_errorprogram(1);
            END IF;

            IF TRIM(t_ercode(2)) IS NOT NULL THEN
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error02 := t_ercode(2);
                i_zdoe_info.i_errormsg02 := t_errormsg(2);
                i_zdoe_info.i_errorfield02 := t_errorfield(2);
                i_zdoe_info.i_fieldvalue02 := t_errorfieldval(2);
                i_zdoe_info.i_errorprogram02 := t_errorprogram(2);
            END IF;

            IF TRIM(t_ercode(3)) IS NOT NULL THEN
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error03 := t_ercode(3);
                i_zdoe_info.i_errormsg03 := t_errormsg(3);
                i_zdoe_info.i_errorfield03 := t_errorfield(3);
                i_zdoe_info.i_fieldvalue03 := t_errorfieldval(3);
                i_zdoe_info.i_errorprogram03 := t_errorprogram(3);
            END IF;

            IF TRIM(t_ercode(4)) IS NOT NULL THEN
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error04 := t_ercode(4);
                i_zdoe_info.i_errormsg04 := t_errormsg(4);
                i_zdoe_info.i_errorfield04 := t_errorfield(4);
                i_zdoe_info.i_fieldvalue04 := t_errorfieldval(4);
                i_zdoe_info.i_errorprogram04 := t_errorprogram(4);
            END IF;

            IF TRIM(t_ercode(5)) IS NOT NULL THEN
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error05 := t_ercode(5);
                i_zdoe_info.i_errormsg05 := t_errormsg(5);
                i_zdoe_info.i_errorfield05 := t_errorfield(5);
                i_zdoe_info.i_fieldvalue05 := t_errorfieldval(5);
                i_zdoe_info.i_errorprogram05 := t_errorprogram(5);
            END IF;

            pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
        ELSE
       --#47
            IF b_chdrnum_isnoerror = false THEN  --- if the current record is not error, but the same preceding Policy Number records are already error
                i_zdoe_info.i_indic := 'E';
                i_zdoe_info.i_error01 := c_rfaa;
                i_zdoe_info.i_errormsg01 := o_errortext(c_rfaa)
                                            || ' The same preceding Policy Number records are already error [#47]';
                i_zdoe_info.i_errorfield01 := 'chdrnum';
                i_zdoe_info.i_fieldvalue01 := trim(obj_maspol.chdrnum);
                i_zdoe_info.i_errorprogram01 := i_schedulename;
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            ELSE -- No error within the same Policy Number records so far.
                i_zdoe_info.i_indic := 'S';
                pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
            END IF;
        END IF;

        << createpostvalidation >> IF b_isnoerror = false OR b_chdrnum_isnoerror = false THEN  --- if the current record is error or the same preceding Policy Number records are already error
            obj_dmigtitdmgmaspol.recidxmpmspol := obj_maspol.recidxmpmspol;
            obj_dmigtitdmgmaspol.chdrnum := obj_maspol.chdrnum;
            obj_dmigtitdmgmaspol.cnttype := obj_maspol.cnttype;
            obj_dmigtitdmgmaspol.statcode := obj_maspol.statcode;
            obj_dmigtitdmgmaspol.zagptnum := obj_maspol.zagptnum;
            obj_dmigtitdmgmaspol.ccdate := obj_maspol.ccdate;
            obj_dmigtitdmgmaspol.crdate := obj_maspol.crdate;
            obj_dmigtitdmgmaspol.rptfpst := obj_maspol.rptfpst;
            obj_dmigtitdmgmaspol.zendcde := obj_maspol.zendcde;
            obj_dmigtitdmgmaspol.rra2ig := obj_maspol.rra2ig;
            obj_dmigtitdmgmaspol.b8tjig := obj_maspol.b8tjig;
            obj_dmigtitdmgmaspol.zblnkpol := obj_maspol.zblnkpol;
            obj_dmigtitdmgmaspol.b8o9nb := obj_maspol.b8o9nb;
            obj_dmigtitdmgmaspol.b8gpst := obj_maspol.b8gpst;
            obj_dmigtitdmgmaspol.b8gost := obj_maspol.b8gost;
            obj_dmigtitdmgmaspol.znbaltpr := obj_maspol.znbaltpr;
            obj_dmigtitdmgmaspol.canceldt := obj_maspol.canceldt;
            obj_dmigtitdmgmaspol.effdate := obj_maspol.effdate;
            obj_dmigtitdmgmaspol.pndate := obj_maspol.pndate;
            obj_dmigtitdmgmaspol.occdate := obj_maspol.occdate;
            obj_dmigtitdmgmaspol.insendte := obj_maspol.insendte;
            obj_dmigtitdmgmaspol.zpenddt := obj_maspol.zpenddt;
            obj_dmigtitdmgmaspol.zccde := obj_maspol.zccde;
            obj_dmigtitdmgmaspol.zconsgnm := obj_maspol.zconsgnm;
            obj_dmigtitdmgmaspol.zbladcd := obj_maspol.zbladcd;
            obj_dmigtitdmgmaspol.clntnum := obj_maspol.clntnum;
            obj_dmigtitdmgmaspol.ind := 'E';
            INSERT INTO dmigtitdmgmaspol VALUES obj_dmigtitdmgmaspol;

            CONTINUE skiprecord;
        END IF;

        IF ( ( b_isnoerror = true ) AND ( i_zprvaldyn = 'N' ) ) THEN
            /**
            IF v_sv_mspol_chdrnum IS NULL THEN
               i_chdrnum_break := TRUE;
               v_sv_mspol_chdrnum := v_mspol_chdrnum;
               v_cnt_policy := 1;
            ELSIF  v_mspol_chdrnum = v_sv_mspol_chdrnum THEN
               i_chdrnum_break := FALSE;
               v_cnt_policy := v_cnt_policy + 1;
            ELSE
               i_chdrnum_break := TRUE;
               v_sv_mspol_chdrnum := v_mspol_chdrnum;
               v_cnt_policy := 1;
            END IF;
            **/

            ---dbms_output.put_line(obj_maspol.chdrnum || '-'  || obj_maspol.ccdate || ' : ' || 'v_cnt_policy:' || v_cnt_policy ||' , obj_maspol.period_num:' || obj_maspol.period_num);  ---debug MP8 @@@@@

            ---MP5
            IF i_chdrnum_break = true THEN
                INSERT INTO pazdmppf (
                    recstatus,
                    prefix,
                    zentity,
                    zigvalue,
                    jobnum,
                    jobname
                ) VALUES (
                    'OK',
                    c_prefix,
                    TRIM(v_sv_mspol_chdrnum),
                    TRIM(v_sv_mspol_chdrnum),
                    i_schedulenumber,
                    i_schedulename
                );

               ---obj_pazdmppf.recstatus := 'OK';
               ---obj_pazdmppf.prefix := c_prefix;
               ---obj_pazdmppf.zentity := TRIM(v_sv_mspol_chdrnum);
               ---obj_pazdmppf.zigvalue := TRIM(v_sv_mspol_chdrnum);
               ---obj_pazdmppf.jobnum := i_schedulenumber;
               ---obj_pazdmppf.jobname := i_schedulename;
               ---INSERT INTO pazdmppf VALUES obj_pazdmppf;

            END IF;

            --- get Renewal ---
            --- MP8 ---
            ----PKG_DM_MASTPOLICY.getRenewal(i_zplancls => v_zplancls, i_zblnkpol => TRIM(obj_maspol.zblnkpol), i_b8gpst => TRIM(obj_maspol.b8gpst), i_b8o9nb => TRIM(obj_maspol.b8o9nb), i_company => i_company, o_zrnwabl => v_zrnwabl);
            --- MP8 ---
            --- get template ---

             /*IF (t_dfpopfval.exists(TRIM(v_template) || TRIM(o_defaultvalues('CHDRCOY')))) THEN
                         dbms_output.put_line('***** debug : got that ****[' || TRIM(v_template) || TRIM(o_defaultvalues('CHDRCOY')) || ']');

             else
                         dbms_output.put_line('***** debug : not available****[' || TRIM(v_template) || TRIM(o_defaultvalues('CHDRCOY')) || ']');

             end if;

              IF (t_dfpopfval.exists(TRIM(v_template))) THEN
                         dbms_output.put_line('***** second debug : got that ****[' || TRIM(v_template) );

             else
                         dbms_output.put_line('*****second  debug : not available****[' || TRIM(v_template) ) ;

             end if;
             */

            r_dfpopval := t_dfpopfval(trim(v_template)
                                      || trim(o_defaultvalues('CHDRCOY')));

            --- GCHD Migration ---
            --- MP8 ---

            IF obj_maspol.period_num = 1 THEN
                obj_gchd.occdate := trim(obj_maspol.ccdate);  -- minimum occdate
            END IF;

            obj_gchd.chdrpfx := o_defaultvalues('CHDRPFX');
            obj_gchd.chdrcoy := o_defaultvalues('CHDRCOY');
            obj_gchd.chdrnum := v_mspol_chdrnum;
            obj_gchd.recode := c_gchd_recode;
            obj_gchd.servunit := o_defaultvalues('SERVUNIT');
            obj_gchd.cnttype := trim(obj_maspol.cnttype);
            obj_gchd.tranid := v_tranid;
            obj_gchd.validflag := o_defaultvalues('VALIDFLAG');
            obj_gchd.currfrom := c_gchd_currfrom;
            obj_gchd.currto := c_gchd_currto;
            obj_gchd.proctrancd := c_gchd_proctrancd;
            obj_gchd.procflag := c_gchd_procflag;
            obj_gchd.procid := c_gchd_procid;
            obj_gchd.statcode := trim(obj_maspol.statcode);
            obj_gchd.statreasn := c_gchd_statreasn;
            obj_gchd.statdate := c_gchd_statdate;
            obj_gchd.stattran := c_gchd_stattran;
            obj_gchd.ccdate := c_gchd_ccdate;
            obj_gchd.crdate := c_gchd_crdate;
            obj_gchd.annamt01 := c_gchd_annamt01;
            obj_gchd.annamt02 := c_gchd_annamt02;
            obj_gchd.annamt03 := c_gchd_annamt03;
            obj_gchd.annamt04 := c_gchd_annamt04;
            obj_gchd.annamt05 := c_gchd_annamt05;
            obj_gchd.annamt06 := c_gchd_annamt06;
            obj_gchd.rnltype := c_gchd_rnltype;
            obj_gchd.rnlnots := c_gchd_rnlnots;
            obj_gchd.rnlnotto := o_defaultvalues('RNLNOTTO');
            obj_gchd.rnlattn := c_gchd_rnlattn;
            obj_gchd.rnldurn := c_gchd_rnldurn;
            obj_gchd.reptype := c_gchd_reptype;
            obj_gchd.repnum := c_gchd_repnum;
            obj_gchd.cownpfx := o_defaultvalues('COWNPFX');
            obj_gchd.cowncoy := o_defaultvalues('COWNCOY');
            obj_gchd.cownnum := v_cownnum;
            obj_gchd.jownnum := c_gchd_jownnum;
            obj_gchd.payrpfx := c_gchd_payrpfx;
            obj_gchd.payrcoy := c_gchd_payrcoy;
            obj_gchd.payrnum := c_gchd_payrnum;
            obj_gchd.desppfx := c_gchd_desppfx;
            obj_gchd.despcoy := c_gchd_despcoy;
            obj_gchd.despnum := c_gchd_despnum;
            obj_gchd.asgnpfx := c_gchd_asgnpfx;
            obj_gchd.asgncoy := c_gchd_asgncoy;
            obj_gchd.asgnnum := c_gchd_asgnnum;
            obj_gchd.cntbranch := c_gchd_cntbranch;
            obj_gchd.agntpfx := c_gchd_agntpfx;
            obj_gchd.agntcoy := c_gchd_agntcoy;
            obj_gchd.agntnum := c_gchd_agntnum;
            obj_gchd.cntcurr := o_defaultvalues('CNTCURR');
            obj_gchd.acctccy := c_gchd_acctccy;
            obj_gchd.crate := c_gchd_crate;
            obj_gchd.payplan := c_gchd_payplan;
            obj_gchd.acctmeth := c_gchd_acctmeth;
            obj_gchd.billfreq := c_gchd_billfreq;
            obj_gchd.billchnl := c_gchd_billchnl;
            obj_gchd.collchnl := c_gchd_collchnl;
            obj_gchd.billday := c_gchd_billday;
            obj_gchd.billmonth := c_gchd_billmonth;
            obj_gchd.billcd := c_gchd_billcd;
            obj_gchd.btdate := c_gchd_btdate;
            obj_gchd.ptdate := c_gchd_ptdate;
            obj_gchd.payflag := c_gchd_payflag;
            obj_gchd.sinstfrom := c_gchd_sinstfrom;
            obj_gchd.sinstto := c_gchd_sinstto;
            obj_gchd.sinstamt01 := c_gchd_sinstamt01;
            obj_gchd.sinstamt02 := c_gchd_sinstamt02;
            obj_gchd.sinstamt03 := c_gchd_sinstamt03;
            obj_gchd.sinstamt04 := c_gchd_sinstamt04;
            obj_gchd.sinstamt05 := c_gchd_sinstamt05;
            obj_gchd.sinstamt06 := c_gchd_sinstamt06;
            obj_gchd.instfrom := c_gchd_instfrom;
            obj_gchd.instto := c_gchd_instto;
            obj_gchd.instbchnl := c_gchd_instbchnl;
            obj_gchd.instcchnl := c_gchd_instcchnl;
            obj_gchd.instfreq := c_gchd_instfreq;
            obj_gchd.insttot01 := c_gchd_insttot01;
            obj_gchd.insttot02 := c_gchd_insttot02;
            obj_gchd.insttot03 := c_gchd_insttot03;
            obj_gchd.insttot04 := c_gchd_insttot04;
            obj_gchd.insttot05 := c_gchd_insttot05;
            obj_gchd.insttot06 := c_gchd_insttot06;
            obj_gchd.instpast01 := c_gchd_instpast01;
            obj_gchd.instpast02 := c_gchd_instpast02;
            obj_gchd.instpast03 := c_gchd_instpast03;
            obj_gchd.instpast04 := c_gchd_instpast04;
            obj_gchd.instpast05 := c_gchd_instpast05;
            obj_gchd.instpast06 := c_gchd_instpast06;
            obj_gchd.instjctl := c_gchd_instjctl;
            obj_gchd.nofoutinst := c_gchd_nofoutinst;
            obj_gchd.outstamt := c_gchd_outstamt;
            obj_gchd.billdate01 := c_gchd_billdate01;
            obj_gchd.billdate02 := c_gchd_billdate02;
            obj_gchd.billdate03 := c_gchd_billdate03;
            obj_gchd.billdate04 := c_gchd_billdate04;
            obj_gchd.billamt01 := c_gchd_billamt01;
            obj_gchd.billamt02 := c_gchd_billamt02;
            obj_gchd.billamt03 := c_gchd_billamt03;
            obj_gchd.billamt04 := c_gchd_billamt04;
            obj_gchd.facthous := c_gchd_facthous;
            obj_gchd.bankkey := c_gchd_bankkey;
            obj_gchd.bankacckey := c_gchd_bankacckey;
            obj_gchd.discode01 := c_gchd_discode01;
            obj_gchd.discode02 := c_gchd_discode02;
            obj_gchd.discode03 := c_gchd_discode03;
            obj_gchd.discode04 := c_gchd_discode04;
            obj_gchd.grupkey := c_gchd_grupkey;
            obj_gchd.membsel := c_gchd_membsel;
            obj_gchd.aplsupr := c_gchd_aplsupr;
            obj_gchd.aplspfrom := c_gchd_aplspfrom;
            obj_gchd.aplspto := c_gchd_aplspto;
            obj_gchd.billsupr := c_gchd_billsupr;
            obj_gchd.billspfrom := c_gchd_billspfrom;
            obj_gchd.billspto := c_gchd_billspto;
            obj_gchd.commsupr := c_gchd_commsupr;
            obj_gchd.commspfrom := c_gchd_commspfrom;
            obj_gchd.commspto := c_gchd_commspto;
            obj_gchd.lapssupr := c_gchd_lapssupr;
            obj_gchd.lapsspfrom := c_gchd_lapsspfrom;
            obj_gchd.lapsspto := c_gchd_lapsspto;
            obj_gchd.mailsupr := c_gchd_mailsupr;
            obj_gchd.mailspfrom := c_gchd_mailspfrom;
            obj_gchd.mailspto := c_gchd_mailspto;
            obj_gchd.notssupr := c_gchd_notssupr;
            obj_gchd.notsspfrom := c_gchd_notsspfrom;
            obj_gchd.notsspto := c_gchd_notsspto;
            obj_gchd.rnwlsupr := c_gchd_rnwlsupr;
            obj_gchd.rnwlspfrom := c_gchd_rnwlspfrom;
            obj_gchd.rnwlspto := c_gchd_rnwlspto;
            obj_gchd.campaign := c_gchd_campaign;
            obj_gchd.srcebus := v_agtype;
            obj_gchd.nofrisks := c_gchd_nofrisks;
            obj_gchd.jacket := c_gchd_jacket;
            obj_gchd.isam01 := c_gchd_isam01;
            obj_gchd.isam02 := c_gchd_isam02;
            obj_gchd.isam03 := c_gchd_isam03;
            obj_gchd.isam04 := c_gchd_isam04;
            obj_gchd.isam05 := c_gchd_isam05;
            obj_gchd.isam06 := c_gchd_isam06;
            obj_gchd.pstcde := c_gchd_pstcde;
            obj_gchd.pstrsn := c_gchd_pstrsn;
            obj_gchd.psttrn := c_gchd_psttrn;
            obj_gchd.pstdat := c_gchd_pstdat;
            obj_gchd.pdind := c_gchd_pdind;
            obj_gchd.reg := c_gchd_reg;
            obj_gchd.stca := c_gchd_stca;
            obj_gchd.stcb := c_gchd_stcb;
            obj_gchd.stcc := c_gchd_stcc;
            obj_gchd.stcd := c_gchd_stcd;
            obj_gchd.stce := c_gchd_stce;
            obj_gchd.mplpfx := c_gchd_mplpfx;
            obj_gchd.mplcoy := o_defaultvalues('MPLCOY');
            obj_gchd.mplnum := v_mspol_chdrnum;
            obj_gchd.poapfx := c_gchd_poapfx;
            obj_gchd.poacoy := c_gchd_poacoy;
            obj_gchd.poanum := c_gchd_poanum;
            obj_gchd.finpfx := c_gchd_finpfx;
            obj_gchd.fincoy := c_gchd_fincoy;
            obj_gchd.finnum := c_gchd_finnum;
            obj_gchd.wvfdat := c_gchd_wvfdat;
            obj_gchd.wvtdat := c_gchd_wvtdat;
            obj_gchd.wvfind := c_gchd_wvfind;
            obj_gchd.clupfx := c_gchd_clupfx;
            obj_gchd.clucoy := c_gchd_clucoy;
            obj_gchd.clunum := c_gchd_clunum;
            obj_gchd.polpln := c_gchd_polpln;
            obj_gchd.chgflag := c_gchd_chgflag;
            obj_gchd.laprind := c_gchd_laprind;
            obj_gchd.specind := c_gchd_specind;
            obj_gchd.dueflg := c_gchd_dueflg;
            obj_gchd.bfcharge := c_gchd_bfcharge;
            obj_gchd.dishnrcnt := c_gchd_dishnrcnt;
            obj_gchd.pdtype := c_gchd_pdtype;
            obj_gchd.dishnrdte := c_gchd_dishnrdte;
            obj_gchd.stmpdtyamt := c_gchd_stmpdtyamt;
            obj_gchd.stmpdtydte := c_gchd_stmpdtydte;
            obj_gchd.polinc := c_gchd_polinc;
            obj_gchd.polsum := c_gchd_polsum;
            obj_gchd.nxtsfx := c_gchd_nxtsfx;
            obj_gchd.avlisu := c_gchd_avlisu;
            obj_gchd.stmdte := c_gchd_stmdte;
            obj_gchd.billcurr := o_defaultvalues('BILLCURR');
            obj_gchd.tfrswused := c_gchd_tfrswused;
            obj_gchd.tfrswleft := c_gchd_tfrswleft;
            obj_gchd.lastswdate := c_gchd_lastswdate;
            obj_gchd.mandref := c_gchd_mandref;
            obj_gchd.cntiss := c_gchd_cntiss;
            obj_gchd.cntrcv := c_gchd_cntrcv;
            obj_gchd.coppn := c_gchd_coppn;
            obj_gchd.cotype := c_gchd_cotype;
            obj_gchd.covernt := c_gchd_covernt;
            obj_gchd.docnum := c_gchd_docnum;
            obj_gchd.dtecan := c_gchd_dtecan;
            obj_gchd.quoteno := c_gchd_quoteno;
            obj_gchd.rnlsts := c_gchd_rnlsts;
            obj_gchd.sustrcde := c_gchd_sustrcde;
            obj_gchd.bankcode := c_gchd_bankcode;
            obj_gchd.pndate := trim(obj_maspol.pndate);
            obj_gchd.subsflg := c_gchd_subsflg;
            obj_gchd.hrskind := c_gchd_hrskind;
            obj_gchd.slrypflg := c_gchd_slrypflg;
            obj_gchd.takovrflg := c_gchd_takovrflg;
            obj_gchd.gprnltyp := c_gchd_gprnltyp;
            obj_gchd.gprmnths := c_gchd_gprmnths;
            obj_gchd.coysrvac := c_gchd_coysrvac;
            obj_gchd.mrksrvac := c_gchd_mrksrvac;
            obj_gchd.polschpflg := o_defaultvalues('POLSCHPFLG');
            obj_gchd.adjdate := c_gchd_adjdate;
            obj_gchd.ptdateab := c_gchd_ptdateab;
            obj_gchd.lmbrno := c_gchd_lmbrno;
            obj_gchd.lheadno := c_gchd_lheadno;
            obj_gchd.pntrcde := o_defaultvalues('PNTRCDE');
            obj_gchd.taxflag := o_defaultvalues('TAXFLAG');
            obj_gchd.agedef := c_gchd_agedef;
            obj_gchd.termage := r_dfpopval.termage;
            obj_gchd.personcov := c_gchd_personcov;
            obj_gchd.enrolltyp := o_defaultvalues('ENROLLTYP');
            obj_gchd.splitsubs := o_defaultvalues('SPLITSUBS');
            obj_gchd.dtlsind := c_gchd_dtlsind;
            obj_gchd.zrenno := c_gchd_zrenno;
            obj_gchd.zendno := c_gchd_zendno;
            obj_gchd.zresnpd := c_gchd_zresnpd;
            obj_gchd.zrepolno := c_gchd_zrepolno;
            obj_gchd.zcomtyp := c_gchd_zcomtyp;
            obj_gchd.zrinum := c_gchd_zrinum;
            obj_gchd.zschprt := c_gchd_zschprt;
            obj_gchd.zpaymode := c_gchd_zpaymode;
            obj_gchd.usrprf := i_usrprf;
            obj_gchd.jobnme := i_schedulename;
            obj_gchd.datime := current_timestamp;
            obj_gchd.jobnm := i_schedulename;
            obj_gchd.quotetype := c_gchd_quotetype;
            obj_gchd.zmandref := c_gchd_zmandref;
            obj_gchd.reqntype := c_gchd_reqntype;
            obj_gchd.payclt := c_gchd_payclt;
            obj_gchd.midjoin := c_gchd_midjoin;
            obj_gchd.igrasp := c_gchd_igrasp;
            obj_gchd.iexplain := c_gchd_iexplain;
            obj_gchd.idate := c_gchd_idate;
            obj_gchd.cvisaind := c_gchd_cvisaind;
            obj_gchd.suprflg := c_gchd_suprflg;
            obj_gchd.iendno := c_gchd_iendno;
            obj_gchd.peiendind := c_gchd_peiendind;
            obj_gchd.duedte := c_gchd_duedte;
            obj_gchd.schmno := c_gchd_schmno;
            obj_gchd.jobnum := c_gchd_jobnum;
            obj_gchd.nlgflg := c_gchd_nlgflg;
            obj_gchd.zrwnlage := c_gchd_zrwnlage;
            obj_gchd.zprvchdr := c_gchd_zprvchdr;
            obj_gchd.rtgrante := c_gchd_rtgrante;
            obj_gchd.rtgrantedate := c_gchd_rtgrantedate;
            obj_gchd.cpiincrind := c_gchd_cpiincrind;
            obj_gchd.superflag := c_gchd_superflag;
            IF obj_maspol.period_num = obj_maspol.cnt_policy THEN  -- insert from the last policy information
                obj_gchd.tranno := obj_maspol.cnt_policy;
                IF TRIM(obj_maspol.statcode) IN (
                    c_sts_ca,
                    c_sts_la
                ) OR TRIM(obj_maspol.canceldt) IS NOT NULL THEN -- cancel (past or future) or lapse
                    obj_gchd.tranno := obj_gchd.tranno + 1;
                END IF;

                obj_gchd.tranlused := obj_gchd.tranno;
                obj_gchd.effdcldt := c_gchd_effdcldt;
                IF trim(obj_maspol.statcode) = c_sts_la THEN  -- lapse
                    obj_gchd.effdcldt := v_crdatesub1d;
                ELSIF TRIM(obj_maspol.canceldt) IS NOT NULL THEN   -- cancellation
                    obj_gchd.effdcldt := trim(obj_maspol.canceldt);
                END IF;

               -- SELECT
               --     seq_chdrpf.NEXTVAL
               -- INTO v_pkvalue
               -- FROM
               --     dual;
                v_pkvalue := seq_chdrpf.NEXTVAL; -- PerfImprov
                obj_gchd.unique_number := v_pkvalue;
                INSERT INTO gchd VALUES obj_gchd;

            END IF;
            --- MP8 --

            --- GCHIPF Migration ---

            obj_gchipf.chdrcoy := o_defaultvalues('CHDRCOY');
            obj_gchipf.chdrnum := v_mspol_chdrnum;
            obj_gchipf.effdate := trim(obj_maspol.effdate);
            obj_gchipf.ccdate := trim(obj_maspol.ccdate);
            obj_gchipf.crdate := v_crdatesub1d;
            obj_gchipf.prvbilflg := o_defaultvalues('PRVBILFLG');
            obj_gchipf.billfreq := r_dfpopval.billfreq;
            obj_gchipf.gadjfreq := r_dfpopval.gadjfreq;
            obj_gchipf.payrpfx := c_gchipf_payrpfx;
            obj_gchipf.payrcoy := c_gchipf_payrcoy;
            obj_gchipf.payrnum := c_gchipf_payrnum;
            obj_gchipf.agntpfx := o_defaultvalues('AGNTPFX');
            obj_gchipf.agntcoy := o_defaultvalues('AGNTCOY');
            obj_gchipf.agntnum := v_agntnum;
            obj_gchipf.cntbranch := o_defaultvalues('CNTBRANCH');
            obj_gchipf.stca := o_defaultvalues('STCA');
            obj_gchipf.stcb := c_gchipf_stcb;
            obj_gchipf.stcc := c_gchipf_stcc;
            obj_gchipf.stcd := c_gchipf_stcd;
            obj_gchipf.stce := c_gchipf_stce;
            obj_gchipf.btdatenr := c_gchipf_btdatenr;
            obj_gchipf.nrisdate := c_gchipf_nrisdate;
            obj_gchipf.termid := i_vrcmtermid;
            obj_gchipf.user_t := c_gchipf_user_t;
            obj_gchipf.trdt := c_gchipf_trdt;
            obj_gchipf.trtm := c_gchipf_trtm;

            --- MP8
            IF obj_maspol.period_num = 1 THEN  --- MP8
                obj_gchipf.tranno := 1;
            ELSE
                obj_gchipf.tranno := obj_gchipf.tranno + 1;
            END IF;
            --- MP8

            obj_gchipf.crate := c_gchipf_crate;
            obj_gchipf.ternmprm := c_gchipf_ternmprm;
            obj_gchipf.surgschmv := c_gchipf_surgschmv;
            obj_gchipf.areacdemv := c_gchipf_areacdemv;
            obj_gchipf.medprvdr := c_gchipf_medprvdr;
            obj_gchipf.spsmbr := c_gchipf_spsmbr;
            obj_gchipf.childmbr := c_gchipf_childmbr;
            obj_gchipf.spsmed := c_gchipf_spsmed;
            obj_gchipf.childmed := c_gchipf_childmed;
            obj_gchipf.bankcode := c_gchipf_bankcode;
            obj_gchipf.billchnl := c_gchipf_billchnl;
            obj_gchipf.mandref := c_gchipf_mandref;
            obj_gchipf.rimthvcd := c_gchipf_rimthvcd;
            obj_gchipf.prmrvwdt := c_gchipf_prmrvwdt;
            obj_gchipf.appltyp := c_gchipf_appltyp;
            obj_gchipf.riind := o_defaultvalues('RIIND');
            obj_gchipf.usrprf := i_usrprf;
            obj_gchipf.jobnm := i_schedulename;
            obj_gchipf.datime := current_timestamp;
            obj_gchipf.cflimit := c_gchipf_cflimit;
            obj_gchipf.polbreak := c_gchipf_polbreak;
            obj_gchipf.cftype := c_gchipf_cftype;
            obj_gchipf.lmtdrl := c_gchipf_lmtdrl;
            obj_gchipf.nofclaim := c_gchipf_nofclaim;
            obj_gchipf.tpa := c_gchipf_tpa;
            obj_gchipf.wkladrt := c_gchipf_wkladrt;
            obj_gchipf.wklcmrt := c_gchipf_wklcmrt;
            obj_gchipf.nofmbr := c_gchipf_nofmbr;
            obj_gchipf.ecnv := c_gchipf_ecnv;
            obj_gchipf.cvntype := c_gchipf_cvntype;
            obj_gchipf.covernt := c_gchipf_covernt;
            --obj_gchipf.timech01 := v_timech01; MP11 : New start/end time implementation
            --obj_gchipf.timech02 := v_timech02; MP11 : New start/end time implementation
            obj_gchipf.tpaflg := c_gchipf_tpaflg;
            obj_gchipf.docrcdte := c_gchipf_docrcdte;
            obj_gchipf.zagptnum := trim(obj_maspol.zagptnum);
            obj_gchipf.insstdte := c_gchipf_insstdte;
            obj_gchipf.insendte := trim(obj_maspol.insendte)
                                   || '  ';
            obj_gchipf.zcmpcode := c_gchipf_zcmpcode;
            obj_gchipf.zsolctflg := c_gchipf_zsolctflg;
            obj_gchipf.hpropdte := c_gchipf_hpropdte;
            obj_gchipf.zpenddt := v_zpenddtsub1d;
            obj_gchipf.zpstddt := obj_gchd.pndate;
            obj_gchipf.zcedtime := c_gchipf_zcedtime;
            obj_gchipf.zcstime := c_gchipf_zcstime;
            obj_gchipf.cownnum := c_gchipf_cownnum;
            obj_gchipf.zpolperd := v_zpolperd;
            obj_gchipf.zrnwcnt := c_gchipf_zrnwcnt;  --MP8

			--START MP11: 
			IF obj_maspol.period_num = 1 THEN --New Business
				obj_gchipf.timech01 := v_timech01;
				obj_gchipf.timech02 := v_timech02;
			ELSE --RENEWAL
				obj_gchipf.timech01 := v_timech02;
				obj_gchipf.timech02 := v_timech02;
			END IF;
			--END MP11:

            --- MP4
            --SELECT
            --    seq_gchipf.NEXTVAL
            --INTO v_pkvalue
            --FROM
            --    dual;
            v_pkvalue := seq_gchipf.NEXTVAL; --PerfImprov
            obj_gchipf.unique_number := v_pkvalue;
            INSERT INTO gchipf VALUES obj_gchipf;

            IF obj_gchd.statcode IN (
                c_sts_ca,
                c_sts_la
            ) OR TRIM(obj_maspol.canceldt) IS NOT NULL THEN
                obj_gchipf.tranno := obj_gchipf.tranno + 1;
               -- SELECT
               --     seq_gchipf.NEXTVAL
               -- INTO v_pkvalue
               -- FROM
               --     dual;
                v_pkvalue := seq_gchipf.NEXTVAL; --PerfImprov
                obj_gchipf.unique_number := v_pkvalue;
                INSERT INTO gchipf VALUES obj_gchipf;

            END IF;

            --- GCHPPF Migration ---

            /* ?X?n????? GCHPPF ???f??n???????}???????????A?d???L?[?ichdrcoy?{chdrnum) ???????????????B????????}???A?X?V?????d?l?????????????????e??????B
               ?????f??n???????}?????????????A
               ?P?D?g???K?[?fTR_GCHPPF?f?@???????n??????B
               ?Q?D???n????l??Script ???@unique_number?@?????g??????B

                SELECT
                       seq_gchppf.NEXTVAL
                INTO
                       obj_gchppf.unique_number
                FROM
                       dual;
            */

            obj_gchppf.chdrcoy := o_defaultvalues('CHDRCOY');
            obj_gchppf.chdrnum := v_mspol_chdrnum;
            obj_gchppf.exbrknm := c_gchppf_exbrknm;
            obj_gchppf.exundnm := c_gchppf_exundnm;
            obj_gchppf.brksrvac := c_gchppf_brksrvac;
            obj_gchppf.refno := c_gchppf_refno;
            obj_gchppf.mbrdata := c_gchppf_mbrdata;
            obj_gchppf.admnrule := r_dfpopval.admnrule;
            obj_gchppf.defplandi := c_gchppf_defplandi;
            obj_gchppf.defclmpye := r_dfpopval.defclmpye;
            obj_gchppf.empgrp := c_gchppf_empgrp;
            obj_gchppf.inwinctyp := c_gchppf_inwinctyp;
            obj_gchppf.areacod := c_gchppf_areacod;
            obj_gchppf.industry := c_gchppf_industry;
            obj_gchppf.majormet := c_gchppf_majormet;
            obj_gchppf.bulkind := o_defaultvalues('BULKIND');
            obj_gchppf.ffeewhom := c_gchppf_ffeewhom;
            obj_gchppf.prodmix := o_defaultvalues('PRODMIX');
            obj_gchppf.feelvl := c_gchppf_feelvl;
            obj_gchppf.ctbeffdt := c_gchppf_ctbeffdt;
            obj_gchppf.exbfml := c_gchppf_exbfml;
            obj_gchppf.exbldays := c_gchppf_exbldays;
            obj_gchppf.ctbfml := c_gchppf_ctbfml;
            obj_gchppf.ctbndays := c_gchppf_ctbndays;
            obj_gchppf.efais := c_gchppf_efais;
            obj_gchppf.efadp := c_gchppf_efadp;
            obj_gchppf.norem := c_gchppf_norem;
            obj_gchppf.fstrmfml := c_gchppf_fstrmfml;
            obj_gchppf.fstrmday := c_gchppf_fstrmday;
            obj_gchppf.sndrmfml := c_gchppf_sndrmfml;
            obj_gchppf.sndrmday := c_gchppf_sndrmday;
            obj_gchppf.trdrmfml := c_gchppf_trdrmfml;
            obj_gchppf.trdrmday := c_gchppf_trdrmday;
            obj_gchppf.mbridfld := r_dfpopval.mbridfld;
            obj_gchppf.exbduedt := c_gchppf_exbduedt;
            obj_gchppf.ctbduedt := c_gchppf_ctbduedt;
            obj_gchppf.lstexbfr := c_gchppf_lstexbfr;
            obj_gchppf.lstexbto := c_gchppf_lstexbto;
            obj_gchppf.lstctbfr := c_gchppf_lstctbfr;
            obj_gchppf.lstctbto := c_gchppf_lstctbto;
            obj_gchppf.lstebpdt := c_gchppf_lstebpdt;
            obj_gchppf.fstrmpdt := c_gchppf_fstrmpdt;
            obj_gchppf.sndrmpdt := c_gchppf_sndrmpdt;
            obj_gchppf.trdrmpdt := c_gchppf_trdrmpdt;
            obj_gchppf.polanv := c_gchppf_polanv;
            obj_gchppf.ctbrule := c_gchppf_ctbrule;
            obj_gchppf.acblrule := c_gchppf_acblrule;
            obj_gchppf.fmcrule := c_gchppf_fmcrule;
            obj_gchppf.swtranno := c_gchppf_swtranno;
            obj_gchppf.feewho := c_gchppf_feewho;
            obj_gchppf.zsrcebus := c_gchppf_zsrcebus;
            obj_gchppf.calcmthd := r_dfpopval.calcmthd;
            obj_gchppf.agebasis := c_gchppf_agebasis;
            obj_gchppf.fcllvl := c_gchppf_fcllvl;
            obj_gchppf.prmpyopt := c_gchppf_prmpyopt;
            obj_gchppf.prmbrlvl := c_gchppf_prmbrlvl;
            obj_gchppf.tolrule := c_gchppf_tolrule;
            obj_gchppf.swcflg := c_gchppf_swcflg;
            obj_gchppf.usrprf := i_usrprf;
            obj_gchppf.jobnm := i_schedulename;
            obj_gchppf.datime := current_timestamp;
            obj_gchppf.certinfm := c_gchppf_certinfm;
            obj_gchppf.fmc2rule := c_gchppf_fmc2rule;
            obj_gchppf.lmbrpfx := c_gchppf_lmbrpfx;
            obj_gchppf.loybnflg := c_gchppf_loybnflg;
            obj_gchppf.autornw := c_gchppf_autornw;
            obj_gchppf.gaplpfx := c_gchppf_gaplpfx;
            obj_gchppf.nmlvar := c_gchppf_nmlvar;
            obj_gchppf.extfmly := c_gchppf_extfmly;
            obj_gchppf.pinfdte := c_gchppf_pinfdte;
            obj_gchppf.cashless := c_gchppf_cashless;
            obj_gchppf.location := c_gchppf_location;
            obj_gchppf.sublocn := c_gchppf_sublocn;
            obj_gchppf.ttdate := c_gchppf_ttdate;
            obj_gchppf.optautornw := c_gchppf_optautornw;
            obj_gchppf.ocallvsa := c_gchppf_ocallvsa;
            obj_gchppf.zplancls := v_zplancls;
            IF v_zplancls = c_zplancls_free THEN  -- When FreePlan, 1st of the previous month of CCDATE is set
                pkg_dm_mastpolicy.shiftdateval(i_dm => 'M', i_date => TRIM(obj_maspol.ccdate), i_increment => - 1, o_date => v_ccdatesub1m
                );

                obj_gchppf.zaplfod := substr(v_ccdatesub1m, 1, 6)
                                      || '01';
            ELSE
                obj_gchppf.zaplfod := c_gchppf_zaplfod;
            END IF;

            obj_gchppf.flagprint := o_defaultvalues('FLAGPRINT');
            obj_gchppf.zgporipcls := c_gchppf_zgporipcls;
            obj_gchppf.zendcde := trim(obj_maspol.zendcde);
            obj_gchppf.petname := trim(obj_maspol.rra2ig);
            obj_gchppf.zpenddt := trim(obj_maspol.zpenddt);
            obj_gchppf.matage := c_gchppf_matage;
            obj_gchppf.stmpdutyexe := c_gchppf_stmpdutyexe;
            obj_gchppf.zismbrpol := c_gchppf_zismbrpol;
            obj_gchppf.zinsrendt := c_gchppf_zinsrendt;
            ---MP2
            obj_gchppf.zcolmcls := v_zcolmcls_org;
            obj_gchppf.zconvindpol := c_gchppf_zconvindpol;
            obj_gchppf.hldcount := c_gchppf_hldcount;
            obj_gchppf.sinstno := c_gchppf_sinstno;
            obj_gchppf.zpgpfrdt := c_gchppf_zpgpfrdt;
            obj_gchppf.zpgptodt := c_gchppf_zpgptodt;
            obj_gchppf.znbmnage := c_gchppf_znbmnage;
            IF TRIM(obj_maspol.b8tjig) IS NULL THEN
                obj_gchppf.zgrpcls := c_gchppf_zgrpcls;
            ELSE
                obj_gchppf.zgrpcls := trim(obj_maspol.b8tjig);
            END IF;

            obj_gchppf.zsalechnl := c_gchppf_zsalechnl;
            obj_gchppf.zprdctg := o_defaultvalues('ZPRDCTG');

            --- MP8 --
            ---IF v_cnt_policy = obj_maspol.cnt_policy THEN -- When a current master policy is read, it is inserted.
            IF obj_maspol.period_num = obj_maspol.cnt_policy THEN -- When a current master policy is read, it is inserted.
                IF v_zrnwabl = 'N' THEN  -- Paid non-rebewable, Free, Blanket policy
                    obj_gchppf.zpoltdate := trim(obj_maspol.crdate); -- GCHIPF.CRDATE + 1 day
                    obj_gchppf.zlaptrx := 'Y';
                ELSE
                    obj_gchppf.zpoltdate := c_gchppf_zpoltdate;  --- 99999999
                    obj_gchppf.zlaptrx := 'N';
                END IF;
               ----MP4
			   --MP12:START-------------
                 IF v_zplancls = c_zplancls_free THEN
                  obj_gchppf.zpoltdate := c_gchppf_zpoltdate; --99999999
                 END IF;
               --MP12:END-------------

                --SELECT
                --    seq_gchppf.NEXTVAL
                --INTO v_pkvalue
                --FROM
                --    dual;
                v_pkvalue := seq_gchppf.NEXTVAL; --PerfImprov
                obj_gchppf.unique_number := v_pkvalue;
                INSERT INTO gchppf VALUES obj_gchppf;

            END IF;
            --- MP8 --

            --- ZENCTPF Migration ---

            IF v_zcolmcls = c_zcolmcls_cd THEN
               ---IF v_cnt_policy = obj_maspol.cnt_policy THEN -- When a current master policy is read, it is inserted.
                IF obj_maspol.period_num = obj_maspol.cnt_policy THEN -- When a current master policy is read, it is inserted. MP8
                    FOR indexitems IN 1..titdmgendctpf_list.count LOOP
                        obj_zenctpf.zpolnmbr := v_mspol_chdrnum;
                        obj_zenctpf.zendcde := obj_gchppf.zendcde;
                      --MP10:START
                        IF ( TRIM(titdmgendctpf_list(indexitems).zcrdtype) IS NOT NULL ) THEN
                            obj_zenctpf.zcrdtype := trim(titdmgendctpf_list(indexitems).zcrdtype);
                        ELSE
                            obj_zenctpf.zcrdtype := c_zenctpf_zcrdtype;
                        END IF;

                        IF ( TRIM(titdmgendctpf_list(indexitems).zcnbrfrm) IS NOT NULL ) THEN
                            obj_zenctpf.zcnbrfrm := trim(titdmgendctpf_list(indexitems).zcnbrfrm);
                        ELSE
                            obj_zenctpf.zcnbrfrm := c_zenctpf_zcnbrfrm;
                        END IF;

                        IF ( TRIM(titdmgendctpf_list(indexitems).zcnbrto) IS NOT NULL ) THEN
                            obj_zenctpf.zcnbrto := trim(titdmgendctpf_list(indexitems).zcnbrto);
                        ELSE
                            obj_zenctpf.zcnbrto := c_zenctpf_zcnbrto;
                        END IF;

                        obj_zenctpf.zmstid := trim(titdmgendctpf_list(indexitems).zmstid);
                        obj_zenctpf.zmstsnme := trim(titdmgendctpf_list(indexitems).zmstsnme);
                        obj_zenctpf.zccde := c_zenctpf_zccde;
                        obj_zenctpf.zconsgnm := c_zenctpf_zconsgnm;
                        obj_zenctpf.zprefix := c_zenctpf_zprefix;
                        obj_zenctpf.seqno := c_zenctpf_seqno;
                        obj_zenctpf.zmstidv := trim(titdmgendctpf_list(indexitems).zmstidv);
                        IF ( TRIM(titdmgendctpf_list(indexitems).zmstsnmev) IS NOT NULL ) THEN
                            obj_zenctpf.zmstsnmev := trim(titdmgendctpf_list(indexitems).zmstsnmev);
                        ELSE
                            obj_zenctpf.zmstsnmev := c_zenctpf_zmstsnmev;
                        END IF;

                        IF ( TRIM(titdmgendctpf_list(indexitems).zcarddc) IS NOT NULL ) THEN
                            obj_zenctpf.zcarddc := trim(titdmgendctpf_list(indexitems).zcarddc);
                        ELSE
                            obj_zenctpf.zcarddc := c_zenctpf_zcarddc;
                        END IF;
                        --MP10 :END

                        obj_zenctpf.zbladcd := trim(obj_maspol.zbladcd);
                        obj_zenctpf.usrprf := i_usrprf;
                        obj_zenctpf.jobnm := i_schedulename;
                        obj_zenctpf.datime := current_timestamp;
                        INSERT INTO zenctpf VALUES obj_zenctpf;

                    END LOOP;

                END IF;
            ELSE
                obj_zenctpf.zpolnmbr := v_mspol_chdrnum;
                obj_zenctpf.zendcde := obj_gchppf.zendcde;
                obj_zenctpf.zcrdtype := c_zenctpf_zcrdtype;
                obj_zenctpf.zcnbrfrm := c_zenctpf_zcnbrfrm;
                obj_zenctpf.zcnbrto := c_zenctpf_zcnbrto;
                obj_zenctpf.zmstid := c_zenctpf_zmstid;
                obj_zenctpf.zmstsnme := c_zenctpf_zmstsnme;

                ---MP6
                IF trim(obj_maspol.rptfpst) = c_rptfpst_paid THEN
                    obj_zenctpf.zccde := trim(obj_maspol.zccde);
                    obj_zenctpf.zconsgnm := trim(obj_maspol.zconsgnm);
                ELSE
                    IF TRIM(obj_maspol.zccde) IS NULL AND TRIM(obj_maspol.zconsgnm) IS NULL THEN
                        obj_zenctpf.zccde := c_zenctpf_zccde_free;
                        obj_zenctpf.zconsgnm := c_zenctpf_zconsgnm_free;
                    ELSE
                        obj_zenctpf.zccde := trim(obj_maspol.zccde);
                        obj_zenctpf.zconsgnm := trim(obj_maspol.zconsgnm);
                    END IF;
                END IF;

                obj_zenctpf.zprefix := c_zenctpf_zprefix;
                obj_zenctpf.seqno := c_zenctpf_seqno;
                obj_zenctpf.zmstidv := c_zenctpf_zmstidv;
                obj_zenctpf.zmstsnmev := c_zenctpf_zmstsnmev;
                obj_zenctpf.zcarddc := c_zenctpf_zcarddc;
                obj_zenctpf.zbladcd := trim(obj_maspol.zbladcd);
                obj_zenctpf.usrprf := i_usrprf;
                obj_zenctpf.jobnm := i_schedulename;
                obj_zenctpf.datime := current_timestamp;
                INSERT INTO zenctpf VALUES obj_zenctpf;

            END IF;

            --- ZTGMPF Migration ---

            ---dbms_output.put_line('obj_gchd.CHDRNUM:' || obj_gchd.CHDRNUM || ', obj_maspol.period_num:' || obj_maspol.period_num);  ----@@debug

            obj_ztgmpf.chdrcoy := obj_gchd.chdrcoy;
            obj_ztgmpf.chdrnum := obj_gchd.chdrnum;
            ---IF v_cnt_policy = 1 THEN
            IF obj_maspol.period_num = 1 THEN  --- MP8
                obj_ztgmpf.tranno := 1;
            ELSE
                obj_ztgmpf.tranno := obj_ztgmpf.tranno + 1;
            END IF;

            obj_ztgmpf.effdate := obj_gchipf.ccdate;
            obj_ztgmpf.cownnum := obj_gchd.cownnum;
            obj_ztgmpf.zagptnum := obj_gchipf.zagptnum;
            obj_ztgmpf.petname := obj_gchppf.petname;
            obj_ztgmpf.ztrxstat := o_defaultvalues('ZTRXSTAT');
            obj_ztgmpf.usrprf := i_usrprf;
            obj_ztgmpf.jobnm := i_schedulename;
            obj_ztgmpf.datime := current_timestamp;
            obj_ztgmpf.zblnkpol := trim(obj_maspol.zblnkpol);
            obj_ztgmpf.zrnwabl := v_zrnwabl;
            obj_ztgmpf.zgpmppp := obj_gchipf.zpolperd;
            obj_ztgmpf.zgrpcls := obj_gchppf.zgrpcls;
            obj_ztgmpf.zwavgflg := v_zwavgflg;
            obj_ztgmpf.znbaltpr := trim(obj_maspol.znbaltpr);
            IF TRIM(obj_maspol.b8o9nb) IS NULL THEN
                obj_ztgmpf.zrreffdt := c_ztgmpf_zrreffdt;
            ELSE
                obj_ztgmpf.zrreffdt := '20' || trim(obj_maspol.b8o9nb);
            END IF;

            obj_ztgmpf.zgrpdtrt := c_ztgmpf_zgrpdtrt;
            obj_ztgmpf.zinstypst1 := NULL;
            obj_ztgmpf.zinstypst2 := NULL;
            obj_ztgmpf.zinstypst3 := NULL;
            obj_ztgmpf.zinstypst4 := NULL;
            obj_ztgmpf.zinstypst5 := NULL;
            FOR indexsetplan1 IN 1..v_inssetplan_tab.count LOOP
                v_instype1 := NULL;
                v_instype2 := NULL;
                v_instype3 := NULL;
                v_instype4 := NULL;
                FOR indexinstypes1 IN 1..v_inssetplan_tab(indexsetplan1).zinstype.count LOOP CASE indexinstypes1
                    WHEN 1 THEN
                        v_instype1 := v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1);
                    WHEN 2 THEN
                        v_instype2 := v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1);
                    WHEN 3 THEN
                        v_instype3 := v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1);
                    WHEN 4 THEN
                        v_instype4 := v_inssetplan_tab(indexsetplan1).zinstype(indexinstypes1);
                END CASE;
                END LOOP;

                pkg_dm_mastpolicy.setinstypst(i_instype1 => v_instype1, i_instype2 => v_instype2, i_instype3 => v_instype3, i_instype4

                => v_instype4, o_instypst => v_instypst);

                CASE indexsetplan1
                    WHEN 1 THEN
                        obj_ztgmpf.zinstypst1 := v_instypst;
                    WHEN 2 THEN
                        obj_ztgmpf.zinstypst2 := v_instypst;
                    WHEN 3 THEN
                        obj_ztgmpf.zinstypst3 := v_instypst;
                    WHEN 4 THEN
                        obj_ztgmpf.zinstypst4 := v_instypst;
                    WHEN 5 THEN
                        obj_ztgmpf.zinstypst5 := v_instypst;
                END CASE;

            END LOOP;

            obj_ztgmpf.ccdate := obj_gchipf.ccdate;   --- MP8
            obj_ztgmpf.crdate := obj_gchipf.crdate;   --- MP8
            INSERT INTO ztgmpf (
                chdrcoy,
                chdrnum,
                tranno,
                effdate,
                cownnum,
                zagptnum,
                petname,
                ztrxstat,
                usrprf,
                jobnm,
                datime,
                zblnkpol,
                zrnwabl,
                zgpmppp,
                zwavgflg,
                znbaltpr,
                zrreffdt,
                zgrpdtrt,
                zinstypst1,
                zinstypst2,
                zinstypst3,
                zinstypst4,
                zinstypst5,
                zgrpcls,
                ccdate  --- MP8
                ,
                crdate
            )  --- MP8
             VALUES (
                obj_ztgmpf.chdrcoy,
                obj_ztgmpf.chdrnum,
                obj_ztgmpf.tranno,
                obj_ztgmpf.effdate,
                obj_ztgmpf.cownnum,
                obj_ztgmpf.zagptnum,
                obj_ztgmpf.petname,
                obj_ztgmpf.ztrxstat,
                obj_ztgmpf.usrprf,
                obj_ztgmpf.jobnm,
                obj_ztgmpf.datime,
                obj_ztgmpf.zblnkpol,
                obj_ztgmpf.zrnwabl,
                obj_ztgmpf.zgpmppp,
                obj_ztgmpf.zwavgflg,
                obj_ztgmpf.znbaltpr,
                obj_ztgmpf.zrreffdt,
                obj_ztgmpf.zgrpdtrt,
                obj_ztgmpf.zinstypst1,
                obj_ztgmpf.zinstypst2,
                obj_ztgmpf.zinstypst3,
                obj_ztgmpf.zinstypst4,
                obj_ztgmpf.zinstypst5,
                obj_ztgmpf.zgrpcls,
                obj_ztgmpf.ccdate    --- MP8
                ,
                obj_ztgmpf.crdate
            );    --- MP8

            IF obj_gchd.statcode IN (
                c_sts_ca,
                c_sts_la
            ) OR TRIM(obj_maspol.canceldt) IS NOT NULL THEN  --- MP8
                obj_ztgmpf.tranno := obj_ztgmpf.tranno + 1;
                IF TRIM(obj_maspol.canceldt) IS NOT NULL THEN  --- MP8
                    obj_ztgmpf.effdate := trim(obj_maspol.canceldt);
                END IF;

                INSERT INTO ztgmpf (
                    chdrcoy,
                    chdrnum,
                    tranno,
                    effdate,
                    cownnum,
                    zagptnum,
                    petname,
                    ztrxstat,
                    usrprf,
                    jobnm,
                    datime,
                    zblnkpol,
                    zrnwabl,
                    zgpmppp,
                    zwavgflg,
                    znbaltpr,
                    zrreffdt,
                    zgrpdtrt,
                    zinstypst1,
                    zinstypst2,
                    zinstypst3,
                    zinstypst4,
                    zinstypst5,
                    zgrpcls,
                    ccdate    --- MP8
                    ,
                    crdate
                )    --- MP8
                 VALUES (
                    obj_ztgmpf.chdrcoy,
                    obj_ztgmpf.chdrnum,
                    obj_ztgmpf.tranno,
                    obj_ztgmpf.effdate,
                    obj_ztgmpf.cownnum,
                    obj_ztgmpf.zagptnum,
                    obj_ztgmpf.petname,
                    obj_ztgmpf.ztrxstat,
                    obj_ztgmpf.usrprf,
                    obj_ztgmpf.jobnm,
                    obj_ztgmpf.datime,
                    obj_ztgmpf.zblnkpol,
                    obj_ztgmpf.zrnwabl,
                    obj_ztgmpf.zgpmppp,
                    obj_ztgmpf.zwavgflg,
                    obj_ztgmpf.znbaltpr,
                    obj_ztgmpf.zrreffdt,
                    obj_ztgmpf.zgrpdtrt,
                    obj_ztgmpf.zinstypst1,
                    obj_ztgmpf.zinstypst2,
                    obj_ztgmpf.zinstypst3,
                    obj_ztgmpf.zinstypst4,
                    obj_ztgmpf.zinstypst5,
                    obj_ztgmpf.zgrpcls,
                    obj_ztgmpf.ccdate    --- MP8
                    ,
                    obj_ztgmpf.crdate
                );    --- MP8

            END IF;


            --- ZTRAPF Migration ---

            obj_ztrapf.chdrcoy := obj_gchd.chdrcoy;
            obj_ztrapf.chdrnum := obj_gchd.chdrnum;

            --- MP8
            ---IF v_cnt_policy = 1 THEN
            IF obj_maspol.period_num = 1 THEN
                obj_ztrapf.tranno := 1;
                obj_ztrapf.trancde := c_nbtrncd;  ---T902
            ELSE
                obj_ztrapf.tranno := obj_ztrapf.tranno + 1;
                obj_ztrapf.trancde := c_rntrncd;  ---T918
            END IF;
            --- MP8

            obj_ztrapf.zquotind := o_defaultvalues('ZQUOTIND');
            obj_ztrapf.efdate := obj_gchipf.ccdate;
            obj_ztrapf.effdate := obj_gchipf.ccdate;
            obj_ztrapf.zlogaltdt := c_ztrapf_zlogaltdt;
            obj_ztrapf.zaltregdat := obj_gchipf.ccdate;
            obj_ztrapf.zaltrcde01 := c_ztrapf_zaltrcde01;
            obj_ztrapf.zaltrcde02 := c_ztrapf_zaltrcde02;
            obj_ztrapf.zaltrcde03 := c_ztrapf_zaltrcde03;
            obj_ztrapf.zaltrcde04 := c_ztrapf_zaltrcde04;
            obj_ztrapf.zaltrcde05 := c_ztrapf_zaltrcde05;
            obj_ztrapf.zfinancflg := c_ztrapf_zfinancflg;
            obj_ztrapf.zclmrecd := c_ztrapf_zclmrecd;
            obj_ztrapf.zinhdsclm := c_ztrapf_zinhdsclm;
            obj_ztrapf.zfinalbym := c_ztrapf_zfinalbym;
            ---obj_ztrapf.zuwrejflg := c_ztrapf_zuwrejflg;   ---MP9
            obj_ztrapf.zvioltyp := c_ztrapf_zvioltyp;
            obj_ztrapf.zstopbpj := c_ztrapf_zstopbpj;
            obj_ztrapf.zdfcncy := c_ztrapf_zdfcncy;
            obj_ztrapf.zmargnflg := c_ztrapf_zmargnflg;
            obj_ztrapf.docrcdte := c_ztrapf_docrcdte;
            obj_ztrapf.hpropdte := c_ztrapf_hpropdte;
            obj_ztrapf.ztrxstat := o_defaultvalues('ZTRXSTAT');
            obj_ztrapf.zstatresn := c_ztrapf_zstatresn;
            obj_ztrapf.zaclsdat := c_ztrapf_zaclsdat;
            obj_ztrapf.apprdte := obj_gchipf.ccdate;
            obj_ztrapf.zpoldate := c_ztrapf_zpoldate;
            obj_ztrapf.unique_number_01 := c_ztrapf_unique_number_01;
            obj_ztrapf.altquoteno := c_ztrapf_altquoteno;
            obj_ztrapf.zpdatatxdat := c_ztrapf_zpdatatxdat;
            obj_ztrapf.zpdatatxflg := c_ztrapf_zpdatatxflg;
            obj_ztrapf.zrefundam := c_ztrapf_zrefundam;
            obj_ztrapf.zsurchrge := c_ztrapf_zsurchrge;
            obj_ztrapf.zsalplnchg := c_ztrapf_zsalplnchg;
            obj_ztrapf.zpayinreq := o_defaultvalues('ZPAYINREQ');
            obj_ztrapf.usrprf := i_usrprf;
            obj_ztrapf.jobnm := i_schedulename;
            obj_ztrapf.datime := current_timestamp;
            obj_ztrapf.zcpmtddt := c_ztrapf_zcpmtddt;
            obj_ztrapf.zshftpgp := c_ztrapf_zshftpgp;
            obj_ztrapf.zcstpbil := c_ztrapf_zcstpbil;
            obj_ztrapf.zcpmcpncde := c_ztrapf_zcpmcpncde;
            obj_ztrapf.zcpmplancd := c_ztrapf_zcpmplancd;
            obj_ztrapf.zcpmbilamt := c_ztrapf_zcpmbilamt;
            obj_ztrapf.zbdpgpset := c_ztrapf_zbdpgpset;
            obj_ztrapf.zdfblind := o_defaultvalues('ZDFBLIND');
            obj_ztrapf.zrvtranno := c_ztrapf_zrvtranno;
            obj_ztrapf.zbltranno := c_ztrapf_zbltranno;
            IF TRIM(obj_maspol.statcode) IN (
                c_sts_ca,
                c_sts_la
            ) THEN  -- When the status is 'CA','LA', the original status set to 'IF'  -- MP8
                obj_ztrapf.statcode := c_ztrapf_statcode_if;
            ELSE
                obj_ztrapf.statcode := obj_gchd.statcode;
            END IF;

            obj_ztrapf.zvldtrxind := c_ztrapf_zvldtrxind; ---This is set to ?eY?f during termination transaction for all other existing transactions with EFFDATE >= Cancellation Date and TRANCDE != ?eT902?f
            obj_ztrapf.zrcaltty := c_ztrapf_zrcaltty;  ---MP8
            INSERT INTO ztrapf (
                chdrcoy,
                chdrnum,
                tranno,
                trancde,
                zquotind,
                efdate,
                effdate,
                zlogaltdt,
                zaltregdat,
                zaltrcde01,
                zaltrcde02,
                zaltrcde03,
                zaltrcde04,
                zaltrcde05,
                zfinancflg,
                zclmrecd,
                zinhdsclm,
                zfinalbym
                                ---,zuwrejflg   ---MP9
                ,
                zvioltyp,
                zstopbpj,
                zdfcncy,
                zmargnflg,
                docrcdte,
                hpropdte,
                ztrxstat,
                zstatresn,
                zaclsdat,
                apprdte,
                zpoldate,
                unique_number_01,
                altquoteno,
                zpdatatxdat,
                zpdatatxflg,
                zrefundam,
                zsurchrge,
                zsalplnchg,
                zpayinreq,
                usrprf,
                jobnm,
                datime,
                zcpmtddt,
                zshftpgp,
                zcstpbil,
                zcpmcpncde,
                zcpmplancd,
                zcpmbilamt,
                zbdpgpset,
                zdfblind,
                zrvtranno,
                zbltranno,
                statcode,
                zvldtrxind,
                zrcaltty
            )   ---MP8
             VALUES (
                obj_ztrapf.chdrcoy,
                obj_ztrapf.chdrnum,
                obj_ztrapf.tranno,
                obj_ztrapf.trancde,
                obj_ztrapf.zquotind,
                obj_ztrapf.efdate,
                obj_ztrapf.effdate,
                obj_ztrapf.zlogaltdt,
                obj_ztrapf.zaltregdat,
                obj_ztrapf.zaltrcde01,
                obj_ztrapf.zaltrcde02,
                obj_ztrapf.zaltrcde03,
                obj_ztrapf.zaltrcde04,
                obj_ztrapf.zaltrcde05,
                obj_ztrapf.zfinancflg,
                obj_ztrapf.zclmrecd,
                obj_ztrapf.zinhdsclm,
                obj_ztrapf.zfinalbym
                               ---,obj_ztrapf.zuwrejflg ---MP9
                ,
                obj_ztrapf.zvioltyp,
                obj_ztrapf.zstopbpj,
                obj_ztrapf.zdfcncy,
                obj_ztrapf.zmargnflg,
                obj_ztrapf.docrcdte,
                obj_ztrapf.hpropdte,
                obj_ztrapf.ztrxstat,
                obj_ztrapf.zstatresn,
                obj_ztrapf.zaclsdat,
                obj_ztrapf.apprdte,
                obj_ztrapf.zpoldate,
                obj_ztrapf.unique_number_01,
                obj_ztrapf.altquoteno,
                obj_ztrapf.zpdatatxdat,
                obj_ztrapf.zpdatatxflg,
                obj_ztrapf.zrefundam,
                obj_ztrapf.zsurchrge,
                obj_ztrapf.zsalplnchg,
                obj_ztrapf.zpayinreq,
                obj_ztrapf.usrprf,
                obj_ztrapf.jobnm,
                obj_ztrapf.datime,
                obj_ztrapf.zcpmtddt,
                obj_ztrapf.zshftpgp,
                obj_ztrapf.zcstpbil,
                obj_ztrapf.zcpmcpncde,
                obj_ztrapf.zcpmplancd,
                obj_ztrapf.zcpmbilamt,
                obj_ztrapf.zbdpgpset,
                obj_ztrapf.zdfblind,
                obj_ztrapf.zrvtranno,
                obj_ztrapf.zbltranno,
                obj_ztrapf.statcode,
                obj_ztrapf.zvldtrxind,
                obj_ztrapf.zrcaltty
            );   ---MP8


            ---- MP8

            IF TRIM(obj_maspol.statcode) IN (
                c_sts_ca,
                c_sts_la
            ) OR TRIM(obj_maspol.canceldt) IS NOT NULL THEN
                obj_ztrapf.tranno := obj_ztrapf.tranno + 1;
                obj_ztrapf.statcode := trim(obj_maspol.statcode);
                IF TRIM(obj_maspol.statcode) IN (
                    c_sts_ca,
                    c_sts_la
                ) THEN
                    obj_ztrapf.zvldtrxind := o_defaultvalues('ZVLDTRXIND');
                END IF;

                obj_ztrapf.trancde := c_cntrncd;  ---T912
                IF trim(obj_maspol.statcode) = c_sts_ca OR TRIM(obj_maspol.canceldt) IS NOT NULL THEN
                    pkg_dm_mastpolicy.shiftdateval(i_dm => 'M', i_date => obj_gchipf.ccdate, i_increment => 1, o_date => v_ccdateadd1m
                    );

                    obj_ztrapf.efdate := v_ccdateadd1m;
                    obj_ztrapf.effdate := trim(obj_maspol.canceldt);
                    obj_ztrapf.zaltregdat := trim(obj_maspol.canceldt);
                    IF v_zplancls = c_zplancls_paid THEN
                        obj_ztrapf.zaltrcde01 := c_ztrapf_zaltrcde01_pc;  ---GC1
                    ELSE
                        obj_ztrapf.zaltrcde01 := c_ztrapf_zaltrcde01_fc;  ---OT4
                    END IF;

                ELSE
                    obj_ztrapf.zaltrcde01 := c_ztrapf_zaltrcde01_la;  ---GC3
                END IF;
            ---- MP8

                INSERT INTO ztrapf (
                    chdrcoy,
                    chdrnum,
                    tranno,
                    trancde,
                    zquotind,
                    efdate,
                    effdate,
                    zlogaltdt,
                    zaltregdat,
                    zaltrcde01,
                    zaltrcde02,
                    zaltrcde03,
                    zaltrcde04,
                    zaltrcde05,
                    zfinancflg,
                    zclmrecd,
                    zinhdsclm,
                    zfinalbym
                                   ---,zuwrejflg  ---MP9
                    ,
                    zvioltyp,
                    zstopbpj,
                    zdfcncy,
                    zmargnflg,
                    docrcdte,
                    hpropdte,
                    ztrxstat,
                    zstatresn,
                    zaclsdat,
                    apprdte,
                    zpoldate,
                    unique_number_01,
                    altquoteno,
                    zpdatatxdat,
                    zpdatatxflg,
                    zrefundam,
                    zsurchrge,
                    zsalplnchg,
                    zpayinreq,
                    usrprf,
                    jobnm,
                    datime,
                    zcpmtddt,
                    zshftpgp,
                    zcstpbil,
                    zcpmcpncde,
                    zcpmplancd,
                    zcpmbilamt,
                    zbdpgpset,
                    zdfblind,
                    zrvtranno,
                    zbltranno,
                    statcode,
                    zvldtrxind,
                    zrcaltty
                )   ---MP8
                 VALUES (
                    obj_ztrapf.chdrcoy,
                    obj_ztrapf.chdrnum,
                    obj_ztrapf.tranno,
                    obj_ztrapf.trancde,
                    obj_ztrapf.zquotind,
                    obj_ztrapf.efdate,
                    obj_ztrapf.effdate,
                    obj_ztrapf.zlogaltdt,
                    obj_ztrapf.zaltregdat,
                    obj_ztrapf.zaltrcde01,
                    obj_ztrapf.zaltrcde02,
                    obj_ztrapf.zaltrcde03,
                    obj_ztrapf.zaltrcde04,
                    obj_ztrapf.zaltrcde05,
                    obj_ztrapf.zfinancflg,
                    obj_ztrapf.zclmrecd,
                    obj_ztrapf.zinhdsclm,
                    obj_ztrapf.zfinalbym
                                  ---,obj_ztrapf.zuwrejflg  ---MP9
                    ,
                    obj_ztrapf.zvioltyp,
                    obj_ztrapf.zstopbpj,
                    obj_ztrapf.zdfcncy,
                    obj_ztrapf.zmargnflg,
                    obj_ztrapf.docrcdte,
                    obj_ztrapf.hpropdte,
                    obj_ztrapf.ztrxstat,
                    obj_ztrapf.zstatresn,
                    obj_ztrapf.zaclsdat,
                    obj_ztrapf.apprdte,
                    obj_ztrapf.zpoldate,
                    obj_ztrapf.unique_number_01,
                    obj_ztrapf.altquoteno,
                    obj_ztrapf.zpdatatxdat,
                    obj_ztrapf.zpdatatxflg,
                    obj_ztrapf.zrefundam,
                    obj_ztrapf.zsurchrge,
                    obj_ztrapf.zsalplnchg,
                    obj_ztrapf.zpayinreq,
                    obj_ztrapf.usrprf,
                    obj_ztrapf.jobnm,
                    obj_ztrapf.datime,
                    obj_ztrapf.zcpmtddt,
                    obj_ztrapf.zshftpgp,
                    obj_ztrapf.zcstpbil,
                    obj_ztrapf.zcpmcpncde,
                    obj_ztrapf.zcpmplancd,
                    obj_ztrapf.zcpmbilamt,
                    obj_ztrapf.zbdpgpset,
                    obj_ztrapf.zdfblind,
                    obj_ztrapf.zrvtranno,
                    obj_ztrapf.zbltranno,
                    obj_ztrapf.statcode,
                    obj_ztrapf.zvldtrxind,
                    obj_ztrapf.zrcaltty
                );    ---MP8

            END IF;

            --- CLRRPF Migration ---

            SELECT
                COUNT(*)
            INTO v_clrrpf_cnt
            FROM
                clrrpf
            WHERE
                clntpfx = o_defaultvalues('COWNPFX')
                AND clntcoy = o_defaultvalues('COWNCOY')
                AND clntnum = obj_gchd.cownnum
                AND clrrrole = o_defaultvalues('CLRRROLE')
                AND forepfx = o_defaultvalues('CHDRPFX')
                AND forecoy = o_defaultvalues('CHDRCOY')
                AND RTRIM(forenum) = obj_gchd.mplnum;

            IF v_clrrpf_cnt = 0 THEN
                obj_clrrpf.clntpfx := o_defaultvalues('COWNPFX');
                obj_clrrpf.clntcoy := o_defaultvalues('COWNCOY');
                obj_clrrpf.clntnum := obj_gchd.cownnum;
                obj_clrrpf.clrrrole := o_defaultvalues('CLRRROLE');
                obj_clrrpf.forepfx := o_defaultvalues('CHDRPFX');
                obj_clrrpf.forecoy := o_defaultvalues('CHDRCOY');
                obj_clrrpf.forenum := obj_gchd.mplnum;
                obj_clrrpf.used2b := c_clrrpf_used2b;
                obj_clrrpf.usrprf := i_usrprf;
                obj_clrrpf.jobnm := i_schedulename;
                obj_clrrpf.datime := current_timestamp;

               ----MP4
                --SELECT
                --    seq_clrrpf.NEXTVAL
                --INTO v_pkvalue
                --FROM
                --    dual;
                v_pkvalue := seq_clrrpf.NEXTVAL; --PerfImprov
                obj_clrrpf.unique_number := v_pkvalue;
                INSERT INTO clrrpf VALUES obj_clrrpf;

               --- AUDIT_CLRRPF Migration ---
                v_pkvalue := seq_clrrpf.NEXTVAL; --PerfImprov
                obj_audit_clrrpf.unique_number := v_pkvalue;
                obj_audit_clrrpf.oldclntpfx := NULL;
                obj_audit_clrrpf.oldclntcoy := NULL;
                obj_audit_clrrpf.oldclntnum := obj_gchd.cownnum;
                obj_audit_clrrpf.oldclrrrole := NULL;
                obj_audit_clrrpf.oldforepfx := NULL;
                obj_audit_clrrpf.oldforecoy := NULL;
                obj_audit_clrrpf.oldforenum := NULL;
                obj_audit_clrrpf.oldused2b := NULL;
                obj_audit_clrrpf.oldusrprf := NULL;
                obj_audit_clrrpf.oldjobnm := NULL;
                obj_audit_clrrpf.olddatime := NULL;
                obj_audit_clrrpf.newclntpfx := o_defaultvalues('COWNPFX');
                obj_audit_clrrpf.newclntcoy := o_defaultvalues('COWNCOY');
                obj_audit_clrrpf.newclntnum := obj_gchd.cownnum;
                obj_audit_clrrpf.newclrrrole := o_defaultvalues('CLRRROLE');
                obj_audit_clrrpf.newforepfx := o_defaultvalues('CHDRPFX');
                obj_audit_clrrpf.newforecoy := o_defaultvalues('CHDRCOY');
                obj_audit_clrrpf.newforenum := obj_gchd.mplnum;
                obj_audit_clrrpf.newused2b := c_clrrpf_used2b;
                obj_audit_clrrpf.newusrprf := i_usrprf;
                obj_audit_clrrpf.newjobnm := i_schedulename;
                obj_audit_clrrpf.newdatime := current_timestamp;
                obj_audit_clrrpf.userid := i_usrprf;
                obj_audit_clrrpf.action := 'INSERT';
                obj_audit_clrrpf.tranno := 1;
                obj_audit_clrrpf.systemdate := current_timestamp;

               --- no need for next value
                INSERT INTO audit_clrrpf VALUES obj_audit_clrrpf;

            END IF;

            --- DMIGTITDMGMASPOL registration ---

            obj_dmigtitdmgmaspol.recidxmpmspol := obj_maspol.recidxmpmspol;
            obj_dmigtitdmgmaspol.chdrnum := obj_maspol.chdrnum;
            obj_dmigtitdmgmaspol.cnttype := obj_maspol.cnttype;
            obj_dmigtitdmgmaspol.statcode := obj_maspol.statcode;
            obj_dmigtitdmgmaspol.zagptnum := obj_maspol.zagptnum;
            obj_dmigtitdmgmaspol.ccdate := obj_maspol.ccdate;
            obj_dmigtitdmgmaspol.crdate := obj_maspol.crdate;
            obj_dmigtitdmgmaspol.rptfpst := obj_maspol.rptfpst;
            obj_dmigtitdmgmaspol.zendcde := obj_maspol.zendcde;
            obj_dmigtitdmgmaspol.rra2ig := obj_maspol.rra2ig;
            obj_dmigtitdmgmaspol.b8tjig := obj_maspol.b8tjig;
            obj_dmigtitdmgmaspol.zblnkpol := obj_maspol.zblnkpol;
            obj_dmigtitdmgmaspol.b8o9nb := obj_maspol.b8o9nb;
            obj_dmigtitdmgmaspol.b8gpst := obj_maspol.b8gpst;
            obj_dmigtitdmgmaspol.b8gost := obj_maspol.b8gost;
            obj_dmigtitdmgmaspol.znbaltpr := obj_maspol.znbaltpr;
            obj_dmigtitdmgmaspol.canceldt := obj_maspol.canceldt;
            obj_dmigtitdmgmaspol.effdate := obj_maspol.effdate;
            obj_dmigtitdmgmaspol.pndate := obj_maspol.pndate;
            obj_dmigtitdmgmaspol.occdate := obj_maspol.occdate;
            obj_dmigtitdmgmaspol.insendte := obj_maspol.insendte;
            obj_dmigtitdmgmaspol.zpenddt := obj_maspol.zpenddt;
            obj_dmigtitdmgmaspol.zccde := obj_maspol.zccde;
            obj_dmigtitdmgmaspol.zconsgnm := obj_maspol.zconsgnm;
            obj_dmigtitdmgmaspol.zbladcd := obj_maspol.zbladcd;
            obj_dmigtitdmgmaspol.clntnum := obj_maspol.clntnum;
            obj_dmigtitdmgmaspol.ind := 'I';
            INSERT INTO dmigtitdmgmaspol VALUES obj_dmigtitdmgmaspol;

        END IF;

    END LOOP;

    CLOSE maspol_cursor;
    ---NULL;
    dbms_output.put_line('Procedure execution time = '
                         ||(dbms_utility.get_time - v_timestart) / 100);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_exitcode := sqlcode;
        p_exittext := 'BQ9EC_MP01_MSTRPL : '
                      || dbms_utility.format_error_backtrace || obj_maspol.chdrnum
                      || ' - '
                      || sqlerrm;
        INSERT INTO Jd1dta.dmberpf (
            schedule_name,
            job_num,
            error_code,
            error_text,
            datime
        ) VALUES (
            i_schedulename,
            i_schedulenumber,
            p_exitcode,
            p_exittext,
            SYSDATE
        );

        COMMIT;
        RAISE;
END bq9ec_mp01_mstrpl;

/
