/**************************************************************************************************************************
  * File Name        : DM2_G1ZDPOLDSH_PARALLEL_EXE
  * Author           : Abhishek Gupta
  * Creation Date    : August 13, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This Procedure is for parallel run for Policy Dishonour Count module
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: MB01 Dishonor
  * Date    Init   Tag   Decription
  * -----   ----   ---   ---------------------------------------------------------------------------
  * MMMDD   XXX    DHXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0813    ABG    DH1   New developed in PA
  
  ********************************************************************************************************************************/

create or replace PROCEDURE                                           Jd1dta.DM2_G1ZDPOLDSH_PARALLEL_EXE(i_schedulename   IN VARCHAR2,
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

  l_sql_stmt        VARCHAR2(2000 CHAR);
  l_sql_stmt_f      VARCHAR2(2000 CHAR);
  l_sql_stmt1       VARCHAR2(200 CHAR);
  l_sql_stmt2       VARCHAR2(200 CHAR);
  l_status          NUMBER;
  l_chunk_stmt      VARCHAR2(2000 CHAR);
  v_taskCont              NUMBER;
  v_dataCount             NUMBER;
  v_timestart       NUMBER := dbms_utility.get_time;
  v_tablenametemp   VARCHAR2(10);
  v_tablenamemb     VARCHAR2(10);
  v_tablenamein     VARCHAR2(10);
  v_last_table_name VARCHAR2(10);
  v_schedulenumber  VARCHAR2(10);
  C_PREFIX CONSTANT VARCHAR2(2 CHAR) := GET_MIGRATION_PREFIX('PDSH',
                                                             i_company);
  p_exitcode number;
  p_exittext varchar2(2000);
BEGIN
 v_schedulenumber:= lpad(trim(i_schedulenumber), 4, '0' );
  p_exitcode := 0;
  p_exittext := NULL;
  dbms_output.put_line('Start execution of DM2_G1ZDPOLDSH_PARALLEL_TASK');
  SELECT COUNT(1) INTO v_dataCount FROM Jd1dta.DMIGTITDMGMBRINDP3;

  IF (v_dataCount > 0) THEN
    SELECT COUNT(*)
      INTO v_taskCont
      FROM user_parallel_execute_tasks
     WHERE task_name = 'DM2_G1ZDPOLDSH_PARALLEL_TASK';

    IF v_taskCont > 0 THEN
      dbms_parallel_execute.drop_task('DM2_G1ZDPOLDSH_PARALLEL_TASK');
    END IF;

  /*  SELECT table_name
      INTO v_last_table_name
      FROM (SELECT table_name
              FROM all_tables
             WHERE owner = 'Jd1dta'
               AND table_name LIKE 'ZDOEAG%'
             ORDER BY table_name DESC)
     WHERE ROWNUM = 1;

    v_schedulenumber := lpad(substr(v_last_table_name, 7, 4) + 1, 4, 0);
  */
    v_tablenametemp := 'ZDOE' || trim(C_PREFIX) ||
                       lpad(trim(i_schedulenumber), 4, '0');

    pkg_dm_common_operations.createzdoepf(i_tablename => trim(v_tablenametemp));

    dbms_parallel_execute.create_task('DM2_G1ZDPOLDSH_PARALLEL_TASK');
    dbms_parallel_execute.create_chunks_by_number_col('DM2_G1ZDPOLDSH_PARALLEL_TASK',
                                                      'Jd1dta',
                                                      'DMIGTITDMGMBRINDP3',
                                                      'RECIDXMBINDP3',
                                                      i_chunksize);
    l_sql_stmt1 := 'BEGIN  Jd1dta.BQ9UT_MB01_DISHONOR(';
    l_sql_stmt2 := '''' || i_schedulename || '''' || ',' || '''' ||
                   v_schedulenumber || '''' || ',' || '''' || i_zprvaldyn || '''' || ',' || '''' ||
                   i_company || '''' || ',' || '''' || i_usrprf || '''' || ',' || '''' ||
                   i_branch || '''' || ',' || '''' || i_transcode || '''' || ',' || '''' ||
                   i_vrcmtermid || '''' || ',' || '''' || i_array_size || '''' || ',' || ':start_id' || ',' ||
                   ':end_id' || ');' || 'END;';

    l_sql_stmt_f := l_sql_stmt1 || l_sql_stmt2;
    dbms_output.put_line('Policy Dishonour Count Procedure call :' || l_sql_stmt_f);

    dbms_parallel_execute.run_task(task_name      => 'DM2_G1ZDPOLDSH_PARALLEL_TASK',
                                   sql_stmt       => l_sql_stmt_f,
                                   language_flag  => dbms_sql.native,
                                   parallel_level => i_degreeParallel); ---Keep this number low may be 2 or max 5.

    l_status := dbms_parallel_execute.task_status('DM2_G1ZDPOLDSH_PARALLEL_TASK');

    o_status := l_status;

    dbms_output.put_line('DM2_G1ZDPOLDSH_PARALLEL_TASK completed! Status:' ||
                         l_status);
   /* INSERT INTO Jd1dta.dmbmonpf
      (batch_name, start_time, end_time, job_num, datime, remarks)
    VALUES
      (i_schedulename,
       v_timestart,
       dbms_utility.get_time,
       v_schedulenumber,
       SYSDATE,
       i_remarks);*/


  END IF;
     dbms_output.put_line('End execution of DM2_G1ZDPOLDSH_PARALLEL_TASK');

exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'DM2_G1ZDPOLDSH_PARALLEL_TASK : ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      (i_scheduleName, v_schedulenumber, p_exitcode, p_exittext, sysdate);
       raise;
              commit;

END;
