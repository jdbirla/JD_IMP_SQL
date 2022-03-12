create or replace FUNCTION GET_MIGRATION_PREFIX(
    i_itemName IN VARCHAR2,
    i_company IN VARCHAR2)
  RETURN VARCHAR2
AS
  v_prefix VARCHAR2(2 CHAR);
  v_msg VARCHAR2(2 CHAR) DEFAULT 'NA';  
BEGIN
  select TRIM(SUBSTR(utl_raw.cast_to_varchar2(GENAREA),1,10)) INTO v_prefix FROM ITEMPF WHERE RTRIM(ITEMTABL)='TQ9Q8' and RTRIM(ITEMITEM) = i_itemName and RTRIM(ITEMCOY) = i_company;

  IF v_prefix IS NULL THEN
    RETURN v_msg;
  ELSE
    RETURN v_prefix;
  END IF;  
END;
/