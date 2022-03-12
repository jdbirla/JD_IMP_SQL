create or replace PROCEDURE                               "NAYOSE_KATAKANA_CLNTPF" (v_halfWidthStr in VARCHAR2) is

  CURSOR cur_clntpf IS
    SELECT * FROM Jd1dta.clntpf where CLTTYPE = 'P';

  obj_clntpf cur_clntpf%rowtype;
begin
  delete from Jd1dta.clntpf_nayose;
  OPEN cur_clntpf;
  <<skipRecord>>
  LOOP
    FETCH cur_clntpf
      INTO obj_clntpf;
    EXIT WHEN cur_clntpf%notfound;

   -- dbms_output.put_line('obj_clntpf zkanagnmnor = ' ||                         obj_clntpf.zkanagnmnor);
   -- dbms_output.put_line('obj_clntpf zkanasnmnor = ' ||                         obj_clntpf.zkanasnmnor);

    IF(TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.zkanagnmnor)) IS NOT NULL)THEN
    obj_clntpf.zkanagnmnor :=halfByteKatakanaNormalized_fun(obj_clntpf.zkanagnmnor);
    ELSE
     obj_clntpf.zkanagnmnor :=' ';
    END IF;
     IF(TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.zkanasnmnor)) IS NOT NULL)THEN
    obj_clntpf.zkanasnmnor :=halfByteKatakanaNormalized_fun(obj_clntpf.zkanasnmnor);
    ELSE
     obj_clntpf.zkanasnmnor :=' ';
    END IF;
    --obj_clntpf.zkanagnmnor :=  NVL2( (TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.zkanagnmnor))),(halfByteKatakanaNormalized_fun(obj_clntpf.zkanagnmnor)), ' ' ) ;
   -- obj_clntpf.zkanasnmnor :=   NVL2(TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.zkanasnmnor)),halfByteKatakanaNormalized_fun(obj_clntpf.zkanasnmnor), ' ' ) ;
    insert into Jd1dta.clntpf_nayose values obj_clntpf;
  END LOOP;
  COMMIT;
  CLOSE cur_clntpf;
end NAYOSE_KATAKANA_CLNTPF;