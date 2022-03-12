create or replace PROCEDURE dm_persnl_clnt_flg (
    p_array_size   IN   PLS_INTEGER DEFAULT 1000,
    p_delta        IN   CHAR DEFAULT 'N'
) AS

   l_err_flg        NUMBER;
    g_err_flg        NUMBER;
    v_errormsg       VARCHAR2(2000) := ' ';
    v_input_count    NUMBER;
    v_output_count   NUMBER;
    temp_no          NUMBER;
    v_source         VARCHAR(500);
BEGIN
   l_err_flg := 0;
    g_err_flg := 0;
    v_input_count := 0;
    v_output_count := 0;
	dm_data_trans_gen.stg_starttime := systimestamp;
    SELECT
        COUNT(*)
    INTO v_input_count
    FROM
        zmrap00;

    v_source := 'ZMRAP00:' || v_input_count;
    v_errormsg := 'DM_persnl_clnt_flg:';
    BEGIN
        IF p_delta = 'Y' THEN
            DELETE FROM persnl_clnt_flg
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_zmrap00 dt
                    WHERE
                        dt.apcucd = apcucd
                );

            COMMIT;
        END IF;
        delete from persnl_clnt_flg;
         INSERT INTO persnl_clnt_flg
        (SELECT
                x.apcucd,
               'O' AS owner,
                substr(x.apcucd, 1, 8) AS refnum,
                NULL AS iscicd,
                NULL AS isa4st,
                0 AS clnt_ctgry,
                '00' AS insur_role,
                concat(substr(x.apcucd, 1, 8), '00') AS stg_clntnum,
                'OwnerQuery' as USRPRF,
                null as datime
            FROM
                zmrap00   X
            UNION ALL
            SELECT
                x.apcucd,
                'I' AS insur_typ,
                substr(x.apcucd, 1, 8) AS chdrnum,
                y.iscicd,
                y.isa4st,
                1 AS clnt_ctgry,
                CASE
                    WHEN z.iscucd IS NULL
                         AND substr(y.iscicd, - 2) <> '01' THEN
                        '03'
                    ELSE
                        decode(substr(y.iscicd, - 2), '01', '01', lpad(y.isa4st, 2, '0'))
                END AS insur_role,
                concat(substr(x.apcucd, 1, 8), decode(y.isa4st, 1, '00', substr(y.iscicd, - 2))) AS stg_clntnum,
                'INSQuery' as USRPRF,
                null as datime
            FROM
                zmrap00   x
                INNER JOIN zmris00   y ON x.apcucd = y.iscucd
                LEFT JOIN zmris00   z ON x.apcucd = z.iscucd
                                       AND z.isa4st = '1');
/*
        INSERT INTO persnl_clnt_flg
              ( SELECT
                x.apcucd,
                nvl2(z.iscucd, 'O', 'I') AS owner,
                substr(x.apcucd, 1, 8) AS refnum,
                NULL AS iscicd,
                NULL AS isa4st,
                0 AS clnt_ctgry,
                '00' AS insur_role,
                concat(substr(x.apcucd, 1, 8), '00') AS stg_clntnum,
                ' ' as USRPRF,
                null as datime
            FROM
                zmrap00   x
                LEFT JOIN zmris00   z ON x.apcucd = z.iscucd
                                       AND z.isa4st = '1'
            UNION ALL
            SELECT
                x.apcucd,
                nvl2(z.iscucd, 'O', 'I') AS insur_typ,
                substr(x.apcucd, 1, 8) AS chdrnum,
                y.iscicd,
                y.isa4st,
                1 AS clnt_ctgry,
                CASE
                    WHEN z.iscucd IS NULL
                         AND substr(y.iscicd, - 2) <> '01' THEN
                        '03'
                    ELSE
                        decode(substr(y.iscicd, - 2), '01', '01', lpad(y.isa4st, 2, '0'))
                END AS insur_role,
                concat(substr(x.apcucd, 1, 8), decode(y.isa4st, 1, '00', substr(y.iscicd, - 2))) AS stg_clntnum,
                ' ' as USRPRF,
                null as datime
            FROM
                zmrap00   x
                INNER JOIN zmris00   y ON x.apcucd = y.iscucd
                LEFT JOIN zmris00   z ON x.apcucd = z.iscucd
                                       AND z.isa4st = '1'
            );*/

        COMMIT;
        v_output_count := v_input_count;
    END;

 /*   dbms_stats.gather_table_stats(ownname => '"STAGEDBUSR2"', tabname => '"PERSNL_CLNT_FLG"', estimate_percent => dbms_stats.auto_sample_size
    ); */

    IF g_err_flg = 0 THEN
        v_errormsg := 'SUCCESS';
        temp_no := DM_data_trans_gen.control_log(v_source, 'PERSNL_CLNT_FLG', systimestamp, '0', v_errormsg,
                              'S', v_input_count, v_output_count);

    ELSE
        v_errormsg := 'COMPLETED WITH ERROR';
      --  temp_no := DM_data_trans_gen.control_log(v_source, 'PERSNL_CLNT_FLG', systimestamp, 'O', v_errormsg,
        --                      'F', v_input_count, v_output_count);

    END IF;  

EXCEPTION
    WHEN OTHERS THEN
        v_errormsg := v_errormsg
                      || ' '
                      || sqlerrm;
        DM_data_trans_gen.error_logs('PERSNL_CLNT_FLG', 0, substr(v_errormsg, 1, 200));
        l_err_flg := 1; 

END dm_persnl_clnt_flg;
/
