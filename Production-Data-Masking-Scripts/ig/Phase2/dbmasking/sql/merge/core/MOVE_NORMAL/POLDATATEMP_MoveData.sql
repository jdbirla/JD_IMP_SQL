UPDATE POLDATATEMP A
   SET (
   
 
   A.ZKANASNM     ,
   A.ZKANAGNM     ,
   A.LSURNAME     ,
   A.LGIVNAME     ,
   A.CLTPHONE01   ,
   A.CLTPHONE02   ,
   A.CLTADDR01    ,
   A.CLTADDR02    ,
   A.CLTADDR03    ,
   A.CLTADDR04    ,
   A.ZKANADDR01   ,
   A.ZKANADDR02   ,
   A.ZKANADDR03   ,
   A.ZKANADDR04   ,
   A.FAXNO   	  ,
   A.CLTADDR05    ,
   A.ZKANADDR05   ,
   A.CRDTCARD     
   
   
   )     =      (select 
   
  
   B.ZKANASNM  ,
   B.ZKANAGNM  ,
   B.LSURNAME  ,
   B.LGIVNAME  ,
   B.CLTPHONE01,
   B.CLTPHONE02,
   B.CLTADDR01 ,
   B.CLTADDR02 ,
   B.CLTADDR03 ,
   B.CLTADDR04 ,
   B.ZKANADDR01,
   B.ZKANADDR02,
   B.ZKANADDR03,
   B.ZKANADDR04,
   B.FAXNO   	,
   B.CLTADDR05 ,
   B.ZKANADDR05,
   B.CRDTCARD  
   
                         FROM POLDATATEMP_EXT B
                        WHERE A.CHDRNUM     =      B.CHDRNUM  and A.tranno  = B.tranno)
WHERE EXISTS (
    SELECT 1
      FROM  POLDATATEMP_EXT B
                        WHERE A.CHDRNUM     =      B.CHDRNUM  and A.tranno  = B.tranno );