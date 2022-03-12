create or replace PACKAGE                          DM_data_trans_gen AS
  FUNCTION CONTROL_LOG(v_src_tabname IN VARCHAR2, v_target_tb IN VARCHAR2, v_endtime IN TIMESTAMP,v_applno IN VARCHAR2,l_errmsg IN VARCHAR2, l_st IN VARCHAR2,v_in_cnt IN NUMBER DEFAULT 0,v_out_cnt IN NUMBER DEFAULT 0) return number;
  PROCEDURE ERROR_LOGS(v_jobnm IN VARCHAR2,v_apnum IN VARCHAR2, v_msg IN VARCHAR2);
  FUNCTION IG_CONTROL_LOG(
      v_src_tabname IN VARCHAR2,
      v_target_tb   IN VARCHAR2,
      v_endtime     IN TIMESTAMP,
      v_applno      IN VARCHAR2,
      l_errmsg      IN VARCHAR2,
      l_st          IN VARCHAR2,
      v_in_cnt      IN NUMBER DEFAULT 0,
      v_out_cnt     IN NUMBER DEFAULT 0)
    RETURN NUMBER;
	ig_starttime     TIMESTAMP;
    stg_starttime    TIMESTAMP;
END DM_data_trans_gen;
/

create or replace PACKAGE BODY   DM_data_trans_gen IS

    v_cnt            NUMBER := 0;
    application_no   VARCHAR2(13);
    -- v_input_count    NUMBER;
    -- v_output_count   NUMBER;
    --ig_starttime     TIMESTAMP;
    --stg_starttime    TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;
    PROCEDURE error_logs (
        v_jobnm   IN   VARCHAR2,
        v_apnum   IN   VARCHAR2,
        v_msg     IN   VARCHAR2
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO error_log (
            jobname,
            last_appno,
            error_message,
            runtime
        ) VALUES (
            v_jobnm,
            v_apnum,
            v_msg,
            systimestamp
        );

        l_err_flg := 1;
        g_err_flg := 1;
        COMMIT;
    END;

    FUNCTION control_log (
        v_src_tabname   IN   VARCHAR2,
        v_target_tb     IN   VARCHAR2,
        v_endtime       IN   TIMESTAMP,
        v_applno        IN   VARCHAR2,
        l_errmsg        IN   VARCHAR2,
        l_st            IN   VARCHAR2,
        v_in_cnt        IN   NUMBER DEFAULT 0,
        v_out_cnt       IN   NUMBER DEFAULT 0
    ) RETURN NUMBER IS
    BEGIN
        v_cnt := 0;
        SELECT
            COUNT(1)
        INTO v_cnt
        FROM
            dm_transfm_cntl_table
        WHERE
            target_table = v_target_tb;

        IF v_cnt > 0 THEN
            UPDATE dm_transfm_cntl_table
            SET
                module_name = 'DM',
                source_table = v_src_tabname,
                target_table = v_target_tb,
                start_timestamp = to_date(TO_CHAR(stg_starttime, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), --start_timestamp = to_char(stg_starttime, 'YYYY-MM-DD HH24:MI:SS'),
                end_timestamp = to_date(TO_CHAR(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),---end_timestamp = to_char(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),
                input_cnt = v_in_cnt,
                output_cnt = v_out_cnt,
                last_processed_appno = v_applno,
                errormsg = l_errmsg,
                status = l_st,
                TOTAL_TIME =  to_number(to_char(v_endtime,'sssss') - to_char(stg_starttime,'sssss'))
            WHERE
                target_table = v_target_tb;

        ELSE
            INSERT INTO dm_transfm_cntl_table (
                module_name,
                source_table,
                target_table,
                start_timestamp,
                end_timestamp,
                input_cnt,
                output_cnt,
                last_processed_appno,
                errormsg,
                status,
                TOTAL_TIME
            ) VALUES (
                'DM',
                v_src_tabname,
                v_target_tb,
                to_date(TO_CHAR(stg_starttime, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),-- to_char(stg_starttime, 'YYYY-MM-DD HH24:MI:SS'),
                to_date(TO_CHAR(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),-- to_char(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),
                v_in_cnt,
                v_out_cnt,
                application_no,
                l_errmsg,
                l_st,
                to_number(to_char(v_endtime,'sssss') - to_char(stg_starttime,'sssss'))
            );

        END IF;

        COMMIT;
        RETURN 0;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('CONTROL_LOG:' || sqlerrm);
            RETURN 1;
    END control_log;

FUNCTION ig_control_log
    (
      v_src_tabname IN VARCHAR2,
      v_target_tb   IN VARCHAR2,
      v_endtime     IN TIMESTAMP,
      v_applno      IN VARCHAR2,
      l_errmsg      IN VARCHAR2,
      l_st          IN VARCHAR2,
      v_in_cnt      IN NUMBER DEFAULT 0,
      v_out_cnt     IN NUMBER DEFAULT 0
    )
    RETURN NUMBER
  IS
  BEGIN
    v_cnt := 0;
    SELECT COUNT(1)
    INTO v_cnt
    FROM ig_copy_cntl_table
    WHERE target_table = v_target_tb;
    IF v_cnt           > 0 THEN
      UPDATE ig_copy_cntl_table
      SET job_detail         = 'STAGE4 - COPYING DATA TO IG TABLE',
        source_table         = v_src_tabname,
        target_table         = v_target_tb,
        start_timestamp      =  to_date(TO_CHAR(ig_starttime, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),
        end_timestamp        =  to_date(TO_CHAR(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),
        input_cnt            = v_in_cnt,
        output_cnt           = v_out_cnt,
        last_processed_appno = v_applno,
        error_msg            = l_errmsg,
        status               = l_st,
         TOTAL_TIME =  to_number(to_char(v_endtime,'sssss') - to_char(ig_starttime,'sssss')) 
      WHERE target_table     = v_target_tb;
    ELSE
      INSERT
      INTO ig_copy_cntl_table
        (
          job_detail,
          source_table,
          target_table,
          start_timestamp,
          end_timestamp,
          input_cnt,
          output_cnt,
          last_processed_appno,
          error_msg,
          status,
          TOTAL_TIME
        )
        VALUES
        (
          'STAGE4 - COPYING DATA TO IG TABLE',
          v_src_tabname,
          v_target_tb,
          to_date(TO_CHAR(ig_starttime, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),
          to_date(TO_CHAR(v_endtime, 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'),
          v_in_cnt,
          v_out_cnt,
          v_applno,
          l_errmsg,
          l_st,
          to_number(to_char(v_endtime,'sssss') - to_char(ig_starttime,'sssss')) 
        );
    END IF;
    COMMIT;
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('IG_CONTROL_LOG:' || sqlerrm);
    RETURN 1;
  END ig_control_log;

END DM_data_trans_gen;
/