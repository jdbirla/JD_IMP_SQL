
select * from (
with  CLIENT_BANK_SRC as
(
select 
clntbnk.*,
clntbnk.BANKCD ||'   '|| clntbnk.BRANCHCD  as bankkey,
(CASE 
  WHEN TRIm(ZENTITY) is null THEN 'CLNTNOTFOUND'
  ELSE pazdcl.ZENTITY
END )as BNKCLNTNO,
(CASE 
  WHEN TRIm(zigvalue) is null THEN 'CLNTNOTFOUND'
  ELSE pazdcl.zigvalue
END )as IG_CLNTNUM
from titdmgclntbank@dmstagedblink clntbnk
left outer join
(select zentity,zigvalue from Jd1dta.pazdclpf where prefix='CP') pazdcl
on clntbnk.refnum = pazdcl.zentity),
CLIENT_BANK_SHI as (
 SELECT
                    a.clntnum mem_clntnum,
                    CASE
                        WHEN b.bankkey = '9999   999' THEN
                            b.bankacckey
                        ELSE
                            ''
                    END AS SHI_crdtcardno,
                    CASE
                        WHEN b.bankkey != '9999   999' THEN
                            b.bankacckey
                        ELSE
                            ''
                    END AS SHI_bankacckey,
                    b.BANKKEY as SHI_BANKKEY
                FROM
                    Jd1dta.clntpf   a
                    INNER JOIN Jd1dta.clbapf   b ON a.clntnum = b.clntnum
                                                       AND b.validflag = '1'
)
select 
srcbnk.*,
shibnk.*,
(CASE 
  WHEN TRIM(shibnk.MEM_CLNTNUM) is null THEN 'CLNTNOTFOUND'
 WHEN RTRIM(srcbnk.IG_CLNTNUM) =  RTRIM(shibnk.MEM_CLNTNUM) THEN 'MATCHING'
  WHEN RTRIM(srcbnk.IG_CLNTNUM) !=  RTRIM(shibnk.MEM_CLNTNUM) THEN IG_CLNTNUM
 else  ''
END )as F_CLNTNUM,
(CASE 
  WHEN TRIM(shibnk.shi_bankacckey) is null THEN 'BANKNOTFOUND'
 WHEN RTRIM(srcbnk.BANKACCKEY) =  RTRIM(shibnk.shi_bankacckey) THEN 'MATCHING'
  WHEN RTRIM(srcbnk.BANKACCKEY) !=  RTRIM(shibnk.shi_bankacckey) THEN srcbnk.BANKACCKEY
 else  ''
END )as F_BANKACCKEY,
(CASE 
  WHEN TRIM(shibnk.shi_crdtcardno) is null THEN 'CRDTNOTFOUND'
 WHEN RTRIM(srcbnk.CRDTCARD) =  RTRIM(shibnk.shi_crdtcardno) THEN 'MATCHING'
  WHEN RTRIM(srcbnk.CRDTCARD) !=  RTRIM(shibnk.shi_crdtcardno) THEN srcbnk.CRDTCARD
 else  ''
END )as F_CRDTCARD
from CLIENT_BANK_SRC srcbnk left outer join
CLIENT_BANK_SHI shibnk on srcbnk.ig_clntnum = shibnk.mem_clntnum
and ((RTRIM(srcbnk.BANKACCKEY) =  RTRIM(shibnk.shi_bankacckey)) or (RTRIM(srcbnk.CRDTCARD) =  RTRIM(shibnk.shi_crdtcardno)))
and (RTRIM(srcbnk.bankKey) =  RTRIM(shibnk.SHI_BANKKEY))) ;
--------------------

select * from (with  CLIENT_END_SRC as
(
select 
clntend.*,
(CASE 
  WHEN TRIm(ZENTITY) is null THEN 'CLNTNOTFOUND'
  ELSE pazdcl.ZENTITY
END )as BNKCLNTNO,
(CASE 
  WHEN TRIm(zigvalue) is null THEN 'CLNTNOTFOUND'
  ELSE pazdcl.zigvalue
END )as IG_CLNTNUM
from STAGEDBUSR.titdmgendspcfc clntend
left outer join
(select zentity,zigvalue from Jd1dta.pazdclpf where prefix='CP') pazdcl
on clntend.refnum = pazdcl.zentity),
CLIENT_END_SHI as (
 SELECT
                    a.clntnum mem_clntnum,
                   b.ZENDCDE SHI_ZENDCDE,
                    b.ZENSPCD01 SHI_ZENSPCD01,
                     b.ZENSPCD02 SHI_ZENSPCD02,
                      b.ZCIFCODE SHI_ZCIFCODE
                FROM
                    Jd1dta.clntpf   a
                    INNER JOIN Jd1dta.zclepf   b ON a.clntnum = b.clntnum 
                                                     
)
select 
srcend.*,
shiend.*,
(CASE 
  WHEN TRIM(shiend.MEM_CLNTNUM) is null THEN 'CLNTNOTFOUND'
 WHEN RTRIM(srcend.IG_CLNTNUM) =  RTRIM(shiend.MEM_CLNTNUM) THEN 'MATCHING'
  WHEN RTRIM(srcend.IG_CLNTNUM) !=  RTRIM(shiend.MEM_CLNTNUM) THEN srcend.IG_CLNTNUM
 else  ''
END )as F_CLNTNUM,
(CASE 
  WHEN TRIM(shiend.SHI_zenspcd01) is null THEN 'END01NOTFOUND'
 WHEN RTRIM(srcend.zenspcd01) =  RTRIM(shiend.SHI_zenspcd01) THEN 'MATCHING'
  WHEN RTRIM(srcend.zenspcd01) !=  RTRIM(shiend.SHI_zenspcd01) THEN srcend.zenspcd01
 else  ''
END )as F_zenspcd01,
(CASE 
  WHEN TRIM(shiend.SHI_zenspcd02) is null THEN 'END02NOTFOUND'
 WHEN RTRIM(srcend.zenspcd02) =  RTRIM(shiend.SHI_zenspcd02) THEN 'MATCHING'
  WHEN RTRIM(srcend.zenspcd02) !=  RTRIM(shiend.SHI_zenspcd02) THEN srcend.zenspcd02
 else  ''
END )as F_zenspcd02,
(CASE 
  WHEN TRIM(shiend.SHI_zcifcode) is null THEN 'ZCIFNOTFOUND'
 WHEN RTRIM(srcend.zcifcode) =  RTRIM(shiend.SHI_zcifcode) THEN 'MATCHING'
  WHEN RTRIM(srcend.zcifcode) !=  RTRIM(shiend.SHI_zcifcode) THEN srcend.zcifcode
 else  ''
END )as F_zcifcode
from CLIENT_END_SRC srcend left outer join
CLIENT_END_SHI shiend on srcend.ig_clntnum = shiend.mem_clntnum and srcend.zendcde = shiend.SHI_zendcde
and(RTRIM(srcend.zenspcd01) =  RTRIM(shiend.SHI_zenspcd01) or ((RTRIM(srcend.zenspcd02) =  RTRIM(shiend.SHI_zenspcd02)))
or (RTRIM(srcend.zcifcode) =  RTRIM(shiend.SHI_zcifcode))))
;