create or replace PROCEDURE               recon_lt_g1zdletr (
        i_schedulenumber IN   VARCHAR2
) AS
    
--VALAGNTPFCHECK:1 

     --   v_timestart             NUMBER := dbms_utility.get_time; --Timecheck
        c_zmrlh00               NUMBER(10) DEFAULT 0;
        c_titdmgletter          NUMBER(10) DEFAULT 0;
        c_letcpf                NUMBER(10) DEFAULT 0;
        p_exitcode              NUMBER;
        p_exittext              VARCHAR2(2000);
        v_no_data_stag          VARCHAR2(8 CHAR) := 'N';
        v_no_data_ig            VARCHAR2(8 CHAR) := 'N';
        recon_masterindex       INTEGER := 0;
        obj_recon_master        recon_master%rowtype;
        --temp_sor_lettype         VARCHAR2(8 CHAR);  


--TAB_NOT_FOUND_LIST
        CURSOR c_recon_master_sor IS
      SELECT  igcode AS sor_lettype, COUNT(igcode) AS sor_cnt from letter_code@DMSTGUSR2DBLINK LC 
inner join zmrlh00@DMSTGUSR2DBLINK za on dmcode = substr(za.lhcqcd, 1, 2) GROUP BY LC.igcode;

        o_reconmasterobj_sor    c_recon_master_sor%rowtype;

        CURSOR c_recon_master_stag IS
        SELECT
                lettype   stag_lettype,
                COUNT(1) stag_cnt
        FROM
                titdmgletter@dmstagedblink
        WHERE
                TRIM(lettype) = o_reconmasterobj_sor.sor_lettype
        GROUP BY
                lettype;

        o_reconmasterobj_stag   c_recon_master_stag%rowtype;
        CURSOR c_recon_master_ig IS
        SELECT
                lettype   ig_lettype,
                COUNT(1) ig_cnt
        FROM
                letcpf
        WHERE
                TRIM(lettype) = o_reconmasterobj_stag.stag_lettype
                and chdrnum in (select chdrnum from titdmgletter@dmstagedblink)
        GROUP BY
                lettype;

        o_reconmasterobj_ig     c_recon_master_ig%rowtype;
BEGIN
        dbms_output.put_line('Start execution of recon_master_lt_g1zdletr, SC NO:  '
                             || i_schedulenumber
                             || ' Flag :'
                             || 'Y');
                 --            delete from recon_master;
        SELECT
                COUNT(1)
        INTO c_zmrlh00
        FROM
                --zmrlh00;
                zmrlh00@DMSTGUSR2DBLINK;

        SELECT
                COUNT(1)
        INTO c_titdmgletter
        FROM
                titdmgletter@dmstagedblink;

        SELECT
                COUNT(1)
        INTO c_letcpf
        FROM
                letcpf where chdrnum in (select chdrnum from titdmgletter@dmstagedblink);

        IF c_zmrlh00 <> c_titdmgletter OR c_titdmgletter <> c_letcpf THEN
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'LETTER0' || recon_masterindex;
                obj_recon_master.module_name := 'LETTER';
                obj_recon_master.group_clause := '';
                obj_recon_master.where_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_zmrlh00;
                obj_recon_master.staging_value := c_titdmgletter;
                obj_recon_master.ig_value := c_letcpf;
                obj_recon_master.status := 'Fail';
                obj_recon_master.rundate := SYSDATE;
                obj_recon_master.query_desc := 'Src count: STAGEDBUSR2.zmrlh00 || stg count: STAGEDBUSR.titdmgletter || IG count: letcpf';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                OPEN c_recon_master_sor;
                 recon_masterindex := recon_masterindex + 1;
                << skiprecord >> LOOP
                        FETCH c_recon_master_sor INTO o_reconmasterobj_sor;
                        EXIT WHEN c_recon_master_sor%notfound;

                        v_no_data_stag := 'Y';
                        OPEN c_recon_master_stag;
                        << skiprecord >> LOOP
                                FETCH c_recon_master_stag INTO o_reconmasterobj_stag;
                                EXIT WHEN c_recon_master_stag%notfound;
                                v_no_data_stag := 'N';
                                v_no_data_ig := 'Y';
                                OPEN c_recon_master_ig;
                                << skiprecord >> LOOP
                                        FETCH c_recon_master_ig INTO o_reconmasterobj_ig;
                                        EXIT WHEN c_recon_master_ig%notfound;
                                        v_no_data_ig := 'N';
                                        IF o_reconmasterobj_sor.sor_cnt <> o_reconmasterobj_stag.stag_cnt OR o_reconmasterobj_stag
                                        .stag_cnt <> o_reconmasterobj_ig.ig_cnt THEN
                                                obj_recon_master.schedule_id := i_schedulenumber;
                                                obj_recon_master.recon_query_id := 'LETTER0' || recon_masterindex;
                                                obj_recon_master.module_name := 'LETTER';
                                                obj_recon_master.group_clause := 'LETTYPE';
                                                obj_recon_master.where_clause := 'LETTYPE  = ' || o_reconmasterobj_sor.sor_lettype
                                                ;
                                                obj_recon_master.validation_type := 'Count OF ' || o_reconmasterobj_sor.sor_lettype
                                                ;
                                                obj_recon_master.source_value := o_reconmasterobj_sor.sor_cnt;--?
                                                obj_recon_master.staging_value := o_reconmasterobj_stag.stag_cnt;
                                                obj_recon_master.ig_value := o_reconmasterobj_ig.ig_cnt;
                                                obj_recon_master.status := 'Fail';
                                                obj_recon_master.rundate := SYSDATE;
                                                  obj_recon_master.query_desc :=  'Src count: LETTYPE || stg count: LETTYPE || IG count: LETTYPE';
--                                
                                        ELSE
                                                obj_recon_master.schedule_id := i_schedulenumber;
                                                obj_recon_master.recon_query_id := 'LETTER0' || recon_masterindex;
                                                obj_recon_master.module_name := 'LETTER';
                                                obj_recon_master.group_clause := 'LETTYPE';
                                                obj_recon_master.where_clause := 'LETTYPE  = ' || o_reconmasterobj_sor.sor_lettype
                                                ;
                                                obj_recon_master.validation_type := 'Count OF ' || o_reconmasterobj_sor.sor_lettype
                                                ;
                                                obj_recon_master.source_value := o_reconmasterobj_sor.sor_cnt;--?
                                                obj_recon_master.staging_value := o_reconmasterobj_stag.stag_cnt;
                                                obj_recon_master.ig_value := o_reconmasterobj_ig.ig_cnt;
                                                obj_recon_master.status := 'Pass';
                                                obj_recon_master.rundate := SYSDATE;
                                                  obj_recon_master.query_desc := 'Src count: LETTYPE || stg count: LETTYPE || IG count: LETTYPE';
--                                
                                        END IF;

                                END LOOP;

                                CLOSE c_recon_master_ig;
                                IF v_no_data_ig = 'Y' THEN
                                        obj_recon_master.schedule_id := i_schedulenumber;
                                        obj_recon_master.recon_query_id := 'LETTER0' || recon_masterindex;
                                        obj_recon_master.module_name := 'LETTER';
                                        obj_recon_master.group_clause := 'LETTYPE';
                                        obj_recon_master.where_clause := 'LETTYPE  = ' || o_reconmasterobj_sor.sor_lettype;
                                        obj_recon_master.validation_type := 'Count OF ' || o_reconmasterobj_sor.sor_lettype;
                                        obj_recon_master.source_value := o_reconmasterobj_sor.sor_cnt;
                                        obj_recon_master.staging_value := o_reconmasterobj_stag.stag_cnt;
                                        obj_recon_master.ig_value := 0;
                                        obj_recon_master.status := 'Fail';
                                        obj_recon_master.rundate := SYSDATE;
                                          obj_recon_master.query_desc := 'Src count: LETTYPE || stg count: LETTYPE || IG count: LETTYPE';
                                        v_no_data_ig := 'N';
                                END IF;

                        END LOOP;

                        CLOSE c_recon_master_stag;
                        IF v_no_data_stag = 'Y' THEN
                                obj_recon_master.schedule_id := i_schedulenumber;
                                obj_recon_master.recon_query_id := 'LETTER0' || recon_masterindex;
                                obj_recon_master.module_name := 'LETTER';
                                obj_recon_master.group_clause := 'LETTYPE';
                                obj_recon_master.where_clause := 'LETTYPE  = ' || o_reconmasterobj_sor.sor_lettype;
                                obj_recon_master.validation_type := 'Count OF ' || o_reconmasterobj_sor.sor_lettype;
                                obj_recon_master.source_value := o_reconmasterobj_sor.sor_cnt;--?
                                obj_recon_master.staging_value := 0;
                               -- obj_recon_master.ig_value := 0;
                                obj_recon_master.status := 'Fail';
                                obj_recon_master.rundate := SYSDATE;
                                  obj_recon_master.query_desc := 'Src count: LETTYPE || stg count: LETTYPE || IG count: LETTYPE';
                                v_no_data_stag := 'N';
                        END IF;

                       INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                END LOOP;

                CLOSE c_recon_master_sor;
        ELSE
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'LETTER0' || recon_masterindex;
                obj_recon_master.module_name := 'LETTER';
                obj_recon_master.group_clause := '';
                obj_recon_master.where_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_zmrlh00;
                obj_recon_master.staging_value := c_titdmgletter;
                obj_recon_master.ig_value := c_letcpf;
                obj_recon_master.status := 'Pass';
                obj_recon_master.rundate := SYSDATE;
                  obj_recon_master.query_desc := 'Src count: STAGEDBUSR2.zmrlh00 || stg count: STAGEDBUSR.titdmgletter || IG count: letcpf';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

        END IF;

        COMMIT;
EXCEPTION
        WHEN OTHERS THEN

                 p_exitcode := sqlcode;
                p_exittext := 'LETTER'
                              || ' '
                              || dbms_utility.format_error_backtrace
                              || ' - '
                              || sqlerrm;

                raise_application_error(-20001, p_exitcode || p_exittext);


END recon_lt_g1zdletr;