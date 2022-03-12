create or replace PACKAGE  DM_data_trans_billhis
AS
/***************************************************************************************************
  * Date    Initials   Tag   Description
  * -----   --------   ---   ---------------------------------------------------------------------------
  * JAN27	CHO              dm_billing_transform -
							 Change from joining with titdmgmbrindp1 to policy_statcode for PA ITR3
  * FEB18	CHO              dm_billing_transform - Remove TRIM keyword to shorten execution time
  *****************************************************************************************************/

  PROCEDURE DM_billing_transform(p_array_size IN PLS_INTEGER DEFAULT 1000, p_delta IN CHAR DEFAULT 'N');


END DM_data_trans_billhis;

/

create or replace PACKAGE BODY dm_data_trans_billhis AS

-- Procedure for DM DM_billing_transform <STARTS> Here

    PROCEDURE dm_billing_transform (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) AS

        temp_no             NUMBER;
        v_errormsg          VARCHAR2(2000) := ' ';
        v_sql_comb          VARCHAR2(500) := ' ';
        v_sql_comb_bill     VARCHAR2(500) := ' ';
        v_sql_comb_i        VARCHAR2(500) := ' ';
        v_sql_comb_bill_i   VARCHAR2(500) := ' ';
        application_no      VARCHAR2(13);
    BEGIN
        dm_data_trans_gen.stg_starttime := systimestamp;
        -------titdmgbill_comb:start-----------
        --EXECUTE IMMEDIATE 'drop table titdmgbill_comb';
 /*       v_sql_comb := 'Create table titdmgbill_comb as 
                           select *
                   from titdmgbill1 a
                   where exists  (select chdrnum from titdmgbill1 b where  a.chdrnum = b.chdrnum
                            and a.TFRDATE = b.TFRDATE
                           group by  chdrnum,TFRDATE having count(1) > 1)'
        ;

					   execute immediate v_sql_comb;
        v_sql_comb_i := 'create INDEX titdmgbill_comb_I1 on titdmgbill_comb(chdrnum)';
        EXECUTE IMMEDIATE v_sql_comb_i;
                -------titdmgbill_comb:end-----------
        -------titdmgbill_com_bill:start-----------

        --EXECUTE IMMEDIATE 'drop table titdmgbill_com_bill';
        v_sql_comb_bill := 'create table titdmgbill_com_bill as
select * from (
select 
RECIDXBILL1, TRREFNUM, CHDRNUM, PRBILFDT, PRBILTDT, PREMOUT, ZCOLFLAG, ZACMCLDT, ZPOSBDSM, ZPOSBDSY, ENDSERCD, TFRDATE, POSTING, NRFLAG, ZPDATATXFLG, TRANNO,row_number() OVER(
        PARTITION BY CHDRNUM
        ORDER BY PRBILFDT DESC
    ) row_num     
     from (select *
                   from titdmgbill1 a
                   where exists  (select chdrnum from titdmgbill1 b where  a.chdrnum = b.chdrnum
                            and a.TFRDATE = b.TFRDATE
                           group by  chdrnum,TFRDATE having count(1) > 1)) ) where row_num=1'
        ;
        EXECUTE IMMEDIATE v_sql_comb_bill;
        v_sql_comb_bill_i := 'create INDEX titdmgbill_com_bill_I1 on titdmgbill_com_bill(chdrnum)';
        EXECUTE IMMEDIATE v_sql_comb_bill_i; */
                -------titdmgbill_com_bill:start-----------
----#ZJNPG-9739 Insert : start---

delete from titdmgbill_comb;
delete from titdmgbill_com_bill;

insert /*+APPEND*/ into  titdmgbill_comb  
SELECT
    *
FROM
    titdmgbill1 a
WHERE
    EXISTS (
        SELECT
            chdrnum
        FROM
            titdmgbill1 b
        WHERE
            a.chdrnum = b.chdrnum
            AND a.tfrdate = b.tfrdate
        GROUP BY
            chdrnum,
            tfrdate
        HAVING
            COUNT(1) > 1
    );
COMMIT;

insert /*+APPEND*/ into titdmgbill_com_bill 
SELECT
    *
FROM
    (
        SELECT
            recidxbill1,
            trrefnum,
            chdrnum,
            prbilfdt,
            prbiltdt,
            premout,
            zcolflag,
            zacmcldt,
            zposbdsm,
            zposbdsy,
            endsercd,
            tfrdate,
            posting,
            nrflag,
            zpdatatxflg,
            tranno,
            ROW_NUMBER() OVER(
                PARTITION BY chdrnum,TFRDATE
                ORDER BY
                    prbilfdt DESC
            ) row_num
        FROM
            (
                SELECT
                    *
                FROM
                    titdmgbill1 a
                WHERE
                    EXISTS (
                        SELECT
                            chdrnum
                        FROM
                            titdmgbill1 b
                        WHERE
                            a.chdrnum = b.chdrnum
                            AND a.tfrdate = b.tfrdate
                        GROUP BY
                            chdrnum,
                            tfrdate
                        HAVING
                            COUNT(1) > 1
                    )
            )
    )
WHERE
    row_num = 1;
COMMIT;
----#ZJNPG-9739 Insert : END---

----merge for normal bills : start---
MERGE INTO stagedbusr2.titdmgbill1 tab1
USING (
          SELECT
              a.chdrnum,
              a.recidxbill1,
              d.zposbdsm,
              d.zposbdsy
          FROM
              stagedbusr2.titdmgbill1   a
              INNER JOIN policy_statcode           b ON a.chdrnum = b.chdrnum
              INNER JOIN stagedbusr.zendrpf        c ON rtrim(b.zendcde) = rtrim(c.zendcde)
              INNER JOIN stagedbusr.zesdpf         d ON c.zendscid = d.zendscid
                                                AND a.prbilfdt = d.zcovcmdt )
tab2 ON ( tab1.chdrnum = tab2.chdrnum
                   and tab1.recidxbill1 = tab2.recidxbill1 )
WHEN MATCHED THEN UPDATE
SET tab1.zposbdsm = tab2.zposbdsm,
    tab1.zposbdsy = tab2.zposbdsy;

----merge for normal bills : end---
 COMMIT;
----merge for comb bill : start---

       MERGE INTO stagedbusr2.titdmgbill1 tab1
        USING (
                  SELECT
                      jd.chdrnum,
                      jd.recidxbill1,
                      a.zposbdsm,
                      a.zposbdsy,
                      a.prbilfdt,
                      a.prbiltdt
                  FROM
                      titdmgbill_comb jd
                      LEFT OUTER JOIN (
                          SELECT
                              a.chdrnum,
                              a.recidxbill1,
                              d.zposbdsm,
                              d.zposbdsy,
                              a.prbilfdt,
                              a.prbiltdt,
                              a.tfrdate
                          FROM
                              stagedbusr2.titdmgbill_com_bill   a
                              INNER JOIN policy_statcode                   b ON a.chdrnum = b.chdrnum
                              INNER JOIN stagedbusr.zendrpf                c ON rtrim(b.zendcde) = rtrim(c.zendcde)
                              INNER JOIN stagedbusr.zesdpf                 d ON c.zendscid = d.zendscid
                                                                AND a.prbilfdt = d.zcovcmdt
                      ) a ON jd.chdrnum = a.chdrnum and jd.tfrdate = a.tfrdate
              )
        tab2 ON ( tab1.chdrnum = tab2.chdrnum
                  AND tab1.recidxbill1 = tab2.recidxbill1 )
        WHEN MATCHED THEN UPDATE
        SET tab1.zposbdsm = tab2.zposbdsm,
            tab1.zposbdsy = tab2.zposbdsy;
----merge for comb bill : start---

        COMMIT;
        UPDATE stagedbusr2.titdmgbill1 a
        SET
            zacmcldt = (
                SELECT
                    b.zacmcldt
                FROM
                    stagedbusr.zesdpf    b,
                    stagedbusr.zendrpf   c,
                    policy_statcode      d
                WHERE
                    b.zendscid = c.zendscid
                    AND c.zendcde = d.zendcde
                    AND b.zposbdsy = a.zposbdsy
                    AND b.zposbdsm = a.zposbdsm
                    AND d.chdrnum = a.chdrnum
            );

        COMMIT;
        v_errormsg := 'SUCCESS';
        application_no := NULL;
        temp_no := dm_data_trans_gen.control_log('DM_data_trans_billhis.dm_billing_transform', 'TITDMGBILL1', systimestamp, application_no
        , v_errormsg, 'S', NULL, NULL);

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            dbms_output.put_line('Error: ' || sqlerrm);
            dm_data_trans_gen.error_logs('TITDMGBILL1', 'zacmcldt', sqlerrm);
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := dm_data_trans_gen.control_log('DM_data_trans_billhis.dm_billing_transform', 'TITDMGBILL1', systimestamp, application_no
            , v_errormsg, 'F', NULL, NULL);

    END dm_billing_transform;
-- Procedure for DM DM_billing_transform <ENDS> Here

END dm_data_trans_billhis;