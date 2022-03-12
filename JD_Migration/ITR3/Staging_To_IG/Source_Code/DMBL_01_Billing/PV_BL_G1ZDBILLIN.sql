/**************************************************************************************************************************
  * File Name        : PV_BL_G1ZDBILLIN
  * Author           : Chong Thau Syn
  * Creation Date    : December 23, 2020
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : This Procedure for post migration validation
  **************************************************************************************************************************/
   /***************************************************************************************************
  * Amendment History: DMBL-01
  * Date    Init   Tag   Description
  * -----   -----  ---   ---------------------------------------------------------------------------
  * 2323     CHO         New developed in PA ITR3
  * 0501     CHO         Add VALGBIHPFCHECK:8 and 9 to patch ZCOLFLAG for CC cases
  * 0601     CHO         Move MSD SHI issue 2-9 (SP8) : for assigning of PTDATE from main script
                         Move MSD SHI issue 2-9 (SP9) : for assigning of BTDATE from main script
                         Move MSD SHI issue 2-8 : for assigning of PTDATE from main script
  * 2202     CHO         C_GPMDPF - remove TRIM to improve performance
                         Put C_DMIGTITDMGBILL1 in c_billing1b and c_billing1c to improve performance
  * 2806     KLP         ZJNPG-9739, Changes to improve the performance, by replacing the cursor with update statement 
  * 2906     KLP         ZJNPG-9739, Fixing to get the max date to set ptdate and btdate 			
  * 0507     KLP         ZJNPG-9739, Changes to check the post validation for only migrated policies
  * 1207     KLP         ZJNPG-9739, Added the migration table to check on post validation
  ********************************************************************************************************************************/

create or replace procedure Jd1dta.PV_BL_G1ZDBILLIN(i_schedulename IN VARCHAR2,
                                                    i_schedulenumber in varchar2) is
    
cursor C_GBIHPF is
  select A.CHDRNUM, A.TRREFNUM, A.PRBILFDT from Jd1dta.DMIGTITDMGBILL1 A where not EXISTS (
  select 1
  from Jd1dta.GBIHPF B
  where trim(B.CHDRNUM) = TRIM(A.CHDRNUM) 
  and B.INSTNO = A.TRREFNUM
  and B.PRBILFDT = A.PRBILFDT
  );
  
cursor C_GPMDPF is
  select A.CHDRNUM, A.TRREFNUM, A.PRBILFDT, A.PRODTYP, A.MBRNO, A.DPNTNO from Jd1dta.DMIGTITDMGBILL2 A where not EXISTS (
  select 1
  from Jd1dta.GPMDPF B
  where B.CHDRNUM = A.CHDRNUM and B.INSTNO = A.TRREFNUM and B.PRMFRDT = A.PRBILFDT
  and B.PRODTYP = A.PRODTYP AND B.MBRNO = A.MBRNO AND B.DPNTNO = A.DPNTNO  
  );
  
cursor C_GBIDPF is
  select A.CHDRNUM, A.TRREFNUM, A.PRBILFDT, A.PRODTYP
  from Jd1dta.DMIGTITDMGBILL2 A 
  LEFT OUTER JOIN Jd1dta.PAZDRBPF C
    ON TRIM(A.CHDRNUM) = TRIM(C.CHDRNUM)
    AND TRIM(A.TRREFNUM) = TRIM(C.ZENTITY)
	AND A.PRBILFDT = C.PRBILFDT
  where not EXISTS (
  select 1
  from Jd1dta.GBIDPF B
  where B.BILLNO = C.ZIGVALUE AND B.PRODTYP = A.PRODTYP
  )
  GROUP BY A.CHDRNUM, A.TRREFNUM, A.PRBILFDT, A.PRODTYP;
  
--cursor C_DMIGTITDMGBILL1 is
--  select distinct chdrnum 
--  from Jd1dta.DMIGTITDMGBILL1;

-- Below cursor is commented for ZJNPG-6619  
/*  CURSOR c_billing1b
  IS
    SELECT CHDRNUM, MAX(prbiltdt) PRBILTDT
      FROM Jd1dta.DMIGTITDMGBILL1
     WHERE premout = 'N'
  GROUP BY CHDRNUM;

  CURSOR c_billing1c
  IS
    SELECT CHDRNUM, MAX(prbiltdt) PRBILTDT
      FROM Jd1dta.DMIGTITDMGBILL1
  GROUP BY CHDRNUM;
*/
  
cursor C_GCHD is
  select chdrnum 
  from Jd1dta.GCHD b
  where statcode = 'XN'
  AND EXISTS (
    SELECT 1 FROM Jd1dta.DMIGTITDMGBILL1 a
    WHERE a.chdrnum = b.chdrnum);
 
  
cursor C_GBIHPF2 is
  select B1.CHDRNUM, B1.INSTNO, B1.BILLNO from Jd1dta.GBIHPF B1,
  Jd1dta.DMIGTITDMGBILL1 MIG
  where MIG.CHDRNUM =  B1.chdrnum
  AND B1.zcolflag <> 'Y' AND B1.premout = 'N'
  AND B1.chdrnum IN
    (SELECT chdrnum FROM Jd1dta.gchppf WHERE zcolmcls = 'C')
  AND b1.chdrnum IN
    (SELECT chdrnum FROM Jd1dta.gchd WHERE btdate = ptdate);

  obj_DMPVALPF  VIEW_DM_DMPVALPF%rowtype;
  DMPVALPFindex integer := 0;
  TYPE DMPVALPF_type IS TABLE of VIEW_DM_DMPVALPF%rowtype;
  DMPVALPF_list DMPVALPF_type := DMPVALPF_type();
  idx PLS_INTEGER;
  
begin

  dbms_output.put_line('Start execution of PV_BL_G1ZDBILLIN');
--  insert_error_log('001','Start execution of PV_BL_G1ZDBILLIN','PV_BL_G1ZDBILLIN');

  --VALGBIHPFCHECK:1 
  FOR REC_GBIHPF IN C_GBIHPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num := i_schedulenumber;
    obj_DMPVALPF.refkey := TRIM(REC_GBIHPF.CHDRNUM);   
    obj_DMPVALPF.reftab := 'GBIHPF';    
    obj_DMPVALPF.errmess01 := 'Bill Not Migrated';    
    obj_DMPVALPF.erorfld := 'CHDRNUM'; 
    obj_DMPVALPF.fldvalue := TRIM(REC_GBIHPF.CHDRNUM) || '-' || TRIM(REC_GBIHPF.TRREFNUM) || '-' || REC_GBIHPF.PRBILFDT; 
    obj_DMPVALPF.valdno := 'VALGBIHPFCHECK:1'; 
    obj_DMPVALPF.datime := sysdate; 
    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 
  
--  dbms_output.put_line('completed VALGBIHPFCHECK:1'||systimestamp);
--  dbms_output.put_line('started VALGPMDPFCHECK:2'||systimestamp);
--  insert_error_log('001','completed VALGBIHPFCHECK:1','PV_BL_G1ZDBILLIN');
--  insert_error_log('001','started VALGPMDPFCHECK:2','PV_BL_G1ZDBILLIN');

  --VALGPMDPFCHECK:2
  FOR REC_GPMDPF IN C_GPMDPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num := i_schedulenumber;
    obj_DMPVALPF.refkey := TRIM(REC_GPMDPF.CHDRNUM);   
    obj_DMPVALPF.reftab := 'GPMDPF';    
    obj_DMPVALPF.errmess01 := 'Bill Not Migrated';    
    obj_DMPVALPF.erorfld := 'CHDRNUM'; 
    obj_DMPVALPF.fldvalue := TRIM(REC_GPMDPF.CHDRNUM) || '-' || TRIM(REC_GPMDPF.TRREFNUM) || '-' || REC_GPMDPF.PRBILFDT
                             || '-' || TRIM(REC_GPMDPF.PRODTYP) || '-' || TRIM(REC_GPMDPF.MBRNO) || '-' || TRIM(REC_GPMDPF.DPNTNO); 
    obj_DMPVALPF.valdno := 'VALGPMDPFCHECK:2'; 
    obj_DMPVALPF.datime := sysdate; 
    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 

--  dbms_output.put_line('completed VALGBIHPFCHECK:2'||systimestamp);
--  dbms_output.put_line('started VALGPMDPFCHECK:3'||systimestamp);
--  insert_error_log('001','completed VALGBIHPFCHECK:2','PV_BL_G1ZDBILLIN');
--  insert_error_log('001','started VALGPMDPFCHECK:3','PV_BL_G1ZDBILLIN');
  
  --VALGBIDPFCHECK:3
  FOR REC_GBIDPF IN C_GBIDPF LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num := i_schedulenumber;
    obj_DMPVALPF.refkey := TRIM(REC_GBIDPF.CHDRNUM);   
    obj_DMPVALPF.reftab := 'GBIDPF';    
    obj_DMPVALPF.errmess01 := 'Bill Not Migrated';    
    obj_DMPVALPF.erorfld := 'CHDRNUM'; 
    obj_DMPVALPF.fldvalue := TRIM(REC_GBIDPF.CHDRNUM) || '-' || TRIM(REC_GBIDPF.TRREFNUM) || '-' || REC_GBIDPF.PRBILFDT || '-' || TRIM(REC_GBIDPF.PRODTYP); 
    obj_DMPVALPF.valdno := 'VALGBIDPFCHECK:3'; 
    obj_DMPVALPF.datime := sysdate; 
    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 

--  dbms_output.put_line('completed VALGBIHPFCHECK:3'||systimestamp);
--  dbms_output.put_line('started VALGPMDPFCHECK:4'||systimestamp);
--  insert_error_log('001','completed VALGBIHPFCHECK:3','PV_BL_G1ZDBILLIN');
--  insert_error_log('001','started VALGPMDPFCHECK:4','PV_BL_G1ZDBILLIN');
  
	--VALGCHDCHECK:4
	--MSD SHI issue 2-9 (SP8) : for assigning of PTDATE

    /*  update Jd1dta.GCHD r1 set PTDATE = (SELECT  MAX(prbiltdt) PRBILTDT
                                            FROM Jd1dta.DMIGTITDMGBILL1 b
                                             WHERE B.CHDRNUM = r1.CHDRNUM
                                             AND R1.PTDATE <> B.PRBILTDT
                                             and B.premout = 'N'
                                             GROUP BY B.CHDRNUM);
                                             */


update Jd1dta.GCHD r1 set PTDATE = (SELECT  MAX(prbiltdt) PRBILTDT
                                            FROM Jd1dta.DMIGTITDMGBILL1 b
                                             WHERE B.CHDRNUM = r1.CHDRNUM
                                             and B.premout = 'N'
                                             and nvl(R1.PTDATE,0) <> (select MAX(prbiltdt) from Jd1dta.DMIGTITDMGBILL1 c where c.CHDRNUM = r1.CHDRNUM and c.premout = 'N')
                                              GROUP BY B.CHDRNUM)
where    exists (SELECT  1
                                            FROM Jd1dta.DMIGTITDMGBILL1 b
                                             WHERE B.CHDRNUM = r1.CHDRNUM
                                              and nvl(R1.PTDATE,0) <> (select MAX(prbiltdt) from Jd1dta.DMIGTITDMGBILL1 c where c.CHDRNUM = r1.CHDRNUM and c.premout = 'N')
                                            and B.premout = 'N');

   IF sql%rowcount >= 0 THEN

        obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
        obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
        obj_DMPVALPF.refkey         := 'Records Updated';
        obj_DMPVALPF.reftab         := 'UPDATE: GCHD=PTDATE';
        obj_DMPVALPF.errmess01      := 'PTDATE has been set to MAX(BILTDT)';
        obj_DMPVALPF.erorfld        := 'NO.OF REC';
        obj_DMPVALPF.fldvalue       := sql%rowcount;
        obj_DMPVALPF.valdno         := 'VALGCHDCHECK:4';
        obj_DMPVALPF.datime         := sysdate;    

        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

   end if;

  /*  
	for r1 in c_billing1b loop
	  update Jd1dta.GCHD set PTDATE = r1.PRBILTDT
	  WHERE CHDRNUM = r1.CHDRNUM
	  AND PTDATE <> r1.PRBILTDT;

	  IF sql%rowcount > 0 THEN
      FOR l_counter IN 1..sql%rowcount LOOP
        obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
        obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
        obj_DMPVALPF.refkey         := r1.CHDRNUM;
        obj_DMPVALPF.reftab         := 'UPDATE: GCHD=PTDATE';
        obj_DMPVALPF.errmess01      := 'PTDATE has been set to MAX(BILTDT)';
        obj_DMPVALPF.erorfld        := 'CHDRNUM';
        obj_DMPVALPF.fldvalue       := r1.PRBILTDT;
        obj_DMPVALPF.valdno         := 'VALGCHDCHECK:4';
        obj_DMPVALPF.datime         := sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
      END LOOP;
	  END IF;
	  
	end loop;

*/


--  dbms_output.put_line('completed VALGBIHPFCHECK:4'||systimestamp);
--  dbms_output.put_line('started VALGPMDPFCHECK:5'||systimestamp);
--  insert_error_log('001','completed VALGBIHPFCHECK:4','PV_BL_G1ZDBILLIN');
--  insert_error_log('001','started VALGPMDPFCHECK:5','PV_BL_G1ZDBILLIN');

	--VALGCHDCHECK:5
	--MSD SHI issue 2-9 (SP9) : for assigning of BTDATE
-- changes for ZJNPG-6619

 /* update Jd1dta.GCHD B  set BTDATE = (SELECT  MAX(prbiltdt) PRBILTDT
                                        FROM Jd1dta.DMIGTITDMGBILL1 r1
                                         WHERE B.CHDRNUM = r1.CHDRNUM
                                         AND B.BTDATE <> r1.PRBILTDT
                                         GROUP BY R1.CHDRNUM);

*/

 update Jd1dta.GCHD B  set BTDATE = (SELECT  MAX(prbiltdt) PRBILTDT
                                        FROM Jd1dta.DMIGTITDMGBILL1 r1
                                         WHERE B.CHDRNUM = r1.CHDRNUM
                                         and nvl(b.BTDATE,0) <> (select MAX(prbiltdt) from Jd1dta.DMIGTITDMGBILL1 c where c.CHDRNUM = b.CHDRNUM )
                                      GROUP BY R1.CHDRNUM)
where exists (SELECT 1
                                        FROM Jd1dta.DMIGTITDMGBILL1 r1
                                         WHERE B.CHDRNUM = r1.CHDRNUM
                                         and nvl(b.BTDATE,0) <> (select MAX(prbiltdt) from Jd1dta.DMIGTITDMGBILL1 c where c.CHDRNUM = b.CHDRNUM )
                                         ); 




	  IF sql%rowcount >= 0 THEN

        obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
        obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
        obj_DMPVALPF.refkey         := 'Records Updated';
        obj_DMPVALPF.reftab         := 'UPDATE: GCHD=BTDATE';
        obj_DMPVALPF.errmess01      := 'BTDATE has been set to MAX(BILTDT)';
        obj_DMPVALPF.erorfld        := 'NO.OF REC';
        obj_DMPVALPF.fldvalue       :=  sql%rowcount;
        obj_DMPVALPF.valdno         := 'VALGCHDCHECK:5';
        obj_DMPVALPF.datime         := sysdate; 

        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;

	  END IF;


/*	for r1 in c_billing1c loop
	  update Jd1dta.GCHD set BTDATE = r1.PRBILTDT
	  WHERE CHDRNUM = r1.CHDRNUM
	  AND BTDATE <> r1.PRBILTDT;

	  IF sql%rowcount > 0 THEN
      FOR l_counter IN 1..sql%rowcount LOOP
        obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
        obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
        obj_DMPVALPF.refkey         := r1.CHDRNUM;
        obj_DMPVALPF.reftab         := 'UPDATE: GCHD=BTDATE';
        obj_DMPVALPF.errmess01      := 'BTDATE has been set to MAX(BILTDT)';
        obj_DMPVALPF.erorfld        := 'CHDRNUM';
        obj_DMPVALPF.fldvalue       := r1.PRBILTDT;
        obj_DMPVALPF.valdno         := 'VALGCHDCHECK:5';
        obj_DMPVALPF.datime         := sysdate; 
        
        DMPVALPFindex :=DMPVALPFindex + 1;
        DMPVALPF_list.extend;
        DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
      END LOOP;
	  END IF;
	  
	end loop;
*/

  commit;

--  dbms_output.put_line('completed VALGBIHPFCHECK:5'||systimestamp);
--  dbms_output.put_line('started VALGPMDPFCHECK:6'||systimestamp);
--  insert_error_log('001','completed VALGBIHPFCHECK:5','PV_BL_G1ZDBILLIN');
--  insert_error_log('001','started VALGPMDPFCHECK:6','PV_BL_G1ZDBILLIN');

  --VALGCHDCHECK:6
  --MSD SHI issue 2-8 : for assigning of PTDATE
  FOR REC_GCHD IN C_GCHD LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num := i_schedulenumber;
    obj_DMPVALPF.refkey := REC_GCHD.CHDRNUM;   
    obj_DMPVALPF.reftab := 'GCHD=XN';    
    obj_DMPVALPF.errmess01 := 'PTDATE must be 99999999';    
    obj_DMPVALPF.erorfld := 'CHDRNUM'; 
    obj_DMPVALPF.fldvalue := REC_GCHD.CHDRNUM; 
    obj_DMPVALPF.valdno := 'VALGCHDCHECK:6'; 
    obj_DMPVALPF.datime := sysdate; 
    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 

  UPDATE Jd1dta.GCHD b SET ptdate = 99999999 
  WHERE statcode = 'XN'
  AND EXISTS (
    SELECT 1 FROM Jd1dta.DMIGTITDMGBILL1 a
    WHERE a.chdrnum = b.chdrnum);
    
--  dbms_output.put_line('completed VALGBIHPFCHECK:6'||systimestamp);  
--  dbms_output.put_line('started VALGPMDPFCHECK:7'||systimestamp);    
--  insert_error_log('001','completed VALGBIHPFCHECK:6','PV_BL_G1ZDBILLIN');
--  insert_error_log('001','started VALGPMDPFCHECK:7','PV_BL_G1ZDBILLIN');
    
  --VALGCHDCHECK:7
  IF sql%rowcount > 0 THEN
    --FOR l_counter IN 1..sql%rowcount LOOP changes for ZJNPG-6619
      obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
      obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
      obj_DMPVALPF.refkey         := 'Records Updated';
      obj_DMPVALPF.reftab         := 'UPDATE: GCHD=XN';
      obj_DMPVALPF.errmess01      := 'PTDATE has been set to 99999999';
      obj_DMPVALPF.erorfld        := 'CHDRNUM';
      obj_DMPVALPF.fldvalue       := 'PTDATE=99999999';
      obj_DMPVALPF.valdno         := 'VALGCHDCHECK:7';
      obj_DMPVALPF.datime         := sysdate; 
      
      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
    --END LOOP;
  END IF;

  commit;

--  dbms_output.put_line('completed VALGBIHPFCHECK:7'||systimestamp);  
--  dbms_output.put_line('started VALGPMDPFCHECK:8'||systimestamp);    
--  insert_error_log('001','completed VALGBIHPFCHECK:7','PV_BL_G1ZDBILLIN');
--  insert_error_log('001','started VALGPMDPFCHECK:8','PV_BL_G1ZDBILLIN');

  --VALGBIHPFCHECK:8
  FOR REC_GBIHPF2 IN C_GBIHPF2 LOOP
    obj_DMPVALPF.Schedule_Name := i_schedulename;
    obj_DMPVALPF.schedule_num := i_schedulenumber;
    obj_DMPVALPF.refkey := REC_GBIHPF2.CHDRNUM || REC_GBIHPF2.INSTNO;   
    obj_DMPVALPF.reftab := 'GBIHPF=CC';    
    obj_DMPVALPF.errmess01 := 'ZCOLFLAG must be Y';    
    obj_DMPVALPF.erorfld := 'CHDRNUM'; 
    obj_DMPVALPF.fldvalue := REC_GBIHPF2.BILLNO; 
    obj_DMPVALPF.valdno := 'VALGBIHPFCHECK:8'; 
    obj_DMPVALPF.datime := sysdate; 
    DMPVALPFindex := DMPVALPFindex + 1;
    DMPVALPF_list.extend;
    DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
  END LOOP; 
  
-- Changes for ZJNPG-6619
 /* UPDATE Jd1dta.gbihpf
  SET zcolflag = 'Y' 
  WHERE zcolflag <> 'Y' AND premout = 'N'
  AND chdrnum IN
    (SELECT chdrnum FROM Jd1dta.gchppf WHERE zcolmcls = 'C')
  AND chdrnum IN
    (SELECT chdrnum FROM Jd1dta.gchd WHERE btdate = ptdate);
*/


-- Changes to include only migrated policies
  /*UPDATE Jd1dta.gbihpf C
  SET zcolflag = 'Y' 
  WHERE zcolflag <> 'Y' AND premout = 'N'
  AND EXISTS
     (SELECT CHDRNUM FROM 
                   (SELECT chdrnum FROM Jd1dta.gchppf WHERE zcolmcls = 'C'
                     UNION 
                     SELECT chdrnum FROM Jd1dta.gchd WHERE btdate = ptdate) UQ
                     WHERE UQ.CHDRNUM = C.CHDRNUM);
                     */
                     
UPDATE Jd1dta.gbihpf C
  SET C.zcolflag = 'Y' 
  WHERE C.zcolflag <> 'Y' AND C.premout = 'N'
  AND EXISTS
     (SELECT 1 FROM 
                   (SELECT chdrnum FROM Jd1dta.gchppf WHERE zcolmcls = 'C'
                     UNION 
                     SELECT chdrnum FROM Jd1dta.gchd WHERE btdate = ptdate) UQ,
                     DMIGTITDMGBILL1 B1
      WHERE UQ.CHDRNUM = B1.CHDRNUM
        AND UQ.CHDRNUM = C.CHDRNUM);



--  dbms_output.put_line('completed VALGBIHPFCHECK:8'||systimestamp);
--  dbms_output.put_line('started VALGPMDPFCHECK:9'||systimestamp);
--  insert_error_log('001','completed VALGBIHPFCHECK:8','PV_BL_G1ZDBILLIN');
--  insert_error_log('001','started VALGPMDPFCHECK:9','PV_BL_G1ZDBILLIN');
    
  --VALGBIHPFCHECK:9
  IF sql%rowcount >= 0 THEN
  --  FOR l_counter IN 1..sql%rowcount LOOP changes for ZJNPG-6619
      obj_DMPVALPF.Schedule_Name 	:= i_schedulename;
      obj_DMPVALPF.schedule_num 	:= i_schedulenumber;
      obj_DMPVALPF.refkey         := 'Records Updated';
      obj_DMPVALPF.reftab         := 'UPDATE: GBIHPF=CC';
      obj_DMPVALPF.errmess01      := 'ZCOLFLAG has been set to Y - '||sql%rowcount;
      obj_DMPVALPF.erorfld        := 'CHDRNUM';
      obj_DMPVALPF.fldvalue       := 'ZCOLFLAG=Y';
      obj_DMPVALPF.valdno         := 'VALGBIHPFCHECK:9';
      obj_DMPVALPF.datime         := sysdate; 
      
      DMPVALPFindex :=DMPVALPFindex + 1;
      DMPVALPF_list.extend;
      DMPVALPF_list(DMPVALPFindex) := obj_DMPVALPF;
    --END LOOP;
  END IF;

  commit;

--  dbms_output.put_line('completed VALGBIHPFCHECK:9'||systimestamp);
--  insert_error_log('001','completed VALGBIHPFCHECK:9','PV_BL_G1ZDBILLIN');
    
  Delete Jd1dta.VIEW_DM_DMPVALPF where SCHEDULE_NAME = i_schedulename;

  idx := DMPVALPF_list.first;
     
  IF (idx IS NOT NULL) THEN
    FORALL idx IN DMPVALPF_list.first .. DMPVALPF_list.last
      INSERT /*+ APPEND_VALUES */ INTO Jd1dta.VIEW_DM_DMPVALPF VALUES DMPVALPF_list(idx);
  END IF;
   
  DMPVALPF_list.delete;
  DMPVALPFindex := 0;
   
  commit;
--  insert_error_log('001','completed fully VALGPMDPFCHECK','PV_BL_G1ZDBILLIN'); 

  exception
    WHEN OTHERS THEN
      dbms_output.put_line('error:'||sqlerrm);  
--      insert_error_log('001','Err'||sqlerrm,'PV_BL_G1ZDBILLIN'); 
      
end PV_BL_G1ZDBILLIN;