create or replace PROCEDURE DM2_G1ZDPOLCOV_PARALLEL_EXE(i_schedulename   IN VARCHAR2,
                                                        i_schedulenumber in Varchar2,
                                                        i_zprvaldyn      IN VARCHAR2,
                                                        i_company        IN VARCHAR2,
                                                        i_usrprf         IN VARCHAR2,
                                                        i_branch         IN VARCHAR2,
                                                        i_transcode      IN VARCHAR2,
                                                        i_vrcmtermid     IN VARCHAR2,
                                                        i_array_size     IN PLS_INTEGER,
                                                        i_remarks        IN VARCHAR2,
                                                        i_chunksize      IN Number,
                                                        i_degreeParallel IN Number,
                                                        o_status         OUT number)
  AUTHID current_user AS
  /**************************************************************************************************************************
  * File Name        : DM2_G1ZDPOLCOV_PARALLEL_EXE
  * Author           : Kevin Sarmiento
  * Creation Date    : August 14, 2020
  * Project          : -----
  ----- Malaysia
  * Description      : This Procedure is for parallel run for Policy Coverage History
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMAG-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   PC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * AUG14    MKS   PH1   New developed in PA
  * -----   -----  ---   ---------------------------------------------------------------------------
  * FEB04    MKS   PH2   PA ITR3 Change  
  ********************************************************************************************************************************/
  l_sql_stmt_f      VARCHAR2(2000 CHAR);
  l_sql_stmt1       VARCHAR2(200 CHAR);
  l_sql_stmt2       VARCHAR2(200 CHAR);
  l_status          NUMBER;
  l_chunk_stmt      VARCHAR2(2000 CHAR);
  v_taskCont        NUMBER;
  v_dataCount       NUMBER;
  v_timestart       NUMBER := dbms_utility.get_time;
  v_tablenametemp   VARCHAR2(10);
  v_tablenamemb     VARCHAR2(10);
  v_tablenamein     VARCHAR2(10);
  v_last_table_name VARCHAR2(10);
  v_schedulenumber  VARCHAR2(10);
  C_PREFIX CONSTANT VARCHAR2(2 CHAR) := GET_MIGRATION_PREFIX('PCHS',
                                                             i_company);
  p_exitcode number;
  p_exittext varchar2(4000);
BEGIN
  v_schedulenumber:= lpad(trim(i_schedulenumber), 4, '0' );
  p_exitcode := 0;
  p_exittext := NULL;
  dbms_output.put_line('Start execution of DM2_G1ZDPOLCOV_PARALLEL_TASK');
  SELECT COUNT(1) INTO v_dataCount FROM Jd1dta.DMIGTITDMGMBRINDP2;

  IF (v_dataCount > 0) THEN
    SELECT COUNT(*)
      INTO v_taskCont
      FROM user_parallel_execute_tasks
     WHERE task_name = 'DM2_G1ZDPOLCOV_PARALLEL_TASK';

    IF v_taskCont > 0 THEN
      dbms_parallel_execute.drop_task('DM2_G1ZDPOLCOV_PARALLEL_TASK');
    END IF;

    v_tablenametemp := 'ZDOE' || trim(C_PREFIX) ||
                       lpad(trim(i_schedulenumber), 4, '0');

    pkg_dm_common_operations.createzdoepf(i_tablename => trim(v_tablenametemp));

    dbms_parallel_execute.create_task('DM2_G1ZDPOLCOV_PARALLEL_TASK');
    dbms_parallel_execute.create_chunks_by_number_col('DM2_G1ZDPOLCOV_PARALLEL_TASK',
                                                      'Jd1dta',
                                                      'DMIGTITDMGMBRINDP2',
                                                      'RECCHUNCKBINDP2',
                                                      i_chunksize);
    l_sql_stmt1 := 'BEGIN  Jd1dta.BQ9SA_PC01_POLCOV(';
    l_sql_stmt2 := '''' || i_schedulename || '''' || ',' || '''' ||
                   v_schedulenumber || '''' || ',' || '''' || i_zprvaldyn || '''' || ',' || '''' ||
                   i_company || '''' || ',' || '''' || i_usrprf || '''' || ',' || '''' ||
                   i_branch || '''' || ',' || 'NULL' || ',' || '''' ||
                   i_vrcmtermid || '''' || ',' || '''' || i_array_size || '''' || ',' || ':start_id' || ',' ||
                   ':end_id' || ');' || 'END;';

    l_sql_stmt_f := l_sql_stmt1 || l_sql_stmt2;
    dbms_output.put_line('Policy Transaction History Procedure call :' || l_sql_stmt_f);

    dbms_parallel_execute.run_task(task_name      => 'DM2_G1ZDPOLCOV_PARALLEL_TASK',
                                   sql_stmt       => l_sql_stmt_f,
                                   language_flag  => dbms_sql.native,
                                   parallel_level => i_degreeParallel); ---Keep this number low may be 2 or max 5.

    l_status := dbms_parallel_execute.task_status('DM2_G1ZDPOLCOV_PARALLEL_TASK');

    o_status := l_status;

    dbms_output.put_line('DM2_G1ZDPOLCOV_PARALLEL_TASK completed! Status:' ||
                         l_status);
	
  END IF;
     dbms_output.put_line('End execution of DM2_G1ZDPOLCOV_PARALLEL_TASK');

  IF (i_zprvaldYN = 'N' AND l_status = 7) THEN
     INSERT /*+ APPEND */ INTO Jd1dta.ZODMPRMVERPF (CHDRCOY, CHDRNUM, CCDATE, CRDATE, ZINSTYPE, ZODMPRMVER, USRPRF, JOBNM, DATIME)
     SELECT DISTINCT 1 chrdcoy, p2.refnum, gc.ccdate, gc.crdate, p2.zinstype,
     CASE 
      WHEN p2.zinstype = 'EQ' THEN
        1
      WHEN gc.CCDATE < 20201201 THEN
        1
      ELSE
        2
      END AS zodmprmver,
      i_usrprf,
  	i_scheduleName,
  	CAST(sysdate AS TIMESTAMP)
     FROM Jd1dta.dmigtitdmgmbrindp2 p2
     LEFT OUTER JOIN Jd1dta.gchipf gc ON gc.chdrnum = p2.refnum and gc.ccdate = p2.effdate
     WHERE p2.periodcnt = p2.periodno AND
       EXISTS (SELECT 1 FROM Jd1dta.gxhipf gx WHERE gx.chdrnum = p2.refnum AND gx.zinstype = p2.zinstype); 
     COMMIT;
  END IF;

exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'DM2_G1ZDPOLCOV_PARALLEL_EXE : ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      (i_scheduleName, v_schedulenumber, p_exitcode, p_exittext, sysdate);
 commit;
raise;

END DM2_G1ZDPOLCOV_PARALLEL_EXE;