--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY KEVIN SARMIENTO
--DATE 4 DEC 2020
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO TITDMGSUMINSFACTOR TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
REPLACE INTO TABLE TITDMGSUMINSFACTOR
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
ZINSTYPE,
DM_PRODTYP,
DNMTOR
)