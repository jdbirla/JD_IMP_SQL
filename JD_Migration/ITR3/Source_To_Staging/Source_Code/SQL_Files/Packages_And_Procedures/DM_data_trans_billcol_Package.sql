create or replace PACKAGE  DM_data_trans_billcol
 AS

  PROCEDURE DM_Billing_collectres(p_array_size IN PLS_INTEGER DEFAULT 1000,  p_delta IN CHAR DEFAULT 'N');


END DM_data_trans_billcol;

/

create or replace PACKAGE BODY DM_data_trans_billcol as


    application_no   VARCHAR2(13);
    v_input_count    NUMBER;
    v_output_count   NUMBER;
    stg_starttime    TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;
    
-- Procedure for DM DM_Billing_collectres <STARTS> Here

    PROCEDURE dm_billing_collectres (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS

        l_cnt_chk          NUMBER(2);
        v_zledest          NUMBER(1);
        v_output_count     NUMBER := 0;
        v_inpcountf        NUMBER := 0;
        v_count            NUMBER := 0;
        v_igcode           CHAR(5);
        v_lhcqcd           VARCHAR(4);
        v_lhcucd           VARCHAR2(11);
        v_cnt              NUMBER(7) := 0;
        vard               VARCHAR2(13);
        stg_endtime        TIMESTAMP;
        TYPE ig_array IS
            TABLE OF titdmgcolres%rowtype;
        st_data            ig_array;
        v_app              titdmgcolres%rowtype;
        l_appno            VARCHAR2(20);
        ig_starttime       TIMESTAMP;
        ig_endtime         TIMESTAMP;
        v_errormsg         VARCHAR2(2000);
        v_input_count      NUMBER := 0;
        temp_no            NUMBER;
        custom_exp EXCEPTION;
        CURSOR cur_titdmgcolres IS
        SELECT
            pj_titdmgcolres.chdrnum,
            pj_titdmgcolres.trrefnum,
            pj_titdmgcolres.tfrdate,
            pj_titdmgcolres.pshcde,
            pj_titdmgcolres.facthous,
            pj_titdmgcolres.prbilfdt,
            (
                SELECT
                    dsh_code_ref.ig_dshcde
                FROM
                    dsh_code_ref
                WHERE
                    dsh_code_ref.pj_dshcde = pj_titdmgcolres.pshcde
                    AND dsh_code_ref.pj_facthous = pj_titdmgcolres.facthous
            ) ig_dshcde
        FROM
            pj_titdmgcolres
        WHERE
            NOT EXISTS (
                SELECT
                    'X'
                FROM
                    titdmgcolres
                WHERE
                    titdmgcolres.chdrnum = pj_titdmgcolres.chdrnum
                    AND titdmgcolres.trrefnum = pj_titdmgcolres.trrefnum
                    AND titdmgcolres.prbilfdt = pj_titdmgcolres.prbilfdt
            )
        ORDER BY
            chdrnum;

        rec_titdmgcolres   cur_titdmgcolres%rowtype;
    BEGIN
        v_input_count := 0;
        v_output_count := 0;
        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
        v_errormsg := 'DM_Billing_collectres:';
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            DELETE FROM titdmgcolres
            WHERE
                EXISTS (
                    SELECT
                        'X'
                    FROM
                        tmp_pj_titdmgcolres dt
                    WHERE
                        dt.chdrnum = titdmgcolres.chdrnum
                );

            COMMIT;
         -- Delete the records for all the records exists in PJ_TITDMGCOLRES for Delta Load
        END IF;

        v_errormsg := 'Master cursor:';
        OPEN cur_titdmgcolres;
        LOOP
            FETCH cur_titdmgcolres INTO rec_titdmgcolres;
            EXIT WHEN cur_titdmgcolres%notfound;
            l_appno := rec_titdmgcolres.chdrnum;
            v_input_count := v_input_count + 1;
            BEGIN
                IF rec_titdmgcolres.ig_dshcde IS NOT NULL THEN
                    v_errormsg := 'Insert CALL:';
                    INSERT INTO titdmgcolres (
                        chdrnum,
                        trrefnum,
                        tfrdate,
                        dshcde,
                        prbilfdt
                    ) VALUES (
                        rec_titdmgcolres.chdrnum,
                        rec_titdmgcolres.trrefnum,
                        rec_titdmgcolres.tfrdate,
                        rec_titdmgcolres.ig_dshcde,
                        rec_titdmgcolres.prbilfdt
                    );

                    v_output_count := v_output_count + 1;
                ELSE
                    v_errormsg := 'No IG code mapping for:' || rec_titdmgcolres.pshcde;
                    DM_data_trans_gen.error_logs('TITDMGCOLRES', rec_titdmgcolres.chdrnum, v_errormsg);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    v_errormsg := 'CODE NOT CONFIRMED / NOT AVAILABLE';
                    DM_data_trans_gen.error_logs('TITDMGCOLRES', l_appno, v_errormsg);
            END;

            IF l_err_flg = 1 THEN
                        --ROLLBACK;
                l_err_flg := 0;
            END IF;
            COMMIT;
        END LOOP;

        CLOSE cur_titdmgcolres;
        COMMIT;
        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := DM_data_trans_gen.control_log('PJ_TITDMGCOLRES', 'TITDMGCOLRES', systimestamp, l_appno, v_errormsg,
            'S', v_input_count, v_output_count);

        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.control_log('PJ_TITDMGCOLRES', 'TITDMGCOLRES', systimestamp, l_appno, v_errormsg,
            'F', v_input_count, v_output_count);

        END IF;

    EXCEPTION
        WHEN custom_exp THEN
            dbms_output.put_line('ALL DATA / NO DATA RETRIEVED FROM THE TABLE');
            v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            temp_no := DM_data_trans_gen.control_log('PJ_TITDMGCOLRES', 'TITDMGCOLRES', systimestamp, NULL, v_errormsg,
            'F', v_input_count, v_output_count);

    END dm_billing_collectres;

end DM_data_trans_billcol;

/
