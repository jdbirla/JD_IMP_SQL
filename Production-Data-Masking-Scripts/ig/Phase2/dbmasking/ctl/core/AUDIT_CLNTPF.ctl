OPTIONS (DIRECT=TRUE)
UNRECOVERABLE
LOAD DATA
REPLACE
INTO TABLE VM1DTA.AUDIT_CLNTPF
FIELDS TERMINATED BY "," ENCLOSED BY '"'
TRAILING NULLCOLS
(
UNIQUE_NUMBER,
OLDCLNTPFX   ,
OLDCLNTCOY   ,
OLDCLNTNUM   ,
OLDTRANID    ,
OLDVALIDFLAG ,
OLDCLTTYPE   ,
OLDSECUITYNO ,
OLDPAYROLLNO ,
OLDSURNAME   ,
OLDGIVNAME   ,
OLDSALUT     ,
OLDINITIALS  ,
OLDCLTSEX    ,
OLDCLTADDR01 ,
OLDCLTADDR02 ,
OLDCLTADDR03 ,
OLDCLTADDR04 ,
OLDCLTADDR05 ,
OLDCLTPCODE  ,
OLDCTRYCODE  ,
OLDMAILING   ,
OLDDIRMAIL   ,
OLDADDRTYPE  ,
OLDCLTPHONE01,
OLDCLTPHONE02,
OLDVIP       ,
OLDOCCPCODE  ,
OLDSERVBRH   ,
OLDSTATCODE  ,
OLDCLTDOB    ,
OLDSOE       ,
OLDDOCNO     ,
OLDCLTDOD    ,
OLDCLTSTAT   ,
OLDCLTMCHG   ,
OLDMIDDL01   ,
OLDMIDDL02   ,
OLDMARRYD    ,
OLDTLXNO     ,
OLDFAXNO     ,
OLDTGRAM     ,
OLDBIRTHP    ,
OLDSALUTL    ,
OLDROLEFLAG01,
OLDROLEFLAG02,
OLDROLEFLAG03,
OLDROLEFLAG04,
OLDROLEFLAG05,
OLDROLEFLAG06,
OLDROLEFLAG07,
OLDROLEFLAG08,
OLDROLEFLAG09,
OLDROLEFLAG10,
OLDROLEFLAG11,
OLDROLEFLAG12,
OLDROLEFLAG13,
OLDROLEFLAG14,
OLDROLEFLAG15,
OLDROLEFLAG16,
OLDROLEFLAG17,
OLDROLEFLAG18,
OLDROLEFLAG19,
OLDROLEFLAG20,
OLDROLEFLAG21,
OLDROLEFLAG22,
OLDROLEFLAG23,
OLDROLEFLAG24,
OLDROLEFLAG25,
OLDROLEFLAG26,
OLDROLEFLAG27,
OLDROLEFLAG28,
OLDROLEFLAG29,
OLDROLEFLAG30,
OLDROLEFLAG31,
OLDROLEFLAG32,
OLDROLEFLAG33,
OLDROLEFLAG34,
OLDROLEFLAG35,
OLDSTCA      ,
OLDSTCB      ,
OLDSTCC      ,
OLDSTCD      ,
OLDSTCE      ,
OLDPROCFLAG  ,
OLDTERMID    ,
OLDUSER_T    ,
OLDTRDT      ,
OLDTRTM      ,
OLDSNDXCDE   ,
OLDNATLTY    ,
OLDFAO       ,
OLDCLTIND    ,
OLDSTATE     ,
OLDLANGUAGE  ,
OLDCAPITAL   ,
OLDCTRYORIG  ,
OLDECACT     ,
OLDETHORIG   ,
OLDSRDATE    ,
OLDSTAFFNO   ,
OLDLSURNAME  ,
OLDLGIVNAME  ,
OLDTAXFLAG   ,
OLDUSRPRF    ,
OLDJOBNM     ,
OLDDATIME    ,
OLDIDTYPE    ,
OLDZ1GSTREGN ,
OLDZ1GSTREGD ,
OLDKANJISURNAME,
OLDKANJIGIVNAME,
OLDKANJICLTADDR01,
OLDKANJICLTADDR02,
OLDKANJICLTADDR03,
OLDKANJICLTADDR04,
OLDKANJICLTADDR05,
OLDEXCEP         ,
OLDZKANASNM      ,
OLDZKANAGNM      ,
OLDZKANADDR01    ,
OLDZKANADDR02    ,
OLDZKANADDR03    ,
OLDZKANADDR04    ,
OLDZKANADDR05    ,
OLDZADDRCD       ,
OLDABUSNUM       ,
OLDBRANCHID      ,
OLDZKANASNMNOR   ,
OLDZKANAGNMNOR   ,
OLDTELECTRYCODE  ,
OLDTELECTRYCODE1 ,
NEWCLNTPFX       ,
NEWCLNTCOY       ,
NEWCLNTNUM       ,
NEWTRANID        ,
NEWVALIDFLAG     ,
NEWCLTTYPE       ,
NEWSECUITYNO     ,
NEWPAYROLLNO     ,
NEWSURNAME       ,
NEWGIVNAME       ,
NEWSALUT         ,
NEWINITIALS      ,
NEWCLTSEX        ,
NEWCLTADDR01     ,
NEWCLTADDR02     ,
NEWCLTADDR03     ,
NEWCLTADDR04     ,
NEWCLTADDR05     ,
NEWCLTPCODE      ,
NEWCTRYCODE      ,
NEWMAILING       ,
NEWDIRMAIL       ,
NEWADDRTYPE      ,
NEWCLTPHONE01    ,
NEWCLTPHONE02    ,
NEWVIP           ,
NEWOCCPCODE      ,
NEWSERVBRH       ,
NEWSTATCODE      ,
NEWCLTDOB        ,
NEWSOE           ,
NEWDOCNO         ,
NEWCLTDOD        ,
NEWCLTSTAT       ,
NEWCLTMCHG       ,
NEWMIDDL01       ,
NEWMIDDL02       ,
NEWMARRYD        ,
NEWTLXNO         ,
NEWFAXNO         ,
NEWTGRAM         ,
NEWBIRTHP        ,
NEWSALUTL        ,
NEWROLEFLAG01    ,
NEWROLEFLAG02    ,
NEWROLEFLAG03    ,
NEWROLEFLAG04    ,
NEWROLEFLAG05    ,
NEWROLEFLAG06    ,
NEWROLEFLAG07    ,
NEWROLEFLAG08    ,
NEWROLEFLAG09    ,
NEWROLEFLAG10    ,
NEWROLEFLAG11    ,
NEWROLEFLAG12    ,
NEWROLEFLAG13    ,
NEWROLEFLAG14    ,
NEWROLEFLAG15    ,
NEWROLEFLAG16    ,
NEWROLEFLAG17    ,
NEWROLEFLAG18    ,
NEWROLEFLAG19    ,
NEWROLEFLAG20    ,
NEWROLEFLAG21    ,
NEWROLEFLAG22    ,
NEWROLEFLAG23    ,
NEWROLEFLAG24    ,
NEWROLEFLAG25    ,
NEWROLEFLAG26    ,
NEWROLEFLAG27    ,
NEWROLEFLAG28    ,
NEWROLEFLAG29    ,
NEWROLEFLAG30    ,
NEWROLEFLAG31    ,
NEWROLEFLAG32    ,
NEWROLEFLAG33    ,
NEWROLEFLAG34    ,
NEWROLEFLAG35    ,
NEWSTCA          ,
NEWSTCB          ,
NEWSTCC          ,
NEWSTCD          ,
NEWSTCE          ,
NEWPROCFLAG      ,
NEWTERMID        ,
NEWUSER_T        ,
NEWTRDT          ,
NEWTRTM          ,
NEWSNDXCDE       ,
NEWNATLTY        ,
NEWFAO           ,
NEWCLTIND        ,
NEWSTATE         ,
NEWLANGUAGE      ,
NEWCAPITAL       ,
NEWCTRYORIG      ,
NEWECACT         ,
NEWETHORIG       ,
NEWSRDATE        ,
NEWSTAFFNO       ,
NEWLSURNAME      ,
NEWLGIVNAME      ,
NEWTAXFLAG       ,
NEWUSRPRF        ,
NEWJOBNM         ,
NEWDATIME        ,
NEWIDTYPE        ,
NEWZ1GSTREGN     ,
NEWZ1GSTREGD     ,
NEWKANJISURNAME  ,
NEWKANJIGIVNAME  ,
NEWKANJICLTADDR01,
NEWKANJICLTADDR02,
NEWKANJICLTADDR03,
NEWKANJICLTADDR04,
NEWKANJICLTADDR05,
NEWEXCEP         ,
NEWZKANASNM      ,
NEWZKANAGNM      ,
NEWZKANADDR01    ,
NEWZKANADDR02    ,
NEWZKANADDR03    ,
NEWZKANADDR04    ,
NEWZKANADDR05    ,
NEWZADDRCD       ,
NEWABUSNUM       ,
NEWBRANCHID      ,
NEWZKANASNMNOR   ,
NEWZKANAGNMNOR   ,
NEWTELECTRYCODE  ,
NEWTELECTRYCODE1 ,
USERID           ,
ACTION           ,
TRANNO           ,
SYSTEMDATE       ,
OLDOCCPCLAS      ,
NEWOCCPCLAS
)
