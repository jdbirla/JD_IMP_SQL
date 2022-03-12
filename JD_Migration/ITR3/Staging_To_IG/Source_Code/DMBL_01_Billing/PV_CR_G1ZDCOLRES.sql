create or replace procedure               PV_CR_G1ZDCOLRES(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
 --Not migrated Successful/Unsuccessfull bill collection                                                
 CURSOR  c_zcrhpf1 IS
	SELECT A.chdrnum || '-' || trrefnum || '-' || prbilfdt || '-' || TRIM(A.tfrdate) AS zentity FROM Jd1dta.DMIGTITDMGCOLRES A 
	WHERE NOT EXISTS (
		SELECT 1
		FROM Jd1dta.zcrhpf B
		WHERE TRIM(B.chdrnum) 	= TRIM(A.chdrnum)
			AND TRIM(B.tfrdate)	= TRIM(A.tfrdate)
			AND B.dshcde <> ' '
	) 
    AND EXISTS(
            SELECT 1 FROM Jd1dta.pazdcrpf pz WHERE substr(pz.zentity,1,8) = a.chdrnum);  --#ZJNPG-9739 : RUAT improvement

 --Not migrated Pending bill collection
 CURSOR  c_zcrhpf2 IS
    SELECT A.chdrnum || '-' || A.billno AS CHDRNUM_BILLNO FROM Jd1dta.gbihpf A
	WHERE A.premout  = 'Y' 
		AND A.zbktrfdt  <> '99999999'
		AND A. zbktrfdt IS NOT NULL
		AND A.ZACMCLDT > TO_CHAR(sysdate,'YYYYMMDD')
		AND EXISTS(
			SELECT 1 FROM Jd1dta.gchppf B WHERE A.chdrnum = B.chdrnum AND B.zcolmcls  ='F')
		AND NOT EXISTS(
			SELECT 1 FROM Jd1dta.zcrhpf C WHERE A.chdrnum = C.chdrnum AND A.billno = C.billno AND C.dshcde = ' ')
        AND EXISTS (
            SELECT 1 FROM Jd1dta.PAZDRBPF pz WHERE pz.chdrnum = a.chdrnum               --#ZJNPG-9739 : RUAT improvement
	);

 -- ZCOLFLAG and PREMOUT validation for SUCCESSFUL Collection (Factoring House Policies)
 CURSOR c_gbhipf1 IS
    SELECT TRIM(A.chdrnum) || '-' || TRIM(A.billno) AS CHDRNUM_BILLNO FROM Jd1dta.zcrhpf A
	WHERE A.dshcde = '00'
	AND EXISTS(
		SELECT 1 FROM Jd1dta.gchppf B WHERE B.chdrnum = A.chdrnum AND B.zcolmcls  ='F')
	AND NOT EXISTS (
		SELECT 1 FROM Jd1dta.gbihpf C WHERE C.chdrnum = A.chdrnum and C.billno = A.billno AND C.zcolflag = 'Y' AND c.premout = 'N')
    AND EXISTS(
        SELECT 1 FROM Jd1dta.pazdcrpf pz WHERE substr(pz.zentity,1,8) = a.chdrnum);     --#ZJNPG-9739 : RUAT improvement

  -- ZCOLFLAG and PREMOUT validation for PENDING Collection (Factoring House Policies)	
  CURSOR c_gbhipf2 IS
    SELECT  TRIM(C.chdrnum) || '-' || TRIM(C.billno) AS CHDRNUM_BILLNO FROM Jd1dta.gbihpf C 
        WHERE  C.zcolflag = ' ' AND c.premout = 'Y' 
            AND c.zbktrfdt  <> '99999999'
			AND c.zbktrfdt IS NOT NULL
			AND c.zbktrfdt >= (select busdate from Jd1dta.busdpf where company = '1')
            AND EXISTS(
                SELECT 1 FROM Jd1dta.gchppf B WHERE B.chdrnum = C.chdrnum AND B.zcolmcls  ='F')
            AND NOT EXISTS (
                SELECT 1 FROM Jd1dta.zcrhpf A WHERE C.chdrnum = A.chdrnum and C.billno = A.billno AND A.dshcde = ' ')
            AND EXISTS (
                SELECT 1 FROM Jd1dta.PAZDRBPF pz WHERE pz.chdrnum = c.chdrnum               --#ZJNPG-9739 : RUAT improvement
	); 

  --Checking for Unsucessfull Collection which are not recorded in ZUCLPF.
  CURSOR c_zuclpf IS
	SELECT DISTINCT A.CHDRNUM FROM Jd1dta.zuclpf A 
	WHERE 
		(SELECT SUM(B.zcombill) FROM Jd1dta.zuclpf B where B.chdrnum = A.chdrnum AND B.zcombill <> 0) 
		< 
		(SELECT COUNT(1) FROM (select chdrnum, billno, count(*) from Jd1dta.zcrhpf  WHERE dshcde <> '00' AND dshcde <> ' ' group by chdrnum, billno) C WHERE C.chdrnum = A.chdrnum)
        AND EXISTS(
            SELECT 1 FROM Jd1dta.pazdcrpf pz WHERE substr(pz.zentity,1,8) = a.chdrnum);     --#ZJNPG-9739 : RUAT improvement  

  --P20: BTDATE and PTDATE validation for CHDRPF table.
  CURSOR c_chdrpf IS
    SELECT CHDRNUM FROM Jd1dta.gchd A
        WHERE --A.btdate <> (SELECT MAX(B.PRBILTDT) FROM Jd1dta.gbihpf B WHERE B.chdrnum = B.chdrnum AND B.bilflag = 'N') AND
        A.PTDATE <> (SELECT MAX(C.PRBILTDT) FROM Jd1dta.gbihpf C WHERE c.chdrnum = a.chdrnum AND c.bilflag = 'N' AND c.premout = 'N' AND c.zcolflag = 'Y')
        --AND EXISTS(
            --SELECT 1 FROM Jd1dta.gchppf D WHERE D.chdrnum = A.chdrnum AND D.zcolmcls = 'F')
        AND EXISTS(
			SELECT 1 FROM Jd1dta.zcrhpf E,  Jd1dta.gchppf D WHERE D.chdrnum = A.chdrnum AND D.zcolmcls = 'F' AND E.CHDRNUM = D.CHDRNUM AND E.chdrnum = A.chdrnum)
        AND EXISTS(
            SELECT 1 FROM Jd1dta.pazdcrpf pz WHERE substr(pz.zentity,1,8) = a.chdrnum);      --#ZJNPG-9739 : RUAT improvement
  
  --START: ZJNPG-9919: Add post validation in gbihpf for unsuccessful collection--
  CURSOR c_gbihpf3 IS
	SELECT  TRIM(C.chdrnum)|| '-' || TRIM(C.billno) AS CHDRNUM_BILLNO FROM  Jd1dta.gbihpf C
		LEFT JOIN Jd1dta.GCHPPF GC ON c.chdrnum = gc.chdrnum								 -- #ZJNPG-10273 - G1 Rehearsal - zesdpf.ZBILDTDT should be used insted of zbktrfdt
		LEFT JOIN Jd1dta.ZENDRPF ZE ON ze.zendcde = gc.zendcde								 -- #ZJNPG-10273 - G1 Rehearsal - zesdpf.ZBILDTDT should be used insted of zbktrfdt
		LEFT JOIN Jd1dta.ZESDPF ZN ON zn.zendscid = ze.zendscid AND zn.zbktrfdt = c.zbktrfdt -- #ZJNPG-10273 - G1 Rehearsal - zesdpf.ZBILDTDT should be used insted of zbktrfdt
        WHERE   (C.zcolflag = ' ' OR C.zcolflag IS NULL)  AND c.premout = 'Y' and c.zbktrfdt  <> '99999999'
            AND c.zbktrfdt IS NOT NULL 
            --AND c.zbktrfdt < (select busdate from Jd1dta.busdpf where company = '1') -- #ZJNPG-10273 - G1 Rehearsal - zesdpf.ZBILDTDT should be used insted of zbktrfdt
			AND ZN.ZBILDTDT < (select busdate from Jd1dta.busdpf where company = '1')  -- #ZJNPG-10273 - G1 Rehearsal - zesdpf.ZBILDTDT should be used insted of zbktrfdt
            AND EXISTS(
                SELECT 1 FROM Jd1dta.gchppf B WHERE B.chdrnum = C.chdrnum AND B.zcolmcls  ='F')
            AND EXISTS (
                SELECT 1 FROM Jd1dta.zcrhpf A WHERE C.chdrnum = A.chdrnum and C.billno = A.billno 
                AND nvl(trim(A.dshcde),'00') <> '00')
            AND EXISTS (
                SELECT 1 FROM Jd1dta.PAZDRBPF pz WHERE pz.chdrnum = c.chdrnum );  
  --END: ZJNPG-9919: Add post validation in gbihpf for unsuccessful collection--

 TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
 DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
 DMPVALPFindex integer := 0;
 idx PLS_INTEGER;

 obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
begin
--1  
  FOR rec_zcrhpf1 IN c_zcrhpf1 LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         := rec_zcrhpf1.zentity;
    obj_DMPVALPF.reftab         := 'PAZDCRPF';
    obj_DMPVALPF.errmess01      := 'Not migrated Successful/Unsuccessfull bill collection';
    obj_DMPVALPF.erorfld        := 'ZENTITY';
    obj_DMPVALPF.fldvalue       := rec_zcrhpf1.zentity;
    obj_DMPVALPF.valdno         := 'VALZCRHPFCHECK:1';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;	
  END LOOP; 

--2  
  FOR rec_zcrhpf2 IN c_zcrhpf2 LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         :=  rec_zcrhpf2.CHDRNUM_BILLNO;
    obj_DMPVALPF.reftab         := 'ZCRHPF';
    obj_DMPVALPF.errmess01      := 'Not migrated Pending bill collection';
    obj_DMPVALPF.erorfld        := 'CHDRNUM';
    obj_DMPVALPF.fldvalue       := rec_zcrhpf2.CHDRNUM_BILLNO;
    obj_DMPVALPF.valdno         := 'VALZCRHPFCHECK:2';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

  END LOOP; 

--3
  FOR rec_gbhipf1 IN c_gbhipf1 LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         :=  rec_gbhipf1.CHDRNUM_BILLNO;
    obj_DMPVALPF.reftab         := 'GBIHPF=00';
    obj_DMPVALPF.errmess01      := 'ZCOLFLAG must be Y and PREMOUT must be N';
    obj_DMPVALPF.erorfld        := 'CHDRNUM';
    obj_DMPVALPF.fldvalue       := rec_gbhipf1.CHDRNUM_BILLNO;
    obj_DMPVALPF.valdno         := 'VALGBIHPFCHECK:3';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

  UPDATE Jd1dta.gbihpf
  SET ZCOLFLAG = 'Y',
    PREMOUT    = 'N'
  WHERE chdrnum || billno IN
    (SELECT chdrnum || billno FROM Jd1dta.zcrhpf WHERE dshcde = '00')
  AND chdrnum IN
    (SELECT chdrnum FROM Jd1dta.gchppf WHERE zcolmcls = 'F')
  AND (zcolflag<>'Y' OR PREMOUT   <> 'N')
  AND chdrnum IN
            (SELECT substr(zentity,1,8) FROM Jd1dta.pazdcrpf) ; --#ZJNPG-9739 : RUAT improvement;

  IF sql%rowcount > 0 THEN
    --FOR l_counter IN 1..sql%rowcount LOOP --#ZJNPG-9739 RUAT - perf improvement
      obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
      obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
      obj_DMPVALPF.refkey         := 'Records Updated';
      obj_DMPVALPF.reftab         := 'UPDATE: GBIHPF=00';
      obj_DMPVALPF.errmess01      := 'ZCOLFLAG has been set to Y and PREMOUT = N';
      obj_DMPVALPF.erorfld        := 'CHDRNUM';
      obj_DMPVALPF.fldvalue       := 'ZCOLFLAG=Y and PREMOUT=N :' ||sql%rowcount;
      obj_DMPVALPF.valdno         := 'VALGBIHPFCHECK:7';
      obj_DMPVALPF.datime         := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
   --END LOOP; --#ZJNPG-9739 RUAT - perf improvement
  END IF;

  COMMIT; 

--4
  FOR rec_gbhipf2 IN c_gbhipf2 LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         :=  rec_gbhipf2.CHDRNUM_BILLNO;
    obj_DMPVALPF.reftab         := 'GBIHPF=BLANK';
    obj_DMPVALPF.errmess01      := 'ZCOLFLAG must be blank and PREMOUT must be Y';
    obj_DMPVALPF.erorfld        := 'CHDRNUM';
    obj_DMPVALPF.fldvalue       := rec_gbhipf2.CHDRNUM_BILLNO;
    obj_DMPVALPF.valdno         := 'VALGBIHPFCHECK:4';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

--5
  FOR rec_zuclpf IN c_zuclpf LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         :=  rec_zuclpf.CHDRNUM;
    obj_DMPVALPF.reftab         := 'ZUCLPF';
    obj_DMPVALPF.errmess01      := 'Some bills were not recorded in ZUCLPF';
    obj_DMPVALPF.erorfld        := 'CHDRNUM';
    obj_DMPVALPF.fldvalue       := rec_zuclpf.CHDRNUM;
    obj_DMPVALPF.valdno         := 'VALZUCLPFCHECK:5';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

--6
  FOR rec_chdrpf IN c_chdrpf LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         :=  rec_chdrpf.CHDRNUM;
    obj_DMPVALPF.reftab         := 'CHDRPF_BEFORE';
    obj_DMPVALPF.errmess01      := 'P20 - PTDATE is incorrect in CHDRPF table';
    obj_DMPVALPF.erorfld        := 'CHDRNUM';
    obj_DMPVALPF.fldvalue       := rec_chdrpf.CHDRNUM;
    obj_DMPVALPF.valdno         := 'VALCHDRPFCHECK:6';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;

    MERGE INTO Jd1dta.gchd gc 
    USING (
    SELECT gbih.gbihpf_ptdate, gchd.* 
    FROM Jd1dta.gchd gchd 
    INNER JOIN 
    (
        SELECT a.chdrnum, max(a.PRBILTDT) gbihpf_ptdate from Jd1dta.gbihpf a 
        WHERE EXISTS(
            SELECT 1 FROM Jd1dta.gchppf D WHERE D.chdrnum = A.chdrnum AND D.zcolmcls = 'F')
        AND EXISTS(
            SELECT 1 FROM Jd1dta.zcrhpf E WHERE E.chdrnum = A.chdrnum)
        AND a.premout = 'N' AND a.bilflag = 'N' AND a.zcolflag = 'Y' group by a.chdrnum
    ) gbih ON gchd.chdrnum = gbih.chdrnum and gchd.ptdate <> gbih.gbihpf_ptdate
    WHERE EXISTS(
            SELECT 1 FROM Jd1dta.pazdcrpf pz WHERE substr(pz.zentity,1,8) = gchd.chdrnum)      --#ZJNPG-9739 : RUAT improvement
    ) gb
    ON (gc.unique_number = gb.unique_number and gc.chdrnum = gb.chdrnum)
    WHEN MATCHED THEN
    UPDATE SET gc.ptdate = gb.gbihpf_ptdate;

  IF sql%rowcount > 0 THEN
    --FOR l_counter IN 1..sql%rowcount LOOP --#ZJNPG-9739 RUAT - perf improvement
      obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
      obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
      obj_DMPVALPF.refkey         := 'PTDATE has been updated';
      obj_DMPVALPF.reftab         := 'UPDATE: CHDRPF';
      obj_DMPVALPF.errmess01      := 'PTDATE has been updated to MAX(PRBILTDT)';
      obj_DMPVALPF.erorfld        := 'CHDRNUM';
      obj_DMPVALPF.fldvalue       := 'PTDATE is MAX(PRBILTDT) :' || sql%rowcount;
      obj_DMPVALPF.valdno         := 'VALCHDRPFCHECK:8';
      obj_DMPVALPF.datime         := sysdate; 

      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
    --END LOOP; --#ZJNPG-9739 RUAT - perf improvement
  END IF;

  COMMIT; 

--7 After Patch
  FOR rec_chdrpf IN c_chdrpf LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         :=  rec_chdrpf.CHDRNUM;
    obj_DMPVALPF.reftab         := 'CHDRPF_AFTER';
    obj_DMPVALPF.errmess01      := 'P20 - PTDATE is still incorrect in CHDRPF table';
    obj_DMPVALPF.erorfld        := 'CHDRNUM';
    obj_DMPVALPF.fldvalue       := rec_chdrpf.CHDRNUM;
    obj_DMPVALPF.valdno         := 'VALCHDRPFCHECK:7';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;


--8 Unsucessfull collection checking in gbihpf
  --Start: ZJNPG-9919: Add post validation in gbihpf for unsuccessful collection--
  FOR rec_chdrpf IN c_gbihpf3 LOOP
    obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
    obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
    obj_DMPVALPF.refkey         :=  rec_chdrpf.CHDRNUM_BILLNO;
    obj_DMPVALPF.reftab         := 'GBIHPF<>00';
    obj_DMPVALPF.errmess01      := 'GBIHPF.ZCOLFLAG should be Y';
    obj_DMPVALPF.erorfld        := 'CHDRNUM';
    obj_DMPVALPF.fldvalue       := rec_chdrpf.CHDRNUM_BILLNO;
    obj_DMPVALPF.valdno         := 'VALCHDRPFCHECK:8';
    obj_DMPVALPF.datime         := sysdate; 

    DMPVALPFindex :=DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP;
  --END: ZJNPG-9919: Add post validation in gbihpf for unsuccessful collection--
	
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
END PV_CR_G1ZDCOLRES;