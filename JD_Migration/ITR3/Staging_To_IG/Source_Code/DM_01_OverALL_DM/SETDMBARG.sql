--------------------------------------------------------
--  File created - Wednesday-July-07-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SETDMBARG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."SETDMBARG" 
(
  inCPUCNT IN NUMBER DEFAULT 10 
, inARRAYSIZE IN NUMBER DEFAULT 1000 ,
   inUSRPRF  in  VARCHAR2 
   
) AS 

G1ZDCOPCLT  number 	;
G1ZDAGENCY	number;
G1ZDCAMPCD  number  ;
G1ZDPERCLT  number ;
G1ZDNAYCLT  number ;
G1ZDPCLHIS  number ;
G1ZDCLTBNK  number ;
G1ZDMBRIND  number ;
G1ZDCOLRES  number   ;
G1ZDLETR    number ;
G1ZDPOLDSH  number ;
G1ZDBILLIN  number    ;
G1ZDBILLRF  number  ;   
G1ZDPOLHST  number  ;
G1ZDPOLCOV  number ;
G1ZDAPIRNO  number;
G1ZDMSTPOL  number  ; 
G1ZDRNWDTM  number   ; 
CURSOR get_chunks IS
select ( 
 SELECT              ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGCLNTCORP@dmstagedblink		) AS		G1ZDCOPCLT	,
( SELECT              ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGAGENTPJ@dmstagedblink		) AS		G1ZDAGENCY	,
 ( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGCAMPCDE@dmstagedblink     ) AS           G1ZDCAMPCD    ,
 ( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGCLTRNHIS@dmstagedblink    ) AS           G1ZDPERCLT   ,
  ( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGCLTRNHIS@dmstagedblink    ) AS           G1ZDNAYCLT   ,
 ( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGCLTRNHIS@dmstagedblink    ) AS           G1ZDPCLHIS   ,
 ( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGCLNTBANK@dmstagedblink    ) AS           G1ZDCLTBNK   ,
 ( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGMBRINDP1@dmstagedblink    ) AS           G1ZDMBRIND   ,
 ( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGCOLRES@dmstagedblink      ) AS           G1ZDCOLRES     ,
 ( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGLETTER@dmstagedblink      ) AS           G1ZDLETR     ,
( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGMBRINDP3@dmstagedblink    ) AS           G1ZDPOLDSH   ,
( SELECT             ROUND(COUNT(*)/(inCPUCNT*2))+1         FROM             Stagedbusr.TITDMGBILL1@dmstagedblink       ) AS           G1ZDBILLIN      ,
( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGREF1@dmstagedblink        ) AS           G1ZDBILLRF    ,   
( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGPOLTRNH@dmstagedblink     ) AS           G1ZDPOLHST    ,
( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGMBRINDP2@dmstagedblink    ) AS           G1ZDPOLCOV   ,
( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGAPIRNO@dmstagedblink      ) AS           G1ZDAPIRNO  ,
( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGMASPOL@dmstagedblink      ) AS           G1ZDMSTPOL    , 
( SELECT             ROUND(COUNT(*)/inCPUCNT)+1         FROM             Stagedbusr.TITDMGRNWDT1@dmstagedblink      ) AS           G1ZDRNWDTM     
from dual;


BEGIN
 OPEN get_chunks;
   LOOP
      FETCH get_chunks INTO G1ZDCOPCLT	, G1ZDAGENCY	, G1ZDCAMPCD    , G1ZDPERCLT   , G1ZDNAYCLT   , G1ZDPCLHIS   , G1ZDCLTBNK   , G1ZDMBRIND   , G1ZDCOLRES     , G1ZDLETR     , G1ZDPOLDSH   , G1ZDBILLIN      , G1ZDBILLRF    ,   G1ZDPOLHST    , G1ZDPOLCOV   , G1ZDAPIRNO  , G1ZDMSTPOL    , G1ZDRNWDTM     ;


   dbms_output.put_line('chunk size of G1ZDCOPCLT = ' || G1ZDCOPCLT); 
  dbms_output.put_line('chunk size of G1ZDAGENCY= ' || G1ZDAGENCY);	
  dbms_output.put_line('chunk size of G1ZDCAMPCD= ' || G1ZDCAMPCD); 
  dbms_output.put_line('chunk size of G1ZDPERCLT= ' || G1ZDPERCLT); 
  dbms_output.put_line('chunk size of G1ZDNAYCLT= ' || G1ZDNAYCLT); 
  dbms_output.put_line('chunk size of G1ZDPCLHIS= ' || G1ZDPCLHIS); 
  dbms_output.put_line('chunk size of G1ZDCLTBNK= ' || G1ZDCLTBNK); 
  dbms_output.put_line('chunk size of G1ZDMBRIND= ' || G1ZDMBRIND); 
  dbms_output.put_line('chunk size of G1ZDCOLRES= ' || G1ZDCOLRES); 
  dbms_output.put_line('chunk size of G1ZDLETR  = ' || G1ZDLETR  ); 
  dbms_output.put_line('chunk size of G1ZDPOLDSH= ' || G1ZDPOLDSH); 
  dbms_output.put_line('chunk size of G1ZDBILLIN= ' || G1ZDBILLIN); 
  dbms_output.put_line('chunk size of G1ZDBILLRF= ' || G1ZDBILLRF);  
  dbms_output.put_line('chunk size of G1ZDPOLHST= ' || G1ZDPOLHST); 
  dbms_output.put_line('chunk size of G1ZDPOLCOV= ' || G1ZDPOLCOV); 
  dbms_output.put_line('chunk size of G1ZDAPIRNO= ' || G1ZDAPIRNO); 
  dbms_output.put_line('chunk size of G1ZDMSTPOL= ' || G1ZDMSTPOL); 
  dbms_output.put_line('chunk size of G1ZDRNWDTM= ' || G1ZDRNWDTM); 

update Jd1dta.dmbargspf set chunk_size=G1ZDCOPCLT ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDCOPCLT';
update Jd1dta.dmbargspf set chunk_size=G1ZDAGENCY ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDAGENCY';
update Jd1dta.dmbargspf set chunk_size=G1ZDCAMPCD ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDCAMPCD';
update Jd1dta.dmbargspf set chunk_size=G1ZDPERCLT ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDPERCLT';
update Jd1dta.dmbargspf set chunk_size=G1ZDNAYCLT ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDNAYCLT';
update Jd1dta.dmbargspf set chunk_size=G1ZDPCLHIS ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDPCLHIS';
update Jd1dta.dmbargspf set chunk_size=G1ZDCLTBNK ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDCLTBNK';
update Jd1dta.dmbargspf set chunk_size=G1ZDMBRIND ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDMBRIND';
update Jd1dta.dmbargspf set chunk_size=G1ZDCOLRES ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDCOLRES';
update Jd1dta.dmbargspf set chunk_size=G1ZDLETR   ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDLETR';
update Jd1dta.dmbargspf set chunk_size=G1ZDPOLDSH ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDPOLDSH';
update Jd1dta.dmbargspf set chunk_size=G1ZDBILLIN ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDBILLIN';
update Jd1dta.dmbargspf set chunk_size=G1ZDBILLRF ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDBILLRF';
update Jd1dta.dmbargspf set chunk_size=G1ZDPOLHST ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDPOLHST';
update Jd1dta.dmbargspf set chunk_size=G1ZDPOLCOV ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDPOLCOV';
update Jd1dta.dmbargspf set chunk_size=G1ZDAPIRNO ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDAPIRNO';
update Jd1dta.dmbargspf set chunk_size=G1ZDMSTPOL ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDMSTPOL';
update Jd1dta.dmbargspf set chunk_size=G1ZDRNWDTM ,array_size=inARRAYSIZE , USRPRF = inUSRPRF , DEGREE_PARALLEL = inCPUCNT where RTRIm(SCHEDULE_NAME)='G1ZDRNWDTM';


      EXIT WHEN get_chunks%notfound;

   END LOOP;

   CLOSE get_chunks;

 EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END SETDMBARG;

/
