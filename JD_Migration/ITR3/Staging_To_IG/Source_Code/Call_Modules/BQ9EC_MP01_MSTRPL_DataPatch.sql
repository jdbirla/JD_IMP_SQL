/*********************************************************************************************************************************
 MASTER POLICY DATA PATCH
   This script will update OCCDATE and RENEWAL COUNT.
   This script must be run after Master Policy and Member Policy migration were done.
   
 Run commad:
     BQ9EC_MP01_MSTRPL_DataPatch.cmd
**********************************************************************************************************************************/

SET SERVEROUTPUT ON;
SET LINESIZE 300;
SET TRIMSPOOL ON;
--SPOOL &1;

DECLARE

    b_found            BOOLEAN;
    v_mi_count         NUMBER(10,0);
    --- For OCCDATE ---
    index_mplnum PLS_INTEGER;
    TYPE obj_mplnum IS RECORD(
      i_mplnum        Jd1dta.gchd.mplnum%type,
      i_occdate       Jd1dta.gchd.occdate%type);
    TYPE v_array_mplnum IS TABLE OF obj_mplnum;
    mplnum_list v_array_mplnum;

    index_occdate PLS_INTEGER;
    TYPE obj_occdate IS RECORD(
      i_mplnum         Jd1dta.gchd.mplnum%type,
      i_occdate        Jd1dta.gchd.occdate%type);
    TYPE v_array_occdate IS TABLE OF obj_occdate;
    occdate_list v_array_occdate;

    --- Renewal Count ---
    index_zrnwcnt PLS_INTEGER;
    TYPE obj_zrnwcnt IS RECORD(
      i_mplnum        Jd1dta.gchd.mplnum%type,
      i_zrnwcnt       Jd1dta.gchipf.zrnwcnt%type);
    TYPE v_array_zrnwcnt IS TABLE OF obj_zrnwcnt;
    zrnwcnt_list v_array_zrnwcnt;
    
    --- Renewal Count for Master Policy---
    index_zrnwcnt_mp PLS_INTEGER;
    TYPE obj_zrnwcnt_mp IS RECORD(
      i_chdrnum       Jd1dta.gchipf.chdrnum%type,
      i_ccdate        Jd1dta.gchipf.ccdate%type,
      i_crdate        Jd1dta.gchipf.crdate%type,
      i_zrnwcnt       Jd1dta.gchipf.zrnwcnt%type,
      i_unique_numer  Jd1dta.gchipf.UNIQUE_NUMBER%type);
    TYPE v_array_zrnwcnt_mp IS TABLE OF obj_zrnwcnt_mp;
    zrnwcnt_list_mp v_array_zrnwcnt_mp;
    
    sv_ccdate         Jd1dta.gchipf.ccdate%type;
    v_zrnwcnt         Jd1dta.gchipf.zrnwcnt%type;
    
BEGIN

    DBMS_OUTPUT.ENABLE( 1000000 );
    
    dbms_output.put_line('***** [Master Policy Data Patch] OCCDATE of GCHD UPDATE START ' || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH:MM:SS') || ' *****');
    
    MERGE INTO GCHD gc
    USING(
    	SELECT
    		p.UNIQUE_NUMBER, p.CHDRNUM, b.OCCDATE
    	FROM
    		Jd1dta.GCHD p
    		INNER JOIN
    			(    SELECT 
    					MPLNUM, 
    					MIN(OCCDATE) AS OCCDATE
    				FROM Jd1dta.GCHD WHERE CHDRNUM <> MPLNUM  AND  JOBNM = 'G1ZDMBRIND'
    				GROUP BY MPLNUM
    			) b ON b.mplnum = p.CHDRNUM
    	WHERE
    		p.CHDRNUM = p.MPLNUM      
    	AND p.JOBNM = 'G1ZDMSTPOL'
    ) od  
    ON (gc.UNIQUE_NUMBER = od.UNIQUE_NUMBER AND gc.CHDRNUM = od.CHDRNUM)
    WHEN MATCHED THEN
    UPDATE SET gc.OCCDATE = od.OCCDATE;
    
    COMMIT;

    dbms_output.put_line('***** [Master Policy Data Patch] OCCDATE of GCHD UPDATE END ' || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH:MM:SS') || ' *****');

    ------- << UPDATE Renewal Count >>------------------
    dbms_output.put_line('***** [Master Policy Data Patch] RENEWAL COUNT of GCHIPF UPDATE START ' || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH:MM:SS') || ' *****');
    
    --- Getting maxumum renewal count of member Pilicy of GCHIPF 
    MERGE INTO Jd1dta.GCHIPF fn
	USING (
		SELECT CASE WHEN RN = 1 THEN
				ZRNWCNT
			WHEN RN = 2 THEN
				ZRNWCNT -1
			END AS CORRECT_ZRNWCNT,
			old_ZRNWCNT, unique_number, chdrnum, ccdate, rn
		FROM (
		SELECT m.ZRNWCNT, 
		row_number() over(partition by chdrnum order by CCDATE DESC, UNIQUE_NUMBER) rn,
		h.unique_number, h.chdrnum, h.ccdate, h.ZRNWCNT as old_ZRNWCNT
		FROM Jd1dta.GCHIPF h 
		INNER JOIN (
			SELECT MPLNUM, MAX(ZRNWCNT) ZRNWCNT 
			FROM (
				SELECT
						gchi.CHDRNUM,
						gc1.MPLNUM,
						gchi.ZRNWCNT
					FROM Jd1dta.GCHIPF gchi 
					INNER JOIN (
						SELECT 
							MPLNUM, 
							CHDRNUM
						FROM Jd1dta.GCHD WHERE CHDRNUM <> MPLNUM  AND  JOBNM = 'G1ZDMBRIND'
						AND TRIM(MPLNUM) IS NOT NULL
					) gc1 ON gc1.CHDRNUM = gchi.CHDRNUM
				)
				GROUP BY MPLNUM
			) m ON h.CHDRNUM = m.MPLNUM
		)
	) od ON (fn.unique_number = od.unique_number AND fn.chdrnum = od.chdrnum AND fn.ccdate = od.ccdate)
	WHEN MATCHED THEN
	UPDATE SET fn.ZRNWCNT = od.CORRECT_ZRNWCNT;
    
    dbms_output.put_line('***** [Master Policy Data Patch] RENEWAL COUNT of GCHIPF UPDATE END  ' || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH:MM:SS') || ' *****');
    
    COMMIT;

END;
/
SPOOL OFF;
EXIT;