----------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO STAGE 3 TABLE FROM CSV FILE
--CODE DEVELOPED BY JD
--DATE 15 DEC 2017
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO PJ_TITDMGCOLRES TABLE FROM CSV FILE
----------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
TRUNCATE INTO TABLE TMP_PJ_TITDMGCOLRES
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
CHDRNUM "NVL(TRIM(:CHDRNUM ),' ')",
TRREFNUM "NVL(TRIM(:TRREFNUM ),' ')",
TFRDATE "NVL(TRIM(:TFRDATE ),' ')",
PSHCDE "NVL(TRIM(:PSHCDE ),' ')",
FACTHOUS "NVL(TRIM(:FACTHOUS ),' ')",
PRBILFDT "NVL(TRIM(:PRBILFDT ),' ')"
)
