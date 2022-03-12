--------------------------------------------------------
--  File created - Monday-December-17-2018   
--------------------------------------------------------

--------------------------------------------------------
--  DDL for Function DATCONOPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "Jd1dta"."DATCONOPERATION" (datepart   IN VARCHAR2,
                                           input_date IN Number)
  RETURN NUMBER AS
  diff NUMBER;
  -- input_datetemp  date;
  cal_day   Number;
  cal_month Number;
  cal_year  Number;
  datetemp  date;
  date1     date;
BEGIN
  --input_datetemp := to_date(TO_CHAR(input_date),'YYYYMMDD');
  select to_number(to_char((select to_date(TO_CHAR(input_date), 'YYYYMMDD') +
                                  INTERVAL '1' DAY
                             from dual),
                           'YYYYMMDD'))
    into cal_day
    from dual;
  /* select to_number(to_char((select to_date(TO_CHAR(input_date), 'YYYYMMDD') +
                                INTERVAL '1' MONTH
                           from dual),
                         'YYYYMMDD'))
  into cal_month
  from dual;*/

  select to_date(TO_CHAR(input_date), 'YYYYMMDD') into datetemp from dual;

  select ADD_MONTHS(datetemp, 1) into date1 from dual;
  cal_month := to_number(to_char(date1, 'YYYYMMDD'));
  /*select to_number(to_char((select ((add_months(to_date(TO_CHAR(input_date),
                                                     'YYYYMMDD'),
                                             12)) + 1)
                           from dual),
                         'YYYYMMDD'))
  into cal_year
  from dual;*/

  diff := CASE datepart
            WHEN 'DAY' THEN
             cal_day
            WHEN 'MONTH' THEN
             cal_month
            WHEN 'YEAR' THEN
             cal_year
          END;
  RETURN diff;
END;
/*CREATE OR REPLACE FUNCTION DATCONOPERATION(datepart   IN VARCHAR2,
                                            input_date IN Number)
  RETURN NUMBER AS
  diff NUMBER;
  -- input_datetemp  date;
  cal_day   Number;
  cal_month Number;
  cal_year  Number;
BEGIN
  --input_datetemp := to_date(TO_CHAR(input_date),'YYYYMMDD');
  select to_number(to_char((select to_date(TO_CHAR(input_date), 'YYYYMMDD') +
                                  INTERVAL '1' DAY
                             from dual),
                           'YYYYMMDD'))
    into cal_day
    from dual;
/*  select to_number(to_char((select to_date(TO_CHAR(input_date), 'YYYYMMDD') +
                                  INTERVAL '1' MONTH
                             from dual),
                           'YYYYMMDD'))
    into cal_month
    from dual;
  select to_number(to_char((select ((add_months(to_date(TO_CHAR(input_date),
                                                       'YYYYMMDD'),
                                               12)) + 1)
                             from dual),
                           'YYYYMMDD'))
    into cal_year
    from dual;*/

 /* diff := CASE datepart
            WHEN 'DAY' THEN
             cal_day
            WHEN 'MONTH' THEN
             cal_month
            WHEN 'YEAR' THEN
             cal_year
          END;
  RETURN diff;
END;
*/





/
--------------------------------------------------------
--  DDL for Function DATEDIFF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "Jd1dta"."DATEDIFF" (datepart IN VARCHAR2, date_from IN Number, date_to IN number)
RETURN NUMBER
AS
  diff NUMBER;
  date_from_temp  date;
  date_to_temp  date;
BEGIN
date_from_temp := to_date(TO_CHAR(date_from),'YYYYMMDD');
date_to_temp := to_date(TO_CHAR(date_to),'YYYYMMDD');
  diff :=  CASE datepart
    WHEN 'DAY'   THEN TRUNC(date_to_temp,'DD') - TRUNC(date_from_temp, 'DD')
    WHEN 'WEEK'  THEN (TRUNC(date_to_temp,'DAY') - TRUNC(date_from_temp, 'DAY')) / 7
    WHEN 'MONTH' THEN MONTHS_BETWEEN(TRUNC(date_to_temp, 'MONTH'), TRUNC(date_from_temp, 'MONTH'))
    WHEN 'YEAR'  THEN floor(months_between(date_to_temp, date_from_temp) /12)
  END;
  RETURN diff;
END;

/

--------------------------------------------------------
--  DDL for Function GET_MIGRATION_PREFIX
--------------------------------------------------------

create or replace FUNCTION          Jd1dta."GET_MIGRATION_PREFIX" (
    i_itemName IN VARCHAR2,
    i_company IN VARCHAR2)
  RETURN VARCHAR2
AS
  v_prefix VARCHAR2(2 CHAR);
  v_msg VARCHAR2(2 CHAR) DEFAULT 'NA';  
BEGIN
select MODPREFIX INTO v_prefix  from Jd1dta.DMPRFXPF where trim(MODULEID)=trim(i_itemName);

  IF v_prefix IS NULL THEN
    RETURN v_msg;
  ELSE
    RETURN v_prefix;
  END IF;  
END;

/
--------------------------------------------------------
--  DDL for Function GET_PRIOR_PROCESS_NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "Jd1dta"."GET_PRIOR_PROCESS_NAME" (
    rprocess IN VARCHAR2)
  RETURN VARCHAR2
AS
BEGIN
 IF TRIM(rprocess) ='BQ9V0' THEN
  RETURN 'BQ9S5' ;
END IF;
IF TRIM(rprocess) ='BQ9V1' THEN
  RETURN 'BQ9Q7';
END IF;
IF TRIM(rprocess) ='BQ9V2' THEN
  RETURN 'BQ9Q6';
END IF;
IF TRIM(rprocess) ='BQ9V3' THEN
  RETURN 'BQ9TV';
END IF;
IF TRIM(rprocess) ='BQ9V4' THEN
  RETURN 'BQ9RU';
END IF;
IF TRIM(rprocess) ='BQ9V5' THEN
  RETURN 'BQ9SF';
END IF;
IF TRIM(rprocess) ='BQ9V6' THEN
  RETURN 'BQ9S8';
END IF;
IF TRIM(rprocess) ='BQ9V7' THEN
  RETURN 'BQ9SC ';
END IF;
IF TRIM(rprocess) ='BQ9V8' THEN
  RETURN 'BQ9UT';
END IF;
IF TRIM(rprocess) ='BQ9V9' THEN
  RETURN 'BQ9UU';
END IF;
IF TRIM(rprocess) ='BQ9VA' THEN
  RETURN 'BQ9TK';
END IF;
IF TRIM(rprocess) ='BQ9VB' THEN
  RETURN 'BQ9TL ';
END IF;
IF TRIM(rprocess) ='BQ9VC' THEN
  RETURN 'BQ9UX';
END IF;
IF TRIM(rprocess) ='BQ9VD' THEN
  RETURN 'BQ9RF';
END IF;

RETURN NULL;
END;


/
--------------------------------------------------------
--  DDL for Function GET_STAGE_TABLE_NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "Jd1dta"."GET_STAGE_TABLE_NAME" (bprogram IN VARCHAR2)
  RETURN VARCHAR2 AS
BEGIN
  IF TRIM(bprogram) = 'BQ9Q6' THEN
    RETURN 'TITDMGCLNTPRSN';
  END IF;
  IF TRIM(bprogram) = 'BQ9S8' THEN
    RETURN 'TITDMGCAMPCDE';
  END IF;
  IF TRIM(bprogram) = 'BQ9SC' THEN
    RETURN 'TITDMGMBRINDP1';
  END IF;
  IF TRIM(bprogram) = 'BQ9UT' THEN
    RETURN 'TITDMGMBRINDP3';
  END IF;
  IF TRIM(bprogram) = 'BQ9SF' THEN
    RETURN 'TITDMGSALEPLN1';
  END IF;
  IF TRIM(bprogram) = 'BQ9Q7' THEN
    RETURN 'TITDMGCLNTCORP';
  END IF;
  IF TRIM(bprogram) = 'BQ9TV' THEN
    RETURN 'TITDMGCLTRNHIS';
  END IF;
  IF TRIM(bprogram) = 'BQ9RU' THEN
    RETURN 'TITDMGCLNTBANK';
  END IF;
  IF TRIM(bprogram) = 'BQ9RF' THEN
    RETURN 'TITDMGLETTER';
  END IF;
  IF TRIM(bprogram) = 'BQ9TK' THEN
    RETURN 'TITDMGBILL1';
  END IF;
  IF TRIM(bprogram) = 'BQ9S5' THEN
    RETURN 'TITDMGAGENTPJ';
  END IF;
  IF TRIM(bprogram) = 'BQ9UU' THEN
    RETURN 'TITDMGPOLTRNH';
  END IF;
    IF TRIM(bprogram) = 'BQ9TL' THEN
    RETURN 'TITDMGCOLRES';
  END IF;
  IF TRIM(bprogram) = 'BQ9UX' THEN
    RETURN 'TITDMGREF1';
  END IF;
  RETURN NULL;
END;

/

--------------------------------------------------------
--  DDL for Function HALFBYTEKATAKANANORMALIZED_FUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "Jd1dta"."HALFBYTEKATAKANANORMALIZED_FUN" (v_halfWidthStr in VARCHAR2)
  RETURN VARCHAR2 AS

  REF_HALFWIDTHKANA  constant varchar2(500) := '±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹¶›ß®©™´Ø¨≠ÆABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  NORM_HALFWIDTHKANA constant varchar2(500) := '±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹¶›±≤≥¥µ¬‘’÷ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ';

  v_inputChar VARCHAR2(500);
  v_index     number;
  v_sb        VARCHAR2(500);
begin

  --dbms_output.put_line('v_halfWidthStr = ' || v_halfWidthStr);
  FOR i IN 1 .. LENGTH(v_halfWidthStr) LOOP
   -- dbms_output.put_line('index at = ' || i);
    v_inputChar := SUBSTR(v_halfWidthStr, i, 1);
   -- dbms_output.put_line(' v_inputChar= ' || v_inputChar);
    v_index := INSTR(REF_HALFWIDTHKANA, v_inputChar);
   -- dbms_output.put_line(' v_index= ' || v_index);
    IF (v_index != 0) THEN
      v_sb := v_sb || SUBSTR(NORM_HALFWIDTHKANA, v_index, 1);
    END IF;
--   dbms_output.put_line(' v_sb= ' || v_sb);
  END LOOP;

  RETURN v_sb;

end halfByteKatakanaNormalized_fun;

  /*StringBuffer sb = new StringBuffer();
  for (int i = 0; i < halfWidthStr.length(); i++) {
    char inputChar = halfWidthStr.charAt(i);
    int index = REF_HALFWIDTHKANA.indexOf(inputChar);
    if (-1 != index) {
      sb.append(NORM_HALFWIDTHKANA.charAt(index));
    }
  }
  return sb.toString();*/
/
--------------------------------------------------------
--  DDL for Function VALIDATE_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "Jd1dta"."VALIDATE_DATE" (
    input_date IN NUMBER)
  RETURN VARCHAR2
AS
  d_date DATE;
BEGIN
  IF input_date = 99999999 THEN
    RETURN 'OK';
  END IF;
IF LENGTH(TO_CHAR(input_date)) < 8 THEN
  RETURN 'Invalid Date ';
END IF;
d_date:=to_date(TO_CHAR(input_date),'YYYYMMDD');
RETURN 'OK';
EXCEPTION
WHEN OTHERS THEN
  RETURN 'Invalid Date';
END;

/
--------------------------------------------------------
--  DDL for Function VALIDATE_JAPANESE_TEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "Jd1dta"."VALIDATE_JAPANESE_TEXT" (
    inputText IN VARCHAR2)
  RETURN VARCHAR2
AS
  v_length          NUMBER(38);
  v_char            VARCHAR2(10);
  isAlphaBetExist   NUMBER(38) DEFAULT 0;
  isJapaneseChar    VARCHAR2(3 CHAR) DEFAULT 'YES';
  japaneseCharCount NUMBER(38) DEFAULT 0;
BEGIN
  -- Check If any alphabet available
  SELECT REGEXP_INSTR(inputText,'[a-z]|[A-Z]') INTO isAlphaBetExist FROM dual;
  IF isAlphaBetExist > 0 THEN
    RETURN 'Invalid';
  END IF;

  -- Check all Japanese charactors
  v_length := LENGTH(inputText);
  FOR i IN 1..v_length
  LOOP
    v_char := SUBSTR(inputText,i,1);
    SELECT REGEXP_INSTR(ASCIISTR(v_char),'[\u3000-\u303F]|[\u3040-\u309F]|[\u30A0-\u30FF]|[\uFF00-\uFFEF]|[\u4E00-\u9FAF]|[\u2605-\u2606]|[\u2190-\u2195]|[\u203B]') INTO japaneseCharCount FROM dual;
    IF japaneseCharCount = 0 THEN
      isJapaneseChar:='NO';
      EXIT;
    END IF;
  END LOOP;

  IF isJapaneseChar = 'NO' THEN
    RETURN 'Invalid';
  ELSE
    RETURN 'OK';
  END IF;
END;

/


--------------------------------------------------------
--  DDL for Function validate_INSTYPE
--------------------------------------------------------

CREATE OR REPLACE FUNCTION validate_INSTYPE(
 in_mastset IN VARCHAR2,
  in_meminsty IN VARCHAR2) RETURN NUMBER AS

    mastset   VARCHAR2(50 CHAR);
   meminsty   VARCHAR2(100 CHAR) ;

    flg        NUMBER := 0;
    n          NUMBER := 0;
BEGIN
mastset := in_mastset;
meminsty := in_meminsty;
    flg := 0;
    LOOP
        n := instr(meminsty, ',');
        IF n = 0 THEN
            IF instr(mastset, meminsty) = 0 THEN
                flg := 0;
            ELSE
                flg := 1;
            END IF;

        ELSE
            IF instr(mastset, substr(meminsty, 1, n - 1)) = 0 THEN
                flg := 0;
            ELSE
                flg := 1;
            END IF;

            meminsty := substr(meminsty, n + 1);
        END IF;

        EXIT WHEN flg = 0 OR n = 0;
    END LOOP;

    RETURN flg;
END validate_INSTYPE;
/
