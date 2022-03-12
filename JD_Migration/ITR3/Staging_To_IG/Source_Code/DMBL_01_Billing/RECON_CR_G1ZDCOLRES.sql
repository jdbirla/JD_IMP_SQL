create or replace PROCEDURE recon_cr_g1zdcolres (
        i_schedulenumber IN   VARCHAR2
) AS

       v_module_name          CONSTANT VARCHAR2(40) := 'Collection Result';
        obj_recon_master       recon_master%rowtype;
        c_pass                 CONSTANT VARCHAR2(4) := 'PASS';
        c_fail                 CONSTANT VARCHAR2(4) := 'FAIL';
        v_stg_zcrhp            VARCHAR2(50);
        c_stg_titdmgcolres     NUMBER;
        c_ig_zcrhpf            NUMBER;
        c_ig_zuclpf            NUMBER;
        c_sor_titdmgcolres     NUMBER;
        recon_masterindex      INTEGER := 0;
        c_sor_titdmgcolres_us     NUMBER ;
        c_stg_titdmgcolres_us     NUMBER ;
        CURSOR c_recon_master_sor IS


   -- SELECT count(1),DSHCDE,TFRDATE  FROM TITDMGCOLRES@dmstagedblink GROUP BY DSHCDE,TFRDATE;
        SELECT
                dshcde   AS sor_dshcde,
                COUNT(1) AS c_sor_titdmgcolres
        FROM
               -- titdmgcolres2@dmstagedblink
				titdmgcolres@DMSTGUSR2DBLINK
        GROUP BY
                dshcde;

        o_reconmasterobj_sor   c_recon_master_sor%rowtype;
        v_reconid              Jd1dta.recon_master.recon_query_id%TYPE;
        v_src_stg_flg          VARCHAR2(1) := 'N';
        v_stg_ig_flg           VARCHAR2(1) := 'N';
        v_final_flg            VARCHAR2(1) := 'N';
        plancnt                NUMBER;
        p_exitcode             NUMBER;
        p_exittext             VARCHAR2(2000);
BEGIN
        SELECT
                COUNT(1)
        INTO c_sor_titdmgcolres
        FROM
               -- titdmgcolres2@dmstagedblink;
			   titdmgcolres@DMSTGUSR2DBLINK;

        SELECT
                COUNT(1)
        INTO c_stg_titdmgcolres
        FROM
                titdmgcolres@dmstagedblink;

        SELECT
                COUNT(1)
        INTO c_ig_zcrhpf
        FROM
                Jd1dta.zcrhpf
        WHERE
                TRIM(chdrnum) IN (
                        SELECT
                                TRIM(chdrnum)
                        FROM
                                titdmgcolres@dmstagedblink
                )
                AND TRIM(jobnm) = 'G1ZDCOLRES';


         SELECT COUNT(1) into c_sor_titdmgcolres_us FROM 
		-- TITDMGCOLRES2@dmstagedblink C 
		 titdmgcolres@DMSTGUSR2DBLINK C
		 WHERE  trim(C.dshcde) <> '00' AND C.dshcde <> ' ';       
         SELECT COUNT(1) into c_stg_titdmgcolres_us FROM TITDMGCOLRES@dmstagedblink C WHERE  trim(C.dshcde) <> '00' AND C.dshcde <> ' ';       
          SELECT SUM(zcombill) into c_ig_zuclpf FROM Jd1dta.zuclpf WHERE
                TRIM(chdrnum) IN (
                        SELECT
                                TRIM(chdrnum)
                        FROM
                                titdmgcolres@dmstagedblink where  trim(dshcde) <> '00' AND dshcde <> ' '
                ) AND trim(JOBNM)='G1ZDCOLRES';

        IF  ( c_sor_titdmgcolres_us = c_stg_titdmgcolres_us AND c_stg_titdmgcolres_us = c_ig_zuclpf )THEN
      recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.module_name := v_module_name;
                obj_recon_master.rundate := SYSDATE;
                obj_recon_master.recon_query_id := 'COLRES0' || recon_masterindex;
                obj_recon_master.group_clause := ' ';
                obj_recon_master.where_clause := ' ';
                obj_recon_master.validation_type := 'COUNT_US';
                obj_recon_master.source_value := c_sor_titdmgcolres_us;
                obj_recon_master.staging_value := c_stg_titdmgcolres_us;
                obj_recon_master.ig_value := c_ig_zuclpf;
                obj_recon_master.query_desc := 'Src count: STAGEDBUSR2.TITDMGCOLRES || stg count: STAGEDBUSR.TITDMGCOLRES || IG count: zuclpf'
                ;
                obj_recon_master.status := c_pass;
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

        ELSE
                obj_recon_master.schedule_id := i_schedulenumber;
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.module_name := v_module_name;
                obj_recon_master.rundate := SYSDATE;
                obj_recon_master.recon_query_id := 'COLRES0' || recon_masterindex;
                obj_recon_master.group_clause := ' ';
                obj_recon_master.where_clause := ' ';
                obj_recon_master.validation_type := 'COUNT_US';
                obj_recon_master.source_value := c_sor_titdmgcolres_us;
                obj_recon_master.staging_value := c_stg_titdmgcolres_us;
                obj_recon_master.ig_value := c_ig_zuclpf;
                obj_recon_master.query_desc := 'Src count: STAGEDBUSR2.TITDMGCOLRES || stg count: STAGEDBUSR.TITDMGCOLRES || IG count: zuclpf'
                ;

                obj_recon_master.status := c_fail;
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;
    END IF;

        IF ( c_sor_titdmgcolres = c_stg_titdmgcolres AND c_stg_titdmgcolres = c_ig_zcrhpf ) THEN
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.module_name := v_module_name;
                obj_recon_master.rundate := SYSDATE;
                obj_recon_master.recon_query_id := 'COLRES0' || recon_masterindex;
                obj_recon_master.group_clause := ' ';
                obj_recon_master.where_clause := ' ';
                obj_recon_master.validation_type := 'COUNT';
                obj_recon_master.source_value := c_sor_titdmgcolres;
                obj_recon_master.staging_value := c_stg_titdmgcolres;
                obj_recon_master.ig_value := c_ig_zcrhpf;
                obj_recon_master.query_desc := 'Src count: STAGEDBUSR2.TITDMGCOLRES || stg count: STAGEDBUSR.TITDMGCOLRES || IG count: zcrhpf'
                ;
                obj_recon_master.status := c_pass;
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

        ELSE
                obj_recon_master.schedule_id := i_schedulenumber;
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.module_name := v_module_name;
                obj_recon_master.rundate := SYSDATE;
                obj_recon_master.recon_query_id := 'COLRES0' || recon_masterindex;
                obj_recon_master.group_clause := ' ';
                obj_recon_master.where_clause := ' ';
                obj_recon_master.validation_type := 'COUNT';
                obj_recon_master.source_value := c_sor_titdmgcolres;
                obj_recon_master.staging_value := c_stg_titdmgcolres;
                obj_recon_master.ig_value := c_ig_zcrhpf;
                obj_recon_master.query_desc := 'Src count: STAGEDBUSR2.TITDMGCOLRES || stg count: STAGEDBUSR.TITDMGCOLRES || IG count: zcrhpf'
                ;
                obj_recon_master.status := c_fail;
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;
 -- delete from recon_master;

                OPEN c_recon_master_sor;
                recon_masterindex := recon_masterindex + 1;
                << skiprecord >> LOOP
                        FETCH c_recon_master_sor INTO o_reconmasterobj_sor;
                        EXIT WHEN c_recon_master_sor%notfound;
                        v_src_stg_flg := 'N';
                        v_stg_ig_flg := 'N';
                        v_final_flg := 'N';
                        c_ig_zcrhpf := 0;
                        c_ig_zuclpf := 0;
                        c_stg_titdmgcolres := 0;
                        obj_recon_master := NULL;
                        BEGIN

    --SELECT count(1),chdrnum,TFRDATE  FROM TITDMGCOLRES@dmstagedblink 
                                SELECT
                                        COUNT(1)
                                INTO c_stg_titdmgcolres
                                FROM
                                        titdmgcolres@dmstagedblink
                                WHERE
                                        TRIM(dshcde) = o_reconmasterobj_sor.sor_dshcde;


                        EXCEPTION
                                WHEN no_data_found THEN
                                        c_stg_titdmgcolres := 0;
                        END;

                        BEGIN
                                SELECT
                                        COUNT(1)
                                INTO c_ig_zcrhpf
                                FROM
                                        Jd1dta.zcrhpf zcr
                                WHERE
                                        TRIM(dshcde) = o_reconmasterobj_sor.sor_dshcde
                                        AND TRIM(jobnm) = 'G1ZDCOLRES'
                                        AND ( TRIM(chdrnum) IN (
                                                SELECT
                                                        TRIM(chdrnum)
                                                FROM
                                                        titdmgcolres@dmstagedblink
                                        ) );

                        EXCEPTION
                                WHEN no_data_found THEN
                                        c_ig_zcrhpf := 0;
                        END;


                        obj_recon_master.schedule_id := i_schedulenumber;
                        obj_recon_master.module_name := v_module_name;
                        obj_recon_master.rundate := SYSDATE;
                        obj_recon_master.recon_query_id := 'COLRES0' || recon_masterindex;
                        obj_recon_master.group_clause := 'Group by DSHCDE';
                        obj_recon_master.where_clause := 'DSHCDE= ' || o_reconmasterobj_sor.sor_dshcde;
                        obj_recon_master.validation_type := 'COUNT';
                        obj_recon_master.source_value := o_reconmasterobj_sor.c_sor_titdmgcolres;
                        obj_recon_master.staging_value := c_stg_titdmgcolres;
                        obj_recon_master.ig_value := c_ig_zcrhpf;
                        obj_recon_master.query_desc := 'Src count: STAGEDBUSR2.TITDMGCOLRES || stg count: STAGEDBUSR.TITDMGCOLRES || IG count: zcrhpf'
                        ;
                        IF ( o_reconmasterobj_sor.c_sor_titdmgcolres = c_stg_titdmgcolres ) THEN
                                v_src_stg_flg := 'Y';
                        END IF;
                        IF ( c_stg_titdmgcolres = c_ig_zcrhpf  ) THEN
                                v_stg_ig_flg := 'Y';
                        END IF;

                        IF ( v_src_stg_flg = 'Y' AND v_stg_ig_flg = 'Y' ) THEN
                                v_final_flg := 'Y';
                        END IF;

                        IF ( v_final_flg = 'Y' ) THEN
                                obj_recon_master.status := c_pass;
                        ELSE
                                obj_recon_master.status := c_fail;
                        END IF;

                        INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                END LOOP;

                CLOSE c_recon_master_sor;
        END IF;


        COMMIT;
EXCEPTION
        WHEN OTHERS THEN
                p_exitcode := sqlcode;
                p_exittext := ' collection result '
                              || ' '
                              || dbms_utility.format_error_backtrace
                              || ' - '
                              || sqlerrm;

                raise_application_error(-20001, p_exitcode || p_exittext);
END recon_cr_g1zdcolres;