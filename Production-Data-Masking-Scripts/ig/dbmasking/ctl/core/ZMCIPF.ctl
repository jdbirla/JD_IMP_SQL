OPTIONS (DIRECT=TRUE)
UNRECOVERABLE
LOAD DATA
REPLACE
INTO TABLE VM1DTA.ZMCIPF
FIELDS TERMINATED BY "," ENCLOSED BY '"'
TRAILING NULLCOLS
(
UNIQUE_NUMBER,
CHDRNUM      ,
TRANNO       ,
ZENDCDE      ,
ZENSPCD01    ,
ZENSPCD02    ,
ZCIFCODE     ,
CRDTCARD     ,
BANKACCKEY01 ,
BANKACCDSC01 ,
BANKKEY      ,
BNKACTYP01   ,
BNKACTYP02   ,
ZPBCTYPE     ,
ZPBCODE      ,
BANKACCKEY02 ,
BANKACCDSC02 ,
PREAUTNO     ,
MTHTO        ,
YEARTO       ,
CARDTYP      ,
USRPRF       ,
JOBNM        ,
DATIME       ,
EFFDATE      ,
ZDDREQNO
)
