create or replace procedure               PV_PC_G1ZDPOLCOV(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    

  CURSOR c_gmhipf IS
	SELECT DISTINCT a.chdrnum, a.mbrno, a.effdate FROM Jd1dta.gmhipf a WHERE a.zprmsi = 0
    AND a.chdrnum || a.mbrno || a.effdate IN 
			(SELECT chdrnum || mbrno || effdate FROM Jd1dta.gxhipf  WHERE dprem <> 0)
    AND a.jobnm = 'G1ZDMBRIND'
	AND exists (select 1 from Jd1dta.pazdrppf ppf where substr(ppf.chdrnum,1,8) = a.chdrnum); --ZJNPG-9739: Raut;


 TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
 DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
 DMPVALPFindex integer := 0;
 idx PLS_INTEGER;

 obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin

    MERGE INTO Jd1dta.gmhipf updt
    USING 
    (
      select gx.sum_dprem, gm.* from Jd1dta.gmhipf gm
      INNER JOIN (
          SELECT distinct chdrnum, mbrno, effdate, SUM(DPREM) over(PARTITION by chdrnum, mbrno, effdate) sum_dprem FROM Jd1dta.gxhipf
          where dprem <> 0 and jobnm = 'G1ZDPOLCOV' --and trim(usrprf) = 'JBIRLA'
      ) gx ON gm.chdrnum = gx.chdrnum AND gm.mbrno = gx.mbrno AND gm.effdate = gx.effdate
      WHERE gm.jobnm = 'G1ZDMBRIND' 
      AND exists (select 1 from Jd1dta.pazdrppf ppf where substr(ppf.chdrnum,1,8) = gm.chdrnum) --ZJNPG-9739: Raut
    ) gmh
    ON (updt.UNIQUE_NUMBER = gmh.UNIQUE_NUMBER)
    WHEN MATCHED THEN
    UPDATE SET updt.zprmsi = gmh.sum_dprem;

  COMMIT;

  FOR rec_gmhipf IN c_gmhipf LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         :=  rec_gmhipf.CHDRNUM || '-' || rec_gmhipf.MBRNO || '-' || rec_gmhipf.EFFDATE;
    obj_DMPVALPF.reftab         := 'GMHIPF';
    obj_DMPVALPF.errmess01      := 'Total premium is incorrect.';
    obj_DMPVALPF.erorfld        := 'ZPRMSI  ';
    obj_DMPVALPF.fldvalue       := rec_gmhipf.CHDRNUM;
    obj_DMPVALPF.valdno         := 'VALCHDRPFCHECK:1';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;


  --Delete previous re
  DELETE Jd1dta.VIEW_DM_DMPVALPF WHERE SCHEDULE_NAME = i_schedulename;

  idx := DMPVALPF_list.first;
  IF (idx IS NOT NULL) THEN
    FORALL idx IN DMPVALPF_list.first .. DMPVALPF_list.last
      INSERT  /*+ APPEND_VALUES */ INTO Jd1dta.VIEW_DM_DMPVALPF VALUES DMPVALPF_list (idx);

  END IF;

  DMPVALPF_list.delete;
  DMPVALPFindex  := 0;
COMMIT;
END PV_PC_G1ZDPOLCOV;