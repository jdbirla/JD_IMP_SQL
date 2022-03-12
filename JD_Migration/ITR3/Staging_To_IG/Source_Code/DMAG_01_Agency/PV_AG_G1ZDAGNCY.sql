/**************************************************************************************************************************
  * File Name        : PV_AG_G1ZDAGNCY
  * Author           : Jitendra Birla
  * Creation Date    : March 16, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This Procedure for post migration validation
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMAG-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0311     JDB   AG1   New developed in PA
  
  ********************************************************************************************************************************/

create or replace procedure Jd1dta.PV_AG_G1ZDAGNCY(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
--VALAGNTPFCHECK:1                                                
cursor  C_AGNTPF is
select ZAREFNUM   from Jd1dta.dmigtitdmgagentpj A where not EXISTS (
  select 1
  from agntpf B
  where
 trim(B.agntnum) = trim(A.ZAREFNUM)
  );
 cursor  C_agplpf is
select ZAREFNUM   from  Jd1dta.dmigtitdmgagentpj A where not EXISTS (
  select 1
  from Jd1dta.agplpf B
  where
 trim(B.agntnum) = trim(A.ZAREFNUM)
  );
 cursor C_ZACRPF IS
  select ZAREFNUM  from  Jd1dta.dmigtitdmgagentpj A where not EXISTS (
  select 1
  from Jd1dta.zacrpf B
  where
 trim(B.GAGNTSEL) = trim(A.ZAREFNUM)
  );
  
  cursor  C_clrrpf is
  select ZAREFNUM   from  Jd1dta.dmigtitdmgagentpj A where not EXISTS (
  select 1          
  from Jd1dta.clrrpf B
  where
 trim(B.forenum) = trim(A.ZAREFNUM)
  );
  
   TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin
  
 FOR REC_AGNPTF IN C_AGNTPF LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_AGNPTF.ZAREFNUM;    
        obj_DMPVALPF.reftab := 'AGNTPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated agent';    
        obj_DMPVALPF.erorfld  := 'ZAREFNUM'; 
        obj_DMPVALPF.fldvalue:= REC_AGNPTF.ZAREFNUM; 
        obj_DMPVALPF.valdno:= 'VALAGNTPFCHECK:1'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
   
    FOR REC_AGPLPF IN C_agplpf LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_AGPLPF.ZAREFNUM;    
        obj_DMPVALPF.reftab := 'AGPLPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated agent';    
        obj_DMPVALPF.erorfld  := 'ZAREFNUM'; 
        obj_DMPVALPF.fldvalue:= REC_AGPLPF.ZAREFNUM; 
        obj_DMPVALPF.valdno:= 'VALAGPLPFCHECK:2'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
   
    FOR REC_ZACRPF IN C_ZACRPF LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_ZACRPF.ZAREFNUM;    
        obj_DMPVALPF.reftab := 'ZACRPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated agent';    
        obj_DMPVALPF.erorfld  := 'ZAREFNUM'; 
        obj_DMPVALPF.fldvalue:= REC_ZACRPF.ZAREFNUM; 
        obj_DMPVALPF.valdno:= 'VALZACRPFCHECK:3'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
   
    FOR REC_clrrpf  IN C_clrrpf LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_clrrpf.ZAREFNUM;    
        obj_DMPVALPF.reftab := 'CLRRPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated agent';    
        obj_DMPVALPF.erorfld  := 'ZAREFNUM'; 
        obj_DMPVALPF.fldvalue:= REC_clrrpf.ZAREFNUM; 
        obj_DMPVALPF.valdno:= 'VALCLRRPFCHECK:4'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
  Delete Jd1dta.VIEW_DM_DMPVALPF where SCHEDULE_NAME = i_schedulename;

		 idx := DMPVALPF_list.first;
  IF (idx IS NOT NULL) THEN
    FORALL idx IN DMPVALPF_list.first .. DMPVALPF_list.last
      INSERT  /*+ APPEND_VALUES */    INTO Jd1dta.VIEW_DM_DMPVALPF VALUES DMPVALPF_list (idx);

  END IF;
   
  DMPVALPF_list.delete;
   DMPVALPFindex  := 0;
commit;
end PV_AG_G1ZDAGNCY;