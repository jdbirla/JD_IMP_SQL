create or replace PROCEDURE                "Jd1dta"."RECONCILIATION_REPORT" (i_scheduleId IN VARCHAR2) as
 
 -------------------------------- Constants -----------------------------
 C_ORACLEDIR VARCHAR2(50) := 'ORACLE_BASE';
 C_EXCELNAME VARCHAR2(30) := 'Recon_Report.xlsx';
 
 
 ------------------------- Variables --------------------------
  p_exitcode       number;
  p_exittext       varchar2(2000);
 
 --------------------- Query for getting reconciliation data from RECON_MASTER table ------------------------ 
 p_sql VARCHAR2(200) := 'SELECT RECON_QUERY_ID, MODULE_NAME, GROUP_CLAUSE, WHERE_CLAUSE, VALIDATION_TYPE, SOURCE_VALUE, STAGING_VALUE, IG_VALUE, STATUS FROM RECON_MASTER WHERE SCHEDULE_ID = ' || i_scheduleId;  

BEGIN

 ------------------ Calling PKG_WRITE_XLSX operations for generating and saving  xlsx file -------------------
 PKG_WRITE_XLSX.query2sheet(p_sql, i_scheduleId);
 PKG_WRITE_XLSX.save(C_ORACLEDIR, C_EXCELNAME);
 
 EXCEPTION
  WHEN OTHERS THEN
    p_exitcode := SQLCODE;
    p_exittext := ' RECONCILIATION_REPORT ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;
    raise_application_error(-20001, p_exitcode || p_exittext);


END RECONCILIATION_REPORT;