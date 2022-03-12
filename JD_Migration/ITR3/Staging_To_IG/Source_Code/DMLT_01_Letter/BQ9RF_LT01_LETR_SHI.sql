create or replace PROCEDURE                               "BQ9RF_LT01_LETR" (i_schedulename   IN VARCHAR2,
                                            i_schedulenumber IN VARCHAR2,
                                            i_zprvaldyn      IN VARCHAR2,
                                            i_company        IN VARCHAR2,
                                            i_userprofile    IN VARCHAR2,
                                            i_branch         IN VARCHAR2,
                                            i_transcode      IN VARCHAR2,
                                            i_vrcmTermid     IN VARCHAR2) AS
/***************************************************************************************************
  * Amenment History: LT01 Letters 
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       LT1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0518     ITR-4 :   LT2 - LOT2 CHANGE
  * 0527     PS        LT3   Set ZENVSEQNO to 0000.
  *****************************************************************************************************/                                
  ----------------------------VARIABLES DECLARATION START-------------------------------------------------------------
  v_timestart       number := dbms_utility.get_time; --Timecheck
  v_lettype         titdmgletter.lettype@DMSTAGEDBLINK%TYPE;
  v_lreqdate        titdmgletter.lreqdate@DMSTAGEDBLINK%TYPE;
  v_chdrnum         titdmgletter.chdrnum@DMSTAGEDBLINK%TYPE;
  v_zdspcatg        titdmgletter.zdspcatg@DMSTAGEDBLINK%TYPE;
  v_zletvern        titdmgletter.zletvern@DMSTAGEDBLINK%TYPE;
  v_zletdest        titdmgletter.zletdest@DMSTAGEDBLINK%TYPE;
  v_zcomaddr        titdmgletter.zcomaddr@DMSTAGEDBLINK%TYPE;
  v_zletcat         titdmgletter.zletcat@DMSTAGEDBLINK%TYPE;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
  v_zapstmpd        titdmgletter.ZAPSTMPD@DMSTAGEDBLINK%TYPE;
 -- v_zdesper         titdmgletter.ZDESPER@DMSTAGEDBLINK%TYPE; MSD CHANGE
  v_zdesper         LETCPF.ZDESPER%type; --MSD change
  ------- mps 4/13 v_unizdesper         LETCPF.ZDESPER%type;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/
  v_refkey          VARCHAR2(50 CHAR);
  v_errorcount      NUMBER(1) DEFAULT 0;
  v_isvalid         NUMBER(1) DEFAULT 0;
  v_isdatevalid     VARCHAR2(20 CHAR);
  v_isduplicate     NUMBER(1) DEFAULT 0;
  v_isexist         NUMBER(1) DEFAULT 0;
  v_isanyerror      VARCHAR2(1) DEFAULT 'N';
  v_migrationprefix VARCHAR2(2);
  v_clientnum       VARCHAR2(8);
  v_chdrpfx         VARCHAR2(20 CHAR);
  v_letrseq         NUMBER(7) DEFAULT 1;
  --  v_zlettrnotemp          NUMBER(5) DEFAULT 1;
  v_zlettrno NUMBER(5) DEFAULT 0;
  v_space    VARCHAR2(2) DEFAULT ' ';
  v_cnt      NUMBER(2) DEFAULT 0;
  temp_val NUMBER DEFAULT 0;

  -----------------------VARIABLE FOR DEFAULT VALUS-----------------------------
  v_clntcoy  VARCHAR2(20 CHAR);
  v_reqcoy   VARCHAR2(20 CHAR);
  v_letstat  VARCHAR2(20 CHAR);
  v_lprtdate VARCHAR2(20 CHAR);
  v_letokey  VARCHAR2(20 CHAR);
  v_rdocpfx  VARCHAR2(20 CHAR);
  v_rdoccoy  VARCHAR2(20 CHAR);
  v_rdocnum  VARCHAR2(20 CHAR);
  v_tranno   VARCHAR2(20 CHAR);
  v_servunit VARCHAR2(20 CHAR);
  v_despnum  VARCHAR2(20 CHAR);
  v_branch   VARCHAR2(20 CHAR);
  v_chdrcoy  VARCHAR2(20 CHAR);
  v_hsublet  VARCHAR2(20 CHAR);
  v_zzcopies VARCHAR2(20 CHAR);
  v_zduplex  VARCHAR2(20 CHAR);
  v_zenvseqn VARCHAR2(20 CHAR);
  v_prevCHDRNUM VARCHAR(8 CHAR);
  v_prevLETTYPE VARCHAR(8 CHAR);
   v_pkValue  letcpf.unique_number%type;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
  v_zrmdlett  VARCHAR2(20 CHAR);
  v_zgoodbye  VARCHAR2(20 CHAR);
  v_quoteno   VARCHAR2(20 CHAR);
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/


  ------------------------------------------------------------------------------
  ----------------------------VARIABLES DECLARATION END----------------------------------------------------------------

  ----------------------------DEFAULT VALUES FROM TQ9Q9 START----------------------------------------------------------
  obj_letcpf letcpf%rowtype;

  ----------------------------DEFAULT VALUES FROM TQ9Q9 END------------------------------------------------------------

  --------------------------------CONSTANTS----------------------------------------------------------------------------
  c_prefix CONSTANT VARCHAR2(2) := get_migration_prefix('LETR', i_company);
  --c_prefix            CONSTANT VARCHAR2(2) := 'LT';
  -----------------------------ERROR CONSTANTS-------------------------------------------------------------------------
  c_errorcount CONSTANT NUMBER := 5;
  c_e186              CONSTANT VARCHAR2(4) := 'E186'; /*Field must be entered*/
  c_z035  CONSTANT VARCHAR2(4) := 'RQMF'; /*Must be in TR383 */
  c_z013  CONSTANT VARCHAR2(4) := 'RQLT'; /*Invalid Date*/
  c_z031  CONSTANT VARCHAR2(4) := 'RQMB'; /*Policy is not yet migrated*/
  c_z020  CONSTANT VARCHAR2(4) := 'RQM0'; /*Item not in table*/
  c_z072  CONSTANT VARCHAR2(4) := 'RQNG'; /*Missing letter version number*/
  c_z034  CONSTANT VARCHAR2(4) := 'RQME'; /*Invalid Dest Letr Type*/
  c_z099  CONSTANT VARCHAR2(4) := 'RQO6'; /*Duplicated record found*/
  c_rqli  CONSTANT VARCHAR2(4) := 'RQLI'; /*Client not yet migrated */
  c_RQYF  CONSTANT VARCHAR2(4) := 'RQYF'; /*Must be valid in TQ9I3 */
  c_RQYR  CONSTANT VARCHAR2(4) := 'RQYR'; /*Item not in table TQ9IM*/
  c_RQYS  CONSTANT VARCHAR2(4) := 'RQYS'; /*Item not in table TQ9IN*/
  c_RQYT  CONSTANT VARCHAR2(4) := 'RQYT'; /*Item not in table TQ9IU*/

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
  c_RR32  CONSTANT VARCHAR2(4) := 'RR32'; /*Item not in table TQ9IR*/
  C_Z028 constant varchar2(4) := 'RQM8'; /*Value must be 塑? or 鮮?    */
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/
  c_bq9rf CONSTANT VARCHAR2(5) := 'BQ9RF';

  --------------------------COMMON FUNCTION START-----------------------------------------------------------------------
  v_tablenametemp VARCHAR2(10);
  v_tablename     VARCHAR2(10);
  itemexist       pkg_dm_common_operations.itemschec;
  o_errortext     pkg_dm_common_operations.errordesc;
  i_zdoe_info     pkg_dm_common_operations.obj_zdoe;
  o_defaultvalues pkg_dm_common_operations.defaultvaluesmap;
  checkdupl       pkg_common_dmlt.ltduplicate;
  getClntnum      pkg_common_dmlt.newzdclpf; -- Rehearsal Changes
  TYPE ercode_tab IS TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
  t_ercode ercode_tab;
  TYPE errorfield_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorfield errorfield_tab;
  TYPE errormsg_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errormsg errormsg_tab;
  TYPE errorfieldvalue_tab IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  t_errorfieldval errorfieldvalue_tab;
  TYPE errorprogram_tab IS TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
  t_errorprogram errorprogram_tab;
  TYPE zdrppf_typ IS TABLE OF VARCHAR(8) INDEX BY BINARY_INTEGER;
  zdrppf_list zdrppf_typ;

  --------------------------COMMON FUNCTION END-------------------------------------------------------------------------
  CURSOR c_lettercursor IS
    --SELECT * FROM titdmgletter@DMSTAGEDBLINK;
    --SELECT t.*, ROW_NUMBER() OVER (PARTITION BY t.chdrnum, t.lettype order by t.chdrnum, t.lettype) letrseq
    --FROM titdmgletter@DMSTAGEDBLINK t;

    SELECT t.*, ROW_NUMBER() OVER (PARTITION BY t.chdrnum, t.lettype order by t.chdrnum, t.lettype) letrseq 
    FROM (SELECT A.*,B.CHDRNUM as zdrppf_chdrnum  FROM TITDMGLETTER@DMSTAGEDBLINK A LEFT OUTER JOIN PAZDRPPF B ON A.CHDRNUM = B.CHDRNUM) t;


  o_letterobj c_lettercursor%rowtype;
BEGIN

  --------------------------COMMON FUNCTION CALLING START-----------------------------------------------------------------------


											  pkg_dm_common_operations.getdefval(i_module_name   => c_bq9rf,
                                     o_defaultvalues => o_defaultvalues);

  pkg_dm_common_operations.checkitemexist(i_module_name => 'DMLT',
                                          itemexist     => itemexist);
  pkg_dm_common_operations.geterrordesc(i_module_name => 'DMLT',
                                        o_errortext   => o_errortext);

  v_tablenametemp := 'ZDOE' || trim(c_prefix) ||
                     lpad(trim(i_schedulenumber), 4, '0');

  v_tablename := trim(v_tablenametemp);
  pkg_dm_common_operations.createzdoepf(i_tablename => v_tablename);
    pkg_common_dmlt.checkcpdup(checkdupl => checkdupl);

  pkg_common_dmlt.getClntnum(getClntnum => getClntnum); --- Rehearsal Changes

  --------------------------COMMON FUNCTION CALLING END-----------------------------------------------------------------------

  ------------------FETCH ALL DEFAULT VALUES FROM TABLE TQ9Q9, ITEM BQ9TL-----------------------------------------------------
  v_reqcoy   := o_defaultvalues('REQCOY');
  v_letstat  := o_defaultvalues('LETSTAT');
  v_clntcoy  := o_defaultvalues('CLNTCOY');
  v_rdocpfx  := o_defaultvalues('RDOCPFX');
  v_rdoccoy  := o_defaultvalues('RDOCCOY');
  v_tranno   := o_defaultvalues('TRANNO');
  v_servunit := o_defaultvalues('SERVUNIT');
  v_chdrcoy  := o_defaultvalues('CHDRCOY');
  v_zzcopies := o_defaultvalues('ZZCOPIES');
  v_zduplex  := o_defaultvalues('ZDUPLEX');

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
  v_zrmdlett  := o_defaultvalues('ZRMDLETT');
  v_zgoodbye  := o_defaultvalues('ZGOODBYE');
  v_quoteno   := o_defaultvalues('QUOTENO');
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/

  --SELECT TRIM(chdrnum) BULK COLLECT INTO zdrppf_list FROM Jd1dta.zdrppf;

  -----------------------------OPEN CURSOR------------------------------------------------------------------------------------


  OPEN c_lettercursor;
<<skiprecord>>
  LOOP
    FETCH c_lettercursor
      INTO o_letterobj;
    EXIT WHEN c_lettercursor%notfound;

    ---------------------------INITIALIZATION START----------------------------------------------------------------------------
    v_lettype  := trim(o_letterobj.lettype);
    v_lreqdate := trim(o_letterobj.lreqdate);
    v_chdrnum  := trim(o_letterobj.chdrnum);
    v_zdspcatg := trim(o_letterobj.zdspcatg);
    v_zletvern := trim(o_letterobj.zletvern);
    v_zletdest := trim(o_letterobj.zletdest);
    v_zcomaddr := trim(o_letterobj.zcomaddr);
    v_zletcat  := trim(o_letterobj.zletcat);

    v_lprtdate := trim(o_letterobj.lreqdate);
    v_letokey  := v_space;
    v_rdocnum  := trim(o_letterobj.chdrnum);
    v_despnum  := v_space;
    v_branch   := trim(i_branch);
    v_hsublet  := trim(o_letterobj.lettype);
    v_zenvseqn := v_space;
    v_letrseq  := TO_NUMBER(o_letterobj.letrseq);

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
    --v_zapstmpd := trim(o_letterobj.zapstmpd);
    v_zapstmpd := 'N';
   -- v_zdesper  := trim(o_letterobj.zdesper); MSD change
    v_zdesper := 0;--MSD change
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/

    ----REFERENCE KEY FOR LETTERS WILL BE THE COMBINATION OF THE FOLLWING FIELDS------
    v_refkey := v_chdrnum || '-' || v_lettype || '-' || v_zletvern || '-' ||
                v_lreqdate;
    v_isanyerror := 'N';
    v_errorcount := 0;
    t_ercode(1) := NULL;
    t_ercode(2) := NULL;
    t_ercode(3) := NULL;
    t_ercode(4) := NULL;
    t_ercode(5) := NULL;

    i_zdoe_info              := NULL;
    i_zdoe_info.i_zfilename  := 'TITDMGLETTER';
    i_zdoe_info.i_prefix     := c_prefix;
    i_zdoe_info.i_scheduleno := i_schedulenumber;
    i_zdoe_info.i_refkey     := v_refkey;
    i_zdoe_info.i_tablename  := v_tablename;


    ---------------------------INITIALIZATION END-------------------------------------------------------------------------------

    ------VALIDATION - "FIELD MUST NOT BE BLANK" FOR ALL FIELDS STARTS----------------------------------------------------------
    --        IF
    --            v_lettype IS NULL
    --        THEN
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_e186;
    --            t_errorfield(v_errorcount) := 'LETTYPE';
    --            t_errormsg(v_errorcount) := o_errortext(c_e186);
    --            t_errorfieldval(v_errorcount) := v_lettype;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;

    --        IF
    --            v_lreqdate IS NULL
    --        THEN
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_e186;
    --            t_errorfield(v_errorcount) := 'LREQDATE';
    --            t_errormsg(v_errorcount) := o_errortext(c_e186);
    --            t_errorfieldval(v_errorcount) := v_lreqdate;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;

    --        IF
    --            v_chdrnum IS NULL
    --        THEN
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_e186;
    --            t_errorfield(v_errorcount) := 'CHDRNUM';
    --            t_errormsg(v_errorcount) := o_errortext(c_e186);
    --            t_errorfieldval(v_errorcount) := v_chdrnum;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;

    --        IF
    --            v_zdspcatg IS NULL
    --        THEN
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_e186;
    --            t_errorfield(v_errorcount) := 'ZDSPCATG';
    --            t_errormsg(v_errorcount) := o_errortext(c_e186);
    --            t_errorfieldval(v_errorcount) := v_zdspcatg;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;

    --        IF
    --            v_zletdest IS NULL
    --        THEN
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_e186;
    --            t_errorfield(v_errorcount) := 'ZLETDEST';
    --            t_errormsg(v_errorcount) := o_errortext(c_e186);
    --            t_errorfieldval(v_errorcount) := v_zletdest;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;

    --        IF
    --            v_zcomaddr IS NULL
    --        THEN
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_e186;
    --            t_errorfield(v_errorcount) := 'ZCOMADDR';
    --            t_errormsg(v_errorcount) := o_errortext(c_e186);
    --            t_errorfieldval(v_errorcount) := v_zcomaddr;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;

    --        IF
    --            v_zletcat IS NULL
    --        THEN
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_e186;
    --            t_errorfield(v_errorcount) := 'ZLETCAT';
    --            t_errormsg(v_errorcount) := o_errortext(c_e186);
    --            t_errorfieldval(v_errorcount) := v_zletcat;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;

    --        IF
    --            v_zletvern IS NULL
    --        THEN
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_z072;
    --            t_errorfield(v_errorcount) := 'ZLETVERN';
    --            t_errormsg(v_errorcount) := o_errortext(c_z072);
    --            t_errorfieldval(v_errorcount) := v_zletvern;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;
    -------VALIDATION - "FIELD MUST NOT BE BLANK" FOR ALL FIELDS ENDS---------------------------------------------------------

    -------VALIDATION - DUPLICATE RECORD--------------------------------------------------------------------------------------
/* SELECT COUNT(recidxletters)
      INTO v_isduplicate
      FROM Jd1dta.zdltpf
     WHERE rtrim(chdrnum) = v_chdrnum
       AND rtrim(hlettype) = v_lettype
       AND rtrim(lreqdate) = v_lreqdate
       AND rtrim(zletvern) = v_zletvern;

    IF v_isduplicate > 0 THEN*/
    select temp_seq.nextval into temp_val from dual;

    IF (checkdupl.exists(TRIM(v_chdrnum) || TRIm(v_lettype) ||
                         TRIM(v_lreqdate) || TRIM(v_zletvern))) THEN
      v_isanyerror                 := 'Y';
      i_zdoe_info.i_indic          := 'E';
      i_zdoe_info.i_error01        := c_z099;
      i_zdoe_info.i_errormsg01     := o_errortext(c_z099);
      i_zdoe_info.i_errorfield01   := 'REFKEY';
      i_zdoe_info.i_fieldvalue01   := v_refkey;
      i_zdoe_info.i_errorprogram01 := i_schedulename;
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
      CONTINUE skiprecord;
    END IF;

    -------[START] VALIDATE ALL FIELDS COMING FROM STAGE DB - TITDMGLETTER---------------------------------------------------------

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
  -------"LETTER TYPE" Must not be blank.--------------
          IF
                v_lettype IS NULL
            THEN
                v_isanyerror := 'Y';
                v_errorcount := v_errorcount + 1;
                t_ercode(v_errorcount) := c_e186;
                t_errorfield(v_errorcount) := 'LETTYPE';
                t_errormsg(v_errorcount) := o_errortext(c_e186);
                t_errorfieldval(v_errorcount) := v_lettype;
                t_errorprogram(v_errorcount) := i_schedulename;
                IF
                    v_errorcount >= c_errorcount
                THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/

    -------"LETTER TYPE" Must be A valid item in TQ9I3--------------
    IF NOT (itemexist.EXISTS(trim('TQ9I3') || trim(v_lettype) || i_company)) THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_RQYF;
      t_errorfield(v_errorcount) := 'LETTYPE';
      t_errormsg(v_errorcount) := o_errortext(c_RQYF);
      t_errorfieldval(v_errorcount) := v_lettype;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
 -----"LETTER REQUEST DATE" Must not be blank----------------------------
             IF
                v_lreqdate IS NULL
            THEN
                v_isanyerror := 'Y';
                v_errorcount := v_errorcount + 1;
                t_ercode(v_errorcount) := c_e186;
                t_errorfield(v_errorcount) := 'LREQDATE';
                t_errormsg(v_errorcount) := o_errortext(c_e186);
                t_errorfieldval(v_errorcount) := v_lreqdate;
                t_errorprogram(v_errorcount) := i_schedulename;
                IF
                    v_errorcount >= c_errorcount
                THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/

-----"LETTER REQUEST DATE" Must be a valid Date.-------------------------   
    v_isdatevalid := validate_date(v_lreqdate);
    IF v_isdatevalid <> 'OK' THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_z013;
      t_errorfield(v_errorcount) := 'LREQDATE';
      t_errormsg(v_errorcount) := o_errortext(c_z013);
      t_errorfieldval(v_errorcount) := v_lreqdate;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
 ----"CONTRACT NUMBER" Must not be blank---------------------------------
            IF
                v_chdrnum IS NULL
            THEN
                v_isanyerror := 'Y';
                v_errorcount := v_errorcount + 1;
                t_ercode(v_errorcount) := c_e186;
                t_errorfield(v_errorcount) := 'CHDRNUM';
                t_errormsg(v_errorcount) := o_errortext(c_e186);
                t_errorfieldval(v_errorcount) := v_chdrnum;
                t_errorprogram(v_errorcount) := i_schedulename;
                IF
                    v_errorcount >= c_errorcount
                THEN
                    GOTO insertzdoe;
                END IF;
            END IF; 
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/ 

    ----"CONTRACT NUMBER" Must be existing------------------------------------------
    --VALIDATION ON CHDRNUM-IF THIS IS NOT PRESENT IN "ZDRPPF-REGISTRY TABLE OF POLICY" THEN THROW ERROR "POLICY YET NOT MIGRATED"
    --BECAUSE POLICY SHOULD BE MIGRATED FIRST BEFORE  PROCEEDING MIGRATION OF LETTERS.

    --v_isexist := 0;
    --FOR i IN zdrppf_list.first .. zdrppf_list.last LOOP
      --IF v_chdrnum = zdrppf_list(i) THEN
        --v_isexist := 1;
      --END IF;
    --END LOOP;

    --IF v_isexist = 0 THEN
    IF TRIM(o_letterobj.zdrppf_chdrnum) IS NULL THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_z031;
      t_errorfield(v_errorcount) := 'CHDRNUM';
      t_errormsg(v_errorcount) := o_errortext(c_z031);
      t_errorfieldval(v_errorcount) := v_chdrnum;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
----"ZDSPCATG	Mail Type" Must not be blank------------------------------
            IF
                v_zdspcatg IS NULL
            THEN
                v_isanyerror := 'Y';
                v_errorcount := v_errorcount + 1;
                t_ercode(v_errorcount) := c_e186;
                t_errorfield(v_errorcount) := 'ZDSPCATG';
                t_errormsg(v_errorcount) := o_errortext(c_e186);
                t_errorfieldval(v_errorcount) := v_zdspcatg;
                t_errorprogram(v_errorcount) := i_schedulename;
                IF
                    v_errorcount >= c_errorcount
                THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/ 

----"ZDSPCATG	Mail Type" Must be valid item in TQ9IM ? Despatch Category.--
    IF NOT
        (itemexist.EXISTS(trim('TQ9IM') || trim(v_zdspcatg) || i_company)) THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_RQYR;
      t_errorfield(v_errorcount) := 'ZDSPCATG';
      t_errormsg(v_errorcount) := o_errortext(c_RQYR);
      t_errorfieldval(v_errorcount) := v_zdspcatg;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

    ----ZLETVERN---SHOULD BE '000' AND NOT NULL-------------------------------------
    IF ((v_zletvern IS NOT NULL) AND (v_zletvern <> '000')) THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_z072;
      t_errorfield(v_errorcount) := 'ZLETVERN';
      t_errormsg(v_errorcount) := o_errortext(c_z072);
      t_errorfieldval(v_errorcount) := v_zletdest;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
----"ZLETDEST	Destination of Letter" Must not be blank.--
            IF
                v_zletdest IS NULL
            THEN
                v_isanyerror := 'Y';
                v_errorcount := v_errorcount + 1;
                t_ercode(v_errorcount) := c_e186;
                t_errorfield(v_errorcount) := 'ZLETDEST';
                t_errormsg(v_errorcount) := o_errortext(c_e186);
                t_errorfieldval(v_errorcount) := v_zletdest;
                t_errorprogram(v_errorcount) := i_schedulename;
                IF
                    v_errorcount >= c_errorcount
                THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/

----"ZLETDEST	Destination of Letter" Must be valid item in TQ9IT ? Letter Destination.--
    IF NOT
        (itemexist.EXISTS(trim('TQ9IT') || trim(v_zletdest) || i_company)) THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_z034;
      t_errorfield(v_errorcount) := 'ZLETDEST';
      t_errormsg(v_errorcount) := o_errortext(c_z034);
      t_errorfieldval(v_errorcount) := v_zletdest;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
----"ZCOMADDR	Specify Communicate To" Must not be blank--
            IF
                v_zcomaddr IS NULL
            THEN
                v_isanyerror := 'Y';
                v_errorcount := v_errorcount + 1;
                t_ercode(v_errorcount) := c_e186;
                t_errorfield(v_errorcount) := 'ZCOMADDR';
                t_errormsg(v_errorcount) := o_errortext(c_e186);
                t_errorfieldval(v_errorcount) := v_zcomaddr;
                t_errorprogram(v_errorcount) := i_schedulename;
                IF
                    v_errorcount >= c_errorcount
                THEN
                    GOTO insertzdoe;
                END IF;
            END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/ 
----"ZCOMADDR	Specify Communicate To" Must be valid item in TQ9IN ? Designation Address.--
    IF NOT
        (itemexist.EXISTS(trim('TQ9IN') || trim(v_zcomaddr) || i_company)) THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_RQYS;
      t_errorfield(v_errorcount) := 'ZCOMADDR';
      t_errormsg(v_errorcount) := o_errortext(c_RQYS);
      t_errorfieldval(v_errorcount) := v_zcomaddr;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
----"ZLETCAT	Letter Category" Must not be blank.--
            IF
                v_zletcat IS NULL
            THEN
                v_isanyerror := 'Y';
                v_errorcount := v_errorcount + 1;
                t_ercode(v_errorcount) := c_e186;
                t_errorfield(v_errorcount) := 'ZLETCAT';
                t_errormsg(v_errorcount) := o_errortext(c_e186);
                t_errorfieldval(v_errorcount) := v_zletcat;
                t_errorprogram(v_errorcount) := i_schedulename;
                IF
                    v_errorcount >= c_errorcount
                THEN
                    GOTO insertzdoe;
                END IF;
            END IF;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/ 

----"ZLETCAT	Letter Category" Must be valid item in TQ9IU  ? Letter Category.--
    IF NOT (itemexist.EXISTS(trim('TQ9IU') || trim(v_zletcat) || i_company)) THEN
      v_isanyerror := 'Y';
      v_errorcount := v_errorcount + 1;
      t_ercode(v_errorcount) := c_RQYT;
      t_errorfield(v_errorcount) := 'ZLETCAT';
      t_errormsg(v_errorcount) := o_errortext(c_RQYT);
      t_errorfieldval(v_errorcount) := v_zletcat;
      t_errorprogram(v_errorcount) := i_schedulename;
      IF v_errorcount >= c_errorcount THEN
        GOTO insertzdoe;
      END IF;
    END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
--"ZDESPER	Designation of Period" Must be valid item in TQ9IR ? Financial Periods.--
--MSD change dont need this column--
--    IF NOT (itemexist.EXISTS(trim('TQ9IR') || trim(v_zdesper) || i_company)) THEN
--      v_isanyerror := 'Y';
--      v_errorcount := v_errorcount + 1;
--      t_ercode(v_errorcount) := c_RR32;
--      t_errorfield(v_errorcount) := 'ZDESPER';
--      t_errormsg(v_errorcount) := o_errortext(c_RR32);
--      t_errorfieldval(v_errorcount) := v_zdesper;
--      t_errorprogram(v_errorcount) := i_schedulename;
--      IF v_errorcount >= c_errorcount THEN
--        GOTO insertzdoe;
--      END IF;
--    END IF;
--MSD change dont need this column--
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
--"ZAPSTMPD	Designation of Period" Valid value is 塑? or 鮮?.--
--IF ((v_zapstmpd <> 'Y') AND (v_zapstmpd <> 'N')) THEN
--      v_isAnyError := 'Y';
--      v_errorCount := v_errorCount + 1;
--      t_ercode(v_errorCount) := C_Z028;
--      t_errorfield(v_errorCount) := 'ZAPSTMPD';
--      t_errormsg(v_errorCount) := o_errortext(C_Z028);
--      t_errorfieldval(v_errorCount) := v_zapstmpd;
--      t_errorprogram(v_errorCount) := i_scheduleName;
--      IF v_errorCount >= C_ERRORCOUNT THEN
--        GOTO insertzdoe;
--      END IF;
--    END IF;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/
    -------[END] VALIDATE ALL FIELDS COMING FROM STAGE DB - TITDMGLETTER---------------------------------------------------------

--    BEGIN
--      SELECT TRIM(zigvalue)
--        INTO v_clientnum
--        FROM Jd1dta.PAZDCLPF
--       WHERE TRIM(prefix) = 'CP'
--         AND TRIM(zentity) = v_chdrnum;
--
--    EXCEPTION
--      WHEN NO_DATA_FOUND THEN
--        v_clientnum := v_space;
--    END;


    IF (getClntnum.exists(TRIM(v_chdrnum))) THEN
        v_clientnum := getClntnum(TRIM(v_chdrnum));
     ELSE
        v_clientnum := v_space;
     END IF;

    -- To get the clientNum

    --        v_clientnum := ' ';
    --        v_cnt := 0;
    --        
    --        
    --        SELECT
    --            COUNT(zigvalue)
    --        INTO
    --            v_cnt
    --        FROM
    --            Jd1dta.zdclpf
    --        WHERE
    --            TRIM(prefix) = 'CP'
    --            AND   TRIM(zentity) = v_chdrnum;
    --
    --        -- If client number is not in PAZDCLPF, this should be thrown as an error
    --
    --        IF
    --            v_cnt > 0
    --        THEN
    --            SELECT
    --                TRIM(zigvalue)
    --            INTO
    --                v_clientnum
    --            FROM
    --                Jd1dta.zdclpf
    --            WHERE
    --                TRIM(prefix) = 'CP'
    --                AND   TRIM(zentity) = v_chdrnum
    --                AND   ROWNUM = 1;
    --
    --        ELSE
    --            v_isanyerror := 'Y';
    --            v_errorcount := v_errorcount + 1;
    --            t_ercode(v_errorcount) := c_rqli;
    --            t_errorfield(v_errorcount) := 'CLNTNUM';
    --            t_errormsg(v_errorcount) := o_errortext(c_rqli);
    --            t_errorfieldval(v_errorcount) := v_clientnum;
    --            t_errorprogram(v_errorcount) := i_schedulename;
    --            IF
    --                v_errorcount >= c_errorcount
    --            THEN
    --                GOTO insertzdoe;
    --            END IF;
    --        END IF;

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

    -- If there is no Error Insert success record in ZDOE

    IF (v_isanyerror = 'N') THEN
      i_zdoe_info.i_indic := 'S';
      pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
    END IF;

    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF---------------------------------------------------------

    --------IF PRE-VALIDATION IS NO - INSERT INTO "PAZDCLPF" REGISTRY TABLE--------------------------------------------------------

    IF i_zprvaldyn = 'N' AND v_isanyerror = 'N' THEN
      -- Get Sequence number
      -- SELECT letcpf_seq.NEXTVAL INTO v_letrseq FROM dual;
      IF RTRIM(v_clientnum) IS NOT NULL

       THEN
        -- Get letter seq
        -- mps 04/23 START --
        -- Letter sequence number to be set to 1 only. Temp Solution
        /*
        SELECT MAX(letseqno)
          INTO v_letrseq
          FROM Jd1dta.letcpf
         WHERE TRIM(reqcoy) = v_reqcoy
           AND rtrim(lettype) = v_lettype
           AND rtrim(clntcoy) = v_clntcoy
           AND rtrim(clntnum) = v_clientnum;

        IF v_letrseq IS NOT NULL THEN
          v_letrseq := v_letrseq + 1;
        ELSE
          v_letrseq := 1;
        END IF;
        */
        --v_letrseq := 1;
        -- mps 04/23 END --
        -- get Letter seq no
        -- mps 04/23 START --
        -- Letter tran number to be set to 1 only. 
        /*
        SELECT MAX(ZLETTRNO)
          INTO v_zlettrno
          FROM Jd1dta.letcpf
         WHERE TRIM(reqcoy) = v_reqcoy
           AND rtrim(clntnum) = v_clientnum;

        IF v_zlettrno IS NOT NULL THEN
          v_zlettrno := v_zlettrno + 1;
        ELSE
          v_zlettrno := 1;
        END IF;
        */
        v_zlettrno := 1;
        -- mps 04/23 END --
      END IF;

      -- insert into Registry table

      INSERT INTO Jd1dta.PAzdltpf
        (chdrnum, hlettype, lreqdate, zletvern, jobnum, jobname)
      VALUES
        (v_chdrnum,
         v_lettype,
         v_lreqdate,
         v_zletvern,
         i_schedulenumber,
         i_schedulename);

      -- set default values
  select SEQ_LETCPF.nextval into v_pkValue from dual;
      obj_letcpf.unique_number := SEQ_LETCPF.nextval;
      obj_letcpf.reqcoy   := v_reqcoy;
      obj_letcpf.letstat  := v_letstat;
      obj_letcpf.lprtdate := v_lprtdate;
      obj_letcpf.clntcoy  := v_clntcoy;
      obj_letcpf.letokey  := v_letokey;
      obj_letcpf.rdocpfx  := v_rdocpfx;
      obj_letcpf.rdoccoy  := v_rdoccoy;
      obj_letcpf.rdocnum  := v_rdocnum;
      obj_letcpf.tranno   := v_tranno;
      obj_letcpf.servunit := v_servunit;
      obj_letcpf.despnum  := v_despnum;
      obj_letcpf.branch   := v_branch;
      obj_letcpf.chdrcoy  := v_chdrcoy;
      obj_letcpf.hsublet  := v_hsublet;
      obj_letcpf.zzcopies := v_zzcopies;
      obj_letcpf.zduplex  := v_zduplex;
      obj_letcpf.zenvseqn := '0000';   -- LT3

      -- set other values
      obj_letcpf.lettype  := v_lettype;
      obj_letcpf.letseqno := v_letrseq;
      obj_letcpf.zlettrno := v_zlettrno;
      obj_letcpf.lreqdate := v_lreqdate;
      obj_letcpf.clntnum  := v_clientnum;
      obj_letcpf.chdrnum  := v_chdrnum;
      obj_letcpf.branch   := i_branch;
      obj_letcpf.trcde    := i_transcode;
      obj_letcpf.zdspcatg := v_zdspcatg;
      obj_letcpf.zletvern := v_zletvern;
      obj_letcpf.zletdest := v_zletdest;
      obj_letcpf.zcomaddr := v_zcomaddr;
      obj_letcpf.zletcat  := v_zletcat;
      obj_letcpf.usrprf   := i_userprofile;
      obj_letcpf.jobnm    := i_schedulename;
      obj_letcpf.datime   := current_timestamp;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
      obj_letcpf.ZAPSTMPD  := v_zapstmpd;
      obj_letcpf.ZRMDLETT  := v_zrmdlett;
      obj_letcpf.ZGOODBYE  := v_zgoodbye;
      obj_letcpf.QUOTENO   := v_quoteno;
      obj_letcpf.ZDESPER   := v_zdesper;
/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/
      -- insert into IG Target table
/**** ITR-4 :  LT2 - LOT2 CHANGE : START ****/
      obj_letcpf.ZLETEFDT   := v_lreqdate;
/**** ITR-4 :  LT2 - LOT2 CHANGE : END ****/
      INSERT INTO Jd1dta.letcpf VALUES obj_letcpf;

    END IF;

  END LOOP;

  CLOSE c_lettercursor;
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);

END BQ9RF_LT01_LETR;