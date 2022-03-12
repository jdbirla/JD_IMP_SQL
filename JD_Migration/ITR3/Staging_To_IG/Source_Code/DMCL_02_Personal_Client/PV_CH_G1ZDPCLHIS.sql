create or replace procedure Jd1dta.PV_CH_G1ZDPCLHIS(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
--VALPAZDCHPFCHK:1                                                
cursor  C_PAZDCHPF is
select refnum   from Jd1dta.dmigtitdmgcltrnhis A where not EXISTS (
  select 1
  from Jd1dta.pazdchpf B
  where
 trim(b.zentity) = trim(A.refnum)
  );

 --VALPAZDCHPFCHK:2
 cursor  C_ZCLNPF is
 select * from (select distinct (zigvalue) from  pazdchpf  where zentity IN (select distinct (refnum)   from dmigtitdmgcltrnhis)) A where not  EXISTS (
  select 1
  from zclnpf B
  where
 trim(A.zigvalue) = trim(b.clntnum)
  );


   TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin

 FOR REC_PAZDCHPF IN C_PAZDCHPF LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_PAZDCHPF.REFNUM;    
        obj_DMPVALPF.reftab := 'PAZDCHPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated personal client History';    
        obj_DMPVALPF.erorfld  := 'REFNUM'; 
        obj_DMPVALPF.fldvalue:= REC_PAZDCHPF.REFNUm; 
        obj_DMPVALPF.valdno:= 'VALPAZDCHPFCHK:1'; 
        obj_DMPVALPF.datime:= sysdate; 

        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;


   END LOOP; 

    FOR REC_ZCLNPF IN C_ZCLNPF LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_ZCLNPF.ZIGVALUE;    
        obj_DMPVALPF.reftab := 'PAZDCHPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated personal client in ZCLNPF';    
        obj_DMPVALPF.erorfld  := 'CLNTNUM'; 
        obj_DMPVALPF.fldvalue:= REC_ZCLNPF.ZIGVALUE; 
        obj_DMPVALPF.valdno:= 'VALPAZDCHPFCHK:2'; 
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
end PV_CH_G1ZDPCLHIS;
