--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY JD
--DATE 26 DEC 2017
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO ZMREIOO TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
REPLACE INTO TABLE ZMREI00
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
EICUCD,
EIPLNO,
EIA2DT,
EIBEDT,
EICTID,
EIYOB1,
EIYOB2,
EIYOB3,
EIYOB4,
EIYOB5,
EIYOB6,
EIYOB7,
EIYOB8,
EIYOB9,
EIYOBA,
EIBOCD,
EIBPCD,
EIAMDT,
EIAATM,
EIBQCD,
EIANDT,
EIABTM,
EIBRCD,
EIB6IG
)
