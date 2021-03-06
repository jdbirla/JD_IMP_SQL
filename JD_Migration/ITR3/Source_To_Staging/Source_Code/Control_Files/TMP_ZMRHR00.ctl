--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY jdc
--DATE 5 Nov 2021
--ZJNPG-10201
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO TMP_ZMRHR00 TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
REPLACE INTO TABLE TMP_ZMRHR00
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(HRYM,
HRC6CD,
HRC7CD,
HRA3ST1,
HRBONB1,
HRCUCD,
HRBEDT,
HRCICD1,
HRBVIG1,
HRATDT1,
HRCVVA1,
HRB3VAO1,
HRB3VAN1,
HRCICD2,
HRBVIG2,
HRBONB2,
HRA3ST2,
HRATDT2,
HRCVVA2,
HRB3VAO2,
HRB3VAN2,
HRDUPF,
OUTJOB,
OUTDATE,
OUTTIME
)

