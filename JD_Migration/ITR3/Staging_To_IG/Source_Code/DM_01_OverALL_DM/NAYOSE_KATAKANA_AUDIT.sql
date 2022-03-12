create or replace PROCEDURE                                      "NAYOSE_KATAKANA_AUDIT" (v_halfWidthStr in VARCHAR2) is

  CURSOR cur_clntpf IS
    SELECT * FROM Jd1dta.audit_clntpf
    where newclttype is not null;
  v_name     varchar2(2000);
  obj_clntpf cur_clntpf%rowtype;
begin
  delete from Jd1dta.clntpf_NAYOSE_audit;
  OPEN cur_clntpf;
  <<skipRecord>>
  LOOP
    FETCH cur_clntpf
      INTO obj_clntpf;
    EXIT WHEN cur_clntpf%notfound;

    /*dbms_output.put_line('obj_clntpf oldzkanagnmnor = ' ||
                         obj_clntpf.oldzkanagnmnor);
    dbms_output.put_line('obj_clntpf oldzkanasnmnor = ' ||
                         obj_clntpf.oldzkanasnmnor);
    dbms_output.put_line('obj_clntpf newzkanagnmnor = ' ||
                         obj_clntpf.newzkanagnmnor);
    dbms_output.put_line('obj_clntpf newzkanasnmnor = ' ||
                         obj_clntpf.newzkanasnmnor);*/
   IF (obj_clntpf.oldzkanagnmnor IS NOT NULL) THEN
        IF (TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.oldzkanagnmnor)) IS NOT NULL) THEN
          obj_clntpf.oldzkanagnmnor := halfByteKatakanaNormalized_fun(obj_clntpf.oldzkanagnmnor);
        ELSE
          obj_clntpf.oldzkanagnmnor := ' ';
        END IF;
   END IF;
   IF (obj_clntpf.oldzkanasnmnor IS NOT NULL) THEN
        IF (TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.oldzkanasnmnor)) IS NOT NULL) THEN
          obj_clntpf.oldzkanasnmnor := halfByteKatakanaNormalized_fun(obj_clntpf.oldzkanasnmnor);
        ELSE
          obj_clntpf.oldzkanasnmnor := ' ';
        END IF;
    END IF;
    IF (obj_clntpf.newzkanagnmnor IS NOT NULL) THEN
        IF (TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.newzkanagnmnor)) IS NOT NULL) THEN
          obj_clntpf.newzkanagnmnor := halfByteKatakanaNormalized_fun(obj_clntpf.newzkanagnmnor);
        ELSE
          obj_clntpf.newzkanagnmnor := ' ';
        END IF;
	END IF;
	IF (obj_clntpf.newzkanasnmnor IS NOT NULL) THEN
        IF (TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.newzkanasnmnor)) IS NOT NULL) THEN
          obj_clntpf.newzkanasnmnor := halfByteKatakanaNormalized_fun(obj_clntpf.newzkanasnmnor);
        ELSE
          obj_clntpf.newzkanasnmnor := ' ';
        END IF;
	END IF;
    --obj_clntpf.zkanagnmnor :=  NVL2( (TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.zkanagnmnor))),(halfByteKatakanaNormalized_fun(obj_clntpf.zkanagnmnor)), ' ' ) ;
    -- obj_clntpf.zkanasnmnor :=   NVL2(TRIM(halfByteKatakanaNormalized_fun(obj_clntpf.zkanasnmnor)),halfByteKatakanaNormalized_fun(obj_clntpf.zkanasnmnor), ' ' ) ;
    insert into clntpf_NAYOSE_audit values obj_clntpf;
  END LOOP;
  COMMIT;
  CLOSE cur_clntpf;
end NAYOSE_KATAKANA_AUDIT;