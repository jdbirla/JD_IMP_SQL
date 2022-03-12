/**************************************************************************************************************************
  * File Name        : PV_CC_G1ZDCOPCLT
  * Author           : Takashi Hodumi
  * Creation Date    : April 06, 2020
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

create or replace procedure PV_CC_G1ZDCOPCLT(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
--VALAGNTPFCHECK:1                                                
cursor  C_CLNTPF is
select
      RECIDXCLCORP
from
      Jd1dta.DMIGTITDMGCLNTCORP A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.clntpf B
        where
             trim(B.clntnum) = trim(A.clntnum)
         and A.ind in ('I','U')
      );
      

cursor  C_AUDIT_CLNTPF is
select
      RECIDXCLCORP
from
      Jd1dta.DMIGTITDMGCLNTCORP A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.audit_clntpf B
        where
             trim(B.newclntnum) = trim(A.clntnum)
         and A.ind in ('I','U')
             
             );
             
cursor  C_CLEXPF is             
select
      RECIDXCLCORP
from
      Jd1dta.DMIGTITDMGCLNTCORP A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.clexpf B
        where
             trim(B.clntnum) = trim(A.clntnum)
         and A.ind in ('I','U')
             
             );   
                       
cursor  C_AUDIT_CLEXPF is              
select
      RECIDXCLCORP
from
      Jd1dta.DMIGTITDMGCLNTCORP A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.audit_clexpf B
        where
             trim(B.newclntnum) = trim(A.clntnum)
         and A.ind in ('I','U')
             
             ); 

cursor  C_AUDIT_CLNT is
select
      RECIDXCLCORP
from
      Jd1dta.DMIGTITDMGCLNTCORP A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.audit_clnt B
        where
             trim(B.clntnum) = trim(A.clntnum)
         and A.ind in ('I','U')
             
             );
cursor  C_VIEW_ZCLNPF is
select
      RECIDXCLCORP
from
      Jd1dta.DMIGTITDMGCLNTCORP A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.view_zclnpf B
        where
             trim(B.clntnum) = trim(A.clntnum)
         and A.ind in ('I','U')
             
             );

  
   TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin
  
  delete from Jd1dta.VIEW_DM_DMPVALPF;
  
  FOR REC_CLNTPF IN C_CLNTPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_CLNTPF.RECIDXCLCORP;    
      obj_DMPVALPF.reftab := 'CLNTPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated corp client';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_CLNTPF.RECIDXCLCORP; 
      obj_DMPVALPF.valdno := 'VALACLNTPFCHECK:1'; 
      obj_DMPVALPF.datime := sysdate; 
      
      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 
   
  FOR REC_AUDIT_CLNTPF IN C_AUDIT_CLNTPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_AUDIT_CLNTPF.RECIDXCLCORP;    
      obj_DMPVALPF.reftab := 'AUDIT_CLNTPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated corp client';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_AUDIT_CLNTPF.RECIDXCLCORP;
      obj_DMPVALPF.valdno := 'VALAUDIT_CLNTPFCHECK:2'; 
      obj_DMPVALPF.datime := sysdate; 
      
      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 

  FOR REC_CLEXPF IN C_CLEXPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_CLEXPF.RECIDXCLCORP;    
      obj_DMPVALPF.reftab := 'CLEXPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated corp client';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_CLEXPF.RECIDXCLCORP;
      obj_DMPVALPF.valdno := 'VALCLEXPFCHECK:3'; 
      obj_DMPVALPF.datime := sysdate; 
      
      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

  FOR REC_AUDIT_CLEXPF IN C_AUDIT_CLEXPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_AUDIT_CLEXPF.RECIDXCLCORP;    
      obj_DMPVALPF.reftab := 'AUDIT_CLEXP';    
      obj_DMPVALPF.errmess01:= 'Not migrated corp client';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_AUDIT_CLEXPF.RECIDXCLCORP;
      obj_DMPVALPF.valdno := 'VALAUDIT_CLEXPFCHECK:4'; 
      obj_DMPVALPF.datime := sysdate; 
      
      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;


  FOR REC_AUDIT_CLNT IN C_AUDIT_CLNT LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_AUDIT_CLNT.RECIDXCLCORP;    
      obj_DMPVALPF.reftab := 'AUDIT_CLNT';    
      obj_DMPVALPF.errmess01:= 'Not migrated corp client';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_AUDIT_CLNT.RECIDXCLCORP;
      obj_DMPVALPF.valdno := 'VALAUDIT_CLNTFCHECK:5'; 
      obj_DMPVALPF.datime := sysdate; 
      
      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

  FOR REC_VIEW_ZCLNPF IN C_VIEW_ZCLNPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_VIEW_ZCLNPF.RECIDXCLCORP;    
      obj_DMPVALPF.reftab := 'VIEW_ZCLNPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated corp client';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_VIEW_ZCLNPF.RECIDXCLCORP;
      obj_DMPVALPF.valdno := 'VALVIEW_ZCLNPFCHECK:6'; 
      obj_DMPVALPF.datime := sysdate; 
      
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
end PV_CC_G1ZDCOPCLT;