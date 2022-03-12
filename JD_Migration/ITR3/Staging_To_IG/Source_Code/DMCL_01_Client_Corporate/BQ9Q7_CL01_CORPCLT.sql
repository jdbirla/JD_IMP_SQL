CREATE OR REPLACE  PROCEDURE "Jd1dta"."BQ9Q7_CL01_CORPCLT" (
    i_schedulename     IN   VARCHAR2,
    i_schedulenumber   IN   VARCHAR2,
    i_zprvaldyn        IN   VARCHAR2,
    i_company          IN   VARCHAR2,
    i_usrprf      IN   VARCHAR2,
    i_branch         IN   VARCHAR2,
    i_transcode      IN   VARCHAR2,
    i_vrcmtermid     IN   VARCHAR2
)   AUTHID current_user AS
/***************************************************************************************************
  * Amenment History: CL01 Corporate Client
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CC1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * MAY11           RC                         CC2    Data Verification Changes
  * APRIL07            CC3   PA migration changes
  * SEP0918            CC4   set Space to SURNAME and GIVNAME
  * SEP0928            CC5   Modification for multiple Agencies per a single corporate client
  * MAR04    Vinay     CC6   Post Validation Level 4 Fixes
  * MAR18    MKS       CC7   Performance Improvement 
  * JUL03    JD        CC8   Fixed ZCLNPF update becuase of wrong update clntnum=1111 
  *****************************************************************************************************/

    v_timestart               NUMBER := dbms_utility.get_time;
    p_exitcode                NUMBER;
    p_exittext                VARCHAR2(4000);

  -- values from Staging DB
    isduplicate               NUMBER(2) DEFAULT 0;
    errorcount                NUMBER(1) DEFAULT 0;
    t_index                   NUMBER(1) DEFAULT 0;
    v_clntnum                 VARCHAR2(8 CHAR);
    p_roleflag                VARCHAR2(1 CHAR) DEFAULT 'Y';
    isdatevalid               VARCHAR2(20 CHAR);
    v_tranid                  VARCHAR2(14 CHAR);
    igspacevalue              VARCHAR2(1) DEFAULT ' ';
    v_effdate                 NUMBER(10) DEFAULT 0;
    v_initials                VARCHAR2(5 CHAR);
    isvalidname               VARCHAR2(10 CHAR);
    b_isnoerror               BOOLEAN := true;
    v_rinternet               VARCHAR2(20 CHAR);
    i_agntpfcount             NUMBER(5) DEFAULT 0;
    i_shicount                NUMBER(5) DEFAULT 0;
    b_update                  BOOLEAN := false;
    b_forSHI                  BOOLEAN := false;
    i_mplnumcnt               NUMBER(5) DEFAULT 0;
    v_clntkey_sv              VARCHAR2(12 CHAR);
    v_mplclntkey              VARCHAR2(12 CHAR);
    --- CC5
    v_agntclntkey             VARCHAR2(12 CHAR);
    i_agntpf                  NUMBER(5) DEFAULT 0;
    --- CC5
    i_gchdcnt                 NUMBER(5) DEFAULT 0;
    v_IGclntnum               VARCHAR2(8);
    i_zdclpfcnt               NUMBER(5) DEFAULT 0;
    i_pazdclpfcnt             NUMBER(5) DEFAULT 0;
    v_view_zdclpcnt           NUMBER(5) DEFAULT 0;
    v_pazdclpcnt              NUMBER(5) DEFAULT 0;
    v_IGclntnumcnt            NUMBER(5) DEFAULT 0;
    b_AGclient                BOOLEAN := false;
    i_audit_clntpfcnt         NUMBER(5) DEFAULT 0;
    i_zclnfcnt                NUMBER(5) DEFAULT 0;
    v_termid                  VARCHAR2(4 CHAR);
    i_clexpfcnt               NUMBER(5) DEFAULT 0;
    i_audit_clexpfcnt         NUMBER(5) DEFAULT 0;
    v_zkanasnmnor             VARCHAR2(60 CHAR);
    v_zkanagnmnor             VARCHAR2(60 CHAR);
    b_clntpf_exist            BOOLEAN := false;
      v_pkValue       CLEXPF.UNIQUE_NUMBER%type;
      v_SEQ_CLNTPF            CLNTPF.UNIQUE_NUMBER%type;
      v_SEQ_VERSIONPF         VERSIONPF.unique_number%type;
    ----anum_cursor1              types.ref_cursor;
    anrow                     anumpf%rowtype;
    tranno                    NUMBER(5, 0);
    v_unq_audit_clntpf        NUMBER(18, 0);
    v_unq_audit_clexpf        NUMBER(18, 0);
    indexitems                PLS_INTEGER;
  --  default values form TQ9Q9 Start
    c_zero                    CONSTANT NUMBER(1) := 0;
  --  v_tablecnt      NUMBER(1)          := 0;
    v_tablenametemp           VARCHAR2(10);
    v_tablename               VARCHAR2(10);
    v_space                   VARCHAR2(1 CHAR);
    v_y                       VARCHAR2(1 CHAR);
  --  default values form TQ9Q9 End
    c_prefix                  CONSTANT VARCHAR2(2) := GET_MIGRATION_PREFIX('CLCO',i_company);  --- 'CC'

    c_t3643                   CONSTANT VARCHAR2(5) := 'T3643';
    c_t3645                   CONSTANT VARCHAR2(5) := 'T3645';
    c_bq9q7                   CONSTANT VARCHAR2(5) := 'BQ9Q7';
    c_h036                    CONSTANT VARCHAR2(5) := 'H366';
    c_z099                    CONSTANT VARCHAR2(4) := 'RQO6';
    c_z016                    CONSTANT VARCHAR2(6) := 'RQLW';
    c_z073                    CONSTANT VARCHAR2(4) := 'RQNH';
    c_z017                    CONSTANT VARCHAR2(4) := 'RQLX';
    c_z013                    CONSTANT VARCHAR2(4) := 'RQLT';
    c_z019                    CONSTANT VARCHAR2(4) := 'RQLZ';
    c_z020                    CONSTANT VARCHAR2(4) := 'E091';
    c_z021                    CONSTANT VARCHAR2(4) := 'RQV4';
    c_z022                    CONSTANT VARCHAR2(4) := 'RFQY';
    c_z023                    CONSTANT VARCHAR2(5) := 'TR9GW';
    c_e299                    CONSTANT VARCHAR2(4) := 'E299';
    --- 20200331 start ---
    C_BQ9S5                   CONSTANT VARCHAR2(6 CHAR) := 'BQ9S5';
    C_VALID_1                 CONSTANT VARCHAR2(1 CHAR) := '1';
    C_ZAGPTPFX                CONSTANT VARCHAR2(2 CHAR) := 'AP';
    C_INSTYP_SHI              CONSTANT VARCHAR2(3 CHAR) := 'SHI';
    C_CHDRPFX                 CONSTANT VARCHAR2(2 CHAR) := 'CH';
    C_IT                     CONSTANT VARCHAR2(2 CHAR) := 'IT';
    C_SHI_AG                  CONSTANT VARCHAR2(5 CHAR) := 'SHIAG';
    C_SHI_MP                  CONSTANT VARCHAR2(5 CHAR) := 'SHIMP';
    C_DUP_AG                  CONSTANT VARCHAR2(7 CHAR) := 'INDUPAG';
    C_DUP_MP                  CONSTANT VARCHAR2(7 CHAR) := 'INDUPMP';
    C_NOCHG                   CONSTANT VARCHAR2(5 CHAR) := 'NOCHG';
    c_delimiter              CONSTANT CHAR(2) := '__';

    --- 20200331 end ---
  -- C_CLRROLE CONSTANT VARCHAR2(4) := 'AG';
  ---- constant start ------------
    c_clntpf_secuityno        CONSTANT CHAR(24) := '                        ';
    c_clntpf_payrollno        CONSTANT CHAR(10) := '          ';
    c_clntpf_salut            CONSTANT CHAR(6) := NULL;
    c_clntpf_initials         CONSTANT CHAR(2) := '  ';
    c_clntpf_cltsex           CONSTANT CHAR(1) := ' ';
    c_clntpf_cltaddr05        CONSTANT NCHAR(50) := '                                                  ';
    c_clntpf_addrtype         CONSTANT CHAR(1) := ' ';
    c_clntpf_occpcode         CONSTANT CHAR(4) := '    ';
    c_clntpf_statcode         CONSTANT CHAR(2) := '  ';
    c_clntpf_soe              CONSTANT CHAR(10) := '          ';
    c_clntpf_docno            CONSTANT CHAR(8) := '        ';
    c_clntpf_middl01          CONSTANT CHAR(20) := '                    ';
    c_clntpf_middl02          CONSTANT CHAR(20) := '                    ';
    c_clntpf_marryd           CONSTANT CHAR(1) := ' ';
    c_clntpf_tlxno            CONSTANT CHAR(16) := '                ';
    c_clntpf_tgram            CONSTANT CHAR(16) := '                ';
    c_clntpf_birthp           CONSTANT CHAR(20) := '                    ';
    c_clntpf_salutl           CONSTANT CHAR(8) := '        ';
    c_clntpf_roleflag01       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag02       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag03       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag04       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag05       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag06       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag07       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag08       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag09       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag10       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag11       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag12       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag13       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag14       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag15       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag16       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag17       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag18       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag19       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag20       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag21       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag22       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag23       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag24       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag25       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag26       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag27       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag28       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag29       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag30       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag31       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag32       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag33       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag34       CONSTANT CHAR(1) := ' ';
    c_clntpf_roleflag35       CONSTANT CHAR(1) := ' ';
    c_clntpf_stca             CONSTANT CHAR(3) := '   ';
    c_clntpf_stcb             CONSTANT CHAR(3) := '   ';
    c_clntpf_stcc             CONSTANT CHAR(3) := '   ';
    c_clntpf_stcd             CONSTANT CHAR(3) := '   ';
    c_clntpf_stce             CONSTANT CHAR(3) := '   ';
    c_clntpf_procflag         CONSTANT CHAR(2) := NULL;
    c_clntpf_termid           CONSTANT CHAR(4) := NULL;
    c_clntpf_user_t           CONSTANT NUMBER(6, 0) := NULL;
    c_clntpf_trdt             CONSTANT NUMBER(6, 0) := NULL;
    c_clntpf_trtm             CONSTANT NUMBER(6, 0) := NULL;
    c_clntpf_sndxcde          CONSTANT CHAR(4) := '    ';
    c_clntpf_natlty           CONSTANT CHAR(3) := '   ';
    c_clntpf_fao              CONSTANT CHAR(30) := '                              ';
    c_clntpf_cltind           CONSTANT CHAR(1) := 'C';
    c_clntpf_state            CONSTANT CHAR(4) := '    ';
   c_clntpf_ctryorig         CONSTANT CHAR(3) := '   ';
    c_clntpf_ethorig          CONSTANT CHAR(3) := '   ';
    c_clntpf_lgivname         CONSTANT VARCHAR2(60) := '                                                            ';
    c_clntpf_taxflag          CONSTANT CHAR(1) := NULL;
    c_clntpf_idtype           CONSTANT NCHAR(2) := '  ';
    c_clntpf_z1gstregn        CONSTANT NCHAR(16) := '                ';
    c_clntpf_kanjisurname     CONSTANT CHAR(60) := NULL;
    c_clntpf_kanjigivname     CONSTANT CHAR(60) := NULL;
    c_clntpf_kanjicltaddr01   CONSTANT CHAR(30) := NULL;
    c_clntpf_kanjicltaddr02   CONSTANT CHAR(30) := NULL;
    c_clntpf_kanjicltaddr03   CONSTANT CHAR(30) := NULL;
    c_clntpf_kanjicltaddr04   CONSTANT CHAR(30) := NULL;
    c_clntpf_kanjicltaddr05   CONSTANT CHAR(30) := NULL;
    c_clntpf_excep            CONSTANT CHAR(1) := ' ';
    c_clntpf_zkanagnm         CONSTANT VARCHAR2(60) := '                                                            ';
    c_clntpf_zkanaddr03       CONSTANT VARCHAR2(60) := '                                                            ';
    c_clntpf_zkanaddr04       CONSTANT VARCHAR2(60) := '                                                            ';
    c_clntpf_zkanaddr05       CONSTANT VARCHAR2(60) := '                                                            ';
    c_clntpf_zaddrcd          CONSTANT VARCHAR2(11) := '           ';
    c_clntpf_abusnum          CONSTANT NCHAR(11) := '           ';
    c_clntpf_branchid         CONSTANT NCHAR(3) := '   ';
    c_clntpf_telectrycode     CONSTANT VARCHAR2(3) := '   ';
    c_clntpf_telectrycode1    CONSTANT VARCHAR2(3) := '   ';
    c_clntpf_zdlind           CONSTANT CHAR(2) := '  ';
    c_clntpf_dirmktmtd        CONSTANT NCHAR(8) := '        ';
    c_clntpf_prefconmtd       CONSTANT NCHAR(8) := '        ';
    c_clntpf_zoccdsc          CONSTANT VARCHAR2(50) := NULL;
    c_clntpf_occpclas         CONSTANT VARCHAR2(2) := NULL;
    c_clntpf_zworkplce        CONSTANT VARCHAR2(25) := NULL;
    c_clntpf_clntstatecd      CONSTANT VARCHAR2(8) := '        ';
    c_clntpf_fundadminflag    CONSTANT VARCHAR2(1) := ' ';
    c_clntpf_province         CONSTANT NCHAR(15) := '               ';
    c_clntpf_seqno            CONSTANT NCHAR(8) := '        ';
    c_clntpf_cltaddr01        CONSTANT NCHAR(50) := '                                                  ';
    c_clntpf_cltaddr02        CONSTANT NCHAR(50) := '                                                  ';
    c_clntpf_cltaddr03        CONSTANT NCHAR(50) := '                                                  ';
    c_clntpf_cltaddr04        CONSTANT NCHAR(50) := '                                                  ';
    c_clntpf_cltpcode         CONSTANT CHAR(10) := '          ';
    c_clntpf_cltphone01       CONSTANT CHAR(16) := '                ';
    c_clntpf_cltphone02       CONSTANT CHAR(16) := '                ';
    c_clntpf_cltdob           CONSTANT NUMBER(8,0) := NULL;
    c_clntpf_faxno            CONSTANT CHAR(16) := '                ';
    C_CLNTPF_GIVNAME          CONSTANT CHAR(20) := '                    ';
    C_CLNTPF_ECACT            CONSTANT CHAR(4) := '    ';
    C_CLNTPF_STAFFNO          CONSTANT CHAR(6) := '      ';
    C_CLNTPF_ISPERMANENTID    CONSTANT CHAR(1) := ' ';
    --CC6
    C_CLNTPF_WORKUNIT         CONSTANT NCHAR(60) := '                                                            '; 
    C_CLNTPF_IDEXPIREDATE     CONSTANT NUMBER(8,0) := 0;
    --CC6
    c_clexpf_rdidtelno        CONSTANT CHAR(16) := '                ';
    c_clexpf_rmblphone        CONSTANT CHAR(16) := '                ';
    C_CLEXPF_RPAGER           CONSTANT CHAR(16) := '                ';
    c_clexpf_faxno            CONSTANT CHAR(16) := '                ';
    C_CLEXPF_RINTERNET        CONSTANT CHAR(50) := '                                                  ';
    c_clexpf_rtaxidnum        CONSTANT VARCHAR2(40) := '                    ';
    c_clexpf_rstaflag         CONSTANT CHAR(2) := '  ';
    c_clexpf_splindic         CONSTANT CHAR(2) := '  ';
    c_clexpf_zspecind         CONSTANT CHAR(2) := '  ';
    c_clexpf_oldidno          CONSTANT CHAR(24) := '                        ';
    c_clexpf_amlstatus        CONSTANT CHAR(2) := '  ';
    c_clexpf_othidno          CONSTANT NCHAR(24) := '                        ';
    c_clexpf_othidtype        CONSTANT NCHAR(2) := '  ';
    c_clexpf_zdmailto01       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_zdmailto02       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_zdmailcc01       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_zdmailcc02       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_zdmailcc03       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_zdmailcc04       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_zdmailcc05       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_zdmailcc06       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_zdmailcc07       CONSTANT CHAR(40) := '                                        ';
    c_clexpf_rinternet2       CONSTANT NCHAR(50) := '                                                  ';
    c_clexpf_telectrycode     CONSTANT VARCHAR2(3) := '   ';
    c_clexpf_zfathername      CONSTANT NCHAR(30) := '                              ';
    c_zclnf_cltsex            CONSTANT CHAR(1) := ' ';
    c_zclnf_cltdobflag        CONSTANT CHAR(1) := 'N';
    c_zclnf_lsurnameflag      CONSTANT CHAR(1) := 'Y';
    c_zclnf_lgivnameflag      CONSTANT CHAR(1) := 'N';
    c_zclnf_zkanasnmflag      CONSTANT CHAR(1) := 'N';
    c_zclnf_zkanagnmflag      CONSTANT CHAR(1) := 'N';
    c_zclnf_cltsexflag        CONSTANT CHAR(1) := 'N';
    c_zclnf_cltpcodeflag      CONSTANT CHAR(1) := 'N';
    c_zclnf_zkanaddr01flag    CONSTANT CHAR(1) := 'N';
    c_zclnf_zkanaddr02flag    CONSTANT CHAR(1) := 'N';
    c_zclnf_zkanaddr03flag    CONSTANT CHAR(1) := 'N';
    c_zclnf_zkanaddr04flag    CONSTANT CHAR(1) := 'N';
    c_zclnf_cltaddr01flag     CONSTANT CHAR(1) := 'N';
    c_zclnf_cltaddr02flag     CONSTANT CHAR(1) := 'N';
    c_zclnf_cltaddr03flag     CONSTANT CHAR(1) := 'N';
    c_zclnf_cltaddr04flag     CONSTANT CHAR(1) := 'N';
    c_zclnf_cltphone01flag    CONSTANT CHAR(1) := 'N';
    c_zclnf_cltphone02flag    CONSTANT CHAR(1) := 'N';
    c_zclnf_zworkplceflag     CONSTANT CHAR(1) := 'N';
    C_ZCLNF_OCCPCODEFLAG      CONSTANT CHAR(1) := 'N';
    C_ZCLNF_OCCPCLASFLAG      CONSTANT CHAR(1) := 'N';
    C_ZCLNF_ZOCCDSCFLAG       CONSTANT CHAR(1) := 'N';
    C_limit                   PLS_INTEGER := 1000; --CC7
    --CC6
    C_AUDIT_CLNT_OLDCLTTYP CONSTANT VARCHAR2(1) := 'C';
    C_AUDIT_CLNT_OLDCLTPHONE01  CONSTANT VARCHAR2(16) := '                ';
    C_AUDIT_CLNT_OLDCLTPHONE02  CONSTANT VARCHAR2(16) := '                ';
    C_AUDIT_CLNT_OLDSALUTL CONSTANT VARCHAR2(8) := '        ';
    C_AUDIT_CLNT_OLDGIVNAME CONSTANT VARCHAR2(20) := '                    ';
    C_AUDIT_CLNT_OLDCTRYCODE CONSTANT VARCHAR2(3) := 'JPN';
    C_AUDIT_CLNT_OLDDIRMAIL CONSTANT VARCHAR2(1) := ' ';
    C_AUDIT_CLNT_OLDCLTDOB CONSTANT VARCHAR2(8) := '99999999';
    C_AUDIT_CLNT_OLDMAILING CONSTANT VARCHAR2(1) := ' ';
    C_AUDIT_CLNTPF_OLDTRTM CONSTANT NUMBER(6,0) := NULL;
    C_AUDIT_CLNTPF_OLDTRDT CONSTANT NUMBER(6,0) := NULL;
    C_ZCLNPF_ZOCCDSC CONSTANT VARCHAR2(1) := ' ';
    C_ZCLNPF_OCCPCLAS CONSTANT VARCHAR2(1) := ' ';
    C_ZCLNPF_CLTADDR03 CONSTANT VARCHAR2(50) := '                                                  ';
    C_ZCLNPF_ZWORKPLCE CONSTANT VARCHAR2(1) := ' ';
    --CC6
---- constant end ----------------

  --------------Common Function Start---------
    o_defaultvalues           PKG_DM_COMMON_OPERATIONS.defaultvaluesmap;
    ---- 20200331 start ---
    o_defaultvalues_BQ9S5     PKG_DM_COMMON_OPERATIONS.defaultvaluesmap;
    ---- 20200331 start ---    
    itemexist                 PKG_DM_COMMON_OPERATIONS.itemschec;
    o_errortext               PKG_DM_COMMON_OPERATIONS.errordesc;
    i_zdoe_info               PKG_DM_COMMON_OPERATIONS.obj_zdoe;
  ---------------Common function end-----------
  ------IG table obj start---
    obj_clntpf                clntpf%rowtype;
  -- obj_auditClntpf AUDIT_CLNTPF%rowtype;
    obj_clexpf                clexpf%rowtype;
  --obj_clrrpf CLRRPF%rowtype;
    obj_zclnf                 view_zclnpf%rowtype;
    ---obj_zclnf                    zclnpf%rowtype;
  -- SIT Fix
    obj_versionpf             versionpf%rowtype;
   -- obj_audit_clntpf          audit_clntpf%rowtype;
   -- obj_audit_clnt            audit_clnt%rowtype;
   -- obj_audit_clexpf           audit_clexpf%rowtype;
    --obj_dmigtitdmgclntcorp    dmigtitdmgclntcorp%rowtype;

  ---- 20191217 START ------
    obj_zdclpf                view_zdclpf%rowtype;
    obj_pazdclpf              view_pazdclpf%rowtype;
  ---- 20191217 END  ------  

  ------IG table obj end ---
    CURSOR corporateclient_cursor IS
   SELECT
        *
    FROM
        titdmgclntcorp@dmstagedblink
       ORDER BY clntkey ASC, agntnum DESC;


    obj_client                corporateclient_cursor%rowtype;
    TYPE t_corpclnt_list IS TABLE OF corporateclient_cursor%rowtype; --CC7
    corpclnt_list t_corpclnt_list; --CC7
  --error cont start
    t_index                   PLS_INTEGER;
    TYPE ercode_tab IS
        TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
    t_ercode                  ercode_tab;
    TYPE errorfield_tab IS
        TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
    t_errorfield              errorfield_tab;
    TYPE errormsg_tab IS
        TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
    t_errormsg                errormsg_tab;
    TYPE errorfieldvalue_tab IS
        TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
    t_errorfieldval           errorfieldvalue_tab;
    TYPE i_errorprogram_tab IS
        TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
    t_errorprogram            i_errorprogram_tab;

    ---TYPE mplnum_tab IS
    ---    TABLE OF VARCHAR(8) INDEX BY VARCHAR2(20);
    ---t_mplnum                mplnum_tab;
    t_mplnum                       PKG_DM_CORPORATE.mplnum_tab;
    i_clntkey_mplnum               VARCHAR2(20);

    ---- CC5
    t_agntnum                       PKG_DM_CORPORATE.agntnum_tab;
    i_clntkey_agntnum               VARCHAR2(20);
    ---- CC5

    TYPE obj_gchd IS RECORD(
      i_cnttype   gchd.cnttype%type,
      i_cownnum   gchd.cownnum%type
     );
    TYPE v_array_gchd IS TABLE OF obj_gchd;
    gchdflist v_array_gchd;

    TYPE obj_agntpf IS RECORD(
      i_clntnum   agntpf.clntnum%type
     );
    TYPE v_array_agntpf IS TABLE OF obj_agntpf;
    agntpflist v_array_agntpf;    

    TYPE obj_view_zdclpf IS RECORD(
      i_zigvalue   view_zdclpf.zigvalue%type
     );
    TYPE v_array_view_zdclpf IS TABLE OF obj_view_zdclpf;
    view_zdclpflist v_array_view_zdclpf;    

    TYPE type_pazdclpf IS RECORD(
      i_zigvalue   pazdclpf.zigvalue%type
     );
    TYPE v_array_pazdclpf IS TABLE OF type_pazdclpf;
    pazdclpflist v_array_pazdclpf;

    ---TYPE instype_tab IS
    ---    TABLE OF VARCHAR(3) INDEX BY VARCHAR2(3);
    ---t_instypeSHI               instype_tab;
    t_instypeSHI               PKG_DM_CORPORATE.instype_tab;
    ---i_instypeSHI               VARCHAR2(3);

    TYPE v_array_audit_clntpf IS TABLE OF audit_clntpf%rowtype;
    audit_clntpflist v_array_audit_clntpf;

    TYPE v_array_audit_clnt IS TABLE OF audit_clnt%rowtype;
    audit_clntlist v_array_audit_clnt;

    TYPE v_array_clntpf IS TABLE OF clntpf%rowtype;
    clntpflist v_array_clntpf;


  --error cont end
BEGIN
  ---------Common Function------------
--  PKG_DM_COMMON_OPERATIONS.getdefaultvalues(i_itemname      => C_BQ9Q7,
--                                            i_company       => company,
--                                            o_defaultvalues => o_defaultvalues);
    PKG_DM_COMMON_OPERATIONS.getdefval(i_module_name => c_bq9q7, o_defaultvalues => o_defaultvalues);
    PKG_DM_COMMON_OPERATIONS.getdefval(i_module_name => C_BQ9S5, o_defaultvalues => o_defaultvalues_BQ9S5);
    PKG_DM_COMMON_OPERATIONS.checkitemexist(i_module_name => 'DMCL', itemexist => itemexist);
    PKG_DM_COMMON_OPERATIONS.geterrordesc(i_module_name => 'DMCL', o_errortext => o_errortext);

    PKG_DM_CORPORATE.getmasterpolicy( itemexist => t_mplnum );
    PKG_DM_CORPORATE.getinstype( i_itempfx => C_IT , i_company => i_company ,itemexist => t_instypeSHI );

    ----CC5
    PKG_DM_CORPORATE.getagent( itemexist => t_agntnum ); 
    ----CC5

    v_tablenametemp := 'ZDOE'
                       || trim(c_prefix)
                       || lpad(trim(i_schedulenumber), 4, '0');

    v_tablename := trim(v_tablenametemp);
    PKG_DM_COMMON_OPERATIONS.createzdoepf(i_tablename => v_tablename);
    v_tranid := concat('QPAD', TO_CHAR(SYSDATE, 'YYMMDDHHMM'));
    SELECT
        DECODE(o_defaultvalues('CAPITAL'), '', 0, ' ', 0, o_defaultvalues('CAPITAL'))
    INTO
        o_defaultvalues('CAPITAL')
    FROM
        dual;

    v_clntkey_sv := '';

   -- DELETE FROM DMIGTITDMGCLNTCORP;

    OPEN corporateclient_cursor;
      LOOP --CC7
      FETCH corporateclient_cursor BULK COLLECT INTO corpclnt_list LIMIT C_limit; --CC7
      << skiprecord >> 
        FOR i IN 1..corpclnt_list.COUNT LOOP

        obj_client := corpclnt_list(i);
      --  FETCH corporateclient_cursor INTO obj_client;
      --  EXIT WHEN corporateclient_cursor%notfound;
    -- Set variable values from staging db to be validated
    --  v_tablecnt := 1;
    -- Initialize error  variables start
    /*t_index     := 0; */
        t_ercode(1) := ' ';
        t_ercode(2) := ' ';
        t_ercode(3) := ' ';
        t_ercode(4) := ' ';
        t_ercode(5) := ' ';
        i_zdoe_info := NULL;
    --   i_zdoe_info.i_tablecnt   := v_tablecnt;
        i_zdoe_info.i_zfilename := 'TITDMGCLNTCORP';
        i_zdoe_info.i_prefix := c_prefix;
        i_zdoe_info.i_scheduleno := i_schedulenumber;
        i_zdoe_info.i_tablename := v_tablename;
        i_zdoe_info.i_refkey := trim(obj_client.clntkey);
    -- Initialize error  variables end
    -- reset counter
    --t_index     := 0;
        errorcount := 0;
        v_space := ' ';
        v_y := 'Y';
        b_isnoerror := true;
        v_effdate := 19010101;
      --  v_initials := substr(o_defaultvalues('LGIVNAME'), 1, 1);
    --IF (i_zprvaldyn = 'Y') THEN
    -- validate for duplicate record in ZDCLPF
        IF TRIM(obj_client.clntkey) IS NULL THEN
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h036;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h036);
            i_zdoe_info.i_errorfield01 := 'Refnum';
            i_zdoe_info.i_fieldvalue01 := trim(obj_client.clntkey);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            PKG_DM_COMMON_OPERATIONS.insertintozdoe(i_zdoe_info => i_zdoe_info);
            v_clntkey_sv := TRIM(obj_client.clntkey);
            GOTO createPostvalidation;
        -- when agenynumber and master policy number are empty, it's going to be error
        ELSIF TRIM(obj_client.agntnum) IS NULL and TRIM(obj_client.mplnum) IS NULL THEN
          --  DBMS_Output.PUT_LINE('(1)[ERROR:agenynumber and master policy number are empty] obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
            b_isnoerror := false;
            i_zdoe_info.i_indic := 'E';
            i_zdoe_info.i_error01 := c_h036;
            i_zdoe_info.i_errormsg01 := o_errortext(c_h036);
            i_zdoe_info.i_errorfield01 := 'agnt,mpl';
            i_zdoe_info.i_fieldvalue01 := trim(obj_client.clntkey);
            i_zdoe_info.i_errorprogram01 := i_schedulename;
            PKG_DM_COMMON_OPERATIONS.insertintozdoe(i_zdoe_info => i_zdoe_info);
            v_clntkey_sv := TRIM(obj_client.clntkey);
            GOTO createPostvalidation;
        ---ELSE
            ---In PA migration, multiple records having the same clntkey, agntnm, mplnm are acceptable so this validation check is to be commented out.
            ---SELECT
            ---    COUNT(*)
            ---INTO isduplicate
            ---FROM
            ---    zdclpf
            ---WHERE
            ---    rtrim(zentity) = TRIM(obj_client.clntkey)
            ---    AND prefix = c_prefix;
            ---
            ---IF isduplicate > 0 THEN
            ---    b_isnoerror := false;
            ---    i_zdoe_info.i_indic := 'E';
            ---    i_zdoe_info.i_error01 := c_z099;
            ---    i_zdoe_info.i_errormsg01 := o_errortext(c_z099);
            ---    i_zdoe_info.i_errorfield01 := 'Refnum';
            ---    i_zdoe_info.i_fieldvalue01 := trim(obj_client.clntkey);
            ---    i_zdoe_info.i_errorprogram01 := i_schedulename;
            ---    PKG_DM_COMMON_OPERATIONS.insertintozdoe(i_zdoe_info => i_zdoe_info);
            ---    v_clntkey_sv := TRIM(obj_client.clntkey);
            ---    GOTO createPostvalidation;
            ---END IF;

        END IF;
    -- validate for duplicate record in ZDCLPF
    -- validate CLTADDR01

        IF TRIM(obj_client.cltaddr01) IS NULL THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_z016;
            t_errorfield(errorcount) := 'cltaddr01';
            t_errormsg(errorcount) := o_errortext(c_z016);
            t_errorfieldval(errorcount) := trim(obj_client.cltaddr01);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;

        IF TRIM(obj_client.cltaddr02) IS NULL THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_z016;
            t_errorfield(errorcount) := 'cltaddr02';
            t_errormsg(errorcount) := o_errortext(c_z016);
            t_errorfieldval(errorcount) := trim(obj_client.cltaddr02);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;

        IF TRIM(obj_client.cltpcode) IS NULL THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_e299;
            t_errorfield(errorcount) := 'CLTPCODE';
            t_errormsg(errorcount) := o_errortext(c_e299);
            t_errorfieldval(errorcount) := trim(obj_client.cltpcode);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- validate zkanaddr01

        IF TRIM(obj_client.zkanaddr01) IS NULL THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_z017;
            t_errorfield(errorcount) := 'zkanaddr01';
            t_errormsg(errorcount) := o_errortext(c_z017);
            t_errorfieldval(errorcount) := trim(obj_client.zkanaddr01);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- validate zkanaddr01
    -- validate zkanaddr02

        IF TRIM(obj_client.zkanaddr02) IS NULL THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_z017;
            t_errorfield(errorcount) := 'zkanaddr02';
            t_errormsg(errorcount) := o_errortext(c_z017);
            t_errorfieldval(errorcount) := trim(obj_client.zkanaddr02);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- validate zkanaddr02
    -- validate p_cltdobx

        isdatevalid := validate_date(obj_client.cltdobx);
        IF isdatevalid <> 'OK' THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_z013;
            t_errorfield(errorcount) := 'cltdobx';
            t_errormsg(errorcount) := o_errortext(c_z013);
            t_errorfieldval(errorcount) := trim(obj_client.cltdobx);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- validate p_cltdobx
    -- validate CLTSTAT

        IF NOT ( itemexist.EXISTS(trim(c_t3643)
                                  || trim(o_defaultvalues('CLTSTAT'))
                                  || 9) ) THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_z019;
            t_errorfield(errorcount) := 'cltstat';
            t_errormsg(errorcount) := o_errortext(c_z019);
            t_errorfieldval(errorcount) := trim(o_defaultvalues('CLTSTAT'));
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
    -- validate CLTSTAT
    -- validate lsurname

        IF TRIM(obj_client.lsurname) IS NULL THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_z020;
            t_errorfield(errorcount) := 'lsurname';
            t_errormsg(errorcount) := o_errortext(c_z020);
            t_errorfieldval(errorcount) := trim(obj_client.lsurname);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;

        IF TRIM(obj_client.zkanasnm) IS NULL THEN
            b_isnoerror := false;
            errorcount := errorcount + 1;
            t_ercode(errorcount) := c_z021;
            t_errorfield(errorcount) := 'zkanasnm';
            t_errormsg(errorcount) := o_errortext(c_z021);
            t_errorfieldval(errorcount) := trim(obj_client.zkanasnm);
            t_errorprogram(errorcount) := i_schedulename;
            IF errorcount >= 5 THEN
                GOTO insertzdoe;
            END IF;
        END IF;
----- valid chechk on SHI Corporate Client
        --- In the case of agntnum exists in Staging table
        IF TRIM(obj_client.agntnum) IS NOT NULL OR  --- (1) Agent Number is not empty or
           (b_AGclient = true AND TRIM(obj_client.clntkey) = TRIM(v_clntkey_sv)) THEN  -- Assuming this condition assumes the first record of multiple records having the same clntkey had Agent Number and the current record having the same clntkey has only Master Policy Number.
           b_AGclient := true;
           IF TRIM(v_clntkey_sv) IS NULL OR TRIM(obj_client.clntkey) <> TRIM(v_clntkey_sv) THEN ---(2)
              b_update := false;
              v_IGclntnum := NULL;
              v_clntkey_sv := TRIM(obj_client.clntkey);

              ---- To see if agntnum exists in IG and get clntnum
              v_IGclntnum := NULL;

              ---- CC5
              b_forSHI := false;
              i_agntpf := 0;
              i_clntkey_agntnum := t_agntnum.FIRST;
              WHILE i_clntkey_agntnum IS NOT NULL LOOP  --- loop agent hash map (t_agntnum)

                    v_agntclntkey := substr(i_clntkey_agntnum,1,instr(i_clntkey_agntnum,c_delimiter,1)-1);
                    --- If a current client number in input file equals to a client number in the agent array from staging.
                    IF TRIM(v_agntclntkey) = TRIM(obj_client.clntkey) THEN  ---(5)
                       SELECT
                            clntnum
                       BULK COLLECT
                       INTO
                            agntpflist
                       FROM
                             agntpf
                       WHERE
                             agntpfx =  o_defaultvalues_BQ9S5('AGNTPFX')
                         AND TRIM(agntnum) =  TRIM(t_agntnum(i_clntkey_agntnum))
                         AND agntcoy = i_company
                         AND validflag = C_VALID_1
                       GROUP BY
                             clntnum
                       ;

                       --- 代理店番号が登録されているかをチェック、存在すれば１件のみ
                       FOR indexitems IN 1 .. agntpflist.COUNT LOOP
                           v_IGclntnum := TRIM(agntpflist(indexitems).i_clntnum);
                           i_agntpf := i_agntpf + 1;
                       END LOOP; 

                       IF v_IGclntnum IS NOT NULL THEN  ---(3) 代理店番号が登録されていれば SHIの代理店かをチェックする

                           SELECT
                                 COUNT(*)
                           INTO
                                 i_shicount
                           FROM
                                 zaacpf
                           WHERE
                                 AGNTPFX  = o_defaultvalues_BQ9S5('AGNTPFX')
                             AND AGNTCOY  = i_company
                             ---AND TRIM(GAGNTSEL) = TRIM(obj_client.agntnum)
                             AND TRIM(GAGNTSEL) = TRIM(t_agntnum(i_clntkey_agntnum))
                             AND ZAGPTPFX = C_ZAGPTPFX
                             AND ZAGPTCOY = i_company
                             AND validflag = C_VALID_1
                             AND (
                                  TRIM(ZINSTYP01) = C_INSTYP_SHI
                                  OR
                                  TRIM(ZINSTYP02) = C_INSTYP_SHI
                                  OR
                                  TRIM(ZINSTYP03) = C_INSTYP_SHI
                                  OR
                                  TRIM(ZINSTYP04) = C_INSTYP_SHI
                                  OR
                                  TRIM(ZINSTYP05) = C_INSTYP_SHI
                                  )
                             ;

                           IF i_shicount > 0 THEN   --- Client exists as Agency for SHI  will be skipped  (4) 
                              b_forSHI := true;
                           END IF;   ---(4)
                           --dbms_output.put_line('CLNT :' || TRIM(obj_client.clntkey) || ', agent; ' || TRIM(t_agntnum(i_clntkey_agntnum)) || ',IG CNT : ' || v_IGclntnum || ', shi cnt : ' || i_shicount);
                        END IF;   ---(3);                                  
                    END IF;  ---(5)

                   i_clntkey_agntnum := t_agntnum.NEXT(i_clntkey_agntnum);  
              END LOOP;

              IF b_forSHI = true THEN --- Master Policy Owner existing in IG for SHI will be skipped (12)

                 b_isnoerror := false;
                 errorcount := errorcount + 1;
                 t_ercode(errorcount) := c_z022;
                 t_errorfield(errorcount) := C_SHI_AG;
                 t_errormsg(errorcount) := o_errortext(c_z022);
                 t_errorfieldval(errorcount) := trim(obj_client.clntkey);
                 t_errorprogram(errorcount) := i_schedulename;
                 IF errorcount >= 5 THEN
                     GOTO insertzdoe;
                 END IF;
              ELSE  ---(12)
                 IF i_agntpf > 0 THEN 
                    b_update := true; ------Agency existing in IG for PA will be updated
                 ELSE
                    b_update := false;  --- Master Policy Owner not existing in IG will be inserted
                 END IF;
              END IF;  ---(12)                           
           ELSE   --- Client Number is duplicated in the case of agency will be skipped (2)
               dbms_output.put_line('dup; ' || TRIM(obj_client.clntkey));
               b_isnoerror := false;
               errorcount := errorcount + 1;
               t_ercode(errorcount) := c_z022;
               t_errorfield(errorcount) := C_DUP_AG;
               t_errormsg(errorcount) := o_errortext(c_z022);
               t_errorfieldval(errorcount) := trim(obj_client.clntkey);
               t_errorprogram(errorcount) := i_schedulename;
               IF errorcount >= 5 THEN
                  GOTO insertzdoe;
                END IF;
           END IF;  ---(2)
         ---- CC5
         --- In the case of master policy number exists
        ELSE  -- (1)
           IF TRIM(obj_client.mplnum) IS NOT NULL THEN  -- (10)
              b_AGclient := false;
              IF TRIM(v_clntkey_sv) IS NULL OR TRIM(obj_client.clntkey) <> TRIM(v_clntkey_sv) THEN  --- (11)
                 v_IGclntnum := NULL;
                 b_update := false;
                 b_forSHI := false;
                 i_gchdcnt := 0;
                 i_clntkey_mplnum := t_mplnum.FIRST;
                 WHILE i_clntkey_mplnum IS NOT NULL LOOP  --- loop master policy hash map (t_mplnum)

                       v_mplclntkey := substr(i_clntkey_mplnum,1,instr(i_clntkey_mplnum,c_delimiter,1)-1);
                       --- If a current client number in input file equals to a client number in the master policy array
                       IF TRIM(v_mplclntkey) = TRIM(obj_client.clntkey) THEN
                           ---- loop process to identify if a cnttype in GCHD(SHIcnttype_cursor) is for SHI by referring to instype array
                          SELECT 
                                 cnttype
                                ,cownnum
                          BULK COLLECT
                          INTO
                                gchdflist
                          FROM
                                 gchd
                          WHERE
                               CHDRPFX = TRIM(C_CHDRPFX)
                           AND MPLCOY  = i_company
                           AND MPLNUM  = TRIM(t_mplnum(i_clntkey_mplnum))
                           AND CHDRNUM = TRIM(t_mplnum(i_clntkey_mplnum))
                           AND validflag     = C_VALID_1
                          GROUP BY
                               cnttype
                              ,COWNNUM
                          ;
                          ---FOR indexitems IN gchdflist.first .. gchdflist.last LOOP
                          FOR indexitems IN 1 .. gchdflist.COUNT LOOP

                                v_IGclntnum := TRIM(gchdflist(indexitems).i_cownnum);
                                i_gchdcnt := i_gchdcnt + 1;

                                IF t_instypeSHI.EXISTS(gchdflist(indexitems).i_cnttype) THEN
                                   b_forSHI := true;
                                END IF;

                          END LOOP;    
                       END IF;

                       i_clntkey_mplnum := t_mplnum.NEXT(i_clntkey_mplnum);  
                 END LOOP;
                 v_clntkey_sv := TRIM(obj_client.clntkey);

                 IF b_forSHI = true THEN --- Master Policy Owner existing in IG for SHI will be skipped (12)
                    b_isnoerror := false;
                    errorcount := errorcount + 1;
                    t_ercode(errorcount) := c_z022;      
                    t_errorfield(errorcount) := C_SHI_MP;
                    t_errormsg(errorcount) := o_errortext(c_z022);
                    t_errorfieldval(errorcount) := trim(obj_client.clntkey);
                    t_errorprogram(errorcount) := i_schedulename;
                    IF errorcount >= 5 THEN
                       GOTO insertzdoe;
                    END IF;
                 ELSE  ---(12)
                    IF i_gchdcnt > 0 THEN 
                       b_update := true; ------ Master Policy Owner existing in IG for PA will be updated
                    ELSE
                       b_update := false;  --- Master Policy Owner not existing in IG will be inserted
                    END IF;
                 END IF;  ---(12)
              ELSE   --- Client Number is duplicated in the case of master policy number will be skipped    (11)
                  b_isnoerror := false;
                  errorcount := errorcount + 1;
                  t_ercode(errorcount) := c_z022;
                  t_errorfield(errorcount) := C_DUP_MP;
                  t_errormsg(errorcount) := o_errortext(c_z022);
                  t_errorfieldval(errorcount) := trim(obj_client.clntkey);
                  t_errorprogram(errorcount) := i_schedulename;
                  IF errorcount >= 5 THEN
                     GOTO insertzdoe;
                  END IF;
              END IF;   --- (11)
           END IF;  -- (10)
        END IF;  -- (1)

         ---- put trace log regarding skip, update or insert
        /*
        IF b_isnoerror = false THEN
           DBMS_Output.PUT_LINE('(2)[SKIP] IG ClientNum :' || v_IGclntnum || ' , obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
        ELSIF b_update = true THEN
           DBMS_Output.PUT_LINE('(3)[UPDATE] IG ClientNum :' || v_IGclntnum || ' , obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
        ELSE
           DBMS_Output.PUT_LINE('(4)[Insert] IG ClientNum :' || v_IGclntnum || ' , obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
        END IF;
        */


        << insertzdoe >> IF ( b_isnoerror = false ) THEN
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

            PKG_DM_COMMON_OPERATIONS.insertintozdoe(i_zdoe_info => i_zdoe_info);
            v_clntkey_sv := TRIM(obj_client.clntkey);
            GOTO createPostvalidation;

        END IF;

        IF ( b_isnoerror = true ) THEN

            --- ↓↓↓↓PA Insert対象の顧客(AgentNumがIGに存在しない、または MasterPolicyNumberがIGに存在しない、つまりロールがない）と判断され、且つview_zdclpfにPJ顧客番号があれば既にIG登録済みと判断して、UPDATEに切り替える
            --- (1)SHI移行時に移行された顧客で、且つ非稼働である(AgentでもMaster Policy Ownerでもない)顧客
            --- (2)PA移行時に移行された顧客で、差分データ移行時に同一の顧客データが連携された場合
            IF b_update = false THEN 
               SELECT 
                     zigvalue
               BULK COLLECT
               INTO
                    view_zdclpflist
               FROM
                     view_zdclpf
               WHERE
                    TRIM(ZENTITY) = TRIM(obj_client.clntkey)
                AND PREFIX = c_prefix
               ;
               FOR indexitems IN 1 .. view_zdclpflist.COUNT LOOP
                    v_clntnum := TRIM(view_zdclpflist(indexitems).i_zigvalue);
                    b_update := true;
                    v_IGclntnum := v_clntnum;
                    ---DBMS_Output.PUT_LINE('(5)[Delta data for new PA Corporate Client already populated in SHI nigration is to change from the insertion to update.] IG ClientNum :' || v_clntnum || ', obj_client.clntkey:' || obj_client.clntkey);
               END LOOP; 

               IF b_update = false THEN

                  SELECT 
                        zigvalue
                  BULK COLLECT
                  INTO
                       pazdclpflist
                  FROM
                        pazdclpf
                  WHERE
                       TRIM(ZENTITY) = TRIM(obj_client.clntkey)
                   AND PREFIX = c_prefix
                  ;
                  FOR indexitems IN 1 .. pazdclpflist.COUNT LOOP
                       v_clntnum := TRIM(pazdclpflist(indexitems).i_zigvalue);
                       b_update := true;
                       v_IGclntnum := v_clntnum;
                       ---DBMS_Output.PUT_LINE('(5)[Delta data for new PA Corporate Client already populated in PA nigration is to change from the insertion to update.] IG ClientNum :' || v_clntnum || ', obj_client.clntkey:' || obj_client.clntkey);
                  END LOOP;                
               END IF;
            END IF;
            --- ↑↑↑↑PA Insert対象の顧客(AgentNumがIGに存在しない、または MasterPolicyNumberがIGに存在しない）と判断され、且つview_zdclpfにPJ顧客番号があれば既にIG登録済みと判断して、UPDATEに切り替える

            --- UPDATEと判定された場合に、値に変更がなければ読み飛ばし
            IF b_update = true THEN

                SELECT
                       *
                BULK COLLECT
                INTO
                     clntpflist
                FROM
                     clntpf
                WHERE
                      TRIM(clntnum) = v_IGclntnum
                      AND clntpfx = o_defaultvalues('CLNTPFX')
                      AND clntcoy =o_defaultvalues('CLNTCOY')
                      AND cltind = o_defaultvalues('CLTIND')
                      AND clttype = o_defaultvalues('CLTTYPE')
                      ----AND validflag = C_VALID_1
                ;

                b_clntpf_exist := false;
                FOR indexitems IN 1 .. clntpflist.COUNT LOOP
                   b_clntpf_exist := true;
                   IF (TRIM(obj_client.lsurname) = TRIM(clntpflist(indexitems).lsurname) OR (TRIM(obj_client.lsurname) IS NULL AND  TRIM(clntpflist(indexitems).lsurname) IS NULL)) AND
                      (TRIM(obj_client.cltaddr01)  = TRIM(clntpflist(indexitems).cltaddr01 ) OR (TRIM(obj_client.cltaddr01) IS NULL AND  TRIM(clntpflist(indexitems).cltaddr01) IS NULL)) AND
                      (TRIM(obj_client.cltaddr02)  = TRIM(clntpflist(indexitems).cltaddr02 ) OR (TRIM(obj_client.cltaddr02) IS NULL AND  TRIM(clntpflist(indexitems).cltaddr02) IS NULL)) AND
                      (TRIM(obj_client.cltaddr03)  = TRIM(clntpflist(indexitems).cltaddr03 ) OR (TRIM(obj_client.cltaddr03) IS NULL AND  TRIM(clntpflist(indexitems).cltaddr03) IS NULL)) AND
                      (TRIM(obj_client.cltaddr04)  = TRIM(clntpflist(indexitems).cltaddr04) OR (TRIM(obj_client.cltaddr04) IS NULL AND  TRIM(clntpflist(indexitems).cltaddr04) IS NULL)) AND
                      (TRIM(obj_client.cltpcode)   = TRIM(clntpflist(indexitems).cltpcode) OR (TRIM(obj_client.cltpcode) IS NULL AND  TRIM(clntpflist(indexitems).cltpcode) IS NULL)) AND
                      (TRIM(obj_client.cltphone01) = TRIM(clntpflist(indexitems).cltphone01) OR (TRIM(obj_client.cltphone01) IS NULL AND  TRIM(clntpflist(indexitems).cltphone01) IS NULL)) AND
                      (TRIM(obj_client.cltphone02) = TRIM(clntpflist(indexitems).cltphone02) OR (TRIM(obj_client.cltphone02) IS NULL AND  TRIM(clntpflist(indexitems).cltphone02) IS NULL)) AND
                      (TRIM(obj_client.cltdobx)     = TRIM(clntpflist(indexitems).cltdob) OR (TRIM(obj_client.cltdobx) IS NULL AND  TRIM(clntpflist(indexitems).cltdob) IS NULL)) AND
                      (TRIM(obj_client.faxno)      = TRIM(clntpflist(indexitems).faxno) OR (TRIM(obj_client.faxno) IS NULL AND  TRIM(clntpflist(indexitems).faxno) IS NULL)) AND
                      (TRIM(obj_client.zkanasnm)   = TRIM(clntpflist(indexitems).zkanasnm) OR (TRIM(obj_client.zkanasnm) IS NULL AND  TRIM(clntpflist(indexitems).zkanasnm) IS NULL)) AND
                      (TRIM(obj_client.zkanaddr01) = TRIM(clntpflist(indexitems).zkanaddr01) OR (TRIM(obj_client.zkanaddr01) IS NULL AND  TRIM(clntpflist(indexitems).zkanaddr01) IS NULL)) AND
                      (TRIM(obj_client.zkanaddr02) = TRIM(clntpflist(indexitems).zkanaddr02) OR (TRIM(obj_client.zkanaddr02) IS NULL AND  TRIM(clntpflist(indexitems).zkanaddr02) IS NULL)) AND
                      (TRIM(obj_client.zkanaddr03) = TRIM(clntpflist(indexitems).zkanaddr03) OR (TRIM(obj_client.zkanaddr03) IS NULL AND  TRIM(clntpflist(indexitems).zkanaddr03) IS NULL)) AND
                      (TRIM(obj_client.zkanaddr04) = TRIM(clntpflist(indexitems).zkanaddr04) OR (TRIM(obj_client.zkanaddr04) IS NULL AND  TRIM(clntpflist(indexitems).zkanaddr04) IS NULL)) THEN

                      b_isnoerror := false;
                      i_zdoe_info.i_indic := 'E';
                      i_zdoe_info.i_error01 := c_z022;
                      i_zdoe_info.i_errormsg01 := o_errortext(c_z022);
                     i_zdoe_info.i_errorfield01 := C_NOCHG;
                      i_zdoe_info.i_fieldvalue01 := trim(obj_client.clntkey);
                      i_zdoe_info.i_errorprogram01 := i_schedulename;

                      PKG_DM_COMMON_OPERATIONS.insertintozdoe(i_zdoe_info => i_zdoe_info);
                      v_clntkey_sv := TRIM(obj_client.clntkey);

                      ---DBMS_Output.PUT_LINE('(6)[SKIP] update data but no item to be changed IG ClientNum :' || v_clntnum || ', obj_client.clntkey:' || obj_client.clntkey);

                      GOTO createPostvalidation; 

                   END IF;                                       
                END LOOP;
                --- view_zdclpflist or pazdclpflist????‘¶???????? CLNTPF??‘¶???????????????A?f?[?^?s???‡?????‡??‘?‰??i???????v?????j?B“???view_zdclpflist????‘????s?????????A‘?????????“??????R?[?h
                IF b_clntpf_exist = false THEN
                   ---DBMS_Output.PUT_LINE('(6_1)[Inconsistent data] ClientNum exists in view_zdclpflist or pazdclpflist but not exists in clntpf, so shifted over from Update to Error IG ClientNum :' || v_clntnum || ', obj_client.clntkey:' || obj_client.clntkey);

                   b_isnoerror := false;
                   i_zdoe_info.i_indic := 'E';
                   i_zdoe_info.i_error01 := c_z022;
                   i_zdoe_info.i_errormsg01 := o_errortext(c_z022);
                   i_zdoe_info.i_errorfield01 := 'INCONS';
                   i_zdoe_info.i_fieldvalue01 := trim(obj_client.clntkey);
                   i_zdoe_info.i_errorprogram01 := i_schedulename;

                   PKG_DM_COMMON_OPERATIONS.insertintozdoe(i_zdoe_info => i_zdoe_info);
                   v_clntkey_sv := TRIM(obj_client.clntkey);

                   GOTO createPostvalidation; 
                END IF;
            END IF;

            i_zdoe_info.i_indic := 'S';
            PKG_DM_COMMON_OPERATIONS.insertintozdoe(i_zdoe_info => i_zdoe_info);
        END IF;

          ---- put trace log regarding skip, update or insert
        /*
        IF b_isnoerror = false THEN
           DBMS_Output.PUT_LINE('(6)[SKIP] IG ClientNum :' || v_IGclntnum || ' , obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
        ELSIF b_update = true THEN
           DBMS_Output.PUT_LINE('(7)[UPDATE] IG ClientNum :' || v_IGclntnum || ' , obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
        ELSE
           DBMS_Output.PUT_LINE('(8)[Insert] IG ClientNum :' || v_IGclntnum || ' , obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
        END IF;
        */

         --- populating the table for post validation check
    << createPostvalidation >>
        /* IF b_isnoerror = false THEN
            obj_dmigtitdmgclntcorp.RECIDXCLCORP := obj_client.RECIDXCLCORP;
            obj_dmigtitdmgclntcorp.CLTTYPE := obj_client.CLTTYPE;
            obj_dmigtitdmgclntcorp.CLTADDR01 := obj_client.CLTADDR01;
            obj_dmigtitdmgclntcorp.CLTADDR02 := obj_client.CLTADDR02;
            obj_dmigtitdmgclntcorp.CLTADDR03 := obj_client.CLTADDR03;
            obj_dmigtitdmgclntcorp.CLTADDR04 := obj_client.CLTADDR04;
            obj_dmigtitdmgclntcorp.ZKANADDR01 := obj_client.ZKANADDR01;
            obj_dmigtitdmgclntcorp.ZKANADDR02 := obj_client.ZKANADDR02;
            obj_dmigtitdmgclntcorp.ZKANADDR03 := obj_client.ZKANADDR03;
            obj_dmigtitdmgclntcorp.ZKANADDR04 := obj_client.ZKANADDR04;
            obj_dmigtitdmgclntcorp.CLTPCODE := obj_client.CLTPCODE;
            obj_dmigtitdmgclntcorp.CLTPHONE01 := obj_client.CLTPHONE01;
            obj_dmigtitdmgclntcorp.CLTPHONE02 := obj_client.CLTPHONE02;
            obj_dmigtitdmgclntcorp.CLTDOBX := obj_client.CLTDOBX;
            obj_dmigtitdmgclntcorp.CLTSTAT := obj_client.CLTSTAT;
            obj_dmigtitdmgclntcorp.FAXNO := obj_client.FAXNO;
            obj_dmigtitdmgclntcorp.LSURNAME := obj_client.LSURNAME;
            obj_dmigtitdmgclntcorp.ZKANASNM := obj_client.ZKANASNM;
            obj_dmigtitdmgclntcorp.CLNTKEY := obj_client.CLNTKEY;
            obj_dmigtitdmgclntcorp.AGNTNUM := obj_client.AGNTNUM;
            obj_dmigtitdmgclntcorp.MPLNUM := obj_client.MPLNUM;
            obj_dmigtitdmgclntcorp.CLNTNUM := v_IGclntnum;
            obj_dmigtitdmgclntcorp.IND := 'S';
            INSERT INTO DMIGTITDMGCLNTCORP VALUES obj_dmigtitdmgclntcorp;

             CONTINUE skiprecord;

         END IF;*/

    -- update IG  tables START

        IF ( ( b_isnoerror = true ) AND ( i_zprvaldyn = 'N' ) ) THEN


            IF b_update = false THEN
               ---SELECT
               ---    seqanumpf.NEXTVAL
               ---INTO v_clntnum
               ---FROM
               ---    dual;

               --LOOP  ----â– [TODO]:æŽ¡ç•ªã�™ã‚‹ãƒ¬ãƒ³ã‚¸ã�Œæ±ºå®šã�§ã��ã�ªã�„å ´å�ˆã�¯ã€�IGã�«å­˜åœ¨ã�—ã�ªã�„ç•ªå�·ã�Œç™ºç•ªã�•ã‚Œã‚‹ã�¾ã�§ç¹°ã‚Šè¿”ã�™ --CC7
                 --SELECT
                 --    seqanumpf.NEXTVAL
                 --     INTO v_clntnum
                 -- FROM
                 --     dual;
                  v_clntnum := seqanumpf.NEXTVAL; --CC7  
                 /*   
                  SELECT
                       count(*)
                  INTO 
                     v_IGclntnumcnt
                  FROM
                     clntpf
                  WHERE
                     clntnum = v_clntnum;  
                  EXIT WHEN v_IGclntnumcnt = 0;
               END LOOP;
               */ --CC7
            ELSE
               v_clntnum := v_IGclntnum;
            END IF;

            /*
            IF b_update = true THEN
               DBMS_Output.PUT_LINE('(9)[UPDATE] IG ClientNum :' || v_clntnum || ' , obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
            ELSE
               DBMS_Output.PUT_LINE('(10)[Insert] IG ClientNum :' || v_clntnum || ' , obj_client.clntkey:' || obj_client.clntkey || ' , obj_client.agntnum:' || obj_client.agntnum || ',obj_client.mplnum;' || obj_client.mplnum);
            END IF;
            */

      -- insert in  IG pazdclpf table start-
        --- pazdclpfに既に同一のPJ顧客番号、IG顧客番号が存在しない場合は、新規登録、更新の場合にpazdclpfに登録する
        --- PA移行時に移行（登録、更新）された顧客は登録しない
        --- SHI移行時に移行された顧客でも、pazdclpfに既に同一のPJ顧客番号、IG顧客番号が存在しない場合は、新規登録、更新の場合にpazdclpfに登録する

        SELECT
              count(*)
        INTO
             v_pazdclpcnt
        FROM
             pazdclpf
        WHERE
              zigvalue =  v_clntnum
          AND zentity = obj_client.clntkey
          AND PREFIX = c_prefix
        ;

        IF v_pazdclpcnt = 0 THEN
           obj_pazdclpf.recstatus := 'OK';
           obj_pazdclpf.prefix := c_prefix;
           obj_pazdclpf.zentity := obj_client.clntkey;
           obj_pazdclpf.zigvalue := v_clntnum;
           obj_pazdclpf.jobnum := i_schedulenumber;
           obj_pazdclpf.jobname := i_schedulename;
           INSERT INTO view_pazdclpf VALUES obj_pazdclpf;
        END IF;

      -- insert in  IG zdclpf table end-
      -- insert in  IG CLNTPF table start-
        IF TRIM(i_vrcmtermid) IS NOT NULL THEN
           v_termid := i_vrcmtermid; --IgSpaceValue; --System updated
        ELSE
           v_termid := c_clntpf_termid;
        END IF;

        PKG_DM_CORPORATE.removeLegalPersonality( i_name => obj_client.zkanasnm , o_name => v_zkanasnmnor);


        IF b_update = false THEN

            obj_clntpf.clntpfx := o_defaultvalues('CLNTPFX');
            obj_clntpf.clntcoy := o_defaultvalues('CLNTCOY');
            obj_clntpf.clntnum := v_clntnum;
            obj_clntpf.tranid := v_tranid;
            obj_clntpf.validflag := o_defaultvalues('VALIDFLAG');
            obj_clntpf.clttype := o_defaultvalues('CLTTYPE');
            OBJ_CLNTPF.SECUITYNO := C_CLNTPF_SECUITYNO;
            OBJ_CLNTPF.PAYROLLNO := C_CLNTPF_PAYROLLNO;
            OBJ_CLNTPF.LSURNAME := OBJ_CLIENT.LSURNAME;
            --- CC6
            obj_clntpf.surname := SUBSTR(obj_client.lsurname,1,30);
            --- CC6
            obj_clntpf.givname := substr(c_clntpf_givname,1,20);
            obj_clntpf.salut := c_clntpf_salut;
            obj_clntpf.initials := c_clntpf_initials;
            obj_clntpf.cltsex := c_clntpf_cltsex;
            IF TRIM(obj_client.cltaddr01) IS NOT NULL THEN
                obj_clntpf.cltaddr01 := obj_client.cltaddr01;
            ELSE
                obj_clntpf.cltaddr01 := c_clntpf_cltaddr01;
            END IF;

            IF TRIM(obj_client.cltaddr02) IS NOT NULL THEN
                obj_clntpf.cltaddr02 := obj_client.cltaddr02;
            ELSE
                obj_clntpf.cltaddr02 := c_clntpf_cltaddr02;
            END IF;

            IF TRIM(obj_client.cltaddr03) IS NOT NULL THEN
                obj_clntpf.cltaddr03 := obj_client.cltaddr03;
            ELSE
                obj_clntpf.cltaddr03 := c_clntpf_cltaddr03;
            END IF;

            IF TRIM(obj_client.cltaddr04) IS NOT NULL THEN
                obj_clntpf.cltaddr04 := obj_client.cltaddr04;
            ELSE
                obj_clntpf.cltaddr04 := c_clntpf_cltaddr04;
            END IF;

            obj_clntpf.cltaddr05 := c_clntpf_cltaddr05;
            IF TRIM(obj_client.cltpcode) IS NOT NULL THEN
                obj_clntpf.cltpcode := obj_client.cltpcode;
            ELSE
                obj_clntpf.cltpcode := c_clntpf_cltpcode;
            END IF;

            --CC6
            OBJ_CLNTPF.ISPERMANENTID := C_CLNTPF_ISPERMANENTID;
            OBJ_CLNTPF.IDEXPIREDATE := C_CLNTPF_IDEXPIREDATE;
            OBJ_CLNTPF.WORKUNIT := C_CLNTPF_WORKUNIT;
            --CC6
            obj_clntpf.ctrycode := o_defaultvalues('CTRYCODE');
            obj_clntpf.mailing := o_defaultvalues('MAILING');
            obj_clntpf.dirmail := o_defaultvalues('DIRMAIL');
            obj_clntpf.addrtype := c_clntpf_addrtype;
            IF TRIM(obj_client.cltphone01) IS NOT NULL THEN
                obj_clntpf.cltphone01 := obj_client.cltphone01;
            ELSE
                obj_clntpf.cltphone01 := c_clntpf_cltphone01;
            END IF;

            IF TRIM(obj_client.cltphone02) IS NOT NULL THEN
                obj_clntpf.cltphone02 := obj_client.cltphone02;
            ELSE
                obj_clntpf.cltphone02 := c_clntpf_cltphone02;
            END IF;

            obj_clntpf.vip := o_defaultvalues('VIP');
            obj_clntpf.occpcode := c_clntpf_occpcode;
            obj_clntpf.servbrh := i_branch;
            obj_clntpf.statcode := c_clntpf_statcode;
            IF TRIM(obj_client.cltdobx) IS NOT NULL THEN
                obj_clntpf.cltdob := obj_client.cltdobx;
            ELSE
                obj_clntpf.cltdob := c_clntpf_cltdob;
            END IF;

            obj_clntpf.soe := c_clntpf_soe;
            obj_clntpf.docno := c_clntpf_docno;
            obj_clntpf.cltdod := o_defaultvalues('CLTDOD');
            obj_clntpf.cltstat := o_defaultvalues('CLTSTAT');
            obj_clntpf.cltmchg := o_defaultvalues('CLTMCHG');
            obj_clntpf.middl01 := c_clntpf_middl01;
            obj_clntpf.middl02 := c_clntpf_middl02;
            obj_clntpf.marryd := c_clntpf_marryd;
            obj_clntpf.tlxno := c_clntpf_tlxno;
            IF TRIM(obj_client.faxno) IS NOT NULL THEN
                obj_clntpf.faxno := obj_client.faxno;
            ELSE
                obj_clntpf.faxno := c_clntpf_faxno;
            END IF;

            obj_clntpf.tgram := c_clntpf_tgram;
            obj_clntpf.birthp := c_clntpf_birthp;
            obj_clntpf.salutl := c_clntpf_salutl;
            obj_clntpf.roleflag01 := c_clntpf_roleflag01;
            obj_clntpf.roleflag02 := c_clntpf_roleflag02;
            obj_clntpf.roleflag03 := c_clntpf_roleflag03;
            obj_clntpf.roleflag04 := c_clntpf_roleflag04;
            obj_clntpf.roleflag05 := c_clntpf_roleflag05;
            obj_clntpf.roleflag06 := c_clntpf_roleflag06;
            obj_clntpf.roleflag07 := c_clntpf_roleflag07;
            obj_clntpf.roleflag08 := c_clntpf_roleflag08;
            obj_clntpf.roleflag09 := c_clntpf_roleflag09;
            obj_clntpf.roleflag10 := c_clntpf_roleflag10;
            obj_clntpf.roleflag11 := c_clntpf_roleflag11;
            obj_clntpf.roleflag12 := c_clntpf_roleflag12;
            obj_clntpf.roleflag13 := c_clntpf_roleflag13;
            obj_clntpf.roleflag14 := c_clntpf_roleflag14;
            obj_clntpf.roleflag15 := c_clntpf_roleflag15;
            obj_clntpf.roleflag16 := c_clntpf_roleflag16;
            obj_clntpf.roleflag17 := c_clntpf_roleflag17;
            obj_clntpf.roleflag18 := c_clntpf_roleflag18;
            obj_clntpf.roleflag19 := c_clntpf_roleflag19;
            obj_clntpf.roleflag20 := c_clntpf_roleflag20;
            obj_clntpf.roleflag21 := c_clntpf_roleflag21;
            obj_clntpf.roleflag22 := c_clntpf_roleflag22;
            obj_clntpf.roleflag23 := c_clntpf_roleflag23;
            obj_clntpf.roleflag24 := c_clntpf_roleflag24;
            obj_clntpf.roleflag25 := c_clntpf_roleflag25;
            obj_clntpf.roleflag26 := c_clntpf_roleflag26;
            obj_clntpf.roleflag27 := c_clntpf_roleflag27;
            obj_clntpf.roleflag28 := c_clntpf_roleflag28;
            obj_clntpf.roleflag29 := c_clntpf_roleflag29;
            obj_clntpf.roleflag30 := c_clntpf_roleflag30;
            obj_clntpf.roleflag31 := c_clntpf_roleflag31;
            obj_clntpf.roleflag32 := c_clntpf_roleflag32;
            obj_clntpf.roleflag33 := c_clntpf_roleflag33;
            obj_clntpf.roleflag34 := c_clntpf_roleflag34;
            obj_clntpf.roleflag35 := c_clntpf_roleflag35;
            obj_clntpf.stca := c_clntpf_stca;
            obj_clntpf.stcb := c_clntpf_stcb;
            obj_clntpf.stcc := c_clntpf_stcc;
            obj_clntpf.stcd := c_clntpf_stcd;
            obj_clntpf.stce := c_clntpf_stce;
            obj_clntpf.procflag := c_clntpf_procflag;
            obj_clntpf.termid := v_termid;
            obj_clntpf.user_t := c_clntpf_user_t;
            obj_clntpf.trdt := c_clntpf_trdt;
            obj_clntpf.trtm := c_clntpf_trtm;
            obj_clntpf.sndxcde := c_clntpf_sndxcde;
            obj_clntpf.natlty := c_clntpf_natlty;
            obj_clntpf.fao := c_clntpf_fao;
            obj_clntpf.cltind := o_defaultvalues('CLTIND');
            obj_clntpf.state := c_clntpf_state;
            obj_clntpf.language := o_defaultvalues('LANGUAGE');
            obj_clntpf.capital := TO_NUMBER(o_defaultvalues('CAPITAL'));
            obj_clntpf.ctryorig := c_clntpf_ctryorig;
            obj_clntpf.ecact := c_clntpf_ecact;
            obj_clntpf.ethorig := c_clntpf_ethorig;
            obj_clntpf.srdate := o_defaultvalues('SRDATE');
            obj_clntpf.staffno := c_clntpf_staffno;
            obj_clntpf.lgivname := c_clntpf_lgivname;
            obj_clntpf.taxflag := o_defaultvalues('TAXFLAG');
            obj_clntpf.usrprf := i_usrprf;
            obj_clntpf.jobnm := i_schedulename;
            obj_clntpf.datime := current_timestamp;
            obj_clntpf.idtype := c_clntpf_idtype;
            obj_clntpf.z1gstregd := o_defaultvalues('Z1GSTREGD');
            obj_clntpf.z1gstregn := c_clntpf_z1gstregn;
            obj_clntpf.kanjisurname := c_clntpf_kanjisurname;
            obj_clntpf.kanjigivname := c_clntpf_kanjigivname;
            obj_clntpf.kanjicltaddr01 := c_clntpf_kanjicltaddr01;
            obj_clntpf.kanjicltaddr02 := c_clntpf_kanjicltaddr02;
            obj_clntpf.kanjicltaddr03 := c_clntpf_kanjicltaddr03;
            obj_clntpf.kanjicltaddr04 := c_clntpf_kanjicltaddr04;
            obj_clntpf.kanjicltaddr05 := c_clntpf_kanjicltaddr05;
            obj_clntpf.excep := c_clntpf_excep;
            obj_clntpf.zkanasnm := obj_client.zkanasnm;
            obj_clntpf.zkanagnm := c_clntpf_zkanagnm;
            obj_clntpf.zkanaddr01 := obj_client.zkanaddr01;
            obj_clntpf.zkanaddr02 := obj_client.zkanaddr02;

            IF TRIM(obj_client.zkanaddr03) IS NOT NULL THEN
                obj_clntpf.zkanaddr03 := obj_client.zkanaddr03;
            ELSE
                obj_clntpf.zkanaddr03 := c_clntpf_zkanaddr03;
            END IF;

            IF TRIM(obj_client.zkanaddr04) IS NOT NULL THEN
                obj_clntpf.zkanaddr04 := obj_client.zkanaddr04;
            ELSE
                obj_clntpf.zkanaddr04 := c_clntpf_zkanaddr04;
            END IF;

            obj_clntpf.zkanaddr05 := c_clntpf_zkanaddr05;
            obj_clntpf.zaddrcd := c_clntpf_zaddrcd;
            obj_clntpf.abusnum := c_clntpf_abusnum;
            obj_clntpf.branchid := c_clntpf_branchid;

            obj_clntpf.zkanasnmnor := v_zkanasnmnor;
            obj_clntpf.zkanagnmnor := c_clntpf_zkanagnm;

            obj_clntpf.telectrycode := c_clntpf_telectrycode;
            obj_clntpf.telectrycode1 := c_clntpf_telectrycode1;
            obj_clntpf.zdlind := c_clntpf_zdlind;
            obj_clntpf.dirmktmtd := c_clntpf_dirmktmtd;
            obj_clntpf.prefconmtd := c_clntpf_prefconmtd;
            obj_clntpf.zoccdsc := c_clntpf_zoccdsc;
            obj_clntpf.occpclas := c_clntpf_occpclas;
            obj_clntpf.zworkplce := c_clntpf_zworkplce;
            obj_clntpf.clntstatecd := c_clntpf_clntstatecd;
            obj_clntpf.fundadminflag := c_clntpf_fundadminflag;
            obj_clntpf.province := c_clntpf_province;
            obj_clntpf.seqno := c_clntpf_seqno;

            v_SEQ_CLNTPF :=   SEQ_CLNTPF.nextval ;
            obj_clntpf.unique_number := v_SEQ_CLNTPF;

            INSERT INTO clntpf VALUES obj_clntpf;
        ELSE               
            UPDATE
                  clntpf
            SET
                  lsurname = obj_client.lsurname
                  --- C6
                 ,surname = substr(obj_client.lsurname,1,30)
                  --- C6
                 ,cltaddr01 = obj_client.cltaddr01
                 ,cltaddr02 = obj_client.cltaddr02
                 ,cltaddr03 = obj_client.cltaddr03
                 ,cltaddr04 = obj_client.cltaddr04
                 ,cltpcode = obj_client.cltpcode
                 ,cltphone01 = obj_client.cltphone01
                 ,cltphone02 = obj_client.cltphone02
                 ,cltdob = obj_client.cltdobx
                 ,faxno = obj_client.faxno
                 ,zkanasnm = obj_client.zkanasnm
                 ,zkanaddr01 = obj_client.zkanaddr01
                 ,zkanaddr02 = obj_client.zkanaddr02
                 ,zkanaddr03 = obj_client.zkanaddr03
                 ,zkanaddr04 = obj_client.zkanaddr04
                 ,zkanasnmnor = v_zkanasnmnor
                 ,termid = v_termid
                 ,usrprf = i_usrprf
                 ,jobnm = i_schedulename
                 ,datime = current_timestamp
            WHERE
                 TRIM(clntnum) = v_clntnum
             AND TRIM(clntpfx) = o_defaultvalues('CLNTPFX')
             AND TRIM(clntcoy) = o_defaultvalues('CLNTCOY')
             AND TRIM(cltind) = o_defaultvalues('CLTIND')
            ;

            obj_clntpf.cltind := o_defaultvalues('CLTIND');
            obj_clntpf.clntpfx := o_defaultvalues('CLNTPFX');
            obj_clntpf.clntcoy := o_defaultvalues('CLNTCOY');
            obj_clntpf.clntnum := v_clntnum;
            obj_clntpf.lsurname := obj_client.lsurname;
            obj_clntpf.surname := substr(obj_client.lsurname,1,30);
            obj_clntpf.cltaddr01 := obj_client.cltaddr01;
            obj_clntpf.cltaddr02 := obj_client.cltaddr02;
            obj_clntpf.cltaddr03 := obj_client.cltaddr03;
            obj_clntpf.cltaddr04 := obj_client.cltaddr04;
            obj_clntpf.cltpcode := obj_client.cltpcode;
            obj_clntpf.cltphone01 := obj_client.cltphone01;
            obj_clntpf.cltphone02 := obj_client.cltphone02;
            obj_clntpf.cltdob := obj_client.cltdobx;
            obj_clntpf.faxno := obj_client.faxno;
            obj_clntpf.zkanasnm := obj_client.zkanasnm;
            obj_clntpf.zkanaddr01 := obj_client.zkanaddr01;
            obj_clntpf.zkanaddr02 := obj_client.zkanaddr02;
            obj_clntpf.zkanaddr03 := obj_client.zkanaddr03;
            obj_clntpf.zkanaddr04 := obj_client.zkanaddr04;

            obj_client.zkanasnm := v_zkanasnmnor;

          
           
            obj_clntpf.termid := v_termid;
            obj_clntpf.usrprf := i_usrprf;
            obj_clntpf.jobnm := i_schedulename;

         END IF;
/*
         --- populating the table for post validation check
         obj_dmigtitdmgclntcorp.RECIDXCLCORP := obj_client.RECIDXCLCORP;
         obj_dmigtitdmgclntcorp.CLTTYPE := obj_client.CLTTYPE;
         obj_dmigtitdmgclntcorp.CLTADDR01 := obj_client.CLTADDR01;
         obj_dmigtitdmgclntcorp.CLTADDR02 := obj_client.CLTADDR02;
         obj_dmigtitdmgclntcorp.CLTADDR03 := obj_client.CLTADDR03;
         obj_dmigtitdmgclntcorp.CLTADDR04 := obj_client.CLTADDR04;
         obj_dmigtitdmgclntcorp.ZKANADDR01 := obj_client.ZKANADDR01;
         obj_dmigtitdmgclntcorp.ZKANADDR02 := obj_client.ZKANADDR02;
         obj_dmigtitdmgclntcorp.ZKANADDR03 := obj_client.ZKANADDR03;
         obj_dmigtitdmgclntcorp.ZKANADDR04 := obj_client.ZKANADDR04;
         obj_dmigtitdmgclntcorp.CLTPCODE := obj_client.CLTPCODE;
         obj_dmigtitdmgclntcorp.CLTPHONE01 := obj_client.CLTPHONE01;
         obj_dmigtitdmgclntcorp.CLTPHONE02 := obj_client.CLTPHONE02;
         obj_dmigtitdmgclntcorp.CLTDOBX := obj_client.CLTDOBX;
         obj_dmigtitdmgclntcorp.CLTSTAT := obj_client.CLTSTAT;
         obj_dmigtitdmgclntcorp.FAXNO := obj_client.FAXNO;
         obj_dmigtitdmgclntcorp.LSURNAME := obj_client.LSURNAME;
         obj_dmigtitdmgclntcorp.ZKANASNM := obj_client.ZKANASNM;
         obj_dmigtitdmgclntcorp.CLNTKEY := obj_client.CLNTKEY;
         obj_dmigtitdmgclntcorp.AGNTNUM := obj_client.AGNTNUM;
         obj_dmigtitdmgclntcorp.MPLNUM := obj_client.MPLNUM;
         obj_dmigtitdmgclntcorp.CLNTNUM := obj_clntpf.clntnum;
         IF b_update = false THEN
            obj_dmigtitdmgclntcorp.IND := 'I';
         ELSE
            obj_dmigtitdmgclntcorp.IND := 'U';
         END IF;
         INSERT INTO DMIGTITDMGCLNTCORP VALUES obj_dmigtitdmgclntcorp;
*/
      -- insert in  IG CLNTPF table end-

      -- insert in  IG AUDIT_CLNTPF table start -
      --- 常にレコードを追加

            --SELECT
            --    seq_clntpf.NEXTVAL
            --INTO v_unq_audit_clntpf
            --FROM
            --     dual;

         --   v_unq_audit_clntpf := seq_clntpf.NEXTVAL; --CC7
         --   obj_audit_clntpf.unique_number := v_unq_audit_clntpf;

            --- å½“è©²é¡§å®¢ã�®ãƒ¬ã‚³ãƒ¼ãƒ‰ã�Œã�‚ã‚‹ã�‹ã‚’ãƒ�ã‚§ãƒƒã‚¯ã�™ã‚‹ï¼ˆæ›´æ–°ãƒ‘ã‚¿ãƒ¼ãƒ³ã�§ã‚‚å±¥æ­´ã�Œå­˜åœ¨ã�—ã�ªã�„å ´å�ˆã�®ã€�å¿µã�®ã�Ÿã‚�ã�®å‡¦ç�†ï¼‰
            /*
            SELECT
                  count(*)
            INTO
                  i_audit_clntpfcnt
            FROM
                  audit_clntpf
            WHERE
                NEWCLNTNUM = obj_clntpf.clntnum
            AND NEWCLNTPFX = obj_clntpf.clntpfx
            AND NEWCLNTCOY = obj_clntpf.clntcoy
            AND NEWCLTIND  = obj_clntpf.cltind
            ;   */ --CC7          

            --IF b_update = false OR i_audit_clntpfcnt = 0 THEN --CC7
            /*
            IF b_update = false THEN --CC7

               obj_audit_clntpf.oldclntnum := obj_clntpf.clntnum;
           -- CH3 START --
               obj_audit_clntpf.oldclntpfx := NULL;
               obj_audit_clntpf.oldclntcoy := NULL;
               obj_audit_clntpf.oldtranid := NULL;
               obj_audit_clntpf.oldvalidflag := NULL;
               obj_audit_clntpf.oldclttype := NULL;
               obj_audit_clntpf.oldsecuityno := NULL;
              obj_audit_clntpf.oldpayrollno := NULL;
               obj_audit_clntpf.oldsurname := NULL;
               obj_audit_clntpf.oldgivname := NULL;
               obj_audit_clntpf.oldsalut := NULL;
               obj_audit_clntpf.oldinitials := NULL;
               obj_audit_clntpf.oldcltsex := NULL;
               obj_audit_clntpf.oldcltaddr01 := NULL;
               obj_audit_clntpf.oldcltaddr02 := NULL;
               obj_audit_clntpf.oldcltaddr03 := NULL;
               obj_audit_clntpf.oldcltaddr04 := NULL;
               obj_audit_clntpf.oldcltaddr05 := NULL;
               obj_audit_clntpf.oldcltpcode := NULL;
               obj_audit_clntpf.oldctrycode := NULL;
               obj_audit_clntpf.oldmailing := NULL;
               obj_audit_clntpf.olddirmail := NULL;
               obj_audit_clntpf.oldaddrtype := NULL;
               obj_audit_clntpf.oldcltphone01 := NULL;
               obj_audit_clntpf.oldcltphone02 := NULL;
               obj_audit_clntpf.oldvip := NULL;
               obj_audit_clntpf.oldoccpcode := NULL;
               obj_audit_clntpf.oldservbrh := NULL;
               obj_audit_clntpf.oldstatcode := NULL;
               obj_audit_clntpf.oldcltdob := 0;
               obj_audit_clntpf.oldsoe := NULL;
               obj_audit_clntpf.olddocno := NULL;
               obj_audit_clntpf.oldcltdod := 0;
               obj_audit_clntpf.oldcltstat := NULL;
               obj_audit_clntpf.oldcltmchg := NULL;
               obj_audit_clntpf.oldmiddl01 := NULL;
               obj_audit_clntpf.oldmiddl02 := NULL;
               obj_audit_clntpf.oldmarryd := NULL;
               obj_audit_clntpf.oldtlxno := NULL;
               obj_audit_clntpf.oldfaxno := NULL;
               obj_audit_clntpf.oldtgram := NULL;
               obj_audit_clntpf.oldbirthp := NULL;
               obj_audit_clntpf.oldsalutl := NULL;
               obj_audit_clntpf.oldroleflag01 := NULL;
               obj_audit_clntpf.oldroleflag02 := NULL;
               obj_audit_clntpf.oldroleflag03 := NULL;
               obj_audit_clntpf.oldroleflag04 := NULL;
               obj_audit_clntpf.oldroleflag05 := NULL;
               obj_audit_clntpf.oldroleflag06 := NULL;
               obj_audit_clntpf.oldroleflag07 := NULL;
               obj_audit_clntpf.oldroleflag08 := NULL;
               obj_audit_clntpf.oldroleflag09 := NULL;
               obj_audit_clntpf.oldroleflag10 := NULL;
               obj_audit_clntpf.oldroleflag11 := NULL;
               obj_audit_clntpf.oldroleflag12 := NULL;
               obj_audit_clntpf.oldroleflag13 := NULL;
               obj_audit_clntpf.oldroleflag14 := NULL;
               obj_audit_clntpf.oldroleflag15 := NULL;
               obj_audit_clntpf.oldroleflag16 := NULL;
               obj_audit_clntpf.oldroleflag17 := NULL;
               obj_audit_clntpf.oldroleflag18 := NULL;
               obj_audit_clntpf.oldroleflag19 := NULL;
               obj_audit_clntpf.oldroleflag20 := NULL;
               obj_audit_clntpf.oldroleflag21 := NULL;
               obj_audit_clntpf.oldroleflag22 := NULL;
               obj_audit_clntpf.oldroleflag23 := NULL;
               obj_audit_clntpf.oldroleflag24 := NULL;
               obj_audit_clntpf.oldroleflag25 := NULL;
               obj_audit_clntpf.oldroleflag26 := NULL;
               obj_audit_clntpf.oldroleflag27 := NULL;
               obj_audit_clntpf.oldroleflag28 := NULL;
               obj_audit_clntpf.oldroleflag29 := NULL;
               obj_audit_clntpf.oldroleflag30 := NULL;
               obj_audit_clntpf.oldroleflag31 := NULL;
               obj_audit_clntpf.oldroleflag32 := NULL;
               obj_audit_clntpf.oldroleflag33 := NULL;
               obj_audit_clntpf.oldroleflag34 := NULL;
               obj_audit_clntpf.oldroleflag35 := NULL;
               obj_audit_clntpf.oldstca := NULL;
               obj_audit_clntpf.oldstcb := NULL;
               obj_audit_clntpf.oldstcc := NULL;
               obj_audit_clntpf.oldstcd := NULL;
               obj_audit_clntpf.oldstce := NULL;
               obj_audit_clntpf.oldprocflag := NULL;
               obj_audit_clntpf.oldtermid := NULL;
               obj_audit_clntpf.olduser_t := 0;
               OBJ_AUDIT_CLNTPF.OLDTRDT := NULL;
               obj_audit_clntpf.oldtrtm := NULL;
               obj_audit_clntpf.oldsndxcde := NULL;
               obj_audit_clntpf.oldnatlty := NULL;
               obj_audit_clntpf.oldfao := NULL;
               obj_audit_clntpf.oldcltind := NULL;
               obj_audit_clntpf.oldstate := NULL;
               obj_audit_clntpf.oldlanguage := NULL;
               obj_audit_clntpf.oldcapital := 0;
               obj_audit_clntpf.oldctryorig := NULL;
               obj_audit_clntpf.oldecact := NULL;
               obj_audit_clntpf.oldethorig := NULL;
               obj_audit_clntpf.oldsrdate := 0;
               obj_audit_clntpf.oldstaffno := NULL;
               obj_audit_clntpf.oldlsurname := NULL;
               obj_audit_clntpf.oldlgivname := NULL;
               obj_audit_clntpf.oldtaxflag := NULL;
               obj_audit_clntpf.oldusrprf := i_usrprf;
               obj_audit_clntpf.oldjobnm := i_schedulename;
               obj_audit_clntpf.olddatime := localtimestamp;
               obj_audit_clntpf.oldidtype := NULL;
               obj_audit_clntpf.oldz1gstregn := NULL;
               obj_audit_clntpf.oldz1gstregd := 0;
               obj_audit_clntpf.oldkanjisurname := NULL;
               obj_audit_clntpf.oldkanjigivname := NULL;
               obj_audit_clntpf.oldkanjicltaddr01 := NULL;
               obj_audit_clntpf.oldkanjicltaddr02 := NULL;
               obj_audit_clntpf.oldkanjicltaddr03 := NULL;
               obj_audit_clntpf.oldkanjicltaddr04 := NULL;
               obj_audit_clntpf.oldkanjicltaddr05 := NULL;
               obj_audit_clntpf.oldexcep := NULL;
               obj_audit_clntpf.oldzkanasnm := NULL;
               obj_audit_clntpf.oldzkanagnm := NULL;
               obj_audit_clntpf.oldzkanaddr01 := NULL;
               obj_audit_clntpf.oldzkanaddr02 := NULL;
               obj_audit_clntpf.oldzkanaddr03 := NULL;
               obj_audit_clntpf.oldzkanaddr04 := NULL;
               obj_audit_clntpf.oldzkanaddr05 := NULL;
               obj_audit_clntpf.oldzaddrcd := NULL;
               obj_audit_clntpf.oldabusnum := NULL;
               obj_audit_clntpf.oldbranchid := NULL;
               obj_audit_clntpf.oldzkanasnmnor := NULL;
               obj_audit_clntpf.oldzkanagnmnor := NULL;
               obj_audit_clntpf.oldtelectrycode := NULL;
               obj_audit_clntpf.oldtelectrycode1 := NULL;

               obj_audit_clntpf.action := 'INSERT';

            ELSE

                SELECT
                       audit_clntpf01.*
                BULK COLLECT
                INTO
                     audit_clntpflist
                FROM
                     audit_clntpf audit_clntpf01
                INNER JOIN
                     (SELECT
                           MAX(systemdate)  max_systemdate
                      FROM
                          audit_clntpf
                      WHERE
                          NEWCLNTNUM = obj_clntpf.clntnum
                      AND NEWCLNTPFX = obj_clntpf.clntpfx
                      AND NEWCLNTCOY = obj_clntpf.clntcoy
                      AND NEWCLTIND = obj_clntpf.cltind
                     ) audit_clntpf02
                ON
                    audit_clntpf01.systemdate = audit_clntpf02.max_systemdate
                WHERE
                      audit_clntpf01.NEWCLNTNUM = obj_clntpf.clntnum
                      AND audit_clntpf01.NEWCLNTPFX = obj_clntpf.clntpfx
                      AND audit_clntpf01.NEWCLNTCOY = obj_clntpf.clntcoy
                      AND audit_clntpf01.NEWCLTIND = obj_clntpf.cltind
                ;

                FOR indexitems IN 1 .. audit_clntpflist.COUNT LOOP

                    obj_audit_clntpf.oldclntpfx := audit_clntpflist(indexitems).newclntpfx;
                    obj_audit_clntpf.oldclntcoy := audit_clntpflist(indexitems).newclntcoy;
                    obj_audit_clntpf.oldtranid := audit_clntpflist(indexitems).newtranid;
                    obj_audit_clntpf.oldvalidflag := audit_clntpflist(indexitems).newvalidflag;
                    obj_audit_clntpf.oldclttype := audit_clntpflist(indexitems).newclttype;
                    obj_audit_clntpf.oldsecuityno := audit_clntpflist(indexitems).newsecuityno;
                    obj_audit_clntpf.oldpayrollno := audit_clntpflist(indexitems).newpayrollno;
                    obj_audit_clntpf.oldsurname := audit_clntpflist(indexitems).newsurname;
                    obj_audit_clntpf.oldgivname := audit_clntpflist(indexitems).newgivname;
                    obj_audit_clntpf.oldsalut := audit_clntpflist(indexitems).newsalut;
                    obj_audit_clntpf.oldinitials := audit_clntpflist(indexitems).newinitials;
                    obj_audit_clntpf.oldcltsex := audit_clntpflist(indexitems).newcltsex;
                    obj_audit_clntpf.oldcltaddr01 := audit_clntpflist(indexitems).newcltaddr01;
                    obj_audit_clntpf.oldcltaddr02 := audit_clntpflist(indexitems).newcltaddr02;
                    obj_audit_clntpf.oldcltaddr03 := audit_clntpflist(indexitems).newcltaddr03;
                    obj_audit_clntpf.oldcltaddr04 := audit_clntpflist(indexitems).newcltaddr04;
                    obj_audit_clntpf.oldcltaddr05 := audit_clntpflist(indexitems).newcltaddr05;
                    obj_audit_clntpf.oldcltpcode := audit_clntpflist(indexitems).newcltpcode;
                    obj_audit_clntpf.oldctrycode := audit_clntpflist(indexitems).newctrycode;
                    obj_audit_clntpf.oldmailing := audit_clntpflist(indexitems).newmailing;
                    obj_audit_clntpf.olddirmail := audit_clntpflist(indexitems).newdirmail;
                    obj_audit_clntpf.oldaddrtype := audit_clntpflist(indexitems).newaddrtype;
                    obj_audit_clntpf.oldcltphone01 := audit_clntpflist(indexitems).newcltphone01;
                    obj_audit_clntpf.oldcltphone02 := audit_clntpflist(indexitems).newcltphone02;
                    obj_audit_clntpf.oldvip := audit_clntpflist(indexitems).newvip;
                    obj_audit_clntpf.oldoccpcode := audit_clntpflist(indexitems).newoccpcode;
                    obj_audit_clntpf.oldservbrh := audit_clntpflist(indexitems).newservbrh;
                    obj_audit_clntpf.oldstatcode := audit_clntpflist(indexitems).newstatcode;
                    obj_audit_clntpf.oldcltdob := audit_clntpflist(indexitems).newcltdob;
                    obj_audit_clntpf.oldsoe := audit_clntpflist(indexitems).newsoe;
                    obj_audit_clntpf.olddocno := audit_clntpflist(indexitems).newdocno;
                    obj_audit_clntpf.oldcltdod := audit_clntpflist(indexitems).newcltdod;
                    obj_audit_clntpf.oldcltstat := audit_clntpflist(indexitems).newcltstat;
                    obj_audit_clntpf.oldcltmchg := audit_clntpflist(indexitems).newcltmchg;
                    obj_audit_clntpf.oldmiddl01 := audit_clntpflist(indexitems).newmiddl01;
                    obj_audit_clntpf.oldmiddl02 := audit_clntpflist(indexitems).newmiddl02;
                    obj_audit_clntpf.oldmarryd := audit_clntpflist(indexitems).newmarryd;
                    obj_audit_clntpf.oldtlxno := audit_clntpflist(indexitems).newtlxno;
                    obj_audit_clntpf.oldfaxno := audit_clntpflist(indexitems).newfaxno;
                    obj_audit_clntpf.oldtgram := audit_clntpflist(indexitems).newtgram;
                    obj_audit_clntpf.oldbirthp := audit_clntpflist(indexitems).newbirthp;
                    obj_audit_clntpf.oldsalutl := audit_clntpflist(indexitems).newsalutl;
                    obj_audit_clntpf.oldroleflag01 := audit_clntpflist(indexitems).newroleflag01;
                    obj_audit_clntpf.oldroleflag02 := audit_clntpflist(indexitems).newroleflag02;
                    obj_audit_clntpf.oldroleflag03 := audit_clntpflist(indexitems).newroleflag03;
                    obj_audit_clntpf.oldroleflag04 := audit_clntpflist(indexitems).newroleflag04;
                    obj_audit_clntpf.oldroleflag05 := audit_clntpflist(indexitems).newroleflag05;
                    obj_audit_clntpf.oldroleflag06 := audit_clntpflist(indexitems).newroleflag06;
                    obj_audit_clntpf.oldroleflag07 := audit_clntpflist(indexitems).newroleflag07;
                    obj_audit_clntpf.oldroleflag08 := audit_clntpflist(indexitems).newroleflag08;
                    obj_audit_clntpf.oldroleflag09 := audit_clntpflist(indexitems).newroleflag09;
                    obj_audit_clntpf.oldroleflag10 := audit_clntpflist(indexitems).newroleflag10;
                    obj_audit_clntpf.oldroleflag11 := audit_clntpflist(indexitems).newroleflag11;
                    obj_audit_clntpf.oldroleflag12 := audit_clntpflist(indexitems).newroleflag12;
                    obj_audit_clntpf.oldroleflag13 := audit_clntpflist(indexitems).newroleflag13;
                    obj_audit_clntpf.oldroleflag14 := audit_clntpflist(indexitems).newroleflag14;
                    obj_audit_clntpf.oldroleflag15 := audit_clntpflist(indexitems).newroleflag15;
                    obj_audit_clntpf.oldroleflag16 := audit_clntpflist(indexitems).newroleflag16;
                    obj_audit_clntpf.oldroleflag17 := audit_clntpflist(indexitems).newroleflag17;
                    obj_audit_clntpf.oldroleflag18 := audit_clntpflist(indexitems).newroleflag18;
                    obj_audit_clntpf.oldroleflag19 := audit_clntpflist(indexitems).newroleflag19;
                    obj_audit_clntpf.oldroleflag20 := audit_clntpflist(indexitems).newroleflag20;
                    obj_audit_clntpf.oldroleflag21 := audit_clntpflist(indexitems).newroleflag21;
                    obj_audit_clntpf.oldroleflag22 := audit_clntpflist(indexitems).newroleflag22;
                    obj_audit_clntpf.oldroleflag23 := audit_clntpflist(indexitems).newroleflag23;
                    obj_audit_clntpf.oldroleflag24 := audit_clntpflist(indexitems).newroleflag24;
                    obj_audit_clntpf.oldroleflag25 := audit_clntpflist(indexitems).newroleflag25;
                    obj_audit_clntpf.oldroleflag26 := audit_clntpflist(indexitems).newroleflag26;
                    obj_audit_clntpf.oldroleflag27 := audit_clntpflist(indexitems).newroleflag27;
                    obj_audit_clntpf.oldroleflag28 := audit_clntpflist(indexitems).newroleflag28;
                    obj_audit_clntpf.oldroleflag29 := audit_clntpflist(indexitems).newroleflag29;
                    obj_audit_clntpf.oldroleflag30 := audit_clntpflist(indexitems).newroleflag30;
                    obj_audit_clntpf.oldroleflag31 := audit_clntpflist(indexitems).newroleflag31;
                    obj_audit_clntpf.oldroleflag32 := audit_clntpflist(indexitems).newroleflag32;
                    obj_audit_clntpf.oldroleflag33 := audit_clntpflist(indexitems).newroleflag33;
                    obj_audit_clntpf.oldroleflag34 := audit_clntpflist(indexitems).newroleflag34;
                    obj_audit_clntpf.oldroleflag35 := audit_clntpflist(indexitems).newroleflag35;
                    obj_audit_clntpf.oldstca := audit_clntpflist(indexitems).newstca;
                    obj_audit_clntpf.oldstcb := audit_clntpflist(indexitems).newstcb;
                    obj_audit_clntpf.oldstcc := audit_clntpflist(indexitems).newstcc;
                    obj_audit_clntpf.oldstcd := audit_clntpflist(indexitems).newstcd;
                    obj_audit_clntpf.oldstce := audit_clntpflist(indexitems).newstce;
                    obj_audit_clntpf.oldprocflag := audit_clntpflist(indexitems).newprocflag;
                    obj_audit_clntpf.oldtermid := audit_clntpflist(indexitems).newtermid;
                    obj_audit_clntpf.olduser_t := audit_clntpflist(indexitems).newuser_t;
--                    obj_audit_clntpf.oldtrdt := audit_clntpflist(indexitems).newtrdt;
--                    obj_audit_clntpf.oldtrtm := audit_clntpflist(indexitems).newtrtm;
                    obj_audit_clntpf.oldsndxcde := audit_clntpflist(indexitems).newsndxcde;
                    obj_audit_clntpf.oldnatlty := audit_clntpflist(indexitems).newnatlty;
                    obj_audit_clntpf.oldfao := audit_clntpflist(indexitems).newfao;
                    obj_audit_clntpf.oldcltind := audit_clntpflist(indexitems).newcltind;
                    obj_audit_clntpf.oldstate := audit_clntpflist(indexitems).newstate;
                    obj_audit_clntpf.oldlanguage := audit_clntpflist(indexitems).newlanguage;
                    obj_audit_clntpf.oldcapital := audit_clntpflist(indexitems).newcapital;
                    obj_audit_clntpf.oldctryorig := audit_clntpflist(indexitems).newctryorig;
                    obj_audit_clntpf.oldecact := audit_clntpflist(indexitems).newecact;
                    obj_audit_clntpf.oldethorig := audit_clntpflist(indexitems).newethorig;
                    obj_audit_clntpf.oldsrdate := audit_clntpflist(indexitems).newsrdate;
                    obj_audit_clntpf.oldstaffno := audit_clntpflist(indexitems).newstaffno;
                    obj_audit_clntpf.oldlsurname := audit_clntpflist(indexitems).newlsurname;
                    obj_audit_clntpf.oldlgivname := audit_clntpflist(indexitems).newlgivname;
                    obj_audit_clntpf.oldtaxflag := audit_clntpflist(indexitems).newtaxflag;
                    obj_audit_clntpf.oldusrprf := audit_clntpflist(indexitems).newusrprf;
                    obj_audit_clntpf.oldjobnm := audit_clntpflist(indexitems).newjobnm;
                    obj_audit_clntpf.olddatime := audit_clntpflist(indexitems).newdatime;
                    obj_audit_clntpf.oldidtype := audit_clntpflist(indexitems).newidtype;
                    obj_audit_clntpf.oldz1gstregn := audit_clntpflist(indexitems).newz1gstregn;
                    obj_audit_clntpf.oldz1gstregd := audit_clntpflist(indexitems).newz1gstregd;
                    obj_audit_clntpf.oldkanjisurname := audit_clntpflist(indexitems).newkanjisurname;
                    obj_audit_clntpf.oldkanjigivname := audit_clntpflist(indexitems).newkanjigivname;
                    obj_audit_clntpf.oldkanjicltaddr01 := audit_clntpflist(indexitems).newkanjicltaddr01;
                    obj_audit_clntpf.oldkanjicltaddr02 := audit_clntpflist(indexitems).newkanjicltaddr02;
                    obj_audit_clntpf.oldkanjicltaddr03 := audit_clntpflist(indexitems).newkanjicltaddr03;
                    obj_audit_clntpf.oldkanjicltaddr04 := audit_clntpflist(indexitems).newkanjicltaddr04;
                    obj_audit_clntpf.oldkanjicltaddr05 := audit_clntpflist(indexitems).newkanjicltaddr05;
                    obj_audit_clntpf.oldexcep := audit_clntpflist(indexitems).newexcep;
                    obj_audit_clntpf.oldzkanasnm := audit_clntpflist(indexitems).newzkanasnm;
                    obj_audit_clntpf.oldzkanagnm := audit_clntpflist(indexitems).newzkanagnm;
                    obj_audit_clntpf.oldzkanaddr01 := audit_clntpflist(indexitems).newzkanaddr01;
                    obj_audit_clntpf.oldzkanaddr02 := audit_clntpflist(indexitems).newzkanaddr02;
                    obj_audit_clntpf.oldzkanaddr03 := audit_clntpflist(indexitems).newzkanaddr03;
                    obj_audit_clntpf.oldzkanaddr04 := audit_clntpflist(indexitems).newzkanaddr04;
                    obj_audit_clntpf.oldzkanaddr05 := audit_clntpflist(indexitems).newzkanaddr05;
                    obj_audit_clntpf.oldzaddrcd := audit_clntpflist(indexitems).newzaddrcd;
                    obj_audit_clntpf.oldabusnum := audit_clntpflist(indexitems).newabusnum;
                    obj_audit_clntpf.oldbranchid := audit_clntpflist(indexitems).newbranchid;
                    obj_audit_clntpf.oldzkanasnmnor := audit_clntpflist(indexitems).newzkanasnmnor;
                    obj_audit_clntpf.oldzkanagnmnor := audit_clntpflist(indexitems).newzkanagnmnor;
                    obj_audit_clntpf.oldtelectrycode := audit_clntpflist(indexitems).newtelectrycode;
                    obj_audit_clntpf.oldtelectrycode1 := audit_clntpflist(indexitems).newtelectrycode1;

                    obj_audit_clntpf.action := 'UPDATE';
               END LOOP;            
            END IF;
            */
            --CC6
            /*
            OBJ_AUDIT_CLNTPF.OLDTRTM := C_AUDIT_CLNTPF_OLDTRTM;
            OBJ_AUDIT_CLNTPF.OLDTRDT := C_AUDIT_CLNTPF_OLDTRDT;
            --CC6
            obj_audit_clntpf.newclntpfx := obj_clntpf.clntpfx;
            obj_audit_clntpf.newclntcoy := obj_clntpf.clntcoy;
            obj_audit_clntpf.newclntnum := obj_clntpf.clntnum;
            obj_audit_clntpf.newtranid := obj_clntpf.tranid;
            obj_audit_clntpf.newvalidflag := obj_clntpf.validflag;
            obj_audit_clntpf.newclttype := obj_clntpf.clttype;
            obj_audit_clntpf.newsecuityno := obj_clntpf.secuityno;
            obj_audit_clntpf.newpayrollno := obj_clntpf.payrollno;
            obj_audit_clntpf.newsurname := obj_clntpf.surname;
            obj_audit_clntpf.newgivname := obj_clntpf.givname;
            obj_audit_clntpf.newinitials := obj_clntpf.initials;
            obj_audit_clntpf.newcltsex := obj_clntpf.cltsex;
            obj_audit_clntpf.newcltaddr01 := obj_clntpf.cltaddr01;
            obj_audit_clntpf.newcltaddr02 := obj_clntpf.cltaddr02;
            obj_audit_clntpf.newcltaddr03 := obj_clntpf.cltaddr03;
            obj_audit_clntpf.newcltaddr04 := obj_clntpf.cltaddr04;
            obj_audit_clntpf.newcltaddr05 := obj_clntpf.cltaddr05;
            obj_audit_clntpf.newcltpcode := obj_clntpf.cltpcode;
            obj_audit_clntpf.newctrycode := obj_clntpf.ctrycode;
            obj_audit_clntpf.newmailing := obj_clntpf.mailing;
            obj_audit_clntpf.newdirmail := obj_clntpf.dirmail;
            obj_audit_clntpf.newaddrtype := obj_clntpf.addrtype;
            obj_audit_clntpf.newcltphone01 := obj_clntpf.cltphone01;
            obj_audit_clntpf.newcltphone02 := obj_clntpf.cltphone02;
            obj_audit_clntpf.newvip := obj_clntpf.vip;
            obj_audit_clntpf.newoccpcode := obj_clntpf.occpcode;
            obj_audit_clntpf.newservbrh := obj_clntpf.servbrh;
            obj_audit_clntpf.newstatcode := obj_clntpf.statcode;
            obj_audit_clntpf.newcltdob := obj_clntpf.cltdob;
            obj_audit_clntpf.newsoe := obj_clntpf.soe;
            obj_audit_clntpf.newdocno := obj_clntpf.docno;
            obj_audit_clntpf.newcltdod := obj_clntpf.cltdod;
            obj_audit_clntpf.newcltstat := obj_clntpf.cltstat;
            obj_audit_clntpf.newcltmchg := obj_clntpf.cltmchg;
            obj_audit_clntpf.newmiddl01 := obj_clntpf.middl01;
            obj_audit_clntpf.newmiddl02 := obj_clntpf.middl02;
            obj_audit_clntpf.newmarryd := obj_clntpf.marryd;
            obj_audit_clntpf.newtlxno := obj_clntpf.tlxno;
            obj_audit_clntpf.newfaxno := obj_clntpf.faxno;
            obj_audit_clntpf.newtgram := obj_clntpf.tgram;
            obj_audit_clntpf.newbirthp := obj_clntpf.birthp;
            obj_audit_clntpf.newsalutl := obj_clntpf.salutl;
            obj_audit_clntpf.newroleflag01 := obj_clntpf.roleflag01;
            obj_audit_clntpf.newroleflag02 := obj_clntpf.roleflag02;
            obj_audit_clntpf.newroleflag03 := obj_clntpf.roleflag03;
            obj_audit_clntpf.newroleflag04 := obj_clntpf.roleflag04;
            obj_audit_clntpf.newroleflag05 := obj_clntpf.roleflag05;
            obj_audit_clntpf.newroleflag06 := obj_clntpf.roleflag06;
            obj_audit_clntpf.newroleflag07 := obj_clntpf.roleflag07;
            obj_audit_clntpf.newroleflag08 := obj_clntpf.roleflag08;
            obj_audit_clntpf.newroleflag09 := obj_clntpf.roleflag09;
            obj_audit_clntpf.newroleflag10 := obj_clntpf.roleflag10;
            obj_audit_clntpf.newroleflag11 := obj_clntpf.roleflag11;
            obj_audit_clntpf.newroleflag12 := obj_clntpf.roleflag12;
            obj_audit_clntpf.newroleflag13 := obj_clntpf.roleflag13;
            obj_audit_clntpf.newroleflag14 := obj_clntpf.roleflag14;
            obj_audit_clntpf.newroleflag15 := obj_clntpf.roleflag15;
            obj_audit_clntpf.newroleflag16 := obj_clntpf.roleflag16;
            obj_audit_clntpf.newroleflag17 := obj_clntpf.roleflag17;
            obj_audit_clntpf.newroleflag18 := obj_clntpf.roleflag18;
            obj_audit_clntpf.newroleflag19 := obj_clntpf.roleflag19;
            obj_audit_clntpf.newroleflag20 := obj_clntpf.roleflag20;
            obj_audit_clntpf.newroleflag21 := obj_clntpf.roleflag21;
            obj_audit_clntpf.newroleflag22 := obj_clntpf.roleflag22;
            obj_audit_clntpf.newroleflag23 := obj_clntpf.roleflag23;
            obj_audit_clntpf.newroleflag24 := obj_clntpf.roleflag24;
            obj_audit_clntpf.newroleflag25 := obj_clntpf.roleflag25;
            obj_audit_clntpf.newroleflag26 := obj_clntpf.roleflag26;
            obj_audit_clntpf.newroleflag27 := obj_clntpf.roleflag27;
            obj_audit_clntpf.newroleflag28 := obj_clntpf.roleflag28;
            obj_audit_clntpf.newroleflag29 := obj_clntpf.roleflag29;
            obj_audit_clntpf.newroleflag30 := obj_clntpf.roleflag30;
            obj_audit_clntpf.newroleflag31 := obj_clntpf.roleflag31;
            obj_audit_clntpf.newroleflag32 := obj_clntpf.roleflag32;
            obj_audit_clntpf.newroleflag33 := obj_clntpf.roleflag33;
            obj_audit_clntpf.newroleflag34 := obj_clntpf.roleflag34;
            obj_audit_clntpf.newroleflag35 := obj_clntpf.roleflag35;
            obj_audit_clntpf.newstca := obj_clntpf.stca;
            obj_audit_clntpf.newstcb := obj_clntpf.stcb;
            obj_audit_clntpf.newstcc := obj_clntpf.stcc;
            obj_audit_clntpf.newstcd := obj_clntpf.stcd;
            obj_audit_clntpf.newstce := obj_clntpf.stce;
            obj_audit_clntpf.newprocflag := c_clntpf_procflag;
            obj_audit_clntpf.newtermid := i_vrcmtermid;
            obj_audit_clntpf.newuser_t := c_clntpf_user_t;
            obj_audit_clntpf.newtrdt :=  c_clntpf_trdt;
            obj_audit_clntpf.newtrtm := c_clntpf_trtm;
            obj_audit_clntpf.newsndxcde := obj_clntpf.sndxcde;
            obj_audit_clntpf.newnatlty := obj_clntpf.natlty;
            obj_audit_clntpf.newfao := obj_clntpf.fao;
            obj_audit_clntpf.newcltind := obj_clntpf.cltind;
            obj_audit_clntpf.newstate := obj_clntpf.state;
            obj_audit_clntpf.newlanguage := obj_clntpf.language;
            obj_audit_clntpf.newcapital := obj_clntpf.capital;
            obj_audit_clntpf.newctryorig := obj_clntpf.ctryorig;
            obj_audit_clntpf.newecact := obj_clntpf.ecact;
            obj_audit_clntpf.newethorig := obj_clntpf.ethorig;
            obj_audit_clntpf.newsrdate := obj_clntpf.srdate;
            obj_audit_clntpf.newstaffno := obj_clntpf.staffno;
            obj_audit_clntpf.newlsurname := obj_clntpf.lsurname;
            obj_audit_clntpf.newlgivname := obj_clntpf.lgivname;
            obj_audit_clntpf.newtaxflag := obj_clntpf.taxflag;
            obj_audit_clntpf.newusrprf := obj_clntpf.usrprf;
            obj_audit_clntpf.newjobnm := obj_clntpf.jobnm;
            obj_audit_clntpf.newdatime := localtimestamp;
            obj_audit_clntpf.newidtype := obj_clntpf.idtype;
            obj_audit_clntpf.newz1gstregn := obj_clntpf.z1gstregn;
            obj_audit_clntpf.newz1gstregd := obj_clntpf.z1gstregd;
            obj_audit_clntpf.newkanjisurname := c_clntpf_kanjisurname;
            obj_audit_clntpf.newkanjigivname := c_clntpf_kanjigivname;
            obj_audit_clntpf.newkanjicltaddr01 := c_clntpf_kanjicltaddr01;
            obj_audit_clntpf.newkanjicltaddr02 := c_clntpf_kanjicltaddr02;
            obj_audit_clntpf.newkanjicltaddr03 := c_clntpf_kanjicltaddr03;
            obj_audit_clntpf.newkanjicltaddr04 := c_clntpf_kanjicltaddr04;
            obj_audit_clntpf.newkanjicltaddr05 := c_clntpf_kanjicltaddr05;
            obj_audit_clntpf.newexcep := obj_clntpf.excep;
            obj_audit_clntpf.newzkanasnm := obj_clntpf.zkanasnm;
            obj_audit_clntpf.newzkanagnm := obj_clntpf.zkanagnm;
            obj_audit_clntpf.newzkanaddr01 := obj_clntpf.zkanaddr01;
            obj_audit_clntpf.newzkanaddr02 := obj_clntpf.zkanaddr02;
            obj_audit_clntpf.newzkanaddr03 := obj_clntpf.zkanaddr03;
            obj_audit_clntpf.newzkanaddr04 := obj_clntpf.zkanaddr04;
            obj_audit_clntpf.newzkanaddr05 := obj_clntpf.zkanaddr05;
            obj_audit_clntpf.newzaddrcd := obj_clntpf.zaddrcd;
            obj_audit_clntpf.newabusnum := obj_clntpf.abusnum;
            obj_audit_clntpf.newbranchid := obj_clntpf.branchid;
            obj_audit_clntpf.newzkanasnmnor := obj_clntpf.zkanasnmnor;
            obj_audit_clntpf.newzkanagnmnor := obj_clntpf.zkanagnmnor;
            obj_audit_clntpf.newtelectrycode := obj_clntpf.telectrycode;
            obj_audit_clntpf.newtelectrycode1 := obj_clntpf.telectrycode1;
            obj_audit_clntpf.userid := i_usrprf;

            SELECT
                MAX(tranno)
            INTO tranno
            FROM
                versionpf
            WHERE
                clntnum = obj_clntpf.clntnum;

            IF ( tranno IS NULL ) THEN
                tranno := 1;
            ELSE
                tranno := tranno + 1;
            END IF;

            obj_audit_clntpf.tranno := tranno;
            obj_audit_clntpf.systemdate := SYSDATE;
            obj_clntpf.usrprf := i_usrprf;
            obj_clntpf.jobnm := i_schedulename;
            obj_clntpf.datime := current_timestamp;

            INSERT INTO audit_clntpf VALUES obj_audit_clntpf; 
  */

      -- insert in  IG AUDIT_CLNTPF table end -

      -- insert in  IG AUDIT_CLNT table start -
      -- 新規登録、更新で項目値に変更がある場合は常に追加
/*
            obj_audit_clnt.unique_number := v_unq_audit_clntpf;
            obj_audit_clnt.clntcoy := obj_clntpf.clntcoy;
            obj_audit_clnt.clntnum := obj_clntpf.clntnum;
            obj_audit_clnt.clntpfx := obj_clntpf.clntpfx;
            obj_audit_clnt.jobnm := obj_clntpf.jobnm;

            obj_audit_clnt.newaddrtype := obj_clntpf.addrtype;
            obj_audit_clnt.newcltaddr01 := obj_clntpf.cltaddr01;
            obj_audit_clnt.newcltaddr02 := obj_clntpf.cltaddr02;
            obj_audit_clnt.newcltaddr03 := obj_clntpf.cltaddr03;
            obj_audit_clnt.newcltaddr04 := obj_clntpf.cltaddr04;
            obj_audit_clnt.newcltaddr05 := obj_clntpf.cltaddr05;
            obj_audit_clnt.newcltdob := obj_clntpf.cltdob;
            obj_audit_clnt.newcltphone01 := obj_clntpf.cltphone01;
            obj_audit_clnt.newcltphone02 := obj_clntpf.cltphone02;
            obj_audit_clnt.newcltstat := obj_clntpf.cltstat;
            obj_audit_clnt.newclttyp := obj_clntpf.clttype;
            obj_audit_clnt.newctrycode := obj_clntpf.ctrycode;
            OBJ_AUDIT_CLNT.NEWDIRMAIL := OBJ_CLNTPF.DIRMAIL;
            OBJ_AUDIT_CLNT.NEWGIVNAME := OBJ_CLNTPF.GIVNAME;
            OBJ_AUDIT_CLNT.NEWMAILING := OBJ_CLNTPF.MAILING;

            OBJ_AUDIT_CLNT.NEWSALUTL := OBJ_CLNTPF.SALUTL;
            obj_audit_clnt.newsurname := obj_clntpf.surname;
            obj_audit_clnt.oldaddrtype := NULL;
            obj_audit_clnt.oldcltaddr01 := NULL;
            obj_audit_clnt.oldcltaddr02 := NULL;
            obj_audit_clnt.oldcltaddr03 := NULL;
            obj_audit_clnt.oldcltaddr04 := NULL;
            OBJ_AUDIT_CLNT.OLDCLTADDR05 := NULL;
            OBJ_AUDIT_CLNT.OLDCLTDOB := NULL;
            OBJ_AUDIT_CLNT.OLDCLTPHONE01 := NULL;
            --CC6
            IF(TRIM(OBJ_AUDIT_CLNT.NEWCLTPHONE02) IS NULL) THEN
            OBJ_AUDIT_CLNT.OLDCLTPHONE02 := C_AUDIT_CLNT_OLDCLTPHONE02;
            ELSE
            OBJ_AUDIT_CLNT.OLDCLTPHONE02 := OBJ_AUDIT_CLNT.NEWCLTPHONE02;
            END IF;

            IF(TRIM(OBJ_AUDIT_CLNT.NEWCLTPHONE01) IS NULL) THEN
            OBJ_AUDIT_CLNT.OLDCLTPHONE01 := C_AUDIT_CLNT_OLDCLTPHONE01;
            ELSE
            OBJ_AUDIT_CLNT.OLDCLTPHONE01 := OBJ_AUDIT_CLNT.NEWCLTPHONE01;
            END IF;

            IF(TRIM(OBJ_AUDIT_CLNT.NEWSALUTL) IS NULL) THEN
            OBJ_AUDIT_CLNT.OLDSALUTL := C_AUDIT_CLNT_OLDSALUTL;
            ELSE
            OBJ_AUDIT_CLNT.OLDSALUTL := OBJ_AUDIT_CLNT.NEWSALUTL;
            END IF;

            IF(TRIM(OBJ_AUDIT_CLNT.NEWGIVNAME) IS NULL) THEN
            OBJ_AUDIT_CLNT.OLDGIVNAME := C_AUDIT_CLNT_OLDGIVNAME;
            ELSE
            OBJ_AUDIT_CLNT.OLDGIVNAME := OBJ_AUDIT_CLNT.NEWGIVNAME;
            END IF;

            IF(TRIM(OBJ_AUDIT_CLNT.NEWDIRMAIL) IS NULL) THEN
            OBJ_AUDIT_CLNT.OLDDIRMAIL := C_AUDIT_CLNT_OLDDIRMAIL;
            ELSE
            OBJ_AUDIT_CLNT.OLDDIRMAIL := OBJ_AUDIT_CLNT.NEWDIRMAIL;
            END IF; 

            IF(TRIM(OBJ_AUDIT_CLNT.NEWCLTDOB) IS NULL) THEN
            OBJ_AUDIT_CLNT.OLDCLTDOB := C_AUDIT_CLNT_OLDCLTDOB;
            ELSE
            OBJ_AUDIT_CLNT.OLDCLTDOB := OBJ_AUDIT_CLNT.NEWCLTDOB;
            END IF;

            IF(TRIM(OBJ_AUDIT_CLNT.NEWMAILING) IS NULL) THEN
            OBJ_AUDIT_CLNT.OLDMAILING := C_AUDIT_CLNT_OLDMAILING;
            ELSE
            OBJ_AUDIT_CLNT.OLDMAILING := OBJ_AUDIT_CLNT.NEWMAILING;
            END IF;

            OBJ_AUDIT_CLNT.OLDCLTSTAT := OBJ_AUDIT_CLNT.NEWCLTSTAT;
            OBJ_AUDIT_CLNT.OLDCLTTYP := C_AUDIT_CLNT_OLDCLTTYP;
            OBJ_AUDIT_CLNT.OLDCTRYCODE := C_AUDIT_CLNT_OLDCTRYCODE;
            OBJ_AUDIT_CLNT.OLDSURNAME := OBJ_AUDIT_CLNT.NEWSURNAME;
            --CC6

            SELECT
                 audit_clntp01.*
            BULK COLLECT
            INTO
                 audit_clntlist
            FROM
                 audit_clnt audit_clntp01
            INNER JOIN
                 (SELECT
                       MAX(systemdate)  max_systemdate
                  FROM
                      audit_clnt
                  WHERE
                      CLNTNUM = obj_clntpf.clntnum
                  AND CLNTPFX = obj_clntpf.clntpfx
                  AND CLNTCOY = obj_clntpf.clntcoy
                  AND NEWCLTTYP = obj_clntpf.cltind
                 ) audit_clntp02
            ON
                audit_clntp01.systemdate = audit_clntp02.max_systemdate
            WHERE
                  audit_clntp01.CLNTNUM = obj_clntpf.clntnum
                  AND audit_clntp01.CLNTPFX = obj_clntpf.clntpfx
                  AND audit_clntp01.CLNTCOY = obj_clntpf.clntcoy
                  AND audit_clntp01.NEWCLTTYP = obj_clntpf.cltind
            ;


            FOR indexitems IN 1 .. audit_clntlist.COUNT LOOP  -- 最新の履歴のNEW項目をOLD項目に設定する
                obj_audit_clnt.oldaddrtype := audit_clntlist(indexitems).newaddrtype;
                obj_audit_clnt.oldcltaddr01 := audit_clntlist(indexitems).newcltaddr01;
                obj_audit_clnt.oldcltaddr02 := audit_clntlist(indexitems).newcltaddr02;
                obj_audit_clnt.oldcltaddr03 := audit_clntlist(indexitems).newcltaddr03;
                obj_audit_clnt.oldcltaddr04 := audit_clntlist(indexitems).newcltaddr04;
                obj_audit_clnt.oldcltaddr05 := audit_clntlist(indexitems).newcltaddr05;
                obj_audit_clnt.oldcltdob := audit_clntlist(indexitems).newcltdob;
                obj_audit_clnt.oldcltphone01 := audit_clntlist(indexitems).newcltphone01;
                obj_audit_clnt.oldcltphone02 := audit_clntlist(indexitems).newcltphone02;
                obj_audit_clnt.oldcltstat := audit_clntlist(indexitems).newcltstat;
                obj_audit_clnt.oldclttyp := audit_clntlist(indexitems).newclttyp;
                obj_audit_clnt.oldctrycode := audit_clntlist(indexitems).newctrycode;
                obj_audit_clnt.olddirmail := audit_clntlist(indexitems).newdirmail;
                obj_audit_clnt.oldgivname := audit_clntlist(indexitems).newgivname;
                obj_audit_clnt.oldmailing := audit_clntlist(indexitems).newmailing;
                obj_audit_clnt.oldsalutl := audit_clntlist(indexitems).newsalutl;
                obj_audit_clnt.oldsurname := audit_clntlist(indexitems).newsurname;            
            END LOOP; 

            obj_audit_clnt.tranid := obj_clntpf.tranid;
            obj_audit_clnt.userid := i_usrprf;
            obj_audit_clnt.usrprf := obj_clntpf.usrprf;
            obj_audit_clnt.action := 'UPDATE';
            obj_audit_clnt.systemdate := SYSDATE;
            INSERT INTO audit_clnt VALUES obj_audit_clnt;
       */
       -- insert in  IG AUDIT_CLNT table end -

      -- insert in  IG CLEXPF table start-
           ---- clexpfは空レコードを出力しているので、更新の場合は何もしない
           ----Updateの時でも当該レコードが存在しない場合は追加するので、当該レコードの存在チェックを行う
           SELECT
                 count(*)
           INTO
                 i_clexpfcnt
           FROM
                 CLEXPF
           WHERE
                 clntpfx = o_defaultvalues('CLNTPFX')
             AND clntcoy = o_defaultvalues('CLNTCOY')
             AND clntnum = obj_clntpf.clntnum
           ;

           IF b_update = false OR i_clexpfcnt = 0 THEN
             --select SEQ_CLEXPF.nextval into v_pkValue from dual;
               v_pkValue := SEQ_CLEXPF.nextval; --CC7
      obj_clexpf.UNIQUE_NUMBER := v_pkValue;
               obj_clexpf.clntpfx := o_defaultvalues('CLNTPFX');
               obj_clexpf.clntcoy := o_defaultvalues('CLNTCOY');
               obj_clexpf.clntnum := obj_clntpf.clntnum;
               obj_clexpf.rdidtelno := c_clexpf_rdidtelno;
               obj_clexpf.rmblphone := c_clexpf_rmblphone;
               obj_clexpf.rpager := c_clexpf_rpager;
               obj_clexpf.faxno := c_clexpf_faxno;
               obj_clexpf.rinternet := c_clexpf_rinternet;
               obj_clexpf.rtaxidnum := c_clexpf_rtaxidnum;
               obj_clexpf.rstaflag := c_clexpf_rstaflag;
               obj_clexpf.splindic := c_clexpf_splindic;
               obj_clexpf.zspecind := c_clexpf_zspecind;
               obj_clexpf.oldidno := c_clexpf_oldidno;
               obj_clexpf.jobnm := i_schedulename;
               obj_clexpf.usrprf := i_usrprf;
               obj_clexpf.datime := SYSDATE;
               obj_clexpf.validflag := o_defaultvalues('VALIDFLAG');
               obj_clexpf.othidno := c_clexpf_othidno;
               obj_clexpf.othidtype := c_clexpf_othidtype;
               obj_clexpf.amlstatus := c_clexpf_amlstatus;
               obj_clexpf.zdmailto01 := c_clexpf_zdmailto01;
               obj_clexpf.zdmailto02 := c_clexpf_zdmailto02;
               obj_clexpf.zdmailcc01 := c_clexpf_zdmailcc01;
               obj_clexpf.zdmailcc02 := c_clexpf_zdmailcc02;
               obj_clexpf.zdmailcc03 := c_clexpf_zdmailcc03;
               obj_clexpf.zdmailcc04 := c_clexpf_zdmailcc04;
               obj_clexpf.zdmailcc05 := c_clexpf_zdmailcc05;
               obj_clexpf.zdmailcc06 := c_clexpf_zdmailcc06;
               obj_clexpf.zdmailcc07 := c_clexpf_zdmailcc07;
               obj_clexpf.rinternet2 := c_clexpf_rinternet2;
               obj_clexpf.telectrycode := c_clexpf_telectrycode;
               obj_clexpf.zfathername := c_clexpf_zfathername;
               INSERT INTO clexpf VALUES obj_clexpf;
           ---ELSE
               ---DBMS_Output.PUT_LINE('(11)[When clientpf is to be updated, nothing will be done with clexpf because all the columns of clexpf are empty] IG ClientNum :' || v_clntnum || ', obj_client.clntkey:' || obj_client.clntkey);
           END IF;


      -- insert in  IG CLEXPF table end-
      -- insert in  IG AUDIT_CLEXPF table start-
            ---clexpfは空レコードを出力しているので、更新の場合は何もしない
            ----Updateの時でも当該レコードが存在しない場合は追加するので、当該レコードの存在チェックを行う
/*         
		 SELECT
                 count(*)
           INTO
                 i_audit_clexpfcnt
           FROM
                AUDIT_CLEXPF
           WHERE
                 newclntpfx = o_defaultvalues('CLNTPFX')
             AND newclntcoy = o_defaultvalues('CLNTCOY')
             AND newclntnum = obj_clntpf.clntnum
           ;*/

/*
           IF b_update = false OR i_audit_clexpfcnt = 0 THEN
               --SELECT
               --    seq_clexpf.NEXTVAL
               --INTO v_unq_audit_clexpf
               --FROM
               --    dual;
               v_unq_audit_clexpf := seq_clexpf.NEXTVAL; --CC7
               obj_audit_clexpf.unique_number := v_unq_audit_clexpf;
               obj_audit_clexpf.oldclntpfx := NULL;
               obj_audit_clexpf.oldclntcoy := NULL;
               obj_audit_clexpf.oldclntnum := obj_clntpf.clntnum;
               obj_audit_clexpf.oldrdidtelno := NULL;
               obj_audit_clexpf.oldrmblphone := NULL;
               obj_audit_clexpf.oldrpager := NULL;
               obj_audit_clexpf.oldfaxno := NULL;
               obj_audit_clexpf.oldrinternet := NULL;
               obj_audit_clexpf.oldrtaxidnum := NULL;
               obj_audit_clexpf.oldrstaflag := NULL;
               obj_audit_clexpf.oldsplindic := NULL;
               obj_audit_clexpf.oldzspecind := NULL;
               obj_audit_clexpf.oldoldidno := NULL;
              obj_audit_clexpf.oldusrprf := NULL;
               obj_audit_clexpf.oldjobnm := NULL;
               obj_audit_clexpf.olddatime := NULL;
               obj_audit_clexpf.oldvalidflag := NULL;
               obj_audit_clexpf.newclntpfx := obj_clexpf.clntpfx;
               obj_audit_clexpf.newclntcoy := obj_clexpf.clntcoy;
               obj_audit_clexpf.newclntnum := obj_clexpf.clntnum;
               obj_audit_clexpf.newrdidtelno := obj_clexpf.rdidtelno;
               obj_audit_clexpf.newrmblphone := obj_clexpf.rmblphone;
               obj_audit_clexpf.newrpager := obj_clexpf.rpager;
               obj_audit_clexpf.newfaxno := obj_clexpf.faxno;
               obj_audit_clexpf.newrinternet := obj_clexpf.rinternet;
               obj_audit_clexpf.newrtaxidnum := SUBSTRB(obj_clexpf.rtaxidnum, 1, 20);
               obj_audit_clexpf.newrstaflag := obj_clexpf.rstaflag;
               obj_audit_clexpf.newsplindic := obj_clexpf.splindic;
               obj_audit_clexpf.newzspecind := obj_clexpf.zspecind;
               obj_audit_clexpf.newoldidno := obj_clexpf.oldidno;
               obj_audit_clexpf.newusrprf := obj_clexpf.usrprf;
               obj_audit_clexpf.newjobnm := obj_clexpf.jobnm;
               obj_audit_clexpf.newdatime := obj_clexpf.datime;
               obj_audit_clexpf.newvalidflag := obj_clexpf.validflag;
               obj_audit_clexpf.userid := i_usrprf;
               obj_audit_clexpf.action := 'INSERT';
               obj_audit_clexpf.tranno := tranno;
               obj_audit_clexpf.systemdate := SYSDATE;
               INSERT INTO audit_clexpf VALUES obj_audit_clexpf;
            END IF;
*/
      -- insert in  IG AUDIT_CLEXPF table end-

      -- insert in  IG ZCLNPF table start-
            ---新規登録時はレコードが追加され、変更では追加せずにそのレコードを書き換える。
            ---更新パターンの時に当該レコードがない場合を考慮した、念のため処理
            IF b_update = true THEN
               SELECT
                    count(*)
               INTO
                    i_zclnfcnt
               FROM
                    view_zclnpf
               WHERE
                    CLNTPFX = obj_clntpf.clntpfx
                AND CLNTCOY = obj_clntpf.clntcoy
                AND CLNTNUM = obj_clntpf.clntnum
               ;
            END IF;

            IF b_update = false OR i_zclnfcnt = 0 THEN
               obj_zclnf.clntpfx := o_defaultvalues('CLNTPFX');
               obj_zclnf.clntcoy := o_defaultvalues('CLNTCOY');
               obj_zclnf.clntnum := obj_clntpf.clntnum;
               obj_zclnf.cltdob := obj_clntpf.cltdob;
               obj_zclnf.lsurname := obj_client.lsurname;
               obj_zclnf.lgivname := obj_clntpf.lgivname;
               obj_zclnf.zkanasnm := obj_clntpf.zkanasnm;
               obj_zclnf.zkanagnm := obj_clntpf.zkanasnm;
               obj_zclnf.cltsex := c_zclnf_cltsex;
               obj_zclnf.cltpcode := obj_clntpf.cltpcode;
               obj_zclnf.zkanaddr01 := obj_clntpf.zkanaddr01;
               obj_zclnf.zkanaddr02 := obj_clntpf.zkanaddr02;
               obj_zclnf.zkanaddr03 := obj_clntpf.zkanaddr03;
               OBJ_ZCLNF.ZKANADDR04 := OBJ_CLNTPF.ZKANADDR04;
               OBJ_ZCLNF.CLTADDR01 := OBJ_CLIENT.CLTADDR01;
               OBJ_ZCLNF.CLTADDR02 := OBJ_CLIENT.CLTADDR02;
               --CC6
               IF(TRIM(OBJ_CLIENT.CLTADDR03) IS NULL) THEN
               OBJ_ZCLNF.CLTADDR03 := C_ZCLNPF_CLTADDR03;
               ELSE
               OBJ_ZCLNF.CLTADDR03 := OBJ_CLIENT.CLTADDR03;
               END IF;

               IF(TRIM(OBJ_CLNTPF.ZOCCDSC) IS NULL) THEN
               OBJ_ZCLNF.ZOCCDSC := C_ZCLNPF_ZOCCDSC;
               ELSE
               OBJ_ZCLNF.ZOCCDSC := OBJ_CLNTPF.ZOCCDSC;
               END IF;

               IF(TRIM(OBJ_CLNTPF.OCCPCLAS) IS NULL) THEN
               OBJ_ZCLNF.OCCPCLAS := C_ZCLNPF_OCCPCLAS;
               ELSE
               OBJ_ZCLNF.OCCPCLAS := OBJ_CLNTPF.OCCPCLAS;
               END IF;

               IF(TRIM(obj_clntpf.zworkplce) IS NULL) THEN
               OBJ_ZCLNF.ZWORKPLCE := C_ZCLNPF_ZWORKPLCE;
               ELSE
               OBJ_ZCLNF.ZWORKPLCE := OBJ_CLNTPF.ZWORKPLCE;
               END IF;
               --CC6

               obj_zclnf.cltaddr04 := obj_client.cltaddr04;
               obj_zclnf.cltphone01 := obj_clntpf.cltphone01;
               OBJ_ZCLNF.CLTPHONE02 := OBJ_CLNTPF.CLTPHONE02;
               OBJ_ZCLNF.OCCPCODE := OBJ_CLNTPF.OCCPCODE;
               obj_zclnf.cltdobflag := c_zclnf_cltdobflag;
               obj_zclnf.lsurnameflag := c_zclnf_lsurnameflag;
               obj_zclnf.lgivnameflag := c_zclnf_lgivnameflag;
               obj_zclnf.zkanasnmflag := c_zclnf_zkanasnmflag;
               obj_zclnf.zkanagnmflag := c_zclnf_zkanagnmflag;
               obj_zclnf.cltsexflag := c_zclnf_cltsexflag;
               obj_zclnf.cltpcodeflag := c_zclnf_cltpcodeflag;
               obj_zclnf.zkanaddr01flag := c_zclnf_zkanaddr01flag;
               obj_zclnf.zkanaddr02flag := c_zclnf_zkanaddr02flag;
               obj_zclnf.zkanaddr03flag := c_zclnf_zkanaddr03flag;
               obj_zclnf.zkanaddr04flag := c_zclnf_zkanaddr04flag;
               obj_zclnf.cltaddr01flag := c_zclnf_cltaddr01flag;
               obj_zclnf.cltaddr02flag := c_zclnf_cltaddr02flag;
               obj_zclnf.cltaddr03flag := c_zclnf_cltaddr03flag;
               obj_zclnf.cltaddr04flag := c_zclnf_cltaddr04flag;
               obj_zclnf.cltphone01flag := c_zclnf_cltphone01flag;
               obj_zclnf.cltphone02flag := c_zclnf_cltphone02flag;
               obj_zclnf.zworkplceflag := c_zclnf_zworkplceflag;
               obj_zclnf.occpcodeflag := c_zclnf_occpcodeflag;
               obj_zclnf.occpclasflag := c_zclnf_occpclasflag;
               obj_zclnf.zoccdscflag := c_zclnf_zoccdscflag;
               obj_zclnf.effdate := obj_clntpf.srdate;
               obj_zclnf.usrprf := i_usrprf;
               obj_zclnf.jobnm := i_schedulename;
               obj_zclnf.datime := current_timestamp;
               INSERT INTO view_zclnpf VALUES obj_zclnf;
            ELSE
               UPDATE
                     view_zclnpf
               SET
                --CC8 clntnum = obj_clntpf.clntnum,
                  cltdob = obj_clntpf.cltdob
                  ,lsurname = obj_client.lsurname
                --CC8  ,lgivname = obj_clntpf.lgivname
                  ,zkanasnm = obj_clntpf.zkanasnm
                --CC8  ,zkanagnm = obj_clntpf.zkanasnm
                  ,cltpcode = obj_clntpf.cltpcode
                  ,zkanaddr01 = obj_clntpf.zkanaddr01
                  ,zkanaddr02 = obj_clntpf.zkanaddr02
                  ,zkanaddr03 = obj_clntpf.zkanaddr03
                  ,zkanaddr04 = obj_clntpf.zkanaddr04
                  ,cltaddr01 = obj_client.cltaddr01
                  ,cltaddr02 = obj_client.cltaddr02
                  ,cltaddr03 = obj_client.cltaddr03
                  ,cltaddr04 = obj_client.cltaddr04
                  ,cltphone01 = obj_clntpf.cltphone01
                  ,CLTPHONE02 = OBJ_CLNTPF.CLTPHONE02
                 --CC8 ,zworkplce = obj_clntpf.zworkplce
                 --CC8 ,OCCPCODE = OBJ_CLNTPF.OCCPCODE
                  ,
                  --CC6
                  /*CC8
                  ZOCCDSC =  CASE
                        WHEN TRIM(OBJ_CLNTPF.ZOCCDSC) IS NULL THEN
                          C_ZCLNPF_ZOCCDSC
                        ELSE
                          OBJ_CLNTPF.ZOCCDSC
                     END*/
                  --CC6
                 --CC8 ,occpclas = obj_clntpf.occpclas
                 --CC8 ,effdate = obj_clntpf.srdate
                   usrprf = i_usrprf
                  ,jobnm = i_schedulename
                  ,datime = current_timestamp
               WHERE
                    CLNTPFX = obj_clntpf.clntpfx
                AND CLNTCOY = obj_clntpf.clntcoy
                AND CLNTNUM = obj_clntpf.clntnum
               ;
            END IF;


      -- insert in  IG ZCLNPF table end-

      -- VERSIONPF Insertion

            obj_versionpf.tranno := 1;
            obj_versionpf.clntnum := v_clntnum;
            v_SEQ_VERSIONPF             :=   SEQ_VERSIONPF.nextval ;
            obj_versionpf.unique_number := v_SEQ_VERSIONPF;
            INSERT INTO versionpf VALUES obj_versionpf;

      -- update IG  tables End

        END IF;
      END LOOP;
      EXIT WHEN corporateclient_cursor%notfound;  --CC7
      COMMIT; --CC7
    END LOOP; --CC7
    COMMIT; --CC7
    CLOSE corporateclient_cursor;
    dbms_output.put_line('Procedure execution time = '
                       ||(dbms_utility.get_time - v_timestart) / 100);

  exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'BQ9Q7_CL01_CORPCLT : ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm ||' clntnum :=' || v_clntnum || ' clntkey :'||TRIM(obj_client.clntkey);

    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);

    commit;
    raise;

END BQ9Q7_CL01_CORPCLT;