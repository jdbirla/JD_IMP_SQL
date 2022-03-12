--------------------------------------------------------
--  File created - Wednesday-July-07-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure DM2_MIGRATION_EXECUTION
--------------------------------------------------------
set define off;

   CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."DM2_MIGRATION_EXECUTION" (i_schedulename   IN VARCHAR2,
                                                    i_schedulenumber in varchar2,
                                                    i_zprvaldyn      IN VARCHAR2,
                                                    i_remarks        IN VARCHAR2)
  AUTHID current_user AS
  obj_dmargs Jd1dta.DMBARGSPF%rowtype;

  V_STATUS    NUMBER := 7;
  v_timestart NUMBER := dbms_utility.get_time;
  p_exitcode  number;
  p_exittext  varchar2(2000);
  v_dataCount NUMBER;
   task_failed exception;


BEGIN
  p_exitcode := 0;
  p_exittext := NULL;
  select *
    into obj_dmargs
    from Jd1dta.DMBARGSPF
   where trim(SCHEDULE_NAME) = trim(i_schedulename);

  SELECT COUNT(1)
    into v_dataCount
    FROM Jd1dta.dmbmonpf
   where BATCH_NAME = obj_dmargs.schedule_name
     and JOB_NUM = i_schedulenumber;

  IF (v_dataCount > 0) THEN
    Delete FROM Jd1dta.dmbmonpf
     where BATCH_NAME = obj_dmargs.schedule_name
       and JOB_NUM = i_schedulenumber;

  end if;

  INSERT INTO Jd1dta.dmbmonpf
    (BATCH_NAME,
     JOB_NUM,
     ZPRVALDYN,
     START_TIME,
     SCHD_STATUS,
     USRPRF,
     DATIME,
     REMARKS,
     START_TIMESTAMP)
  VALUES
    (obj_dmargs.schedule_name,
     i_schedulenumber,
     i_zprvaldyn,
     v_timestart,
     '10',
     obj_dmargs.usrprf,
     SYSDATE,
     i_remarks,
    to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'));

  Insert into dm_mail_alert (BATCH_NAME) values(obj_dmargs.schedule_name);

  CASE (i_schedulename)


  WHEN 'G1ZDCOPCLT' THEN
            dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                                 i_schedulename);

            Jd1dta.BQ9Q7_CL01_CORPCLT(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid);
            dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                                 i_schedulename);

    WHEN 'G1ZDAGENCY' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      Jd1dta.DM2_G1ZDAGENCY_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                         i_remarks        => i_remarks,
                                         i_chunksize      => obj_dmargs.chunk_size,
                                         i_degreeparallel => obj_dmargs.degree_parallel,
                                         o_status         => V_STATUS);

      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      WHEN 'G1ZDNAYCLT' THEN
          dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                               i_schedulename);

          DM2_G1ZDNAYCLT_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                      i_schedulenumber => i_schedulenumber,
                                      i_zprvaldyn      => i_zprvaldyn,
                                      i_company        => obj_dmargs.company,
                                      i_usrprf         => obj_dmargs.usrprf,
                                      i_branch         => obj_dmargs.branch,
                                      i_transcode      => obj_dmargs.transcode,
                                      i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                      i_remarks        => i_remarks,
                                       i_array_size     => obj_dmargs.array_size,
                                      i_chunksize      => obj_dmargs.chunk_size,
                                      i_degreeparallel => obj_dmargs.degree_parallel,
                                      o_status         => V_STATUS);

          dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

    WHEN 'G1ZDPERCLT' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      Jd1dta.DM2_G1ZDPERCLT_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                         i_remarks        => i_remarks,
										  i_array_size     => obj_dmargs.array_size,
                                         i_chunksize      => obj_dmargs.chunk_size,
                                         i_degreeparallel => obj_dmargs.degree_parallel,
                                         o_status         => V_STATUS);

      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);
    WHEN 'G1ZDPCLHIS' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      Jd1dta.DM2_G1ZDPCLNHIS_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                          i_schedulenumber => i_schedulenumber,
                                          i_zprvaldyn      => i_zprvaldyn,
                                          i_company        => obj_dmargs.company,
                                          i_usrprf         => obj_dmargs.usrprf,
                                          i_branch         => obj_dmargs.branch,
                                          i_transcode      => obj_dmargs.transcode,
                                          i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                          i_remarks        => i_remarks,
										   i_array_size     => obj_dmargs.array_size,
                                          i_chunksize      => obj_dmargs.chunk_size,
                                          i_degreeparallel => obj_dmargs.degree_parallel,
                                          o_status         => V_STATUS);

      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

    WHEN 'G1ZDCLTBNK' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      Jd1dta.DM2_G1ZDCLTBNK_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                         i_remarks        => i_remarks,
                                          i_array_size     => obj_dmargs.array_size,
                                         i_chunksize      => obj_dmargs.chunk_size,
                                         i_degreeparallel => obj_dmargs.degree_parallel,
                                         o_status         => V_STATUS);


      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);
    WHEN 'G1ZDCAMPCD' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);


       Jd1dta.DM2_G1ZDCAMPCD_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                         i_array_size     => obj_dmargs.array_size,
                                         i_remarks        => i_remarks,
                                         i_chunksize      => obj_dmargs.chunk_size,
                                         i_degreeparallel => obj_dmargs.degree_parallel,
                                         o_status         => V_STATUS);
      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);



    WHEN 'G1ZDMBRIND' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      Jd1dta.DM2_G1ZDMBRIND_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_fsucocompany   => obj_dmargs.fsucocompany,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                         i_user_t         => obj_dmargs.user_t,
                                         i_array_size     => obj_dmargs.array_size,
                                         i_remarks        => i_remarks,
                                         i_chunksize      => obj_dmargs.chunk_size,
                                         i_degreeparallel => obj_dmargs.degree_parallel,
                                         o_status         => V_STATUS);

      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

	 WHEN 'G1ZDMSTPOL' THEN

	  dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

  Jd1dta.BQ9EC_MP01_MSTRPL(i_schedulename   => obj_dmargs.schedule_name,
                                     i_schedulenumber => i_schedulenumber,
                                     i_zprvaldyn      => i_zprvaldyn,
                                     i_company        => obj_dmargs.company,
                                     i_usrprf         => obj_dmargs.usrprf,
                                     i_branch         => obj_dmargs.branch,
                                     i_transcode      => obj_dmargs.transcode,
                                     i_vrcmtermid     => obj_dmargs.vrcmtermid);
        dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);
 WHEN 'G1ZDLETR' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      Jd1dta.DM2_G1ZDLETR_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid,
										 i_array_size     => obj_dmargs.array_size,
                                         i_remarks        => i_remarks,
                                         i_chunksize      => obj_dmargs.chunk_size,
                                         i_degreeparallel => obj_dmargs.degree_parallel,
                                         o_status         => V_STATUS);

      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);	
WHEN 'G1ZDCOLRES' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);



        Jd1dta.DM2_G1ZDCOLRES_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                    i_schedulenumber => i_schedulenumber,
                                    i_zprvaldyn      => i_zprvaldyn,
                                    i_company        => obj_dmargs.company,
                                    i_usrprf         => obj_dmargs.usrprf,
                                    i_branch         => obj_dmargs.branch,
                                    i_transcode      => obj_dmargs.transcode,
                                    i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                    i_array_size     => obj_dmargs.array_size,
                                    i_remarks        => i_remarks,
                                    i_chunksize      => obj_dmargs.chunk_size,
                                    i_degreeparallel => obj_dmargs.degree_parallel,
                                    o_status         => V_STATUS);


		WHEN 'G1ZDPOLDSH' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

        Jd1dta.DM2_G1ZDPOLDSH_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                    i_schedulenumber => i_schedulenumber,
                                    i_zprvaldyn      => i_zprvaldyn,
                                    i_company        => obj_dmargs.company,
                                    i_usrprf         => obj_dmargs.usrprf,
                                    i_branch         => obj_dmargs.branch,
                                    i_transcode      => obj_dmargs.transcode,
                                    i_vrcmtermid     => obj_dmargs.vrcmtermid,
				    i_array_size     => obj_dmargs.array_size,
                                    i_remarks        => i_remarks,
                                    i_chunksize      => obj_dmargs.chunk_size,
                                    i_degreeparallel => obj_dmargs.degree_parallel,
                                    o_status         => V_STATUS);

        dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);


	WHEN 'G1ZDBILLRF' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      Jd1dta.DM2_G1ZDBILLRF_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtime		  => to_number(to_char(sysdate,'HH24miss')),
                                         i_vrcmuser 	  => obj_dmargs.VRCMUSER,
                                         i_acctYear       => obj_dmargs.ACCTYEAR,
                                         i_acctMonth      => obj_dmargs.ACCTMONTH,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid,
										 i_array_size     => obj_dmargs.array_size,
                                         i_remarks        => i_remarks, 
                                         i_chunksize      => obj_dmargs.chunk_size,
                                         i_degreeparallel => obj_dmargs.degree_parallel, 
                                         o_status         => V_STATUS); 

      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' || i_schedulename);

    WHEN 'G1ZDBILLIN' THEN
      dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      Jd1dta.DM2_G1ZDBILLIN_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                         i_schedulenumber => i_schedulenumber,
                                         i_zprvaldyn      => i_zprvaldyn,
                                         i_company        => obj_dmargs.company,
                                         i_usrprf         => obj_dmargs.usrprf,
                                         i_branch         => obj_dmargs.branch,
                                         i_transcode      => obj_dmargs.transcode,
                                         i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                         i_user_t         => obj_dmargs.user_t,
                                         i_acctYear       => obj_dmargs.acctYear,
                                         i_acctMonth      => obj_dmargs.acctMonth,
                                         i_array_size     => obj_dmargs.array_size,
                                         i_remarks        => i_remarks,
                                         i_chunksize      => obj_dmargs.chunk_size,
                                         i_degreeparallel => obj_dmargs.degree_parallel,
                                         o_status         => V_STATUS);

      dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                           i_schedulename);

      WHEN 'G1ZDPOLHST' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

        Jd1dta.DM2_G1ZDPOLHST_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                    i_schedulenumber => i_schedulenumber,
                                    i_zprvaldyn      => i_zprvaldyn,
                                    i_company        => obj_dmargs.company,
                                    i_usrprf         => obj_dmargs.usrprf,
                                    i_branch         => obj_dmargs.branch,
                                    i_transcode      => obj_dmargs.transcode,
                                    i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                    i_array_size     => obj_dmargs.array_size,
                                    i_remarks        => i_remarks,
                                    i_chunksize      => obj_dmargs.chunk_size,
                                    i_degreeparallel => obj_dmargs.degree_parallel,
                                    o_status         => V_STATUS);
        dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

      WHEN 'G1ZDPOLCOV' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

        Jd1dta.DM2_G1ZDPOLCOV_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                    i_schedulenumber => i_schedulenumber,
                                    i_zprvaldyn      => i_zprvaldyn,
                                    i_company        => obj_dmargs.company,
                                    i_usrprf         => obj_dmargs.usrprf,
                                    i_branch         => obj_dmargs.branch,
                                    i_transcode      => obj_dmargs.transcode,
                                    i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                    i_array_size     => obj_dmargs.array_size,
                                    i_remarks        => i_remarks,
                                    i_chunksize      => obj_dmargs.chunk_size,
                                    i_degreeparallel => obj_dmargs.degree_parallel,
                                    o_status         => V_STATUS);

        dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);


      WHEN 'G1ZDAPIRNO' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

        Jd1dta.DM2_G1ZDAPIRNO_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
                                    i_schedulenumber => i_schedulenumber,
                                    i_zprvaldyn      => i_zprvaldyn,
                                    i_company        => obj_dmargs.company,
                                    i_usrprf         => obj_dmargs.usrprf,
                                    i_branch         => obj_dmargs.branch,
                                    i_transcode      => obj_dmargs.transcode,
                                    i_vrcmtermid     => obj_dmargs.vrcmtermid,
                                    i_array_size     => obj_dmargs.array_size,
                                    i_remarks        => i_remarks,
                                    i_chunksize      => obj_dmargs.chunk_size,
                                    i_degreeparallel => obj_dmargs.degree_parallel,
                                    o_status         => V_STATUS);

        dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);	
                             
          WHEN 'G1ZDRNWDTM' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);                   
                             
    

                              Jd1dta.BQ9UY_RD01_RWRD(
                                I_SCHEDULENAME => obj_dmargs.schedule_name,
                                I_SCHEDULENUMBER => i_schedulenumber,
                                I_ZPRVALDYN => i_zprvaldyn,
                                I_COMPANY => obj_dmargs.company,
                                I_USRPRF => obj_dmargs.usrprf,
                                I_BRANCH => obj_dmargs.branch,
                                I_TRANSCODE => obj_dmargs.transcode,
                                I_VRCMTERMID => obj_dmargs.vrcmtermid
                              );

 dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

    ELSE
      dbms_output.put_line('Please correct the module name or refer the DMBARGSPF table');
  END CASE;
  --Update batch status
  if (V_STATUS = 7) then
    Update Jd1dta.dmbmonpf
       set SCHD_STATUS = '90', END_TIME = dbms_utility.get_time,END_TIMESTAMP= to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')
     where BATCH_NAME = obj_dmargs.schedule_name
       and JOB_NUM = i_schedulenumber;
  else
   ROLLBACK;
    Update Jd1dta.dmbmonpf
       set SCHD_STATUS = '01', END_TIME = dbms_utility.get_time,END_TIMESTAMP=  to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')
     where BATCH_NAME = obj_dmargs.schedule_name
       and JOB_NUM = i_schedulenumber;
       commit;
       RAISE  task_failed;
  end if;
  COMMIT;

exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'DM2_MIGRATION_EXECUTION : ' || i_scheduleName || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      (i_scheduleName, i_schedulenumber, p_exitcode, p_exittext, sysdate);

    commit;
     raise;
END DM2_MIGRATION_EXECUTION;

/
