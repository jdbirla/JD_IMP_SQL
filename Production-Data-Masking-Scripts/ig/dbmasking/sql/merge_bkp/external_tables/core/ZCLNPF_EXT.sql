CREATE TABLE "ZCLNPF_EXT" 
(
        "UNIQUE_NUMBER"  NUMBER(18,0), 
		"LSURNAME"	     VARCHAR2(60 CHAR), 
        "LGIVNAME"	     VARCHAR2(60 CHAR), 
        "ZKANASNM"	     VARCHAR2(60 CHAR), 
        "ZKANAGNM"	     VARCHAR2(60 CHAR), 
        "ZKANADDR01"	 VARCHAR2(60 CHAR), 
        "ZKANADDR02"	 VARCHAR2(60 CHAR), 
        "ZKANADDR03"	 VARCHAR2(60 CHAR), 
        "ZKANADDR04"	 VARCHAR2(60 CHAR), 
        "CLTADDR01"	     NCHAR(50 CHAR), 
        "CLTADDR02"	     NCHAR(50 CHAR), 
        "CLTADDR03"	     NCHAR(50 CHAR), 
        "CLTADDR04"	     NCHAR(50 CHAR), 
        "CLTPHONE01"	 CHAR(16 CHAR),
        "CLTPHONE02"	 CHAR(16 CHAR),
        "ZWORKPLCE"	     VARCHAR2(25 CHAR)
	
)
ORGANIZATION external 
(
  TYPE oracle_loader
  DEFAULT DIRECTORY EXT_DATA_DIR
  ACCESS PARAMETERS 
  (
    RECORDS DELIMITED BY NEWLINE CHARACTERSET JA16SJISTILDE
    BADFILE 'EXT_DATA_DIR':'ZCLNPF_EXT.bad'
    LOGFILE 'ZCLNPF_EXT.log_xt'
    READSIZE 1048576
    FIELDS TERMINATED BY ","  
    REJECT ROWS WITH ALL NULL FIELDS 
    (
        "UNIQUE_NUMBER"  CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',		
		"LSURNAME"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"LGIVNAME"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"ZKANASNM"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"ZKANAGNM"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"ZKANADDR01"     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"ZKANADDR02"     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"ZKANADDR03"     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"ZKANADDR04"     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"CLTADDR01"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"CLTADDR02"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"CLTADDR03"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"CLTADDR04"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',	
		"CLTPHONE01"     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',
		"CLTPHONE02"     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"',
        "ZWORKPLCE"	     CHAR(255)   TERMINATED BY "," ENCLOSED BY '"'
	)
  )
  location 
  (
    '/opt/ig/hitoku/user/output/outputZCLNPF.csv'
  )
)REJECT LIMIT UNLIMITED;
/

--drop table ZCLNPF_EXT;

--select * from ZCLNPF_EXT; 