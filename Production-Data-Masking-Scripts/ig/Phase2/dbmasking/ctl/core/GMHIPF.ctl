OPTIONS (DIRECT=TRUE)
UNRECOVERABLE
LOAD DATA
REPLACE
INTO TABLE VM1DTA.GMHIPF
FIELDS TERMINATED BY "," ENCLOSED BY '"'
TRAILING NULLCOLS
(
UNIQUE_NUMBER,
CHDRCOY      ,
CHDRNUM      ,
MBRNO        ,
EFFDATE      ,
DTETRM       ,
SUBSCOY      ,
SUBSNUM      ,
OCCPCODE     ,
SALARY       ,
DTEAPP       ,
SBSTDL       ,
TERMID       ,
USER_T       ,
TRDT         ,
TRTM         ,
TRANNO       ,
FUPFLG       ,
DPNTNO       ,
CLIENT       ,
PERSONCOV    ,
MLVLPLAN     ,
CLNTCOY      ,
PCCCLNT      ,
APCCCLNT     ,
EARNING      ,
CTBPRCNT     ,
CTBAMT       ,
USRPRF       ,
JOBNM        ,
DATIME       ,
ISSTAFF      ,
ZWRKPCT      ,
ZTRXSTAT     ,
ZSTATRESN    ,
QUOTENO      ,
ZPLANCDE     ,
HPROPDTE     ,
NOTSFROM     ,
DOCRCDTE     ,
DCLDATE      ,
ZDECLCAT     ,
ZDCLITEM01   ,
ZDCLITEM02   ,
ZDCRSNCD     ,
ADDRINDC     ,
ZADCHCTL     ,
ZMARGNFLG    ,
ZDFCNCY      ,
ZINHDSCLM    ,
ZCPNSCDE     ,
ZPRMSI       ,
DATATYPE     ,
ZINTENT      ,
ZCENDDTE     ,
ZWORKPLCE1   ,
ZWORKPLCE2   ,
ZPOLDTFLG
)
