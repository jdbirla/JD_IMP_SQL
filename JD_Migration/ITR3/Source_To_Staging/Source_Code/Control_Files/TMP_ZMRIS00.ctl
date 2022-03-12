--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY JD
--DATE 26 DEC 2017
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO TMP_ZMRISOO TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
REPLACE INTO TABLE TMP_ZMRIS00
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
ISCUCD,
ISCICD,
ISCJCD,
ISCMCD,
ISCNCD,
ISCOCD,
ISBTIG,
ISBUIG,
ISBVIG,
ISBWIG,
ISATDT,
ISB0NB,
ISA3ST,
ISA4ST,
ISBXIG,
ISBYIG,
ISBZIG,
ISB0IG,
ISBYTX,
ISBZTX,
ISA5ST,
ISB1IG,
ISCPCD,
ISCVVA,
ISCFST,
ISGJCD,
ISBOCD,
ISBPCD,
ISAMDT,
ISAATM,
ISBQCD,
ISANDT,
ISABTM,
ISBRCD,
ISB6IG,
B1_ZKNJFULNM,
B1_CLTADDR01,
B1_BNYPC,
B1_BNYRLN,
B2_ZKNJFULNM,
B2_CLTADDR01,
B2_BNYPC,
B2_BNYRLN,
B3_ZKNJFULNM,
B3_CLTADDR01,
B3_BNYPC,
B3_BNYRLN,
B4_ZKNJFULNM,
B4_CLTADDR01,
B4_BNYPC,
B4_BNYRLN,
B5_ZKNJFULNM,
B5_CLTADDR01,
B5_BNYPC,
B5_BNYRLN
)


