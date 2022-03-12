create or replace PACKAGE                                                   DM_PA_TRANNO  AS 

/***************************************************************************************************
    Date    Initials   Tag   Description
    -----   --------   ---   ---------------------------------------------------------------------------
   150121	CHO          	 PA ITR3 Implementation 
							 - Insert PRBILFDT to TRANNOTBL (DM_GENERATE_TRANNO)
							 - Add PRBILFDT condition when update to TITDMGBILL1 and TITDMGBILL2 (DM_PA_TRANNO_UPDATE)
   090221	CHO          	 ZJNPG-8963 - Add trancde and nrflag for Take Up policy changes for PA ITR3
							 [12012021  prabu & JD]
   280621   KLP				ZJNPG-9739, Fix for the tranno generation.			 
  *****************************************************************************************************/

  /* TODO enter package declarations (types, exceptions, methods etc) here 
	This package is used to generate the Tranno based on the transaction type and also it will synchronize the tranno 
	with the policy history module, Billing Installments & Refund
  
  */ 
 PROCEDURE dm_generate_tranno (
    p_array_size   IN   PLS_INTEGER DEFAULT 1000,
    p_delta        IN   CHAR DEFAULT 'N'
) ;


 PROCEDURE dm_PA_TRANNO_UPDATE (
    p_delta        IN   CHAR DEFAULT 'N'
) ;
END DM_PA_TRANNO;

/

create or replace PACKAGE BODY  DM_PA_TRANNO AS

  PROCEDURE dm_generate_tranno (
    p_array_size   IN   PLS_INTEGER DEFAULT 1000,
    p_delta        IN   CHAR DEFAULT 'N'
)  AS

/*CURSOR policy_cur IS
    SELECT DISTINCT
        a.chdrnum,
        b.trefnum AS oldpolnum
    FROM
        stagedbusr2.titdmgpoltrnh    a
        LEFT JOIN stagedbusr2.titdmgmbrindp1   b ON a.chdrnum = substr(b.refnum, 1, 8)
                                      AND b.trefnum IS NOT NULL
    ORDER BY
        1;*/

--Pre-Requisite for Titdmgbill1 Table 
--1. DBlink should be created to tables  ZESDPF and ZENDRPF (these two tables shoud be availbel in stagedbusr schema)
--2. Once above two tables are available in stagedbusr schema, Charles will  update the column ZACMCLDT  in TITDMGBILL1 table with zacmcldt value from above two tables based on conditions
--3. Value of column ZACMCLDT  in TITDMGBILL1 table should not be in ('99999999')

-- Below cursor has been changed for the performance improvement
-- Below cursor has been changed for ZJNPG-9739
    CURSOR tranno_cur 
	IS
    SELECT
        trim(chdrnum) chdrnum,
        zseqno,
        CASE
            WHEN t_type = 1 THEN
                'P'
            WHEN t_type = 2 THEN
                'B'
            WHEN t_type = 3 THEN
                'R'
        END t_type,
        zaltrcde_ref,
        t_date,
        PRBILFDT,
        btdate,
        EFFDATE,
		zaltr_type,
		trancde,--- 12012021  prabu & JD ended 
		nrflag --- 12012021  prabu & JD ended 
    FROM
        (
            SELECT DISTINCT --MKS
                 1 ord_seq,
                chdrnum,
                zseqno,
                1 AS t_type,
                b.zaltrcde01 AS zaltrcde_ref,
               -- zaltregdat AS t_date,
                case when b.effdate >= b.zaltregdat 
                and substr(utl_raw.cast_to_varchar2(c.genarea),6,4) = 'TERM'
                then
                b.effdate
                else
                b.zaltregdat
                end t_date,
                NULL AS PRBILFDT,
                null AS btdate, --MKS
                EFFDATE,
				substr(utl_raw.cast_to_varchar2(c.genarea),6,4) as zaltr_type,
				b.trancde, --- 12012021  prabu & JD ended 
				null nrflag --- 12012021  prabu & JD ended 
            FROM
                stagedbusr2.titdmgpoltrnh b
				left outer join stagedbusr.itempf c -- lprabu
				on 	trim(c.itemitem)=trim(b.zaltrcde01) 
					and  trim(c.itemtabl) = 'TQ9MP' 
					and trim(c.itemcoy) in (1, 9) 
					and trim(c.itempfx) = 'IT' 
					and trim(c.validflag)= '1'					            
               -- WHERE b.chdrnum = '00036234'  
            UNION ALL
           SELECT distinct 
                2 ord_seq,
                a.chdrnum,
                case when trrefnum = '1' and nrflag = 'N'
                then '000'
                else null  end zseqno,
                
               -- NULL AS zseqno,
                2 AS t_type,
                trrefnum   AS zaltrcde_ref,
                case when trrefnum = '1' and nrflag = 'N'
                then zaltregdat
                else zacmcldt end t_date,
                PRBILFDT AS PRBILFDT,
                PRBILTDT AS btdate, --MKS
                null as effdate,
				null zaltr_type,
				null trancde, --- 12012021  prabu & JD ended 
				nrflag --- 12012021  prabu & JD ended 
            FROM
                titdmgbill1 a left outer join stagedbusr2.titdmgpoltrnh b on a.chdrnum = b.chdrnum
                               and a.PRBILFDT = b.effdate
                               and b.zseqno = '000'
                
            WHERE zacmcldt not in ('99999999')
            --and  a.chdrnum = '00036234'
            UNION ALL
            SELECT DISTINCT
                3 ord_seq,
                a.chdrnum as chdrnum,
                NULL AS zseqno,
                3 AS t_type,
                refnum   AS zaltrcde_ref,
               --  max(b.effdate,b.zaltregdat) t_date,
                case when b.effdate >= b.zaltregdat then
                b.effdate
                else
                b.zaltregdat
                end t_date,
                NULL AS PRBILFDT,
                null AS btdate, --MKS
                null as effdate,
				null as zaltr_type, -- lprabu
				b.trancde, --- 12012021  prabu & JD ended 
				null nrflag --- 12012021  prabu & JD ended 
            FROM
                stagedbusr2.titdmgref1 a, 
				stagedbusr2.titdmgpoltrnh b
                join stagedbusr.itempf c -- lprabu
				on 	trim(c.itemitem)=trim(nvl(b.zaltrcde01,b.zstatresn)) 
					and  trim(c.itemtabl) = 'TQ9MP' 
					and trim(c.itemcoy) in (1, 9) 
					and trim(c.itempfx) = 'IT' 
					and trim(c.validflag)= '1'
					and substr(utl_raw.cast_to_varchar2(c.genarea),6,4) = 'TERM'
            WHERE trim(a.chdrnum) = trim(b.chdrnum)
                and a.effdate = b.effdate
              ---  and a.chdrnum = '00036234'
            UNION 
            SELECT DISTINCT
                3 ord_seq,
                a.chdrnum as chdrnum,
                NULL AS zseqno,
                3 AS t_type,
                refnum   AS zaltrcde_ref,
                b.zaltregdat t_date,
                NULL AS PRBILFDT,
                null AS btdate, --MKS
                null as effdate,
				null as zaltr_type, -- lprabu
				b.trancde, --- 12012021  prabu & JD ended 
				null nrflag --- 12012021  prabu & JD ended 
            FROM
                stagedbusr2.titdmgref1 a, 
				stagedbusr2.titdmgpoltrnh b
                join stagedbusr.itempf c -- lprabu
				on 	trim(c.itemitem)=trim(b.zstatresn) 
					and  trim(c.itemtabl) = 'TQ9FU' 
					and trim(c.itemcoy) in (1, 9) 
					and trim(c.itempfx) = 'IT' 
					and trim(c.validflag)= '1'
				-- 	and substr(utl_raw.cast_to_varchar2(c.genarea),6,4) = 'TERM'
            WHERE trim(a.chdrnum) = trim(b.chdrnum)
                and a.effdate = b.effdate   
              --  and a.chdrnum = '00036234'
        )
    ORDER BY chdrnum,t_date,zseqno,ord_seq,zaltrcde_ref;

    -- policy_cur_rec   policy_cur%rowtype;
    tranno_cur_rec   tranno_cur%rowtype;
    l_tranno         NUMBER := 0;
    l_date           VARCHAR2(8);
    old_l_date       VARCHAR2(8);
    l_type           CHAR(1);
    b_effdate        tranno_cur_rec.effdate%type;
    acd_clsrdate     tranno_cur_rec.effdate%type;
    r_effdate        tranno_cur_rec.effdate%type;
	lv_tmp_pol_no    stagedbusr2.titdmgpoltrnh.chdrnum%type := null;
	
  BEGIN
   /*IF p_delta = 'Y' THEN
        DELETE FROM stagedbusr.trannotbl t
        WHERE
            EXISTS (
                SELECT
                    1
                FROM
                    stageddbusr.zmrap00 dt
                WHERE
                    substr(dt.apcucd, 1, 8) = t.chdrnum
            );

        COMMIT;
    END IF; */

    -- OPEN policy_cur;
    -- LOOP
       --  FETCH policy_cur INTO policy_cur_rec;
       --  EXIT WHEN policy_cur%notfound;
       -- l_tranno := 0;
       -- l_date := '01010001';
       -- l_type := 'P';
        -- OPEN tranno_cur(policy_cur_rec.chdrnum);
		
		OPEN tranno_cur;
        LOOP
            FETCH tranno_cur INTO tranno_cur_rec;
            EXIT WHEN tranno_cur%notfound;
			
            IF nvl(lv_tmp_pol_no,'9999') <> tranno_cur_rec.chdrnum THEN
                        l_tranno := 0;
                        l_date := '01010001';
                        l_type := 'P';
            END IF;            
           
            ---  Below case to identify the new business transaction and set with 1
            CASE  WHEN  l_tranno = 0 and tranno_cur_rec.t_type in ('P') and TRIM(tranno_cur_rec.zaltrcde_ref) is null 
            and  trim(tranno_cur_rec.trancde) <> 'T928' 
            then
             l_tranno := l_tranno + 1;
             b_effdate :=tranno_cur_rec.effdate;

			 ------- 12012021  prabu & JD started
             ---  Below case to identify the renewal (take up policy). Set the tranno as 2
			 WHEN l_tranno = 0 and trim(tranno_cur_rec.trancde) = 'T928' and tranno_cur_rec.t_type in ('P')
			 then
				l_tranno := l_tranno + 2;
				b_effdate :=tranno_cur_rec.effdate;
			 ------- 12012021  prabu & JD ended 
             
                ---  Below case to identify the refund transaction and assign the same tranno with latest or previous tranno
                WHEN   tranno_cur_rec.t_type in ('R') 
                THEN
               
               l_tranno := l_tranno;
               
               ---  Below case to identify the billing installment tranaction (except first NB bill) and 
               --- increment the tranno for each bills
             WHEN   tranno_cur_rec.t_type in ('B') and TRANNO_CUR_REC.zaltrcde_ref <>'1' 
            THEN
            
             l_tranno := l_tranno + 1;
             
             -- Below case to identify the billing installment (first NB bill) and assign the tranno with 
             -- same tranno number of NB policy transaction (It will be always 1)
            
            WHEN   tranno_cur_rec.t_type in ('B') and TRANNO_CUR_REC.zaltrcde_ref='1' 
            And b_effdate = tranno_cur_rec.PRBILFDT  and trim(tranno_cur_rec.nrflag) <> 'R' 
            THEN

              l_tranno := l_tranno;
          
		   ---- 12012021  prabu & JD started
		   
             --- Below case to identify the billing installment for renewal bills and increment the tranno
             --- with one for each bill
             
             WHEN   tranno_cur_rec.t_type in ('B') and TRANNO_CUR_REC.zaltrcde_ref='1' 
			 and trim(tranno_cur_rec.nrflag) = 'R' 
			 then
					l_tranno := l_tranno + 1;
			
			---- 12012021  prabu & JD ended
             
             --- Below else part will increment the tranno with one for each transaction
             --- policy transaction like alterations
            ELSE
                                l_tranno := l_tranno + 1;
                                
                                
            END CASE;


            INSERT INTO TRANNOTBL(
                chdrnum,
                zseqno,
                t_type,
                zaltrcde_ref,
                t_date,
                tranno,
                -- oldpolnum,
                btdate,
				zaltr_type, -- lprabu
				prbilfdt -- Chong
            ) VALUES (
                tranno_cur_rec.chdrnum,
                decode(tranno_cur_rec.t_type,'B',null,tranno_cur_rec.zseqno),
               --  tranno_cur_rec.zseqno,
                tranno_cur_rec.t_type,
                tranno_cur_rec.zaltrcde_ref,
                tranno_cur_rec.t_date,
                l_tranno,
                -- policy_cur_rec.oldpolnum,
                tranno_cur_rec.btdate,
				tranno_cur_rec.zaltr_type,
				tranno_cur_rec.prbilfdt
            );

            l_date := tranno_cur_rec.t_date;
            l_type := tranno_cur_rec.t_type;
			
			lv_tmp_pol_no := tranno_cur_rec.chdrnum;
			
        END LOOP;

        CLOSE tranno_cur;
        COMMIT;
    -- END LOOP;-- Commented this for deployment issue ITR3 FT

    -- CLOSE policy_cur;
    exception
    when others then
    dbms_output.put_line (' TRANNO PROCEDURE : '||sqlerrm);
  END dm_generate_tranno;

  PROCEDURE dm_PA_TRANNO_UPDATE (
    p_delta        IN   CHAR DEFAULT 'N'
)  AS
  BEGIN

---Member and IND pol
update stagedbusr.titdmgmbrindp1 P1 set (trannomin,trannomax)=
( select trannomin,trannomax 
    from
        (select  chdrnum , min(tranno) trannomin ,max(tranno) trannomax 
            from STAGEDBUSR2.trannotbl GROUP by chdrnum) TRAN
where TRAN.chdrnum = substr(p1.refnum,1,8)
)
where EXISTS 
 (
select trannomin from(select  chdrnum , min(tranno) trannomin ,max(tranno) trannomax 
from STAGEDBUSR2.trannotbl GROUP by chdrnum) TRAN
where TRAN.chdrnum = substr(p1.refnum,1,8)
);

commit;

UPDATE stagedbusr.titdmgmbrindp1 b
  SET b.TRANNONBRN = (SELECT a.tranno from TRANNOTBL a WHERE substr(refnum,1,8) = a.chdrnum AND substr(b.refnum,9,2) = substr(a.zseqno,1,2) AND substr(a.zseqno,-1) = '0'  AND a.T_TYPE = 'P')
WHERE EXISTS 
        (SELECT a.tranno from TRANNOTBL a WHERE substr(refnum,1,8) = a.chdrnum AND substr(b.refnum,9,2) = substr(a.zseqno,1,2) AND substr(a.zseqno,-1) = '0'  AND a.T_TYPE = 'P');


commit;

--Billing Instalment 

update  stagedbusr.titdmgbill1 b set tranno = (select tranno
                                     from STAGEDBUSR2.trannotbl a
                                    where t_type = 'B'
                                      and a.chdrnum = b.chdrnum
                                      and a.zaltrcde_ref = b.trrefnum
									  and a.prbilfdt = b.prbilfdt);

commit;

update stagedbusr.titdmgbill2 b set tranno = (select tranno
                                     from STAGEDBUSR2.trannotbl a
                                    where t_type = 'B'
                                      and a.chdrnum = b.chdrnum
                                      and a.zaltrcde_ref = b.trrefnum
									  and a.prbilfdt = b.prbilfdt);

commit;

update  stagedbusr.titdmgref1 b set tranno = (select tranno
                                     from STAGEDBUSR2.trannotbl a
                                    where t_type = 'R'
                                      and a.chdrnum = b.chdrnum
                                      and a.zaltrcde_ref = b.refnum);

commit;

update stagedbusr.titdmgref2 b set tranno = (select tranno
                                     from STAGEDBUSR2.trannotbl a
                                    where t_type = 'R'
                                      and a.chdrnum = b.chdrnum
                                      and a.zaltrcde_ref = b.trrefnum);

commit;

  ---Update for Policy History
    update stagedbusr.TITDMGPOLTRNH a
    set  a.tranno = (select b.TRANNO from STAGEDBUSR2.trannotbl b WHERE b.chdrnum = a.chdrnum and b.zseqno = a.zseqno and b.t_type = 'P'),
    a.intrefund = (select SUM(b.ZREFUNDBE) + SUM(b.ZREFUNDBZ) FROM stagedbusr.TITDMGREF1 b where trim(b.CHDRNUM) = trim(a.CHDRNUM)),
    a.mintranno = (select min(b.TRANNO) from STAGEDBUSR2.trannotbl b WHERE b.chdrnum = a.chdrnum and b.t_type = 'P');
	COMMIT;

    update stagedbusr.TITDMGPOLTRNH a
    set  a.btdate = (select  decode(bt_min, null, bt_max,  bt_min)  
                        from (
                            select a.chdrnum, a.tranno,
                            (SELECT MAX(b.btdate) FROM STAGEDBUSR2.trannotbl b WHERE b.chdrnum = a.chdrnum  AND a.tranno >= b.tranno AND b.t_type = 'B') as bt_min,
                            (SELECT MIN(b.btdate) FROM STAGEDBUSR2.trannotbl b WHERE b.chdrnum = a.chdrnum  AND a.tranno < b.tranno AND b.t_type = 'B') as bt_max 
                            from dual
                            ) 
                    );
	COMMIT;

	update stagedbusr.TITDMGMBRINDP2 a
      set  a.tranno = (select b.TRANNO from STAGEDBUSR2.trannotbl b WHERE b.chdrnum = a.refnum and b.zseqno = a.zseqno and b.t_type = 'P')
    WHERE exists (select 1 from STAGEDBUSR2.trannotbl b WHERE b.chdrnum = a.refnum and b.zseqno = a.zseqno and b.t_type = 'P');
	COMMIT;

    update stagedbusr.TITDMGMBRINDP2 p2
      set  p2.zplancde = (select ph.zplancde from stagedbusr.TITDMGPOLTRNH ph WHERE ph.chdrnum = p2.refnum and ph.zseqno = p2.zseqno and p2.mbrno = ph.mbrno)
    WHERE exists (select 1 from stagedbusr.TITDMGPOLTRNH ph WHERE ph.chdrnum = p2.refnum and ph.zseqno = p2.zseqno and p2.mbrno = ph.mbrno);
    COMMIT;

    update stagedbusr.TITDMGAPIRNO a
		set  a.tranno = (select MIN(b.TRANNO) from STAGEDBUSR2.trannotbl b WHERE b.chdrnum = a.chdrnum and b.t_type = 'P')
    WHERE exists (select 1 from STAGEDBUSR2.trannotbl b WHERE b.chdrnum = a.chdrnum and b.t_type = 'P');
	COMMIT;

  END dm_PA_TRANNO_UPDATE;

END DM_PA_TRANNO;

/
