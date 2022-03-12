create or replace PACKAGE   DM_data_trans_cmpc AS

  PROCEDURE dm_saleplan_camp_transform(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');

END DM_data_trans_cmpc;

/

create or replace PACKAGE BODY  DM_data_trans_cmpc IS

--- Start DM Campaign and Sale plan code ------

PROCEDURE dm_saleplan_camp_transform (
    p_array_size   IN   PLS_INTEGER DEFAULT 1000,
    p_delta        IN   CHAR DEFAULT 'N'
) AS

/* TYPE IG_ARRAY IS RECORD
(
ST_ZCMPCODE ZMRCP00.CPBCCD%TYPE,
ST_ZSALPLAN ZMRRP00.RPBVCD%TYPE,
ST_ENDORSER_CODE ZMRRP00.RPFOCD%TYPE
);
TYPE ST_DATA IS TABLE OF IG_ARRAY;*/

    v_app            stagedbusr2.titdmgzcslpf%rowtype;
    l_appno          VARCHAR2(20);
    ig_starttime     TIMESTAMP;
    ig_endtime       TIMESTAMP;
    v_errormsg       VARCHAR2(2000);
    temp_no          NUMBER;
    sql_stmt         VARCHAR2(100);
    row_count        NUMBER(10) DEFAULT 0;
    tmp_sql_stmt     VARCHAR2(100);
    tmp_row_count    NUMBER(10) DEFAULT 0;
    stg_starttime    TIMESTAMP;
    v_input_count    NUMBER(10) DEFAULT 0;
    v_ip_stmt        VARCHAR2(100);
    v_output_count   NUMBER(10) DEFAULT 0;
    v_op_stmt        VARCHAR2(100);
    g_err_flg        VARCHAR2(20);
    l_err_flg        NUMBER(10) DEFAULT 0;
    application_no   VARCHAR2(20);


/*   CURSOR cur_tempt IS
SELECT
    zmrcp00.cpbccd,
    zmrrp00.rpbvcd,
    ZMRRP00.RPFOCD
    FROM
    zmrcp00
    INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd )
                          AND ( zmrcp00.cpbdcd = zmrrp00.rpfocd );
                           SELECT zmrcp00.cpbccd,
    zmrrp00.rpbvcd
    FROM
    zmrcp00 INNER JOIN zmrrp00
        ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
             AND
            zmrcp00.cpbdcd = zmrrp00.rpfocd )
    group by
    zmrcp00.cpbccd,
    zmrrp00.rpbvcd;

TYPE IG_ARRAY IS TABLE OF cur_tempt%ROWTYPE;
ST_DATA IG_ARRAY; */
BEGIN
    dm_data_trans_gen.stg_starttime := systimestamp;
    v_errormsg := 'TEMP Table:';
--  v_output_count := 0;
--  v_input_count := 0;
    g_err_flg := 0;
    sql_stmt := 'select count(*) as row_count from STAGEDBUSR2.TITDMGZCSLPF';
    IF row_count > 0 THEN
        DELETE FROM stagedbusr2.titdmgzcslpf;

        COMMIT;
    END IF;
    tmp_sql_stmt := 'select count(*) as tmp_row_count from STAGEDBUSR2.TMP_TITDMGZCSLPF';
    IF tmp_row_count > 0 THEN
        DELETE FROM stagedbusr2.tmp_titdmgzcslpf;

        COMMIT;
    END IF;
--DELETE FROM TEMP1;commit;
    l_err_flg := 0;
    v_errormsg := 'DM_Saleplan_Camp_transform:';
    IF p_delta = 'Y' THEN
        v_errormsg := 'For Delta Load:';
        DELETE FROM stagedbusr2.titdmgzcslpf
        WHERE
            EXISTS (
                SELECT
                    'X'
                FROM
                    zmrcp00   dt,
                    zmrrp00   dt2,
                    SPPlanconvertion sp
                WHERE
                    dt.cpbecd = dt2.rpbtcd
                    AND dt.cpbdcd = dt2.rpfocd
                    and sp.oldzsalplan = dt2.rpbvcd
            );

        COMMIT;
     -- Delete the records for all the records exists in DM_Annualprem_transform for Delta Load
    END IF;

    v_errormsg := 'Before CUR_TEMPT Cursor:';

/*  OPEN cur_tempt;

LOOP
    FETCH cur_tempt BULK COLLECT INTO ST_DATA limit p_array_size;
    v_errormsg := 'Validate No.of Rows in cur_tempt Cursor:';
 /*   FORALL i IN 1..ST_DATA.count


        INSERT INTO tmp_titdmgsalepln2 (
             zcmpcode,
            zsalplan
        ) VALUES (
            st_data(i).CPBCCD,
            st_data(i).RPBVCD
        );

    EXIT WHEN cur_tempt%notfound;
  --  v_ip_stmt := 'SELECT COUNT(1) FROM ' || ST_DATA;

   -- dbms_output.get_line(v_input_count);
 -- EXECUTE IMMEDIATE v_ip_stmt INTO v_input_count;
END LOOP;
 v_input_count := cur_tempt%rowcount;
--  COMMIT;
CLOSE cur_tempt; */
  --  EXECUTE IMMEDIATE 'select count(*) from (SELECT count(*)
  --  FROM
 --   zmrcp00 INNER JOIN zmrrp00
  --      ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
 --            AND
 --           zmrcp00.cpbdcd = zmrrp00.rpfocd )
 --   group by
 --   zmrcp00.cpbccd,
  --  zmrrp00.rpbvcd) tmp'
  --  INTO v_input_count;

  -- Changed below to get the proper count of record counts from input

    EXECUTE IMMEDIATE 'select count(1) from (SELECT count(1)
            FROM
                zmrcp00
                INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                                        AND zmrcp00.cpbdcd = zmrrp00.rpfocd )
                JOIN spplanconvertion ON oldzsalplan = zmrrp00.rpbvcd
            GROUP BY
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd,
                spplanconvertion.newzsalplan) tmp'
    INTO v_input_count;

/*CURSOR A1 IS SELECT RECIDXSLPL2,ZCMPCODE,ZSALPLAN FROM TMP_TITDMGSALEPLN2;

A1REC A1%ROWTYPE;*/
    v_errormsg := 'A1 cur:';
    l_err_flg := 0;
-- v_input_count := 0;
-- v_output_count := 0;

--OPEN A1;
     --LOOP
    --FETCH A1 BULK COLLECT INTO A1REC LIMIT p_array_size;
   -- EXIT WHEN A1%NOTFOUND;
/*  FOR j IN (
    SELECT
        recidxslpl2,
        zcmpcode,
        zsalplan
    FROM
        tmp_titdmgsalepln2
    GROUP BY
        tmp_titdmgsalepln2.zcmpcode,
        tmp_titdmgsalepln2.zsalplan
) LOOP
    v_input_count := v_input_count + 1; */
    l_appno := 'test';
    v_errormsg := 'Stage Insert :';
    application_no := 'SALEPLAN';
/*    INSERT INTO titdmgsalepln2 (
         zcmpcode,
        zsalplan
    ) VALUES (
        j.zcmpcode,
        j.zsalplan
    ); */
    BEGIN
        INSERT /*+ PARALLEL */ INTO stagedbusr2.titdmgzcslpf (
            zcmpcode,
            old_zsalplan,
            zsalplan
        )
         /* OLD SALEPLAN CODE  SELECT
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd
            FROM
                zmrcp00
                INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                                        AND zmrcp00.cpbdcd = zmrrp00.rpfocd )
            GROUP BY
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd;
                */
                -- New Saleplan Code
                --JD : Change due to duplicate newsalesplan
                with camp_sal as(
select * from
( SELECT
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd,
                spplanconvertion.newzsalplan
            FROM
                zmrcp00
                INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                                        AND zmrcp00.cpbdcd = zmrrp00.rpfocd )
                JOIN spplanconvertion ON oldzsalplan = zmrrp00.rpbvcd
            GROUP BY
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd,
                spplanconvertion.newzsalplan))
                select CPBCCD, RPBVCD, NEWZSALPLAN from (select CPBCCD, RPBVCD, NEWZSALPLAN,  row_number() OVER(
        PARTITION BY CPBCCD, NEWZSALPLAN
        ORDER BY RPBVCD ASC
    ) row_num from camp_sal) where row_num=1 ;
    /*
            SELECT
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd,
                spplanconvertion.newzsalplan
            FROM
                zmrcp00
                INNER JOIN zmrrp00 ON ( zmrcp00.cpbecd = zmrrp00.rpbtcd
                                        AND zmrcp00.cpbdcd = zmrrp00.rpfocd )
                JOIN spplanconvertion ON oldzsalplan = zmrrp00.rpbvcd
            GROUP BY
                zmrcp00.cpbccd,
                zmrrp00.rpbvcd,
                spplanconvertion.newzsalplan;
   */
        EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM STAGEDBUSR2.TITDMGZCSLPF'
        INTO v_output_count;
    -- v_output_count := titdmgsalepln2%rowcount;
-- EXECUTE IMMEDIATE v_op_stmt INTO v_output_count;
   -- END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            DM_data_trans_gen.error_logs('TITDMGZCSLPF', application_no, v_errormsg);
            l_err_flg := 1;
            IF ( MOD(v_output_count, v_input_count) = 0 ) THEN
                COMMIT;
            END IF;
    END;

    IF l_err_flg <= 0 THEN
        v_errormsg := 'SUCCESS';
        temp_no := DM_data_trans_gen.control_log('ZMRCP00,ZMRRP00', 'TITDMGZCSLPF', systimestamp, application_no, v_errormsg,
        'S', v_input_count, v_output_count);

    ELSE
        v_errormsg := 'COMPLETED WITH ERROR';
        temp_no := DM_data_trans_gen.control_log('ZMRCP00,ZMRRP00', 'TITDMGZCSLPF', systimestamp, application_no, v_errormsg,
        'F', v_input_count, v_output_count);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        v_errormsg := v_errormsg
                      || '-'
                      || sqlerrm;
        temp_no := DM_data_trans_gen.control_log('ZMRRP00', 'TITDMGZCSLPF', systimestamp, application_no, v_errormsg,
        'F', v_input_count, v_output_count);

END dm_saleplan_camp_transform;

END DM_data_trans_cmpc;
/