CREATE TABLE "CLEXPF_EXT" 
(
        "UNIQUE_NUMBER"	   NUMBER(18,0),
		"FAXNO"	        CHAR(16 CHAR),
		"RINTERNET"		CHAR(50 CHAR),
		"RINTERNET2"			NCHAR(50 CHAR)


            
                                                  
                                                  
)
ORGANIZATION external 
(
  TYPE oracle_loader
  DEFAULT DIRECTORY EXT_DATA_DIR
  ACCESS PARAMETERS 
  (
    RECORDS DELIMITED BY NEWLINE CHARACTERSET JA16SJISTILDE
    BADFILE 'EXT_DATA_DIR':'CLEXPF_EXT.bad'
    LOGFILE 'CLEXPF_EXT.log_xt'
    READSIZE 1048576
    FIELDS TERMINATED BY ","  
    REJECT ROWS WITH ALL NULL FIELDS 
    (
	
		"UNIQUE_NUMBER"	CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',
		"FAXNO"	        CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',
		"RINTERNET"		CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',
		"RINTERNET2"	CHAR(255)   TERMINATED BY "," ENCLOSED BY '"'
	
 )
  )
  location 
  (
    '/opt/ig/hitoku/user/output/outputCLEXPF.csv'
  )
)REJECT LIMIT UNLIMITED;
/

--drop table CLEXPF_EXT;

--select * from CLEXPF_EXT; 