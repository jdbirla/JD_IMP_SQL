--------------------------------------------------------
--  File created - Wednesday-July-07-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure PV_MP_G1ZDMSTPOL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."PV_MP_G1ZDMSTPOL" (i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
--VALAGNTPFCHECK:1                                                
cursor  C_GCDH is
select
      RECIDXMPMSPOL
from
      Jd1dta.DMIGTITDMGMASPOL A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.gchd B
        where
             B.chdrnum = 
             CASE WHEN LENGTH(A.chdrnum) = 11 THEN SUBSTR(A.chdrnum,4,8)
                  ELSE A.chdrnum
             END
         and A.ind in ('I')
      );


cursor  C_GCHIPF is
select
      RECIDXMPMSPOL
from
      Jd1dta.DMIGTITDMGMASPOL A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.gchipf B
        where
             B.chdrnum =
             CASE WHEN LENGTH(A.chdrnum) = 11 THEN SUBSTR(A.chdrnum,4,8)
                  ELSE A.chdrnum
             END
         and A.ind in ('I')

             );

cursor  C_GCHPPF is
select
      RECIDXMPMSPOL
from
      Jd1dta.DMIGTITDMGMASPOL A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.gchppf B
        where
             B.chdrnum =
             CASE WHEN LENGTH(A.chdrnum) = 11 THEN SUBSTR(A.chdrnum,4,8)
                  ELSE A.chdrnum
             END
         and A.ind in ('I')

             );

cursor  C_ZENCTPF is
select
      RECIDXMPMSPOL
from
      Jd1dta.DMIGTITDMGMASPOL A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.zenctpf B
        where
             trim(B.zpolnmbr) = 
             CASE WHEN LENGTH(A.chdrnum) = 11 THEN SUBSTR(A.chdrnum,4,8)
                  ELSE A.chdrnum
             END
         and A.ind in ('I')

             );


cursor  C_ZTGMPF is
select
      RECIDXMPMSPOL
from
      Jd1dta.DMIGTITDMGMASPOL A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.ztgmpf B
        where
             B.chdrnum =
             CASE WHEN LENGTH(A.chdrnum) = 11 THEN SUBSTR(A.chdrnum,4,8)
                  ELSE A.chdrnum
             END
         and A.ind in ('I')

             );

cursor  C_ZTRAPF is
select
      RECIDXMPMSPOL
from
      Jd1dta.DMIGTITDMGMASPOL A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.ztrapf B
        where
             B.chdrnum =
             CASE WHEN LENGTH(A.chdrnum) = 11 THEN SUBSTR(A.chdrnum,4,8)
                  ELSE A.chdrnum
             END
         and A.ind in ('I')

             );

cursor  C_CLRRPF is
select
      RECIDXMPMSPOL
from
      Jd1dta.DMIGTITDMGMASPOL A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.clrrpf B
        where
             Rtrim(B.forenum) =
             CASE WHEN LENGTH(A.chdrnum) = 11 THEN SUBSTR(A.chdrnum,4,8)
                  ELSE A.chdrnum
             END
         and A.ind in ('I')

             );

cursor  C_AUDIT_CLRRPF is
select
      RECIDXMPMSPOL
from
      Jd1dta.DMIGTITDMGMASPOL A
where
     not EXISTS
      (
        select
              1
        from
              Jd1dta.audit_clrrpf B
        where
             Rtrim(B.newforenum) =
             CASE WHEN LENGTH(A.chdrnum) = 11 THEN SUBSTR(A.chdrnum,4,8)
                  ELSE A.chdrnum
             END
         and A.ind in ('I')

             );

   TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
    idx PLS_INTEGER;

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin

  delete from Jd1dta.VIEW_DM_DMPVALPF;

  FOR REC_GCDH IN C_GCDH LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_GCDH.RECIDXMPMSPOL;    
      obj_DMPVALPF.reftab := 'GCDH';    
      obj_DMPVALPF.errmess01:= 'Not migrated master policy';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_GCDH.RECIDXMPMSPOL; 
      obj_DMPVALPF.valdno := 'VALGCDHCHECK:1'; 
      obj_DMPVALPF.datime := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 

  FOR REC_GCHIPF IN C_GCHIPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_GCHIPF.RECIDXMPMSPOL;    
      obj_DMPVALPF.reftab := 'GCHIPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated master policy';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_GCHIPF.RECIDXMPMSPOL;
      obj_DMPVALPF.valdno := 'VALGCHIPFCHECK:2'; 
      obj_DMPVALPF.datime := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 

  FOR REC_GCHPPF IN C_GCHPPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_GCHPPF.RECIDXMPMSPOL;    
      obj_DMPVALPF.reftab := 'GCHPPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated master policy';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_GCHPPF.RECIDXMPMSPOL;
      obj_DMPVALPF.valdno := 'VALGCHPPFCHECK:3'; 
      obj_DMPVALPF.datime := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

  FOR REC_ZENCTPF IN C_ZENCTPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_ZENCTPF.RECIDXMPMSPOL;    
      obj_DMPVALPF.reftab := 'ZENCTPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated master policy';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_ZENCTPF.RECIDXMPMSPOL;
      obj_DMPVALPF.valdno := 'VALZENCTPFCHECK:4'; 
      obj_DMPVALPF.datime := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;


  FOR REC_ZTGMPF IN C_ZTGMPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_ZTGMPF.RECIDXMPMSPOL;    
      obj_DMPVALPF.reftab := 'ZTGMPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated master policy';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_ZTGMPF.RECIDXMPMSPOL;
      obj_DMPVALPF.valdno := 'VALZTGMPFCHECK:5'; 
      obj_DMPVALPF.datime := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

  FOR REC_ZTRAPF IN C_ZTRAPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_ZTRAPF.RECIDXMPMSPOL;    
      obj_DMPVALPF.reftab := 'ZTRAPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated master policy';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_ZTRAPF.RECIDXMPMSPOL;
      obj_DMPVALPF.valdno := 'VALZTRAPFCHECK:6'; 
      obj_DMPVALPF.datime := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

  FOR REC_CLRRPF IN C_CLRRPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_CLRRPF.RECIDXMPMSPOL;    
      obj_DMPVALPF.reftab := 'CLRRPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated master policy';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_CLRRPF.RECIDXMPMSPOL;
      obj_DMPVALPF.valdno := 'VALCLRRPFCHECK:7'; 
      obj_DMPVALPF.datime := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

  FOR REC_AUDIT_CLRRPF IN C_AUDIT_CLRRPF LOOP
      obj_DMPVALPF.Schedule_Name :=   i_schedulename;
      obj_DMPVALPF.schedule_num := i_schedulenumber;
      obj_DMPVALPF.refkey :=  REC_AUDIT_CLRRPF.RECIDXMPMSPOL;    
      obj_DMPVALPF.reftab := 'AUDIT_CLRRPF';    
      obj_DMPVALPF.errmess01:= 'Not migrated master policy';    
      obj_DMPVALPF.erorfld  := 'RECIDXCLCO'; 
      obj_DMPVALPF.fldvalue:= REC_AUDIT_CLRRPF.RECIDXMPMSPOL;
      obj_DMPVALPF.valdno := 'VALAUDIT_CLRRPFCHECK:8'; 
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
end PV_MP_G1ZDMSTPOL;

/
