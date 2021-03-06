CREATE TABLE "TOTPAMMISTRA_EXT" 
(
        "RECIDXACTPOLTRA"      NUMBER(38,0), 
		"ZADDRCD"	VARCHAR2(11 CHAR)
      

)
ORGANIZATION external 
(
  TYPE oracle_loader
  DEFAULT DIRECTORY EXT_DATA_DIR
  ACCESS PARAMETERS 
  (
    RECORDS DELIMITED BY NEWLINE CHARACTERSET JA16SJISTILDE
    BADFILE 'EXT_DATA_DIR':'TOTPAMMISTRA_EXT.bad'
    LOGFILE 'TOTPAMMISTRA_EXT.log_xt'
    READSIZE 1048576
    FIELDS TERMINATED BY ","  
    REJECT ROWS WITH ALL NULL FIELDS 
    (
   
		  "RECIDXACTPOLTRA"  CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',
		  "ZADDRCD"	CHAR(255)   TERMINATED BY "," ENCLOSED BY '"'
		
		  
 )
  )
  location 
  (
    '/opt/ig/hitoku/user/output/outputTOTPAMMISTRA.csv'
  )
)REJECT LIMIT UNLIMITED;
/

--drop table TOTPAMMISTRA_EXT;

--select * from TOTPAMMISTRA_EXT; 