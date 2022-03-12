create or replace PROCEDURE          "BQ9RF_LT01_LETR" (
        i_schedulename     IN                 VARCHAR2,
        i_schedulenumber   IN                 VARCHAR2,
        i_zprvaldyn        IN                 VARCHAR2,
        i_company          IN                 VARCHAR2,
        i_usrprf           IN                 VARCHAR2,
        i_branch           IN                 VARCHAR2,
        i_transcode        IN                 VARCHAR2,
        i_vrcmtermid       IN                 VARCHAR2,
		i_array_size       IN                 PLS_INTEGER DEFAULT 1000,
        start_id           IN                 NUMBER,
        end_id             IN                 NUMBER
) AS
/***************************************************************************************************
  * Amenment History: LT01 Letters 
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       LT1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0728     BS        LT1   Pa New Implementation
  * 1222     BS        LT2   ITR3 New Implementation
  *****************************************************************************************************/                                
  ----------------------------VARIABLES DECLARATION START-------------------------------------------------------------

        v_timestart       NUMBER := dbms_utility.get_time; --Timecheck
        v_refkey          VARCHAR2(50 CHAR);
        v_errorcount      NUMBER(1) DEFAULT 0;
        v_isdatevalid     VARCHAR2(20 CHAR);
        v_isanyerror      VARCHAR2(1) DEFAULT 'N';
     --   v_clientnum       VARCHAR2(8);
        v_letrseq         NUMBER(7) DEFAULT 1;
        v_zlettrno        NUMBER(5) DEFAULT 1;
       v_space           VARCHAR2(2) DEFAULT ' ';
        v_tempchdrnum     VARCHAR2(8 CHAR);
        p_exitcode        NUMBER;
        p_exittext        VARCHAR2(2000);
	    c_limit           PLS_INTEGER := i_array_size;


  -----------------------VARIABLE FOR DEFAULT VALUS-----------------------------
     --   v_pkvalue         letcpf.unique_number%TYPE;
   /**** LT1 Start****/
        v_quoteno         VARCHAR2(8 CHAR) := '        ';
        v_zaltrcde01      VARCHAR2(4 CHAR) := '    ';
        v_zaltrcde02      VARCHAR2(4 CHAR) := '    ';
        v_zaltrcde03      VARCHAR2(4 CHAR) := '    ';
        v_zaltrcde04      VARCHAR2(4 CHAR) := '    ';
        v_zaltrcde05      VARCHAR2(4 CHAR) := '    ';
        v_despnum         VARCHAR2(8 CHAR) := '        ';
        v_transeq         VARCHAR2(4 CHAR) := NULL;
        v_letokey         VARCHAR2(20 CHAR) := ' ';
        v_zrfuqno         NUMBER(18, 0) := NULL;
  /**** LT1 END****/

  ------------------------------------------------------------------------------
  ----------------------------VARIABLES DECLARATION END----------------------------------------------------------------
------IG table obj start---
        obj_letcpf        letcpf%rowtype;
------IG table obj End---
  --------------------------------CONSTANTS----------------------------------------------------------------------------
        c_prefix          CONSTANT VARCHAR2(2) := get_migration_prefix('LETR', i_company);
       --c_prefix            CONSTANT VARCHAR2(2) := 'LT';
        c_bq9rf           CONSTANT VARCHAR2(5) := 'BQ9RF';
        c_tq9i3           CONSTANT VARCHAR2(5 CHAR) := 'TQ9I3';
        c_tq9im           CONSTANT VARCHAR2(5 CHAR) := 'TQ9IM';
        c_tq9in           CONSTANT VARCHAR2(5 CHAR) := 'TQ9IN';
        c_tq9iu           CONSTANT VARCHAR2(5 CHAR) := 'TQ9IU';
        c_tq9it           CONSTANT VARCHAR2(5 CHAR) := 'TQ9IT';

  -----------------------------ERROR CONSTANTS-------------------------------------------------------------------------
        c_e186            CONSTANT VARCHAR2(4) := 'E186'; /*Field must be entered*/
   --     c_z035              CONSTANT VARCHAR2(4) := 'RQMF'; /*Must be in TR383 */
        c_z013            CONSTANT VARCHAR2(4) := 'RQLT'; /*Invalid Date*/-- H903  Invalid Date Format     
        c_z031            CONSTANT VARCHAR2(4) := 'RQMB'; /*Policy is not yet migrated*/
     --   c_z020              CONSTANT VARCHAR2(4) := 'RQM0'; /*Item not in table*/
        c_z072            CONSTANT VARCHAR2(4) := 'RQNG'; /*Missing letter version number*/
        c_z034            CONSTANT VARCHAR2(4) := 'RQME'; /*Invalid Dest Letr Type*/
        c_z099            CONSTANT VARCHAR2(4) := 'RQO6'; /*Duplicated record found*/
    --    c_rqli              CONSTANT VARCHAR2(4) := 'RQLI'; /*Client not yet migrated */
        c_rqyf            CONSTANT VARCHAR2(4) := 'RQYF'; /*Must be valid in TQ9I3 */
        c_rqyr            CONSTANT VARCHAR2(4) := 'RQYR'; /*Item not in table TQ9IM*/
        c_rqys            CONSTANT VARCHAR2(4) := 'RQYS'; /*Item not in table TQ9IN*/
        c_rqyt            CONSTANT VARCHAR2(4) := 'RQYT'; /*Item not in table TQ9IU*/

  --     c_rr32              CONSTANT VARCHAR2(4) := 'RR32'; /*Item not in table TQ9IR*/
  --      c_z028              CONSTANT VARCHAR2(4) := 'RQM8'; /*Value must be Ã¥Â¡â€˜? or Ã©Â®Â®?    */
        c_errorcount      CONSTANT NUMBER := 5;
  --------------------------COMMON FUNCTION START-----------------------------------------------------------------------
        v_tablenametemp   VARCHAR2(10);
        v_tablename       VARCHAR2(10);
        itemexist         pkg_dm_common_operations.itemschec;
        o_errortext       pkg_dm_common_operations.errordesc;
        i_zdoe_info       pkg_dm_common_operations.obj_zdoe;
        o_defaultvalues   pkg_dm_common_operations.defaultvaluesmap;
        checkdupl         pkg_common_dmlt.ltduplicate;
     --   getclntnum        pkg_common_dmlt.newzdclpf; -- Rehearsal Changes
		getZrndtnum       pkg_common_dmlt.newzrndthpf; -- LT2 Changes
        TYPE ercode_tab IS
                TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER;
        t_ercode          ercode_tab;
       TYPE errorfield_tab IS
                TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
        t_errorfield      errorfield_tab;
        TYPE errormsg_tab IS
                TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
        t_errormsg        errormsg_tab;
        TYPE errorfieldvalue_tab IS
                TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER;
        t_errorfieldval   errorfieldvalue_tab;
        TYPE errorprogram_tab IS
                TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER;
        t_errorprogram    errorprogram_tab;
--        TYPE zdrppf_typ IS
--                TABLE OF VARCHAR(8) INDEX BY BINARY_INTEGER;
--        zdrppf_list       zdrppf_typ;

  --------------------------COMMON FUNCTION END-------------------------------------------------------------------------
        CURSOR c_lettercursor IS
       /*
         SELECT
    t.*,
    ROW_NUMBER() OVER(
        PARTITION BY t.pazdrppf_clntno, t.lettype
        ORDER BY
            t.chdrnum, t.lettype, t.lreqdate
    ) letrseq
FROM
    (
        SELECT
            tit.*,
            drppf.chdrnum    AS zdrppf_chdrnum,
            dclpf.zigvalue   AS pazdrppf_clntno,
            LTPF.CHDRNUM CHDRNUM_DUP
        FROM
            Jd1dta.dmigtitdmgletter   tit
            LEFT OUTER JOIN pazdrppf                  drppf ON tit.chdrnum = substr(drppf.chdrnum, 1, 8)
             AND drppf.zinsrole = '0'
             LEFT OUTER JOIN pazdclpf                  dclpf ON tit.stageclntno = dclpf.zentity
              AND dclpf.prefix = 'CP'
              LEFT OUTER JOIN PAZDLTPF  LTPF
              ON  tit.chdrnum = LTPF.CHDRNUM
              and tit.lettype = LTPF.hlettype
              and tit.lreqdate = LTPF.LREQDATE
              and tit.ZLETTRNO = LTPF.ZLETVERN
    ) t
WHERE        refnumchunk BETWEEN start_id AND end_id;*/

WITH MainData as(
 SELECT
    t.*,
    ROW_NUMBER() OVER(
        PARTITION BY t.pazdrppf_clntno, t.lettype
        ORDER BY
            t.chdrnum, t.lettype, t.lreqdate
    ) letrseq
FROM
    (
        SELECT
            tit.*,
            drppf.chdrnum    AS zdrppf_chdrnum,
            dclpf.zigvalue   AS pazdrppf_clntno,
            LTPF.CHDRNUM CHDRNUM_DUP
        FROM
            Jd1dta.dmigtitdmgletter   tit
            LEFT OUTER JOIN pazdrppf                  drppf ON tit.chdrnum = substr(drppf.chdrnum, 1, 8)
             AND drppf.zinsrole = '0'
             LEFT OUTER JOIN pazdclpf                  dclpf ON tit.stageclntno = dclpf.zentity
              AND dclpf.prefix = 'CP'
              LEFT OUTER JOIN PAZDLTPF  LTPF
              ON  tit.chdrnum = LTPF.CHDRNUM
              and tit.lettype = LTPF.hlettype
              and tit.lreqdate = LTPF.LREQDATE
              and tit.ZLETTRNO = LTPF.ZLETVERN
    ) t),
    IGDATA as (
    select LETTYPE IG_LETTYPE,CLNTNUM, max(LETSEQNO) as IG_LETSEQNO from letcpf group by LETTYPE,CLNTNUM
    )
    select RECIDXLETR, CHDRNUM, LETTYPE, LREQDATE, ZDSPCATG, ZLETVERN, ZLETDEST, ZCOMADDR, ZLETCAT, ZAPSTMPD, ZDESPER, ZLETEFDT, ZLETTRNO, STAGECLNTNO, REFNUMCHUNK, ZDRPPF_CHDRNUM, PAZDRPPF_CLNTNO, CHDRNUM_DUP, 
NVL2( IG_LETSEQNO, IG_LETSEQNO+LETRSEQ, LETRSEQ ) as LETRSEQ,
IG_LETTYPE, CLNTNUM, IG_LETSEQNO from maindata A left outer join IGDATA B on A.pazdrppf_clntno= B.clntnum and RTRIm(A.lettype) = RTRIM(b.IG_LETTYPE) WHERE    refnumchunk BETWEEN start_id AND end_id;

        o_letterobj       c_lettercursor%rowtype;
		 TYPE t_letter_list IS
                TABLE OF c_lettercursor%rowtype;
        letter_list       t_letter_list;
BEGIN
        dbms_output.put_line('Start execution of BQ9RF_LT01_LETR, SC NO:  '
                             || i_schedulenumber
                             || ' Flag :'
                             || i_zprvaldyn);

  --------------------------COMMON FUNCTION CALLING START-----------------------------------------------------------------------
        pkg_dm_common_operations.getdefval(i_module_name => c_bq9rf, o_defaultvalues => o_defaultvalues);
        pkg_dm_common_operations.checkitemexist(i_module_name => 'DMLT', itemexist => itemexist);
        pkg_dm_common_operations.geterrordesc(i_module_name => 'DMLT', o_errortext => o_errortext);
        v_tablenametemp := 'ZDOE'
                           || trim(c_prefix)
                           || lpad(trim(i_schedulenumber), 4, '0');

        v_tablename := trim(v_tablenametemp);
     -- pkg_dm_common_operations.createzdoepf(i_tablename => v_tablename);
       -- pkg_common_dmlt.checkcpdup(checkdupl => checkdupl);
     --   pkg_common_dmlt.getclntnum(getclntnum => getclntnum); --- Rehearsal Changes
		pkg_common_dmlt.getZrndtnum(getZrndtnum => getZrndtnum); --- LT2 Changes

  --------------------------COMMON FUNCTION CALLING END-----------------------------------------------------------------------

    -----------------------------OPEN CURSOR------------------------------------------------------------------------------------
       OPEN c_lettercursor;
        LOOP
                FETCH c_lettercursor BULK COLLECT INTO letter_list LIMIT c_limit;
                << skiprecord >> FOR i IN 1..letter_list.count LOOP
                        o_letterobj := letter_list(i);

             --   FETCH c_lettercursor INTO o_letterobj;
            --    EXIT WHEN c_lettercursor%notfound;

    ---------------------------INITIALIZATION START----------------------------------------------------------------------------

           --     v_zletdest := trim(o_letterobj.zletdest); --LT1
                v_letrseq := to_number(o_letterobj.letrseq);
--                IF ( v_tempchdrnum = o_letterobj.chdrnum ) THEN
--                        v_zlettrno := v_zlettrno + 1;
--                ELSE
--                        v_tempchdrnum := o_letterobj.chdrnum;
--v_zlettrno :=  1;
--                END IF;
    ----REFERENCE KEY FOR LETTERS WILL BE THE COMBINATION OF THE FOLLWING FIELDS------

                v_refkey := trim(o_letterobj.chdrnum)
                            || '-'
                            || trim(o_letterobj.lettype)
                            || '-'
                           -- || trim(o_letterobj.zletvern) --ZLETTRNO
                            || trim(o_letterobj.ZLETTRNO)
                            || '-'
                            || trim(o_letterobj.lreqdate);

                v_isanyerror := 'N';
                v_errorcount := 0;
                t_ercode(1) := ' ';
                t_ercode(2) := ' ';
                t_ercode(3) := ' ';
                t_ercode(4) := ' ';
                t_ercode(5) := ' ';
                i_zdoe_info := NULL;
                i_zdoe_info.i_zfilename := 'TITDMGLETTER';
                i_zdoe_info.i_prefix := c_prefix;
                i_zdoe_info.i_refkey := v_refkey;
                i_zdoe_info.i_tablename := v_tablename;

    ---------------------------INITIALIZATION END-------------------------------------------------------------------------------


    -------VALIDATION - DUPLICATE RECORD--------------------------------------------------------------------------------------
               /* IF ( checkdupl.EXISTS(trim(o_letterobj.chdrnum)
                                      || trim(o_letterobj.lettype)
                                      || trim(o_letterobj.lreqdate)
                                     -- || trim(o_letterobj.zletvern)) ) THEN
                                      || trim(o_letterobj.ZLETTRNO)) ) THEN*/
                                      IF(o_letterobj.CHDRNUM_DUP IS NOT NULl)THEN
                        v_isanyerror := 'Y';
                        i_zdoe_info.i_indic := 'E';
                        i_zdoe_info.i_error01 := c_z099;
                        i_zdoe_info.i_errormsg01 := o_errortext(c_z099);
                        i_zdoe_info.i_errorfield01 := 'REFKEY';
                        i_zdoe_info.i_fieldvalue01 := v_refkey;
                        i_zdoe_info.i_errorprogram01 := i_schedulename;
                        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                        CONTINUE skiprecord;
                END IF;

    -------[START] VALIDATE ALL FIELDS COMING FROM STAGE DB - TITDMGLETTER---------------------------------------------------------

  -------"LETTER TYPE" Must not be blank.--------------

                IF TRIM(o_letterobj.lettype) IS NULL THEN
                        v_isanyerror := 'Y';
                        v_errorcount := v_errorcount + 1;
                        t_ercode(v_errorcount) := c_e186;
                        t_errorfield(v_errorcount) := 'LETTYPE';
                        t_errormsg(v_errorcount) := o_errortext(c_e186);
                        t_errorfieldval(v_errorcount) := trim(o_letterobj.lettype);
                        t_errorprogram(v_errorcount) := i_schedulename;
                        IF v_errorcount >= c_errorcount THEN
                                GOTO insertzdoe;
                        END IF;


    -------"LETTER TYPE" Must be A valid item in TQ9I3--------------
                ELSE
                        IF NOT ( itemexist.EXISTS(trim(c_tq9i3)
                                                  || trim(o_letterobj.lettype)
                                                  || i_company) ) THEN
                                v_isanyerror := 'Y';
                                v_errorcount := v_errorcount + 1;
                                t_ercode(v_errorcount) := c_rqyf;
                                t_errorfield(v_errorcount) := 'LETTYPE';
                                t_errormsg(v_errorcount) := o_errortext(c_rqyf);
                                t_errorfieldval(v_errorcount) := trim(o_letterobj.lettype);
                                t_errorprogram(v_errorcount) := i_schedulename;
                                IF v_errorcount >= c_errorcount THEN
                                        GOTO insertzdoe;
                                END IF;
                        END IF;
                END IF;

-----"LETTER REQUEST DATE" Must not be blank----------------------------

               IF TRIM(o_letterobj.lreqdate) IS NULL THEN
                        v_isanyerror := 'Y';
                        v_errorcount := v_errorcount + 1;
                        t_ercode(v_errorcount) := c_e186;
                        t_errorfield(v_errorcount) := 'LREQDATE';
                        t_errormsg(v_errorcount) := o_errortext(c_e186);
                        t_errorfieldval(v_errorcount) := trim(o_letterobj.lreqdate);
                        t_errorprogram(v_errorcount) := i_schedulename;
                        IF v_errorcount >= c_errorcount THEN
                                GOTO insertzdoe;
                        END IF;


-----"LETTER REQUEST DATE" Must be a valid Date.-------------------------   
                ELSE
                        v_isdatevalid := validate_date(trim(o_letterobj.lreqdate));
                        IF v_isdatevalid <> 'OK' THEN
                                v_isanyerror := 'Y';
                                v_errorcount := v_errorcount + 1;
                                t_ercode(v_errorcount) := c_z013;
                                t_errorfield(v_errorcount) := 'LREQDATE';
                                t_errormsg(v_errorcount) := o_errortext(c_z013);
                                t_errorfieldval(v_errorcount) := trim(o_letterobj.lreqdate);
                                t_errorprogram(v_errorcount) := i_schedulename;
                                IF v_errorcount >= c_errorcount THEN
                                        GOTO insertzdoe;
                                END IF;
                        END IF;

                END IF;   

----"CONTRACT NUMBER" Must not be blank---------------------------------

                IF TRIM(o_letterobj.chdrnum) IS NULL THEN
                        v_isanyerror := 'Y';
                        v_errorcount := v_errorcount + 1;
                        t_ercode(v_errorcount) := c_e186;
                        t_errorfield(v_errorcount) := 'CHDRNUM';
                        t_errormsg(v_errorcount) := o_errortext(c_e186);
                        t_errorfieldval(v_errorcount) := trim(o_letterobj.chdrnum);
                        t_errorprogram(v_errorcount) := i_schedulename;
                        IF v_errorcount >= c_errorcount THEN
                                GOTO insertzdoe;
                        END IF;
                END IF; 

    ----"CONTRACT NUMBER" Must be existing------------------------------------------
    --VALIDATION ON CHDRNUM-IF THIS IS NOT PRESENT IN "ZDRPPF-REGISTRY TABLE OF POLICY" THEN THROW ERROR "POLICY YET NOT MIGRATED"
    --BECAUSE POLICY SHOULD BE MIGRATED FIRST BEFORE  PROCEEDING MIGRATION OF LETTERS.

                IF TRIM(o_letterobj.zdrppf_chdrnum) IS NULL THEN
                        v_isanyerror := 'Y';
                        v_errorcount := v_errorcount + 1;
                        t_ercode(v_errorcount) := c_z031;
                        t_errorfield(v_errorcount) := 'CHDRNUM';
                        t_errormsg(v_errorcount) := o_errortext(c_z031);
                        t_errorfieldval(v_errorcount) := trim(o_letterobj.chdrnum);
                        t_errorprogram(v_errorcount) := i_schedulename;
                        IF v_errorcount >= c_errorcount THEN
                                GOTO insertzdoe;
                        END IF;
                END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
----"ZDSPCATG Mail Type" Must not be blank------------------------------

                IF TRIM(o_letterobj.zdspcatg) IS NULL THEN
                        v_isanyerror := 'Y';
                        v_errorcount := v_errorcount + 1;
                        t_ercode(v_errorcount) := c_e186;
                        t_errorfield(v_errorcount) := 'ZDSPCATG';
                        t_errormsg(v_errorcount) := o_errortext(c_e186);
                        t_errorfieldval(v_errorcount) := trim(o_letterobj.zdspcatg);
                        t_errorprogram(v_errorcount) := i_schedulename;
                        IF v_errorcount >= c_errorcount THEN
                                GOTO insertzdoe;
                        END IF;



----"ZDSPCATG Mail Type" Must be valid item in TQ9IM ? Despatch Category.--
                ELSE
                        IF NOT ( itemexist.EXISTS(trim(c_tq9im)
                                                  || trim(o_letterobj.zdspcatg)
                                                  || i_company) ) THEN
                                v_isanyerror := 'Y';
                                v_errorcount := v_errorcount + 1;
                                t_ercode(v_errorcount) := c_rqyr;
                                t_errorfield(v_errorcount) := 'ZDSPCATG';
                                t_errormsg(v_errorcount) := o_errortext(c_rqyr);
                                t_errorfieldval(v_errorcount) := trim(o_letterobj.zdspcatg);
                                t_errorprogram(v_errorcount) := i_schedulename;
                                IF v_errorcount >= c_errorcount THEN
                                        GOTO insertzdoe;
                                END IF;
                        END IF;
                END IF;
    ----ZLETVERN---SHOULD BE '000' AND NOT NULL-------------------------------------

                IF ( ( TRIM(o_letterobj.zletvern) IS NOT NULL ) AND ( trim(o_letterobj.zletvern) <> '000' ) ) THEN
                        v_isanyerror := 'Y';
                        v_errorcount := v_errorcount + 1;
                        t_ercode(v_errorcount) := c_z072;
                        t_errorfield(v_errorcount) := 'ZLETVERN';
                        t_errormsg(v_errorcount) := o_errortext(c_z072);
                        t_errorfieldval(v_errorcount) := trim(o_letterobj.zletvern);   ---?LT1
                        t_errorprogram(v_errorcount) := i_schedulename;
                        IF v_errorcount >= c_errorcount THEN
                                GOTO insertzdoe;
                        END IF;
                END IF;

/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : START ****/
------"ZLETDEST            Destination of Letter" Must not be blank.-- 
-- IN LT1 ZLETDEST       Destination of Letter set as default '2'
--
--                IF v_zletdest IS NULL THEN
--                        v_isanyerror := 'Y';
--                        v_errorcount := v_errorcount + 1;
--                        t_ercode(v_errorcount) := c_e186;
--                        t_errorfield(v_errorcount) := 'ZLETDEST';
--                        t_errormsg(v_errorcount) := o_errortext(c_e186);
--                        t_errorfieldval(v_errorcount) := v_zletdest;
--                        t_errorprogram(v_errorcount) := i_schedulename;
--                        IF v_errorcount >= c_errorcount THEN
--                                GOTO insertzdoe;
--                        END IF;
--                END IF;
--/**** ITR-4 :  ADD : new column added for TITDMGLETTER table : END ****/
--
------"ZLETDEST            Destination of Letter" Must be valid item in TQ9IT ? Letter Destination.--
--
--                IF NOT ( itemexist.EXISTS(trim(C_TQ9IT)
--                                          || trim(v_zletdest)
--                                          || i_company) ) THEN
--                        v_isanyerror := 'Y';
--                        v_errorcount := v_errorcount + 1;
--                        t_ercode(v_errorcount) := c_z034;
--                        t_errorfield(v_errorcount) := 'ZLETDEST';
--                        t_errormsg(v_errorcount) := o_errortext(c_z034);
--                        t_errorfieldval(v_errorcount) := v_zletdest;
--                        t_errorprogram(v_errorcount) := i_schedulename;
--                        IF v_errorcount >= c_errorcount THEN
--                                GOTO insertzdoe;
--                        END IF;
--                END IF;

----"ZCOMADDR            Specify Communicate To" Must not be blank--

                IF TRIM(o_letterobj.zcomaddr) IS NULL THEN
                        v_isanyerror := 'Y';
                        v_errorcount := v_errorcount + 1;
                        t_ercode(v_errorcount) := c_e186;
                        t_errorfield(v_errorcount) := 'ZCOMADDR';
                        t_errormsg(v_errorcount) := o_errortext(c_e186);
                        t_errorfieldval(v_errorcount) := trim(o_letterobj.zcomaddr);
                        t_errorprogram(v_errorcount) := i_schedulename;
                        IF v_errorcount >= c_errorcount THEN
                                GOTO insertzdoe;
                        END IF;


----"ZCOMADDR            Specify Communicate To" Must be valid item in TQ9IN ? Designation Address.--
                ELSE
                        IF NOT ( itemexist.EXISTS(trim(c_tq9in)
                                                  || trim(o_letterobj.zcomaddr)
                                                  || i_company) ) THEN
                                v_isanyerror := 'Y';
                                v_errorcount := v_errorcount + 1;
                                t_ercode(v_errorcount) := c_rqys;
                                t_errorfield(v_errorcount) := 'ZCOMADDR';
                                t_errormsg(v_errorcount) := o_errortext(c_rqys);
                                t_errorfieldval(v_errorcount) := trim(o_letterobj.zcomaddr);
                                t_errorprogram(v_errorcount) := i_schedulename;
                                IF v_errorcount >= c_errorcount THEN
                                        GOTO insertzdoe;
                                END IF;
                        END IF;
                END IF;

----"ZLETCAT    Letter Category" Must not be blank.--

                IF TRIM(o_letterobj.zletcat) IS NULL THEN
                        v_isanyerror := 'Y';
                        v_errorcount := v_errorcount + 1;
                        t_ercode(v_errorcount) := c_e186;
                        t_errorfield(v_errorcount) := 'ZLETCAT';
                        t_errormsg(v_errorcount) := o_errortext(c_e186);
                        t_errorfieldval(v_errorcount) := trim(o_letterobj.zletcat);
                        t_errorprogram(v_errorcount) := i_schedulename;
                        IF v_errorcount >= c_errorcount THEN
                                GOTO insertzdoe;
                        END IF;


----"ZLETCAT    Letter Category" Must be valid item in TQ9IU  ? Letter Category.--
                ELSE
                        IF NOT ( itemexist.EXISTS(trim(c_tq9iu)
                                                  || trim(trim(o_letterobj.zletcat))
                                                  || i_company) ) THEN
                                v_isanyerror := 'Y';
                                v_errorcount := v_errorcount + 1;
                                t_ercode(v_errorcount) := c_rqyt;
                                t_errorfield(v_errorcount) := 'ZLETCAT';
                                t_errormsg(v_errorcount) := o_errortext(c_rqyt);
                                t_errorfieldval(v_errorcount) := trim(o_letterobj.zletcat);
                                t_errorprogram(v_errorcount) := i_schedulename;
                                IF v_errorcount >= c_errorcount THEN
                                        GOTO insertzdoe;
                                END IF;
                        END IF;
                END IF;


 ----"CLNTNUM    " Must not be blank.--
--                IF ( getclntnum.EXISTS(trim(o_letterobj.chdrnum)||'00')) THEN
--                        v_clientnum := getclntnum(trim(o_letterobj.chdrnum)||'00');
--                ELSE

                        IF TRIM(o_letterobj.pazdrppf_clntno) IS NULL THEN -- LT3
                       -- v_clientnum := v_space;
                                v_isanyerror := 'Y';
                                v_errorcount := v_errorcount + 1;
                                t_ercode(v_errorcount) := c_e186;
                                t_errorfield(v_errorcount) := 'CLNTNUM';
                                t_errormsg(v_errorcount) := o_errortext(c_e186);
                                t_errorfieldval(v_errorcount) := trim(o_letterobj.chdrnum);
                                t_errorprogram(v_errorcount) := i_schedulename;
                                IF v_errorcount >= c_errorcount THEN
                                        GOTO insertzdoe;
                                END IF;
                        END IF;


    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF--------------------------------------------------------

                << insertzdoe >> IF ( v_isanyerror = 'Y' ) THEN
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
                        CONTINUE skiprecord;
                END IF;

    -- If there is no Error Insert success record in ZDOE

                IF ( v_isanyerror = 'N' ) THEN
                        i_zdoe_info.i_indic := 'S';
                        pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info);
                END IF;

    ---------------------COMMON BUSINESS LOGIC FOR INSERTING INTO ZDOEPF---------------------------------------------------------

    --------IF PRE-VALIDATION IS NO - INSERT INTO "PAZDCLPF" REGISTRY TABLE--------------------------------------------------------

                IF i_zprvaldyn = 'N' AND v_isanyerror = 'N' THEN
            -- insert into Registry table
                        INSERT INTO Jd1dta.pazdltpf (
                                chdrnum,
                                hlettype,
                                lreqdate,
                                zletvern,
                                jobnum,
                                jobname
                        ) VALUES (
                                TRIM(o_letterobj.chdrnum),
                                TRIM(o_letterobj.lettype),
                                TRIM(o_letterobj.lreqdate),
                               -- TRIM(o_letterobj.zletvern), 
                                 TRIM(o_letterobj.ZLETTRNO),
                                i_schedulenumber,
                                i_schedulename
                        );

      -- set default values

--                        SELECT
--                                seq_letcpf.NEXTVAL
--                        INTO v_pkvalue
--                        FROM
--                                dual;

                        obj_letcpf.unique_number := seq_letcpf.nextval;
                        obj_letcpf.reqcoy := o_defaultvalues('REQCOY');
                        obj_letcpf.letstat := o_defaultvalues('LETSTAT');
                        obj_letcpf.lprtdate := trim(o_letterobj.lreqdate);
                       obj_letcpf.clntcoy := o_defaultvalues('CLNTCOY');
                        obj_letcpf.letokey := v_letokey;
                        obj_letcpf.rdocpfx := o_defaultvalues('RDOCPFX');
                        obj_letcpf.rdoccoy := o_defaultvalues('RDOCCOY');
                        obj_letcpf.rdocnum := trim(o_letterobj.chdrnum);
                        obj_letcpf.tranno := o_defaultvalues('TRANNO');
                        obj_letcpf.servunit := o_defaultvalues('SERVUNIT');
                        obj_letcpf.despnum := v_despnum;
                        obj_letcpf.branch := i_branch;--o_defaultvalues('BRANCH'); --? Need to check
                        obj_letcpf.chdrcoy := o_defaultvalues('CHDRCOY');
                        obj_letcpf.hsublet := trim(o_letterobj.lettype);
                        obj_letcpf.zzcopies := o_defaultvalues('ZZCOPIES');
                        obj_letcpf.zduplex := o_defaultvalues('ZDUPLEX');
                        obj_letcpf.zenvseqn := o_defaultvalues('ZENVSEQN');   -- LT3

      -- set other values
                        obj_letcpf.lettype := trim(o_letterobj.lettype);
                        obj_letcpf.letseqno := v_letrseq; -- need to check
                     --   obj_letcpf.zlettrno := v_zlettrno;
                        obj_letcpf.zlettrno := trim(o_letterobj.ZLETTRNO);
                        obj_letcpf.lreqdate := trim(o_letterobj.lreqdate);
                       -- obj_letcpf.clntnum := v_clientnum;
					    obj_letcpf.clntnum := trim(o_letterobj.pazdrppf_clntno);-- LT3
                        obj_letcpf.chdrnum := trim(o_letterobj.chdrnum);
                        --obj_letcpf.branch := i_branch;
                        obj_letcpf.trcde := i_transcode;--? Need to check
                        obj_letcpf.zdspcatg := trim(o_letterobj.zdspcatg);
                        obj_letcpf.zletvern := trim(o_letterobj.zletvern);
                      --  obj_letcpf.zletdest := v_zletdest;
                        obj_letcpf.zletdest := o_defaultvalues('ZLETDEST');--LT1
                        obj_letcpf.zcomaddr := trim(o_letterobj.zcomaddr);
                        obj_letcpf.zletcat := trim(o_letterobj.zletcat);
                        obj_letcpf.usrprf := i_usrprf;
                        obj_letcpf.jobnm := i_schedulename;
                        obj_letcpf.datime := current_timestamp;
                        obj_letcpf.zapstmpd := o_defaultvalues('ZAPSTMPD');
                        obj_letcpf.zrmdlett := o_defaultvalues('ZRMDLETT');
                        obj_letcpf.zgoodbye := o_defaultvalues('ZGOODBYE');
                        obj_letcpf.quoteno := v_quoteno;
                        obj_letcpf.zdesper := o_defaultvalues('ZDESPER');
                        obj_letcpf.zletefdt := trim(o_letterobj.lreqdate);
                        obj_letcpf.zaltrcde01 := v_zaltrcde01; --LT1
                        obj_letcpf.zaltrcde02 := v_zaltrcde02; --LT1
                        obj_letcpf.zaltrcde03 := v_zaltrcde03; --LT1
                        obj_letcpf.zaltrcde04 := v_zaltrcde04; --LT1
                        obj_letcpf.zaltrcde05 := v_zaltrcde05; --LT1
                        obj_letcpf.transeq := v_transeq; --LT1
                        obj_letcpf.zremdt01 := o_defaultvalues('ZREMDT01'); --LT1
                        obj_letcpf.zremdt02 := o_defaultvalues('ZREMDT02'); --LT1
                        obj_letcpf.zremdt03 := o_defaultvalues('ZREMDT03'); --LT1
                        obj_letcpf.zrmpdyn01 := o_defaultvalues('ZRMPDYN01'); --LT1
                        obj_letcpf.zrmpdyn02 := o_defaultvalues('ZRMPDYN02'); --LT1
                        obj_letcpf.zrmpdyn03 := o_defaultvalues('ZRMPDYN03'); --LT1
                        obj_letcpf.zrfuqno := v_zrfuqno; --LT1
                        obj_letcpf.znoftdsp := o_defaultvalues('ZNOFTDSP'); --LT1
						 IF ( getZrndtnum.EXISTS(trim(o_letterobj.chdrnum))) THEN --LT2
                        obj_letcpf.ZRNDTNUM := getZrndtnum(trim(o_letterobj.chdrnum)); --LT2
                        ELSE
                                obj_letcpf.ZRNDTNUM := NULL;--LT2
                        END IF;--LT2

                        INSERT INTO Jd1dta.letcpf VALUES obj_letcpf;

                END IF;

        END LOOP;
        EXIT WHEN c_lettercursor%notfound;
        END LOOP;
        CLOSE c_lettercursor;
        dbms_output.put_line('Procedure execution time = '
                             ||(dbms_utility.get_time - v_timestart) / 100);
        dbms_output.put_line('End execution of BQ9RF_LT01_LETR, SC NO:  '
                             || i_schedulenumber
                             || ' Flag :'
                             || i_zprvaldyn);
EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                p_exitcode := sqlcode;
                p_exittext := 'BQ9RF_LT01_LETR : '
                              || dbms_utility.format_error_backtrace
                              || ' - ' ||v_refkey
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
END bq9rf_lt01_letr;
/