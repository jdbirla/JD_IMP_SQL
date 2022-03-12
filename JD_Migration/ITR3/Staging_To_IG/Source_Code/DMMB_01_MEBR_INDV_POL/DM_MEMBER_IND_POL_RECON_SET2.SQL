create or replace PROCEDURE DM_MEMBER_IND_POL_RECON_SET2  
(
  p_detail_batch_id IN VARCHAR2,
  p_summary_batch_id IN VARCHAR2
) AS 
 v_timestart          NUMBER := dbms_utility.get_time;
-- Total attribs 44

/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR POLICY_BASED_ENDORSER*/

Cursor CUR_MASTER_SRC_RECON IS
with data_1 as(
select  distinct 'source' data_from ,
a.apc6cd pol_based_endorser,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_BASED_ENDORSER' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'
union all
Select  distinct 'staging', a.zendcde ,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_BASED_ENDORSER' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
select  distinct 'IG',a.zendcde, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_BASED_ENDORSER' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchppf a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)
select a.v_policy_no, a.pol_based_endorser src_val,
b.pol_based_endorser stg_val,
c.pol_based_endorser ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.pol_based_endorser <> b.pol_based_endorser
or b.pol_based_endorser <> c.pol_based_endorser
or a.pol_based_endorser <> c.pol_based_endorser)
order by a.v_policy_no;

Type Master_array is TABLE OF CUR_MASTER_SRC_RECON%rowtype;
PROCESS_DATA    CUR_MASTER_SRC_RECON%ROWTYPE;
V_SRC_DESC VARCHAR2(300) := 'Effective date from Source ZMRAP00.APA2DT ';
Err_desc    Varchar2(500);

/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR POLICY_PLAN_CLASS*/
Cursor CUR_PLAN_CLASS_RECON IS
with data_1 as(
select  distinct 'source' data_from ,
RPT.RPTFPST pol_plan_class,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_PLAN_CLASS' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a,
stagedbusr2.ZMRRPT00@DMSTGUSR2DBLINK  RPT,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
AND RPT.RPTBTCD = a.APC7CD
and b.v_pol_type ='IND_MEMBER'
union all
Select  distinct 'staging', a.PLNCLASS ,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_PLAN_CLASS' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
select  distinct 'IG',substr(ZPLANCLS,1,1), b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_PLAN_CLASS' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchppf a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER')
select a.v_policy_no, a.pol_plan_class src_val,
b.pol_plan_class stg_val,
c.pol_plan_class ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.pol_plan_class <> b.pol_plan_class
or b.pol_plan_class <> c.pol_plan_class
or a.pol_plan_class <> c.pol_plan_class)
order by a.v_policy_no;
Type Master_array2 is TABLE OF CUR_PLAN_CLASS_RECON%rowtype;
PROCESS_DATA2    CUR_PLAN_CLASS_RECON%ROWTYPE;
/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR POLICY_STATCODE*/
Cursor CUR_STATCODE_RECON IS
with data_1 as(
select  distinct 'source' data_from ,
a.statcode statcode,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_STATCODE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from
                  stagedbusr2.policy_statcode@DMSTGUSR2DBLINK                 a
                  inner join stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK b on a.chdrnum = b.v_policy_no
where 
 b.v_pol_type ='IND_MEMBER'
union all
Select  distinct 'staging', a.statcode ,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_STATCODE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
select  distinct 'IG',a.STATCODE, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_STATCODE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchD a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER' )
select a.v_policy_no, a.STATCODE src_val,
b.STATCODE stg_val,
c.STATCODE ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.STATCODE <> b.STATCODE
or b.STATCODE <> c.STATCODE
or a.STATCODE <> c.STATCODE)
order by a.v_policy_no;

Type Master_array3 is TABLE OF CUR_STATCODE_RECON%rowtype;
PROCESS_DATA3    CUR_STATCODE_RECON%ROWTYPE;

/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR CUR_INSURED_DATA_RECON*/

Cursor CUR_INSURED_DATA_RECON IS
with data_1 as(
select  distinct 'source' data_from ,
substr(a.insur_role,2,1) pol_insur_role,
a.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_INSURED_DATA' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from 
(select a.chdrnum||'-'||substr(a.iscicd,-2) v_policy_no ,insur_role, max(substr(a.apcucd,9,3))  from stagedbusr2.PERSNL_CLNT_FLG@DMSTGUSR2DBLINK a
where a.isa4st is not null
and a.insur_typ = 'I' 
group by a.chdrnum, substr(a.iscicd,-2),insur_role ) a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where substr(a.v_policy_no,1,8) = b.v_policy_no
and b.v_pol_type ='IND_MEMBER' 

--and substr(a.apcucd,1,8) = '15620X87'
union all
Select  distinct 'staging', a.ZINSROLE pol_insur_role ,
a.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_INSURED_DATA' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from 
(select substr(refnum,1,8)||'-'||mbrno v_policy_no,zinsrole  from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK 
where client_category in('1')) a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where substr(a.v_policy_no,1,8) = b.v_policy_no
and b.v_pol_type ='IND_MEMBER'
union all
select  distinct 'IG',a.zinsrole pol_insur_role, 
a.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_INSURED_DATA' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from 
(select chdrnum||'-'||substr(mbrno,-2) v_policy_no , zinsrole, max(tranno) from
Jd1dta.zinsdtlspf  group by chdrnum,mbrno, zinsrole) a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where substr(a.v_policy_no,1,8) = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'

)
--and a.zinsrole='1')
select substr(a.v_policy_no,1,8) v_policy_no, a.pol_insur_role src_val,
b.pol_insur_role stg_val,
c.pol_insur_role ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.pol_insur_role <> b.pol_insur_role
or b.pol_insur_role <> c.pol_insur_role
or a.pol_insur_role <> c.pol_insur_role);

Type Master_array4 is TABLE OF CUR_INSURED_DATA_RECON%rowtype;
PROCESS_DATA4    CUR_INSURED_DATA_RECON%ROWTYPE;

/*REMOVED CUR_SALES_PLAN_RECON as this is a duplicate of attribute GMHIPF_ZPLANCDE */

/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR CUR_POLICY_TERM_RECON*/
Cursor CUR_POLICY_TERM_RECON IS
with data_1 as(
select  distinct 'source' data_from ,APA2DT src_strt_dt,  Apbedt src_CR_date,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_TERM' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
FROM STAGEDBUSR2.zmrap00@DMSTGUSR2DBLINK  a
inner join stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK b on b.v_policy_no = substr(a.apcucd,1,8)
WHERE  substr(a.apcucd,-3) = '000'
union all
Select  distinct 'staging', a.effdate src_strt_dt, a.crdate src_CR_date,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_TERM' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
select  distinct 'IG', a.effdate src_strt_dt, to_number(to_char(to_date(a.crdate,'yyyymmdd') +1,'yyyymmdd')) src_CR_date, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_TERM' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHipF a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER')
select a.v_policy_no,
a.src_strt_dt src_strt_dt_a,
b.src_strt_dt src_strt_dt_b,
c.src_strt_dt src_strt_dt_c,
a.src_CR_date src_CR_date_a,
b.src_CR_date src_CR_date_b,
c.src_CR_date src_CR_date_c,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.src_strt_dt <> b.src_strt_dt
or b.src_strt_dt <> c.src_strt_dt
or a.src_strt_dt <> c.src_strt_dt
or a.src_CR_date <> b.src_CR_date
or b.src_CR_date <> c.src_CR_date
or a.src_CR_date <> c.src_CR_date)
order by a.v_policy_no;

Type Master_array6 is TABLE OF CUR_POLICY_TERM_RECON%rowtype;
PROCESS_DATA6    CUR_POLICY_TERM_RECON%ROWTYPE;
/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR CUR_START_DATE_RECON*/
Cursor CUR_START_DATE_RECON IS
with data_1 as(
select  distinct 'source' data_from ,
a.APA2DT  pol_START_DT,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_START_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
FROM
stagedbusr2.zmrap00@DMSTGUSR2DBLINK              a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK b  
WHERE  --a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt  
substr(a.apcucd,-3) = '000'
and substr(a.apcucd,1,8) =b.v_policy_no 
union all
Select  distinct 'staging', a.effdate pol_START_DT,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_START_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '1'
and b.v_pol_type ='IND_MEMBER'
union all
select  distinct 'IG',a.effdate pol_START_DT, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_START_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchipf a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER')
select a.v_policy_no, a.pol_START_DT src_val,
b.pol_START_DT stg_val,
c.pol_START_DT ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.pol_START_DT <> b.pol_START_DT
or b.pol_START_DT <> c.pol_START_DT
or a.pol_START_DT <> c.pol_START_DT)
order by a.v_policy_no;
Type Master_array7 is TABLE OF CUR_START_DATE_RECON%rowtype;
PROCESS_DATA7    CUR_START_DATE_RECON%ROWTYPE;

/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR CUR_END_DATE_RECON*/

Cursor CUR_END_DATE_RECON IS
with data_1 as(
select  distinct 'source' data_from ,
a.APBEDT  pol_END_DT,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_END_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
FROM
stagedbusr2.zmrap00@DMSTGUSR2DBLINK              a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK b  
WHERE  --a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt  
substr(a.apcucd,-3) = '000'
and substr(a.apcucd,1,8) =b.v_policy_no 
union all
Select  distinct 'staging', a.CRDATE pol_END_DT,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_END_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '1'
and b.v_pol_type ='IND_MEMBER'
union all
select  distinct 'IG',to_number(to_char(to_date(a.crdate,'yyyymmdd') +1,'yyyymmdd')) pol_END_DT, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_END_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchipf a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER')
select a.v_policy_no, a.pol_END_DT src_val,
b.pol_END_DT stg_val,
c.pol_END_DT ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.pol_END_DT <> b.pol_END_DT
or b.pol_END_DT <> c.pol_END_DT
or a.pol_END_DT <> c.pol_END_DT)
order by a.v_policy_no;
Type Master_array8 is TABLE OF CUR_END_DATE_RECON%rowtype;
PROCESS_DATA8    CUR_END_DATE_RECON%ROWTYPE;

/*----------------BEGIN - ATTRIB : OCCDATE - SET 2 RECON ITR3 ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
--to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR CUR_OCCDATE_RECON*/

/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR POLICY_COMNCMT_DATE*/

Cursor CUR_POLICY_COMNCMT_DATE_RECON IS
with data_1 as (
select  distinct 'source' data_from,
a.occdate  POLICY_COMNCMT_DATE,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_COMNCMT_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'
union all
-- staging
Select  distinct 'staging', 
a.occdate POLICY_COMNCMT_DATE,
b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_COMNCMT_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
-- ig tables
select  distinct 'IG',a.occdate POLICY_COMNCMT_DATE, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_COMNCMT_DATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchd a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)select a.v_policy_no, a.POLICY_COMNCMT_DATE src_val,
b.POLICY_COMNCMT_DATE stg_val,
c.POLICY_COMNCMT_DATE ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.POLICY_COMNCMT_DATE <> b.POLICY_COMNCMT_DATE
or b.POLICY_COMNCMT_DATE <> c.POLICY_COMNCMT_DATE
or a.POLICY_COMNCMT_DATE <> c.POLICY_COMNCMT_DATE)
order by a.v_policy_no;

Type Master_array9 is TABLE OF CUR_POLICY_COMNCMT_DATE_RECON%rowtype;
PROCESS_DATA9    CUR_POLICY_COMNCMT_DATE_RECON%ROWTYPE;

/* Following cursor is to fetch NON-MATCHING VALUES OF SRC, STG, IG rows FOR POLICY_BILLED_TODATE*/

Cursor CUR_POLICY_BILLED_TODATE_RECON IS
with data_1 as (
select  distinct 'source' data_from,
pst.btdate  POLICY_BILLED_TODATE,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_BILLED_TODATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
left join stagedbusr2.policy_statcode@DMSTGUSR2DBLINK pst on a.apcucd= pst.apcucd
,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'
union all
-- staging
Select  distinct 'staging', a.btdate POLICY_BILLED_TODATE,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_BILLED_TODATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
-- ig tables
select  distinct 'IG',a.btdate POLICY_BILLED_TODATE, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_BILLED_TODATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchd a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)select a.v_policy_no, a.POLICY_BILLED_TODATE src_val,
b.POLICY_BILLED_TODATE stg_val,
c.POLICY_BILLED_TODATE ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.POLICY_BILLED_TODATE <> b.POLICY_BILLED_TODATE
or b.POLICY_BILLED_TODATE <> c.POLICY_BILLED_TODATE
or a.POLICY_BILLED_TODATE <> c.POLICY_BILLED_TODATE)
order by a.v_policy_no;

Type Master_array10 is TABLE OF CUR_POLICY_BILLED_TODATE_RECON%rowtype;
PROCESS_DATA10    CUR_POLICY_BILLED_TODATE_RECON%ROWTYPE;
/*----------------END CURSOR SQL - ATTRIB : POLICY_BILLED_TODATE - SET 2 RECON ITR3 ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
/*----------------BEGIN - ATTRIB : POLICY_PAID_TODATE - SET 2 RECON ITR3 ATTRIBUTE-------------------------------------------------------------------------------------------*/ 

Cursor CUR_POLICY_PAID_TODATE_RECON IS
with data_1 as (
-- source
select  distinct 'source' data_from,
pst.ptdate  POLICY_PAID_TODATE,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_PAID_TODATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
left join stagedbusr2.policy_statcode@DMSTGUSR2DBLINK pst on a.apcucd= pst.apcucd
,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'
union all
-- staging
Select  distinct 'staging', a.ptdate POLICY_PAID_TODATE,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_PAID_TODATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
-- ig tables
select  distinct 'IG',a.ptdate POLICY_PAID_TODATE, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_PAID_TODATE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchd a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)select a.v_policy_no, a.POLICY_PAID_TODATE src_val,
b.POLICY_PAID_TODATE stg_val,
c.POLICY_PAID_TODATE ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.POLICY_PAID_TODATE <> b.POLICY_PAID_TODATE
or b.POLICY_PAID_TODATE <> c.POLICY_PAID_TODATE
or a.POLICY_PAID_TODATE <> c.POLICY_PAID_TODATE)
order by a.v_policy_no;
Type Master_array11 is TABLE OF CUR_POLICY_PAID_TODATE_RECON%rowtype;
PROCESS_DATA11    CUR_POLICY_PAID_TODATE_RECON%ROWTYPE;

/*----------------END CURSOR SQL - ATTRIB : POLICY_PAID_TODATE - SET 2 RECON ITR3 ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
/*----------------BEGIN - ATTRIB : POLICY_UPPER_RNAGE - SET 2 RECON ITR3 ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
Cursor CUR_POLICY_UPPER_RNAGE_RECON IS
with data_1 as (
-- source
select  distinct 'source' data_from,
r.ULANWLT  POLICY_UPPER_RNAGE,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_UPPER_RNAGE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
LEFT JOIN stagedbusr2.zmrula00@DMSTGUSR2DBLINK r ON a.apc6cd = r.ulac6cd
                                        AND a.apc7cd = r.ulac7cd
,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'
union all
-- staging
Select  distinct 'staging', a.TERMAGE POLICY_UPPER_RNAGE,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_UPPER_RNAGE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
-- ig tables
select  distinct 'IG',a.TERMAGE POLICY_UPPER_RNAGE, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_UPPER_RNAGE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchd a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)select a.v_policy_no, a.POLICY_UPPER_RNAGE src_val,
b.POLICY_UPPER_RNAGE stg_val,
c.POLICY_UPPER_RNAGE ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.POLICY_UPPER_RNAGE <> b.POLICY_UPPER_RNAGE
or b.POLICY_UPPER_RNAGE <> c.POLICY_UPPER_RNAGE
or a.POLICY_UPPER_RNAGE <> c.POLICY_UPPER_RNAGE)
order by a.v_policy_no;

Type Master_array12 is TABLE OF CUR_POLICY_UPPER_RNAGE_RECON%rowtype;
PROCESS_DATA12    CUR_POLICY_UPPER_RNAGE_RECON%ROWTYPE;

/*----------------END CURSOR - ATTRIB : POLICY_UPPER_RNAGE - SET 2 RECON ITR3 ATTRIBUTE-------------------------------------------------------------------------------------------*/ 

/*----------------BEGIN - ATTRIB : POLICY_MAX_RNAGE - SET 2 RECON ITR3  ATTRIBUTE-------------------------------------------------------------------------------------------*/ /*----------------BEGIN - ATTRIB : OCCDATE - SET 2 RECON ITR3 ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
Cursor CUR_POLICY_MAX_RNAGE_RECON IS
with data_1 as (
-- source
select  distinct 'source' data_from,
r.ULAB0NB  POLICY_MAX_RNAGE,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_MAX_RNAGE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
LEFT JOIN stagedbusr2.zmrula00@DMSTGUSR2DBLINK r ON a.apc6cd = r.ulac6cd
                                        AND a.apc7cd = r.ulac7cd
,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'
union all
-- staging
Select  distinct 'staging', a.ZRWNLAGE POLICY_MAX_RNAGE,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_MAX_RNAGE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
-- ig tables
select  distinct 'IG',a.ZRWNLAGE POLICY_MAX_RNAGE, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_MAX_RNAGE' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchd a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)select a.v_policy_no, a.POLICY_MAX_RNAGE src_val,
b.POLICY_MAX_RNAGE stg_val,
c.POLICY_MAX_RNAGE ig_val,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.d_pol_end_dt d_pol_end_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
a.n_alt_cnt n_alt_cnt, 
a.n_ren_cnt n_ren_cnt, 
a.v_pol_type  v_pol_type
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.POLICY_MAX_RNAGE <> b.POLICY_MAX_RNAGE
or b.POLICY_MAX_RNAGE <> c.POLICY_MAX_RNAGE
or a.POLICY_MAX_RNAGE <> c.POLICY_MAX_RNAGE)
order by a.v_policy_no;
Type Master_array13 is TABLE OF CUR_POLICY_UPPER_RNAGE_RECON%rowtype;
PROCESS_DATA13    CUR_POLICY_UPPER_RNAGE_RECON%ROWTYPE;


begin

            BEGIN
            /*----------------BEGIN - POLICY_BASED_ENDORSER  ATTRIBUTE-------------------------------------------------------------------------------------------*/

            OPEN CUR_MASTER_SRC_RECON;
              LOOP
              FETCH CUR_MASTER_SRC_RECON INTO PROCESS_DATA;
              EXIT WHEN CUR_MASTER_SRC_RECON%NOTFOUND;
            Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA.V_POLICY_NO,
                                                             PROCESS_DATA.V_PRD_CDE,
                                                             PROCESS_DATA.D_POL_START_DT,
                                                             PROCESS_DATA.V_ATTRIB_NAME,
                                                             PROCESS_DATA.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA.src_val,
                                                             PROCESS_DATA.stg_val,
                                                             PROCESS_DATA.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            end loop;
             COMMIT;

            CLOSE CUR_MASTER_SRC_RECON;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_BASED_ENDORSER'|| PROCESS_DATA.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_BASED_ENDORSER'|| PROCESS_DATA.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;
/*----------------END- POLICY_BASED_ENDORSER  ATTRIBUTE-------------------------------------------------------------------------------------------*/

/*----------------BEGIN - POLICY_PLAN_CLASS  ATTRIBUTE-------------------------------------------------------------------------------------------*/
            BEGIN

            OPEN CUR_PLAN_CLASS_RECON;
              LOOP
              FETCH CUR_PLAN_CLASS_RECON INTO PROCESS_DATA2;
              EXIT WHEN CUR_PLAN_CLASS_RECON%NOTFOUND;
              Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA2.V_POLICY_NO,
                                                             PROCESS_DATA2.V_PRD_CDE,
                                                             PROCESS_DATA2.D_POL_START_DT,
                                                             PROCESS_DATA2.V_ATTRIB_NAME,
                                                             PROCESS_DATA2.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA2.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA2.src_val,
                                                             PROCESS_DATA2.stg_val,
                                                             PROCESS_DATA2.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            END LOOP;
            COMMIT;

            CLOSE CUR_PLAN_CLASS_RECON;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_PLAN_CLASS'|| PROCESS_DATA2.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_PLAN_CLASS'|| PROCESS_DATA2.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;

/*----------------END - POLICY_PLAN_CLASS  ATTRIBUTE-------------------------------------------------------------------------------------------*/

/*----------------BEGIN - POLICY_STATCODE  ATTRIBUTE-------------------------------------------------------------------------------------------*/
            BEGIN
             OPEN CUR_STATCODE_RECON;
              LOOP
              FETCH CUR_STATCODE_RECON INTO PROCESS_DATA3;
              EXIT WHEN CUR_STATCODE_RECON%NOTFOUND;
              Err_desc:=NULL;
             insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA3.V_POLICY_NO,
                                                             PROCESS_DATA3.V_PRD_CDE,
                                                             PROCESS_DATA3.D_POL_START_DT,
                                                             PROCESS_DATA3.V_ATTRIB_NAME,
                                                             PROCESS_DATA3.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA3.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA3.src_val,
                                                             PROCESS_DATA3.stg_val,
                                                             PROCESS_DATA3.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            END LOOP;
            COMMIT;

            CLOSE CUR_STATCODE_RECON;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_STATCODE'|| PROCESS_DATA3.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_STATCODE'|| PROCESS_DATA3.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;
/*----------------END - POLICY_STATCODE  ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
/*----------------BEGIN - POLICY_INSURED_DATA  ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
--CUR_INSURED_DATA_RECON
            BEGIN
            OPEN CUR_INSURED_DATA_RECON;
              LOOP
              FETCH CUR_INSURED_DATA_RECON INTO PROCESS_DATA4;
              EXIT WHEN CUR_INSURED_DATA_RECON%NOTFOUND;
              Err_desc:=NULL;
            insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                               ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA4.V_POLICY_NO,
                                                             PROCESS_DATA4.V_PRD_CDE,
                                                             PROCESS_DATA4.D_POL_START_DT,
                                                             PROCESS_DATA4.V_ATTRIB_NAME,
                                                             PROCESS_DATA4.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA4.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA4.src_val,
                                                             PROCESS_DATA4.stg_val,
                                                             PROCESS_DATA4.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            END LOOP;
            COMMIT;

            CLOSE CUR_INSURED_DATA_RECON;
             EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_INSURED_DATA'|| PROCESS_DATA4.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_INSURED_DATA'|| PROCESS_DATA4.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;



/*----------------END - POLICY_INSURED_DATA   ATTRIBUTE-------------------------------------------------------------------------------------------*/ 

/*----------------BEGIN - POLICY_SALES_PLAN  ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
--Removed this code as this is duplicate of GMHIPF_ZPLANCDE
/*----------------END - POLICY_SALES_PLAN   ATTRIBUTE-------------------------------------------------------------------------------------------*/ 

/*----------------BEGIN - POLICY_TERM   ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
            BEGIN
             OPEN CUR_POLICY_TERM_RECON;
              LOOP
              FETCH CUR_POLICY_TERM_RECON INTO PROCESS_DATA6;
              EXIT WHEN CUR_POLICY_TERM_RECON%NOTFOUND;
              Err_desc:=NULL;
              insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA6.V_POLICY_NO,
                                                             PROCESS_DATA6.V_PRD_CDE,
                                                             PROCESS_DATA6.D_POL_START_DT,
                                                             PROCESS_DATA6.V_ATTRIB_NAME,
                                                             PROCESS_DATA6.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA6.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA6.src_strt_dt_a||','||PROCESS_DATA6.src_CR_date_a,
                                                             PROCESS_DATA6.src_strt_dt_b||','||PROCESS_DATA6.src_CR_date_b,
                                                             PROCESS_DATA6.src_strt_dt_c||','||PROCESS_DATA6.src_CR_date_c,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            END LOOP;
            COMMIT;

            CLOSE CUR_POLICY_TERM_RECON;
              EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_TERM'|| PROCESS_DATA6.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_TERM'|| PROCESS_DATA6.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;
/*----------------END - POLICY_TERM   ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
/*----------------BEGIN - POLICY_START_DATE   ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
--CUR_START_DATE_RECON
            BEGIN
            OPEN CUR_START_DATE_RECON;
              LOOP
              FETCH CUR_START_DATE_RECON INTO PROCESS_DATA7;
              EXIT WHEN CUR_START_DATE_RECON%NOTFOUND;
              Err_desc:=NULL;
            insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA7.V_POLICY_NO,
                                                             PROCESS_DATA7.V_PRD_CDE,
                                                             PROCESS_DATA7.D_POL_START_DT,
                                                             PROCESS_DATA7.V_ATTRIB_NAME,
                                                             PROCESS_DATA7.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA7.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA7.src_val,
                                                             PROCESS_DATA7.stg_val,
                                                             PROCESS_DATA7.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            END LOOP;
            COMMIT;

            CLOSE CUR_START_DATE_RECON;
              EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_START_DATE'|| PROCESS_DATA7.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_START_DATE'|| PROCESS_DATA7.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            END;
/*----------------END - POLICY_START_DATE   ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
/*----------------BEGIN - POLICY_END_DATE   ATTRIBUTE-------------------------------------------------------------------------------------------*/ 

            BEGIN
            OPEN CUR_END_DATE_RECON;
              LOOP
              FETCH CUR_END_DATE_RECON INTO PROCESS_DATA8;
              EXIT WHEN CUR_END_DATE_RECON%NOTFOUND;
              Err_desc:=NULL;
            insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                         V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,      V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA8.V_POLICY_NO,
                                                             PROCESS_DATA8.V_PRD_CDE,
                                                             PROCESS_DATA8.D_POL_START_DT,
                                                             PROCESS_DATA8.V_ATTRIB_NAME,
                                                             PROCESS_DATA8.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA8.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA8.src_val,
                                                             PROCESS_DATA8.stg_val,
                                                             PROCESS_DATA8.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            END LOOP;
            COMMIT;

            CLOSE CUR_END_DATE_RECON;
              EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_END_DATE'|| PROCESS_DATA8.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_END_DATE'|| PROCESS_DATA8.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;
/*----------------END - POLICY_END_DATE   ATTRIBUTE-------------------------------------------------------------------------------------------*/ 

/*----------------BEGIN - ATTRIB : OCCDATE - SET 2 RECON ITR3  ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
BEGIN 

OPEN CUR_POLICY_COMNCMT_DATE_RECON;
              LOOP
              FETCH CUR_POLICY_COMNCMT_DATE_RECON INTO PROCESS_DATA9;
              EXIT WHEN CUR_POLICY_COMNCMT_DATE_RECON%NOTFOUND;
            Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA9.V_POLICY_NO,
                                                             PROCESS_DATA9.V_PRD_CDE,
                                                             PROCESS_DATA9.D_POL_START_DT,
                                                             PROCESS_DATA9.V_ATTRIB_NAME,
                                                             PROCESS_DATA9.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA9.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA9.src_val,
                                                             PROCESS_DATA9.stg_val,
                                                             PROCESS_DATA9.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            end loop;
             COMMIT;

            CLOSE CUR_POLICY_COMNCMT_DATE_RECON;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_COMNCMT_DATE'|| PROCESS_DATA9.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_COMNCMT_DATE'|| PROCESS_DATA9.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;



/*----------------END - ATTRIB : OCCDATE - SET 2 RECON ITR3  ATTRIBUTE-------------------------------------------------------------------------------------------*/ 

/*----------------BEGIN - ATTRIB : POLICY_BILLED_TODATE - SET 2 RECON ITR3 ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
BEGIN 

OPEN CUR_POLICY_BILLED_TODATE_RECON;
              LOOP
              FETCH CUR_POLICY_BILLED_TODATE_RECON INTO PROCESS_DATA10;
              EXIT WHEN CUR_POLICY_BILLED_TODATE_RECON%NOTFOUND;
            Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA10.V_POLICY_NO,
                                                             PROCESS_DATA10.V_PRD_CDE,
                                                             PROCESS_DATA10.D_POL_START_DT,
                                                             PROCESS_DATA10.V_ATTRIB_NAME,
                                                             PROCESS_DATA10.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA10.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA10.src_val,
                                                             PROCESS_DATA10.stg_val,
                                                             PROCESS_DATA10.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            end loop;
             COMMIT;

            CLOSE CUR_POLICY_BILLED_TODATE_RECON;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_BILLED_TODATE'|| PROCESS_DATA10.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_BILLED_TODATE'|| PROCESS_DATA10.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;
/*----------------END - ATTRIB : POLICY_BILLED_TODATE - SET 2 RECON ITR3  ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
BEGIN 

OPEN CUR_POLICY_PAID_TODATE_RECON;
              LOOP
              FETCH CUR_POLICY_PAID_TODATE_RECON INTO PROCESS_DATA11;
              EXIT WHEN CUR_POLICY_PAID_TODATE_RECON%NOTFOUND;
            Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA11.V_POLICY_NO,
                                                             PROCESS_DATA11.V_PRD_CDE,
                                                             PROCESS_DATA11.D_POL_START_DT,
                                                             PROCESS_DATA11.V_ATTRIB_NAME,
                                                             PROCESS_DATA11.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA11.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA11.src_val,
                                                             PROCESS_DATA11.stg_val,
                                                             PROCESS_DATA11.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            end loop;
             COMMIT;

            CLOSE CUR_POLICY_PAID_TODATE_RECON;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_PAID_TODATE'|| PROCESS_DATA11.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_PAID_TODATE'|| PROCESS_DATA11.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;
/*----------------END - ATTRIB : POLICY_BILLED_TODATE - SET 2 RECON ITR3  ATTRIBUTE-------------------------------------------------------------------------------------------*/ 
BEGIN 

OPEN CUR_POLICY_UPPER_RNAGE_RECON;
              LOOP
              FETCH CUR_POLICY_UPPER_RNAGE_RECON INTO PROCESS_DATA12;
              EXIT WHEN CUR_POLICY_UPPER_RNAGE_RECON%NOTFOUND;
            Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA12.V_POLICY_NO,
                                                             PROCESS_DATA12.V_PRD_CDE,
                                                             PROCESS_DATA12.D_POL_START_DT,
                                                             PROCESS_DATA12.V_ATTRIB_NAME,
                                                             PROCESS_DATA12.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA12.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA12.src_val,
                                                             PROCESS_DATA12.stg_val,
                                                             PROCESS_DATA12.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            end loop;
             COMMIT;

            CLOSE CUR_POLICY_UPPER_RNAGE_RECON;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_UPPER_RNAGE'|| PROCESS_DATA12.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_UPPER_RNAGE'|| PROCESS_DATA12.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;
/*----------------END - ATTRIB : POLICY_POLICY_UPPER_RNAGE - SET 2 RECON ITR3  ATTRIBUTE-------------------------------------------------------------------------------------------*/ 


BEGIN
/*----------------BEGIN - POLICY_MAX_RNAGE   ATTRIBUTE-------------------------------------------------------------------------------------------*/

            OPEN CUR_POLICY_MAX_RNAGE_RECON;
              LOOP
              FETCH CUR_POLICY_MAX_RNAGE_RECON INTO PROCESS_DATA13;
              EXIT WHEN CUR_POLICY_MAX_RNAGE_RECON%NOTFOUND;
            Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
                                                    values (p_detail_batch_id,
                                                             PROCESS_DATA13.V_POLICY_NO,
                                                             PROCESS_DATA13.V_PRD_CDE,
                                                             PROCESS_DATA13.D_POL_START_DT,
                                                             PROCESS_DATA13.V_ATTRIB_NAME,
                                                             PROCESS_DATA13.V_POL_STATUS,
                                                              'Member and Individual Policy',
                                                             PROCESS_DATA.D_POL_START_DT,
                                                             V_SRC_DESC,
                                                             PROCESS_DATA13.src_val,
                                                             PROCESS_DATA13.stg_val,
                                                             PROCESS_DATA13.ig_val,
                                                             p_summary_batch_id,
                                                             SYSDATE,
                                                             'JPARRM',
                                                             'DM_MEMBER_IND_POL_RECON_SET2');

            end loop;
             COMMIT;

            CLOSE CUR_POLICY_MAX_RNAGE_RECON;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_MAX_RNAGE'|| PROCESS_DATA13.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_MAX_RNAGE'|| PROCESS_DATA13.V_POLICY_NO;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;
/*----------------END- POLICY_MAX_RNAGE  ATTRIBUTE-------------------------------------------------------------------------------------------*/

/*----------------BEGIN - POLICY_SINSTNO   ATTRIBUTE-------------------------------------------------------------------------------------------*/

begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from,
to_number(substr(decode(pst.plnclass, 'F', 1, a.aplacd * 12), 1, 3)) POLICY_SINSTNO ,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_SINSTNO' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
left join stagedbusr2.policy_statcode@DMSTGUSR2DBLINK pst on a.apcucd= pst.apcucd
,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'
union all
-- staging
Select  distinct 'staging', a.SINSTNO POLICY_SINSTNO,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_SINSTNO' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
-- ig tables
select  distinct 'IG',a.SINSTNO POLICY_SINSTNO, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_SINSTNO' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchppf a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)select p_detail_batch_id, a.v_policy_no,
a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt,
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt,
V_SRC_DESC,    a.POLICY_SINSTNO src_val,
b.POLICY_SINSTNO stg_val,
c.POLICY_SINSTNO ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.POLICY_SINSTNO <> b.POLICY_SINSTNO
or b.POLICY_SINSTNO <> c.POLICY_SINSTNO
or a.POLICY_SINSTNO <> c.POLICY_SINSTNO)
order by a.v_policy_no;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_SINSTNO'|| sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_SINSTNO'|| sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;
/*----------------END- POLICY_SINSTNO  ATTRIBUTE-------------------------------------------------------------------------------------------*/

/*----------------BEGIN - POLICY_SALE_CHANNEL   ATTRIBUTE-------------------------------------------------------------------------------------------*/

begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from,
CASE WHEN A.APYOB9 = '0' then '10' 
               WHEN A.APYOB9 = '1' then '20' 
               WHEN A.APYOB9 = '2' then '99' 
               WHEN A.APYOB9 = '3' then '30' 
end as POLICY_SALE_CHANNEL ,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_SALE_CHANNEL' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
left join stagedbusr2.policy_statcode@DMSTGUSR2DBLINK pst on a.apcucd= pst.apcucd
,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'
union all
-- staging
Select  distinct 'staging', a.ZSALECHNL POLICY_SALE_CHANNEL,b.v_policy_no,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,
'POLICY_SALE_CHANNEL' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and a.client_category = '0'
and b.v_pol_type ='IND_MEMBER'
union all
-- ig tables
-- ig tables
select  distinct 'IG',a.ZSALECHNL POLICY_SALE_CHANNEL, b.v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt, 
'POLICY_SALE_CHANNEL' V_ATTRIB_NAME,
b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.gchppf a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)select p_detail_batch_id, a.v_policy_no,
a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt,
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt,
V_SRC_DESC,    a.POLICY_SALE_CHANNEL src_val,
b.POLICY_SALE_CHANNEL stg_val,
c.POLICY_SALE_CHANNEL ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (a.POLICY_SALE_CHANNEL <> b.POLICY_SALE_CHANNEL
or b.POLICY_SALE_CHANNEL <> c.POLICY_SALE_CHANNEL
or a.POLICY_SALE_CHANNEL <> c.POLICY_SALE_CHANNEL)
order by a.v_policy_no;

            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_SALE_CHANNEL'|| sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_SALE_CHANNEL'|| sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            DBMS_OUTPUT.PUT_lINE('Exception erors'|| SQLERRM);
            END;
/*----------------END- POLICY_SALE_CHANNEL  ATTRIBUTE-------------------------------------------------------------------------------------------*/


/*----------------BEGIN - GCHIPF_REFNUM   ATTRIBUTE-------------------------------------------------------------------------------------------*/
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (
                                                                    V_BATCH_ID
                                                                ,        V_POLICY_NO
                                                                ,        V_PROD_CDE
                                                                ,        V_POL_COMMDT
                                                                ,        V_ATTRIB_NAME
                                                                ,        V_POL_STATUS
                                                                ,        V_MODULE_NAME
                                                                ,        V_EFF_DATE
                                                                ,        V_EFF_DESC,    V_SRC_VAL
                                                                ,   V_STG_VAL
                                                                ,        V_IG_VAL
                                                                ,        V_SUMMARY_BATCH_ID
                                                                ,        D_CREATED_ON
                                                                ,        V_CREATED_BY
                                                                ,        V_JOB_NAME)
with data_1 as (
-- source
select  distinct 'source' data_from, substr(a.APCUCD,1,8) GCHIPF_REFNUM,        b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,    'GCHIPF_REFNUM' V_ATTRIB_NAME,    b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a,    stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, substr(a.REFNUM,1,8) GCHIPF_REFNUM,       b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,    'GCHIPF_REFNUM' V_ATTRIB_NAME,    b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.CHDRNUM GCHIPF_REFNUM,                 
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,    'GCHIPF_REFNUM' V_ATTRIB_NAME,    b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHIPF  a,              
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)select p_detail_batch_id, 
a.v_policy_no,
a.v_prd_cde v_prd_cde, 
a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,
a.GCHIPF_REFNUM src_val,
b.GCHIPF_REFNUM stg_val,
c.GCHIPF_REFNUM ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'
--a.d_pol_end_dt d_pol_end_dt, 
--a.n_alt_cnt n_alt_cnt, 
--a.n_ren_cnt n_ren_cnt, 
--a.v_pol_type  v_pol_type           
from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHIPF_REFNUM <>  b.GCHIPF_REFNUM
or b.GCHIPF_REFNUM <> c.GCHIPF_REFNUM
or a.GCHIPF_REFNUM <> c.GCHIPF_REFNUM )
order by a.v_policy_no; 
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing POLICY_GCHIPF_REFNUM'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing POLICY_GCHIPF_REFNUM'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;

/*----------------BEGIN - GCHIPF_REFNUM   ATTRIBUTE-------------------------------------------------------------------------------------------*/            
--/*----------------BEGIN - ATTRIB : GCHIPF_CCDATE -------------------------------------------------------------------------------------------*/
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)
with data_1 as (
-- source
select  distinct 'source' data_from, g.effdate GCHIPF_CCDATE,   b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_CCDATE' V_ATTRIB_NAME,         b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a
LEFT JOIN (
                    SELECT
                        a.apcucd   AS pjapp,
                        min.period_apcucd as period_apcucd,
                        a.apa2dt   AS effdate
                    FROM
                        stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK a 
                        left outer join stagedbusr2.maxpolnum@DMSTGUSR2DBLINK  min on a.apcucd = min.app_no
                    WHERE
                       a.apcucd = min.minperiod
          ) g ON substr(a.apcucd,1,10) = g.period_apcucd
,             stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.EFFDATE GCHIPF_CCDATE,             b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_CCDATE' V_ATTRIB_NAME,         b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.CCDATE GCHIPF_CCDATE,         
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_CCDATE' V_ATTRIB_NAME,         b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHIPF  a,              
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHIPF_CCDATE src_val,b.GCHIPF_CCDATE stg_val,
c.GCHIPF_CCDATE ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      trim(a.GCHIPF_CCDATE) <>  trim(b.GCHIPF_CCDATE)
or trim(b.GCHIPF_CCDATE) <> trim(c.GCHIPF_CCDATE)
or trim(a.GCHIPF_CCDATE) <> trim(c.GCHIPF_CCDATE) )
order by a.v_policy_no;     

COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHIPF_CCDATE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHIPF_CCDATE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;

--/*----------------END - ATTRIB : GCHIPF_CCDATE -------------------------------------------------------------------------------------------*/
--/*----------------BEGIN - ATTRIB : GCHIPF_INSSTDTE-------------------------------------------------------------------------------------------*/ 
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
                                                        with data_1 as (
-- source
select  distinct 'source' data_from,  to_char(g.effdate) GCHIPF_INSSTDTE,          b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_INSSTDTE' V_ATTRIB_NAME,      b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a
LEFT JOIN (
                    SELECT
                        a.apcucd   AS pjapp,
                        min.period_apcucd as period_apcucd,
                        a.apa2dt   AS effdate
                    FROM
                        stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK a 
                        left outer join stagedbusr2.maxpolnum@DMSTGUSR2DBLINK  min on a.apcucd = min.app_no
                    WHERE
                       a.apcucd = min.minperiod
          ) g ON substr(a.apcucd,1,10) = g.period_apcucd
,             stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, to_char(a.EFFDATE) GCHIPF_INSSTDTE,        b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_INSSTDTE' V_ATTRIB_NAME,      b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.INSSTDTE GCHIPF_INSSTDTE,                
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_INSSTDTE' V_ATTRIB_NAME,      b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHIPF  a,              
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHIPF_INSSTDTE src_val,b.GCHIPF_INSSTDTE stg_val,
c.GCHIPF_INSSTDTE ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      trim(a.GCHIPF_INSSTDTE) <>  trim(b.GCHIPF_INSSTDTE)
or trim(b.GCHIPF_INSSTDTE) <> trim(c.GCHIPF_INSSTDTE)
or trim(a.GCHIPF_INSSTDTE) <> trim(c.GCHIPF_INSSTDTE) )
order by a.v_policy_no;     

COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHIPF_INSSTDTE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHIPF_INSSTDTE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;

--/*----------------END - ATTRIB : GCHIPF_INSSTDTE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GCHIPF_ZCMPCODE-------------------------------------------------------------------------------------------*/           
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, rpad(a.APC1CD,6,0) GCHIPF_ZCMPCODE,       b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZCMPCODE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a,    stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.ZCMPCODE GCHIPF_ZCMPCODE,                b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZCMPCODE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '1' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZCMPCODE GCHIPF_ZCMPCODE,           
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZCMPCODE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHIPF  a,              
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHIPF_ZCMPCODE src_val,b.GCHIPF_ZCMPCODE stg_val,
c.GCHIPF_ZCMPCODE ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHIPF_ZCMPCODE <>  b.GCHIPF_ZCMPCODE
or b.GCHIPF_ZCMPCODE <> c.GCHIPF_ZCMPCODE
or a.GCHIPF_ZCMPCODE <> c.GCHIPF_ZCMPCODE )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHIPF_ZCMPCODE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHIPF_ZCMPCODE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GCHIPF_ZCMPCODE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GCHIPF_ZPSTDDT-------------------------------------------------------------------------------------------*/  
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)               
with data_1 as (
-- source
select  distinct 'source' data_from, to_char(g.effdate) GCHIPF_ZPSTDDT,              b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZPSTDDT' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a
LEFT JOIN (
                    SELECT
                        a.apcucd   AS pjapp,
                        min.period_apcucd as period_apcucd,
                        a.apa2dt   AS effdate
                    FROM
                        stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK a 
                        left outer join stagedbusr2.maxpolnum@DMSTGUSR2DBLINK  min on a.apcucd = min.app_no
                    WHERE
                       a.apcucd = min.minperiod
          ) g ON substr(a.apcucd, 1, 10) = g.period_apcucd

,             stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, to_char(a.EFFDATE) GCHIPF_ZPSTDDT,         b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZPSTDDT' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZPSTDDT GCHIPF_ZPSTDDT,     
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZPSTDDT' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHIPF  a,              
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHIPF_ZPSTDDT src_val,b.GCHIPF_ZPSTDDT stg_val,
c.GCHIPF_ZPSTDDT ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHIPF_ZPSTDDT <>  b.GCHIPF_ZPSTDDT
or b.GCHIPF_ZPSTDDT <> c.GCHIPF_ZPSTDDT
or a.GCHIPF_ZPSTDDT <> c.GCHIPF_ZPSTDDT )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHIPF_ZPSTDDT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHIPF_ZPSTDDT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GCHIPF_ZPSTDDT  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GCHIPF_ZRNWCNT-------------------------------------------------------------------------------------------*/ 
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
                                                        with data_1 as (
-- source
select  distinct 'source' data_from, 

                    CASE  WHEN pst.plnclass = 'P' and substr(a.apcucd,9,1)='0'  THEN to_char(substr(a.apcucd,10,1)) 
                          WHEN pst.plnclass = 'P' and substr(a.apcucd,9,1)<>'0'  THEN to_char(substr(a.apcucd,9,2))  
                          WHEN pst.plnclass = 'F' THEN  '0'
                      END AS GCHIPF_ZRNWCNT,                      
             b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZRNWCNT' V_ATTRIB_NAME,      b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a
LEFT JOIN stagedbusr2.policy_statcode@DMSTGUSR2DBLINK  pst ON substr(a.apcucd, 1, 8) = pst.chdrnum,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, to_char(a.ZRNWCNT) GCHIPF_ZRNWCNT,      b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZRNWCNT' V_ATTRIB_NAME,      b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, to_char(a.ZRNWCNT) GCHIPF_ZRNWCNT,              
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZRNWCNT' V_ATTRIB_NAME,      b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHIPF  a,              
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHIPF_ZRNWCNT src_val,b.GCHIPF_ZRNWCNT stg_val,
c.GCHIPF_ZRNWCNT ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHIPF_ZRNWCNT <>  b.GCHIPF_ZRNWCNT
or b.GCHIPF_ZRNWCNT <> c.GCHIPF_ZRNWCNT
or a.GCHIPF_ZRNWCNT <> c.GCHIPF_ZRNWCNT )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHIPF_ZRNWCNT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHIPF_ZRNWCNT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GCHIPF_ZRNWCNT  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHDPF_MBRNO-------------------------------------------------------------------------------------------*/  
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
                                                        with data_1 as (
-- source
select  distinct 'source' data_from, '000'||substr(a.iscicd,- 2) GMHDPF_MBRNO,                 b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_MBRNO' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRIS00@DMSTGUSR2DBLINK  a
left join stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  C ON c.apcucd =a.iscucd
,             stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where c.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, '000'||a.MBRNO GMHDPF_MBRNO,                 b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_MBRNO' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.MBRNO GMHDPF_MBRNO,        
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_MBRNO' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHDPF  a,           
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHDPF_MBRNO src_val,b.GMHDPF_MBRNO stg_val,
c.GMHDPF_MBRNO ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.GMHDPF_MBRNO=b.GMHDPF_MBRNO
and a.GMHDPF_MBRNO= c.GMHDPF_MBRNO
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHDPF_MBRNO <>  b.GMHDPF_MBRNO
or b.GMHDPF_MBRNO <> c.GMHDPF_MBRNO
or a.GMHDPF_MBRNO <> c.GMHDPF_MBRNO )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHDPF_MBRNO'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHDPF_MBRNO'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHDPF_MBRNO  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHDPF_DTEATT-------------------------------------------------------------------------------------------*/  
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
                                                        with data_1 as (
-- source
select  distinct 'source' data_from, a.OCCDATE GMHDPF_DTEATT,           b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_DTEATT' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a,    stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.OCCDATE GMHDPF_DTEATT,          b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_DTEATT' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.DTEATT GMHDPF_DTEATT,        
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_DTEATT' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHDPF  a,           
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHDPF_DTEATT src_val,b.GMHDPF_DTEATT stg_val,
c.GMHDPF_DTEATT ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHDPF_DTEATT <>  b.GMHDPF_DTEATT
or b.GMHDPF_DTEATT <> c.GMHDPF_DTEATT
or a.GMHDPF_DTEATT <> c.GMHDPF_DTEATT )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHDPF_DTEATT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHDPF_DTEATT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHDPF_DTEATT  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHDPF_RELN-------------------------------------------------------------------------------------------*/       
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, a.ISA4ST GMHDPF_RELN,      b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_RELN' V_ATTRIB_NAME,            b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
'000'||SUBSTR(a.ISCICD,-2) MBRNO
from stagedbusr2.ZMRIS00@DMSTGUSR2DBLINK  a,      stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.iscucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
Union all             --STAGING
select  distinct 'staging' data_from, a.CLTRELN GMHDPF_RELN,               b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_RELN' V_ATTRIB_NAME,            b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
'000'||a.MBRNO MBRNO
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '1' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.RELN GMHDPF_RELN,                
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_RELN' V_ATTRIB_NAME,            b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
a.MBRNO MBRNO
from Jd1dta.GMHDPF  a,           
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHDPF_RELN src_val,b.GMHDPF_RELN stg_val,
c.GMHDPF_RELN ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
AND a.MBRNO=b.MBRNO
AND a.mbrno=c.mbrno
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (                   trim(a.GMHDPF_RELN) <>  trim(b.GMHDPF_RELN)
or trim(b.GMHDPF_RELN) <> trim(c.GMHDPF_RELN)
or trim(a.GMHDPF_RELN) <> trim(c.GMHDPF_RELN) )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHDPF_RELN'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHDPF_RELN'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHDPF_RELN  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHDPF_ZANNCLDT-------------------------------------------------------------------------------------------*/           
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, to_char(a.APCVCD) GMHDPF_ZANNCLDT,      b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_ZANNCLDT' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a,    stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, to_char(a.ZANNCLDT) GMHDPF_ZANNCLDT,              b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_ZANNCLDT' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZANNCLDT GMHDPF_ZANNCLDT,          
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_ZANNCLDT' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHDPF  a,           
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHDPF_ZANNCLDT src_val,b.GMHDPF_ZANNCLDT stg_val,
c.GMHDPF_ZANNCLDT ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHDPF_ZANNCLDT <>  b.GMHDPF_ZANNCLDT
or b.GMHDPF_ZANNCLDT <> c.GMHDPF_ZANNCLDT
or a.GMHDPF_ZANNCLDT <> c.GMHDPF_ZANNCLDT )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHDPF_ZANNCLDT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHDPF_ZANNCLDT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHDPF_ZANNCLDT  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHDPF_CLTRELN-------------------------------------------------------------------------------------------*/ 
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, a.ISA4ST GMHDPF_CLTRELN,             b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_CLTRELN' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
'000'||SUBSTR(a.ISCICD,-2) MBRNO
from stagedbusr2.ZMRIS00@DMSTGUSR2DBLINK  a,      stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.iscucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.CLTRELN GMHDPF_CLTRELN,        b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_CLTRELN' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
'000'||a.MBRNO MBRNO
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.CLTRELN GMHDPF_CLTRELN,                 
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHDPF_CLTRELN' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
A.MBRNO MBRNO
from Jd1dta.GMHDPF  a,           
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHDPF_CLTRELN src_val,b.GMHDPF_CLTRELN stg_val,
c.GMHDPF_CLTRELN ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
AND a.MBRNO=b.MBRNO
AND a.mbrno=c.mbrno
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHDPF_CLTRELN <>  b.GMHDPF_CLTRELN
or b.GMHDPF_CLTRELN <> c.GMHDPF_CLTRELN
or a.GMHDPF_CLTRELN <> c.GMHDPF_CLTRELN )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHDPF_CLTRELN'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHDPF_CLTRELN'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHDPF_CLTRELN  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHIPF_MBRNO-------------------------------------------------------------------------------------------*/   
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, '000'||substr(a.iscicd,- 2) GMHIPF_MBRNO,     b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_MBRNO' V_ATTRIB_NAME,         b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRIS00@DMSTGUSR2DBLINK  a,      stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.iscucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.MBRNO GMHIPF_MBRNO,               b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_MBRNO' V_ATTRIB_NAME,         b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '1' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.MBRNO GMHIPF_MBRNO,          
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_MBRNO' V_ATTRIB_NAME,         b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHIPF  a,             
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHIPF_MBRNO src_val,b.GMHIPF_MBRNO stg_val,
c.GMHIPF_MBRNO ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.GMHIPF_MBRNO=b.GMHIPF_MBRNO
and a.GMHIPF_MBRNO=c.GMHIPF_MBRNO
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHIPF_MBRNO <>  b.GMHIPF_MBRNO
or b.GMHIPF_MBRNO <> c.GMHIPF_MBRNO
or a.GMHIPF_MBRNO <> c.GMHIPF_MBRNO )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHIPF_MBRNO'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHIPF_MBRNO'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHIPF_MBRNO  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHIPF_EFFDATE-------------------------------------------------------------------------------------------*/  
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, to_char(g.effdate) GMHIPF_EFFDATE,              b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_EFFDATE' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a
LEFT JOIN (
                    SELECT
                        a.apcucd   AS pjapp,
                        min.period_apcucd as period_apcucd,
                        a.apa2dt   AS effdate
                    FROM
                        stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK a 
                        left outer join stagedbusr2.maxpolnum@DMSTGUSR2DBLINK  min on a.apcucd = min.app_no
                    WHERE
                       a.apcucd = min.minperiod
          ) g ON substr(a.apcucd,1,10) = g.period_apcucd
,             stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, to_char(a.EFFDATE) GMHIPF_EFFDATE,         b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_EFFDATE' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '1' 
Union all             --IG TABLES
select  distinct 'IG' data_from, to_char(a.EFFDATE) GMHIPF_EFFDATE,   
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_EFFDATE' V_ATTRIB_NAME,       b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHIPF  a,             
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHIPF_EFFDATE src_val,b.GMHIPF_EFFDATE stg_val,
c.GMHIPF_EFFDATE ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      trim(a.GMHIPF_EFFDATE) <>  trim(b.GMHIPF_EFFDATE)
or trim(b.GMHIPF_EFFDATE) <> trim(c.GMHIPF_EFFDATE)
or trim(a.GMHIPF_EFFDATE) <> trim(c.GMHIPF_EFFDATE) )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHIPF_EFFDATE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHIPF_EFFDATE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHIPF_EFFDATE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHIPF_ZTRXSTAT-------------------------------------------------------------------------------------------*/ 
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, 
CASE
                            WHEN pst.plnclass = 'F' THEN
                                CASE
                                    WHEN a.apblst in ('1','3') THEN
                                        'AP'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69 THEN
                                        decode(substr(a.apdlcd, 1, 1), '*', 'RJ', 'AP')
                                    WHEN a.apblst = '2'
                                         AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                        'AP'
                                    WHEN a.apblst = '5' THEN
                                        'RJ'
                                END
                            WHEN pst.plnclass = 'P' THEN
                                CASE
                                    WHEN a.apblst in ('1','3') THEN
                                        'AP'
                                    WHEN a.apblst = '2'
                                         AND a.apcycd BETWEEN 50 AND 69 THEN
                                        decode(substr(a.apdlcd, 1, 1), '*', 'RJ', 'AP')
                                    WHEN a.apblst = '2'
                                         AND a.apcycd NOT BETWEEN 50 AND 69 THEN
                                        'AP'
                                    WHEN a.apblst = '5' THEN
                                        'RJ'
                                END
                        END GMHIPF_ZTRXSTAT,

             b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZTRXSTAT' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK a 
left join stagedbusr2.policy_statcode@DMSTGUSR2DBLINK pst on a.apcucd= pst.apcucd ,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.ZTRXSTAT GMHIPF_ZTRXSTAT,      b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZTRXSTAT' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZTRXSTAT GMHIPF_ZTRXSTAT,               
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZTRXSTAT' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHIPF  a,             
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHIPF_ZTRXSTAT src_val,b.GMHIPF_ZTRXSTAT stg_val,
c.GMHIPF_ZTRXSTAT ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHIPF_ZTRXSTAT <>  b.GMHIPF_ZTRXSTAT
or b.GMHIPF_ZTRXSTAT <> c.GMHIPF_ZTRXSTAT
or a.GMHIPF_ZTRXSTAT <> c.GMHIPF_ZTRXSTAT )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHIPF_ZTRXSTAT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHIPF_ZTRXSTAT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);
            END;           
--/*----------------END - ATTRIB : GMHIPF_ZTRXSTAT  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHIPF_ZSTATRESN-------------------------------------------------------------------------------------------*/           
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from,
(
                    SELECT DISTINCT
                        ig_r_code
                    FROM
                        stagedbusr2.decline_reason_code@DMSTGUSR2DBLINK 
                    WHERE
                        a.apdlcd = dm_r_code
                        AND ROWNUM = 1
)  GMHIPF_ZSTATRESN,

b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZSTATRESN' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.ZSTATRESN GMHIPF_ZSTATRESN,               b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZSTATRESN' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZSTATRESN GMHIPF_ZSTATRESN,         
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZSTATRESN' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHIPF  a,             
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHIPF_ZSTATRESN src_val,b.GMHIPF_ZSTATRESN stg_val,
c.GMHIPF_ZSTATRESN ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHIPF_ZSTATRESN <>  b.GMHIPF_ZSTATRESN
or b.GMHIPF_ZSTATRESN <> c.GMHIPF_ZSTATRESN
or a.GMHIPF_ZSTATRESN <> c.GMHIPF_ZSTATRESN )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHIPF_ZSTATRESN'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHIPF_ZSTATRESN'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHIPF_ZSTATRESN  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHIPF_ZPLANCDE-------------------------------------------------------------------------------------------*/             
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, sp.newzsalplan GMHIPF_ZPLANCDE,               b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZPLANCDE' V_ATTRIB_NAME,    b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
sp.mbrno mbrno
from stagedbusr2.mem_ind_polhist_ssplan_intrmdt@DMSTGUSR2DBLINK  sp, 
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where substr(sp.apcucd,1,10) =  b.v_policy_no||b.n_ren_cnt
and b.v_pol_type ='IND_MEMBER' 
Union all             --STAGING
select  distinct 'staging' data_from, a.ZPLANCDE GMHIPF_ZPLANCDE,   b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZPLANCDE' V_ATTRIB_NAME,    b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
'000'||a.mbrno mbrno
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '1' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZPLANCDE GMHIPF_ZPLANCDE,            
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_ZPLANCDE' V_ATTRIB_NAME,    b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type,
a.mbrno mbrno
from Jd1dta.GMHIPF  a,             
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHIPF_ZPLANCDE src_val,b.GMHIPF_ZPLANCDE stg_val,
c.GMHIPF_ZPLANCDE ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.mbrno = b.mbrno
and a.mbrno = c.mbrno
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHIPF_ZPLANCDE <>  b.GMHIPF_ZPLANCDE
or b.GMHIPF_ZPLANCDE <> c.GMHIPF_ZPLANCDE
or a.GMHIPF_ZPLANCDE <> c.GMHIPF_ZPLANCDE )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHIPF_ZPLANCDE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHIPF_ZPLANCDE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHIPF_ZPLANCDE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHIPF_HPROPDTE-------------------------------------------------------------------------------------------*/           
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, a.APCVCDNEW GMHIPF_HPROPDTE,              b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_HPROPDTE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a,    stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.HPROPDTE GMHIPF_HPROPDTE,                 b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_HPROPDTE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.HPROPDTE GMHIPF_HPROPDTE,           
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_HPROPDTE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHIPF  a,             
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHIPF_HPROPDTE src_val,b.GMHIPF_HPROPDTE stg_val,
c.GMHIPF_HPROPDTE ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHIPF_HPROPDTE <>  b.GMHIPF_HPROPDTE
or b.GMHIPF_HPROPDTE <> c.GMHIPF_HPROPDTE
or a.GMHIPF_HPROPDTE <> c.GMHIPF_HPROPDTE )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHIPF_HPROPDTE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHIPF_HPROPDTE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHIPF_HPROPDTE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GMHIPF_DOCRCDTE-------------------------------------------------------------------------------------------*/           
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, a.APCVCDNEW GMHIPF_DOCRCDTE,              b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_DOCRCDTE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a,    stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' Union all          --STAGING
select  distinct 'staging' data_from, a.DOCRCVDT GMHIPF_DOCRCDTE,                b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_DOCRCDTE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.DOCRCDTE GMHIPF_DOCRCDTE,           
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GMHIPF_DOCRCDTE' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GMHIPF  a,             
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GMHIPF_DOCRCDTE src_val,b.GMHIPF_DOCRCDTE stg_val,
c.GMHIPF_DOCRCDTE ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GMHIPF_DOCRCDTE <>  b.GMHIPF_DOCRCDTE
or b.GMHIPF_DOCRCDTE <> c.GMHIPF_DOCRCDTE
or a.GMHIPF_DOCRCDTE <> c.GMHIPF_DOCRCDTE )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GMHIPF_DOCRCDTE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GMHIPF_DOCRCDTE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GMHIPF_DOCRCDTE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : ZCELINKPF_ZENDCDE-------------------------------------------------------------------------------------------*/        
--Removed this Attrib as this is moved to Transformation queries
--/*----------------END - ATTRIB : ZCELINKPF_ZENDCDE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : ZCLEPF_ZENDCDE-------------------------------------------------------------------------------------------*/ 
--Removed this Attrib as this is moved to Transformation queries
--/*----------------END - ATTRIB : ZCLEPF_ZENDCDE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : ZCLEPF_ZENSPCD01-------------------------------------------------------------------------------------------*/           
--Removed this Attrib as this is moved to Transformation queries
--/*----------------END - ATTRIB : ZCLEPF_ZENSPCD01  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : ZCLEPF_ZENSPCD02-------------------------------------------------------------------------------------------*/           
--Removed this Attrib as this is moved to Transformation queries
--/*----------------END - ATTRIB : ZCLEPF_ZENSPCD02  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : ZCLEPF_ZCIFCODE-------------------------------------------------------------------------------------------*/ 
--Removed this Attrib as this is moved to Transformation queries
--/*----------------END - ATTRIB : ZCLEPF_ZCIFCODE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : CLRRPF_FORENUM-------------------------------------------------------------------------------------------*/             
--Removed this Attrib as this is moved to Transformation queries
--/*----------------END - ATTRIB : CLRRPF_FORENUM  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GCHPPF_ZNBMNAGE          
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from,
CASE 
                          WHEN pst.plnclass = 'F' THEN
                            0
                          WHEN  pst.plnclass = 'P' THEN
                            CASE
                              WHEN a.apc6cd in ('BSCYCLE', 'BSCYCLE_PC') THEN
                                0
                              WHEN a.apc6cd = 'AMEX_CR' THEN
                                22
                              WHEN TRIM(i.icdmcd) = 'SPA' THEN
                                65
                              WHEN mna.zendcde IS NOT NULL THEN
                                22
                              ELSE
                                20
                            END
                        END GCHPPF_ZNBMNAGE,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZNBMNAGE' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
left join stagedbusr2.policy_statcode@DMSTGUSR2DBLINK pst on a.apcucd= pst.apcucd
LEFT OUTER JOIN stagedbusr2.minage_table@DMSTGUSR2DBLINK mna ON mna.zendcde = TRIM(a.apc6cd)
                                AND mna.prod_code = TRIM(a.apc7cd)
LEFT JOIN (SELECT DISTINCT
                                    iccucd,
                                    icdmcd
                          FROM
                            stagedbusr2.zmric00@DMSTGUSR2DBLINK
                          WHERE
                            substr(iccicd,-2) = '01'
                            AND icdmcd = 'SPA'
                                --AND ROWNUM = 1
                        ) i ON a.apcucd = i.iccucd                                
                                ,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 

Union all             --STAGING
select  distinct 'staging' data_from, a.ZNBMNAGE GCHPPF_ZNBMNAGE,              b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZNBMNAGE' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZNBMNAGE GCHPPF_ZNBMNAGE,         
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZNBMNAGE' V_ATTRIB_NAME,                b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHPPF  a,            
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHPPF_ZNBMNAGE src_val,b.GCHPPF_ZNBMNAGE stg_val,
c.GCHPPF_ZNBMNAGE ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHPPF_ZNBMNAGE <>  b.GCHPPF_ZNBMNAGE
or b.GCHPPF_ZNBMNAGE <> c.GCHPPF_ZNBMNAGE
or a.GCHPPF_ZNBMNAGE <> c.GCHPPF_ZNBMNAGE )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHPPF_ZNBMNAGE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHPPF_ZNBMNAGE'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GCHPPF_ZNBMNAGE  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GCHPPF_ZPGPTODT -------------------------------------------------------------------------------------------*/          
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from,
nvl(pst.zpgptodt, 99999999)  GCHPPF_ZPGPTODT,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZPGPTODT' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
left join stagedbusr2.policy_statcode@DMSTGUSR2DBLINK pst on a.apcucd= pst.apcucd ,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 

Union all             --STAGING
select  distinct 'staging' data_from, a.ZPGPTODT GCHPPF_ZPGPTODT,   b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZPGPTODT' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZPGPTODT GCHPPF_ZPGPTODT,            
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZPGPTODT' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHPPF  a,            
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHPPF_ZPGPTODT src_val,b.GCHPPF_ZPGPTODT stg_val,
c.GCHPPF_ZPGPTODT ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHPPF_ZPGPTODT <>  b.GCHPPF_ZPGPTODT
or b.GCHPPF_ZPGPTODT <> c.GCHPPF_ZPGPTODT
or a.GCHPPF_ZPGPTODT <> c.GCHPPF_ZPGPTODT )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHPPF_ZPGPTODT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHPPF_ZPGPTODT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GCHPPF_ZPGPTODT  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GCHPPF_ZPGPFRDT            
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from,
nvl(pst.zpgpfrdt, 99999999)   GCHPPF_ZPGPFRDT,
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZPGPFRDT' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.zmrap00@DMSTGUSR2DBLINK  a
left join stagedbusr2.policy_statcode@DMSTGUSR2DBLINK pst on a.apcucd= pst.apcucd ,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 

Union all             --STAGING
select  distinct 'staging' data_from, a.ZPGPFRDT GCHPPF_ZPGPFRDT,   b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZPGPFRDT' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZPGPFRDT GCHPPF_ZPGPFRDT,            
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZPGPFRDT' V_ATTRIB_NAME,  b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHPPF  a,            
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHPPF_ZPGPFRDT src_val,b.GCHPPF_ZPGPFRDT stg_val,
c.GCHPPF_ZPGPFRDT ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHPPF_ZPGPFRDT <>  b.GCHPPF_ZPGPFRDT
or b.GCHPPF_ZPGPFRDT <> c.GCHPPF_ZPGPFRDT
or a.GCHPPF_ZPGPFRDT <> c.GCHPPF_ZPGPFRDT )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHPPF_ZPGPFRDT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHPPF_ZPGPFRDT'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GCHPPF_ZPGPFRDT  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GCHPPF_ZCONVINDPOL-------------------------------------------------------------------------------------------*/     
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from,

decode(apdlcd, 'C6', mp.zconvpol, NULL) GCHPPF_ZCONVINDPOL,

b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZCONVINDPOL' V_ATTRIB_NAME,          b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a
LEFT JOIN stagedbusr2.mempol_view@DMSTGUSR2DBLINK         mp ON a.apcucd = mp.mp,
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 

Union all             --STAGING
select  distinct 'staging' data_from, a.ZCONVINDPOL   GCHPPF_ZCONVINDPOL,             b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZCONVINDPOL' V_ATTRIB_NAME,          b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, a.ZCONVINDPOL GCHPPF_ZCONVINDPOL,            
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHPPF_ZCONVINDPOL' V_ATTRIB_NAME,          b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHPPF  a,            
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no, a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHPPF_ZCONVINDPOL src_val,b.GCHPPF_ZCONVINDPOL stg_val,
c.GCHPPF_ZCONVINDPOL ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHPPF_ZCONVINDPOL <>  b.GCHPPF_ZCONVINDPOL
or b.GCHPPF_ZCONVINDPOL <> c.GCHPPF_ZCONVINDPOL
or a.GCHPPF_ZCONVINDPOL <> c.GCHPPF_ZCONVINDPOL )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHPPF_ZCONVINDPOL'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHPPF_ZCONVINDPOL'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GCHPPF_ZCONVINDPOL  -------------------------------------------------------------------------------------------*/ 
--/*----------------BEGIN - ATTRIB : GCHIPF_ZPOLPERD-------------------------------------------------------------------------------------------*/             
begin            
                Err_desc:=NULL;
                insert into Jd1dta.DM_MEM_IND_RECON_DET (V_BATCH_ID,V_POLICY_NO,V_PROD_CDE,V_POL_COMMDT,V_ATTRIB_NAME,V_POL_STATUS,               V_MODULE_NAME,V_EFF_DATE, V_EFF_DESC, V_SRC_VAL, V_STG_VAL,V_IG_VAL, V_SUMMARY_BATCH_ID,D_CREATED_ON, V_CREATED_BY, V_JOB_NAME)                         
with data_1 as (
-- source
select  distinct 'source' data_from, 
to_char(to_date(g.effdate, 'yyyymmdd')) GCHIPF_ZPOLPERD,       

b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZPOLPERD' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr2.ZMRAP00@DMSTGUSR2DBLINK  a
LEFT JOIN (
                    SELECT
                        a.apcucd   AS pjapp,
                        min.period_apcucd as period_apcucd,
                        a.apa2dt   AS effdate
                    FROM
                        stagedbusr2.zmrap00@DMSTGUSR2DBLINK a
                        left outer join stagedbusr2.maxpolnum@DMSTGUSR2DBLINK min on a.apcucd = min.apcucd
                    WHERE
                       a.apcucd = min.minperiod
          ) g ON substr(a.apcucd, 1, 10) = g.period_apcucd


,             stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.apcucd = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER'  

Union all             --STAGING
select  distinct 'staging' data_from, to_char(a.ZPOLPERD) GCHIPF_ZPOLPERD,   b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZPOLPERD' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from stagedbusr.titdmgmbrindp1@DMSTGUSR2DBLINK  a,           stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
where a.refnum = b.v_policy_no||b.n_ren_cnt||b.n_alt_cnt
and b.v_pol_type ='IND_MEMBER' 
and a.client_category = '0' 
Union all             --IG TABLES
select  distinct 'IG' data_from, to_char(a.ZPOLPERD) GCHIPF_ZPOLPERD,            
b.v_policy_no v_policy_no ,
b.v_prd_cde v_prd_cde, 
b.d_pol_start_dt d_pol_start_dt, 
b.d_pol_end_dt d_pol_end_dt,  'GCHIPF_ZPOLPERD' V_ATTRIB_NAME,     b.v_pol_status v_pol_status, 
b.n_alt_cnt n_alt_cnt, 
b.n_ren_cnt n_ren_cnt, 
b.v_pol_type  v_pol_type
from Jd1dta.GCHIPF  a,              
stagedbusr2.dm_policy_recon@DMSTGUSR2DBLINK  b
Where a.chdrnum = b.v_policy_no
and  b.v_pol_type ='IND_MEMBER'
)             select p_detail_batch_id,a.v_policy_no,
a.v_prd_cde v_prd_cde, a.d_pol_start_dt d_pol_start_dt, 
a.V_ATTRIB_NAME V_ATTRIB_NAME,
a.v_pol_status v_pol_status, 
'Member and Individual Policy' V_MODULE_NAME,
a.d_pol_start_dt d_pol_start_dt, 
V_SRC_DESC,    a.GCHIPF_ZPOLPERD src_val,b.GCHIPF_ZPOLPERD stg_val,
c.GCHIPF_ZPOLPERD ig_val,
p_summary_batch_id,
sysdate,
'JPARRM',
'DM_MEMBER_IND_POL_RECON_SET2'                from data_1 a,
     data_1 b,
     data_1 c
where a.v_policy_no = b.v_policy_no
and a.v_policy_no = c.v_policy_no
and a.data_from = 'source'
and b.data_from = 'staging'
and c.data_from = 'IG'
and (      a.GCHIPF_ZPOLPERD <>  b.GCHIPF_ZPOLPERD
or b.GCHIPF_ZPOLPERD <> c.GCHIPF_ZPOLPERD
or a.GCHIPF_ZPOLPERD <> c.GCHIPF_ZPOLPERD )
order by a.v_policy_no;     
COMMIT;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            Err_desc:='Error while executing GCHIPF_ZPOLPERD'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);             
            WHEN OTHERS THEN
            Err_desc:='Error while executing GCHIPF_ZPOLPERD'||sqlerrm;
            Jd1dta.insert_error_log(null,  Err_desc ,null);

            END;           
--/*----------------END - ATTRIB : GCHIPF_ZPOLPERD  -------------------------------------------------------------------------------------------*/ 

dbms_output.put_line('Procedure execution time = ' ||
                       (dbms_utility.get_time - v_timestart) / 100); 
end DM_MEMBER_IND_POL_RECON_SET2 ;