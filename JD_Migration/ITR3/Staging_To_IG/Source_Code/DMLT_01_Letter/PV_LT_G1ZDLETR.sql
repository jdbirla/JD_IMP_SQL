/**************************************************************************************************************************
  * File Name        : PV_LT_G1ZDLETR
  * Author           : Bhupendra Singh
  * Creation Date    : Agu 10, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This Procedure for post migration validation
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMLT-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0311     JDB   LT1   New developed in PA
  
  ********************************************************************************************************************************/
CREATE OR REPLACE PROCEDURE Jd1dta.pv_lt_g1zdletr (
        i_schedulename     IN                 VARCHAR2,
        i_schedulenumber   IN                 VARCHAR2
) IS
    
--VALAGNTPFCHECK:1          

        CURSOR c_letcpf IS
        SELECT
                chdrnum
        FROM
                titdmgletter@dmstagedblink a
        WHERE
                NOT EXISTS (
                        SELECT
                                1
                        FROM
                                letcpf b
                        WHERE
                                TRIM(b.chdrnum) = TRIM(a.chdrnum)
                                AND TRIM(b.lettype) = TRIM(a.lettype)
                                AND TRIM(b.lreqdate) = TRIM(a.lreqdate)
                                AND TRIM(b.zletvern) = TRIM(a.zletvern)
                );

        TYPE dmpvalpf_type IS
                TABLE OF view_dm_dmpvalpf%rowtype;
        dmpvalpf_list   dmpvalpf_type := dmpvalpf_type();
        dmpvalpfindex   INTEGER := 0;
        idx             PLS_INTEGER;
        obj_dmpvalpf    view_dm_dmpvalpf%rowtype;
BEGIN
        FOR rec_letcpf IN c_letcpf LOOP
                obj_dmpvalpf.schedule_name := i_schedulename;
                obj_dmpvalpf.schedule_num := i_schedulenumber;
                obj_dmpvalpf.refkey := rec_letcpf.chdrnum;
                obj_dmpvalpf.reftab := 'LETCPF';
                obj_dmpvalpf.errmess01 := 'Not migrated Letter';
                obj_dmpvalpf.erorfld := 'CHDRNUM';
                obj_dmpvalpf.fldvalue := rec_letcpf.chdrnum;
                obj_dmpvalpf.valdno := 'VALLETCPFCHECK:1';
                obj_dmpvalpf.datime := SYSDATE;
                dmpvalpfindex := dmpvalpfindex + 1;
                dmpvalpf_list.extend;
                dmpvalpf_list(dmpvalpfindex) := obj_dmpvalpf;
        END LOOP;
		
		 --Delete previous re
  DELETE Jd1dta.VIEW_DM_DMPVALPF WHERE SCHEDULE_NAME = i_schedulename;

        idx := dmpvalpf_list.first;
        IF ( idx IS NOT NULL ) THEN
                FORALL idx IN dmpvalpf_list.first..dmpvalpf_list.last
                        INSERT  /*+ APPEND_VALUES */ INTO Jd1dta.view_dm_dmpvalpf VALUES dmpvalpf_list ( idx );

        END IF;

        dmpvalpf_list.DELETE;
        dmpvalpfindex := 0;
        COMMIT;
END pv_lt_g1zdletr;