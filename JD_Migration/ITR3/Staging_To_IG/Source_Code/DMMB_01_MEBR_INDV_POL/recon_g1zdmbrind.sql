create or replace PROCEDURE recon_g1zdmbrind(i_schedulenumber IN VARCHAR2) IS

  CURSOR c_src_zendcde IS
  
    SELECT 'MBINPOL01' RECONID, apc6cd, COUNT(apc6cd) zencount
      FROM (SELECT DISTINCT substr(apcucd, 1, 8), apc6cd
              FROM stagedbusr2.zmrap00@DMSTGUSR2DBLINK) zmrap
     GROUP BY apc6cd;
  obj_c_src_zendcde c_src_zendcde%rowtype;

  CURSOR c_src_plancde IS
    SELECT 'MBINPOL11' RECONID, zplancde, COUNT(zplancde) plancnt
      FROM STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
     where client_category = 1 and LAST_TRXS ='Y'
     GROUP BY zplancde;
  obj_c_src_plancde c_src_plancde%rowtype;

  v_module_name CONSTANT VARCHAR2(40) := 'DMMB-Member and Individaul Policy';
  obj_recon_master recon_master%rowtype;
  C_PASS constant varchar2(4) := 'PASS';
  C_FAIL constant varchar2(4) := 'FAIL';

  v_stg_zendcde varchar2(50);
  v_stg_zencnt  number;
  v_ig_zendcde  varchar2(50);
  v_ig_zencnt   number;
  v_stg_plancnt number;
  v_ig_plancnt  number;

  v_reconid     Jd1dta.recon_master.recon_query_id%type;
  v_srcCount    number;
  v_stgcount    number;
  v_igCount     number;
  v_src_stg_flg varchar2(1) := 'N';
  v_stg_ig_flg  varchar2(1) := 'N';
  v_final_flg   varchar2(1) := 'N';
  plancnt       number;
  p_exitcode    number;
  p_exittext    varchar2(2000);
BEGIN
 --delete from recon_master;
  -----MBINPOL01 (count per endorser):START------
  OPEN c_src_zendcde;
  <<skipRecord>>
  LOOP
    FETCH c_src_zendcde
      INTO obj_c_src_zendcde;
    EXIT WHEN c_src_zendcde%notfound;

    v_src_stg_flg    := 'N';
    v_stg_ig_flg     := 'N';
    v_final_flg      := 'N';
    v_ig_zencnt      := 0;
    v_stg_zencnt     := 0;
    obj_recon_master := null;
    BEGIN
      SELECT zendcde, COUNT(zendcde)
        into v_stg_zendcde, v_stg_zencnt
        FROM stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
       WHERE client_category = 0 and LAST_TRXS ='Y'
         AND zendcde = obj_c_src_zendcde.apc6cd
       GROUP by zendcde;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_stg_zencnt := 0;
    END;
    BEGIN

      select ZENDCDE, count(ZENDCDE)
        into v_ig_zendcde, v_ig_zencnt
        from (select chdrnum, ZENDCDE
                from Jd1dta.gchppf GCHP
               inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                            from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                           where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y') TIT
                  on GCHP.chdrnum = REFNUM)
       where zendcde = obj_c_src_zendcde.apc6cd
       group by ZENDCDE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ig_zencnt := 0;
    END;

    obj_recon_master.schedule_id     := i_schedulenumber;
    obj_RECON_MASTER.module_name     := v_module_name;
    obj_recon_master.rundate         := SYSDATE;
    obj_recon_master.recon_query_id  := obj_c_src_zendcde.RECONID;
    obj_recon_master.group_clause    := 'Group by Endorser code';
    obj_recon_master.where_clause    := 'ZENDCDE= ' ||
                                        obj_c_src_zendcde.apc6cd;
    obj_recon_master.validation_type := 'COUNT';
    obj_recon_master.source_value    := obj_c_src_zendcde.zencount;
    obj_recon_master.staging_value   := v_stg_zencnt;
    obj_recon_master.ig_value        := v_ig_zencnt;
    obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.ZMRAP00 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHPPF';

    if (obj_c_src_zendcde.zencount = v_stg_zencnt) then

      v_src_stg_flg := 'Y';
    end if;
    if (v_stg_zencnt = v_ig_zencnt) THEN
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
  close c_src_zendcde;
  -----MBINPOL01 (count per endorser):END------

  -----MBINPOL02(Count based on plan classification ='PP'):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  SELECT 'MBINPOL02' RECONID,
         (select count(*)
            from STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and plnclass = 'P') AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and plnclass = 'P') AS stgcount,

         (select count(*)
            from (select gchp.zplancls
                    from Jd1dta.gchppf GCHP
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y') TIT
                      on GCHP.chdrnum = REFNUM
                     and zplancls = 'PP')) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'zplancls= PP';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHPPF';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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

  -----MBINPOL02(Count based on plan classification ='PP'):END------

  -----MBINPOL03(Count based on plan classification ='FP'):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  SELECT 'MBINPOL03' RECONID,
         (select count(*)
            from STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and plnclass = 'F') AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and plnclass = 'F') AS stgcount,
         (select count(*)
            from (select gchp.zplancls
                    from Jd1dta.gchppf GCHP
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y') TIT
                      on GCHP.chdrnum = REFNUM
                     and zplancls = 'FP')) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'zplancls= FP';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHPPF';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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

  -----MBINPOL03(Count based on plan classification ='FP'):END------

  -----MBINPOL04(Count based on STATCODE ='IF'):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  SELECT 'MBINPOL04' RECONID,
         (select count(*)
            from STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and STATCODE = 'IF') AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and STATCODE = 'IF') AS stgcount,
         (select count(*)
            from (select gchd.chdrnum
                    from Jd1dta.GCHD GCHD
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y') TIT
                      on GCHD.chdrnum = REFNUM
                     and STATCODE = 'IF')) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'STATCODE=IF';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHD';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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
  -----MBINPOL04(Count based on STATCODE ='IF'):END------

  -----MBINPOL04_1(Count based on statcode conversion from CA to IF):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

SELECT 'MBINPOL04_1' RECONID,
         (0) AS srcCount,
         (0) AS stgcount,
         (select count(*)
            from (select a.chdrnum, a.statcode GCHD_STATCODE,b.statcode STG_STATCDE,B.ZTRXSTAT,B.dtetrm,B.zpoltdate,B.ZPDATATXFLG from gchd A, dmigtitdmgmbrindp1 B where
A.chdrnum=substr(B.refnum,1,8) and b.client_category='0' and b.LAST_TRXS ='Y'
and A.statcode != b.statcode and B.statcode='CA' and A.statcode='IF')) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'INFO:STATCODE CA to IF converted into IG';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHD';
/*
  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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
  */
   obj_recon_master.status := C_PASS;
  INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

  -----MBINPOL04_1(Count based on statcode conversion from CA to IF):END------

  -----MBINPOL05(Count based on STATCODE ='CA'):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  SELECT 'MBINPOL05' RECONID,
         (select count(*)
            from STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and STATCODE = 'CA') AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and STATCODE = 'CA') AS stgcount,
         (select count(*)
            from (select gchd.chdrnum
                    from Jd1dta.GCHD GCHD
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y') TIT
                      on GCHD.chdrnum = REFNUM
                     and STATCODE = 'CA')) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'STATCODE=CA';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHD';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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

  -----MBINPOL05(Count based on STATCODE ='CA'):END------

   -----MBINPOL05_1(Count based on statcode conversion from IF to CA):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  SELECT 'MBINPOL05_1' RECONID,
         (0) AS srcCount,
         (0) AS stgcount,
         (select count(*)
            from (select a.chdrnum, a.statcode GCHD_STATCODE,b.statcode STG_STATCDE,B.ZTRXSTAT,B.dtetrm,B.zpoltdate,B.ZPDATATXFLG from gchd A, dmigtitdmgmbrindp1 B where
A.chdrnum=substr(B.refnum,1,8) and b.client_category='0' and b.LAST_TRXS ='Y'
and A.statcode != b.statcode and B.statcode='IF' and A.statcode='CA')) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'INFO:STATCODE IF to CA converted into IG';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHD';
/*
  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
    v_stg_ig_flg := 'Y';
  end if;

  if (v_src_stg_flg = 'Y' AND v_stg_ig_flg = 'Y') then
    v_final_flg := 'Y';
  end if;

  if (v_final_flg = 'Y') then
    obj_recon_master.status := C_PASS;

  else
    obj_recon_master.status := C_FAIL;
  end if;*/
    obj_recon_master.status := C_PASS;

  INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

   obj_recon_master.status := C_PASS;

   -----MBINPOL05_1(Count based on statcode conversion from IF to CA):END------

  -----MBINPOL06(Count based on Policy Type = Member Policy):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  SELECT 'MBINPOL06' RECONID,
         (select count(*)
            from STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and CNTTYPIND = 'M') AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and CNTTYPIND = 'M') AS stgcount,
         (select count(*)
            from (select gchd.chdrnum
                    from Jd1dta.GCHD GCHD
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y'
                                 and CNTTYPIND = 'M') TIT
                      on GCHD.chdrnum = REFNUM)) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;
  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'PolicyType = Member policy';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHD';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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

  -----MBINPOL06(Count based on Policy Type = Member Policy):END------

  -----MBINPOL07(Count based on Policy Type = Individaul Policy):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;
  SELECT 'MBINPOL07' RECONID,
         (select count(*)
            from STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and CNTTYPIND = 'I') AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and CNTTYPIND = 'I') AS stgcount,
         (select count(*)
            from (select gchd.chdrnum
                    from Jd1dta.GCHD GCHD
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y'
                                 and CNTTYPIND = 'I') TIT
                      on GCHD.chdrnum = REFNUM)) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;
  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'PolicyType = Individual policy';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHD';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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

  -----MBINPOL07(Count based on Policy Type = Individaul Policy):END------

  -----MBINPOL08(Count based on Blanket policy = True):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  SELECT 'MBINPOL08' RECONID,
         (select count(*)
            from STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and ZBLNKPOL = 'Y') AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 0 and LAST_TRXS ='Y'
             and ZBLNKPOL = 'Y') AS stgcount,
         (select count(*)
            from (select gchd.chdrnum
                    from Jd1dta.GCHD GCHD
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y'
                                 and ZBLNKPOL = 'Y') TIT
                      on GCHD.chdrnum = REFNUM)) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'Blanket policy = TRUE';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHD';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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
  -----MBINPOL08(Count based on Blanket policy = True):END------

  -----MBINPOL09(Count based on Total policy record ):START------

  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;
  SELECT 'MBINPOL09' RECONID,
         (select count(*)
            from (SELECT DISTINCT substr(apcucd, 1, 8)
                    FROM stagedbusr2.zmrap00@DMSTGUSR2DBLINK) zmrap) AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 0 and LAST_TRXS ='Y') AS stgcount,
         (select count(*)
            from (select gchd.chdrnum
                    from Jd1dta.GCHD GCHD
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 0 and LAST_TRXS ='Y') TIT
                      on GCHD.chdrnum = REFNUM)) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;
  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'Total policy Count : where client_category = 0';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.ZMRAP00 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GCHD';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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

  -----MBINPOL09(Count based on Total policy record ):END------

  -----MBINPOL10(Count based on Insured data):START------
  v_reconid        := '';
  v_src_stg_flg    := 'N';
  v_stg_ig_flg     := 'N';
  v_final_flg      := 'N';
  v_srcCount       := 0;
  v_stgcount       := 0;
  v_igCount        := 0;
  obj_recon_master := null;

  SELECT 'MBINPOL10' RECONID,
         (select count(*)
            from STAGEDBUSR2.TITDMGMBRINDP1@DMSTGUSR2DBLINK
           where client_category = 1 and LAST_TRXS ='Y') AS srcCount,
         (select count(*)
            from STAGEDBUSR.titdmgmbrindp1@DMSTAGEDBLINK
           where client_category = 1 and LAST_TRXS ='Y') AS stgcount,
         (select count(*)
            from (select GMHD.chdrnum
                    from Jd1dta.GMHDPF GMHD
                   inner join (select SUBSTR(REFNUM, 1, 8) REFNUM,
                                     ('000' || MBRNO) as MBRNO
                                from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                               where CLIENT_CATEGORY = 1 and LAST_TRXS ='Y') TIT
                      on GMHD.chdrnum = TIT.REFNUM
                     and gmhd.mbrno = tit.mbrno)) as igcount
    into v_reconid, v_srcCount, v_stgcount, v_igCount
    FROM dual;

  obj_recon_master.schedule_id     := i_schedulenumber;
  obj_RECON_MASTER.module_name     := v_module_name;
  obj_recon_master.rundate         := SYSDATE;
  obj_recon_master.recon_query_id  := v_reconid;
  obj_recon_master.group_clause    := '';
  obj_recon_master.where_clause    := 'Total Insured count :where client_category = 1';
  obj_recon_master.validation_type := 'COUNT';
  obj_recon_master.source_value    := v_srcCount;
  obj_recon_master.staging_value   := v_stgcount;
  obj_recon_master.ig_value        := v_igCount;
  obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.titdmgmbrindp1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GMHDPF';

  if (v_srcCount = v_stgcount) then

    v_src_stg_flg := 'Y';
  end if;
  if (v_stgcount = v_igCount) THEN
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

  -----MBINPOL10(Count based on Insured data):END------

  -----MBINPOL11 (count per zplancde ):START------
  OPEN c_src_plancde;
  <<skipRecord>>
  LOOP
    FETCH c_src_plancde
      INTO obj_c_src_plancde;
    EXIT WHEN c_src_plancde%notfound;

    v_src_stg_flg    := 'N';
    v_stg_ig_flg     := 'N';
    v_final_flg      := 'N';
    v_ig_plancnt     := 0;
    v_stg_plancnt    := 0;
    obj_recon_master := null;
    BEGIN
      SELECT COUNT(zplancde)
        into v_stg_plancnt
        FROM stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
       WHERE client_category = 1 and LAST_TRXS ='Y'
         AND zplancde = obj_c_src_plancde.zplancde
       GROUP by zplancde;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_stg_plancnt := 0;
    END;
    BEGIN
/*
      select igplancnt
        into v_ig_plancnt
        from (select zplancde, count(*) igplancnt
                from Jd1dta.GMHIPF GMHI
               inner join (select SUBSTR(REFNUM, 1, 8) REFNUM,
                                 ('000' || MBRNO) as MBRNO
                            from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                           where CLIENT_CATEGORY = 1  AND zplancde = obj_c_src_plancde.zplancde ) TIT
                  on GMHI.chdrnum = TIT.REFNUM
                 and gmhi.mbrno = TIT.mbrno
               group by gmhi.zplancde)
       where zplancde = obj_c_src_plancde.zplancde;*/
       
         select igplancnt
        into v_ig_plancnt from(
       select  zplancde, count(*) igplancnt
        from (select distinct gmhi.chdrnum,gmhi.mbrno,gmhi.zplancde
                from Jd1dta.GMHIPF GMHI
               inner join (select DISTINCT SUBSTR(REFNUM, 1, 8) REFNUM,
                                 ('000' || MBRNO) as MBRNO
                            from stagedbusr.titdmgmbrindp1@DMSTAGEDBLINK
                           where CLIENT_CATEGORY = 1  and LAST_TRXS ='Y' AND zplancde =obj_c_src_plancde.zplancde ) TIT
                  on GMHI.chdrnum = TIT.REFNUM
                 and gmhi.mbrno = TIT.mbrno
                 and gmhi.zplancde =obj_c_src_plancde.zplancde
               )group by zplancde);
               
               
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ig_plancnt := 0;
    END;

    obj_recon_master.schedule_id     := i_schedulenumber;
    obj_RECON_MASTER.module_name     := v_module_name;
    obj_recon_master.rundate         := SYSDATE;
    obj_recon_master.recon_query_id  := obj_c_src_plancde.RECONID;
    obj_recon_master.group_clause    := 'Group by zplancde';
    obj_recon_master.where_clause    := 'zplancde= ' ||
                                        obj_c_src_plancde.zplancde;
    obj_recon_master.validation_type := 'COUNT';
    obj_recon_master.source_value    := obj_c_src_plancde.plancnt;
    obj_recon_master.staging_value   := v_stg_plancnt;
    obj_recon_master.ig_value        := v_ig_plancnt;
    obj_recon_master.query_desc      := 'Src count: STAGEDBUSR2.TITDMGMBRINDP1 || stg count: STAGEDBUSR.TITDMGMBRINDP1 || IG count: GMHIPF';

    if (obj_c_src_plancde.plancnt = v_stg_plancnt) then

      v_src_stg_flg := 'Y';
    end if;
    if (v_stg_plancnt = v_ig_plancnt) THEN
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
  close c_src_plancde;
  -----MBINPOL11 (count per zplancde ):END------

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_exitcode := SQLCODE;
    p_exittext := ' DMMB- Member and Individual Policy ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
    raise_application_error(-20001, p_exitcode || p_exittext);
END recon_g1zdmbrind;