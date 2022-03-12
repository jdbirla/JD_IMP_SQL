--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY jdc-Kevin
--DATE 28 FEB 2018
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO TMP_ZMRDA00 TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
REPLACE INTO TABLE TMP_ZMRDA00
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
DAPLNO,
DAB5TX,
DAB6TX,
DACBIG,
DACCIG,
DAC9CD,
DAB0TX,
DAB1TX,
DAB2TX,
DAB3TX,
DAB7IG,
DAB8IG,
DAB9IG,
DACAIG,
DAB4TX,
DAYOB1,
DAYOB2,
DAYOB3,
DAYOB4,
DAYOB5,
DAYOB6,
DAYOB7,
DAYOB8,
DABOCD,
DABPCD,
DAAMDT,
DAAATM,
DABQCD,
DAANDT,
DAABTM,
DABRCD,
DAB6IG
)