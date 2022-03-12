CREATE OR REPLACE FUNCTION VALIDATE_JAPANESE_TEXT(
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
