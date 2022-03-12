--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY JD
--DATE 26 DEC 2017
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO TITDMGCAMPCDE TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
TRUNCATE INTO TABLE TMP_TITDMGCAMPCDE
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
ZCMPCODE "NVL(TRIM(:ZCMPCODE ),' ')",
ZPETNAME "NVL(TRIM(:ZPETNAME ),' ')",
ZPOLCLS "NVL(TRIM(:ZPOLCLS ),' ')",
ZENDCODE "NVL(TRIM(:ZENDCODE ),' ')",
CHDRNUM "NVL(TRIM(:CHDRNUM ),' ')",
GPOLTYP "NVL(TRIM(:GPOLTYP ),' ')",
ZAGPTID "NVL(TRIM(:ZAGPTID ),' ')",
RCDATE "NVL(TRIM(:RCDATE ),0)",
ZCMPFRM "NVL(TRIM(:ZCMPFRM ),0)",
ZCMPTO "NVL(TRIM(:ZCMPTO ),0)",
ZMAILDAT "NVL(TRIM(:ZMAILDAT ),0)",
ZACLSDAT "NVL(TRIM(:ZACLSDAT ),0)",
ZDLVCDDT "NVL(TRIM(:ZDLVCDDT ),0)",
ZVEHICLE "NVL(TRIM(:ZVEHICLE ),' ')",
ZSTAGE "NVL(TRIM(:ZSTAGE ),' ')",
ZSCHEME01 "NVL(TRIM(:ZSCHEME01 ),' ')",
ZSCHEME02 "NVL(TRIM(:ZSCHEME02 ),' ')",
ZCRTUSR "NVL(TRIM(:ZCRTUSR ),' ')",
ZAPPDATE "NVL(TRIM(:ZAPPDATE ),0)",
ZCCODIND "NVL(TRIM(:ZCCODIND ),' ')",
EFFDATE "NVL(TRIM(:EFFDATE ),0)",
STATUS "NVL(TRIM(:STATUS ),' ')"
)