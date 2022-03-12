/**************************************************************************************************************************
  * File Name        : PV_CM_G1ZDCAMPCD
  * Author           : Srilakshmi Sriram
  * Creation Date    : March 30, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This Procedure for post migration validation
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amenment History: DMAG-01
  * Date    Init   Tag   Decription
  * -----   -----  ---   ---------------------------------------------------------------------------
  * MMMDD    XXX   MB1   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 0330     SRI   CM1   New developed in PA
  
  ********************************************************************************************************************************/

create or replace procedure PV_CM_G1ZDCAMPCD(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
--VALZCPNPFCHECK:1                                                
cursor  C_ZCPNPF is
select substr(TRIM(ZCMPCODE),1,5)||'0' as ZCMPCODE from  TITDMGCAMPCDE@DMSTAGEDBLINK A where not EXISTS (
  select 1
  from zcpnpf B
  where
 trim(B.ZCMPCODE) = substr(TRIM(A.ZCMPCODE),1,5)||'0'
  );
 
  
  cursor  C_ZCSLPF is
  select substr(TRIM(ZCMPCODE),1,5)||'0' as ZCMPCODE from TITDMGZCSLPF@DMSTAGEDBLINK A where not EXISTS (
  select 1          
  from Jd1dta.ZCSLPF B
  where
 trim(B.ZCMPCODE) = substr(TRIM(A.ZCMPCODE),1,5)||'0' 
  ) and trim(A.ZCMPCODE) NOT like 'C%';
  
  TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin
  
 FOR REC_ZCPNPF IN C_ZCPNPF LOOP
        obj_DMPVALPF.Schedule_Name :=   i_schedulename;
        obj_DMPVALPF.schedule_num := i_schedulenumber;
		obj_DMPVALPF.refkey :=  REC_ZCPNPF.ZCMPCODE;   
        obj_DMPVALPF.reftab := 'ZCPNPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated Campaign Code';    
        obj_DMPVALPF.erorfld  := 'ZCMPCODE'; 
        obj_DMPVALPF.fldvalue:= REC_ZCPNPF.ZCMPCODE; 
        obj_DMPVALPF.valdno:= 'VALZCPNPFCHECK:1'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
   
 --VALZCSLPFCHECK:2   
   
    FOR REC_ZCSLPF IN C_ZCSLPF LOOP
        obj_DMPVALPF.Schedule_Name :=   i_schedulename;
        obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_ZCSLPF.ZCMPCODE;    
        obj_DMPVALPF.reftab := 'ZCSLPF';    
        obj_DMPVALPF.errmess01:= 'ZCMPCODE is Not Migrated for Campaign - Sales Plan Link Table';    
        obj_DMPVALPF.erorfld  := 'ZCMPCODE'; 
        obj_DMPVALPF.fldvalue:= REC_ZCSLPF.ZCMPCODE; 
        obj_DMPVALPF.valdno:= 'VALZCSLPFCHECK:2'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
   
   
		 idx := DMPVALPF_list.first;
  IF (idx IS NOT NULL) THEN
    FORALL idx IN DMPVALPF_list.first .. DMPVALPF_list.last
      INSERT  /*+ APPEND_VALUES */    INTO Jd1dta.VIEW_DM_DMPVALPF VALUES DMPVALPF_list (idx);

  END IF;
   
  DMPVALPF_list.delete;
   DMPVALPFindex  := 0;
commit;
end PV_CM_G1ZDCAMPCD;