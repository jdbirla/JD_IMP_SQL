create or replace FUNCTION             "HALFBYTEKATAKANANORMALIZED_FUN" (v_halfWidthStr in VARCHAR2)
  RETURN VARCHAR2 AS

  REF_HALFWIDTHKANA  constant varchar2(500) := 'ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  NORM_HALFWIDTHKANA constant varchar2(500) := 'ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｱｲｳｴｵﾂﾔﾕﾖABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ';

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

