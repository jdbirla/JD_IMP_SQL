create or replace PACKAGE          "PKG_DM_MASTPOLICY" as
      
  TYPE itemval_r_val is RECORD (
       itmfrm  NUMBER(8,0),
       itmto   NUMBER(8,0),
       itemval1 VARCHAR2(100),
       itemval2 VARCHAR2(100),
       itemval3 VARCHAR2(100)
  );
  TYPE itemval_tab IS
        TABLE OF itemval_r_val INDEX BY VARCHAR2(14);  -- itemcoy + itemtabl + itemitem    
  PROCEDURE getItemValues(itemValues OUT itemval_tab);
  
  PROCEDURE chkAllHalfSizeChar(i_charactors IN VARCHAR2, results OUT BOOLEAN);
  TYPE clntno_r_val is RECORD (
       zentity    VARCHAR2(50),
       zigvalue   VARCHAR2(50)
  );
  TYPE clntno_tab IS
        TABLE OF clntno_r_val INDEX BY VARCHAR2(50);  -- zentity         
  PROCEDURE getClientNumber(clientNumber OUT clntno_tab);
  
  PROCEDURE cnvClientNumber(i_PJClientNumber IN VARCHAR2, IGClientNumber OUT VARCHAR2);
  
  TYPE dfpopf_tab IS 
       TABLE OF dfpopf%rowtype INDEX BY VARCHAR2(9);  -- CHDRCOY + TEMPLATE
  PROCEDURE getDfpopfValues(dfpopfValues OUT dfpopf_tab);
  

  PROCEDURE validDateVal(i_date IN CHAR, results OUT BOOLEAN);

  PROCEDURE shiftDateVal(i_dm IN CHAR, i_date IN CHAR, i_increment IN NUMBER, o_date OUT CHAR);
  
  PROCEDURE calcMonths(i_fmdate IN CHAR, i_todate IN CHAR, o_month OUT NUMBER);
  
  PROCEDURE getFormOutDate(i_ccdate IN CHAR, i_increment IN NUMBER DEFAULT -1, o_frmoutdt OUT CHAR);
  
  PROCEDURE getRenewal(i_zplancls IN CHAR, i_zblnkpol IN VARCHAR2, i_b8gpst IN CHAR, i_b8o9nb IN CHAR, i_company in CHAR, o_zrnwabl OUT CHAR);
  
  PROCEDURE setInsTypSt(i_instype1 IN CHAR, i_instype2 IN CHAR, i_instype3 IN CHAR,i_instype4 IN CHAR, o_instypst OUT VARCHAR2);
  
  TYPE errordesc IS TABLE OF VARCHAR2(250) INDEX BY VARCHAR2(6);
  PROCEDURE geterrordesc(o_errortext   OUT errordesc);
  
  PROCEDURE sortStrings(i_string IN VARCHAR2, o_string OUT VARCHAR2);
 
  ---- PA END ---- 
end PKG_DM_MASTPOLICY;
/


create or replace PACKAGE BODY          "PKG_DM_MASTPOLICY" as

  PROCEDURE getItemValues(itemValues OUT itemval_tab)

   is
   
    itemRec itemval_r_val;
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_company itempf.itemcoy%type,
      i_table   itempf.itemtabl%type,
      i_item    itempf.itemitem%type,
      i_itmfrm itempf.itmfrm%type,
      i_itmto  itempf.itmto%type,
      i_genarea VARCHAR2(2000));

    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;

  BEGIN

    Select itemcoy, itemtabl, itemitem, itmfrm, itmto, utl_raw.cast_to_varchar2(genarea) 
        BULK COLLECT
        into itempflist
        from itempf
    where TRIM(itemtabl) IN ('T9799','TQ9FK','TQ9E4','T3684','TQ9E6','TW966','TQ9B6','TQ9GX')
         and TRIM(itemcoy) IN (1, 9)
         and TRIM(itempfx) = 'IT'
         and TRIM(validflag)= '1'
    ORDER BY TRIM(itemtabl);

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
        CASE (TRIM(itempflist(indexitems).i_table)) 
           WHEN 'T9799' THEN
                itemRec.itmfrm := TRIM(itempflist(indexitems).i_itmfrm);
                itemRec.itmto := TRIM(itempflist(indexitems).i_itmto);
                itemRec.itemval1 := null;
                itemRec.itemval2 := null;
                itemRec.itemval3 := null;   
           WHEN 'TQ9FK' THEN
                itemRec.itmfrm := TRIM(itempflist(indexitems).i_itmfrm);
                itemRec.itmto := TRIM(itempflist(indexitems).i_itmto);
                itemRec.itemval1 := SUBSTR(itempflist(indexitems).i_item,1,3);
                itemRec.itemval2 := SUBSTR(itempflist(indexitems).i_item,4,2);
                itemRec.itemval3 := SUBSTR(itempflist(indexitems).i_genarea,9,7);  
           WHEN 'TQ9E4' THEN
                itemRec.itmfrm := TRIM(itempflist(indexitems).i_itmfrm);
                itemRec.itmto := TRIM(itempflist(indexitems).i_itmto);
                itemRec.itemval1 := null;
                itemRec.itemval2 := null;
                itemRec.itemval3 := null; 
           WHEN 'T3684' THEN
                itemRec.itmfrm := TRIM(itempflist(indexitems).i_itmfrm);
                itemRec.itmto := TRIM(itempflist(indexitems).i_itmto);
                itemRec.itemval1 := SUBSTR(itempflist(indexitems).i_genarea,196,1);
                itemRec.itemval2 := SUBSTR(itempflist(indexitems).i_genarea,200,2);
                itemRec.itemval3 := null; 
           WHEN 'TQ9E6' THEN
                itemRec.itmfrm := TRIM(itempflist(indexitems).i_itmfrm);
                itemRec.itmto := TRIM(itempflist(indexitems).i_itmto);
                itemRec.itemval1 := null;
                itemRec.itemval2 := null;
                itemRec.itemval3 := null;   
           WHEN 'TW966' THEN
                itemRec.itmfrm := TRIM(itempflist(indexitems).i_itmfrm);
                itemRec.itmto := TRIM(itempflist(indexitems).i_itmto);
                itemRec.itemval1 := null;
                itemRec.itemval2 := null;
                itemRec.itemval3 := null;   
           WHEN 'TQ9B6' THEN
                itemRec.itmfrm := TRIM(itempflist(indexitems).i_itmfrm);
                itemRec.itmto := TRIM(itempflist(indexitems).i_itmto);
                itemRec.itemval1 := null;
                itemRec.itemval2 := null;
                itemRec.itemval3 := null; 
           WHEN 'TQ9GX' THEN
                itemRec.itmfrm := TRIM(itempflist(indexitems).i_itmfrm);
                itemRec.itmto := TRIM(itempflist(indexitems).i_itmto);
                itemRec.itemval1 := SUBSTR(itempflist(indexitems).i_genarea,1,5); ---TIMECH01
                itemRec.itemval2 := SUBSTR(itempflist(indexitems).i_genarea,6,5); ---TIMECH02
                itemRec.itemval3 := null; 
         END CASE;
        itemValues(TRIM(itempflist(indexitems).i_table) || TRIM(itempflist(indexitems).i_item) || TRIM(itempflist(indexitems).i_company)) := itemRec;
    END LOOP;

   END; 

  PROCEDURE chkAllHalfSizeChar(i_charactors IN VARCHAR2, results OUT BOOLEAN)
    is

    REF_HALFWIDTHKANA  constant VARCHAR2(500) := 'ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮﾟﾞｰ･';
    i_halfKana                  BOOLEAN;

  BEGIN
        results := TRUE;
        FOR i IN 1 .. LENGTH(i_charactors) LOOP
            IF LENGTH(SUBSTR(i_charactors, i, 1)) <> LENGTHB(SUBSTR(i_charactors, i, 1)) THEN
                i_halfKana := FALSE;
                FOR j IN 1 .. LENGTH(REF_HALFWIDTHKANA) LOOP
                    IF SUBSTR(i_charactors, i, 1) = SUBSTR(REF_HALFWIDTHKANA, j, 1)  THEN
                       i_halfKana := TRUE;
                       EXIT;
                    END IF;               
                END LOOP;            
                IF i_halfKana = FALSE THEN
                    results := FALSE;
                    EXIT;
                END IF;
            END IF; 
        END LOOP;

  END;

  PROCEDURE cnvClientNumber(i_PJClientNumber IN VARCHAR2, IGClientNumber OUT VARCHAR2)
    is

    i_clientnumber                  VARCHAR2(8);

  BEGIN

        BEGIN
           SELECT
                 ZIGVALUE
           INTO
                 i_clientnumber
           FROM
                 PAZDCLPF
           WHERE
                 TRIM(ZENTITY) = TRIM(i_PJClientNumber) 
             AND PREFIX = 'CC';
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                 i_clientnumber := NULL;
        END; 

        IF i_clientnumber IS NULL THEN
           BEGIN
              SELECT
                    ZIGVALUE
              INTO
                    i_clientnumber
              FROM
                    ZDCLPF
              WHERE
                    TRIM(ZENTITY) = TRIM(i_PJClientNumber) 
                AND PREFIX = 'CC';
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                    i_clientnumber := NULL;
           END;    
        END IF;

        IGClientNumber := i_clientnumber;

  END;

    PROCEDURE getDfpopfValues(dfpopfValues OUT dfpopf_tab)

   is

    dfpopfRec dfpopf%rowtype;
    indexdfpopf PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_company itempf.itemcoy%type,
      i_table   itempf.itemtabl%type,
      i_item    itempf.itemitem%type,
      i_itmfrm itempf.itmfrm%type,
      i_itmto  itempf.itmto%type,
      i_genarea VARCHAR2(2000));

    TYPE v_array IS TABLE OF dfpopf%rowtype;
    dfpopflist v_array;

  BEGIN

    Select *
        BULK COLLECT
        into dfpopflist
        from dfpopf
    ORDER BY TRIM(chdrcoy), TRIM(template);


    FOR indexdfpopf IN dfpopflist.first .. dfpopflist.last LOOP
        dfpopfValues(TRIM(dfpopflist(indexdfpopf).template) || TRIM(dfpopflist(indexdfpopf).chdrcoy) ) := dfpopflist(indexdfpopf);
    END LOOP;

   END; 


PROCEDURE validDateVal(i_date IN CHAR, results OUT BOOLEAN)
    is

    w_date            DATE;
  BEGIN
        results := TRUE;
        BEGIN  
            w_date := TO_DATE(i_date,'YYYYMMDD');
        EXCEPTION
           WHEN OTHERS THEN
                 results := FALSE;
        END;    
  END;

PROCEDURE shiftDateVal(i_dm IN CHAR, i_date IN CHAR, i_increment IN NUMBER, o_date OUT CHAR)
    is

    i_results      BOOLEAN;

  BEGIN

    validDateVal( i_date => i_date, results => i_results);
    IF i_results = TRUE THEN
       IF i_dm = 'D' THEN
          o_date := TO_CHAR(TO_DATE(i_date,'YYYYMMDD') + i_increment,'YYYYMMDD');
       ELSIF i_dm = 'M' THEN
          o_date := TO_CHAR(ADD_MONTHS(TO_DATE(i_date,'YYYYMMDD'), i_increment),'YYYYMMDD');
       ELSE
          o_date := NULL;
       END IF;
    ELSE
       o_date := NULL;
    END IF;

  END;

PROCEDURE calcMonths(i_fmdate IN CHAR, i_todate IN CHAR, o_month OUT NUMBER)
    is

    i_results      BOOLEAN;

  BEGIN

    o_month := NULL;
    validDateVal( i_date => i_fmdate, results => i_results);
    IF i_results = TRUE THEN
       validDateVal( i_date => i_todate, results => i_results);
       IF i_results = TRUE THEN
          o_month := CEIL(MONTHS_BETWEEN(TO_DATE(i_todate,'YYYYMMDD'),TO_DATE(i_fmdate,'YYYYMMDD')));
       END IF;   
    END IF;

  END;

PROCEDURE getFormOutDate(i_ccdate IN CHAR, i_increment IN NUMBER DEFAULT -1, o_frmoutdt OUT CHAR)  
    is

    i_results      BOOLEAN;
    i_oneMonthBf   CHAR(08);

  BEGIN

    o_frmoutdt := NULL;
    validDateVal( i_date => i_ccdate, results => i_results);
    IF i_results = TRUE THEN
       i_oneMonthBf := TO_CHAR(ADD_MONTHS(TO_DATE(i_ccdate,'YYYYMMDD'),i_increment),'YYYYMMDD');
       o_frmoutdt := SUBSTR(i_oneMonthBf,1,6) || '01';  
    END IF;

  END;

 PROCEDURE getRenewal(i_zplancls IN CHAR, i_zblnkpol IN VARCHAR2, i_b8gpst IN CHAR, i_b8o9nb IN CHAR, i_company in CHAR, o_zrnwabl OUT CHAR)
    is

    i_results      BOOLEAN;
    v_BUSDATE      busdpf.busdate%type;

  BEGIN

    --- add 20201218
    SELECT
          BUSDATE
    INTO
          v_BUSDATE
    FROM
          busdpf
    WHERE
          TRIM(company) = TRIM(i_company);

    IF i_zplancls = 'FP' OR i_zblnkpol = 'Y' THEN
       o_zrnwabl := 'N';
    /* -- ZJNPG-9748 - P2-11763 change of requirement   
    ELSIF TRIM(i_b8gpst) = 'Y' THEN
       o_zrnwabl := 'Y'; --P2-11763 comment 
    ELSE
       IF TRIM(i_b8o9nb) IS NOT NULL THEN
           validDateVal( i_date => '20' || TRIM(i_b8o9nb), results => i_results);
           IF i_results = TRUE THEN
              IF v_BUSDATE >= 20 || TRIM(i_b8o9nb) THEN
                  o_zrnwabl := 'N';
              ELSE
                  o_zrnwabl := 'Y';
              END IF;
           ELSE
              o_zrnwabl := 'N';           
           END IF;           
       ELSE
           o_zrnwabl := 'Y';
       END IF;
    END IF;
    */ ----P2-11763 change of requirement   
  
  -- ZJNPG-9748 - P2-11763: Start: ----
   ELSIF TRIM(i_b8gpst) IS NULL THEN  --Requirement #1
    o_zrnwabl := 'Y';
   ELSIF TRIM(i_b8gpst) = 'Y' THEN    --Requirement #2
    o_zrnwabl := 'Y';
   ELSE 
       IF TRIM(i_b8o9nb) IS NOT NULL THEN
           validDateVal( i_date => '20' || TRIM(i_b8o9nb), results => i_results);
           IF i_results = TRUE THEN
              IF v_BUSDATE >= 20 || TRIM(i_b8o9nb) THEN --Requirement #4
                  o_zrnwabl := 'N';
              ELSE
                  o_zrnwabl := 'Y';                     --Requirement #3
              END IF;
           ELSE
              o_zrnwabl := 'N';           
           END IF;           
       ELSE
           o_zrnwabl := 'Y';
       END IF;
    END IF;      
  -- ZJNPG-9748 - P2-11763: END:   ----
  END;

 PROCEDURE setInsTypSt(i_instype1 IN CHAR, i_instype2 IN CHAR, i_instype3 IN CHAR,i_instype4 IN CHAR, o_instypst OUT VARCHAR2)
     is

    i_results      BOOLEAN;
    i_oneMonthBf   CHAR(08);

  BEGIN

    o_instypst := NULL;
    IF TRIM(i_instype1) IS NULL THEN
       o_instypst :=  o_instypst || '   ';
    ELSE
       o_instypst :=  o_instypst || TRIM(i_instype1);
    END IF;

    IF TRIM(i_instype2) IS NULL THEN
       o_instypst :=  o_instypst || ',' || '   ';
    ELSE
       o_instypst :=  o_instypst || ',' || TRIM(i_instype2);
    END IF;

    IF TRIM(i_instype3) IS NULL THEN
       o_instypst :=  o_instypst || ',' || '   ';
    ELSE
       o_instypst :=  o_instypst || ',' || TRIM(i_instype3);
    END IF;

    IF TRIM(i_instype4) IS NULL THEN
       o_instypst :=  o_instypst || ',' || '   ';
    ELSE
       o_instypst :=  o_instypst || ',' || TRIM(i_instype4);
    END IF;   

END;
  PROCEDURE geterrordesc(o_errortext   OUT errordesc)


   is

    indexerror PLS_INTEGER;
    TYPE obj_error IS RECORD(
      errorcode ERORPF.EROREROR%type,
      errordesc ERORPF.ERORDESC%type);
    TYPE v_array IS TABLE OF obj_error;
    errorlist v_array;

  BEGIN

  Select eroreror, erordesc
         BULK COLLECT
  into errorlist
  from ERORPF
  WHERE TRIM(ERORLANG) = TRIM('E')
    AND TRIM(ERORDESC) IS NOT NULL
    AND TRIM(EROREROR) IN (
                           'E177',
                           'E315',
                           'E456',
                           'E725',
                           'E767',
                           'E999',
                           'EV02',
                           'F596',
                           'H357',
                           'H366',
                           'RFQ7',
                           'RFQ9',
                           'RFZW',
                           'RFZX',
                           'RG11',
                           'RGIG',
                           'RPMY',
                           'RPTJ',
                           'RQM2',
                           'RQM9',
                           'RQSQ',
                           'RQX4',
                           'RQYA',
                           'RR99',
                           'RRYM',
                           'W219',
                           'W226',
                           'E048',
                           'RQWL',
                           'D041',
                           'G532',
                           'RFAA'
                           );

 FOR indexerror IN errorlist.first .. errorlist.last LOOP
   o_errortext(TRIM(errorlist(indexerror).errorcode)) :=  REPLACE(TRIM(errorlist(indexerror).errordesc),CHR(39),' '); -- remove single quotation
 END LOOP;

END;

  PROCEDURE sortStrings(i_string IN VARCHAR2, o_string OUT VARCHAR2)

   is 
    v_string                    VARCHAR2(100);
    v_char                      CHAR(1);   

   BEGIN
     IF TRIM(i_string) IS NULL THEN
        o_string := NULL;
     ELSE
        v_string := i_string;
        FOR ix1 in 1..LENGTH(v_string) - 1 LOOP
          FOR ix2 in 1..LENGTH(v_string) - 1 LOOP
              IF SUBSTR(v_string,ix2,1) > SUBSTR(v_string,ix2 + 1,1) THEN
                 v_char := SUBSTR(v_string,ix2,1); 
                 IF ix2 = 1 THEN
                    v_string :=  SUBSTR(v_string, ix2 + 1, 1) ||  v_char || SUBSTR(v_string, ix2 + 2, LENGTH(v_string) - ix2 );
                 ELSE
                    v_string := SUBSTR(v_string, 1, ix2 - 1 )  || SUBSTR(v_string,ix2 + 1,1) || v_char || SUBSTR(v_string, ix2 + 2, LENGTH(v_string) - ix2 );
                 END IF; 
              END IF;
          END LOOP;
        END LOOP;
        o_string:= v_string; 
    END IF;
  END;

  PROCEDURE getClientNumber(clientNumber OUT clntno_tab)

   is

    clntRec clntno_r_val;
    indexdClnt PLS_INTEGER;
    TYPE obj_pazdclpf IS RECORD(
      i_zentity    pazdclpf.zentity%type,
      i_zigvalue   pazdclpf.zigvalue%type);
      
    TYPE v_array IS TABLE OF obj_pazdclpf;
    clntlist v_array;

  BEGIN

    Select DISTINCT zentity, zigvalue
        BULK COLLECT
        into clntlist
        from pazdclpf
        where prefix = 'CC';

    FOR indexdClnt IN clntlist.first .. clntlist.last LOOP
        clntRec.zentity := TRIM(clntlist(indexdClnt).i_zentity);
        clntRec.zigvalue := TRIM(clntlist(indexdClnt).i_zigvalue);        
        clientNumber(TRIM(clntlist(indexdClnt).i_zentity)) := clntRec;
    END LOOP;

   END; 

  ---- PA END ----  
end PKG_DM_MASTPOLICY;
/