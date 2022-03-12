CREATE OR REPLACE PROCEDURE DM2_MIGRATION_EXECUTION(i_schedulename   IN VARCHAR2,
                                                      i_schedulenumber in varchar2,
                                                      i_zprvaldyn      IN VARCHAR2,
                                                      i_remarks        IN VARCHAR2)
    AUTHID current_user AS
    obj_dmargs Jd1dta.DMBARGSPF%rowtype;
  
    V_STATUS    NUMBER := 7;
    v_timestart NUMBER := dbms_utility.get_time;
    p_exitcode  number;
    p_exittext  varchar2(500);
  BEGIN
    p_exitcode := 0;
    p_exittext := NULL;
    select *
      into obj_dmargs
      from Jd1dta.DMBARGSPF
     where trim(SCHEDULE_NAME) = trim(i_schedulename);
  
    INSERT INTO Jd1dta.dmbmonpf
      (BATCH_NAME,
       JOB_NUM,
       ZPRVALDYN,
       START_TIME,
       SCHD_STATUS,
       USRPRF,
       DATIME,
       REMARKS)
    VALUES
      (obj_dmargs.schedule_name,
       i_schedulenumber,
       i_zprvaldyn,
       v_timestart,
       '10',
       obj_dmargs.usrprf,
       SYSDATE,
       i_remarks);
    CASE (i_schedulename)
    
      WHEN 'G1ZDAGENCY' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);
      
        DM2_G1ZDAGENCY_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
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
                                    i_chunksize      => obj_dmargs.chunk_size,
                                    i_degreeparallel => obj_dmargs.degree_parallel,
                                    o_status         => V_STATUS);

        dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);
      
     WHEN 'G1ZDPERCLT' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);
      
        DM2_G1ZDPERCLT_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
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
    WHEN 'G1ZDPCLHIS' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);
      
        DM2_G1ZDPCLNHIS_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
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
							 
		 WHEN 'G1ZDCLTBNK' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);

        DM2_G1ZDCLTBNK_PARALLEL_EXE(i_schedulename   => obj_dmargs.schedule_name,
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
      WHEN 'G1ZDCAMPCD' THEN
        dbms_output.put_line('Start execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);
      
        Jd1dta.BQ9S8_CM01_CAMPCD(i_schedulename   => obj_dmargs.schedule_name,
                                 i_schedulenumber => i_schedulenumber,
                                 i_zprvaldyn      => i_zprvaldyn,
                                 i_company        => obj_dmargs.company,
                                 i_usrprf         => obj_dmargs.usrprf,
                                 i_branch         => obj_dmargs.branch,
                                 i_transcode      => obj_dmargs.transcode,
                                 i_vrcmtermid     => obj_dmargs.vrcmtermid);
        dbms_output.put_line('End execution of DM2_MIGRATION_EXECUTION : ' ||
                             i_schedulename);
               
               
      
      ELSE
        dbms_output.put_line('Please correct the module name or refer the DMBARGSPF table');
    END CASE;
    --Update batch status
    if (V_STATUS = 7) then
      Update Jd1dta.dmbmonpf
         set SCHD_STATUS = '90', END_TIME = dbms_utility.get_time
       where BATCH_NAME = obj_dmargs.schedule_name
         and JOB_NUM = i_schedulenumber;
    else
    
      Update Jd1dta.dmbmonpf
         set SCHD_STATUS = '10', END_TIME = dbms_utility.get_time
       where BATCH_NAME = obj_dmargs.schedule_name
         and JOB_NUM = i_schedulenumber;
    end if;
    COMMIT;
  
  exception
    WHEN OTHERS THEN
      ROLLBACK;
      p_exitcode := SQLCODE;
      p_exittext := 'DM2_MIGRATION_EXECUTION : ' ||i_scheduleName || ' ' ||
                    DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
    
      insert into Jd1dta.dmberpf
        (schedule_name, JOB_NUM, error_code, error_text, DATIME)
      values
        (i_scheduleName, i_schedulenumber, p_exitcode, p_exittext, sysdate);
    
      commit;
  END DM2_MIGRATION_EXECUTION;
  
