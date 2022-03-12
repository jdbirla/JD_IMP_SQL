create or replace procedure Jd1dta.PV_CB_G1ZDCLTBNK(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
--VALPAZDCLPFCHK:1                                                
cursor  C_PAZDCLPF is
select refnum   from Jd1dta.dmigtitdmgclntbank A where not EXISTS (
  select b.zentity
  from pazdclpf B
  where
 substr(b.zentity,0,10) = trim(A.refnum) and b.prefix='CB'
  );


   TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin

 FOR REC_CLBAPF IN C_PAZDCLPF LOOP
          obj_DMPVALPF.Schedule_Name :=   i_schedulename;
          obj_DMPVALPF.schedule_num := i_schedulenumber;
        obj_DMPVALPF.refkey :=  REC_CLBAPF.REFNUM;    
        obj_DMPVALPF.reftab := 'PAZDCLPF';    
        obj_DMPVALPF.errmess01:= 'Not migrated Client bank';    
        obj_DMPVALPF.erorfld  := 'REFNUM'; 
        obj_DMPVALPF.fldvalue:= REC_CLBAPF.REFNUm; 
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
end PV_CB_G1ZDCLTBNK;
