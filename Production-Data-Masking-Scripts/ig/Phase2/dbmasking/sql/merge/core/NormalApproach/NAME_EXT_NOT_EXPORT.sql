CREATE TABLE "NAME_EXT" 
(
        "ZRPTYPE"	  VARCHAR2(1 BYTE),
        "CRDTCARD"	  VARCHAR2(20 BYTE),
        "BANKACCKEY"  VARCHAR2(20 BYTE)      
)
ORGANIZATION external 
(
  TYPE oracle_loader
  DEFAULT DIRECTORY EXT_DATA_DIR
  ACCESS PARAMETERS 
  (
    RECORDS DELIMITED BY NEWLINE CHARACTERSET JA16SJISTILDE
    BADFILE 'EXT_DATA_DIR':'NAME_EXT.bad'
    LOGFILE 'NAME_EXT.log_xt'
    READSIZE 1048576
    FIELDS TERMINATED BY ","  
    REJECT ROWS WITH ALL NULL FIELDS 
    (
        "ZRPTYPE"     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',		
		"CRDTCARD"	  CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"BANKACCKEY"  CHAR(255)   TERMINATED BY "," ENCLOSED BY '"'			
		
	)
  )
  location 
  (
    'outputNAME.csv'
  )
)REJECT LIMIT UNLIMITED;
/

--drop table NAME_EXT;

--select * from NAME_EXT; 