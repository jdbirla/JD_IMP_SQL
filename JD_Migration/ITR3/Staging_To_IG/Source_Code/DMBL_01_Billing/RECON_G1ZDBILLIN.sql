create or replace PROCEDURE Jd1dta.RECON_G1ZDBILLIN(i_schedulenumber IN VARCHAR2) IS

/***************************************************************************************************
  * Amendment History: BL01 Billing History
  * Date    Initials   Tag   Description
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       BL1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * SEP02	   CHO       BL1	 PA New Implementation for Reconciliation task
  *****************************************************************************************************/

  obj_recon_master recon_master%rowtype;
  
  C_MODULE_NAME constant varchar2(40) := 'DMBL-Billing Instalment';
  C_PASS constant varchar2(4) := 'PASS';
  C_FAIL constant varchar2(4) := 'FAIL';

  v_stg_zendcde varchar2(50);
  v_ig_zendcde  varchar2(50);
  v_srcCount    number;
  v_stgCount    number;
  v_igCount     number;
  v_src_stg_flg varchar2(1) := 'N';
  v_stg_ig_flg  varchar2(1) := 'N';
  v_final_flg   varchar2(1) := 'N';
  p_exitcode    number;
  p_exittext    varchar2(2000);

  CURSOR c_src_zendcde IS
  select c.zendcde, count(c.zendcde) zencount
    FROM TITDMGBILL1@DMSTGUSR2DBLINK a, zesdpf b, zendrpf c, titdmgmbrindp1@DMSTGUSR2DBLINK d
   where a.zposbdsy = b.zposbdsy
     and a.zposbdsm = b.zposbdsm
     and b.zendscid = c.zendscid
     and trim(a.chdrnum) = SUBSTR(TRIM(d.refnum), 1, 8)
     and c.zendcde = d.zendcde
   group by c.zendcde;

  obj_c_src_zendcde c_src_zendcde%rowtype;

  CURSOR c_src_zendcde2 IS
  select c.zendcde, sum(e.bprem) zencount
    FROM TITDMGBILL1@DMSTGUSR2DBLINK a, zesdpf b, zendrpf c, titdmgmbrindp1@DMSTGUSR2DBLINK d, TITDMGBILL2@DMSTGUSR2DBLINK e
   where a.zposbdsy = b.zposbdsy
     and a.zposbdsm = b.zposbdsm
     and b.zendscid = c.zendscid
     and trim(a.chdrnum) = SUBSTR(TRIM(d.refnum), 1, 8)
     and c.zendcde = d.zendcde
     and a.chdrnum = e.chdrnum
     and a.trrefnum = e.trrefnum
     and a.prbilfdt = e.prbilfdt
   group by c.zendcde;

  obj_c_src_zendcde2 c_src_zendcde2%rowtype;

BEGIN

  -----BILLIN01 (count all for GBIHPF):START------

  BEGIN
    SELECT COUNT(*)
      into v_srcCount
      FROM TITDMGBILL1@DMSTGUSR2DBLINK;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_srcCount := 0;
  END;

  BEGIN
    SELECT COUNT(*)
      into v_stgCount
      FROM stagedbusr.TITDMGBILL1@DMSTAGEDBLINK;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_stgCount := 0;
  END;

  BEGIN
    SELECT COUNT(*)
      into v_igCount
      FROM Jd1dta.gbihpf A
      JOIN stagedbusr.TITDMGBILL1@DMSTAGEDBLINK B
        ON A.CHDRNUM = B.CHDRNUM
       AND A.INSTNO = B.TRREFNUM
       AND A.PRBILFDT = B.PRBILFDT
	 WHERE A.BILLTYP = 'N';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_igCount := 0;
  END;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_recon_master.module_name     := C_MODULE_NAME;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := 'BILLIN01';
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := '';
  obj_recon_master.validation_type := 'COUNT for GBIHPF';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgCount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.TITDMGBILL1 - stg count: STAGEDBUSR.TITDMGBILL1 - IG count: GBIHPF';

  if (v_srcCount = v_stgCount) then    
    v_src_stg_flg := 'Y';
  end if;

  if (v_stgCount = v_igCount) THEN
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

  INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

  -----BILLIN01 (count all for GBIHPF):END------

  -----BILLIN02 (count all for GPMDPF):START------

  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;    
  v_stgCount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  BEGIN
    SELECT COUNT(*)
      into v_srcCount
      FROM TITDMGBILL2@DMSTGUSR2DBLINK;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_srcCount := 0;
  END;

  BEGIN
    SELECT COUNT(*)
      into v_stgCount
      FROM stagedbusr.TITDMGBILL2@DMSTAGEDBLINK;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_stgCount := 0;
  END;

  BEGIN
    SELECT COUNT(*)
      into v_igCount
      FROM Jd1dta.gpmdpf A
      JOIN stagedbusr.TITDMGBILL2@DMSTAGEDBLINK B
        ON A.CHDRNUM = B.CHDRNUM
       AND A.INSTNO = B.TRREFNUM
       AND A.PRMFRDT = B.PRBILFDT
       AND A.PRODTYP = B.PRODTYP
       AND A.MBRNO = B.MBRNO
       AND A.DPNTNO = B.DPNTNO
	 WHERE A.BILLTYP = 'N';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_igCount := 0;
  END;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_recon_master.module_name     := C_MODULE_NAME;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := 'BILLIN02';
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := '';
  obj_recon_master.validation_type := 'COUNT for GPMDPF';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgCount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.TITDMGBILL2 - stg count: STAGEDBUSR.TITDMGBILL2 - IG count: GPMDPF';

  if (v_srcCount = v_stgCount) then    
    v_src_stg_flg := 'Y';
  end if;

  if (v_stgCount = v_igCount) THEN
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

  INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

  -----BILLIN02 (count all for GPMDPF):END------

  -----BILLIN03 (count all for GBIDPF):START------
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;    
  v_stgCount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  BEGIN
    SELECT COUNT(*)
      into v_srcCount
      FROM (
    SELECT CHDRNUM, TRREFNUM, PRBILFDT, PRODTYP
      FROM TITDMGBILL2@DMSTGUSR2DBLINK
     GROUP BY CHDRNUM, TRREFNUM, PRBILFDT, PRODTYP);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_srcCount := 0;
  END;

  BEGIN
    SELECT COUNT(*)
      into v_stgCount
      FROM (
    SELECT CHDRNUM, TRREFNUM, PRBILFDT, PRODTYP
      FROM stagedbusr.TITDMGBILL2@DMSTAGEDBLINK
     GROUP BY CHDRNUM, TRREFNUM, PRBILFDT, PRODTYP);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_stgCount := 0;
  END;

  BEGIN
    SELECT COUNT(*)
      into v_igCount
      FROM Jd1dta.gbidpf A,
           Jd1dta.PAZDRBPF B
     WHERE A.BILLNO = B.ZIGVALUE;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_igCount := 0;
  END;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_recon_master.module_name     := C_MODULE_NAME;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := 'BILLIN03';
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := '';
  obj_recon_master.validation_type := 'COUNT for GBIDPF';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgCount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.TITDMGBILL2 - stg count: STAGEDBUSR.TITDMGBILL2 - IG count: GBIDPF';

  if (v_srcCount = v_stgCount) then    
    v_src_stg_flg := 'Y';
  end if;

  if (v_stgCount = v_igCount) THEN
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

  INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

  -----BILLIN03 (count all for GBIDPF):END------

  -----BILLIN04 (count bills per endorser for GBIHPF):START------
  
  OPEN c_src_zendcde;

  LOOP
    FETCH c_src_zendcde
     INTO obj_c_src_zendcde;
    EXIT WHEN c_src_zendcde%notfound;

    v_src_stg_flg    := 'N';
    v_stg_ig_flg     := 'N';
    v_final_flg      := 'N';
    v_srcCount       := 0;    
    v_stgCount       := 0;
    v_igCount        := 0;
    obj_recon_master := null;

    BEGIN       
      select c.zendcde, count(c.zendcde)
        into v_stg_zendcde, v_stgCount
        FROM stagedbusr.TITDMGBILL1@DMSTAGEDBLINK a, zesdpf b, zendrpf c, stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK d
       where a.zposbdsy = b.zposbdsy
         and a.zposbdsm = b.zposbdsm
         and b.zendscid = c.zendscid
         and trim(a.chdrnum) = SUBSTR(TRIM(d.refnum), 1, 8)
         and c.zendcde = d.zendcde
         and d.zendcde = obj_c_src_zendcde.zendcde
       group by c.zendcde;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_stgCount := 0;
    END;

    BEGIN
      SELECT d.zendcde, COUNT(d.zendcde)
        into v_ig_zendcde, v_igCount
        FROM Jd1dta.gbihpf A, stagedbusr.TITDMGBILL1@DMSTAGEDBLINK B, zesdpf c, zendrpf d, 
             stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK e
       WHERE A.CHDRNUM = B.CHDRNUM
         AND A.INSTNO = B.TRREFNUM
         AND A.PRBILFDT = B.PRBILFDT
		 AND A.BILLTYP = 'N'
         AND b.zposbdsy = c.zposbdsy
         and b.zposbdsm = c.zposbdsm
         and c.zendscid = d.zendscid
         and trim(b.chdrnum) = SUBSTR(TRIM(e.refnum), 1, 8)
         and d.zendcde = e.zendcde
         and e.zendcde = obj_c_src_zendcde.zendcde
       group by d.zendcde;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_igCount := 0;
    END;

    obj_recon_master.schedule_id     := i_schedulenumber;
    obj_recon_master.module_name     := C_MODULE_NAME;
    obj_recon_master.rundate         := SYSDATE;
    obj_recon_master.recon_query_id  := 'BILLIN04';
    obj_recon_master.group_clause    := 'Endorser code';
    obj_recon_master.where_clause    := 'ZENDCDE = ' || obj_c_src_zendcde.zendcde;
    obj_recon_master.validation_type := 'COUNT bills for GBIHPF';
    obj_recon_master.source_value    := obj_c_src_zendcde.zencount;
    obj_recon_master.staging_value   := v_stgCount;
    obj_recon_master.ig_value        := v_igCount;
    obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.TITDMGBILL1 - stg count: STAGEDBUSR.TITDMGBILL1 - IG count: GBIHPF';

    if (obj_c_src_zendcde.zencount = v_stgCount) then    
      v_src_stg_flg := 'Y';
    end if;

    if (v_stgCount = v_igCount) THEN
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

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

  END LOOP;

    -----BILLIN04 (count bills per endorser for GBIHPF):END------

  -----BILLIN05 (sum billed premiums per endorser for GPMDPF):START------

  OPEN c_src_zendcde2;

  LOOP
    FETCH c_src_zendcde2
     INTO obj_c_src_zendcde2;
    EXIT WHEN c_src_zendcde2%notfound;

    v_src_stg_flg    := 'N';
    v_stg_ig_flg     := 'N';
    v_final_flg      := 'N';
    v_srcCount       := 0;    
    v_stgCount       := 0;
    v_igCount        := 0;
    obj_recon_master := null;

    BEGIN       
      select c.zendcde, sum(e.bprem)
        into v_stg_zendcde, v_stgCount
        FROM stagedbusr.TITDMGBILL1@DMSTAGEDBLINK a, zesdpf b, zendrpf c, stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK d, 
             TITDMGBILL2@DMSTAGEDBLINK e
       where a.zposbdsy = b.zposbdsy
         and a.zposbdsm = b.zposbdsm
         and b.zendscid = c.zendscid
         and trim(a.chdrnum) = SUBSTR(TRIM(d.refnum), 1, 8)
         and c.zendcde = d.zendcde
         and d.zendcde = obj_c_src_zendcde2.zendcde
         and a.chdrnum = e.chdrnum
         and a.trrefnum = e.trrefnum
         and a.prbilfdt = e.prbilfdt
       group by c.zendcde;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_stgCount := 0;
    END;

    BEGIN
      SELECT d.zendcde, sum(a.pprem)
        into v_ig_zendcde, v_igCount
        FROM Jd1dta.gpmdpf A, stagedbusr.TITDMGBILL1@DMSTAGEDBLINK B, zesdpf c, zendrpf d, 
             stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK e
       WHERE A.CHDRNUM = B.CHDRNUM
         AND A.INSTNO = B.TRREFNUM
         AND A.PRMFRDT = B.PRBILFDT
		 AND A.BILLTYP = 'N'
         AND b.zposbdsy = c.zposbdsy
         and b.zposbdsm = c.zposbdsm
         and c.zendscid = d.zendscid
         and trim(b.chdrnum) = SUBSTR(TRIM(e.refnum), 1, 8)
         and d.zendcde = e.zendcde
         and e.zendcde = obj_c_src_zendcde2.zendcde
       group by d.zendcde;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_igCount := 0;
    END;

    obj_recon_master.schedule_id     := i_schedulenumber;
    obj_recon_master.module_name     := C_MODULE_NAME;
    obj_recon_master.rundate         := SYSDATE;
    obj_recon_master.recon_query_id  := 'BILLIN05';
    obj_recon_master.group_clause    := 'Endorser code';
    obj_recon_master.where_clause    := 'ZENDCDE = ' || obj_c_src_zendcde2.zendcde;
    obj_recon_master.validation_type := 'SUM billed premiums for GPMDPF';
    obj_recon_master.source_value    := obj_c_src_zendcde2.zencount;
    obj_recon_master.staging_value   := v_stgCount;
    obj_recon_master.ig_value        := v_igCount;
    obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.TITDMGBILL2 - stg count: STAGEDBUSR.TITDMGBILL2 - IG count: GPMDPF';

    if (obj_c_src_zendcde2.zencount = v_stgCount) then    
      v_src_stg_flg := 'Y';
    end if;

    if (v_stgCount = v_igCount) THEN
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

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

  END LOOP;

    -----BILLIN05 (sum billed premiums per endorser for GPMDPF):END------

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line('error: '||sqlerrm);
    p_exitcode := SQLCODE;
    p_exittext := 'DMBL-Billing Instalment' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
    raise_application_error(-20001, p_exitcode || p_exittext);

END RECON_G1ZDBILLIN;