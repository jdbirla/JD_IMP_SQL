create or replace FUNCTION                      "VALIDATE_DATE" (
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
