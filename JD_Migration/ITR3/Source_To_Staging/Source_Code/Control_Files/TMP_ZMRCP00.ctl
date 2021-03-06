--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY JD
--DATE 26 DEC 2017
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO ZMRCPOO TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
TRUNCATE INTO TABLE TMP_ZMRCP00
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
CPBCCD,
CPBDCD,
CPBECD,
CPBFCD,
CPEUST,
CPF8CD,
CPENIG,
CPMTIG,
CPEECD,
CPEDCD,
CPAGDT,
CPA0VA,
CPA1VA,
CPBICD,
CPBJCD,
CPBKCD,
CPBLCD,
CPBMCD,
CPBBTX,
CPA2VA,
CPA3VA,
CPA4VA,
CPBNCD,
CPAYIG,
CPA5VA,
CPA6VA,
CPA7VA,
CPA8VA,
CPBBVA,
CPCSVA,
CPA9VA,
CPBAVA,
CPBCTX,
CPAHDT,
CPBDTX,
CPAIDT,
CPBETX,
CPAJDT,
CPBFTX,
CPAKDT,
CPBGTX,
CPALDT,
CPBHTX,
CPB7NB,
CPHVCE,
CPHYCE,
CPHZCE,
CPPCNB,
CPV8IG,
CPJSTX,
CPBOCD,
CPBPCD,
CPAMDT,
CPAATM,
CPBQCD,
CPANDT,
CPABTM,
CPBRCD,
CPB6IG
)

