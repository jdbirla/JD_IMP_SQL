/**************************************************************************************************************************
  * File Name        : PV_BL_G1ZDBILLRF
  * Author           : Srilakshmi Sriram
  * Creation Date    : Aug 21, 2020
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
  * 0707     KLP   PVR1  ZJNPG-9739, Changes on the cursor to improve performance 
  ********************************************************************************************************************************/

create or replace procedure PV_BL_G1ZDBILLRF(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
                                              
cursor  C_GBIHPF is
select DISTINCT A.CHDRNUM, A.TRANNO from  DMIGTITDMGREF1 A where not EXISTS (
  select 1
  from Jd1dta.GBIHPF B
  where
 trim(B.CHDRNUM) = TRIM(A.CHDRNUM) and B.TRANNO = A.TRANNO
 and a.PRBILFDT = b.PRBILFDT
 and b.BILLTYP = 'A'
  );
  
cursor  C_ZREPPF is
select DISTINCT A.CHDRNUM, A.ZREFMTCD, A.TRANNO from  DMIGTITDMGREF1 A where not EXISTS (
  select 1
  from Jd1dta.ZREPPF B
  where
 trim(B.CHDRNUM) = TRIM(A.CHDRNUM) and  trim(B.ZREFMTCD) = TRIM(A.ZREFMTCD)  and A.TRANNO = B.TRANNO
  );
  
cursor  C_ZRFDPF is
select DISTINCT  A.CHDRNUM, A.ZREFMTCD, A.TRANNO from  DMIGTITDMGREF1 A where not EXISTS (
  select 1
  from Jd1dta.ZRFDPF B
  where
 trim(B.CHDRNUM) = TRIM(A.CHDRNUM) and  trim(B.ZREFMTCD) = TRIM(A.ZREFMTCD)  and A.TRANNO = B.TRANNO
  );
 
 
/*cursor  C_GBIDPF is
select A.CHDRNUM, A.ZREFMTCD, A.PRODTYP,A.TRANNO from  DMIGTITDMGREF2 A where not EXISTS (
  select 1
  from Jd1dta.GBIDPF B, Jd1dta.GBIHPF C
  where trim(C.CHDRNUM) = TRIM(A.CHDRNUM) and   C.BILLNO = B.BILLNO 
  ) group by A.CHDRNUM, A.ZREFMTCD, A.PRODTYP,A.TRANNO;
*/

cursor  C_GBIDPF is
select DISTINCT A.CHDRNUM, A.ZREFMTCD, A.PRODTYP,A.TRANNO from  DMIGTITDMGREF2 A where not EXISTS (
  select 1
  from Jd1dta.GBIDPF B, Jd1dta.GBIHPF C
  where trim(C.CHDRNUM) = TRIM(A.CHDRNUM) and   C.BILLNO = B.BILLNO 
  AND A.TRANNO = C.TRANNO
  AND C.BILLTYP = 'A' 
  ) ;  
  
  
cursor  C_GPMDPF is
select DISTINCT A.CHDRNUM, A.PRODTYP, A.BPREM, A.TRANNO from  DMIGTITDMGREF2 A where not EXISTS (
  select 1
  from Jd1dta.GPMDPF B
  where
 trim(B.CHDRNUM) = TRIM(A.CHDRNUM) 
 and  trim(B.PRODTYP) = TRIM(A.PRODTYP) 
 and B.TRANNO = A.TRANNO 
 and A.BPREM = B.PPREM*-1
  );
  
  
  TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin

 --VALGBIHPFCHECK:1 
 FOR REC_GBIHPF IN C_GBIHPF LOOP
        obj_DMPVALPF.Schedule_Name :=   i_schedulename;
        obj_DMPVALPF.schedule_num := i_schedulenumber;
		obj_DMPVALPF.refkey :=  TRIM(REC_GBIHPF.CHDRNUM) || TRIM(REC_GBIHPF.TRANNO);   
        obj_DMPVALPF.reftab := 'GBIHPF';    
        obj_DMPVALPF.errmess01:= 'Refund Bill Not Migrated';    
        obj_DMPVALPF.erorfld  := 'CH-TN'; 
        obj_DMPVALPF.fldvalue:= TRIM(REC_GBIHPF.CHDRNUM) || TRIM(REC_GBIHPF.TRANNO); 
        obj_DMPVALPF.valdno:= 'VALGBIHPFCHECK:1'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
 END LOOP; 
 
  --VALZREPPFCHECK:2 
 FOR REC_ZREPPF IN C_ZREPPF LOOP
        obj_DMPVALPF.Schedule_Name :=   i_schedulename;
        obj_DMPVALPF.schedule_num := i_schedulenumber;
		obj_DMPVALPF.refkey :=  TRIM(REC_ZREPPF.CHDRNUM) || TRIM(REC_ZREPPF.ZREFMTCD) || REC_ZREPPF.TRANNO;   
        obj_DMPVALPF.reftab := 'ZREPPF';    
        obj_DMPVALPF.errmess01:= 'Refund Bill Not Migrated';    
        obj_DMPVALPF.erorfld  := 'CH-RMT-TN'; 
        obj_DMPVALPF.fldvalue:= TRIM(REC_ZREPPF.CHDRNUM) ||REC_ZREPPF.ZREFMTCD  ||REC_ZREPPF.TRANNO; 
        obj_DMPVALPF.valdno:= 'VALZREPPFCHECK:2'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
 END LOOP; 
   
   
  --VALZRFDPFCHECK:3 
 FOR REC_ZRFDPF IN C_ZRFDPF LOOP
        obj_DMPVALPF.Schedule_Name :=   i_schedulename;
        obj_DMPVALPF.schedule_num := i_schedulenumber;
		obj_DMPVALPF.refkey :=  TRIM(REC_ZRFDPF.CHDRNUM) || TRIM(REC_ZRFDPF.ZREFMTCD) || REC_ZRFDPF.TRANNO;  
        obj_DMPVALPF.reftab := 'ZRFDPF';    
        obj_DMPVALPF.errmess01:= 'Refund Bill Not Migrated';    
        obj_DMPVALPF.erorfld  := 'CH-RMT-TN'; 
        obj_DMPVALPF.fldvalue:= TRIM(REC_ZRFDPF.CHDRNUM)  ||REC_ZRFDPF.ZREFMTCD || TRIM(REC_ZRFDPF.TRANNO); 
        obj_DMPVALPF.valdno:= 'VALZRFDPFCHECK:3'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
 END LOOP; 
   
   
 --VALGBIDPFCHECK:4  
   
    FOR REC_GBIDPF IN C_GBIDPF LOOP
        obj_DMPVALPF.Schedule_Name :=   i_schedulename;
        obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  TRIM(REC_GBIDPF.CHDRNUM) || TRIM(REC_GBIDPF.PRODTYP) || REC_GBIDPF.TRANNO;      
        obj_DMPVALPF.reftab := 'GBIDPF';    
        obj_DMPVALPF.errmess01:= 'Refund Bill Not Migrated';    
        obj_DMPVALPF.erorfld  := 'CH-PDTY-TN'; 
        obj_DMPVALPF.fldvalue:= TRIM(REC_GBIDPF.CHDRNUM) ||  REC_GBIDPF.PRODTYP || REC_GBIDPF.TRANNO;        
		obj_DMPVALPF.valdno:= 'VALGBIDPFCHECK:4'; 
        obj_DMPVALPF.datime:= sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
		

   END LOOP; 
 
 --VALGBIHPFCHECK:5 
 FOR REC_GPMDPF IN C_GPMDPF LOOP
        obj_DMPVALPF.Schedule_Name :=   i_schedulename;
        obj_DMPVALPF.schedule_num := i_schedulenumber;
		obj_DMPVALPF.refkey :=  TRIM(REC_GPMDPF.CHDRNUM)|| TRIM(REC_GPMDPF.PRODTYP) || REC_GPMDPF.TRANNO;   
        obj_DMPVALPF.reftab := 'GPMDPF';    
        obj_DMPVALPF.errmess01:= 'Refund Bill Not Migrated';    
        obj_DMPVALPF.erorfld  := 'CH-PDTY-TN'; 
        obj_DMPVALPF.fldvalue:= TRIM(REC_GPMDPF.CHDRNUM)|| TRIM(REC_GPMDPF.PRODTYP) ||REC_GPMDPF.TRANNO; 
        obj_DMPVALPF.valdno:= 'VALGPMDPFCHECK:5'; 
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
end PV_BL_G1ZDBILLRF;