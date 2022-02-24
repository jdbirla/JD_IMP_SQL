OPTIONS (DIRECT=TRUE)
UNRECOVERABLE
LOAD DATA
REPLACE
INTO TABLE STAGEDBUSR.TITPAMCAMPAIGN_BKP
FIELDS TERMINATED BY "," ENCLOSED BY '"'
TRAILING NULLCOLS
(
RECIDXCAMP				,
CREDITCARDNO			,
BK_BRANCH_CD_COLLECT    ,
BK_ACC_TYPE_COLLECT     ,
BK_ACC_NO_COLLECT       ,
JPB_ACC_TYPE_COLLECT    ,
JPB_CONTR_TYPE_COLLECT  ,
JPB_PASSBOOK_CD_COLLECT ,
JPB_PASSBOOK_NO_COLLECT ,
ACCHOLDERNAME_COLLECT   ,
AUTHORIZATIONNUMBER     ,
VALID_TILL_M            ,
VALID_TILL_Y            ,
VALIDITYCHECKRESULT     ,
BK_BRANCH_CD_PAYM       ,
BK_ACC_TYPE_PAYM        ,
BK_ACC_NO_PAYM          ,
JPB_ACC_TYPE_PAYM       ,
JPB_CONTR_TYPE_PAYM     ,
JPB_PASSBOOK_CD_PAYM    ,
JPB_PASSBOOK_NO_PAYM    ,
ACCHOLDERNAME_PAYM      ,
RELATIONSHIP            ,
SURNAMEKANA             ,
GIVENNAMEKANA           ,
SURNAMEKANJI            ,
GIVENNAMEKANJI          ,
DATEOFBIRTH             ,
GENDER                  ,
OCCUPATION              ,
OCCUPATION_CODE         ,
OCCUPATIONPA            ,
OCCUPATION_CLASS        ,
ASRF1                   ,
ASRF2                   ,
ASRF3                   ,
ASRF4                   ,
ASRF5                   ,
ASRF6                   ,
ASRF7                   ,
ASRF8                   ,
ASRF9                   ,
ASRF10                  ,
POSTAL_CODE             ,
ADDRESSINKANA_1         ,
ADDRESSINKANA_2         ,
ADDRESSINKANA_3         ,
ADDRESSINKANA_4         ,
ADDRESSINKANJI_1        ,
ADDRESSINKANJI_2        ,
ADDRESSINKANJI_3        ,
ADDRESSINKANJI_4        ,
TELEPHONENO             ,
MOBILENO                ,
EMAILADDRESS            ,
PREMIUM                 ,
WORKPLACENAME           ,
SOLICITATION_FLAG       ,
INHERITDISCLAIMERFLAG   ,
DECLARATION_DATE        ,
DECLARATION_CATEGORY    ,
DECLARATIONITEM1        ,
DECLARATIONITEM2        ,
RELATIONSHIPOFGUARDIAN  ,
SURNAMEGUARDIANKANJI    ,
GIVENNAMEGUARDIANKANJI  ,
SURNAMEGUARDIANKANA     ,
GIVENNAMEGUARDIANKANA   ,
DATEBIRTHOFGUARDIAN     ,
POSTALCODEGUARDIAN      ,
ADDRGUARDIANKANA_1      ,
ADDRGUARDIANKANA_2      ,
ADDRGUARDIANKANA_3      ,
ADDRGUARDIANKANA_4      ,
ADDRGUARDIANKANJI_1     ,
ADDRGUARDIANKANJI_2     ,
ADDRGUARDIANKANJI_3     ,
ADDRGUARDIANKANJI_4     ,
TELNOGUARDIAN
)