--------------------------------------------------------
--  DDL for Procedure DM_SAVE_DROP_INDEX
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."DM_SAVE_DROP_INDEX" (p_detail_batch_id IN VARCHAR2) 
 AUTHID current_user AS
 /***************************************************************************************************
 * Amednment History: Save and Drop Index
 * Date    Initials   Tag   Decription
 * -----   --------   ---   ---------------------------------------------------------------------------
 * MMMDD    XXX       VN#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 * MAR09	MKS		  VN1   Initial Code
 * MAR10    JDB       VN2   Changes for Valida flag
 *****************************************************************************************************/
BEGIN

--delete existing index scripts
  DELETE FROM Jd1dta.dm_index_scripts WHERE jobname = p_detail_batch_id;
  COMMIT;

--Save Index meta_data
 
      INSERT INTO Jd1dta.dm_index_scripts (module_name, jobname, table_name, index_name, indx_script)
    SELECT b.module_name, b.jobname, b.target_table, b.index_name, to_char(DBMS_METADATA.GET_DDL ('INDEX', b.index_name, 'Jd1dta')) indx_script 
    FROM  Jd1dta.dm_target_tables b 
    WHERE b.jobname = p_detail_batch_id
    and b.valid_flg='1'
     AND EXISTS (SELECT 1 FROM all_indexes a WHERE a.owner= 'Jd1dta' AND a.uniqueness != 'UNIQUE' and a.index_name = b.index_name   and b.valid_flg='1');
  COMMIT;

--Drop Index
  FOR cur_rec IN (SELECT *  FROM all_indexes a WHERE a.owner= 'Jd1dta' AND a.uniqueness != 'UNIQUE' 
    AND EXISTS (SELECT 1 FROM Jd1dta.dm_target_tables b WHERE b.target_table = a.table_name and a.index_name = b.index_name AND b.jobname = p_detail_batch_id and b.valid_flg='1'))
  LOOP
    BEGIN
        EXECUTE IMMEDIATE 'DROP INDEX ' || cur_rec.owner || '.' || cur_rec.index_name ;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Issue in dropping index: ' || cur_rec.index_name);
    END;
  END LOOP;

END;

/