create or replace PROCEDURE          "BQ9SS_DM01_OVERALLDM" (i_scheduleName   IN VARCHAR2,
                                                 i_scheduleNumber IN VARCHAR2,
                                                 i_company        IN VARCHAR2,
                                                 i_rprocess       IN VARCHAR2,
                                                 o_ztotOk         OUT NUMBER,
                                                 o_ztotNprc       OUT NUMBER,
                                                 o_ztotErr        OUT NUMBER,
                                                 o_zTotal         OUT NUMBER,
                                                 o_longdesc       OUT VARCHAR2,
                                                 o_zdoetablename  OUT VARCHAR2,
                                                 o_startTime      OUT VARCHAR2) AS

  --timecheck
  v_timestart       number := dbms_utility.get_time;
  v_prefix          VARCHAR2(2 CHAR);
  v_prefixIN        VARCHAR2(2 CHAR);
  v_prefixMB        VARCHAR2(2 CHAR);
  v_tableNametIN    VARCHAR2(10);
  v_tableNameIN     VARCHAR2(10);
  v_tableNametMB    VARCHAR2(10);
  v_tableNameMB     VARCHAR2(10);
  v_tableNametemp   VARCHAR2(10);
  v_tableName       VARCHAR2(10);
  v_sqlQuery1       VARCHAR2(500);
  v_sqlQuery2       VARCHAR2(500);
  v_sqlQuery3       VARCHAR2(500);
  v_sqlQuery4       VARCHAR2(500);
  v_prefixitem1     BPRDPF.Bpsyspar04%type;
  v_prefixitem2     BPRDPF.Bpsyspar03%type;
  v_zdoepftablename BPRDPF.Bpsyspar01%type;
  v_bprogramname    VARCHAR2(30);
  v_filenametemp    VARCHAR2(30);
  v_fileName        VARCHAR2(30);
  o_ztotOkIN        NUMBER(16) DEFAULT 0;
  o_ztotNprcIN      NUMBER(16) DEFAULT 0;
  o_ztotErrIN       NUMBER(16) DEFAULT 0;
  o_zTotalIN        NUMBER(16) DEFAULT 0;
  o_ztotOkMB        NUMBER(16) DEFAULT 0;
  o_ztotNprcMB      NUMBER(16) DEFAULT 0;
  o_ztotErrMB       NUMBER(16) DEFAULT 0;
  o_zTotalMB        NUMBER(16) DEFAULT 0;
  o_longdescIN      DESCPF.Longdesc%type;
  o_longdescMB      DESCPF.Longdesc%type;
  C_TQ9Q8    constant varchar2(5) := 'TQ9Q8';
  C_MBRINDSC constant varchar2(10) := 'BQ9SC';

BEGIN
  select TRIM(LEADING '#' FROM BPRIORPROC)
    into v_bprogramname
    from BPSRPRI
   where TRIM(BSUBSEQPRC) = TRIM('#' || TRIM(i_rprocess));

  --- v_bprogramname := get_prior_process_name(rprocess => TRIM(i_rprocess));

  IF (TRIM(v_bprogramname) != C_MBRINDSC) THEN

    SELECT BPSYSPAR01,
           BPSYSPAR04,
           to_char(cast(BPDATMSTRT as date), 'hh24:mi:ss')
      into v_zdoepftablename, v_prefixitem1, o_startTime
      from (SELECT BP.BPSYSPAR01, BP.BPSYSPAR04, BS.BPDATMSTRT
              FROM BPRDPF BP
             INNER JOIN BSPRPF BS
                ON BP.COMPANY = BS.COMPANY
               AND BP.BPROCESNAM = BS.BPROCESNAM
             WHERE TRIM(BS.BSCHEDNAM) = TRIM(i_scheduleName)
               AND TRIM(BS.BSCHEDNUM) = i_scheduleNumber
               AND TRIM(BP.BPROGRAM) = TRIM(v_bprogramname)
               and TRIM(BS.BPRCSTATUS) = '90'
               and TRIM(BP.Bprocesnam) = TRIM('#' || v_bprogramname)
               and rownum = 1
             ORDER BY BS.DATIME desc)
     where rownum = 1;

    v_filenametemp  := get_stage_table_name(bprogram => v_bprogramname);
    v_fileName      := '''' || v_filenametemp || '''';
    v_prefix        := GET_MIGRATION_PREFIX(TRIM(v_prefixitem1), i_company);
    v_tableNametemp := SUBSTR(v_zdoepftablename, 1, 4) || TRIM(v_prefix) ||
                       LPAD(TRIM(i_scheduleNumber), 4, '0');
    v_tableName     := TRIM(v_tableNametemp);
    o_zdoetablename := v_filenametemp;
    v_sqlQuery1     := 'SELECT COUNT(*) ' || ' FROM ' || v_tableName ||
                       '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                       ' AND TRIM(INDIC) = ''S''';

    --dbms_output.put_line('v_sqlQuery1' || v_sqlQuery1);
    EXECUTE IMMEDIATE v_sqlQuery1
      into o_ztotOk;

    v_sqlQuery2 := 'SELECT COUNT(*) FROM  ' || v_tableName ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NOT NULL OR TRIM(EROR02) IS NOT NULL OR TRIM(EROR03) IS NOT NULL OR TRIM(EROR04) IS NOT NULL OR TRIM(EROR05) IS NOT NULL )';
    EXECUTE IMMEDIATE v_sqlQuery2
      into o_ztotErr;

    v_sqlQuery3 := 'SELECT COUNT(*) FROM ' || v_tableName ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NULL AND TRIM(EROR02) IS NULL AND TRIM(EROR03) IS NULL AND TRIM(EROR04) IS NULL AND TRIM(EROR05) IS NULL )';
    EXECUTE IMMEDIATE v_sqlQuery3
      into o_ztotNprc;
    o_ztotNprc := 0;
    /*  v_sqlQuery4 := ' SELECT COUNT(*) FROM ' || v_tableName;
    EXECUTE IMMEDIATE v_sqlQuery4
      into o_zTotal;*/
    o_zTotal := o_ztotOk + o_ztotErr + o_ztotNprc;

    SELECT LONGDESC
      into o_longdesc
      FROM DESCPF
     WHERE TRIM(DESCPFX) = 'IT'
       AND TRIM(DESCTABL) = C_TQ9Q8
       AND TRIM(DESCITEM) = TRIM(v_prefixitem1)
       AND TRIM(DESCCOY) = i_company
       AND TRIM(LANGUAGE) = 'E';
  ELSE

    SELECT BPSYSPAR01,
           BPSYSPAR03,
           BPSYSPAR04,
           to_char(cast(BPDATMSTRT as date), 'hh24:mi:ss')
      into v_zdoepftablename, v_prefixitem1, v_prefixitem2, o_startTime
      from (SELECT BP.BPSYSPAR01,
                   BP.BPSYSPAR03,
                   BP.BPSYSPAR04,
                   BS.BPDATMSTRT
              FROM BPRDPF BP
             INNER JOIN BSPRPF BS
                ON BP.COMPANY = BS.COMPANY
               AND BP.BPROCESNAM = BS.BPROCESNAM
             WHERE TRIM(BS.BSCHEDNAM) = TRIM(i_scheduleName)
               AND TRIM(BS.BSCHEDNUM) = i_scheduleNumber
               AND TRIM(BP.BPROGRAM) = TRIM(v_bprogramname)
               and TRIM(BS.BPRCSTATUS) = '90'
               and TRIM(BP.Bprocesnam) = TRIM('#' || v_bprogramname)
               and rownum = 1
             ORDER BY BS.DATIME desc)
     where rownum = 1;

    v_filenametemp := get_stage_table_name(bprogram => v_bprogramname);
    v_fileName     := '''' || v_filenametemp || '''';

    v_prefixIN := GET_MIGRATION_PREFIX(TRIM(v_prefixitem1), i_company);
    v_prefixMB := GET_MIGRATION_PREFIX(TRIM(v_prefixitem2), i_company);

    v_tableNametIN := SUBSTR(v_zdoepftablename, 1, 4) || TRIM(v_prefixIN) ||
                      LPAD(TRIM(i_scheduleNumber), 4, '0');
    v_tableNameIN  := TRIM(v_tableNametIN);

    v_tableNametMB  := SUBSTR(v_zdoepftablename, 1, 4) || TRIM(v_prefixMB) ||
                       LPAD(TRIM(i_scheduleNumber), 4, '0');
    v_tableNameMB   := TRIM(v_tableNametMB);
    o_zdoetablename := v_filenametemp;
    v_sqlQuery1     := 'SELECT COUNT(*) ' || ' FROM ' || v_tableNameIN ||
                       '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                       ' AND TRIM(INDIC) = ''S''';

    --dbms_output.put_line('v_sqlQuery1' || v_sqlQuery1);
    EXECUTE IMMEDIATE v_sqlQuery1
      into o_ztotOkIN;

    v_sqlQuery2 := 'SELECT COUNT(*) FROM  ' || v_tableNameIN ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NOT NULL OR TRIM(EROR02) IS NOT NULL OR TRIM(EROR03) IS NOT NULL OR TRIM(EROR04) IS NOT NULL OR TRIM(EROR05) IS NOT NULL )';
    EXECUTE IMMEDIATE v_sqlQuery2
      into o_ztotErrIN;

    v_sqlQuery3 := 'SELECT COUNT(*) FROM ' || v_tableNameIN ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NULL AND TRIM(EROR02) IS NULL AND TRIM(EROR03) IS NULL AND TRIM(EROR04) IS NULL AND TRIM(EROR05) IS NULL )';
    EXECUTE IMMEDIATE v_sqlQuery3
      into o_ztotNprcIN;
    o_ztotNprcIN := 0;
    o_zTotalIN   := o_ztotOkIN + o_ztotErrIN + o_ztotNprcIN;
    /*v_sqlQuery4 := ' SELECT COUNT(*) FROM ' || v_tableNameIN;
    EXECUTE IMMEDIATE v_sqlQuery4
      into o_zTotalIN;*/

    SELECT LONGDESC
      into o_longdescIN
      FROM DESCPF
     WHERE TRIM(DESCPFX) = 'IT'
       AND TRIM(DESCTABL) = C_TQ9Q8
       AND TRIM(DESCITEM) = TRIM(v_prefixitem1)
       AND TRIM(DESCCOY) = i_company
       AND TRIM(LANGUAGE) = 'E';
    -------------------------MB: START------------------------------

    v_sqlQuery1 := 'SELECT COUNT(*) ' || ' FROM ' || v_tableNameMB ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   ' AND TRIM(INDIC) = ''S''';

    --dbms_output.put_line('v_sqlQuery1' || v_sqlQuery1);
    EXECUTE IMMEDIATE v_sqlQuery1
      into o_ztotOkMB;

    v_sqlQuery2 := 'SELECT COUNT(*) FROM  ' || v_tableNameMB ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NOT NULL OR TRIM(EROR02) IS NOT NULL OR TRIM(EROR03) IS NOT NULL OR TRIM(EROR04) IS NOT NULL OR TRIM(EROR05) IS NOT NULL )';
    EXECUTE IMMEDIATE v_sqlQuery2
      into o_ztotErrMB;

    v_sqlQuery3 := 'SELECT COUNT(*) FROM ' || v_tableNameMB ||
                   '  WHERE TRIM(zfilenme) = ' || v_fileName ||
                   '  AND TRIM(INDIC) = ''E'' AND ( TRIM(EROR01) IS NULL AND TRIM(EROR02) IS NULL AND TRIM(EROR03) IS NULL AND TRIM(EROR04) IS NULL AND TRIM(EROR05) IS NULL )';
    EXECUTE IMMEDIATE v_sqlQuery3
      into o_ztotNprcMB;
    o_ztotNprcMB := 0;
    o_zTotalMB   := o_ztotOkMB + o_ztotErrMB + o_ztotNprcMB;
    /* v_sqlQuery4 := ' SELECT COUNT(*) FROM ' || v_tableNameMB;
    EXECUTE IMMEDIATE v_sqlQuery4
      into o_zTotalMB;*/

    SELECT LONGDESC
      into o_longdescMB
      FROM DESCPF
     WHERE TRIM(DESCPFX) = 'IT'
       AND TRIM(DESCTABL) = C_TQ9Q8
       AND TRIM(DESCITEM) = TRIM(v_prefixitem2)
       AND TRIM(DESCCOY) = i_company
       AND TRIM(LANGUAGE) = 'E';

    o_ztotOk   := o_ztotOkIN + o_ztotOkMB;
    o_ztotNprc := o_ztotNprcIN + o_ztotNprcMB;
    o_ztotErr  := o_ztotErrIN + o_ztotErrMB;
    o_zTotal   := o_zTotalIN + o_zTotalMB;
    o_longdesc := TRIM(o_longdescIN) || ' and ' || TRIM(o_longdescMB);
    ------------------------MB END-----------------------------------------------
  END IF;
  dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100);

END BQ9SS_DM01_OVERALLDM;




