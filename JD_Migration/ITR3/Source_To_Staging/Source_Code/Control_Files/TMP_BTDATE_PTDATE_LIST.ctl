--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY JD
--DATE 26 DEC 2017
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO BTDATE_PTDATE_LIST TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
TRUNCATE INTO TABLE TMP_BTDATE_PTDATE_LIST
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
CHDRNUM "TRIM(:CHDRNUM)",
PTDATE "TRIM(:PTDATE)",
BTDATE "TRIM(:BTDATE)",
STATCODE "TRIM(:STATCODE)",
ZPGPFRDT "TRIM(:ZPGPFRDT)",
ZPGPTODT "TRIM(:ZPGPTODT)",
ENDSERCD "TRIM(:ENDSERCD)"
)
