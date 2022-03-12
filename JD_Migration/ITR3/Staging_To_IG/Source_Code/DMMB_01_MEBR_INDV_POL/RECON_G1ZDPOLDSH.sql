create or replace PROCEDURE                 RECON_G1ZDPOLDSH (i_schedulenumber IN VARCHAR2) 
IS
    
  ------------------------ START - Variables and Constants ---------------------------
  v_module_name CONSTANT VARCHAR2(40) := 'Policy Dishonor';
  obj_recon_master recon_master%rowtype;
  C_PASS constant varchar2(4) := 'Pass';
  C_FAIL constant varchar2(4) := 'Fail';

  v_src_oldpolnumcnt   number;
  v_stg_oldpolnumcnt   number;
  v_ig_oldpolnumcnt   number;
  v_ig_validntmgrtdoldpolnumcnt   number;

  v_src_stg_flg     varchar2(1);
  v_stg_ig_flg     varchar2(1);
  v_final_flg      varchar2(1);

  v_ddlquery       varchar2(200);
  p_exitcode       number;
  p_exittext       varchar2(2000);
  ------------------------ END - Variables and Constants -----------------------------

  -------------------------------- Cursor for Source ---------------------------------
  CURSOR c_src_oldpolnum IS  
    SELECT OLDPOLNUM FROM STAGEDBUSR2.TITDMGMBRINDP3@DMSTGUSR2DBLINK;
  obj_c_src c_src_oldpolnum%rowtype;


 BEGIN

  --------------------- START - POLDSH01 (count per oldpolnum) ----------------------
  OPEN c_src_oldpolnum;
  <<skipRecord>>
  LOOP
    FETCH c_src_oldpolnum
      INTO obj_c_src;
    EXIT WHEN c_src_oldpolnum%notfound;

    v_src_stg_flg                 := 'N';
    v_stg_ig_flg                  := 'N';
    v_final_flg                   := 'N';
    v_src_oldpolnumcnt            := 1;
    v_stg_oldpolnumcnt            := 0;
    v_ig_oldpolnumcnt             := 0;
    v_ig_validntmgrtdoldpolnumcnt := 0;
    obj_recon_master              := null;

  ----------------------- Query to Staging table TITDMGMBRINDP3 ---------------------------    
    BEGIN
      SELECT COUNT(OLDPOLNUM) into v_stg_oldpolnumcnt
        FROM STAGEDBUSR.TITDMGMBRINDP3@DMSTAGEDBLINK WHERE OLDPOLNUM = obj_c_src.OLDPOLNUM;
      
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_stg_oldpolnumcnt := 0;
    END;
    
  ----------------------- Query to IG tables PAZDPDPF and ZUCLPF ---------------------------  
   
   ------- Check for table-1 PAZDPDPF --------
    BEGIN
      select COUNT(OLDCHDRNUM) into v_ig_oldpolnumcnt
        from Jd1dta.PAZDPDPF where OLDCHDRNUM = obj_c_src.OLDPOLNUM AND JOBNAME = 'G1ZDPOLDSH';
        
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ig_oldpolnumcnt := 0;
    END;

   --------- Check for table-2 ZUCLPF, only if OLDPOLNUM present in table PAZDPDPF ----------
   IF (v_ig_oldpolnumcnt != 0) THEN
   BEGIN
      select COUNT(CHDRNUM) into v_ig_oldpolnumcnt
        from Jd1dta.ZUCLPF where CHDRNUM = obj_c_src.OLDPOLNUM AND JOBNM = 'G1ZDPOLDSH';
        
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ig_oldpolnumcnt := 0;
    END;
   END IF;
   
   ---------- Check for valid oldpolnum which is not migrated to Staging or IG -------------
   IF (v_ig_oldpolnumcnt = 0) THEN
   BEGIN
     v_ddlquery := 'select count(ZREFKEY) from Jd1dta.ZDOEPD000' || i_schedulenumber || ' where ZREFKEY = ''' || obj_c_src.OLDPOLNUM || 
        ''' AND ERORPROG01 = ''G1ZDPOLDSH'' AND ERRMESS01 = ''Skipped because new policy''';
        EXECUTE IMMEDIATE v_ddlquery INTO v_ig_validntmgrtdoldpolnumcnt;
        
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ig_oldpolnumcnt := 0;
    END;
   
   END IF;
   
  --------------- Insert data into Reconciliation table i.e. RECON_MASTER ----------------
    obj_recon_master.schedule_id     := i_schedulenumber;
    obj_RECON_MASTER.module_name     := v_module_name;
    obj_recon_master.rundate         := SYSDATE;
    obj_recon_master.recon_query_id  := 'POLDSH01';
    obj_recon_master.group_clause    := null;
    obj_recon_master.where_clause    := 'OLDCHDRNUM = ' || obj_c_src.OLDPOLNUM || ' AND JOBNAME = G1ZDPOLDSH';
    obj_recon_master.validation_type := 'Count';
    obj_recon_master.source_value    := v_src_oldpolnumcnt;
    obj_recon_master.staging_value   := v_stg_oldpolnumcnt;
    obj_recon_master.ig_value        := v_ig_oldpolnumcnt;
    obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.TITDMGMBRINDP3 || Stg count: STAGEDBUSR.TITDMGMBRINDP3 || IG count: PAZDPDPF/ZUCLPF';

    if (v_src_oldpolnumcnt = v_stg_oldpolnumcnt) then
      v_src_stg_flg := 'Y';
    end if;
    
    if (v_stg_oldpolnumcnt = v_ig_oldpolnumcnt) then
      v_stg_ig_flg := 'Y';
    end if;
    
    if (v_stg_oldpolnumcnt != v_ig_oldpolnumcnt and v_ig_validntmgrtdoldpolnumcnt = 1) then
      v_stg_ig_flg := 'Y';
    end if;

    if (v_src_stg_flg = 'Y' AND v_stg_ig_flg = 'Y') then
      v_final_flg := 'Y';
    end if;

    if (v_final_flg = 'Y') then
      obj_recon_master.status := C_PASS;
    else
      obj_recon_master.status := C_FAIL;
    end if;
    
    INSERT INTO Jd1dta.RECON_MASTER VALUES obj_recon_master;
  END LOOP;
  close c_src_oldpolnum;
  
  ---------------------- END - POLDSH01 (count per oldpolnum) -----------------------
   
  COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    p_exitcode := SQLCODE;
    p_exittext := ' RECON_G1ZDPOLDSH ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
    raise_application_error(-20001, p_exitcode || p_exittext);

 END RECON_G1ZDPOLDSH;