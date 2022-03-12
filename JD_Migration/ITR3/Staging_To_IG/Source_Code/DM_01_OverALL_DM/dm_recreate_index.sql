--------------------------------------------------------
--  DDL for Procedure DM_RECREATE_INDEX
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."DM_RECREATE_INDEX" (p_detail_batch_id IN VARCHAR2) 
 AUTHID current_user AS
 /***************************************************************************************************
 * Amednment History: Save and Drop Index
 * Date    Initials   Tag   Decription
 * -----   --------   ---   ---------------------------------------------------------------------------
 * MMMDD    XXX       VN#   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 * MAR09	MKS		  VN1   Initial Code
 * MAR10    JDB       VN2   Changes for REPLACE
 *****************************************************************************************************/
v_ddlquery varchar2(2000);
BEGIN

  FOR cur_rec IN (SELECT * from dm_index_scripts WHERE jobname = p_detail_batch_id)
  LOOP
    BEGIN
 
     -- v_ddlquery := REPLACE(cur_rec.indx_script, ';');
    ---  dbms_output.put_line('v_ddlquery: ' || v_ddlquery);

    EXECUTE IMMEDIATE  REPLACE(cur_rec.indx_script, ';');
   
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Issue in creating index: ' || cur_rec.index_name || sqlerrm);
    END;
  END LOOP;

END;

/