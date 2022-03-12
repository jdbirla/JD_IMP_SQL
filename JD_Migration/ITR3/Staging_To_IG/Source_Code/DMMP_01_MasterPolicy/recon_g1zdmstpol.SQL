create or replace PROCEDURE                             RECON_G1ZDMSTPOL (
   i_schedulenumber     IN  VARCHAR2
)  IS
/***************************************************************************************************
  * Amenment History: Reconciliation for Group Master Policy
  * Date    Initials   Tag   Decription
  * -----   --------   ---   ---------------------------------------------------------------------------
  * MMMDD    XXX       CC1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * MAY11	 RC		   CC2	 Data Verification Changes
  * APRIL07            CC3   PA migration changes
  *****************************************************************************************************/
  
    -- Constant values
    c_schedulename                  CONSTANT VARCHAR2(50)  := 'G1ZDMSTPOL';
    c_module_name                   CONSTANT VARCHAR2(50)  := 'Master Policy';
    c_group_clause_chdrnum          CONSTANT VARCHAR2(255) := 'chdrnum';
    c_validation_type_header        CONSTANT VARCHAR2(255) := 'Policy Header Count';
    c_validation_type_contract      CONSTANT VARCHAR2(255) := 'Policy Count';
    c_where_clause_XN               CONSTANT VARCHAR2(255) := 'STATCODE = XN';
    c_where_clause_IF               CONSTANT VARCHAR2(255) := 'STATCODE = IF';
    c_where_clause_CA               CONSTANT VARCHAR2(255) := 'STATCODE = CA';
    c_query_desc_header             CONSTANT VARCHAR2(500) := 'Count is the number of Master Policy Number.';
    c_statcode_XN                   CONSTANT CHAR(2) := 'XN';
    c_statcode_IF                   CONSTANT CHAR(2) := 'IF';
    c_statcode_CA                   CONSTANT CHAR(2) := 'CA';
    c_fail                          constant CHAR(4) := 'Fail';
    c_pass                          constant CHAR(4) := 'Pass';

    --- Contract Header Count of all status
    v_count_mspol01_src       NUMBER(5);
    v_count_mspol01_stg       NUMBER(5);
    v_count_mspol01_ig        NUMBER(5);
    --- Contract Header Count of c_statcode_XN
    v_count_mspol02_src       NUMBER(5); 
    v_count_mspol02_stg       NUMBER(5);
    v_count_mspol02_ig        NUMBER(5);
    --- Contract Header Count of c_statcode_IF
    v_count_mspol03_src       NUMBER(5);
    v_count_mspol03_stg       NUMBER(5);
    v_count_mspol03_ig        NUMBER(5);
    --- Contract Header Count of c_statcode_CA
    v_count_mspol04_src       NUMBER(5);
    v_count_mspol04_stg       NUMBER(5);
    v_count_mspol04_ig        NUMBER(5);
    --- Contract Count  of all status
    v_count_mspol05_src       NUMBER(5);
    v_count_mspol05_stg       NUMBER(5);
    v_count_mspol05_ig        NUMBER(5);
    --- Contract Count of c_statcode_XN
    v_count_mspol06_src       NUMBER(5);
    v_count_mspol06_stg       NUMBER(5);
    v_count_mspol06_ig        NUMBER(5);
    --- Contract Count of c_statcode_IF
    v_count_mspol07_src       NUMBER(5);
    v_count_mspol07_stg       NUMBER(5);
    v_count_mspol07_ig        NUMBER(5);
    --- Contract Count of c_statcode_CA
    v_count_mspol08_src       NUMBER(5);
    v_count_mspol08_stg       NUMBER(5);
    v_count_mspol08_ig        NUMBER(5);

    v_cnt_rec                 NUMBER(5);
    v_timestart               NUMBER := dbms_utility.get_time;

  -------------- Cursor for MSPOL01 - MSPOL03 ---------
  --- policy headrer in src
    CURSOR src_policy_header_cursor IS
    --- select the number of records by each statcode of stg2.
    SELECT
          COUNT(*) cnt
         ,statcode
    FROM
         (
          --- select stdchdrnum and statcode from the latest policies.
          SELECT
                mp1.stdchdrnum
               ,mp1.statcode
          FROM
              (
                --- select stdchdrnum, ccdate and statcode of each latest policy of stag2 having identical stdchdrnum and ccdate with those of the sub-query.
                SELECT
                      CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                      END stdchdrnum
                     ,ccdate
                     ,statcode
                FROM
                    TITDMGMASPOL@dmstgusr2dblink
              ) mp1
              INNER JOIN
              (
                -- select grouped standardized chdrnum and maximum ccdate for getting the latest policy from sub-query.
                SELECT
                      stdchdrnum
                     ,MAX(ccdate) ccdate
                FROM
                    (
                     --- select standardized chdrnum and ccdate from stag2.
                     SELECT
                          CASE LENGTH(TRIM(chdrnum)) 
                               WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                               ELSE TRIM(chdrnum)
                          END stdchdrnum
                         ,ccdate
                     FROM
                         TITDMGMASPOL@dmstgusr2dblink
                     )
                GROUP BY
                    stdchdrnum
                ) mp2
              ON
                  mp1.stdchdrnum = mp2.stdchdrnum
              AND mp1.ccdate     = mp2.ccdate
          ORDER BY
              mp1.stdchdrnum
         )
    GROUP BY
         statcode
    ;

    obj_src_policy_header     src_policy_header_cursor%rowtype;
    
  --- policy headrer in stg
    CURSOR stg_policy_header_cursor IS
    
    --- select the number of records by each statcode of stg.
    SELECT
          COUNT(*) cnt
         ,statcode
    FROM
         (
          --- select stdchdrnum and statcode from the latest policies.
          SELECT
                mp1.stdchdrnum
               ,mp1.statcode
          FROM
              (
                --- select stdchdrnum, ccdate and statcode of each latest policy of stag having identical stdchdrnum and ccdate with those of the sub-query.
                SELECT
                      CASE LENGTH(TRIM(chdrnum)) 
                           WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                           ELSE TRIM(chdrnum)
                      END stdchdrnum
                     ,ccdate
                     ,statcode
                FROM
                    TITDMGMASPOL@dmstagedblink
              ) mp1
              INNER JOIN
              (
                -- select grouped standardized chdrnum and maximum ccdate for getting the latest policy from sub-query.
                SELECT 
                      stdchdrnum
                     ,MAX(ccdate) ccdate
                FROM
                    (
                     --- select standardized chdrnum and ccdate from stag.
                     SELECT
                          CASE LENGTH(TRIM(chdrnum)) 
                               WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                               ELSE TRIM(chdrnum)
                          END stdchdrnum
                         ,ccdate
                     FROM
                         TITDMGMASPOL@dmstagedblink
                     )
                GROUP BY
                    stdchdrnum
                ) mp2
              ON
                  mp1.stdchdrnum = mp2.stdchdrnum
              AND mp1.ccdate     = mp2.ccdate
          ORDER BY
              mp1.stdchdrnum
         )
    GROUP BY
         statcode
    ;

    obj_stg_policy_header     stg_policy_header_cursor%rowtype;

  --- policy headrer in IG
    CURSOR ig_policy_header_cursor IS
    SELECT
         COUNT(*) cnt
        ,statcode
    FROM
         Jd1dta.gchd
    WHERE
         jobnm = c_schedulename
    GROUP BY
         statcode   
    ;

    obj_ig_policy_header     ig_policy_header_cursor%rowtype;   

  -------------- Cursor for MSPOL04 - MSPOL06 ---------
  --- policy in src
    CURSOR src_policy_cursor IS
    SELECT
         COUNT(*) cnt
        ,statcode
    FROM
        TITDMGMASPOL@dmstgusr2dblink
    GROUP BY
        statcode
    ;

    obj_src_policy     src_policy_cursor%rowtype;

  --- policy in stg
    CURSOR stg_policy_cursor IS
    SELECT
         COUNT(*) cnt
        ,statcode
    FROM
        TITDMGMASPOL@dmstagedblink
    GROUP BY
        statcode
    ;

    obj_stg_policy     stg_policy_cursor%rowtype;
    
  --- policy in IG
   CURSOR ig_policy_cursor IS
   SELECT
         COUNT(*) cnt
        ,statcode  -- from the latest policy of Jd1dta.gchd (it's just for reference)
        ,stg_statcode  -- Since the latest status code is not necessarily equal to the previous term's status code, counting will be based on the status code of stg. 
   FROM
       (
          SELECT
             mp1.chdrnum
            ,mp2.statcode
            ,mp3.statcode stg_statcode
          FROM
             (
              --- select chdrnum and ccdate from Jd1dta.gchipf having jobnm is 'G1ZDMSTPOL' INNER JOIN mp2 and LEFT JOIN mp3
              SELECT
                    chdrnum
                   ,ccdate
              FROM
                    Jd1dta.gchipf
              WHERE
                    TRIM(jobnm) = c_schedulename
             ) mp1
             INNER JOIN
            (
             --- select chdrnum and statcode from Jd1dta.gchd having jobnm is 'G1ZDMSTPOL' mp1 INNER JOIN mp2
             SELECT
                  chdrnum
                 ,statcode
             FROM
                 Jd1dta.gchd
             WHERE
                TRIM(jobnm) = c_schedulename
            ) mp2
            ON
              TRIM(mp1.chdrnum) = TRIM(mp2.chdrnum)
            LEFT JOIN
            (
             -- select stdchdrnum, ccdate and statcode from stg, mp1 LEFT JOIN mp3
             SELECT
                   stdchdrnum
                  ,ccdate
                  ,statcode
             FROM
                 (
                   SELECT
                         CASE LENGTH(TRIM(chdrnum)) 
                              WHEN 11 THEN SUBSTR(TRIM(chdrnum),4,8)
                              ELSE TRIM(chdrnum)
                         END stdchdrnum
                        ,ccdate
                        ,statcode
                   FROM
                       TITDMGMASPOL@dmstagedblink
                 )
            ) mp3
            ON
                TRIM(mp1.chdrnum) = TRIM(mp3.stdchdrnum)
            AND TRIM(mp1.ccdate) = TRIM(mp3.ccdate)
       )
   GROUP BY
       statcode, stg_statcode
  ;
  
  obj_ig_policy     ig_policy_cursor%rowtype;
  
  -------------- Cursor for recon_master ---------
    obj_recon_master          Jd1dta.recon_master%rowtype;

BEGIN

    v_count_mspol01_src := 0;
    v_count_mspol01_stg := 0;
    v_count_mspol01_ig := 0;

    v_count_mspol02_src := 0;
    v_count_mspol02_stg := 0;
    v_count_mspol02_ig := 0;

    v_count_mspol03_src := 0;
    v_count_mspol03_stg := 0;
    v_count_mspol03_ig := 0;

    v_count_mspol04_src := 0;
    v_count_mspol04_stg := 0;
    v_count_mspol04_ig := 0;

    v_count_mspol05_src := 0;
    v_count_mspol05_stg := 0;
    v_count_mspol05_ig := 0;

    v_count_mspol06_src := 0;
    v_count_mspol06_stg := 0;
    v_count_mspol06_ig := 0; 

    v_count_mspol07_src := 0;
    v_count_mspol07_stg := 0;
    v_count_mspol07_ig := 0; 

    v_count_mspol08_src := 0;
    v_count_mspol08_stg := 0;
    v_count_mspol08_ig := 0; 

--- validation on policy header in source
    OPEN src_policy_header_cursor;
    LOOP
        FETCH src_policy_header_cursor INTO obj_src_policy_header;
        EXIT WHEN src_policy_header_cursor%notfound;
        
        v_count_mspol01_src := v_count_mspol01_src + obj_src_policy_header.cnt;
        CASE obj_src_policy_header.statcode
             WHEN c_statcode_XN THEN v_count_mspol02_src := v_count_mspol02_src + obj_src_policy_header.cnt;
             WHEN c_statcode_IF THEN v_count_mspol03_src := v_count_mspol03_src + obj_src_policy_header.cnt;
             WHEN c_statcode_CA THEN v_count_mspol04_src := v_count_mspol04_src + obj_src_policy_header.cnt;
        END CASE;

            
    END LOOP;
    
    dbms_output.put_line('---- policy header in source ---');
    dbms_output.put_line('src_header_total: ' || v_count_mspol01_src);
    dbms_output.put_line('src_header_XN: ' || v_count_mspol02_src);
    dbms_output.put_line('src_header_IF: ' || v_count_mspol03_src);
    dbms_output.put_line('src_header_CA: ' || v_count_mspol04_src);
    
    CLOSE src_policy_header_cursor;
    
--- validation on policy header in staging
    OPEN stg_policy_header_cursor;
    LOOP
        FETCH stg_policy_header_cursor INTO obj_stg_policy_header;
        EXIT WHEN stg_policy_header_cursor%notfound;
        
        v_count_mspol01_stg := v_count_mspol01_stg + obj_stg_policy_header.cnt;
        CASE obj_stg_policy_header.statcode
             WHEN c_statcode_XN THEN v_count_mspol02_stg := v_count_mspol02_stg + obj_stg_policy_header.cnt;
             WHEN c_statcode_IF THEN v_count_mspol03_stg := v_count_mspol03_stg + obj_stg_policy_header.cnt;
             WHEN c_statcode_CA THEN v_count_mspol04_stg := v_count_mspol04_stg + obj_stg_policy_header.cnt;
        END CASE;

            
    END LOOP;
    
    dbms_output.put_line('---- policy header in staging ---');
    dbms_output.put_line('stg_header_total: ' || v_count_mspol01_stg);
    dbms_output.put_line('stg_header_XN: ' || v_count_mspol02_stg);
    dbms_output.put_line('stg_header_IF: ' || v_count_mspol03_stg);
    dbms_output.put_line('stg_header_CA: ' || v_count_mspol04_stg);
    
    CLOSE stg_policy_header_cursor;
    
--- validation on policy header in ig
    OPEN ig_policy_header_cursor;
    LOOP
        FETCH ig_policy_header_cursor INTO obj_ig_policy_header;
        EXIT WHEN ig_policy_header_cursor%notfound;
        
        v_count_mspol01_ig := v_count_mspol01_ig + obj_ig_policy_header.cnt;
        CASE obj_ig_policy_header.statcode
             WHEN c_statcode_XN THEN v_count_mspol02_ig := v_count_mspol02_ig + obj_ig_policy_header.cnt;
             WHEN c_statcode_IF THEN v_count_mspol03_ig := v_count_mspol03_ig + obj_ig_policy_header.cnt;
             WHEN c_statcode_CA THEN v_count_mspol04_ig := v_count_mspol04_ig + obj_ig_policy_header.cnt;
        END CASE;

            
    END LOOP;
    
    dbms_output.put_line('---- policy header in ig ---');
    dbms_output.put_line('ig_header_total: ' || v_count_mspol01_ig);
    dbms_output.put_line('ig_header_XN: ' || v_count_mspol02_ig);
    dbms_output.put_line('ig_header_IF: ' || v_count_mspol03_ig);
    dbms_output.put_line('ig_header_CA: ' || v_count_mspol04_ig);
    
    CLOSE ig_policy_header_cursor;   
 
 ---- insert MSPOL01 valiudation results -----
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_recon_master.recon_query_id := 'MSPOL01';
    obj_recon_master.module_name := c_module_name;
    obj_recon_master.group_clause := c_group_clause_chdrnum;
    obj_recon_master.where_clause := null;
    obj_recon_master.validation_type := c_validation_type_header;
    obj_recon_master.source_value := v_count_mspol01_src;
    obj_recon_master.staging_value := v_count_mspol01_stg;
    obj_recon_master.ig_value := v_count_mspol01_ig;
    IF v_count_mspol01_src * 3 = (v_count_mspol01_src + v_count_mspol01_stg + v_count_mspol01_ig) THEN
       obj_recon_master.status := c_pass;
    ELSE
       obj_recon_master.status := c_fail;
    END IF;
    
    obj_recon_master.rundate := current_timestamp;
    obj_recon_master.query_desc := c_query_desc_header;

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

 ---- insert MSPOL02 valiudation results -----
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_recon_master.recon_query_id := 'MSPOL02';
    obj_recon_master.module_name := c_module_name;
    obj_recon_master.group_clause := c_group_clause_chdrnum;
    obj_recon_master.where_clause := c_where_clause_XN;
    obj_recon_master.validation_type := c_validation_type_header;
    obj_recon_master.source_value := v_count_mspol02_src;
    obj_recon_master.staging_value := v_count_mspol02_stg;
    obj_recon_master.ig_value := v_count_mspol02_ig;
    IF v_count_mspol02_src * 3 = (v_count_mspol02_src + v_count_mspol02_stg + v_count_mspol02_ig) THEN
       obj_recon_master.status := c_pass;
    ELSE
       obj_recon_master.status := c_fail;
    END IF;
    
    obj_recon_master.rundate := current_timestamp;
    obj_recon_master.query_desc := c_query_desc_header;

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

 ---- insert MSPOL03 valiudation results -----
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_recon_master.recon_query_id := 'MSPOL03';
    obj_recon_master.module_name := c_module_name;
    obj_recon_master.group_clause := c_group_clause_chdrnum;
    obj_recon_master.where_clause := c_where_clause_IF;
    obj_recon_master.validation_type := c_validation_type_header;
    obj_recon_master.source_value := v_count_mspol03_src;
    obj_recon_master.staging_value := v_count_mspol03_stg;
    obj_recon_master.ig_value := v_count_mspol03_ig;
    IF v_count_mspol03_src * 3 = (v_count_mspol03_src + v_count_mspol03_stg + v_count_mspol03_ig) THEN
       obj_recon_master.status := c_pass;
    ELSE
       obj_recon_master.status := c_fail;
    END IF;
    
    obj_recon_master.rundate := current_timestamp;
    obj_recon_master.query_desc := c_query_desc_header;

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;
    
 ---- insert MSPOL04 valiudation results -----
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_recon_master.recon_query_id := 'MSPOL04';
    obj_recon_master.module_name := c_module_name;
    obj_recon_master.group_clause := c_group_clause_chdrnum;
    obj_recon_master.where_clause := c_where_clause_CA;
    obj_recon_master.validation_type := c_validation_type_header;
    obj_recon_master.source_value := v_count_mspol04_src;
    obj_recon_master.staging_value := v_count_mspol04_stg;
    obj_recon_master.ig_value := v_count_mspol04_ig;
    IF v_count_mspol04_src * 3 = (v_count_mspol04_src + v_count_mspol04_stg + v_count_mspol04_ig) THEN
       obj_recon_master.status := c_pass;
    ELSE
       obj_recon_master.status := c_fail;
    END IF;
    
    obj_recon_master.rundate := current_timestamp;
    obj_recon_master.query_desc := c_query_desc_header;

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;
      
--- validation on policy in source
    OPEN src_policy_cursor;
    LOOP
        FETCH src_policy_cursor INTO obj_src_policy;
        EXIT WHEN src_policy_cursor%notfound;
        
        v_count_mspol05_src := v_count_mspol05_src + obj_src_policy.cnt;
        CASE obj_src_policy.statcode
             WHEN c_statcode_XN THEN v_count_mspol06_src := v_count_mspol06_src + obj_src_policy.cnt;
             WHEN c_statcode_IF THEN v_count_mspol07_src := v_count_mspol07_src + obj_src_policy.cnt;
             WHEN c_statcode_CA THEN v_count_mspol08_src := v_count_mspol08_src + obj_src_policy.cnt;
        END CASE;

            
    END LOOP;
    
    dbms_output.put_line('---- policy in source ---');
    dbms_output.put_line('src_total: ' || v_count_mspol05_src);
    dbms_output.put_line('src_XN: ' || v_count_mspol06_src);
    dbms_output.put_line('src_IF: ' || v_count_mspol07_src);
    dbms_output.put_line('src_CA: ' || v_count_mspol08_src);
    
    CLOSE src_policy_cursor;

--- validation on policy in staging
    OPEN stg_policy_cursor;
    LOOP
        FETCH stg_policy_cursor INTO obj_stg_policy;
        EXIT WHEN stg_policy_cursor%notfound;
        
        v_count_mspol05_stg := v_count_mspol05_stg + obj_stg_policy.cnt;

        CASE obj_stg_policy.statcode
             WHEN c_statcode_XN THEN v_count_mspol06_stg := v_count_mspol06_stg + obj_stg_policy.cnt;
             WHEN c_statcode_IF THEN v_count_mspol07_stg := v_count_mspol07_stg + obj_stg_policy.cnt;
             WHEN c_statcode_CA THEN v_count_mspol08_stg := v_count_mspol08_stg + obj_stg_policy.cnt;
        END CASE;
            
    END LOOP;
    
    dbms_output.put_line('---- policy in staging ---');
    dbms_output.put_line('stg_total: ' || v_count_mspol05_stg);
    dbms_output.put_line('stg_XN: ' || v_count_mspol06_stg);
    dbms_output.put_line('stg_IF: ' || v_count_mspol07_stg);
    dbms_output.put_line('stg_CA: ' || v_count_mspol08_stg);
    
    CLOSE stg_policy_cursor; 
    
--- validation on policy in ig
    OPEN ig_policy_cursor;
    LOOP
        FETCH ig_policy_cursor INTO obj_ig_policy;
        EXIT WHEN ig_policy_cursor%notfound;
        
        v_count_mspol05_ig := v_count_mspol05_ig + obj_ig_policy.cnt;
        IF obj_ig_policy.stg_statcode IS NOT NULL THEN
        CASE obj_ig_policy.stg_statcode -- counted by statcode of stg
             WHEN c_statcode_XN THEN v_count_mspol06_ig := v_count_mspol06_ig + obj_ig_policy.cnt;
             WHEN c_statcode_IF THEN v_count_mspol07_ig := v_count_mspol07_ig + obj_ig_policy.cnt;
             WHEN c_statcode_CA THEN v_count_mspol08_ig := v_count_mspol08_ig + obj_ig_policy.cnt;
        END CASE;
        END IF;

    END LOOP;
    
    dbms_output.put_line('---- policy in ig ---');
    dbms_output.put_line('ig_total: ' || v_count_mspol05_ig);
    dbms_output.put_line('ig_XN: ' || v_count_mspol06_ig);
    dbms_output.put_line('ig_IF: ' || v_count_mspol07_ig);
    dbms_output.put_line('ig_CA: ' || v_count_mspol08_ig);
    
    CLOSE ig_policy_cursor;

 ---- insert MSPOL05 valiudation results -----
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_recon_master.recon_query_id := 'MSPOL05';
    obj_recon_master.module_name := c_module_name;
    obj_recon_master.group_clause := null;
    obj_recon_master.where_clause := null;
    obj_recon_master.validation_type := c_validation_type_contract;
    obj_recon_master.source_value := v_count_mspol05_src;
    obj_recon_master.staging_value := v_count_mspol05_stg;
    obj_recon_master.ig_value := v_count_mspol05_ig;
    IF v_count_mspol05_src * 3 = (v_count_mspol05_src + v_count_mspol05_stg + v_count_mspol05_ig) THEN
       obj_recon_master.status := c_pass;
    ELSE
       obj_recon_master.status := c_fail;
    END IF;
    
    obj_recon_master.rundate := current_timestamp;
    obj_recon_master.query_desc := null;

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

 ---- insert MSPOL06 valiudation results -----
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_recon_master.recon_query_id := 'MSPOL06';
    obj_recon_master.module_name := c_module_name;
    obj_recon_master.group_clause := null;
    obj_recon_master.where_clause := c_where_clause_XN;
    obj_recon_master.validation_type := c_validation_type_contract;
    obj_recon_master.source_value := v_count_mspol06_src;
    obj_recon_master.staging_value := v_count_mspol06_stg;
    obj_recon_master.ig_value := v_count_mspol06_ig;
    IF v_count_mspol06_src * 3 = (v_count_mspol06_src + v_count_mspol06_stg + v_count_mspol06_ig) THEN
       obj_recon_master.status := c_pass;
    ELSE
       obj_recon_master.status := c_fail;
    END IF;
    
    obj_recon_master.rundate := current_timestamp;
    obj_recon_master.query_desc := null;

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

 ---- insert MSPOL07 valiudation results -----
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_recon_master.recon_query_id := 'MSPOL07';
    obj_recon_master.module_name := c_module_name;
    obj_recon_master.group_clause := null;
    obj_recon_master.where_clause := c_where_clause_IF;
    obj_recon_master.validation_type := c_validation_type_contract;
    obj_recon_master.source_value := v_count_mspol07_src;
    obj_recon_master.staging_value := v_count_mspol07_stg;
    obj_recon_master.ig_value := v_count_mspol07_ig;
    IF v_count_mspol07_src * 3 = (v_count_mspol07_src + v_count_mspol07_stg + v_count_mspol07_ig) THEN
       obj_recon_master.status := c_pass;
    ELSE
       obj_recon_master.status := c_fail;
    END IF;
    
    obj_recon_master.rundate := current_timestamp;
    obj_recon_master.query_desc := null;

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;
    
 ---- insert MSPOL08 valiudation results -----
    obj_recon_master.schedule_id := i_schedulenumber;
    obj_recon_master.recon_query_id := 'MSPOL08';
    obj_recon_master.module_name := c_module_name;
    obj_recon_master.group_clause := null;
    obj_recon_master.where_clause := c_where_clause_CA;
    obj_recon_master.validation_type := c_validation_type_contract;
    obj_recon_master.source_value := v_count_mspol08_src;
    obj_recon_master.staging_value := v_count_mspol08_stg;
    obj_recon_master.ig_value := v_count_mspol08_ig;
    IF v_count_mspol08_src * 3 = (v_count_mspol08_src + v_count_mspol08_stg + v_count_mspol08_ig) THEN
       obj_recon_master.status := c_pass;
    ELSE
       obj_recon_master.status := c_fail;
    END IF;
    
    obj_recon_master.rundate := current_timestamp;
    obj_recon_master.query_desc := null;

    INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

    NULL;
    
    dbms_output.put_line('Procedure execution time = '
                         ||(dbms_utility.get_time - v_timestart) / 100);    

END RECON_G1ZDMSTPOL;
