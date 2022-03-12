create or replace FUNCTION DATCONOPERATION(datepart   IN VARCHAR2,
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
/CREATE OR REPLACE FUNCTION DATCONOPERATION(datepart   IN VARCHAR2,
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
/
