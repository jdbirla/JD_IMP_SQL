CREATE TABLE "CLBAPF_EXT" 
(
        "UNIQUE_NUMBER"	NUMBER(18,0)  ,
		"BANKACCKEY"	CHAR(20 CHAR),
		"BANKACCDSC"	CHAR(30 CHAR)

            
                                                  
                                                  
)
ORGANIZATION external 
(
  TYPE oracle_loader
  DEFAULT DIRECTORY EXT_DATA_DIR
  ACCESS PARAMETERS 
  (
    RECORDS DELIMITED BY NEWLINE CHARACTERSET JA16SJISTILDE
    BADFILE 'EXT_DATA_DIR':'CLBAPF_EXT.bad'
    LOGFILE 'CLBAPF_EXT.log_xt'
    READSIZE 1048576
    FIELDS TERMINATED BY ","  
    REJECT ROWS WITH ALL NULL FIELDS 
    (
	
	 
	   "UNIQUE_NUMBER"	CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',
		"BANKACCKEY"	CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',
		"BANKACCDSC"	CHAR(255)   TERMINATED BY "," ENCLOSED BY '"'
	
 )
  )
  location 
  (
    '/opt/ig/hitoku/user/output/outputCLBAPF.csv'
  )
)REJECT LIMIT UNLIMITED;
/

--drop table CLBAPF_EXT;

--select * from CLBAPF_EXT; 