--SALES PLAN Conversion validation
WITH data_1 AS
    (SELECT src_data.apcucd ,
      src_data.chdrnum ,
      src_data.mbrno,
      src_data.oldzsalplan,
      src_data.relationship ,
      src_data.crdt_card_ridr ,
      src_data.hcr_coverage ,
      ssp.newzsalplan
    FROM
      (SELECT p.apcucd,
        SUBSTR(p.apcucd,1,8) chdrnum,
        '000'
        ||SUBSTR(ris.iscicd,-2) mbrno,
        ris.iscjcd oldzsalplan,
        ris.isa4st                       AS relationship,
        DECODE (rrs.rsbvcd,NULL,'N','Y') AS crdt_card_ridr,
        CASE
          WHEN SUBSTR(p.apyob1,1,1) IN (' ','N')
          THEN 'N'
          WHEN SUBSTR(p.apyob1,1,1) IN ('A','B','C','D','E')
          THEN SUBSTR(p.apyob1,1,1)
          ELSE 'N'
        END AS hcr_coverage
      FROM zmrap00 p
      LEFT OUTER JOIN zmris00 ris
      ON p.apcucd = ris.iscucd
      LEFT OUTER JOIN
        (SELECT b.rsbtcd,
          b.rsbucd,
          b.rsfocd,
          b.rsbvcd,
          b.rsgacd,
          b.rsb0cd,
          b.rsb1cd,
          b.rsb2cd,
          b.rsb3cd,
          b.rsb4cd,
          b.rsb5cd
        FROM zmrrs00 b
        WHERE (b.rsgacd IN ('PO')
        AND 351         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('PTA')
        AND 352         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('PFT')
        AND 353         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('PFA')
        AND 354         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('CLP')
        AND 355         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        OR (b.rsgacd    IN ('SPA')
        AND 356         IN (rsb0cd, rsb1cd, rsb2cd, rsb3cd, rsb4cd, rsb5cd))
        ) rrs
    ON p.apc7cd              = rrs.rsbtcd
    AND p.apc8cd             = rrs.rsbucd
    AND p.apc6cd             = rrs.rsfocd
    AND ris.iscjcd           = rrs.rsbvcd
    WHERE SUBSTR(p.apcucd,-1)='0'
      --and ris.isa4st ='1'
      ) src_data
    LEFT OUTER JOIN STAGEDBUSR2.SPPLANCONVERTION ssp
    ON ssp.oldzsalplan        = src_data.oldzsalplan
    AND ssp.relationship      = src_data.relationship
    AND ssp.CCSPECIALCONTRACT = src_data.crdt_card_ridr
    AND ssp.hcrflag           = src_data.hcr_coverage
      --WHERE SRC_DATA.OLDZSALPLAN NOT IN ('F15BXXX100X0-001','F19NXXX001X0-004')
    )
  SELECT APCUCD,
    CHDRNUM,
    mbrno,
    OLDZSALPLAN,
    RELATIONSHIP,
    crdt_card_ridr,
    hcr_coverage,
    NEWZSALPLAN
  FROM data_1 WHERE trim(NEWZSALPLAN) is null OR hcr_coverage IS NULL;

--Check if any missing policy
select * from stagedbusr2.zmrap00 where apcucd not in (select ICCUCD from stagedbusr2.zmric00);
select * from stagedbusr2.zmric00 where ICCUCD not in (select apcucd from stagedbusr2.zmrap00);  
  
--Endorser Checking
SELECT DISTINCT TRIM(apc6cd) FROM STAGEDBUSR2.ZMRAP00 WHERE TRIM(apc6cd) NOT IN (SELECT TRIM(ENDORSERCODE) FROM card_endorser_list);  
  
--Alter Reason Code Check
 select * from stagedbusr2.zmrap00 where apdlcd not in (SELECT DISTINCT dm_al_code FROM alter_reason_code) AND apdlcd NOT LIKE '*%';
 
--Decline Reason Code Check
 select * from stagedbusr2.zmrap00 where apdlcd not in (SELECT dm_r_code FROM decline_reason_code) AND apdlcd LIKE '*%';

--check all card endorser
select * from zmrap00 where APC6CD not in (select ENDORSERCODE from card_endorser_list);
 
--Tranno issue 
select apcucd, APCVCD, APA2DT, APDLCD from stagedbusr2.zmrap00 where substr(apcucd,1,8) in (select chdrnum from trannotbl_kevin where zseqno = '000' and tranno <> 1) order by apcucd;
select * from stagedbusr2.zmrap00 where substr(apcucd,2) <> '00' and substr(apcucd,-1) = '0'  and APCVCD > APA2DT;
