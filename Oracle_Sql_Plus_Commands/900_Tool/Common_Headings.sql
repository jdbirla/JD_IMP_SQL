/*
	Headings
*/

col CHDRNUM  format a9 heading  'Policy No|CHDRNUM'
col STATCODE  format a13 heading  'Policy Status|STATCODE'
col ZTRXSTAT  format a11 heading  'Trx Stat CD|ZTRXSTAT'

col OCCDATE  format a13 heading  'OCC Date|OCCDATE'
col NRISDATE  format a12 heading  'Pol Issue Dt|NRISDATE'
col NOTSFROM  format a19 heading  'Agrmnt Dt Ntfctn Dt|NOTSFROM'
col CCDATE    format a12 heading  'Policy St Dt|CCDATE'
col CRDATE    format a12 heading  'Renweal Date|CRDATE'
col ZPENDDT   format a12 heading  'Pol End Date|ZPENDDT'
col ZPOLTDATE format a11 heading  'Pol Term Dt|ZPOLTDATE'
col EFFDCLDT  format a13 heading  'Pol Cancel Dt|EFFDCLDT'
col ZPOLPERD  format a10 heading  'Pol Rediod|ZPOLPERD'
col ZGPORIPCLS  format a15 heading  'Grp Classifictn|ZGPORIPCLS'
col ZPLANCLS  format a16 heading  'Plan Classifictn|ZPLANCLS'
col BTDATE  format a13 heading  'Billed To Dt|BTDATE'
col PTDATE  format a13 heading  'Paid To Dt|PTDATE'
col ZPGPFRDT  format a9 heading  'PGP St Dt|ZPGPFRDT'
col ZPGPTODT  format a9 heading  'PGP Ed Dt|ZPGPTODT'
col ZCMPCODE  format a13 heading 'Campaign Code|ZCMPCODE'
col ZSALECHNL  format a11 heading  'Sales Chnnl|ZSALECHNL'
col MPLNUM  format a13 heading  'Master Policy|MPLNUM'
col ZPRVCHDR  format a11 heading  'Prev Pol No|ZPRVCHDR'
col ZENDCDE  format a20 heading  'Endorser Code|ZENDCDE'
col ZANNCLDT  format a13 heading  'Accm Cls Date|ZANNCLDT'
col AGE  format a11 heading  'Insured Age|AGE'
col COWNNUM  format a13 heading  'Ownwer Client|COWNNUM'
col CLNTNUM  format a14 heading  'Insured Client|CLNTNUM'
col ZALTRECD format a10 heading 'Alt Rsn Cd|ZALTRECD'
col ZRQBKRDF format a12 heading 'Bnk Req Form|ZRQBKRDF'
col ZREFMTCD format a12 heading 'Refund Mthd|ZREFMTCD'
col ZLAPTRX format a7 heading 'ZLAPTRX'



col CHGFLAG  format a11 heading  'Change Flag|CHGFLAG'
col ZDCLITEM01 format a10 heading  'Decl Item1|ZDCLITEM01'
col ZDCLITEM02 format a10 heading  'Decl Item2|ZDCLITEM02'

col BILLTYP format A7 heading 'BILLTYP'
col PREMOUT format A7 heading 'PREMOUT'
col ZSTPBLYN format A12 heading '2nd Stp Bill|ZSTPBLYN'
col ZPOSBDSY format A12 heading 'Posting Year|ZPOSBDSY'
col ZPOSBDSM format A13 heading 'Posting Month|ZPOSBDSM'
col ZACMCLDT format A8 heading 'ACD|ZACMCLDT'
col ZBKTRFDT format A15 heading 'Bank Transfr Dt|ZBKTRFDT'
col RDOCPFX format A10 heading 'Doc Prefix|RDOCPFX'
col RDOCCOY format A11 heading 'Doc Company|RDOCCOY'
col RDOCNUM format A10 heading 'Doc Ref No|RDOCNUM'
col REVFLAG format A12 heading 'Reverse Flag|REVFLAG'

col ZAPLFOD format A10 heading 'App Form|Ptint Date|ZAPLFOD'
col FLAGPRINT format A10 heading 'Flag Print|FLAGPRINT'

col CNTBRANCH format A14 heading 'Service Branch|ZPOSBDSM'

-- col UNIQUE_NUMBER
col CHDRCOY         format a8 heading 'CHDRCOY'
col CHDRNUM         format a8 heading 'CHDRNUM'
-- col TRANNO
col TRANCDE       format a7 heading 'TRANCDE'
col ZQUOTIND       format a8 heading 'ZQUOTIND'
--col EFDATE
--col EFFDATE
col ZLOGALTDT          format a8 heading 'ZLOGALTDT'
col ZALTREGDAT         format a10 heading 'ZALTREGDAT'
col ZALTRCDE01         format a10 heading 'Alt Rsn 1|ZALTRCDE01'
col ZALTRCDE02         format a10 heading 'Alt Rsn 2|ZALTRCDE02'
col ZALTRCDE03         format a10 heading 'Alt Rsn 3|ZALTRCDE03'
col ZALTRCDE04         format a10 heading 'Alt Rsn 4|ZALTRCDE04'
col ZALTRCDE05         format a10 heading 'Alt Rsn 5|ZALTRCDE05'
col ZFINANCFLG         format a10 heading 'ZFINANCFLG'
--col ZCLMRECD
col ZINHDSCLM          format a9 heading 'ZINHDSCLM'
--col ZFINALBYM
col ZUWREJFLG          format a9 heading 'ZUWREJFLG'
col ZVIOLTYP           format a8 heading 'ZVIOLTYP'
col ZSTOPBPJ           format a8 heading 'ZSTOPBPJ'
col ZDFCNCY            format a8 heading 'ZDFCNCY'
col ZMARGNFLG          format a8 heading 'ZMARGNFLG'
--col DOCRCDTE           format a8 heading 'DOCRCDTE'
--col HPROPDTE           format a8 heading 'HPROPDTE'
col ZTRXSTAT           format a8 heading 'ZTRXSTAT'
col ZSTATRESN           format a9 heading 'ZSTATRESN'
--col ZACLSDAT
--col APPRDTE
--col ZPOLDATE
--col AGE
--col MBRNO
col DPNTNO           format a8 heading 'DPNTNO'
--col UNIQUE_NUMBER_01
--col UNIQUE_NUMBER_02
--col ALTQUOTENO
col ZPDATATXDAT         format a14 heading 'Pol Data Tr Dt|ZPDATATXDAT'
col ZPDATATXFLG         format a15 heading 'Pol Data Tr Flg|ZPDATATXFLG'
--col ZREFUNDAM
--col ZSURCHRGE
col ZSALPLNCHG           format a8 heading 'ZSALPLNCHG'
-- col ZORIGSALP
col ZPAYINREQ           format a8 heading 'ZPAYINREQ'
--col USRPRF
--col JOBNM
col DATIME   format a32 heading  'Date Time |DATIME'
--col ZCPMTDDT
col ZSHFTPGP           format a8 heading 'ZSHFTPGP'
col ZCSTPBIL           format a8 heading 'ZCSTPBIL'
col ZCPMCPNCDE          format a8 heading 'ZCPMCPNCDE'
--col ZCPMPLANCD
--col ZCPMBILAMT
col ZBDPGPSET          format a8 heading 'ZBDPGPSET'
col ZDFBLIND           format a8 heading 'ZDFBLIND'
--col ZRVTRANNO
--col ZBLTRANNO
col STATCODE           format a8 heading 'STATCODE'

col ZCOLFLAG format a16 heading 'Pending Coll Flg|ZCOLFLAG'

col ZCHDRCOY         format a8 heading "ZCHDRCOY"
col ZCHDRNUM         format a8 heading "ZCHDRNUM"

col ZRFDST format a15 heading 'Main Ref Status|ZRFDST'
col ZENRFDST format a17 heading 'Endorser Ref Stat|ZENRFDST'
col ZZHRFDST format a15 heading 'Zurich Ref Stat|ZZHRFDST'

col VALIDFLAG format a10 heading 'Valid Flag|VALIDFLAG'

col BATCCOY format a7 heading 'BATCCOY'
col BATCBRN format a7 heading 'BATCBRN'
col BATCACTYR format a9 heading 'BATCACTYR'
col BATCACTMN format a7 heading 'BATCACTMN'
col BATCTRCD format a8 heading 'BATCTRCD'
col BATCBATCH format a9 heading 'BATCBATCH'
col BATCPFX format a7 heading 'BATCPFX'
col EXTRFLAG format a8 heading 'EXTRFLAG'
col STATUSTYP format a9 heading 'STATUSTYP'
col NOCOMNFLG format a9 heading 'NOCOMNFLG'


col ZENCDSDT       format a13 heading 'Endrsr Status|ZENCDSDT'
col ZFACTHUS       format a8 heading 'FH|ZFACTHUS'
col ZENDFH         format a8 heading 'FH|ZENDFH'
col ZCOLM          format a11 heading 'Coll Method|ZCOLM'


col PLANNO         format a8 heading 'PLANNO'
col PRODTYP        format a8 heading 'PRODTYP'
col ZINSTYPE       format a8 heading 'ZINSTYPE'
col THREADNO       format a8 heading 'THREADNO"'
col ZWAITPEDT      format a14 heading 'Waiting Period|ZWAITPEDT'
col ZTAXFLG        format a8 heading 'ZTAXFLG'

col LANGUAGE format a8 heading 'Language|LANGUAGE'

col ZBNKFLAG  format a13 heading  'BA Input|ZBNKFLAG'
col ZCCFLAG  format a13 heading  'CC Input|ZCCFLAG'
col ZCIFFLAG  format a13 heading  'CIF Input|ZCIFFLAG'
col ZENFLG1  format a13 heading  'ESC1 Input|ZENFLG1'
col ZENFLG2  format a13 heading  'ESC2 Input|ZENFLG2'
col BILLIND01  format a13 heading  'BA for Bill|BILLIND01'
col BILLIND02  format a13 heading  'CC for Bill|BILLIND02'
col BILLIND03  format a13 heading  'CIF for Bill|BILLIND03'
col BILLIND04  format a13 heading  'ESC1 for Bill|BILLIND04'
col BILLIND05  format a13 heading  'ESC2 for Bill|BILLIND05'
col ZJPBFLG  format a13 heading  'JBP Reqred|ZJPBFLG'
col ZMBRNOID  format a13 heading  'Use Membr No|ZMBRNOID'


col FACTHOUS  format a15 heading  'Factoring House|FACTHOUS'
col CNTTYPE  format a13 heading  'Contract Type|CNTTYPE'
col ZINSTYPE  format a15 heading  'Insurance Type|ZINSTYPE'
col BNKACCTYP  format a13 heading  'Bank Acc Type|BNKACCTYP'
col ZBILSTAT  format a13 heading  'Bill Status|ZBILSTAT'
col PAYPLAN  format a13 heading  'Pay Plan|PAYPLAN'
col STREASON format a13 heading  'Status Reason|STREASON'
col ZCOLLTYP format a15 heading  'Collection Type|ZCOLLTYP'
col ZIGFLAG  format a8 heading  'IG Flag|ZIGFLAG'

col ZRPTYPE format a11 heading  'Report type|ZRPTYPE'

col BANKCODE format A9 heading 'Bank Code|BANKCODE'
col MARRYFLAG format A10 heading 'Marry Flag|MARRYFLAG'
col ZPYINMTD format A22 heading 'Pay-In Method|ZPYINMTD'
col ZXCESSYN format A10 heading 'Excess Y/N|ZXCESSYN'

col CHDRPFX format a7 heading 'CHDRPFX'
col DSHCDE format a6 heading 'DSHCDE'

col BNKACTYP format a8 heading 'BNKACTYP'
col ZPBCODE  format a7 heading 'ZPBCODE'
col MTHTO    format a6 heading 'MTHTO'
col YEARTO   format a6 heading 'YEARTO'

col ZMSTID   format A15 heading 'Mem Store ID|ZMSTID'
col ZMSTSNME format A60 heading 'Mem Store Name	|ZMSTSNME'
col ZCRDTYPE format A9  heading 'Card Type|ZCRDTYPE'
col ZCONSGNM format A60 heading 'Consignor Name|ZCONSGNM'
col ZPREFIX  format A7 heading 'Prefix|ZPREFIX'
col ZMSTIDV  format A21 heading 'Mem Store ID Validity|ZMSTIDV'
col ZMSTSNMEV  format A60 heading 'Mem Store Name Validity|ZMSTSNMEV'
col ZCARDDC  format A16 heading 'Card Digit Count|ZCARDDC'
         

col ZSYSIMP01 format A10  heading 'Sys Imp 1|ZSYSIMP01'
col ZSYSIMP02 format A10  heading 'Sys Imp 2|ZSYSIMP02'
col ZSYSIMP03 format A10  heading 'Sys Imp 3|ZSYSIMP03'

col ZBUZFLG format A8  heading 'Bus Days|ZBUZFLG'
col ZPMDAY  format A10  heading 'No of Days|ZPMDAY'
col ZPMWEHO format A8  heading 'Week End|ZPMWEHO'


col ZVLDTRXIND format A10  heading 'ZVLDTRXIND'
col ZRCALTTY format A8  heading 'ZRCALTTY'
col ZDCLITEM03 format A10  heading 'ZDCLITEM03'
col ZTRXSTSIND format A8  heading 'ZTRXSTSIND'
col ZINSROLE format A10  heading 'ZINSROLE'
col ZRTRANNO format A8  heading 'ZRTRANNO'
col TERMDTE format A10  heading 'TERMDTE'
col OCCPCODE format A10  heading 'OCCPCODE'
col ZBLNKPOL format A8  heading 'ZBLNKPOL'
col ZRNWABL format A7  heading 'ZRNWABL'
col ZGPMPPP format A6  heading 'ZGPMPPP'
col ZWAVGFLG format A8 heading 'ZWAVGFLG'
col ZNBALTPR format A8  heading 'ZNBALTPR'
col BILLFREQ format A8  heading 'BILLFREQ'
col ZSOLCTFLG format A9  heading 'ZSOLCTFLG'
col ZRCORADR format A8  heading 'ZRCORADR'
col ZTESTTYP format A8  heading 'ZTESTTYP'
col ZBACKDATED format A10  heading 'ZBACKDATED'
col ZRECEPFG format A8  heading 'ZRECEPFG'
col ZSLPTYP format A7  heading 'ZSLPTYP'
col PREFIX format A6  heading 'PREFIX'
col DM_OR_IG format A8  heading 'DM_OR_IG'
col CLNTSTAS format A8  heading 'CLNTSTAS'
col IS_UPDATE_REQ format A13  heading 'IS_UPDATE_REQ'
col ZENTITY format A10  heading 'ZENTITY'
col ZIGVALUE format A8  heading 'ZIGVALUE'
col JOBNUM format A8  heading 'JOBNUM'
col JOBNAME format A10  heading 'JOBNAME'
col ZCOVRID format A7  heading 'ZCOVRID'
col ZIMBRPLO format A8  heading 'ZIMBRPLO'
col CLRRROLE format A8  heading 'CLRRROLE'
col FOREPFX format A7  heading 'FOREPFX'
col FORECOY format A7  heading 'FORECOY'
col ADMNOPER01 format A10  heading 'ADMNOPER01'
col ADMNOPER02 format A10  heading 'ADMNOPER02'
col ADMNOPER03 format A10  heading 'ADMNOPER03'
col ADMNOPER04 format A10  heading 'ADMNOPER04'
col ADMNOPER05 format A10  heading 'ADMNOPER05'
col ZAGPTPFX format A8  heading 'ZAGPTPFX'
col ZAGPTCOY format A8  heading 'ZAGPTCOY'
col GPLOTYP format A7  heading 'GPLOTYP'
col ZPETNAME format A15  heading 'ZPETNAME'
col ZVEHICLE format A8  heading 'ZVEHICLE'
col ZSTAGE format A6  heading 'ZSTAGE'
col ZSCHEME01 format A9  heading 'ZSCHEME01'
col ZSCHEME02 format A9  heading 'ZSCHEME02'
col ZPOLCLS format A7  heading 'ZPOLCLS'
col ZCRTUSR format A7  heading 'ZCRTUSR'
col ZAPPDATE format A8  heading 'ZAPPDATE'
col ZCCODIND format A8  heading 'ZCCODIND'
col STATUS format A6  heading 'STATUS'
col SERVUNIT format A8  heading 'SERVUNIT'
col BRANCH format A6  heading 'BRANCH'
col ZDUPLEX format A7  heading 'ZDUPLEX'
col ZENVSEQN format A8  heading 'ZENVSEQN'
col ZDSPCATG format A8  heading 'ZDSPCATG'
col ZLETVERN format A8  heading 'ZLETVERN'
col ZLETDEST format A8  heading 'ZLETDEST'
col ZCOMADDR format A8  heading 'ZCOMADDR'
col ZRMPDYN01 format A9  heading 'ZRMPDYN01'
col ZRMPDYN02 format A9  heading 'ZRMPDYN02'
col ZRMPDYN03 format A9  heading 'ZRMPDYN03'

col ZLETCAT format A7  heading 'ZLETCAT'
col ZAPSTMPD format A8  heading 'ZAPSTMPD'
col ZRMDLETT format A8  heading 'ZRMDLETT'
col ZGOODBYE format A8  heading 'ZGOODBYE'
col REQCOY format A6  heading 'REQCOY'
col ZCOLMCLS format A8  heading 'ZCOLMCLS'
col ZGRPCLS format A7  heading 'ZGRPCLS'
col ZPRDCTG format A7  heading 'ZPRDCTG'
col ZDECLCAT format A8  heading 'ZDECLCAT'
col UNIQUE_NUMBER format A13  heading 'UNIQUE_NUMBER'
col ZBSTSYIM02 format A10  heading 'ZBSTSYIM02'
col CLTRELN format A7  heading 'CLTRELN'
col ZWORKPLCE2 format A10  heading 'ZWORKPLCE2'
col EFFDATE format A8  heading 'EFFDATE'
col DTETRM format A8  heading 'DTETRM'
col DTEATT format A8  heading 'DTEATT'
col ZCHGTYPE format A8  heading 'ZCHGTYPE'
col NRFLG format A5  heading 'NRFLG'
col PETNAME format A60 WRAP heading 'PETNAME' 




