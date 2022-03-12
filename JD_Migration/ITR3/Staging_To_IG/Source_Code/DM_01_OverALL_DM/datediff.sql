create or replace FUNCTION datediff (datepart IN VARCHAR2, date_from IN Number, date_to IN number)
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