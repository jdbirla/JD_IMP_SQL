create or replace PACKAGE   DM_data_trans_perclnthis AS
/*************************************************************************************************** 
 * Amednment History: DM_POLICY_STATUS_CODE
 * Date    Initials   Tag   Decription 
 * -----   --------   ---   --------------------------------------------------------------------------- 
 * MMMDD    XXX       PC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
 * JAN14    MKS       PC1   PA_ITR3 Policy Status Code Initial Code  
*****************************************************************************************************/ 

  PROCEDURE dm_clienthistory_transform(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');
END DM_data_trans_perclnthis;
/
create or replace PACKAGE BODY  DM_data_trans_perclnthis IS
/*************************************************************************************************** 
 * Amednment History: DM_POLICY_STATUS_CODE
 * Date    Initials   Tag   Decription 
 * -----   --------   ---   --------------------------------------------------------------------------- 
 * MMMDD    XXX       PC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
 * JAN14    MKS       PC1   PA_ITR3 Policy Status Code Initial Code  
*****************************************************************************************************/ 
    stg_starttime    TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;    


--START: Client and Client History Source Transform
    PROCEDURE dm_clienthistory_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        v_input_count    NUMBER;
        v_output_count   NUMBER;
        stg_starttime    TIMESTAMP;
        stg_endtime      TIMESTAMP;
        l_err_flg        NUMBER := 0;
        g_err_flg        NUMBER := 0;
        v_errormsg       VARCHAR2(2000);
        temp_no          NUMBER;
        v_targettbl      VARCHAR2(15);
        v_srctble        VARCHAR2(100);
        client_issue EXCEPTION;
        PRAGMA exception_init(client_issue, -20111);

        CURSOR cur_data IS
          SELECT
            RANK() OVER (ORDER BY lst.zkanagnmnor, lst.zkanasnmnor, lst.zendcde, lst.cltsex,	lst.cln_cltphone01,	lst.cltdob,	lst.cln_cltpcode ) AS prg_clnt,
            lst.*
          FROM (
            SELECT  
              halfbytekatakananormalized_fun(fnl.zkanagivname) AS zkanagnmnor,
              halfbytekatakananormalized_fun(fnl.zkanasurname) AS zkanasnmnor,
              fnl.*
            FROM
              (
                  SELECT
                      a.apcucd        AS apcucd,
                      x.stg_clntnum   AS refnum,
                      substr(a.apcucd, - 3) AS zseqno,
                      a.apa2dt        AS effdate,
                      TRIM(substr((TRIM(a.apcbig)), 1,(
                          CASE
                              WHEN instr(TRIM(a.apcbig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(a.apcbig), unistr('\3000')) 
                              WHEN instr(TRIM(a.apcbig), ' ')  <> 0 THEN
                                  instr(TRIM(a.apcbig), ' ')
                              ELSE
                                  instr(TRIM(a.apcbig), '?')
                          END
                      ) - 1))  lsurname,

                      TRIM(substr((TRIM(a.apcbig)),(
                          CASE
                              WHEN instr(TRIM(a.apcbig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(a.apcbig), unistr('\3000')) 
                              WHEN instr(TRIM(a.apcbig), ' ')  <> 0 THEN
                                  instr(TRIM(a.apcbig), ' ')
                              ELSE
                                  instr(TRIM(a.apcbig), '?')
                          END
                      ) + 1)) lgivname,
                      nvl(TRIM(substr((TRIM(a.apb5tx)), instr((TRIM(a.apb5tx)), ' ') + 1)), ' ') AS zkanagivname,
                      nvl(TRIM(substr((TRIM(a.apb5tx)), 1, instr((TRIM(a.apb5tx)), ' ') - 1)), ' ') AS zkanasurname,
                      REGEXP_REPLACE(a.apc9cd ,'[^0-9]') AS  cltpcode,
                      regexp_replace(a.apc9cd, '\D', '') AS  cln_cltpcode,
                      a.apb7ig        AS cltaddr01,
                      a.apb8ig        AS cltaddr02,
                      a.apb9ig        AS cltaddr03,
                      --a.apb0tx        AS zkanaddr01,
                      --a.apb1tx        AS zkanaddr02,
                      CASE
                          WHEN (a.apb0tx IS NULL OR a.apb1tx IS NULL)  AND k.kana1 IS NOT NULL THEN
                            k.kana1
                          WHEN (a.apb0tx = ' '  OR a.apb1tx = ' ') AND k.kana1 IS NOT NULL THEN
                            k.kana1
                          ELSE
                            a.apb0tx
                      END  AS zkanaddr01, --P2-19448 If any address is null/blank fetch from KANA_ADDRESS_LIST
                      CASE
                          WHEN (a.apb0tx IS NULL OR a.apb1tx IS NULL) AND k.kana2 IS NOT NULL THEN
                            k.kana2
                          WHEN (a.apb0tx = ' '  OR a.apb1tx = ' ') AND k.kana2 IS NOT NULL THEN
                            k.kana2
                          ELSE
                            a.apb1tx
                      END  AS zkanaddr02,--P2-19448 If any address is null/blank fetch from KANA_ADDRESS_LIST
                      decode(a.apbast, '1', 'M', '2', 'F') AS cltsex,
                      'R' AS addrtype,  --ZJNPG-9095 : Addrtype must be defaulted as 'R'
                      nvl(a.apb4tx, '                ')        AS cltphone01, 						  --ZJNPG-10268: cltphone01 is not mandatory in IG anymore.
                      nvl(regexp_replace(a.apb4tx, '\D', ''), '                ') AS  cln_cltphone01, --ZJNPG-10268: cltphone01 is not mandatory in IG anymore.
                      a.apb9tx        AS cltphone02,
                      b.iscpcd        AS occpcode,
                      a.apa3dt        AS cltdob,
                      b.isb1ig        AS zoccdsc,
                      substr(a.apcdig, 1, 25) AS zworkplce,
                      a.apdlcd        AS zaltrcde01,
                     decode(a.apcucd, max_apcucd, 1, 0) AS transhist,
                  a.apc6cd        AS zendcde,
                  x.insur_typ     AS clntroleflg,
                  1 AS n7_ver,
                  1 AS n4_ver,
                  a.min_apcucd,
                  a.max_apcucd,
                  s.plnclass || 'P' AS policytype,
                  s.statcode AS policystatus,
                  CASE
                      WHEN ( (s.statcode = 'IF' or s.statcode = 'XN') AND s.plnclass = 'P' ) THEN
                          '1'
                      WHEN ( (s.statcode = 'IF' or s.statcode = 'XN') AND s.plnclass = 'F' ) THEN
                          '2'
                      WHEN ( (s.statcode = 'CA' or s.statcode = 'LA') AND s.plnclass = 'P' ) THEN
                          '3'
                      WHEN ((s.statcode = 'CA' or s.statcode = 'LA') AND s.plnclass = 'F' ) THEN
                          '4'
                      ELSE
                          '9'
                    END AS priorty                
                FROM
                  (
                      SELECT
                          a.*,
                          concat(substr(apcucd, 1, 10), MIN(substr(apcucd, - 1)) OVER(
                              PARTITION BY substr(apcucd, 1, 10)
                          )) min_apcucd,
                          concat(substr(apcucd, 1, 10), MAX(substr(apcucd, - 1)) OVER(
                              PARTITION BY substr(apcucd, 1, 10)
                          )) max_apcucd
                      FROM
                          zmrap00 a 
                      WHERE (a.apblst IN (1,3,5) 
                                        OR a.apdlcd IN ('N1','NS','N7','N4'))
                  ) a
                  INNER JOIN persnl_clnt_flg        x ON a.apcucd = x.apcucd
                                                        AND x.isa4st IS NULL
                  LEFT OUTER JOIN zmris00           b ON a.apcucd = b.iscucd
                                                        AND b.isa4st = '1'
                  LEFT OUTER JOIN zmrisa00          c ON b.iscicd = c.isacicd
                  LEFT OUTER JOIN kana_address_list k ON a.apc9cd = k.postalcd
                  LEFT OUTER JOIN policy_statcode   s on substr(a.apcucd, 1, 8) =  s.chdrnum
                  WHERE
                      ( a.apcucd = a.min_apcucd AND apblst IN (1,3, 5) )
                      OR apdlcd IN ('N1','NS','N7','N4')

                  UNION ALL

                  SELECT
                      a.apcucd        AS apcucd,
                      x.stg_clntnum   AS refnum,
                      substr(a.apcucd, - 3) AS zseqno,
                      a.apa2dt        AS effdate,
                      TRIM(substr((TRIM(b.isbvig)), 1,(
                          CASE
                              WHEN instr(TRIM(b.isbvig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(b.isbvig), unistr('\3000')) 
                              WHEN instr(TRIM(b.isbvig), ' ')  <> 0 THEN
                                  instr(TRIM(b.isbvig), ' ')
                              ELSE
                                  instr(TRIM(b.isbvig), '?')
                          END
                      ) - 1))   AS lsurname,
                      TRIM(substr((TRIM(b.isbvig)),(
                          CASE
                              WHEN instr(TRIM(b.isbvig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(b.isbvig), unistr('\3000')) 
                              WHEN instr(TRIM(b.isbvig), ' ')  <> 0 THEN
                                  instr(TRIM(b.isbvig), ' ')
                              ELSE
                                  instr(TRIM(b.isbvig), '?')
                          END
                      ) + 1)) AS lgivname,
                      nvl(TRIM(substr((TRIM(b.isbtig)), instr((TRIM(b.isbtig)), ' ') + 1)), ' ') AS zkanagivname,
                      nvl(TRIM(substr((TRIM(b.isbtig)), 1, instr((TRIM(b.isbtig)), ' ') - 1)), ' ') AS zkanasurname,
					  REGEXP_REPLACE(c.isac9cd,'[^0-9]')  AS  cltpcode,
                      regexp_replace(c.isac9cd, '\D', '') AS  cln_cltpcode,
                      c.isab7ig AS cltaddr01,
                      c.isab8ig AS cltaddr02,
                      c.isab9ig AS cltaddr03,
                      --c.isab0tx AS zkanaddr01,
                      --c.isab1tx AS zkanaddr02,
                      CASE
                          WHEN (c.isab0tx IS NULL OR c.isab1tx IS NULL )AND k.kana1 IS NOT NULL THEN
                            k.kana1
                          WHEN (c.isab0tx = ' ' OR c.isab1tx = ' ') AND k.kana1 IS NOT NULL THEN
                            k.kana1
                          ELSE
                            c.isab0tx
                      END  AS zkanaddr01,--P2-19448 If any address is null/blank fetch from KANA_ADDRESS_LIST
                      CASE
                          WHEN(c.isab0tx IS NULL OR c.isab1tx IS NULL ) AND k.kana2 IS NOT NULL THEN
                            k.kana2
                          WHEN (c.isab0tx = ' ' OR c.isab1tx = ' ') AND k.kana2 IS NOT NULL THEN
                            k.kana2
                          ELSE
                            c.isab1tx
                      END AS zkanaddr02,--P2-19448 If any address is null/blank fetch from KANA_ADDRESS_LIST
                    /*nvl2(i.iscucd, a.apc9cd, c.isac9cd) AS cltpcode,
                      nvl2(i.iscucd, a.apb7ig, c.isab7ig) AS cltaddr01,
                      nvl2(i.iscucd, a.apb8ig, c.isab8ig) AS cltaddr02,
                      nvl2(i.iscucd, a.apb9ig, c.isab9ig) AS cltaddr03,
                      nvl2(i.iscucd, a.apb0tx, c.isab0tx) AS zkanaddr01,
                      nvl2(i.iscucd, a.apb1tx, c.isab1tx) AS zkanaddr02, */
                      decode(b.isa3st, '1', 'M', '2', 'F') AS cltsex,
                      'R' AS addrtype, --ZJNPG-9095 : Addrtype must be defaulted as 'R'
                      nvl(c.isab4tx, '                ') AS cltphone01, 							   --ZJNPG-10268: cltphone01 is not mandatory in IG anymore.
                      nvl(regexp_replace(c.isab4tx, '\D', ''), '                ') AS  cln_cltphone01, --ZJNPG-10268: cltphone01 is not mandatory in IG anymore.
                      --nvl2(i.iscucd, a.apb4tx, c.isab4tx) AS cltphone01,
                      b.isbytx        AS cltphone02,
                      b.iscpcd        AS occpcode,
                      b.isatdt        AS cltdob,
                      b.isb1ig        AS zoccdsc,
                      substr(b.isbzig, 1, 25) AS zworkplce,
                      a.apdlcd        AS zaltrcde01,
                      decode(a.apcucd, max_apcucd, 1, 0) AS transhist,
                      a.apc6cd        AS zendcde,
                      x.insur_typ     AS clntroleflg,
                      1 AS n7_ver,
                      1 AS n4_ver,
                      a.min_apcucd,
                      a.max_apcucd,
                      s.plnclass || 'P' AS policytype,
                      s.statcode AS policystatus,
                      CASE
                        WHEN ( (s.statcode = 'IF' or s.statcode = 'XN') AND s.plnclass = 'P' ) THEN
                            '1'
                        WHEN ( (s.statcode = 'IF' or s.statcode = 'XN') AND s.plnclass = 'F' ) THEN
                            '2'
                        WHEN ( (s.statcode = 'CA' or s.statcode = 'LA') AND s.plnclass = 'P' ) THEN
                            '3'
                        WHEN ((s.statcode = 'CA' or s.statcode = 'LA') AND s.plnclass = 'F' ) THEN
                            '4'
                        ELSE
                            '9'
                      END AS priorty  
                  FROM
                  (
                      SELECT
                          a.*,
                          concat(substr(apcucd, 1, 10), MIN(substr(apcucd, - 1)) OVER(
                              PARTITION BY substr(apcucd, 1, 10)
                          )) min_apcucd,
                          concat(substr(apcucd, 1, 10), MAX(substr(apcucd, - 1)) OVER(
                              PARTITION BY substr(apcucd, 1, 10)
                          )) max_apcucd
                      FROM
                          zmrap00 a 
                      WHERE (a.apblst IN (1,3,5 ) 
                                  OR a.apdlcd IN ('N7','ND','N6','N4'))
                  ) a
                  INNER JOIN persnl_clnt_flg        x ON a.apcucd = x.apcucd
                                                          AND x.isa4st IS NOT NULL
                  INNER JOIN zmris00                b ON b.iscicd = x.iscicd
                                                          AND b.isa4st <> '1'
                  LEFT OUTER JOIN zmrisa00          c ON b.iscicd = c.isacicd
                  LEFT OUTER JOIN kana_address_list k ON c.isac9cd = k.postalcd
                  LEFT OUTER JOIN policy_statcode   s on substr(a.apcucd, 1, 8) = s.chdrnum
                  WHERE
                      b.isa4st <> 1
                      AND ( a.apcucd = min_apcucd 
                            AND apblst IN (1,3, 5 ) )
                      OR a.apdlcd IN ('N7','ND','N6', 'N4')
              ) fnl ) lst
          ORDER BY
              lst.refnum,
              lst.zseqno;

        TYPE ig_array IS
            TABLE OF cur_data%rowtype;
        st_data          ig_array;
        prev_data        cur_data%rowtype;

        l_app_old        VARCHAR2(15) := NULL;
        n7_ver           NUMBER := 1;
        n4_ver           NUMBER := 1;
        ins_flg          INTEGER := 0;
        ins_seq          INTEGER := 0;
    BEGIN
        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            OPEN cur_data;
            LOOP
                FETCH cur_data BULK COLLECT INTO st_data LIMIT p_array_size;
                FORALL d_indx IN 1..st_data.COUNT
                  DELETE FROM titdmgcltrnhis_int
                  WHERE
                      refnum = st_data(d_indx).refnum;
                 EXIT WHEN cur_data%notfound;          
            END LOOP;
            COMMIT;
            CLOSE cur_data;
         -- Delete the records for all the records exists in TITDMGCLTRNHIS_INT for Delta Load
        END IF;

        v_errormsg := 'MASTER :';
        v_srctble := 'ZMRAP00,ZMRIS00,PERSNL_CLNT_FLG,POLICY_STATCODE';
        v_targettbl := 'CLNTHIST_INT';
        OPEN cur_data;
        LOOP
            FETCH cur_data BULK COLLECT INTO st_data LIMIT p_array_size;
            v_input_count := v_input_count + st_data.COUNT;
            FOR st_indx IN 1..st_data.COUNT LOOP
              l_app_old := st_data(st_indx).apcucd;
              ins_flg := 0;
              IF prev_data.refnum = st_data(st_indx).refnum THEN
                  IF nvl(prev_data.occpcode, '-1') <> nvl(st_data(st_indx).occpcode, '-1') THEN
                      n4_ver := n4_ver + 1;
                      ins_flg := 1;
                  END IF;

                  IF NOT ( ( nvl(prev_data.lsurname, '-XYZ') = nvl(st_data(st_indx).lsurname, '-XYZ') ) AND ( nvl(prev_data.lgivname, '-XYZ'
                  ) = nvl(st_data(st_indx).lgivname, '-XYZ') ) AND ( nvl(prev_data.zkanagivname, '-XYZ') = nvl(st_data(st_indx).zkanagivname, '-XYZ')
                  ) AND ( nvl(prev_data.zkanasurname, '-XYZ') = nvl(st_data(st_indx).zkanasurname, '-XYZ') ) AND ( nvl(prev_data.cltpcode, '-XYZ'
                  ) = nvl(st_data(st_indx).cltpcode, '-XYZ') ) AND ( nvl(prev_data.cltaddr01, '-XYZ') = nvl(st_data(st_indx).cltaddr01, '-XYZ') ) AND
                  ( nvl(prev_data.cltaddr02, '-XYZ') = nvl(st_data(st_indx).cltaddr02, '-XYZ') ) AND ( nvl(prev_data.cltaddr03, '-XYZ') = nvl
                  (st_data(st_indx).cltaddr03, '-XYZ') ) AND ( nvl(prev_data.zkanaddr01, '-XYZ') = nvl(st_data(st_indx).zkanaddr01, '-XYZ') ) AND ( nvl
                  (prev_data.zkanaddr02, '-XYZ') = nvl(st_data(st_indx).zkanaddr02, '-XYZ') ) AND ( nvl(prev_data.cltsex, '-XYZ') = nvl(st_data(st_indx)
                  .cltsex, '-XYZ') ) AND ( nvl(prev_data.cltphone01, '-XYZ') = nvl(st_data(st_indx).cltphone01, '-XYZ') ) AND ( nvl(prev_data
                  .cltphone02, '-XYZ') = nvl(st_data(st_indx).cltphone02, '-XYZ') ) AND ( nvl(prev_data.cltdob, -1) = nvl(st_data(st_indx).cltdob, -1
                  ) ) ) THEN
                      n7_ver := n7_ver + 1;
                      ins_flg := 1;
                  END IF;

                  IF st_data(st_indx).zaltrcde01 IN (
                      'N1',
                      'NS',
                      'N6',
                      'ND'
                  ) THEN
                      ins_flg := 1;
                  END IF;

                  IF ins_flg = 1 THEN
                      ins_seq := ins_seq + 1;
                  END IF;

              ELSE
                  ins_seq := 0;
                  n7_ver := 1;
                  n4_ver := 1;
                  ins_flg := 1;
              END IF;

              prev_data := st_data(st_indx);

              BEGIN
                  IF ins_flg = 1 THEN
                      v_errormsg := 'INSERT titdmgcltrnhis_int :';
                      INSERT INTO titdmgcltrnhis_int (
                          apcucd,
                          refnum,
                          zseqno,
                          zseqdmno,
                          effdate,
                          lsurname,
                          lgivname,
                          zkanagivname,
                          zkanasurname,
                          cltpcode,
                          cltaddr01,
                          cltaddr02,
                          cltaddr03,
                          zkanaddr01,
                          zkanaddr02,
                          addrtype,
                          cltsex,
                          cltphone01,
                          cltphone02,
                          occpcode,
                          cltdob,
                          zoccdsc,
                          zworkplce,
                          zaltrcde01,
                          transhist,
                          zendcde,
                          clntroleflg,
                          zkanasnmnor,
                          zkanagnmnor,
                          policytype,
                          policystatus,
                          priorty,
                          prg_clnt,
                          n7_ver,
                          n4_ver
                      ) VALUES (
                          st_data(st_indx).apcucd,
                          st_data(st_indx).refnum,
                          ins_seq,
                          st_data(st_indx).zseqno,
                          st_data(st_indx).effdate,
                          st_data(st_indx).lsurname,
                          st_data(st_indx).lgivname, --removed NVL function
                          st_data(st_indx).zkanagivname,
                          st_data(st_indx).zkanasurname,--removed NVL function
                          st_data(st_indx).cltpcode,--removed NVL function
                          st_data(st_indx).cltaddr01,--removed NVL function
                          st_data(st_indx).cltaddr02,--removed NVL function
                          st_data(st_indx).cltaddr03,
                          st_data(st_indx).zkanaddr01,--removed NVL function
                          st_data(st_indx).zkanaddr02,
                          st_data(st_indx).addrtype,
                          st_data(st_indx).cltsex,--removed NVL function
                          st_data(st_indx).cltphone01,
                          st_data(st_indx).cltphone02,
                          st_data(st_indx).occpcode,
                          st_data(st_indx).cltdob,
                          st_data(st_indx).zoccdsc,
                          st_data(st_indx).zworkplce,
                          substr(st_data(st_indx).zaltrcde01, 1, 4),
                          st_data(st_indx).transhist,
                          st_data(st_indx).zendcde,
                          st_data(st_indx).clntroleflg,
                          st_data(st_indx).zkanasnmnor,
                          st_data(st_indx).zkanagnmnor,
                          st_data(st_indx).policytype,
                          st_data(st_indx).policystatus,
                          st_data(st_indx).priorty,
                          st_data(st_indx).prg_clnt,
                          n7_ver,
                          n4_ver
                      );
                  END IF;

              v_output_count := v_output_count + 1;
              EXCEPTION
                  WHEN OTHERS THEN
                      g_err_flg := g_err_flg + 1;
                      v_errormsg := v_errormsg
                                    || '-'
                                    || sqlerrm;
                      DM_data_trans_gen.error_logs('TITDMGCLTRNHIS_INT', st_data(st_indx).apcucd, v_errormsg);
              END;
            END LOOP;
            --IF ( MOD(v_output_count, p_array_size) = 0 ) THEN
              COMMIT;
           -- END IF;
           EXIT WHEN cur_data%notfound;
        END LOOP;
        COMMIT;
        v_input_count := cur_data%rowcount;
        CLOSE cur_data;

        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
            'S', v_input_count, v_output_count);
        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);
        END IF;

--Check if any issue in TITDGCLTRNHIS_INT, raise error and stop  the process.
        IF g_err_flg <> 0 THEN
          raise_application_error(-20111,'TITDGCLTRNHIS_INT has issue. Please check and re-execute.');
        END IF;

--START: NAYOSE CHECK               
        v_errormsg := 'Insert into SRCNAYOSETBL: ';
        v_srctble := 'CLNTHIST_INT';
        v_targettbl := 'SRCNAYOSETBL';
        v_input_count := 0;
        v_output_count := 0;
        INSERT INTO srcnayosetbl 
        (
          refnum,
          zseqno,
          effdate,
          zkanasnmnor,
          zkanagnmnor,
          cltpcode,
          cltaddr01,
          zkanaddr01,
          zkanaddr02,
          cltsex,
          cltphone01,
          occpcode,
          cltdob,
          zendcde,
          policystatus,
          policytype,
          priorty,
          prg_clnt,
          max_apcucd,
          validpriority
        )
        SELECT 
          cl.refnum,
          cl.zseqno,
          cl.effdate,
          cl.zkanasnmnor,
          cl.zkanagnmnor,
          regexp_replace(cl.cltpcode, '\D', '') AS  cltpcode,
          cl.cltaddr01,
          cl.zkanaddr01,
          cl.zkanaddr02,
          cl.cltsex,
          nvl(regexp_replace(cl.cltphone01, '\D', ''), '                ') AS  cltphone01, --#ZJNPG-10273 : cltphone01 is no longer required in IG.
          cl.occpcode,
          cl.cltdob,
          cl.zendcde,
          cl.policystatus,
          cl.policytype,
          cl.priorty,
          cl.prg_clnt,
          cl.max_apcucd,  
          DECODE(RANK() OVER ( PARTITION BY cl.prg_clnt ORDER BY cl.priorty, cl.effdate DESC, cl.refnum desc), 1, 1, 0) AS validpriority
        FROM
         (SELECT a.*,
            concat(a.refnum, (MAX(a.zseqno) OVER( PARTITION BY a.refnum)) ) max_apcucd
           FROM titdmgcltrnhis_int a
          ) cl
        WHERE cl.refnum || cl.zseqno = max_apcucd 
        ORDER BY cl.prg_clnt, cl.priorty, cl.effdate DESC, cl.refnum DESC;

        IF sql%found THEN
          v_errormsg := 'SUCCESS';
          v_input_count := sql%ROWCOUNT;
          temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
                                                                                  'S', v_input_count, v_input_count);
          COMMIT;
        END IF;
--END: NAYOSE CHECK   

--START: INSERT CLIENT MAPPING TABLE
        v_errormsg := 'Insert into TITDMGCLNTMAP: ';
        v_srctble := 'SRCNAYOSETBL';
        v_targettbl := 'TITDMGCLNTMAP';
        v_input_count := 0;
        v_output_count := 0;
        INSERT INTO TITDMGCLNTMAP (REFNUM,STAGECLNTNO,DATIME)
          SELECT 
            DISTINCT src.refnum, ny.stageclntno, systimestamp
          FROM srcnayosetbl src
          LEFT OUTER JOIN
            (SELECT refnum AS stageclntno,
              prg_clnt
            FROM srcnayosetbl
            WHERE validpriority = 1
            ) ny
          ON src.prg_clnt = ny.prg_clnt
          ORDER BY ny.stageclntno;

        IF sql%found THEN
          v_errormsg := 'SUCCESS';
          v_input_count := sql%ROWCOUNT;
          temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
          'S', v_input_count, v_input_count);
          COMMIT;
        END IF;
--END: INSERT CLIENT MAPPING TABLE  

--START: FINAL TRANSFORMATION FOR CLIENT AND CLIENT HISTORY
        v_errormsg := 'Insert into TITDMGCLTRNHIS: ';
        v_srctble := 'TITDMGCLTRNHIS_INT, TITDMGCLNTMAP';
        v_targettbl := 'TITDMGCLTRNHIS';
        v_input_count := 0;
        v_output_count := 0;
        INSERT INTO titdmgcltrnhis (
            refnum,
            zseqno,
            zseqdmno,
            effdate,
            lsurname,
            lgivname,
            zkanagivname,
            zkanasurname,
            zkanasnmnor,
            zkanagnmnor,
            cltpcode,
            cltaddr01,
            cltaddr02,
            cltaddr03,
            zkanaddr01,
            zkanaddr02,
            cltsex,
            addrtype,
            cltphone01,
            cltphone02,
            occpcode,
            cltdob,
            zoccdsc,
            zworkplce,
            zaltrcde01,
            transhist,
            zendcde,
            clntroleflg,
            policystatus,
            policytype,
            priorty,
            n7_ver,
            n4_ver
          )
          SELECT cl.refnum,
            cl.zseqno,
            cl.zseqdmno,
            cl.effdate,
            cl.lsurname,
            cl.lgivname,
            cl.zkanagivname,
            cl.zkanasurname,
            cl.zkanasnmnor,
            cl.zkanagnmnor,
            cl.cltpcode,
            cl.cltaddr01,
            cl.cltaddr02,
            cl.cltaddr03,
            cl.zkanaddr01,
            cl.zkanaddr02,
            cl.cltsex,
            cl.addrtype,
            cl.cltphone01,
            cl.cltphone02,
            cl.occpcode,
            cl.cltdob,
            cl.zoccdsc,
            cl.zworkplce,
            cl.zaltrcde01,
            decode(concat(cl.refnum,cl.zseqno), max_apcucd, 1, 0) AS transhist,
            cl.zendcde,
            cl.clntroleflg,
            cl.policystatus,
            cl.policytype,
            cl.priorty,
            cl.n7_ver,
            cl.n4_ver
          FROM 
          (SELECT a.*,
            concat(a.refnum, (MAX(a.zseqno) OVER( PARTITION BY a.refnum)) ) max_apcucd
           FROM titdmgcltrnhis_int a
          ) cl
          WHERE EXISTS (SELECT 1 from titdmgclntmap mp WHERE mp.stageclntno = cl.refnum)
          ORDER by cl.refnum, cl.effdate;

        IF sql%found THEN
          v_errormsg := 'SUCCESS';
          v_input_count := sql%ROWCOUNT;
          temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
          'S', v_input_count, v_input_count);
          COMMIT;
        END IF;
--END: FINAL TRANSFORMATION FOR CLIENT AND CLIENT HISTORY 

--        UPDATE titdmgcltrnhis a set TRANSHIST = 1 where (refnum || ZSEQNO) in (select refnum || max(ZSEQNO) ZSEQNO from stagedbusr2.titdmgcltrnhis group by refnum) 
--        and TRANSHIST = 0;
--        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
        dbms_output.put_line('Error message' || sqlerrm);
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);

    END dm_clienthistory_transform;
--END: Client and Client History Source Transform

END DM_data_trans_perclnthis;
/