--------------------------------------STAGEDBUSR2---------------------------------------------------
---------------------------------Before transformation Validation--------------------------------
--======================================================================================================================================
--Master policy checking
--1 distinct campiagn code 
select count(distinct apc1cd) from zmrap00;--8828
select count(distinct apc6cd) from zmrap00;--149

--1. enoderser and campcode 
select distinct A.endorsercode,A.campaign,B.apc6cd,B.apc1cd from grp_policy_free A inner join zmrap00 b on A.campaign = B.apc1cd 
and  A.endorsercode!=B.apc6cd order by a.campaign;--2054
--2. all free plan policies are availbale in grp
select distinct apc6cd ,apc1cd,apc7cd from zmrap00 where (apc6cd ,apc1cd) not in (
select distinct endorsercode,campaign from grp_policy_free ) and apc7cd in (select rptbtcd from zmrrpt00 where RPTFPST='F'  );
--3 master policies are not available in TITDMGMASPOL
select distinct apc6cd ,apc1cd,apc7cd,substr(apcwcd,-8),apcwcd from zmrap00 where apc7cd in (select rptbtcd from zmrrpt00 where RPTFPST='P'  )
and substr(apcwcd,-8) not in (select chdrnum from titdmgmaspol) and apevst = '2'; 
--4 Free master policies are not availble in TITDMGMASPOL
select * from(select distinct a.grp_policy_no_pj from  grp_policy_free A inner join zmrap00 B on B.apc6cd=A.endorsercode and b.apc1cd=A.campaign)
where  grp_policy_no_pj not in (select grp_policy_no_pj from titdmgmaspol);
--5. Duplicate data into grp_policy_free
select * from grp_policy_free where (ENDORSERCODE, CAMPAIGN) in (
select ENDORSERCODE, CAMPAIGN from grp_policy_free group by ENDORSERCODE, CAMPAIGN having count(*)>1) order by endorsercode,campaign;
--6. Duplicat records ZMRRR00
select RRBTCD, RRBUCD, RRFOCD, RRA2IG from ZMRRR00 a
where exists  (select RRBTCD,RRFOCD,count(1) from ZMRRR00 b where a.RRBTCD = b.RRBTCD
               and a.RRFOCD = b.RRFOCD  group by RRBTCD,RRFOCD having count(1) > 1 )
order by 1,3;
--7. Master polic
select * from titdmgmaspol where chdrnum not in (select grupnum from MSTPOLGRP);
    select * from TITDMGMASPOL where TRIM(ZENDCDE) || TRIM(TITDMGMASPOL.CNTTYPE) not in
    (select TRIM(ENDCD) ||  TRIM(PRODCD) from MSTPOLDB);
    select * from titdmgmaspol where chdrnum not in (SELECT trim(MPLNUM) from titdmgclntcorp where trim(MPLNUM) is not null) ;
--======================================================================================================================================	
-----Client and client history
---Duplicate insured
select APCUCD,COUNT(distinct occpcode)  from titdmgcltrnhis_int where CLNTROLEFLG='I' and TRANSHIST='1' group by APCUCD;
select CHDRNUM,zkanagivname,zkanasurname,sex,cltphone01,cltdob  from (
select apcucd CHDRNUM ,nvl(TRIM(substr((TRIM(apb5tx)), instr((TRIM(apb5tx)), ' ') + 1)), ' ') AS zkanagivname, nvl(TRIM(substr((TRIM(apb5tx)), 1, instr((TRIM(apb5tx)), ' ') - 1)), ' ') AS zkanasurname,apbast sex,nvl(apb4tx, '                ')        AS cltphone01 ,apa3dt        AS cltdob from zmrap00 
union ALL
select b.iscucd CHDRNUM ,nvl(TRIM(substr((TRIM(b.isbtig)), instr((TRIM(b.isbtig)), ' ') + 1)), ' ') AS zkanagivname , nvl(TRIM(substr((TRIM(b.isbtig)), 1, instr((TRIM(b.isbtig)), ' ') - 1)), ' ') AS zkanasurname,b.isa3st sex ,  nvl(c.isab4tx, '                ')        AS cltphone01 ,b.isatdt        AS cltdob
from zmris00 b  LEFT OUTER JOIN zmrisa00          c ON b.iscicd = c.isacicd where  b.isa4st <> '1') 
group by CHDRNUM,zkanagivname,zkanasurname,sex,cltphone01,cltdob having count(*)>1;

 --======================================================================================================================================   

--Postal code issues

select apcucd,apc9cd from zmrap00 where(
length(regexp_replace(apc9cd, '\D', '')) >7 or 
length(regexp_replace(apc9cd, '\D', '')) is null or
length(regexp_replace(apc9cd, '\D', '')) <7 or
length(regexp_replace(apc9cd, '\D', '')) =0);--122

select ISACUCD,ISAC9CD from zmrisa00 where (
length(regexp_replace(ISAC9CD, '\D', '')) >7 or 
length(regexp_replace(ISAC9CD, '\D', '')) is null or
length(regexp_replace(ISAC9CD, '\D', '')) <7 or
length(regexp_replace(ISAC9CD, '\D', '')) =0);--4


 
 --======================================================================================================================================   
 --Total client checking in persnl_clnt_flg 
  select * from 
 (select zmrap00.apcucd from zmrap00
 UNION ALL
   select zmris00.iscucd from zmris00)
   minus
     select APCUCD from persnl_clnt_flg ;  


--====================================================================================================================

----Relationship Issue
SELECT iscucd,  iscicd,  isa4st
FROM zmris00
WHERE ISCICD IN
  (SELECT ISCICD FROM
    (SELECT (SUBSTR(ISCICD, 1,8) || SUBSTR(ISCICD, -2)) AS Policy_Insured,
      ISCICD,
      ISA4ST
    FROM zmris00
    WHERE (SUBSTR(ISCICD, 1,8)|| SUBSTR(ISCICD, -2)) IN
      (SELECT a FROM
          (SELECT a, COUNT(b)
               FROM
                ( SELECT DISTINCT SUBSTR(ISCICD, 1,8) || SUBSTR(ISCICD, -2) AS a, ISA4ST AS b
                    FROM stagedbusr2.zmris00 )
            GROUP BY a
            HAVING COUNT(b) > 1
        )
      )
    )
  )
ORDER BY 1,2;
--====================================================================================================================

--btdate_ptdate_list validation
	/*  
	  INSERT
    INTO
        btdate_ptdate_list(
           CHDRNUM, 
           PTDATE, 
           BTDATE, 
           STATCODE, 
           ZPGPFRDT, 
           ZPGPTODT, 
           ENDSERCD
        ) 
 SELECT
    *
FROM
    (
        SELECT
            substr(a.apcucd, 1, 8) chdrnum,
            --a.apa2dt,
           to_date(to_char(to_date(a.apa2dt, 'YYYYMMDD'), 'DD-MM-YY'))-1 ptdate,
           to_date(to_char(to_date(a.apa2dt, 'YYYYMMDD'), 'DD-MM-YY'))-1 btdate,
            'IF' statcode,
            99999999 zpgpfrdt,
            99999999 zpgptodt,
            'DM' endsercd
        FROM
            zmrap00    a
            LEFT JOIN zmrrpt00   c ON a.apc7cd = c.rptbtcd
        WHERE
            a.apblst IN (
                1,
                3
            )
            AND c.rptfpst = 'P') b
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            btdate_ptdate_list a where
            a.chdrnum = b.chdrnum
    );
	*/

--====================================================================================================================
	 

--------APCVCD is too early for renewal case (alteration registration)	
	select * from(
select 
apcucd,
APCVCD,
APA2DT,
apflst,
MONTHS_BETWEEN(TRUNC(to_date(TO_CHAR(APA2DT),'YYYYMMDD'), 'MONTH'), TRUNC(to_date(TO_CHAR(APCVCD),'YYYYMMDD'), 'MONTH')) as month_diff
from zmrap00 where apblst =3) where  month_diff >2 ;
--======================================================================================================================================
----------------------NB and AL is different
select 
case 
    when substr(a.zseqno,1,2) = '00' then 
        'NB' 
    else 
        'RN' 
    end as Period_Type, a.* from (
select apcucd, substr(apcucd,9,3) zseqno,apa2dt, apcvcd,
row_number() over(partition by  substr(apcucd,1,8) order by apcucd) zseq_order,
row_number() over(partition by  substr(apcucd,1,8) order by apcvcd) apcvcd_order from zmrap00 
--where apcucd like '19938W09%'
) a
where a.zseq_order <> a.apcvcd_order
--and zseqno = '000'
order by a.apcucd;
--======================================================================================================================================
-----------------------check set plan
select ICJGCD, ICDMCD, ICCICD,count(1) from (select distinct ICJGCD,ICDMCD,ICCICD from ZMRIC00) group by ICJGCD, ICDMCD, ICCICD;
--======================================================================================================================================


--======================================================================================================================================--======================================================================================================================================
 -------------------------------------------------After Tranformation---------------------------
--======================================================================================================================================--======================================================================================================================================
						  
-----------Tranno
select distinct chdrnum from (
select * from trannotbl where zseqno=000 and tranno !=1
UNION
select * from trannotbl where zseqno=000 and tranno >1
UNION
select * from trannotbl where T_TYPE='B' and tranno=0
union
select * from trannotbl where t_type='B' and ZALTRCDE_REF='1' and (chdrnum,T_DATE) in (select chdrnum,T_DATE from trannotbl where ZSEQNO =000) and tranno <>1
union
select * from trannotbl where t_type='P' and RTRIm(ZALTRCDE_REF) is null and  ( tranno <>1) and trannotbl.zseqno=000
union
select * from trannotbl where t_type='P' and RTRIm(ZALTRCDE_REF) is null and  ( tranno < 2) and substr(ZSEQNO,1,2) >0
union
select * from trannotbl where t_type='B' and ZALTRCDE_REF='1' and chdrnum in (select chdrnum from trannotbl where substr(ZSEQNO,1,2) >0 and TRIM(ZSEQNO) is not null) and tranno =1 and TRIM(ZSEQNO) is not null
union
select * from trannotbl where t_type='P' and RTRIM(ZALTRCDE_REF) is not null  and tranno <= 1
);


--======================================================================================================================================  
--Client duplication check
select refnum from titdmgcltrnhis where TRANSHIST=1 group by refnum having count(*)>1;
--======================================================================================================================================
----Letter code validation
    select * from letter_code where igcode='ER120';
	
--======================================================================================================================================
--Client duplication check
select refnum from titdmgcltrnhis where TRANSHIST=1 group by refnum having count(*)>1;
--======================================================================================================================================
-------card_endorser_list  table configuration checking i
---1. if all tab is null
	SELECT
    *
FROM
    (
        SELECT
            endorsercode,
            MAX(decode(filetype, 'CreditCard', 'CreditCard'))               crdt,
            MAX(decode(filetype, 'CreditCard', fieldname))                  crdt_tab1,
            MAX(decode(filetype, 'BankAccount', 'BankAccount'))             bnk,
            MAX(decode(filetype, 'BankAccount', fieldname))                 bank_tab1,
            MAX(decode(filetype, 'EndorserSpecCode1', 'EndorserSpecCode1')) endorserspec1,
            MAX(decode(filetype, 'EndorserSpecCode1', fieldname))           endorserspec_tab1,
            MAX(decode(filetype, 'EndorserSpecCode1', st_pos))              endorser1_pos,
            MAX(decode(filetype, 'EndorserSpecCode1', datalength))          endorser1_len,
            MAX(decode(filetype, 'EndorserSpecCode2', 'EndorserSpecCode2')) endorserspec2,
            MAX(decode(filetype, 'EndorserSpecCode2', fieldname))           endorserspec_tab2,
            MAX(decode(filetype, 'EndorserSpecCode2', st_pos))              endorser2_pos,
            MAX(decode(filetype, 'EndorserSpecCode2', datalength))          endorser2_len,
            MAX(decode(filetype, 'CIF', 'CIF'))                             cif,
            MAX(decode(filetype, 'CIF', fieldname))                         cif_tab,
            MAX(decode(filetype, 'CIF', st_pos))                            cif_pos,
            MAX(decode(filetype, 'CIF', datalength))                        cif_len
        FROM
            card_endorser_list
        WHERE
            filetype IN ( 'CreditCard', 'BankAccount', 'EndorserSpecCode1', 'EndorserSpecCode2', 'CIF' )
        GROUP BY
            endorsercode
    )
WHERE
    crdt_tab1 IS NULL
    AND bank_tab1 IS NULL
    AND endorserspec_tab1 IS NULL
    AND endorserspec_tab1 IS NULL
    AND cif_tab IS NULL;
	
---2.--Member Identifiaction validation && Check card enpdser is sync with ZENCIPF

---in Jd1dta
	SELECT
GRP.zendcde,
    a.*
FROM
    zencipf a
    LEFT OUTER JOIN (
        SELECT
            endorsercode,
            MAX(decode(filetype, 'CreditCard', 'CreditCard'))               crdt,
            MAX(decode(filetype, 'CreditCard', fieldname))                  crdt_tab1,
            MAX(decode(filetype, 'BankAccount', 'BankAccount'))             bnk,
            MAX(decode(filetype, 'BankAccount', fieldname))                 bank_tab1,
            MAX(decode(filetype, 'EndorserSpecCode1', 'EndorserSpecCode1')) endorserspec1,
            MAX(decode(filetype, 'EndorserSpecCode1', fieldname))           endorserspec_tab1,
            MAX(decode(filetype, 'EndorserSpecCode1', st_pos))              endorser1_pos,
            MAX(decode(filetype, 'EndorserSpecCode1', datalength))          endorser1_len,
            MAX(decode(filetype, 'EndorserSpecCode2', 'EndorserSpecCode2')) endorserspec2,
            MAX(decode(filetype, 'EndorserSpecCode2', fieldname))           endorserspec_tab2,
            MAX(decode(filetype, 'EndorserSpecCode2', st_pos))              endorser2_pos,
            MAX(decode(filetype, 'EndorserSpecCode2', datalength))          endorser2_len,
            MAX(decode(filetype, 'CIF', 'CIF'))                             cif,
            MAX(decode(filetype, 'CIF', fieldname))                         cif_tab,
            MAX(decode(filetype, 'CIF', st_pos))                            cif_pos,
            MAX(decode(filetype, 'CIF', datalength))                        cif_len
        FROM
            card_endorser_list@DMSTGUSR2DBLINK
        WHERE
            filetype IN ( 'CreditCard', 'BankAccount', 'EndorserSpecCode1', 'EndorserSpecCode2', 'CIF' )
        GROUP BY
            endorsercode
    )       b ON RTRIm(a.zendcde) = RTRIm(b.endorsercode)
    inner join  
    dmpagrpmig@DMSTGUSR2DBLINK GRP on RTRIm(a.zendcde) =RTRIm(GRP.zendcde)
WHERE
    ( ( a.zbnkflag = 'Y'
        AND rtrim(bnk) IS NULL )
      OR ( a.zccflag = 'Y'
           AND rtrim(crdt) IS NULL )
      OR ( a.zcifflag = 'Y'
           AND rtrim(cif) IS NULL )
      OR ( a.zenflg1 = 'Y'
           AND rtrim(endorserspec1) IS NULL )
      OR ( a.zenflg2 = 'Y'
           AND rtrim(endorserspec2) IS NULL ) );
		   
---3. in Stagedbusr2 and stagedbusr after transformarion
--Stagedbusr
create table Stagedbusr.zencipf as select * from zencipf@IGCOREDBLINK;
--stagedbusr2
select A.chdrnum, B.zendcde,b.plnclass, C.ZBNKFLAG,A.BNKACCKEY01, C.ZCCFLAG,A.CRDTCARD, C.ZCIFFLAG,A.ZCIFCODE, C.ZENFLG1, A.ZENSPCD01, C.ZENFLG2,A.ZENSPCD02 from titdmgpoltrnh A
Inner join policy_statcode B on A.chdrnum =B.chdrnum
inner join stagedbusr.zencipf C on B.zendcde= C.zendcde 
where (ZBNKFLAG = 'Y' and RTRIM(BNKACCKEY01) is null )
or(ZCCFLAG = 'Y' and RTRIM(CRDTCARD) is null)
or(ZCIFFLAG = 'Y' and RTRIM(ZCIFCODE) is null) 
or(ZENFLG1 = 'Y' and RTRIM(ZENSPCD01) is null) 
or(ZENFLG2 = 'Y' and RTRIM(ZENSPCD02) is null) ;

--4..
----Enoderser specific code /Creditc card / bank account key  checking 

select * from titdmgmbrindp1 where plnclass='F' and (TRIM(crdtcard) IS NULL) AND
             (TRIM(zenspcd01) IS NULL) AND
             (TRIM(zenspcd02) IS NULL) AND
             (TRIM(ZCIFCODE) IS NULL) and  CLIENT_CATEGORY=0;
       
 select * from titdmgmbrindp1 where plnclass='P' and (TRIM(crdtcard) IS NULL) AND
             (TRIM(bnkacckey01) IS NULL) AND
             (TRIM(zenspcd01) IS NULL) and  CLIENT_CATEGORY=0;
--======================================================================================================================================
----APIRNO checking
--same name FULLKANJINAME in titdmgapirno for both insured
select RECIDXAPIRNO from( SELECT 
                          chdrnum,
                          recidxapirno,
                          clnt_mbrno
                      FROM
                          (
                                SELECT
                                    api.chdrnum        chdrnum,
                                    api.recidxapirno   recidxapirno,
                                    cl.cln_mbrno       clnt_mbrno
                                FROM
                                   (
                                    SELECT 
									TRIM(regexp_replace(a.fullkanjiname, '[[:space:]]+', '')) AS name_2,
									--TRIM(replace(replace(a.fullkanjiname, unistr('\3000'), ''), ' ', '')) AS name_2,
									a.*
                                    FROM
                                    titdmgapirno a
                                ) api
                                LEFT OUTER JOIN (
                                    select * from (
                                        select concat(SUBSTR(a.iscucd,1,8), MAX(SUBSTR(a.iscucd, - 3)) OVER( PARTITION BY SUBSTR(a.iscucd,1,8) )) maxapcucd, 
                                        a.ISCUCD, substr(a.ISCUCD,1,8) chdrnum, '000'||substr(a.ISCICD,-2) cln_mbrno, 
										TRIM(regexp_replace(a.ISBVIG, '[[:space:]]+', '')) cln_fullname  
										--TRIM(replace(replace(a.isbvig, unistr('\3000'), ''), ' ', '')) cln_fullname  
										from zmris00 a
                                        ) ris 
                                    where ris.maxapcucd = ris.iscucd 
                                ) cl ON cl.chdrnum = api.chdrnum
                                          AND cl.cln_fullname = api.name_2
                              WHERE
                                  api.chdrnum NOT IN (
                                      SELECT DISTINCT
                                          chdrnum
                                      FROM
                                          titdmgapirno
                                      WHERE
                                          mbrno = '00001'
                                  )
                                  AND cl.cln_mbrno IS NOT NULL
                          )) group by RECIDXAPIRNO having count(*)>1 ;
						  
--==================================================================================================================================
--FCT ZJNPG-10023 : As per ROMA mail 01/10/2021 11:35 policy will be cancel if EFFDATE < ZALTREGDAT bbut in migration we are migratinf as IF due to condition of IF: ZPDATATXFLG<>Y OR ZPDATATXFLG IS NULL 
 
 ---After bulk copy
 select A.apcucd, A.chdrnum, A.EFFDATE, A.CRDATE,  A.ZPOLTDATE,  A.DTETRM, a.endsercd,a.zendcde, A.ZTRXSTAT,  A.ZPDATATXFLG,  A.STATCODE,  A.BTDATE, A.CASENAME  from  JD_policy_statcode A
    where
    (A.ZPOLTDATE <>'99999999' or  A.DTETRM <>'99999999')
    and
     A.chdrnum in (select chdrnum from (select chdrnum,zaltrcde01, zaltregdat,effdate , row_number() OVER( PARTITION BY chdrnum order by tranno desc) rownm from STAGEDBUSR.titdmgpoltrnh)  where rownm=1 and zaltregdat >  effdate)
     and A.STATCODE='IF';


--========================================================================================================================================================================================================--6. Jobcode patching
---Job Code
select * from titdmgclntmap A where Not EXISTS (select 1 from dmpacljobcde B where A.refnum=A.refnum);


--========================================================================================================================================================================================================

--======================================================================================================================================--======================================================================================================================================
---------------------------------After Migratoin validation-------------------------


----------------------------------Validation---------------------------------------------------------
---COMMON FOR CC anf FH POLICY
---ZPDATATXDAT should no maxdate 
select A.CHDRNUM,A.ZPDATATXDAT,A.ZPDATATXFLG,B.statcode from ztrapf A 
inner join GCHD B 
on a.chdrnum = b.chdrnum
inner join pazdrppf C
on
B.chdrnum=C.POLNUM
where B.statcode='XN' and
A.ZPDATATXDAT < (select busdate from Jd1dta.busdpf where company = '1');

--

---------------------------------------------CREDIT CARD POLICY CHECK-----------------------

-------------------------------CC : PREMOUT
---IF policy in XN and not transffered  to PJ yet then PREMOUT should be Y
 select A.CHDRNUM,A.ZPDATATXDAT,A.ZPDATATXFLG,B.statcode,d.premout from ztrapf A 
inner join GCHD B 
on a.chdrnum = b.chdrnum
inner join pazdrppf C
on
B.chdrnum=C.POLNUM
inner join gbihpf D
on C.polnum= D.chdrnum
where B.statcode='XN' and
A.ZPDATATXDAT > (select busdate from Jd1dta.busdpf where company = '1')
and d.premout = 'N' ;



---	--Credit card polcies where PREMOUT is Y even no stop bill date or even stop bill date has been already passsed , it should be N 

SELECT
    gbihpf.billno,
    gbihpf.chdrnum,
    gchppf.zendcde,
    zesdpf.zendscid,
    gbihpf.zacmcldt,
    zesdpf.zbstcsdt01 ,
    zesdpf.zbstcsdt02 ,
    zesdpf.zbstcsdt03 
FROM
         gbihpf
    INNER JOIN gchppf ON gchppf.chdrnum = gbihpf.chdrnum
    INNER JOIN zendrpf ON zendrpf.zendcde = gchppf.zendcde
    INNER JOIN zesdpf ON gbihpf.zacmcldt = zesdpf.zacmcldt
                         AND zesdpf.zendscid = zendrpf.zendscid
                         inner join pazdrppf 
on
gchppf.chdrnum=pazdrppf.POLNUM
WHERE
 gbihpf.zacmcldt < (select busdate from Jd1dta.busdpf where company = '1')
 and
        gbihpf.premout = 'Y'
    AND gbihpf.zstpblyn != 'Y'
    AND gbihpf.billtyp = 'N'
    AND gbihpf.revflag != 'Y'
    AND gchppf.zcolmcls != 'F'
    AND gchppf.zprdctg = 'PA'
    AND ( ( ( zesdpf.zbstcsdt01 < (select busdate from Jd1dta.busdpf where company = '1')
              AND zesdpf.zbstcsdt02 = 99999999
              AND zesdpf.zbstcsdt03 = 99999999 ) )
          OR ( zesdpf.zbstcsdt02 < (select busdate from Jd1dta.busdpf where company = '1')
               AND zesdpf.zbstcsdt03 = 99999999 )
          OR zesdpf.zbstcsdt03 < (select busdate from Jd1dta.busdpf where company = '1') );

		  
-------------------------------------------CC : COL FLAG
  ---IF policy in XN and not transffered  to PJ yet then zcolflag should be Y
select A.CHDRNUM,A.ZPDATATXDAT,A.ZPDATATXFLG,B.statcode from ztrapf A 
inner join GCHD B 
on a.chdrnum = b.chdrnum
inner join pazdrppf C
on
B.chdrnum=C.POLNUM
inner join gbihpf D
on C.polnum= D.chdrnum
where B.statcode='XN' and
A.ZPDATATXDAT > (select busdate from Jd1dta.busdpf where company = '1')
and d.zcolflag <> 'Y' ;

--No stop bill ZCOLFLAG must be Y after ACD
SELECT
    gbihpf.billno,
    gbihpf.chdrnum,
    gchppf.zendcde,
    zesdpf.zendscid,
    gbihpf.zacmcldt,
        gbihpf.premout,
    gbihpf.zcolflag,

    zesdpf.zbstcsdt01 ,
    zesdpf.zbstcsdt02 ,
    zesdpf.zbstcsdt03 
FROM
         gbihpf
    INNER JOIN gchppf ON gchppf.chdrnum = gbihpf.chdrnum
    INNER JOIN zendrpf ON zendrpf.zendcde = gchppf.zendcde
    INNER JOIN zesdpf ON gbihpf.zacmcldt = zesdpf.zacmcldt
                         AND zesdpf.zendscid = zendrpf.zendscid
                         inner join pazdrppf 
on
gchppf.chdrnum=pazdrppf.POLNUM
WHERE
 gbihpf.zacmcldt < (select busdate from Jd1dta.busdpf where company = '1')
 and
        gbihpf.zcolflag != 'Y'
    AND gbihpf.zstpblyn != 'Y'
    AND gbihpf.billtyp = 'N'
    AND gbihpf.revflag != 'Y'
    AND gchppf.zcolmcls != 'F'
    AND gchppf.zprdctg = 'PA'
    AND (  zesdpf.zbstcsdt02 = 99999999
              AND zesdpf.zbstcsdt03 = 99999999  );
			  

			  
--1 and 2 stop bill is there and date is not arrvied yet then ZCOLFLAG must be " " space before stopbill date

SELECT
    gbihpf.billno,
    gbihpf.chdrnum,
    gchppf.zendcde,
    zesdpf.zendscid,
    gbihpf.zacmcldt,
    gbihpf.premout,
    gbihpf.zcolflag,
    zesdpf.zbstcsdt01 ,
    zesdpf.zbstcsdt02 ,
    zesdpf.zbstcsdt03 
FROM
         gbihpf
    INNER JOIN gchppf ON gchppf.chdrnum = gbihpf.chdrnum
    INNER JOIN zendrpf ON zendrpf.zendcde = gchppf.zendcde
    INNER JOIN zesdpf ON gbihpf.zacmcldt = zesdpf.zacmcldt
                         AND zesdpf.zendscid = zendrpf.zendscid
                         inner join pazdrppf 
on
gchppf.chdrnum=pazdrppf.POLNUM
WHERE
 gbihpf.zacmcldt < (select busdate from Jd1dta.busdpf where company = '1')
 and
gbihpf.zcolflag <> ' '
    AND gbihpf.billtyp = 'N'
    AND gbihpf.revflag != 'Y'
    AND gchppf.zcolmcls != 'F'
    AND gchppf.zprdctg = 'PA'
    AND (  ( zesdpf.zbstcsdt02 > (select busdate from Jd1dta.busdpf where company = '1')
               AND zesdpf.zbstcsdt03 = 99999999 and zesdpf.zbstcsdt02 <> 99999999)
          OR (zesdpf.zbstcsdt03 > (select busdate from Jd1dta.busdpf where company = '1') and  zesdpf.zbstcsdt03 <> 99999999) );
		


--1 and 2 stop bill is there and date already crossed then ZCOLFLAG must be "Y"  
		
SELECT
    gbihpf.billno,
    gbihpf.chdrnum,
    gchppf.zendcde,
    zesdpf.zendscid,
    gbihpf.zacmcldt,
     gbihpf.premout,
    gbihpf.zcolflag,
    zesdpf.zbstcsdt01 ,
    zesdpf.zbstcsdt02 ,
    zesdpf.zbstcsdt03 
FROM
         gbihpf
    INNER JOIN gchppf ON gchppf.chdrnum = gbihpf.chdrnum
    INNER JOIN zendrpf ON zendrpf.zendcde = gchppf.zendcde
    INNER JOIN zesdpf ON gbihpf.zacmcldt = zesdpf.zacmcldt
                         AND zesdpf.zendscid = zendrpf.zendscid
                         inner join pazdrppf 
on
gchppf.chdrnum=pazdrppf.POLNUM
WHERE
 gbihpf.zacmcldt < (select busdate from Jd1dta.busdpf where company = '1')
 and
        gbihpf.zcolflag != 'Y'
    AND gbihpf.billtyp = 'N'
    AND gbihpf.revflag != 'Y'
    AND gchppf.zcolmcls != 'F'
    AND gchppf.zprdctg = 'PA'
    AND ( ( ( zesdpf.zbstcsdt01 < (select busdate from Jd1dta.busdpf where company = '1')
              AND zesdpf.zbstcsdt02 = 99999999
              AND zesdpf.zbstcsdt03 = 99999999 ) )
          OR ( zesdpf.zbstcsdt02 < (select busdate from Jd1dta.busdpf where company = '1')
               AND zesdpf.zbstcsdt03 = 99999999 )
          OR zesdpf.zbstcsdt03 < (select busdate from Jd1dta.busdpf where company = '1') );
		  
  ----------------------------------------------FH PLICY CHECK-----------------------------------------------
  --------------------------------------------FH : PREMOUT
  ---IF policy in XN and not transffered  to PJ yet then PREMOUT should be Y
  select A.CHDRNUM,A.ZPDATATXDAT,A.ZPDATATXFLG,B.statcode from ztrapf A 
inner join GCHD B 
on a.chdrnum = b.chdrnum
inner join pazdrppf C
on
B.chdrnum=C.POLNUM
inner join gbihpf D
on C.polnum= D.chdrnum
where B.statcode='XN' and
A.ZPDATATXDAT > (select busdate from Jd1dta.busdpf where company = '1')
and d.premout <> 'Y' ;

--Bill generated and exracted meaing ACD crossed and collection not done yet then  PREMOUT should be Y and ZCOLFALG should be space
SELECT
    A.billno,
    A.chdrnum,
    B.zendcde,
    D.zendscid,
    A.premout,
    a.zcolflag,
    A.zacmcldt,
    f.dshcde
    
FROM
         gbihpf A
    INNER JOIN gchppf B ON A.chdrnum = B.chdrnum
    INNER JOIN GCHD G on A.chdrnum=G.chdrnum
    INNER JOIN zendrpf C ON B.zendcde = C.zendcde
    INNER JOIN zesdpf D ON C.zendscid = D.zendscid
inner join pazdrppf E
on
B.chdrnum=E.POLNUM
Inner join zcrhpf F
on A.chdrnum= F.chdrnum
and A.billno = f.billno
WHERE
G.statcode !='CA'
and
b.zcolmcls='F'
and
a.zacmcldt < (select busdate from Jd1dta.busdpf where company = '1')
and RTRIm(f.dshcde) is null
and A.premout ='N' ;

---Collection has been completed with failure and banktransfer date has been passed then premout must be Y
select C.*  from Jd1dta.gbihpf c             
where  C.premout ='N'
            AND c.zbktrfdt IS NOT NULL
            AND c.zbktrfdt < (select busdate from Jd1dta.busdpf where company = '1')
            AND EXISTS(
                SELECT 1 FROM Jd1dta.gchppf B WHERE B.chdrnum = C.chdrnum AND B.zcolmcls  ='F')
                   AND EXISTS(
                select 1 from (select * from (SELECT chdrnum,billno, DSHCDE,TFRDATE, ROW_NUMBER() over(PARTITION by chdrnum,billno order by TFRDATE desc) rwn FROM Jd1dta.zcrhpf) where rwn=1) D WHERE D.chdrnum = C.chdrnum and D.BILLNO = C.BILLNO and RTRIm(D.DSHCDE) <> '00' )
            AND EXISTS (
                SELECT 1 FROM Jd1dta.PAZDRBPF pz WHERE pz.chdrnum = c.chdrnum and c.billno= pz.zigvalue );-- It will update 4451 rows.
  
  
---Collection has been completed with success and banktransfer date has been passed then premout must be N

select C.*  from Jd1dta.gbihpf c             
where  C.premout ='Y'
            AND c.zbktrfdt IS NOT NULL
            AND c.zbktrfdt < (select busdate from Jd1dta.busdpf where company = '1')
            AND EXISTS(
                SELECT 1 FROM Jd1dta.gchppf B WHERE B.chdrnum = C.chdrnum AND B.zcolmcls  ='F')
                   AND EXISTS(
                select 1 from (select * from (SELECT chdrnum,billno, DSHCDE,TFRDATE, ROW_NUMBER() over(PARTITION by chdrnum,billno order by TFRDATE desc) rwn FROM Jd1dta.zcrhpf) where rwn=1) D WHERE D.chdrnum = C.chdrnum and D.BILLNO = C.BILLNO and RTRIm(D.DSHCDE) ='00' )
            AND EXISTS (
                SELECT 1 FROM Jd1dta.PAZDRBPF pz WHERE pz.chdrnum = c.chdrnum and c.billno= pz.zigvalue );-- It will update 4451 rows.


  
  ----------------------------------------------FH : COL FLAG
 ---IF policy in XN and not transffered  to PJ yet then zcolflag should be Y
select A.CHDRNUM,A.ZPDATATXDAT,A.ZPDATATXFLG,B.statcode,d.zcolflag from ztrapf A 
inner join GCHD B 
on a.chdrnum = b.chdrnum
inner join pazdrppf C
on
B.chdrnum=C.POLNUM
inner join gbihpf D
on C.polnum= D.chdrnum
where B.statcode='XN' and
A.ZPDATATXDAT > (select busdate from Jd1dta.busdpf where company = '1')
and d.zcolflag = 'N' ;


--Bill generated and exracted meaing ACD crossed and collection not done yet then  PREMOUT should be Y and ZCOLFALG should be space

SELECT
    A.billno,
    A.chdrnum,
    B.zendcde,
    D.zendscid,
    A.premout,
    a.zcolflag,
    A.zacmcldt,
    f.dshcde
    
FROM
         gbihpf A
    INNER JOIN gchppf B ON A.chdrnum = B.chdrnum
    INNER JOIN GCHD G on A.chdrnum=G.chdrnum
    INNER JOIN zendrpf C ON B.zendcde = C.zendcde
    INNER JOIN zesdpf D ON C.zendscid = D.zendscid
inner join pazdrppf E
on
B.chdrnum=E.POLNUM
Inner join zcrhpf F
on A.chdrnum= F.chdrnum
and A.billno = f.billno
WHERE
G.statcode !='CA'
and
b.zcolmcls='F'
and
a.zacmcldt < (select busdate from Jd1dta.busdpf where company = '1')
and RTRIm(f.dshcde) is null
and A.zcolflag <> ' ' ;

---By Kevin 
--ZCOLFLG should be space
select gb.*
from Jd1dta.gbihpf gb
inner join Jd1dta.gchppf gc ON gc.chdrnum = gb.chdrnum and gc.zcolmcls = 'F'
inner join(
        select chdrnum, billno, dshcde
        from (
            select chdrnum, billno, dshcde, row_number() over(partition by chdrnum, billno order by tfrdate desc) rw
            from Jd1dta.zcrhpf
            )
        where rw = 1
        and dshcde = ' '
) zc ON zc.chdrnum = gb.chdrnum and gb.billno = zc.billno
where gb.premout <> 'N'
and gc.zcolmcls = 'F'
and exists (select 1 from Jd1dta.pazdrbpf rg where rg.chdrnum = gb.chdrnum and rg.zigvalue = gb.billno)
and gb.zcolflag = 'Y'
and zc.dshcde = ' ';

------

---FH checking if collection result executed and bktrfdate < busdpf then ZCOLFLAG must be Y
select C.*  from Jd1dta.gbihpf c             
where  C.zcolflag = ' ' and c.zbktrfdt  <> '99999999'
            AND c.zbktrfdt IS NOT NULL
            AND c.zbktrfdt < (select busdate from Jd1dta.busdpf where company = '1')
            AND EXISTS(
                SELECT 1 FROM Jd1dta.gchppf B WHERE B.chdrnum = C.chdrnum AND B.zcolmcls  ='F')
            AND EXISTS (
                SELECT 1 FROM Jd1dta.PAZDRBPF pz WHERE pz.chdrnum = c.chdrnum and c.billno= pz.zigvalue );-- It will update 4451 rows.
  
  
  ---By Kevin 
  --ZCOLFLG should be Y
  select gb.*
from Jd1dta.gbihpf gb
inner join Jd1dta.gchppf gc ON gc.chdrnum = gb.chdrnum and gc.zcolmcls = 'F'
inner join(
        select chdrnum, billno, dshcde
        from (
            select chdrnum, billno, dshcde, row_number() over(partition by chdrnum, billno order by tfrdate desc) rw
            from Jd1dta.zcrhpf
            )
        where rw = 1
        and dshcde <> ' '
) zc ON zc.chdrnum = gb.chdrnum and gb.billno = zc.billno
where gb.premout <> 'N'
and gc.zcolmcls = 'F'
and exists (select 1 from Jd1dta.pazdrbpf rg where rg.chdrnum = gb.chdrnum and rg.zigvalue = gb.billno)
and gb.zcolflag <> 'Y'
and zc.dshcde <> ' ';
  
  
 ------------------------------------------------------------------------------------------------------------------------------------------------------------ 
--How to check if premout is Y for the current bill and PTDATE is equal to the Btdate , PTDATE should be less than btdate
    select A.chdrnum, A.Ptdate,B.prbiltdt,C.zendcde from GCHD A inner join (select chdrnum,prbiltdt,MAX(premout)premout,usrprf from gbihpf where billtyp='N' group by chdrnum,prbiltdt,usrprf) B on A.chdrnum= B.chdrnum inner join GCHPPF C on B.chdrnum=C.chdrnum
          where b.premout='Y' and A.ptdate>= b.prbiltdt and A.PTDATE <> 99999999 and b.usrprf='JBIRLA'; 
		  

---P2-17372 
--How to check policies where R04 is required after 2 combill

select a.chdrnum, a.billno, count(*) from Jd1dta.zcrhpf a
where a.dshcde <> '00'
and a.dshcde <> ' '
and a.chdrnum in (select substr(zentity,1,8) from Jd1dta.pazdcrpf)
and  not exists (select 1 from Jd1dta.ztrapf z where z.chdrnum = a.chdrnum and (z.ZALTRCDE01 = 'R04'))
and  not exists (select 1 from Jd1dta.ztrapf z where z.chdrnum = a.chdrnum and (z.ZALTRCDE01 = 'D01'))
--and exists (select 1 from Jd1dta.dmigtitdmgpoltrnh t where t.chdrnum = a.chdrnum and t.zendcde = 'NCITY_BK')
and exists (select 1 from Jd1dta.zuclpf zu where zu.chdrnum = a.chdrnum and zu.zcombill = '2')
group by a.chdrnum, a.billno HAVING count(*) > 1

--How to check policies where R02/R0B is required after initial collection

select A.CHDRNUM,A.ZPDATATXDAT,A.ZPDATATXFLG,B.statcode,D.DSHCDE,A.zrcaltty from ztrapf A 
inner join GCHD B 
on a.chdrnum = b.chdrnum
inner join pazdrppf C
on
B.chdrnum=C.POLNUM
inner join zcrhpf D on B.chdrnum=D.chdrnum
where B.statcode='XN'
and RTRIM(D.DSHCDE) <> '00'
and (NVL(A.zrcaltty,' ')  != 'TERM');

----------------------------------
---Check if PJ given 3 bills as combined bills which is not possible in IG 
select distinct chdrnum from (select  chdrnum,TFRDATE, count(1) from STAGEDBUSR2.titdmgbill1  group by chdrnum,TFRDATE having count(*)>2 );

--======================================================================================================================================
--card_endorser_list member indentification check
select A.chdrnum, A.zendcde,b.zplancls, C.ZBNKFLAG,A.BANKACCKEY01, C.ZCCFLAG,A.CRDTCARD, C.ZCIFFLAG,A.ZCIFCODE, C.ZENFLG1, A.ZENSPCD01, C.ZENFLG2,A.ZENSPCD02, c.zjpbflg, c.zmbrnoid from zmcipf A
inner join gchppf B on a.chdrnum = B.chdrnum
inner join zencipf C on A.zendcde= C.zendcde 
where (ZBNKFLAG = 'Y' and RTRIM(BANKACCKEY01) is null and b.zplancls='PP')
or(ZCCFLAG = 'Y' and RTRIM(CRDTCARD) is null  and b.zplancls='PP')
or(ZCIFFLAG = 'Y' and RTRIM(ZCIFCODE) is null) 
or(ZENFLG1 = 'Y' and RTRIM(ZENSPCD01) is null) 
or(ZENFLG2 = 'Y' and RTRIM(ZENSPCD02) is null) ;
			

			
			
--======================================================================================================================================--======================================================================================================================================
--======================================================================================================================================--======================================================================================================================================
--------------------------------------------Patching-------------------------------------------------
---Corporate client patch after exection , insertion record which are not updatd
  select * from titdmgclntcorp@dmstagedblink where clntkey='31464629';;
             insert into pazdclpf (RECSTATUS, PREFIX, ZENTITY, ZIGVALUE, JOBNUM, JOBNAME)
              select distinct 'OK' , 'CC', B.clntkey, A.CLNTNUM , 0002, 'INSERT' from agntpf A inner join
              ( select clntkey,RTRIM(agntnum) agntnum from titdmgclntcorp@dmstagedblink  where RTRIm(clntkey)in (
                select distinct ZREFKEY from zdoecc0002 where erorfld01='SHIAG') and rtrim(agntnum)is not null) B
                on RTRIm(A.agntnum) = RTRIM(B.agntnum)  ;
                
insert into pazdclpf (RECSTATUS, PREFIX, ZENTITY, ZIGVALUE, JOBNUM, JOBNAME)
              select distinct 'OK' , 'CC', B.clntkey, A.CLNTNUM , 0002, 'INSERT' from agntpf A inner join
              ( select clntkey,RTRIM(agntnum) agntnum from titdmgclntcorp@dmstagedblink  where RTRIm(clntkey)in (
                select distinct ZREFKEY from zdoecc0002 where erorfld01='NOCHG') and rtrim(agntnum)is not null) B
                on RTRIm(A.agntnum) = RTRIM(B.agntnum);
				