create or replace procedure Jd1dta.PV_CP_G1ZDPERCLT(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
--VALPAZDCLPFCHK:1                                                
cursor  C_PAZDCLPF is
select refnum   from Jd1dta.dmigtitdmgcltrnhis A where not EXISTS (
  select 1
  from pazdclpf B
  where
 trim(b.zentity) = trim(A.refnum) and b.prefix='CP'
  );
 

   TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin

 FOR REC_AGNPTF IN C_PAZDCLPF LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_AGNPTF.REFNUM;    
        obj_DMPVALPF.reftab := 'PAZDCLPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated personal client';    
        obj_DMPVALPF.erorfld  := 'REFNUM'; 
        obj_DMPVALPF.fldvalue:= REC_AGNPTF.REFNUm; 
        obj_DMPVALPF.valdno:= 'VALPAZDCLPFCHK:1'; 
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
end PV_CP_G1ZDPERCLT;
