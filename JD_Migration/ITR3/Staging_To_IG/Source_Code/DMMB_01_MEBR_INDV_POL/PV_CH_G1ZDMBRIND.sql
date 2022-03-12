CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."PV_CH_G1ZDMBRIND" (i_schedulename   IN VARCHAR2,
                                             i_schedulenumber in varchar2) is

  --VALPAZDRPPFCHK:1                                                
  cursor C_PAZDRPPF is
      select a.refnum, a.zinsrole
      from Jd1dta.dmigtitdmgmbrindp1 A
     where not EXISTS (select 1
              from Jd1dta.pazdrppf B
             where TRIM(b.chdrnum) = A.refnum
               and a.zinsrole = b.zinsrole);

  --VALPAZDRPPFCHK:2                                               
  cursor C_gchd is
    select DISTINCT (a.refnum)
      from Jd1dta.dmigtitdmgmbrindp1 A
     where not EXISTS
     (select 1
              from Jd1dta.gchd B
             where TRIM(b.chdrnum) = substr(A.refnum, 1, 8));

  cursor C_GCHPPF is

    select DISTINCT (a.refnum)
      from Jd1dta.dmigtitdmgmbrindp1 A
     where not EXISTS
     (select 1
              from Jd1dta.GCHPPF B
             where TRIM(b.chdrnum) = substr(A.refnum, 1, 8));

  cursor C_GCHIPF is

    select DISTINCT (a.refnum)
      from Jd1dta.dmigtitdmgmbrindp1 A
     where not EXISTS
     (select 1
              from Jd1dta.GCHIPF B
             where TRIM(b.chdrnum) = substr(A.refnum, 1, 8));

  cursor C_ZCLEPF is
   SELECT
    /*+ PARALLEL (t1, 8) */ t1.*
FROM
    (
        SELECT
            a.refnum,
            a.clientno,
            b.zigvalue,
            a.client_category,
            a.zendcde,
            a.zenspcd01,
            a.zenspcd02,
            a.zcifcode
        FROM
          (select refnum,
            clientno,
        client_category,
        zendcde,
        zenspcd01,
        zenspcd02,
            zcifcode   from Jd1dta.dmigtitdmgmbrindp1 where (RTRIM(zenspcd01) is not null or
                   RTRIM(zenspcd02) is not null or
                   RTRIM(ZCIFCODE) is not null) )  a
            INNER JOIN pazdclpf                    b ON a.clientno = b.zentity
        INNER JOIN pazdrppf C  on a.refnum= C.chdrnum  
    ) t1 WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            Jd1dta.zclepf t2 WHERE
            t1.zigvalue = t2.clntnum
            AND ( (RTRIM(t1.zenspcd01) = RTRIM(t2.zenspcd01) )
                  OR ( RTRIM(t1.zenspcd02) = RTRIM(t2.zenspcd02) )
                  OR ( RTRIM(t1.zcifcode) = RTRIM(t2.zcifcode) ) )
    );


  cursor C_zcelinkpf is
    select *
      from (select A.refnum, A.clientno, b.zigvalue, A.client_category
              from Jd1dta.dmigtitdmgmbrindp1 A
             Inner join PAZDCLPF B
                on A.clientno = B.Zentity) T1
     where not EXISTS
     (select 1 from Jd1dta.zcelinkpf T2 where T1.zigvalue = T2.clntnum);

  cursor C_clrrpf is
    select *
      from (select A.refnum, A.clientno, b.zigvalue, a.zinsrole
              from Jd1dta.dmigtitdmgmbrindp1 A
             Inner join PAZDCLPF B
                on A.clientno = B.Zentity) T1
     where not EXISTS
     (select 1
              from Jd1dta.clrrpf T2
             where T1.zigvalue = T2.clntnum
               and substr(t1.refnum, 1, 8) = TRIM(t2.forenum));
  cursor C_audit_clrrpf is
    select *
      from (select A.refnum, A.clientno, b.zigvalue, a.zinsrole
              from Jd1dta.dmigtitdmgmbrindp1 A
             Inner join PAZDCLPF B
                on A.clientno = B.Zentity) T1
     where not EXISTS
     (select 1
              from Jd1dta.audit_clrrpf T2
             where T1.zigvalue = T2.newclntnum
               and substr(t1.refnum, 1, 8) = TRIM(t2.newforenum));

  cursor C_GMHDPF is
    select *
      from (select a.refnum, a.zinsrole, a.mbrno
              from Jd1dta.dmigtitdmgmbrindp1 A
             where client_category = '1') T1
     where not EXISTS (select 1
              from Jd1dta.GMHDPF T2
             where TRIM(T2.chdrnum) = substr(T1.refnum, 1, 8)
               and T1.mbrno = substr(T2.mbrno, 4, 2));

  cursor C_GMHIPF is
    select *
      from (select a.refnum, a.zinsrole, a.mbrno
              from Jd1dta.dmigtitdmgmbrindp1 A
             where client_category = '1') T1
     where not EXISTS (select 1
              from Jd1dta.GMHIPF T2
             where TRIM(T2.chdrnum) = substr(T1.refnum, 1, 8)
               and T1.mbrno = substr(T2.mbrno, 4, 2));
  TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  DMPVALPFindex integer := 0;
  idx           PLS_INTEGER;

  obj_DMPVALPF VIEW_DM_DMPVALPF%rowtype;
begin
  execute IMMEDIATE 'DROP index pazdclpf_idx1';
execute IMMEDIATE 'DROP index pazdrppf_idx1';
execute IMMEDIATE 'DROP index dmigtitdmgmbrindp1_idx1';
execute IMMEDIATE 'DROP index dmigtitdmgmbrindp1_idx2';
execute IMMEDIATE 'DROP index dmigtitdmgmbrindp1_idx3';
execute IMMEDIATE 'DROP index DM_zclepf_idx1';
execute IMMEDIATE 'DROP index DM_zclepf_idx2';
execute IMMEDIATE 'DROP index DM_zclepf_idx3';

execute IMMEDIATE 'CREATE INDEX pazdclpf_idx1 ON Jd1dta.pazdclpf (zentity)';
execute IMMEDIATE 'CREATE INDEX pazdrppf_idx1 ON Jd1dta.pazdrppf (chdrnum)';
execute IMMEDIATE 'CREATE INDEX DM_zclepf_idx1 ON Jd1dta.zclepf ( RTRIM(zenspcd01))';
execute IMMEDIATE 'CREATE INDEX DM_zclepf_idx2 ON Jd1dta.zclepf ( RTRIM(zenspcd02))';
execute IMMEDIATE 'CREATE INDEX DM_zclepf_idx3 ON Jd1dta.zclepf ( RTRIM(zcifcode))';
execute IMMEDIATE 'CREATE INDEX dmigtitdmgmbrindp1_idx1 ON Jd1dta.dmigtitdmgmbrindp1 ( RTRIM(zenspcd01))';
execute IMMEDIATE 'CREATE INDEX dmigtitdmgmbrindp1_idx2 ON Jd1dta.dmigtitdmgmbrindp1 ( RTRIM(zenspcd02))';
execute IMMEDIATE 'CREATE INDEX dmigtitdmgmbrindp1_idx3 ON Jd1dta.dmigtitdmgmbrindp1 ( RTRIM(zcifcode))';

  FOR REC_PAZDRPPF IN C_PAZDRPPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_PAZDRPPF.REFNUM;
    obj_DMPVALPF.reftab        := 'PAZDRPPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Member policy';
    obj_DMPVALPF.erorfld       := 'REFNUM';
    obj_DMPVALPF.fldvalue      := REC_PAZDRPPF.REFNUM || ' - ' ||
                                  REC_PAZDRPPF.ZINSROLE;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:1';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;

  FOR REC_GCHD IN C_GCHD LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_GCHD.refnum;
    obj_DMPVALPF.reftab        := 'GCHD';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in GCHD';
    obj_DMPVALPF.erorfld       := 'CHDRNUM';
    obj_DMPVALPF.fldvalue      := REC_GCHD.refnum;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:2';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;

  FOR REC_GCHPPF IN C_GCHPPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_GCHPPF.refnum;
    obj_DMPVALPF.reftab        := 'GCHPPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in GCHPPF';
    obj_DMPVALPF.erorfld       := 'CHDRNUM';
    obj_DMPVALPF.fldvalue      := REC_GCHPPF.refnum;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:3';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;

  FOR REC_GCHIPF IN C_GCHIPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_GCHIPF.refnum;
    obj_DMPVALPF.reftab        := 'GCHIPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in GCHIPF';
    obj_DMPVALPF.erorfld       := 'CHDRNUM';
    obj_DMPVALPF.fldvalue      := REC_GCHIPF.refnum;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:4';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;

  FOR REC_ZCLEPF IN C_ZCLEPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_ZCLEPF.REFNUM;
    obj_DMPVALPF.reftab        := 'ZCELPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in ZCLEPF';
    obj_DMPVALPF.erorfld       := 'CLIENTNO';
    obj_DMPVALPF.fldvalue      := REC_ZCLEPF.REFNUM || ' - ' ||
                                  REC_ZCLEPF.Clientno;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:5';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;

  FOR REC_zcelinkpf IN C_zcelinkpf LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_zcelinkpf.REFNUM;
    obj_DMPVALPF.reftab        := 'ZCELINKPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in zcelinkpf';
    obj_DMPVALPF.erorfld       := 'CLIENTNO';
    obj_DMPVALPF.fldvalue      := REC_zcelinkpf.REFNUM || ' - ' ||
                                  REC_zcelinkpf.Clientno;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:6';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;

  FOR REC_CLRRPF IN C_CLRRPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_CLRRPF.refnum;
    obj_DMPVALPF.reftab        := 'CLRRPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in CLRRPF';
    obj_DMPVALPF.erorfld       := 'CHDRNUM';
    obj_DMPVALPF.fldvalue      := REC_CLRRPF.Refnum || ' - ' ||
                                  REC_CLRRPF.Clientno;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:7';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;

  FOR REC_AUDIT_CLRRPF IN C_AUDIT_CLRRPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_AUDIT_CLRRPF.refnum;
    obj_DMPVALPF.reftab        := 'AUDIT_CLRRPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in AUDIT_CLRRPF';
    obj_DMPVALPF.erorfld       := 'CHDRNUM';
    obj_DMPVALPF.fldvalue      := REC_AUDIT_CLRRPF.Refnum || ' - ' ||
                                  REC_AUDIT_CLRRPF.Clientno;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:8';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;

  FOR REC_GMHDPF IN C_GMHDPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_GMHDPF.refnum;
    obj_DMPVALPF.reftab        := 'GMHDPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in GMHDPF';
    obj_DMPVALPF.erorfld       := 'CHDRNUM';
    obj_DMPVALPF.fldvalue      := REC_GMHDPF.refnum || ' - ' ||
                                  REC_GMHDPF.ZINSROLE;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:9';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;
  FOR REC_GMHIPF IN C_GMHIPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num  := i_schedulenumber;
    obj_DMPVALPF.refkey        := REC_GMHIPF.refnum;
    obj_DMPVALPF.reftab        := 'GMHIPF';
    obj_DMPVALPF.errmess01     := 'Not migrated Policy in GMHIPF';
    obj_DMPVALPF.erorfld       := 'CHDRNUM';
    obj_DMPVALPF.fldvalue      := REC_GMHIPF.refnum || ' - ' ||
                                  REC_GMHIPF.ZINSROLE;
    obj_DMPVALPF.valdno        := 'VALPAZDRPPFCHK:9';
    obj_DMPVALPF.datime        := sysdate;

    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP;
  Delete Jd1dta.VIEW_DM_DMPVALPF where SCHEDULE_NAME = i_schedulename;
  idx := DMPVALPF_list.first;
  IF (idx IS NOT NULL) THEN
    FORALL idx IN DMPVALPF_list.first .. DMPVALPF_list.last
      INSERT /*+ APPEND_VALUES */
      INTO Jd1dta.VIEW_DM_DMPVALPF
      VALUES DMPVALPF_list
        (idx);

  END IF;

  DMPVALPF_list.delete;
  DMPVALPFindex := 0;
  commit;
  execute IMMEDIATE 'DROP index pazdclpf_idx1';
execute IMMEDIATE 'DROP index pazdrppf_idx1';
execute IMMEDIATE 'DROP index dmigtitdmgmbrindp1_idx1';
execute IMMEDIATE 'DROP index dmigtitdmgmbrindp1_idx2';
execute IMMEDIATE 'DROP index dmigtitdmgmbrindp1_idx3';
execute IMMEDIATE 'DROP index DM_zclepf_idx1';
execute IMMEDIATE 'DROP index DM_zclepf_idx2';
execute IMMEDIATE 'DROP index DM_zclepf_idx3';
end PV_CH_G1ZDMBRIND;

/