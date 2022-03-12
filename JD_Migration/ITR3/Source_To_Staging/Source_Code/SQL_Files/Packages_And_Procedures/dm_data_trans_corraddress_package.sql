create or replace PACKAGE   dm_data_trans_corraddress AS
/*************************************************************************************************** 
 * Amednment History: DM_POLICY_STATUS_CODE
* Date    Initials   Tag   Decription 
 * -----   --------   ---   --------------------------------------------------------------------------- 
 * MMMDD    XXX       PC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
 * FEB28    MKS       CA1   Correspondence Address Transformation
*****************************************************************************************************/ 

  PROCEDURE dm_corraddr_transformation(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');
  
END dm_data_trans_corraddress;
/
create or replace PACKAGE BODY  dm_data_trans_corraddress IS
/*************************************************************************************************** 
 * Amednment History: DM_POLICY_STATUS_CODE
* Date    Initials   Tag   Decription 
 * -----   --------   ---   --------------------------------------------------------------------------- 
 * MMMDD    XXX       PC#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
 * JAN14    MKS       PC1   PA_ITR3 Policy Status Code Initial Code  
*****************************************************************************************************/ 
    stg_starttime    TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;    

    PROCEDURE dm_corraddr_transformation (
        p_array_size   IN   PLS_INTEGER DEFAULT 1000,
        p_delta        IN   CHAR DEFAULT 'N'
    ) IS
        v_input_count    NUMBER;
        v_output_count   NUMBER;
        stg_starttime    TIMESTAMP;
        stg_endtime      TIMESTAMP;
        l_err_flg        NUMBER := 0;
        g_err_flg        NUMBER := 0;
        v_errormsg       VARCHAR2(2000);
        temp_no          NUMBER;
        v_targettbl      VARCHAR2(15);
        v_srctble        VARCHAR2(100);
        corr_addr_issue  EXCEPTION;
        PRAGMA exception_init(corr_addr_issue, -20111);

        CURSOR cur_data IS        
            SELECT a.daplno chdrnum,
                    nvl(TRIM(substr((TRIM(a.dab5tx)), 1, instr((TRIM(a.dab5tx)), ' ') - 1)), ' ') AS zkanasnm,
                    nvl(TRIM(substr((TRIM(a.dab5tx)), instr((TRIM(a.dab5tx)), ' ') + 1)), ' ') AS zkanagnm,
                    TRIM(substr((TRIM(a.dacbig)), 1,(
                          CASE
                              WHEN instr(TRIM(a.dacbig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(a.dacbig), unistr('\3000')) 
                              WHEN instr(TRIM(a.dacbig), ' ')  <> 0 THEN
                                  instr(TRIM(a.dacbig), ' ')
                              ELSE
                                  instr(TRIM(a.dacbig), '?')
                          END
                      ) - 1)) AS lsurname,
                    TRIM(substr((TRIM(a.dacbig)),(
                          CASE
                              WHEN instr(TRIM(a.dacbig), unistr('\3000'))  <> 0 THEN
                                  instr(TRIM(a.dacbig), unistr('\3000')) 
                              WHEN instr(TRIM(a.dacbig), ' ')  <> 0 THEN
                                  instr(TRIM(a.dacbig), ' ')
                              ELSE
                                  instr(TRIM(a.dacbig), '?')
                          END
                      ) + 1)) AS lgivname,
                    REGEXP_REPLACE(a.Dac9cd ,'[^0-9]') AS cltpcode,
                    a.dab7ig AS cltaddr01,
                    a.dab8ig AS cltaddr02,
                    a.dab9ig AS cltaddr03,
                    a.dacaig AS cltaddr04,
                    a.dab0tx AS zkanaddr01,
                    a.dab1tx AS zkanaddr02,
                    a.dab2tx AS zkanaddr03,
                    a.dab3tx AS zkanaddr04,
                    nvl(a.dab4tx, '                ') AS cltphone01
            FROM zmrda00 a
			ORDER BY a.daplno;

        TYPE ig_array IS
            TABLE OF cur_data%rowtype;
        st_data          ig_array;
        prev_data        cur_data%rowtype;

        l_app_old        VARCHAR2(15) := NULL;

    BEGIN		

        l_err_flg := 0;
        g_err_flg := 0;
        dm_data_trans_gen.stg_starttime := systimestamp;
        v_input_count := 0;
        v_output_count := 0;
        IF p_delta = 'Y' THEN
            v_errormsg := 'For Delta Load:';
            OPEN cur_data;
            LOOP
                FETCH cur_data BULK COLLECT INTO st_data LIMIT p_array_size;
                FORALL d_indx IN 1..st_data.COUNT
                  DELETE FROM titdmgcoraddr
                  WHERE
                      chdrnum = st_data(d_indx).chdrnum;
                 EXIT WHEN cur_data%notfound;          
            END LOOP;
            COMMIT;
            CLOSE cur_data;
         -- Delete the records for all the records exists in TITDMGCORADDR for Delta Load
        END IF;

		v_errormsg := 'MASTER :';
        v_srctble := 'ZMRDA00';
        v_targettbl := 'TITDMGCORADDR';	
		OPEN cur_data;
        LOOP
		FETCH cur_data BULK COLLECT INTO st_data LIMIT p_array_size;
			v_input_count := v_input_count + st_data.COUNT;
            FOR st_indx IN 1..st_data.COUNT LOOP
              l_app_old := st_data(st_indx).chdrnum; 

			  BEGIN	
				INSERT INTO titdmgcoraddr (
					CHDRNUM,
					ZKANASNM,
					ZKANAGNM,
					LSURNAME,
					LGIVNAME,
					CLTPCODE,
					CLTADDR01,
					CLTADDR02,
					CLTADDR03,
					CLTADDR04,
					ZKANADDR01,
					ZKANADDR02,
					ZKANADDR03,
					ZKANADDR04,
					CLTPHONE01
				) VALUES (
					st_data(st_indx).chdrnum,
					st_data(st_indx).zkanasnm,
					st_data(st_indx).zkanagnm,
					st_data(st_indx).lsurname,
					st_data(st_indx).lgivname,
					st_data(st_indx).cltpcode,
					st_data(st_indx).cltaddr01,
					st_data(st_indx).cltaddr02,
					st_data(st_indx).cltaddr03,
					st_data(st_indx).cltaddr04,
					st_data(st_indx).zkanaddr01,
					st_data(st_indx).zkanaddr02,
					st_data(st_indx).zkanaddr03,
					st_data(st_indx).zkanaddr04,
					st_data(st_indx).cltphone01
				);
			v_output_count := v_output_count + 1;
              EXCEPTION
                  WHEN OTHERS THEN
                      g_err_flg := g_err_flg + 1;
                      v_errormsg := v_errormsg
                                    || '-'
                                    || sqlerrm;
                      DM_data_trans_gen.error_logs('TITDMGCORADDR', st_data(st_indx).chdrnum, v_errormsg);
              END;
            END LOOP;
			EXIT WHEN cur_data%NOTFOUND;
		END LOOP;
        COMMIT;
		CLOSE cur_data;

        IF g_err_flg = 0 THEN
            v_errormsg := 'SUCCESS';
            temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
            'S', v_input_count, v_output_count);
        ELSE
            v_errormsg := 'COMPLETED WITH ERROR';
            temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);
        END IF;		

    EXCEPTION
        WHEN OTHERS THEN
        dbms_output.put_line('Error message' || sqlerrm);
            v_errormsg := v_errormsg
                          || '-'
                          || sqlerrm;
            temp_no := DM_data_trans_gen.control_log(v_srctble, v_targettbl, systimestamp, l_app_old, v_errormsg,
            'F', v_input_count, v_output_count);		
    END dm_corraddr_transformation;
END dm_data_trans_corraddress;

/
