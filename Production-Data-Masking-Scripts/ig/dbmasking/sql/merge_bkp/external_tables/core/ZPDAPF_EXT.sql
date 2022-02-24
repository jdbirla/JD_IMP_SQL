CREATE TABLE "ZPDAPF_EXT" 
(
         "ZKANASNM01"	     VARCHAR2(60 CHAR),
         "ZKANAGNM01"	     VARCHAR2(60 CHAR),
         "LSURNAME01"	     VARCHAR2(60 CHAR),
         "LGIVNAME01"	     VARCHAR2(60 CHAR),
         "CLNTPHONE01"	     VARCHAR2(16 CHAR),
         "CLNTPHONE02"	     VARCHAR2(16 CHAR),
         "FAXNO01"	         VARCHAR2(16 CHAR),
         "RMBLPHONE01"	     VARCHAR2(16 CHAR),
         "ZKANADDR01"	     VARCHAR2(60 CHAR),
         "CLTADDR01"         VARCHAR2(30 CHAR),
         "ZKANADDR02"	     VARCHAR2(60 CHAR),
         "CLTADDR02"	     VARCHAR2(30 CHAR),
         "ZKANADDR03"	     VARCHAR2(60 CHAR),
         "CLTADDR03"	     VARCHAR2(30 CHAR),
         "ZKANADDR04"	     VARCHAR2(60 CHAR),
         "CLTADDR04"	     VARCHAR2(30 CHAR),
         "BANKACCKEY01"	     VARCHAR2(30 CHAR),
         "BANKACCDSC01"	     VARCHAR2(30 CHAR),
         "ZKANASNM02"	     VARCHAR2(60 CHAR),
         "ZKANAGNM02"	     VARCHAR2(60 CHAR),
         "LSURNAME02"	     VARCHAR2(60 CHAR),
         "LGIVNAME02"	     VARCHAR2(60 CHAR),
         "CLNTPHONE03"	     VARCHAR2(16 CHAR),
         "CLNTPHONE04"	     VARCHAR2(16 CHAR),
         "FAXNO02"	         VARCHAR2(16 CHAR),
         "RMBLPHONE02"	     VARCHAR2(16 CHAR),
         "ZKANADDR05"	     VARCHAR2(60 CHAR),
         "CLTADDR05"	     VARCHAR2(30 CHAR),
         "ZKANADDR06"	     VARCHAR2(60 CHAR),
         "CLTADDR06"	     VARCHAR2(30 CHAR),
         "ZKANADDR07"	     VARCHAR2(60 CHAR),
         "CLTADDR07"	     VARCHAR2(30 CHAR),
         "ZKANADDR08"	     VARCHAR2(60 CHAR),
         "CLTADDR08"	     VARCHAR2(30 CHAR)        
)
ORGANIZATION external 
(
  TYPE oracle_loader
  DEFAULT DIRECTORY EXT_DATA_DIR
  ACCESS PARAMETERS 
  (
    RECORDS DELIMITED BY NEWLINE CHARACTERSET JA16SJISTILDE
    BADFILE 'EXT_DATA_DIR':'ZPDAPF_EXT.bad'
    LOGFILE 'ZPDAPF_EXT.log_xt'
    READSIZE 1048576
    FIELDS TERMINATED BY ","  
    REJECT ROWS WITH ALL NULL FIELDS 
    (
       	 "ZKANASNM01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANAGNM01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "LSURNAME01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "LGIVNAME01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLNTPHONE01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLNTPHONE02"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "FAXNO01"	         CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "RMBLPHONE01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANADDR01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLTADDR01"         CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANADDR02"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLTADDR02"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANADDR03"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLTADDR03"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANADDR04"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLTADDR04"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "BANKACCKEY01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "BANKACCDSC01"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANASNM02"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANAGNM02"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "LSURNAME02"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "LGIVNAME02"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLNTPHONE03"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLNTPHONE04"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "FAXNO02"	         CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "RMBLPHONE02"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANADDR05"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLTADDR05"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANADDR06"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLTADDR06"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANADDR07"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLTADDR07"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "ZKANADDR08"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"',
         "CLTADDR08"	     CHAR(255 ) TERMINATED BY "," ENCLOSED BY '"'
       
    )
  )
  location 
  (
    '/opt/ig/hitoku/user/output/outputZPDAPF.csv'
  )
)REJECT LIMIT UNLIMITED;
/

-- drop table ZPDAPF_EXT;

-- select * from ZPDAPF_EXT; 