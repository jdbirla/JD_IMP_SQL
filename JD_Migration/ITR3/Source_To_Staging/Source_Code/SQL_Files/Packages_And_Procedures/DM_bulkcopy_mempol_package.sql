create or replace PACKAGE DM_bulkcopy_mempol AS

  PROCEDURE DM_Memberpol_to_ig(
      v_ig_schema  IN VARCHAR2,
      p_array_size IN PLS_INTEGER DEFAULT 1000,
      p_delta      IN CHAR DEFAULT 'N');
      
END DM_bulkcopy_mempol;
/

create or replace PACKAGE BODY     DM_bulkcopy_mempol AS
  v_cnt          NUMBER := 0;
  v_input_count  NUMBER := 0;
  v_output_count NUMBER := 0;
  ig_starttime   TIMESTAMP;
  l_err_flg      NUMBER := 0;
  g_err_flg      NUMBER := 0;
  
-- Procedure for DM Member Policy IG movement <STARTS> Here
PROCEDURE dm_memberpol_to_ig(
    v_ig_schema  IN VARCHAR2,
    p_array_size IN PLS_INTEGER DEFAULT 1000,
    p_delta      IN CHAR DEFAULT 'N' )
IS
TYPE ig_array
IS
  TABLE OF titdmgmbrindp1%rowtype;
  mp_data ig_array;
  v_app titdmgmbrindp1%rowtype;
  v_errormsg     VARCHAR2(2000);
  temp_tablename VARCHAR2(30) := NULL;
  temp_no        NUMBER       := 0;
  dml_errors     EXCEPTION;
  PRAGMA exception_init ( dml_errors, -24381 );
TYPE mpol_rc
IS
  REF
  CURSOR;
    cur_membrpol mpol_rc;
    sqlstmt        VARCHAR2(2000) := NULL;
    l_output_count NUMBER         := 0;
  BEGIN
    v_input_count  := 0;
    v_output_count := 0;
    l_output_count := 0;
    l_err_flg      := 0;
    g_err_flg      := 0;
    dm_data_trans_gen.ig_starttime   := systimestamp;
    temp_tablename := v_ig_schema || '.TITDMGMBRINDP1';
    IF p_delta      = 'Y' THEN
      v_errormsg   := 'For Delta Load:';
      EXECUTE IMMEDIATE 'DELETE FROM ' || temp_tablename || ' T WHERE EXISTS (SELECT ''X'' FROM TITDMGMBRINDP1 DT WHERE DT.REFNUM=T.REFNUM and DT.REFNUM in(select distinct substr(APCUCD,1,8) from TMP_ZMRAP00))' ;
      COMMIT;
      -- Delete the records for all the records exists in TITDMGMBRINDP1 for Delta Load
    END IF;
    sqlstmt := 'SELECT * FROM TITDMGMBRINDP1 where not exists ( select ''x'' from ' || temp_tablename || ' DT WHERE DT.REFNUM=TITDMGMBRINDP1.REFNUM) ORDER BY TITDMGMBRINDP1.REFNUM';
    
    OPEN cur_membrpol FOR sqlstmt;
    LOOP
      FETCH cur_membrpol BULK COLLECT INTO mp_data;--LIMIT p_array_size;
      v_errormsg := temp_tablename || '-Before Bulk Insert:';
      BEGIN
        v_input_count := v_input_count + mp_data.count;
        FORALL i                      IN 1..mp_data.count SAVE EXCEPTIONS
        EXECUTE IMMEDIATE 'INSERT INTO ' || temp_tablename ||
        ' (                                           
            client_category,
            refnum,
            mbrno,
            zinsrole,
            trannomin,
            trannonbrn,
            trannomax,
            clientno,
            occdate,
            gpoltype,
            zendcde,
            zcmpcode,
            mpolnum,
            effdate,
            zpolperd,
            zmargnflg,
            zdfcncy,
            docrcvdt,
            hpropdte,
            ztrxstat,
            zstatresn,
            zanncldt,
            zcpnscde02,
            zsalechnl,
            zsolctflg,
            cltreln,
            zplancde,
            crdtcard,
            preautno,
            bnkacckey01,
            zenspcd01,
            zenspcd02,
            zcifcode,
            dtetrm,
            crdate,
            cnttypind,
            ptdate,
            btdate,
            statcode,
            zwaitpedt,
            zconvindpol,
            zpoltdate,
            oldpolnum,
            zpgpfrdt,
            zpgptodt,
            sinstno,
            trefnum,
            endsercd,
            issdate,
            zpdatatxflg,
            zrwnlage,
            znbmnage,
            termage,
            zblnkpol,
            plnclass,
            zrnwcnt,
            zlaptrx,
            period_no,
            total_period_count,
            last_trxs)                                 
            VALUES                                           
            (:1, :2, :3, :4,:5, :6, :7, :8, :9, :10,                                            
            :11, :12,:13,:14,:15,:16,:17,:18,:19,:20,                                            
            :21,:22,:23,:24,:25,:26,:27,:28,:29,:30,                                            
            :31,:32,:33,:34,:35,:36,:37,:38,:39,:40,                                            
            :41,:42,:43,:44,:45,:46,:47,:48,:49,:50,                                            
            :51,:52,:53,:54,:55,:56,:57,:58,:59,:60)'
        USING mp_data(i).client_category,
              mp_data(i).refnum,
              mp_data(i).mbrno,
              mp_data(i).zinsrole,
              mp_data(i).trannomin,
              mp_data(i).trannonbrn,
              mp_data(i).trannomax,
              mp_data(i).clientno,
              mp_data(i).occdate,
              mp_data(i).gpoltype,
              mp_data(i).zendcde,
              mp_data(i).zcmpcode,
              mp_data(i).mpolnum,
              mp_data(i).effdate,
              mp_data(i).zpolperd,
              mp_data(i).zmargnflg,
              mp_data(i).zdfcncy,
              mp_data(i).docrcvdt,
              mp_data(i).hpropdte,
              mp_data(i).ztrxstat,
              mp_data(i).zstatresn,
              mp_data(i).zanncldt,
              mp_data(i).zcpnscde02,
              mp_data(i).zsalechnl,
              mp_data(i).zsolctflg,
              mp_data(i).cltreln,
              mp_data(i).zplancde,
              mp_data(i).crdtcard,
              mp_data(i).preautno,
              mp_data(i).bnkacckey01,
              mp_data(i).zenspcd01,
              mp_data(i).zenspcd02,
              mp_data(i).zcifcode,
              mp_data(i).dtetrm,
              mp_data(i).crdate,
              mp_data(i).cnttypind,
              mp_data(i).ptdate,
              mp_data(i).btdate,
              mp_data(i).statcode,
              mp_data(i).zwaitpedt,
              mp_data(i).zconvindpol,
              mp_data(i).zpoltdate,
              mp_data(i).oldpolnum,
              mp_data(i).zpgpfrdt,
              mp_data(i).zpgptodt,
              mp_data(i).sinstno,
              mp_data(i).trefnum,
              mp_data(i).endsercd,
              mp_data(i).issdate,
              mp_data(i).zpdatatxflg,
              mp_data(i).zrwnlage,
              mp_data(i).znbmnage,
              mp_data(i).termage,
              mp_data(i).zblnkpol,
              mp_data(i).plnclass,
              mp_data(i).zrnwcnt,
              mp_data(i).zlaptrx,
              mp_data(i).period_no,
              mp_data(i).total_period_count,
              mp_data(i).last_trxs;
        -- V_OUTPUT_COUNT := V_OUTPUT_COUNT + MP_DATA.COUNT;
      EXCEPTION
      WHEN dml_errors THEN
        g_err_flg := 1;
        FOR beindx IN 1..SQL%bulk_exceptions.count
        LOOP
          v_errormsg := 'In Insert -' || sqlerrm(-SQL%bulk_exceptions(beindx).error_code);
          DM_data_trans_gen.error_logs('TITDMGMBRINDP1_IG', SUBSTR(mp_data(SQL%bulk_exceptions(beindx).error_index).refnum, 1, 15), SUBSTR (v_errormsg, 1, 1000));
          l_output_count := l_output_count + 1;
        END LOOP;
      END;
      
    v_app            := NULL;
    
    IF v_input_count <> 0 THEN
      v_app          := mp_data(v_input_count);
    END IF;
    COMMIT;
    EXIT WHEN cur_membrpol%notfound;
  END LOOP;
  CLOSE cur_membrpol;
  
  v_output_count := v_input_count - l_output_count;
  
  IF g_err_flg    = 0 THEN
    v_errormsg   := 'SUCCESS';
    temp_no      := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP1', 'TITDMGMBRINDP1_IG', systimestamp, v_app.refnum, v_errormsg, 'S', v_input_count , v_output_count);
  ELSE
    v_errormsg := 'COMPLETED WITH ERROR';
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP1', 'TITDMGMBRINDP1_IG', systimestamp, v_app.refnum, v_errormsg, 'F', v_input_count , v_output_count);
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    v_errormsg := v_errormsg || '-' || sqlerrm;
    temp_no    := DM_data_trans_gen.ig_control_log('TITDMGMBRINDP1', 'TITDMGMBRINDP1_IG', systimestamp, v_app.refnum, v_errormsg, 'F', v_input_count , v_output_count);
    RETURN;
END dm_memberpol_to_ig;
-- Procedure for DM Member Policy IG movement <ENDS> Here

END DM_bulkcopy_mempol;
/
