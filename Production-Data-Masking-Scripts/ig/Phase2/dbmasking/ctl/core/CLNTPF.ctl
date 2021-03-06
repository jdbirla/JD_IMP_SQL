OPTIONS (DIRECT=TRUE)
UNRECOVERABLE
LOAD DATA
REPLACE
INTO TABLE VM1DTA.CLNTPF
FIELDS TERMINATED BY "," ENCLOSED BY '"'
TRAILING NULLCOLS
(
UNIQUE_NUMBER	,
CLNTPFX          ,
CLNTCOY          ,
CLNTNUM          ,
TRANID           ,
VALIDFLAG        ,
CLTTYPE          ,
SECUITYNO        ,
PAYROLLNO        ,
SURNAME          ,
GIVNAME          ,
SALUT            ,
INITIALS         ,
CLTSEX           ,
CLTADDR01        ,
CLTADDR02        ,
CLTADDR03        ,
CLTADDR04        ,
CLTADDR05        ,
CLTPCODE         ,
CTRYCODE         ,
MAILING          ,
DIRMAIL          ,
ADDRTYPE         ,
CLTPHONE01       ,
CLTPHONE02       ,
VIP              ,
OCCPCODE         ,
SERVBRH          ,
STATCODE         ,
CLTDOB           ,
SOE              ,
DOCNO            ,
CLTDOD           ,
CLTSTAT          ,
CLTMCHG          ,
MIDDL01          ,
MIDDL02          ,
MARRYD           ,
TLXNO            ,
FAXNO            ,
TGRAM            ,
BIRTHP           ,
SALUTL           ,
ROLEFLAG01       ,
ROLEFLAG02       ,
ROLEFLAG03       ,
ROLEFLAG04       ,
ROLEFLAG05       ,
ROLEFLAG06       ,
ROLEFLAG07       ,
ROLEFLAG08       ,
ROLEFLAG09       ,
ROLEFLAG10       ,
ROLEFLAG11       ,
ROLEFLAG12       ,
ROLEFLAG13       ,
ROLEFLAG14       ,
ROLEFLAG15       ,
ROLEFLAG16       ,
ROLEFLAG17       ,
ROLEFLAG18       ,
ROLEFLAG19       ,
ROLEFLAG20       ,
ROLEFLAG21       ,
ROLEFLAG22       ,
ROLEFLAG23       ,
ROLEFLAG24       ,
ROLEFLAG25       ,
ROLEFLAG26       ,
ROLEFLAG27       ,
ROLEFLAG28       ,
ROLEFLAG29       ,
ROLEFLAG30       ,
ROLEFLAG31       ,
ROLEFLAG32       ,
ROLEFLAG33       ,
ROLEFLAG34       ,
ROLEFLAG35       ,
STCA             ,
STCB             ,
STCC             ,
STCD             ,
STCE             ,
PROCFLAG         ,
TERMID           ,
USER_T           ,
TRDT             ,
TRTM             ,
SNDXCDE          ,
NATLTY           ,
FAO              ,
CLTIND           ,
STATE            ,
LANGUAGE         ,
CAPITAL          ,
CTRYORIG         ,
ECACT            ,
ETHORIG          ,
SRDATE           ,
STAFFNO          ,
LSURNAME         ,
LGIVNAME         ,
TAXFLAG          ,
USRPRF           ,
JOBNM            ,
DATIME           ,
IDTYPE           ,
Z1GSTREGN        ,
Z1GSTREGD        ,
KANJISURNAME     ,
KANJIGIVNAME     ,
KANJICLTADDR01   ,
KANJICLTADDR02   ,
KANJICLTADDR03   ,
KANJICLTADDR04   ,
KANJICLTADDR05   ,
EXCEP            ,
ZKANASNM         ,
ZKANAGNM         ,
ZKANADDR01       ,
ZKANADDR02       ,
ZKANADDR03       ,
ZKANADDR04       ,
ZKANADDR05       ,
ZADDRCD          ,
ABUSNUM          ,
BRANCHID         ,
ZKANASNMNOR      ,
ZKANAGNMNOR      ,
TELECTRYCODE     ,
TELECTRYCODE1    ,
ZDLIND           ,
DIRMKTMTD        ,
PREFCONMTD       ,
ZOCCDSC          ,
OCCPCLAS         ,
ZWORKPLCE        ,
CLNTSTATECD      ,
FUNDADMINFLAG    ,
PROVINCE         ,
SEQNO            
)
