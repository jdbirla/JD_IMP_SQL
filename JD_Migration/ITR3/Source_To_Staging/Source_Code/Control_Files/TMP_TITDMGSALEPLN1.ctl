--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY JD
--DATE 26 DEC 2017
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO TITDMGSALEPLN1 TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
TRUNCATE INTO TABLE TMP_TITDMGSALEPLN1
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
ZSALPLAN "NVL(TRIM(:ZSALPLAN ),' ')",
ZINSTYPE "NVL(TRIM(:ZINSTYPE ),' ')",
PRODTYP "NVL(TRIM(:PRODTYP ),' ')",
SUMINS "NVL(TRIM(:SUMINS ),0)",
ZCOVRID "NVL(TRIM(:ZCOVRID ),' ')",
ZIMBRPLO "NVL(TRIM(:ZIMBRPLO ),' ')"

)