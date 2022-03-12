create or replace package dm_data_trans_renew_det
as

procedure dm_zmrage_renew_det(p_array_size IN PLS_INTEGER DEFAULT 1000);
procedure dm_zmrhr_renew_det(p_array_size IN PLS_INTEGER DEFAULT 1000);
procedure dm_rnwasis_renew_det(p_array_size IN PLS_INTEGER DEFAULT 1000);
procedure dm_asrf_renew_det(p_array_size IN PLS_INTEGER DEFAULT 1000);


end dm_data_trans_renew_det;

/


create or replace PACKAGE BODY  dm_data_trans_renew_det IS

PROCEDURE dm_zmrage_renew_det(p_array_size IN PLS_INTEGER DEFAULT 1000) IS


cursor c_fet_policy Is 
    SELECT DISTINCT
        substr(a.agecucd, 1, 8) chdrnum,
        substr(a.agecicd, - 2, length(a.agecicd)) ins_no,
        lpad(substr(a.agecicd, - 2), 5, '000') mbrno,
        agebedt      ren_frm_dt,
        to_number(to_char(add_months(to_date(to_date(agebedt, 'yyyymmdd')), 12) - 1, 'yyyymmdd')) ren_to_dt,
        TRIM(a.agecjcdn) new_sp_cde,
        TRIM(a.agecjcdo) old_sp_cde,
        a.agedlcd    cncl_cde,
        a.agetfce    form_no,
        a.agec7cdo   prd_cde,
        a.agec8cdo   prd_sub_cde,
        a.agec6cdo   end_cde,
        a.ageyob2    nspflg,
        a.ageyob1    ospflg,
        b.statcode   policy_stat_code,
        b.Zpoltdate  policy_cncl_date,
        COUNT(a.agecicd) OVER(
            PARTITION BY substr(a.agecucd, 1, 8)
        ) cnt_of_ins,
       COUNT(a.agecicd) OVER(
            PARTITION BY a.agecicd
        ) ins_dup_check
    FROM
        stagedbusr2.zmrage00 a
        left outer join policy_statcode b on substr(a.AGECUCD,1,8) =  b.chdrnum
    ORDER BY
        substr(a.agecucd, 1, 8),
        substr(a.agecicd, - 2, length(a.agecicd))
;





    CURSOR c_get_insur_role (
        cp_chdrnum   persnl_clnt_flg.apcucd%TYPE,
        cp_ins_no    CHAR
    ) IS
    SELECT DISTINCT
        substr(pcf.insur_role, - 1) insur_role,
        cm.stageclntno stg_clntnum
    FROM
        persnl_clnt_flg   pcf,
        titdmgclntmap     cm
    WHERE
        substr(pcf.apcucd, 1, 8) = cp_chdrnum
        AND cm.refnum = pcf.stg_clntnum
        AND pcf.insur_typ = 'I'
        AND substr(pcf.iscicd, - 2, length(pcf.iscicd)) = cp_ins_no
        AND pcf.isa4st IS NOT NULL;


/*
cursor c_get_insur_role(cp_chdrnum persnl_clnt_flg.apcucd%type,
                        cp_ins_no char)  
is
select pcf.insur_role,
       clnt.stageclntno
from persnl_clnt_flg pcf ,
titdmgclntmap clnt
where substr(pcf.apcucd,1,8) = cp_chdrnum
and substr(pcf.iscicd,-2,length(pcf.iscicd) = cp_ins_no
and clnt.refnum = pcf.Stg_Clntnum
and pcf.isa4st is not null;
*/

    CURSOR c_get_relationship (
        cp_chdrnum   persnl_clnt_flg.apcucd%TYPE,
        cp_ins_no    CHAR
    ) IS
    SELECT
        ins.isa4st
    FROM
        maxpolnum   mp,
        zmris00     ins
    WHERE
        mp.maxapcucd = ins.iscucd
        AND substr(mp.apcucd, 1, 8) = cp_chdrnum
        AND substr(ins.iscicd, - 2) = cp_ins_no;

    CURSOR c_chk_cc_rider (
        cp_prd_cde      zmrage00.agec7cdo%TYPE,
        cp_prd_subcde   zmrage00.agec8cdo%TYPE,
        cp_end_cde      zmrage00.agec6cdo%TYPE,
        cp_sp_cde       zmrage00.agecjcdn%TYPE
    ) IS
    SELECT
        COUNT(1)
    FROM
        zmrrs00 rr
    WHERE
        rr.rsbtcd = cp_prd_cde
        AND rr.rsbucd = cp_prd_subcde
        AND rr.rsfocd = cp_end_cde
        AND rr.rsbvcd = cp_sp_cde
        AND ( rr.rsb0cd IN (
            351,
            352,
            353,
            354,
            355,
            356
        )
              OR rr.rsb1cd IN (
            351,
            352,
            353,
            354,
            355,
            356
        )
              OR rr.rsb2cd IN (
            351,
            352,
            353,
            354,
            355,
            356
        )
              OR rr.rsb3cd IN (
            351,
            352,
            353,
            354,
            355,
            356
        )
              OR rr.rsb4cd IN (
            351,
            352,
            353,
            354,
            355,
            356
        )
              OR rr.rsb5cd IN (
            351,
            352,
            353,
            354,
            355,
            356
        ) );

    CURSOR c_get_ig_sp (
        cp_oldsp     stagedbusr2.spplanconvertion.oldzsalplan%TYPE,
        cp_rel       stagedbusr2.spplanconvertion.relationship%TYPE,
        cp_ccrider   stagedbusr2.spplanconvertion.ccspecialcontract%TYPE,
        cp_hcr       stagedbusr2.spplanconvertion.hcrflag%TYPE
    ) IS
    SELECT
        newzsalplan
    FROM
        stagedbusr2.spplanconvertion
    WHERE
        trim(oldzsalplan) = trim(cp_oldsp)
        AND trim(relationship) = trim(cp_rel)
        AND trim(ccspecialcontract) = trim(cp_ccrider)
        AND trim(hcrflag) = trim(cp_hcr);

    CURSOR c_get_ndr_prdtyp2 (
        cp_ins_typ   stagedbusr2.ig_coverage_ndrrider.insurance_type%TYPE,
        cp_prd_typ   stagedbusr2.ig_coverage_ndrrider.prod_code%TYPE
    ) IS
    SELECT
        ndr_rider_code
    FROM
        stagedbusr2.ig_coverage_ndrrider
    WHERE
        insurance_type = cp_ins_typ
        AND prod_code = cp_prd_typ;

	cursor c_get_cvr is select * from source_coverage_results a where not exists (Select 1 from titdmgrnwdt1 b
	where a.chdrnum = b.chdrnum and a.mbrno = b.mbrno and b.ZTERMFLG = 'Y');
	
	/*
	cursor c_get_curr_sp(cp_pol,cp_ins)
	is
	select newzsalplan
	from mem_ind_polhist_ssplan_intrmdt
	where chdrnum = cp_pol
	and mbrno = '000'||cp_ins;
	*/

    TYPE t_fet_policy IS TABLE OF c_fet_policy%rowtype;
    r_fet_policy       t_fet_policy;


    TYPE t_get_cvr IS TABLE OF c_get_cvr%rowtype;
    r_get_cvr       t_get_cvr;    

    lv_pol_exists     NUMBER := 0;
    lv_sp_change      CHAR(1);
    lv_step           CHAR(2);
    lv_main_det_cde   CHAR(3);
    lv_sec_det_cde    CHAR(3);
    lv_alt_code       CHAR(3);
    v_errormsg        VARCHAR2(2000) := NULL;
    lv_zterm          stagedbusr2.titdmgrnwdt1.ztermflg%TYPE;
    lv_ins_role       stagedbusr2.titdmgrnwdt1.zinsrole%TYPE;
    lv_stg_clntnum    VARCHAR2(15 CHAR); ---stagedbusr2.titdmgrnwdt1.stageclntno%TYPE;
    lv_pol_no         stagedbusr2.zmrage00.agecucd%TYPE;
    lv_dm_sp_cde      stagedbusr2.zmrage00.agecjcdn%TYPE;
    lv_cc_rider       CHAR(2);
    lv_cc_rider_cnt   NUMBER;
    lv_ins_rel        VARCHAR2(5);
    lv_hcr            CHAR(2);
    lv_ig_sp_code     stagedbusr2.spplanconvertion.newzsalplan%TYPE;
    lv_busdate        stagedbusr.busdpf.busdate%TYPE;
    lv_prod_type02    stagedbusr2.ig_coverage_ndrrider.ndr_rider_code%TYPE;
    lv_mem_cnt        NUMBER;
    lv_cnt            NUMBER;
    lv_pol_chk_cnt    NUMBER;
    v_output_count    NUMBER;
    v_input_count     NUMBER;
    l_app_old         VARCHAR2(60) := NULL;
    temp_no           NUMBER;
    lv_err_chk        BOOLEAN := false;
    lv_typ            varchar2(25);
    lv_pol_cnt        NUMBER;
    c_limit PLS_INTEGER := p_array_size;
    rec_chk           NUMBER;
	lv_cur_sp_code	  stagedbusr2.spplanconvertion.newzsalplan%TYPE;

--ex_exp exception;    
BEGIN
    dm_data_trans_gen.stg_starttime := systimestamp;

--- Setting up the business date
    SELECT
        busdate
    INTO lv_busdate
    FROM
        stagedbusr.busdpf
    WHERE
        company = 1;

    v_output_count := 0;
	
	SELECT
		COUNT(*)
	INTO v_input_count
	FROM
		stagedbusr2.zmrage00; 


/*    FOR c_fet_chdrnum IN (
    SELECT DISTINCT
        substr(a.agecucd, 1, 8) chdrnum,
        substr(a.agecicd, - 2, length(a.agecicd)) ins_no,
        lpad(substr(a.agecicd, - 2, length(a.agecicd)), 5, '000') mbrno,
        agebedt      ren_frm_dt,
        to_number(to_char(add_months(to_date(to_date(agebedt, 'yyyymmdd')), 12) - 1, 'yyyymmdd')) ren_to_dt,
        TRIM(a.agecjcdn) new_sp_cde,
        TRIM(a.agecjcdo) old_sp_cde,
        a.agedlcd    cncl_cde,
        a.agetfce    form_no,
        a.agec7cdo   prd_cde,
        a.agec8cdo   prd_sub_cde,
        a.agec6cdo   end_cde,
        a.ageyob2    nspflg,
        a.ageyob1    ospflg,
        COUNT(a.agecicd) OVER(
            PARTITION BY substr(a.agecucd, 1, 8)
        ) cnt_of_ins
    FROM
        stagedbusr2.zmrage00 a
    ORDER BY
        substr(a.agecucd, 1, 8),
        substr(a.agecicd, - 2, length(a.agecicd))
) */

open c_fet_policy;
loop
fetch c_fet_policy bulk collect into  r_fet_policy limit c_limit;

FOR i_indx IN 1..r_fet_policy.count 

loop
    IF nvl(lv_pol_no, 'x') <> r_fet_policy(i_indx).chdrnum THEN

--- Resetting all variables  
        lv_pol_exists := 0;
        lv_sp_change := NULL;
        lv_step := NULL;
        v_errormsg := NULL;
        lv_main_det_cde := NULL;
        lv_sec_det_cde := NULL;
        lv_alt_code := NULL;
        lv_ins_role := NULL;
        lv_zterm := NULL;
        lv_stg_clntnum := NULL;
        lv_typ := NULL;
        lv_pol_cnt := NULL;
		lv_cur_sp_code := null;
        lv_ig_sp_code := Null;
    END IF;

    lv_pol_no := r_fet_policy(i_indx).chdrnum;


-- lv_pol_no       := null;
    SELECT
        COUNT(1)
    INTO lv_pol_exists
    FROM
        titdmgmbrindp1
    WHERE
        substr(TRIM(refnum), 1, 8) = r_fet_policy(i_indx).chdrnum;

    dbms_output.put_line('Before err');
    dbms_output.put_line('Policy number - ' || r_fet_policy(i_indx).chdrnum);
    IF lv_pol_exists = 0 THEN
  --v_errormsg := c_fet_chdrnum.chdrnum||' doesnt exists in titdmgmbrindp1';
        v_errormsg := 'policy no does not exists in Titdmgmbrindp1';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
                                                     || '-'
                                                     || r_fet_policy(i_indx).ins_no, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    END IF;

    
    
    if trim(r_fet_policy(i_indx).policy_stat_code) = 'CA' then
        v_errormsg := 'policy no - '
                      || r_fet_policy(i_indx).chdrnum  || ' Ins ' || r_fet_policy(i_indx).ins_no                
                      || ' is already in cancelled status';

        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;    
    elsif trim(r_fet_policy(i_indx).policy_cncl_date)  <> '99999999' then 
        v_errormsg := 'policy no - '
                      || r_fet_policy(i_indx).chdrnum  || ' Ins ' || r_fet_policy(i_indx).ins_no                 
                      || ' has future dated cancellation transaction';

        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;     
    
    
    end if;

-- Validate if the same insured for policy is available in the zmrage00
-- to improve performance , below code is changed

   /* SELECT
        COUNT(1)
    INTO lv_mem_cnt
    FROM
        stagedbusr2.zmrage00 a
    WHERE
        substr(a.agecucd, 1, 8) = r_fet_policy(i_indx).chdrnum
        AND substr(a.agecicd, - 2) = r_fet_policy(i_indx).ins_no;
		*/

    IF r_fet_policy(i_indx).ins_dup_check > 1 THEN
        v_errormsg := 'policy no '
                      || r_fet_policy(i_indx).chdrnum
                      || ' insured no '
                      || r_fet_policy(i_indx).ins_no
                      || ' is duplicated in zmrage00';

        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    END IF;

    SELECT
        COUNT(1)
    INTO lv_mem_cnt
    FROM
        stagedbusr2.renew_as_is
    WHERE
        apcucd = r_fet_policy(i_indx).chdrnum
        AND icicd = r_fet_policy(i_indx).ins_no;

    IF lv_mem_cnt > 1 THEN
        v_errormsg := 'policy no '
                      || r_fet_policy(i_indx).chdrnum
                      || ' insured no '
                      || r_fet_policy(i_indx).ins_no
                      || ' is duplicated in renew_as_is';

        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    END IF;

    IF r_fet_policy(i_indx).cnt_of_ins = 1 AND r_fet_policy(i_indx).ins_no = '02' THEN
        SELECT
            COUNT(1)
        INTO lv_mem_cnt
        FROM
            stagedbusr2.renew_as_is
        WHERE
            apcucd = r_fet_policy(i_indx).chdrnum
            AND icicd <> r_fet_policy(i_indx).ins_no;

        IF lv_mem_cnt = 0 THEN
            v_errormsg := 'policy no '
                          || r_fet_policy(i_indx).chdrnum
                          || ' main insured is not available in renew_as_is';
            dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

            lv_err_chk := true;
            CONTINUE;
        END IF;

    END IF;

    BEGIN
        SELECT
            typ,
            COUNT(1)
        INTO
            lv_typ,
            lv_pol_cnt
        FROM
            ( /* 
                SELECT
                    'zmrhr00' typ,
                    COUNT(substr(HRCUCD,1,8)) pol_cnt
                FROM
                    zmrhr00
                WHERE
                    substr(HRCUCD,1,8) = r_fet_policy(i_indx).chdrnum
                GROUP BY
                    'zmrhr00'
               UNION */
                SELECT
                    'asrf_rnw_dtrm' typ,
                    COUNT(chdrnum) pol_cnt
                FROM
                    asrf_rnw_dtrm
                WHERE
                    chdrnum = r_fet_policy(i_indx).chdrnum
                GROUP BY
                    'asrf_rnw_dtrm'
            )
        WHERE
            pol_cnt > 0
        GROUP BY
            typ;

    EXCEPTION
        WHEN no_data_found THEN
            NULL;
    END;

    /*IF lv_typ = 'zmrhr00' AND lv_pol_cnt > 0 THEN
        v_errormsg := 'policy no '
                      || r_fet_policy(i_indx).chdrnum
                      || ' exists in HCR file';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    ELS */
	IF lv_typ = 'asrf_rnw_dtrm' AND lv_pol_cnt > 0 THEN
        v_errormsg := 'policy no '
                      || r_fet_policy(i_indx).chdrnum
                      || ' exists in ASRF file';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    END IF;

    dbms_output.put_line('c_fet_chdrnum.new_sp_cde ' || r_fet_policy(i_indx).new_sp_cde);
    dbms_output.put_line('c_fet_chdrnum.old_sp_cde ' || r_fet_policy(i_indx).old_sp_cde);
    dbms_output.put_line('c_fet_chdrnum.cncl_cde ' || r_fet_policy(i_indx).cncl_cde);
	
/*--- Validating if the new sp code is same as the current / old sp code.
-- Fetch the old / current sp using mem_ind_polhist_ssplan_intrmdt

	open c_get_curr_sp(r_fet_policy(i_indx).chdrnum,r_fet_policy(i_indx).ins_no);
	fetch c_get_curr_sp into lv_cur_sp_code;
	close c_get_curr_sp;
	
	if trim(lv_cur_sp_code) = trim(nvl(r_fet_policy(i_indx).new_sp_cde,'x')) then
	
        v_errormsg := 'policy no '
                      || r_fet_policy(i_indx).chdrnum ||'-'||r_fet_policy(i_indx).ins_no
                      || ' has same current and new SP code';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;		
	
	end if;
*/	
	
	

--- If 'New Salesplan code' is Not blank
--- and 'New sales Plan Code' <> "Old Sales plan code, 
-- Then Consider it as Sales plan change.
    IF r_fet_policy(i_indx).new_sp_cde IS NOT NULL 
   -- and c_fet_chdrnum.new_sp_cde <> nvl(c_fet_chdrnum.old_sp_cde,'x') AG-2 Changes
     THEN
        lv_sp_change := 'Y';
        lv_step := 's1';

    END IF;
--elsif (nvl(c_fet_chdrnum.new_sp_cde,'x') = nvl(c_fet_chdrnum.old_sp_cde,'x'))
--       and nvl(trim(c_fet_chdrnum.cncl_cde),'x') in ('A1','A3') then
    IF ( ( r_fet_policy(i_indx).old_sp_cde IS NOT NULL AND r_fet_policy(i_indx).new_sp_cde IS NULL ) AND ( nvl(TRIM(r_fet_policy(i_indx).cncl_cde),
    'x') IN (
        'A1',
        'A3'
    ) ) ) THEN
        lv_sp_change := 'N';
        lv_step := 's2';
    END IF;

	--- If Sales Plan Changes is 'No' and Form No. = 'A2'  
	---then, Consider it as Cancel and re-entry case.  
	--- Below changes for AG-3

	IF ( ( r_fet_policy(i_indx).old_sp_cde IS NOT NULL AND r_fet_policy(i_indx).new_sp_cde IS NULL ) AND TRIM(r_fet_policy(i_indx).form_no) IN (
		'A2',
		'A5',
		'A8',
		'A9'
	) AND r_fet_policy(i_indx).ins_no = '02' ) THEN
		lv_sp_change := 'N'; 
		lv_step := 's3';
	END IF;  

-- If 'Old sales plan code' <> Blank and if 'New sales plan code = 'Blank' and Cancellation Code is 'Blank'
-- then, Consider as 'No-sales plan change'
--- Below code is commented as per AG-2, no sales plan change will be sent in RENEW_AS_IS file

/*if c_fet_chdrnum.new_sp_cde is null and c_fet_chdrnum.old_sp_cde is not null
   and trim(c_fet_chdrnum.cncl_cde) is null
then 
   lv_step := 's4';
end if;
*/

--- If Sales plan Change = 'Yes'  and 'Cancellation Code' is Not Blank, >> Error records
	IF lv_sp_change = 'Y' AND TRIM(r_fet_policy(i_indx).cncl_cde) IS NOT NULL THEN
		-- v_errormsg := c_fet_chdrnum.chdrnum||' SP changed with cancel code';
		v_errormsg := 'SP changed with cancel code';
		dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
													 || '-'
													 || r_fet_policy(i_indx).ins_no, substr(v_errormsg, 1, 200));

		lv_err_chk := true;
		CONTINUE;
            -- Below validation is added to check if there are insured which has letter code A2/A5/A8/A9 for secondary insured with SP change Y
    ELSIF lv_sp_change = 'Y' AND TRIM(r_fet_policy(i_indx).form_no) IN (
        'A2',
        'A5',
        'A8',
        'A9'
    ) AND r_fet_policy(i_indx).ins_no = '02' THEN
    -- v_errormsg := c_fet_chdrnum.chdrnum||' SP changed with letter code';
        v_errormsg := 'SP changed with letter code';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
                                                     || '-'
                                                     || r_fet_policy(i_indx).ins_no, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    ELSIF lv_step IS NULL THEN --- If None of the 3 conditions are met >> Error record
    --v_errormsg := c_fet_chdrnum.chdrnum||' has failed in SP check';
        v_errormsg := 'Failed in steps check';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
                                                     || '-'
                                                     || r_fet_policy(i_indx).ins_no, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    END IF;

    IF lv_step = 's1' THEN
        IF r_fet_policy(i_indx).ins_no = '01' THEN
            lv_main_det_cde := 'A10';
        ELSIF r_fet_policy(i_indx).ins_no = '02' THEN
            lv_sec_det_cde := 'A10';
        END IF;
    ELSIF lv_step = 's2' THEN
        IF trim(r_fet_policy(i_indx).cncl_cde) = 'A1' AND r_fet_policy(i_indx).ins_no = '01' THEN
            lv_main_det_cde := 'A01';
        ELSIF trim(r_fet_policy(i_indx).cncl_cde) = 'A3' AND r_fet_policy(i_indx).ins_no = '01' THEN
            lv_main_det_cde := 'A03';
        ELSIF trim(r_fet_policy(i_indx).cncl_cde) = 'A1' AND r_fet_policy(i_indx).ins_no = '02' THEN
            lv_sec_det_cde := 'A01';
        ELSIF trim(r_fet_policy(i_indx).cncl_cde) = 'A3' AND r_fet_policy(i_indx).ins_no = '02' THEN
            lv_sec_det_cde := 'A03';
        END IF;
    ELSIF lv_step = 's3' THEN
		-- AG-3 As per the new logic, main insured with letter code should be ignored and it should be treated
		--- as change in SP, since the new SP code will sent along with letter code for main insured.
		-- IF r_fet_policy(i_indx).ins_no = '01' THEN
		--     lv_main_det_cde := 'A03';
		-- ELS
		IF r_fet_policy(i_indx).ins_no = '02' THEN
            lv_sec_det_cde := 'A03';
        END IF;    

	/* Below code is commented as part of AG-2 changes, no SP change will be sent in renew_as_is file

	elsif  lv_step = 's4' then

		if c_fet_chdrnum.ins_no = '01' then
			lv_main_det_cde := null;
		elsif c_fet_chdrnum.ins_no = '02' then   
			lv_sec_det_cde := null;
		end if;
	*/
    END IF;

    IF TRIM(r_fet_policy(i_indx).cncl_cde) IS NOT NULL THEN
        lv_zterm := 'Y';
    ELSIF nvl(TRIM(r_fet_policy(i_indx).form_no), 'x') IN (
        'A2',
        'A5',
        'A8',
        'A9'
    ) AND r_fet_policy(i_indx).ins_no = '02' THEN
        lv_zterm := 'Y';
    ELSIF r_fet_policy(i_indx).ins_no = '02' AND r_fet_policy(i_indx).cnt_of_ins = '2' THEN
        SELECT
            COUNT(1)
        INTO lv_cnt
        FROM
            stagedbusr2.zmrage00
        WHERE
            substr(agecucd, 1, 8) = r_fet_policy(i_indx).chdrnum
            AND substr(agecicd, - 2) = '01'
            AND agedlcd IN (
                'A1',
                'A3'
            ); --or agetfce = 'A2');--- AG-3 Letter code is not valid for primary insured

        IF lv_cnt > 0 THEN
            lv_zterm := 'Y';
        END IF;
    ELSE
        lv_zterm := NULL;
    END IF;

    dbms_output.put_line('chdrnum '
                         || r_fet_policy(i_indx).chdrnum
                         || ' ins_no '
                         || r_fet_policy(i_indx).ins_no);

    OPEN c_get_insur_role(r_fet_policy(i_indx).chdrnum, r_fet_policy(i_indx).ins_no);
    FETCH c_get_insur_role INTO
        lv_ins_role,
        lv_stg_clntnum;
    CLOSE c_get_insur_role;
    dbms_output.put_line('before insert lv_ins_role ' || lv_ins_role);
    dbms_output.put_line('before insert lv_stg_clntnum ' || lv_stg_clntnum);
    dbms_output.put_line('before insert v_errormsg ' || v_errormsg);
    IF lv_ins_role IS NULL THEN
        v_errormsg := 'Insured role is null';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
                                                     || '-'
                                                     || r_fet_policy(i_indx).ins_no, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    ELSIF lv_stg_clntnum IS NULL THEN
        v_errormsg := 'Staging Client Number is null';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
                                                     || '-'
                                                     || r_fet_policy(i_indx).ins_no, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    END IF;

---- To get the alteration code using the determination code

    IF r_fet_policy(i_indx).ins_no = '01' THEN ----  
-- Blank            Any determination code  except Blank and Null            A02
        IF lv_main_det_cde IS NULL THEN
            lv_alt_code := NULL;
        ELSIF lv_main_det_cde IN (
            'A01',
            'A03'
        ) THEN
            lv_alt_code := 'A01';
        ELSIF lv_main_det_cde = 'A10' THEN
            lv_alt_code := 'A02';
        END IF;
    ELSIF r_fet_policy(i_indx).ins_no = '02' THEN
       -- AG-2 No Change in SP (Renew as is) for a one insured / both insured cannot come in ZMRAGE00
       -- Those insured will be sent in Renew as is file
       -- IF lv_main_det_cde IS NULL AND lv_sec_det_cde IS NULL THEN
       --     lv_alt_code := NULL;
       -- ELS
        IF lv_main_det_cde IN (
            'A01',
            'A03'
        ) THEN
            lv_alt_code := 'A01';
        ELSIF lv_main_det_cde IS NULL AND lv_sec_det_cde IS NOT NULL THEN
            lv_alt_code := 'A02';
        ELSIF lv_main_det_cde = 'A10' AND lv_sec_det_cde IS NOT NULL THEN
            lv_alt_code := 'A02';
        END IF;
    END IF;

---- Special case when the main insured is null and secondary insured is having any value other than null

    IF r_fet_policy(i_indx).cnt_of_ins = 2 AND r_fet_policy(i_indx).ins_no = '02' AND lv_main_det_cde IS NULL AND lv_sec_det_cde IS NOT NULL THEN
        UPDATE stagedbusr2.titdmgrnwdt1
        SET
            zaltrcde = 'A02'
        WHERE
            chdrnum = r_fet_policy(i_indx).chdrnum
            AND mbrno = '00001';

	ELSIF 		r_fet_policy(i_indx).cnt_of_ins = 1 AND r_fet_policy(i_indx).ins_no = '02'	and lv_sec_det_cde IS NOT NULL then
	
        UPDATE stagedbusr2.titdmgrnwdt1
        SET
            zaltrcde = 'A02'
        WHERE
            chdrnum = r_fet_policy(i_indx).chdrnum
            AND mbrno = '00001';	

    END IF;

--- below code should be changed as part of new development ************* AG

--update stagedbusr2.titdmgrnwdt1 set zaltrcde = 'A02'
--where chdrnum = c_fet_chdrnum.chdrnum
--and mbrno mbrno <> c_fet_chdrnum.mbrno
--and lv_sec_det_cde is not null 
--and trim(ZALTRCDE) is null;




-- salesplan conversion starts

    lv_dm_sp_cde := nvl(trim(r_fet_policy(i_indx).new_sp_cde), r_fet_policy(i_indx).old_sp_cde);

    OPEN c_get_relationship(r_fet_policy(i_indx).chdrnum, r_fet_policy(i_indx).ins_no);
    FETCH c_get_relationship INTO lv_ins_rel;
    CLOSE c_get_relationship;

    OPEN c_chk_cc_rider(r_fet_policy(i_indx).prd_cde, r_fet_policy(i_indx).prd_sub_cde, r_fet_policy(i_indx).end_cde, lv_dm_sp_cde);
    FETCH c_chk_cc_rider INTO lv_cc_rider_cnt;
    CLOSE c_chk_cc_rider;

    IF lv_cc_rider_cnt = 0 THEN
        lv_cc_rider := 'N';
    ELSE
        lv_cc_rider := 'Y';
    END IF;

    IF TRIM(r_fet_policy(i_indx).new_sp_cde) IS NOT NULL THEN
        IF substr(r_fet_policy(i_indx).nspflg, 1, 1) IN (
            'A',
            'B',
            'C',
            'D',
            'E'
        ) THEN
            lv_hcr := substr(r_fet_policy(i_indx).nspflg, 1, 1);
        ELSE
            lv_hcr := 'N';
        END IF;
    ELSE
        IF substr(r_fet_policy(i_indx).ospflg, 1, 1) IN (
            'A',
            'B',
            'C',
            'D',
            'E'
        ) THEN
            lv_hcr := substr(r_fet_policy(i_indx).ospflg, 1, 1) ;
        ELSE
            lv_hcr := 'N';
        END IF;
    END IF;

    dbms_output.put_line('lv_dm_sp_cde ' || lv_dm_sp_cde);
    dbms_output.put_line('lv_ins_rel ' || lv_ins_rel);
    dbms_output.put_line('lv_cc_rider ' || lv_cc_rider);
    dbms_output.put_line('lv_hcr ' || lv_hcr);


    OPEN c_get_ig_sp(lv_dm_sp_cde, lv_ins_rel, lv_cc_rider, lv_hcr);
    FETCH c_get_ig_sp INTO lv_ig_sp_code;
    CLOSE c_get_ig_sp;
    dbms_output.put_line('lv_ig_sp_code ' || lv_ig_sp_code);
    IF lv_ig_sp_code IS NULL THEN
        v_errormsg := 'IG Sales plan code is null / not found';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
                                                     || '-'
                                                     || r_fet_policy(i_indx).ins_no, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    END IF;

    select count(1) into rec_chk 
    from stagedbusr2.titdmgrnwdt1
    where chdrnum = r_fet_policy(i_indx).chdrnum
    and mbrno = r_fet_policy(i_indx).mbrno;
    
    if rec_chk > 0 then
        v_errormsg := 'Policy Insured already exists in TITDMGRNWDT1';
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
                                                     || '-'
                                                     || r_fet_policy(i_indx).mbrno, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE; 
 
    
    end if;


-- salesplan conversion ends

    IF v_errormsg IS NULL THEN
        dbms_output.put_line('lv_step ' || lv_step);
        dbms_output.put_line(r_fet_policy(i_indx).chdrnum
                             || '--'
                             || r_fet_policy(i_indx).mbrno
                             || '--'
                             || r_fet_policy(i_indx).ren_frm_dt
                             || '--'
                             || r_fet_policy(i_indx).ren_to_dt);

        dbms_output.put_line(lv_ins_role
                             || '--'
                             || lv_stg_clntnum
                             || '--'
                             || lv_zterm
                             || '--'
                             || nvl(trim(r_fet_policy(i_indx).new_sp_cde), r_fet_policy(i_indx).old_sp_cde));

        dbms_output.put_line(lv_main_det_cde);
        INSERT INTO stagedbusr2.titdmgrnwdt1 VALUES (
            r_fet_policy(i_indx).chdrnum,
            r_fet_policy(i_indx).mbrno,
            r_fet_policy(i_indx).ren_frm_dt,
            r_fet_policy(i_indx).ren_to_dt,
            lv_alt_code,-- this will be updated in below proc
            lv_busdate,----- This date is the business date
            lv_busdate,----- This date is the business date
            lv_ins_role,
            lv_stg_clntnum,----- This needs to be corrected
            lv_zterm,
            lv_ig_sp_code,--nvl(trim(c_fet_chdrnum.new_sp_cde),c_fet_chdrnum.old_sp_cde),--- This should rewrite to get IG sp through Spplancoversion logic
            decode(r_fet_policy(i_indx).ins_no, '01', lv_main_det_cde, lv_sec_det_cde),--lv_main_det_cde,
            NULL,
            'ZMRAGE00'
        );

        v_output_count := v_output_count + 1;
        l_app_old := r_fet_policy(i_indx).chdrnum;
    END IF;

    dbms_output.put_line('v_errormsg ' || v_errormsg);
    dbms_output.put_line('lv_step '
                         || r_fet_policy(i_indx).chdrnum
                         || '--'
                         || lv_step);

commit;

END loop;

        EXIT WHEN c_fet_policy%notfound;
    END LOOP;


close c_fet_policy;
--- To insert into the summary of the TITDMGRNWDT1 transformation
IF  not lv_err_chk  THEN

    temp_no := DM_data_trans_gen.control_log('ZMRAGE00', 'TITDMGRNWDT1', systimestamp, l_app_old, 'SUCCESS',
                      'S', v_input_count, v_output_count);
ELSE

    temp_no := DM_data_trans_gen.control_log('ZMRAGE00', 'TITDMGRNWDT1', systimestamp, l_app_old, 'COMPLETED WITH ERROR',
                      'F', v_input_count, v_output_count);
END IF;

commit;

-- if v_errormsg is null then

--raise ex_exp;


--raise; --- Testing

-- Rest the error check value for TITDMGRNWDT2 transformation
lv_err_chk := false;
v_output_count := 0;

---- Coverages for the policies
--- Below query change for AG-3, to check the letter code only for the secondary (spouse & relative) and not for main insured

insert into rnd_coverage_table
(SELECT CHDRNUM,
        RNCNT,
        ALCNT,
        CNTTYP,
        SLPLAN,
        INSURED,
        MBRNO,
        DECODE(INSURED, 'Main', '00', 'Spouse', '01', 'Relative', '02') DPNTNO,
        INSTYPE,
        PRODTYP,
        PREM_J1,
        PREM_J2,
        SUMINS,
        ENDRCDE,
                        NDR_PREM_J1,
                        NDR_PREM_J2
FROM (
    SELECT SUBSTR(AGE.AGECUCD,0,8) CHDRNUM,
                        '000' || SUBSTR(AGE.AGECICD, -2) MBRNO,
        SUBSTR(AGE.AGECUCD,9,2) RNCNT,
        SUBSTR(AGE.AGECUCD,11,1) ALCNT,
        C.RCBUCD SUBCODE,
        C.RCBTCD CNTTYP,
        C.RCBVCD SLPLAN,
        'Main' INSURED,
        C.RCB6CD INSTYPE,
        DECODE(C.RCB6CD,'PO',2||C.RCA0ST,'PFA',3||C.RCA0ST,'SPA',4||C.RCA0ST,'PTA',5||C.RCA0ST,'PFT',6||C.RCA0ST,'CLP',7||C.RCA0ST,'EQ',8||C.RCA0ST) PRODTYP,
        C.RCBPVA PREM_J1,
        C.RCBSVA PREM_J2,
        C.RCBDVA SUMINS,
        C.RCFOCD ENDRCDE,
        C.RCPPVA NDR_PREM_J1,
        C.RCPSVA NDR_PREM_J2
    FROM  stagedbusr2.ZMRAGE00 AGE,stagedbusr2.ZMRRC00 C
    WHERE
                        -- If New Sales Plan Code, is available, use it.
                        -- Else use Old/Current Sales Plan Code.
            C.RCBVCD=NVL2(TRIM(AGE.AGECJCDN),AGE.AGECJCDN,AGE.AGECJCDO)
                        AND AGE.AGEC6CDO=C.RCFOCD        -- Endorser Code
                        AND AGE.AGEC7CDO=C.RCBTCD        -- Contract Type
                        AND AGE.AGEC8CDO=C.RCBUCD        -- Sub Contract Code
 --   AND NVL(AGE.AGEDLCD,'X') NOT IN ('A1','A3') 
    ---AND NVL(AGE.AGETFCE,'X') <> 'A2' -- This added to control the policy which are going to get terminated as per new logic
    UNION ALL
    SELECT SUBSTR(AGE.AGECUCD,0,8) CHDRNUM,
                        '000' || SUBSTR(AGE.AGECICD, -2) MBRNO,
        SUBSTR(AGE.AGECUCD,9,2) RNCNT,
        SUBSTR(AGE.AGECUCD,11,1) ALCNT,
        C.RCBUCD SUBCODE,
        C.RCBTCD CNTTYP,
        C.RCBVCD SLPLAN,
        'Spouse' INSURED,
        C.RCB6CD INSTYPE,
        DECODE(C.RCB6CD,'PO',2||C.RCA0ST,'PFA',3||C.RCA0ST,'SPA',4||C.RCA0ST,'PTA',5||C.RCA0ST,'PFT',6||C.RCA0ST,'CLP',7||C.RCA0ST,'EQ',8||C.RCA0ST) PRODTYP,
        C.RCBQVA PREM_J1,
        C.RCBTVA PREM_J2,
        C.RCBEVA SUMINS,
        C.RCFOCD ENDRCDE,
                        C.RCPQVA NDR_PREM_J1,
                        C.RCPTVA NDR_PREM_J2
    FROM  stagedbusr2.ZMRAGE00 AGE,stagedbusr2.ZMRRC00 C
    WHERE
                        -- If New Sales Plan Code, is available, use it.
                        -- Else use Old/Current Sales Plan Code.
            C.RCBVCD=NVL2(TRIM(AGE.AGECJCDN),AGE.AGECJCDN,AGE.AGECJCDO)
                        AND AGE.AGEC6CDO=C.RCFOCD        -- Endorser Code
                        AND AGE.AGEC7CDO=C.RCBTCD        -- Contract Type
                        AND AGE.AGEC8CDO=C.RCBUCD        -- Sub Contract Code
 --   AND NVL(AGE.AGEDLCD,'X') NOT IN ('A1','A3') 
 --   AND NVL(AGE.AGETFCE,'X') NOT IN ('A2','A5','A8','A9') -- This added to control the policy which are going to get terminated as per new logic
    UNION ALL
    SELECT SUBSTR(AGE.AGECUCD,0,8) CHDRNUM,
                        '000' || SUBSTR(AGE.AGECICD, -2) MBRNO,
        SUBSTR(AGE.AGECUCD,9,2) RNCNT,
        SUBSTR(AGE.AGECUCD,11,1) ALCNT,
        C.RCBUCD SUBCODE,
        C.RCBTCD CNTTYP,
        C.RCBVCD SLPLAN,
        'Relative' INSURED,
        C.RCB6CD INSTYPE,
        DECODE(C.RCB6CD,'PO',2||C.RCA0ST,'PFA',3||C.RCA0ST,'SPA',4||C.RCA0ST,'PTA',5||C.RCA0ST,'PFT',6||C.RCA0ST,'CLP',7||C.RCA0ST,'EQ',8||C.RCA0ST) PRODTYP,
        C.RCBRVA PREM_J1,
        C.RCBUVA PREM_J2,
        C.RCBFVA SUMINS,
        C.RCFOCD ENDRCDE,
                        C.RCPRVA NDR_PREM_J1,
                        C.RCPUVA NDR_PREM_J2
    FROM  stagedbusr2.ZMRAGE00 AGE,stagedbusr2.ZMRRC00 C
            WHERE
                        -- If New Sales Plan Code, is available, use it.
                        -- Else use Old/Current Sales Plan Code.
            C.RCBVCD=NVL2(TRIM(AGE.AGECJCDN),AGE.AGECJCDN,AGE.AGECJCDO)
                        AND AGE.AGEC6CDO=C.RCFOCD        -- Endorser Code
                        AND AGE.AGEC7CDO=C.RCBTCD        -- Contract Type
                        AND AGE.AGEC8CDO=C.RCBUCD        -- Sub Contract Code
  --  AND NVL(AGE.AGEDLCD,'X') NOT IN ('A1','A3') 
  --  AND NVL(AGE.AGETFCE,'X') NOT IN ('A2','A5','A8','A9') -- This added to control the policy which are going to get terminated as per new logic
) WHERE 
PREM_J1 > 0 or PREM_J2 > 0
);

----- Coverage results insertion

insert into stagedbusr2.source_coverage_results
(SELECT DISTINCT chdrnum, mbrno, dpntno, zsalplan, zinstype, prodtyp, SUMINS, prem, ndrprem --PRODTYP02,ZTAXFLG
FROM(
            SELECT cov.chdrnum AS chdrnum,
                        cov.mbrno AS mbrno,
                        '00' AS dpntno, --- For Named cases, always it is 00
                        dt1.zsalplan AS zsalplan,
                        cov.prodtyp AS prodtyp,
                        cov.instype AS zinstype,
                        (cov.sumins * NVL(dnm.dnmtor, 1))  AS SUMINS,
                        --Premium
                        CASE WHEN ris.iscfst = 1 THEN
                cov.prem_j1 
             WHEN ris.iscfst = 2 THEN
                cov.prem_j2
                        END AS prem,
                        --NDR Premium
                        CASE WHEN ris.iscfst = 1 THEN
                cov.ndr_prem_j1
             WHEN ris.iscfst = 2 THEN
                cov.ndr_prem_j2
                        END AS ndrprem                                              
            FROM rnd_coverage_table cov
                        INNER JOIN titdmgrnwdt1   dt1 ON  dt1.chdrnum = cov.chdrnum ---- This is added as we need to check the policy exists in titdmgrnwdt1
                                                                                    AND dt1.mbrno = cov.mbrno    
                        LEFT OUTER JOIN maxpolnum mx  ON mx.apcucd = cov.chdrnum
                        LEFT OUTER JOIN zmris00   ris ON ris.iscucd = mx.maxapcucd
                                                                                    AND SUBSTR(ris.iscicd,-2) = SUBSTR(cov.mbrno,-2)
                        LEFT OUTER JOIN stagedbusr.zslphpf hpf ON hpf.zsalplan = dt1.zsalplan
                        LEFT OUTER JOIN titdmgsuminsfactor dnm ON dnm.zinstype = cov.instype
                                                                                    AND dnm.dm_prodtyp = substr(cov.prodtyp,-3) -- to remove first digit
                        LEFT OUTER JOIN stagedbusr.zslppf ppf ON ppf.zsalplan = dt1.zsalplan
            WHERE hpf.zslptyp = 'N'
        and (dt1.mbrno = '00001' OR 
        (dt1.mbrno = '00002' AND NOT EXISTS  (SELECT 1 FROM stagedbusr.itempf it WHERE ppf.prodtyp= RTRIM(it.itemitem) AND it.itemtabl='TQ9GY'
                                      AND it.itempfx='IT' AND it.validflag='1' AND TRIM(substr(UTL_RAW.CAST_TO_VARCHAR2(it.genarea),1,5))='C'
                                      AND substr(UTL_RAW.CAST_TO_VARCHAR2(genarea),9,1)='Y')
                                                                      ))
union all
--- To get the rider details
SELECT cov.chdrnum AS chdrnum,
                        cov.mbrno AS mbrno,
    case when hpf.zslptyp = 'N' then
                        '00'
    else
  cov.dpntno --- To follow same as un-named 
    --'0' || (dt1.zinsrole -1)
    end as dpntno, --- For Named cases, always it is 00 for un-named to be checked..???
                        dt1.zsalplan AS zsalplan,
                        ppf.prodtyp AS prodtyp,
                        ppf.zinstype AS zinstype,
                        0 AS SUMINS, --- for riders it is set as 0
    0 as Premium,--- for riders it is set as 0
    0 as ndrprem --- for riders it is set as 0

            FROM rnd_coverage_table cov
                        INNER JOIN titdmgrnwdt1   dt1 ON  dt1.chdrnum = cov.chdrnum ---- This is added as we need to check the policy exists in titdmgrnwdt1
                                                                                    AND dt1.mbrno = cov.mbrno    
                        LEFT OUTER JOIN stagedbusr.zslphpf hpf ON hpf.zsalplan = dt1.zsalplan
    LEFT OUTER JOIN stagedbusr.zslppf ppf ON ppf.zsalplan = dt1.zsalplan AND ppf.zcovrid IN ('R')
            where (dt1.mbrno = '00001' OR 
          (dt1.mbrno = '00002' AND NOT EXISTS  (SELECT 1 FROM stagedbusr.itempf it WHERE ppf.prodtyp= RTRIM(it.itemitem) AND it.itemtabl='TQ9GY'
                                                              AND it.itempfx='IT' AND it.validflag='1' AND TRIM(substr(UTL_RAW.CAST_TO_VARCHAR2(it.genarea),1,5))='R'
                                                              AND substr(UTL_RAW.CAST_TO_VARCHAR2(genarea),9,1)='Y')
                                                  ))
UNION ALL
  --- HCR coverages
    select dt1.chdrnum,
    dt1.mbrno,
    case when hpf.zslptyp = 'N' then
    '00'
    else
    '0' || (dt1.zinsrole -1)
    end as dpntno,
    dt1.zsalplan AS zsalplan,
    ppf.prodtyp,
    ppf.zinstype,
    ppf.sumins,
    0 dprem,
    0 Ndr_Dprem
    from titdmgrnwdt1 dt1,
    stagedbusr.zslphpf hpf,
    stagedbusr.zslppf ppf,
    stagedbusr2.zmrage00 zmr,
    stagedbusr.itempf itm
    where substr(zmr.agecucd,1,8) = dt1.chdrnum
    and '000' || substr(zmr.agecicd, -2)  = dt1.mbrno
    and hpf.zsalplan = dt1.zsalplan
    and ppf.zsalplan = dt1.zsalplan
    and itm.itemtabl= 'TQ9GY'  
    and itm.itempfx = 'IT'
    and Substr(Utl_Raw.Cast_To_Varchar2(itm.Genarea),1,1) = 'C'
    and substr(utl_raw.cast_to_varchar2(itm.genarea),8,1) = '1'    
    and ppf.prodtyp = trim(itm.itemitem) -- ('2951','3951')
    and nvl(trim(zmr.Ageyob2),'N') <> 'N'
            UNION ALL

            SELECT cov.chdrnum AS chdrnum,
                        cov.mbrno AS mbrno,
                        cov.dpntno AS dpntno,
                        dt1.zsalplan AS zsalplan,
                        cov.prodtyp AS prodtyp,
                        cov.instype AS zinstype,
                        (cov.sumins * NVL(dnm.dnmtor, 1))  AS SUMINS,
                        --Premium
                        CASE WHEN ris.iscfst = 1 THEN
                cov.prem_j1 
             WHEN ris.iscfst = 2 THEN
                cov.prem_j2
                        END AS prem,
                        --NDR Premium
                        CASE WHEN ris.iscfst = 1 THEN
                cov.NDR_PREM_J1
             WHEN ris.iscfst = 2 THEN
                cov.NDR_PREM_J2
                        END AS ndrprem                                              
            FROM rnd_coverage_table cov
                        INNER JOIN titdmgrnwdt1   dt1 ON  dt1.chdrnum = cov.chdrnum
                                                                                    AND dt1.mbrno = cov.mbrno  --- titdmgrnwdt1, mbrno already in the required format and so no need to add 000
                                                                                    --  AND ('0' || (dt1.zinsrole -1)) = cov.dpntno --- commented because all cases dependents covereage should be available in un-named
                        LEFT OUTER JOIN maxpolnum mx  ON mx.apcucd = cov.chdrnum
                        LEFT OUTER JOIN zmris00   ris ON ris.iscucd = mx.maxapcucd
                                                                                    AND SUBSTR(ris.iscicd,-2) = SUBSTR(cov.mbrno,-2)
                        --LEFT OUTER JOIN spplanconvertion   spp ON spp.oldzsalplan = cov.slplan
                        LEFT OUTER JOIN stagedbusr.zslphpf hpf ON hpf.zsalplan = dt1.zsalplan
                        LEFT OUTER JOIN titdmgsuminsfactor dnm ON dnm.zinstype = cov.instype
                                                                                    AND dnm.dm_prodtyp = substr(cov.prodtyp,-3) -- to remove first digit
            WHERE hpf.zslptyp = 'U'
            ));
COMMIT;
select count(1) into v_input_count
from source_coverage_results;

--for c_get_cvr in (select * from source_coverage_results)
open c_get_cvr;
loop
fetch c_get_cvr bulk collect into r_get_cvr limit c_limit;

for  i_indx IN 1..r_get_cvr.count 
loop

select count(1) into lv_pol_chk_cnt from
stagedbusr2.titdmgrnwdt1
where chdrnum = r_get_cvr(i_indx).chdrnum
and mbrno = r_get_cvr(i_indx).mbrno;

if lv_pol_chk_cnt = 0 then

    v_errormsg := 'policy and member is not available in TITDMGRNWDT1';
    DM_data_trans_gen.error_logs('TITDMGRNWDT2', r_get_cvr(i_indx).chdrnum||'-'||r_get_cvr(i_indx).mbrno, substr(v_errormsg, 1, 200));
    lv_err_chk := true;
    continue;

end if;

if r_get_cvr(i_indx).mbrno = '00002' then

  select count(1) into lv_cnt from 
  stagedbusr2.zmrage00
  where substr(agecucd,1,8) = r_get_cvr(i_indx).chdrnum
  and substr(agecicd,-2)  = '01'
  and agedlcd in ('A1','A3'); --or agetfce = 'A2' -- Changed for AG-3

    IF lv_cnt > 0 THEN

         --v_errormsg := c_fet_chdrnum.chdrnum||' has failed in SP check';
        v_errormsg := 'Main-insured is cancelled and hence secondary insured not inserted';
        -- No need to record this error, as this is a valid case
        --dm_data_trans_gen.error_logs('TITDMGRNWDT2', r_get_cvr(i_indx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;
    END IF;
END IF;

    IF nvl(r_get_cvr(i_indx).ndrprem, 0) <> 0 THEN
        OPEN c_get_ndr_prdtyp2(r_get_cvr(i_indx).zinstype, r_get_cvr(i_indx).prodtyp);
        FETCH c_get_ndr_prdtyp2 INTO lv_prod_type02;
        CLOSE c_get_ndr_prdtyp2;
    ELSE
        lv_prod_type02 := NULL;
    END IF;

--- Insert into final table

    INSERT INTO stagedbusr2.titdmgrnwdt2 VALUES (
        r_get_cvr(i_indx).chdrnum,
        r_get_cvr(i_indx).mbrno,
        r_get_cvr(i_indx).dpntno,
        r_get_cvr(i_indx).prodtyp,
        r_get_cvr(i_indx).sumins,
        r_get_cvr(i_indx).prem,
        r_get_cvr(i_indx).zinstype,
        lv_prod_type02,
        r_get_cvr(i_indx).ndrprem,
        'ZMRAGE00'
    );

    l_app_old := r_get_cvr(i_indx).chdrnum;
    v_output_count := v_output_count + 1;

commit;

END loop;
    EXIT WHEN c_get_cvr%notfound;

end loop;

close c_get_cvr;



--end if;
    IF NOT lv_err_chk THEN
        temp_no := dm_data_trans_gen.control_log('SOURCE_COVERAGE_RESULTS', 'TITDMGRNWDT2', systimestamp, l_app_old, 'SUCCESS',
                              'S', v_input_count, v_output_count);

    ELSE
        temp_no := dm_data_trans_gen.control_log('SOURCE_COVERAGE_RESULTS', 'TITDMGRNWDT2', systimestamp, l_app_old, 'COMPLETED WITH ERROR'
        ,
                              'F', v_input_count, v_output_count);
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('sqlerrm ' || substr(dbms_utility.format_error_backtrace,1,4000));
        v_errormsg := v_errormsg
                      || ' '
                      || sqlerrm;
        dm_data_trans_gen.error_logs('TITDMGRNWDT1', lv_pol_no, substr(v_errormsg, 1, 200));
END dm_zmrage_renew_det;


procedure dm_zmrhr_renew_det (p_array_size IN PLS_INTEGER DEFAULT 1000)
is

--- Cusrosr declaration


/*cursor  c_fet_policy is 
select distinct  a.chdrnum,
              a.maturity_date, 
              b.mbrno,
              b.zinsrole,
              b.clientno,
              a.ins_age,
              b.zplancde
     from v_zmrhr00 a,
              trnh_records b
     where a.Chdrnum = b.chdrnum
           and lpad(a.ins,5,'00000') = b.mbrno;*/

cursor  c_fet_policy is 
select a.*,b.statcode   policy_stat_code,
        b.Zpoltdate  policy_cncl_date from stagedbusr2.zmrhr00_p1 a 
left outer join policy_statcode b
on a.chdrnum = b.chdrnum;



/*cursor c_fet_cov_det is select refnum chdrnum, 
                  mbrno,dpntno,prodtyp,hsuminsu,zinstype,prodtyp02,ndrprem,aprem
                  from p2_records; */         


cursor c_fet_cov_det is
select distinct p2.refnum chdrnum, p2.mbrno,p2.dpntno,p2.Prodtyp,p2.hsuminsu,p2.zinstype,p2.prodtyp02,p2.ndrprem,p2.aprem
from stagedbusr2.zmrhr00_p1 src,
     stagedbusr2.titdmgmbrindp2 p2
where src.chdrnum = p2.refnum
and substr(src.mbrno,-2) = substr(p2.mbrno,-2)
and src.effdate = p2.effdate
and (substr(src.mbrno,-2) = '01' or
    (substr(src.mbrno,-2) = '02' AND NOT EXISTS  (SELECT 1 FROM stagedbusr.itempf it WHERE p2.prodtyp= RTRIM(it.itemitem) AND it.itemtabl='TQ9GY'
                                      AND it.itempfx='IT' AND it.validflag='1' AND TRIM(substr(UTL_RAW.CAST_TO_VARCHAR2(it.genarea),1,5))='C'
                                      AND substr(UTL_RAW.CAST_TO_VARCHAR2(genarea),9,1)='Y')
                                      ));

cursor c_get_dprem(cp_pol_no stagedbusr2.zmrage00.agecucd%type,
                   cp_mem_no varchar2)               
is 
select hrcvva1 tot_prem_af_ren
from zmrhr00 src
where substr(src.hrcucd,1,8) = cp_pol_no
and substr(src.hrcicd1,-2) = substr(cp_mem_no,-2);

type t_fet_policy is table of c_fet_policy%rowtype;
r_fet_policy t_fet_policy;


type t_fet_cov_det is table of c_fet_cov_det%rowtype;
r_fet_cov_det t_fet_cov_det;

--- local variable declaration


lv_pol_no          stagedbusr2.zmrage00.agecucd%type; 
lv_dprem           stagedbusr2.zmrhr00.hrcvva1%type;
lv_pol_indp1_chk   pls_integer := 0;
lv_pol_indp2_chk   pls_integer := 0;
lv_ren_to_date     varchar2(25);
lv_typ             varchar2(15); 
lv_pol_cnt         pls_integer;
lv_prod_cnt        pls_integer;
lv_pol_chk_cnt     number;


v_errormsg         varchar2(2000) := null;
lv_busdate         stagedbusr.busdpf.busdate%type;

v_output_count      number;
v_input_count       number;
l_app_old           varchar2(60) := NULL;
temp_no             Number;
lv_err_chk          boolean := false;
c_limit            PLS_INTEGER := p_array_size;
rec_chk             number;

lv_zterm           stagedbusr2.titdmgrnwdt1.ztermflg%TYPE;
lv_main_cncl       PLS_INTEGER := 0;
lv_cnt             PLS_INTEGER;
begin

dm_data_trans_gen.stg_starttime := systimestamp;

select busdate into lv_busdate
from stagedbusr.busdpf
where company = 1;

/*
select count(1) into  v_input_count 
from (
select distinct  a.chdrnum,
a.maturity_date, 
b.mbrno,
b.zinsrole,
b.clientno,
a.ins_age,
b.zplancde
from v_zmrhr00 a,
trnh_records b
where a.Chdrnum = b.chdrnum
and lpad(a.ins,5,'00000') = b.mbrno);
*/

select count(1) into  v_input_count  from zmrhr00;


/*for c_fet_policy in (select distinct  a.chdrnum,
                                      a.maturity_date, 
                                      b.mbrno,
                                      b.zinsrole,
                                      b.clientno,
                                      a.ins_age,
                                      b.zplancde
                                      from v_zmrhr00 a,
                                      trnh_records b
                                      where a.Chdrnum = b.chdrnum
                                      and lpad(a.ins,5,'00000') = b.mbrno)
loop
*/

--- To Improve the performance, temp views are changed to below query

Insert into stagedbusr2.zmrhr00_p1
(select  distinct substr(src.hrcucd,1,8) chdrnum,
hrbedt maturity_date,
'000'||p1i.mbrno mbrno,
trnh.zinsrole zinsrole,
trnh.clientno clientno,
src.hrbonb1 ins_age,
p1i.zplancde zplancde,
trnh.effdate effdate
from zmrhr00 src,
titdmgmbrindp1 p1,
titdmgpoltrnh trnh,
titdmgmbrindp1 p1i
where substr(p1.refnum,1,8) = substr(src.hrcucd,1,8)
and trnh.chdrnum = substr(p1.refnum,1,8)
and trnh.chdrnum = substr(p1i.refnum,1,8)
and substr(trnh.mbrno,-2) = p1i.mbrno
and substr(src.hrcicd1,-2) = p1i.mbrno
and p1.client_category = '0'
and p1i.client_category = '1'
and to_date(trnh.effdate,'yyyymmdd') = to_date(p1.effdate,'yyyymmdd')
and p1.effdate = (select max(p1m.effdate) from titdmgmbrindp1 p1m where substr(p1m.refnum,1,8) = substr(src.hrcucd,1,8)
                 and p1m.client_category = p1.client_category)
);

v_output_count := 0;

open c_fet_policy;
loop

fetch c_fet_policy bulk collect into r_fet_policy limit c_limit;

for i_idx in 1..r_fet_policy.count 
loop

lv_pol_no := r_fet_policy(i_idx).chdrnum;
v_errormsg := 'Insertion into titdmgrnwdt1 ';

select count(1) into lv_pol_indp1_chk
from titdmgmbrindp1
where  substr(refnum,1,8) = r_fet_policy(i_idx).chdrnum;

select count(1) into lv_pol_indp2_chk
from titdmgmbrindp2
where  substr(refnum,1,8) = r_fet_policy(i_idx).chdrnum;

if lv_pol_indp1_chk = 0 then 

  v_errormsg := 'policy no doesnt exists in titdmgmbrindp1';
  DM_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_idx).chdrnum, substr(v_errormsg, 1, 200));
  lv_err_chk := true;
  continue;

elsif lv_pol_indp2_chk = 0 then

  v_errormsg := 'policy no doesnt exists in titdmgmbrindp2';
  DM_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_idx).chdrnum, substr(v_errormsg, 1, 200));
  lv_err_chk := true;
  continue;

end if;





 if trim(r_fet_policy(i_idx).policy_stat_code) = 'CA' then
        v_errormsg := 'policy no - '
                      || r_fet_policy(i_idx).chdrnum  || ' Ins ' || r_fet_policy(i_idx).mbrno                
                      || ' is already in cancelled status';

        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_idx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;    
    elsif trim(r_fet_policy(i_idx).policy_cncl_date)  <> '99999999' then 
        v_errormsg := 'policy no - '
                      || r_fet_policy(i_idx).chdrnum  || ' Ins ' || r_fet_policy(i_idx).mbrno                 
                      || ' has future dated cancellation transaction';

        dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_idx).chdrnum, substr(v_errormsg, 1, 200));

        lv_err_chk := true;
        CONTINUE;     
    
    
 end if;

begin

select typ, count(1) into lv_typ,lv_pol_cnt
from (
/*select 'zmrage00' typ,count(substr(Agecucd,1,8)) pol_cnt
from zmrage00
where substr(agecucd,1,8) = r_fet_policy(i_idx).chdrnum
group by 'zmrage00'*/
/*union 
select 'renew_as_is' typ,count(apcucd)
from renew_as_is
where apcucd = r_fet_policy(i_idx).chdrnum
group by 'renew_as_is'
*/
--union
select 'asrf' typ,count(chdrnum) pol_cnt
from asrf_rnw_dtrm
where chdrnum = r_fet_policy(i_idx).chdrnum
group by 'asrf'
)
where pol_cnt > 0
group by typ;

exception when NO_DATA_FOUND THEN
        NULL;
end;



/*
if nvl(lv_typ,'x') = 'zmrage00' and nvl(lv_pol_cnt,0) > 0 then

  v_errormsg := 'policy no exists in zmrage00';
  DM_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_idx).chdrnum, substr(v_errormsg, 1, 200));
  lv_err_chk := true;
  continue;

/*elsif nvl(lv_typ,'x') = 'renew_as_is' and nvl(lv_pol_cnt,0) > 0 then

  v_errormsg := 'policy no exists in renew_as_is';
  DM_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_idx).chdrnum, substr(v_errormsg, 1, 200));
  lv_err_chk := true;
  continue;
*/
  -- els
  
  if nvl(lv_typ,'x') = 'asrf' and nvl(lv_pol_cnt,0) > 0 then

  v_errormsg := 'policy no exists in asrf';
  DM_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_idx).chdrnum, substr(v_errormsg, 1, 200));
  lv_err_chk := true;
  continue;

end if;


--- Get the Renewal To date

--open c_fet_rento_date(c_fet_policy.chdrnum);
--fetch c_fet_rento_date into lv_ren_to_date;
--close c_fet_rento_date;
select count(1) into rec_chk 
from stagedbusr2.titdmgrnwdt1
where chdrnum = r_fet_policy(i_idx).chdrnum
and mbrno = r_fet_policy(i_idx).mbrno;

if rec_chk > 0 then
    v_errormsg := 'Policy Insured already exists in TITDMGRNWDT1';
    dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_idx).chdrnum
                                                 || '-'
                                                 || r_fet_policy(i_idx).mbrno, substr(v_errormsg, 1, 200));

    lv_err_chk := true;
    CONTINUE; 


end if;



IF r_fet_policy(i_idx).mbrno = '00002' THEN
	SELECT
		COUNT(1)
	INTO lv_cnt
	FROM
		stagedbusr2.zmrage00
	WHERE
		substr(agecucd, 1, 8) = r_fet_policy(i_idx).chdrnum
		AND substr(agecicd, - 2) = '01'
		AND ( agedlcd IN (
			'A1',
			'A3'
		)
			  --OR agetfce = 'A2'-- Letter code is not applicable for main insured
			  );

	IF lv_cnt > 0 THEN
		lv_zterm := 'Y';
	ELSE
		lv_zterm := NULL;
	END IF;
	
ELSE

	lv_zterm := NULL; 
END IF;



insert into stagedbusr2.titdmgrnwdt1
values
(r_fet_policy(i_idx).chdrnum,
r_fet_policy(i_idx).mbrno,
r_fet_policy(i_idx).maturity_date,
to_number(to_char(add_months( to_date(to_date(r_fet_policy(i_idx).maturity_date,'yyyymmdd')), 12 )-1,'yyyymmdd')),
--lv_ren_to_date,
null,---- ZALTRCDE
lv_busdate,---- ZRNDTREG
lv_busdate,---- ZRNDTAPP
r_fet_policy(i_idx).zinsrole,
r_fet_policy(i_idx).clientno,
lv_zterm,-- null,--- ZTERMFLG
r_fet_policy(i_idx).zplancde,
null,-- ZRNDTRCD
r_fet_policy(i_idx).ins_age,
'ZMRHR00'
);

l_app_old := r_fet_policy(i_idx).chdrnum;
v_output_count := v_output_count + 1;

commit;
end loop;
exit when c_fet_policy%notfound;
end loop;

close c_fet_policy;





IF  not lv_err_chk  THEN

       temp_no := DM_data_trans_gen.control_log('V_ZMRHR00 - TRNH_RECORDS', 'TITDMGRNWDT1', systimestamp, l_app_old, 'SUCCESS',
                      'S', v_input_count, v_output_count); 

ELSE

    temp_no := DM_data_trans_gen.control_log('V_ZMRHR00 - TRNH_RECORDS', 'TITDMGRNWDT1', systimestamp, l_app_old, 'COMPLETED WITH ERROR',
                      'F', v_input_count, v_output_count);
END IF;


select count(1) into v_input_count
from zmrhr00_p1;

v_output_count := 0;
lv_err_chk := false;

/*for c_fet_pol2 in (select refnum chdrnum, 
                  mbrno,dpntno,prodtyp,hsuminsu,zinstype,prodtyp02,ndrprem,aprem
                  from p2_records)
loop
*/
open c_fet_cov_det;
loop
fetch c_fet_cov_det bulk collect into r_fet_cov_det limit c_limit;

for i_idx in 1..r_fet_cov_det.count loop

lv_pol_no := r_fet_cov_det(i_idx).chdrnum;
v_errormsg := 'Insertion into titdmgrnwdt2 ';

lv_dprem := null;

select count(1) into lv_pol_chk_cnt from
stagedbusr2.titdmgrnwdt1
where chdrnum = r_fet_cov_det(i_idx).chdrnum
and substr(mbrno,-2) = substr(r_fet_cov_det(i_idx).mbrno,-2);

if lv_pol_chk_cnt = 0 then

    v_errormsg := 'policy and member is not available in TITDMGRNWDT1';
    DM_data_trans_gen.error_logs('TITDMGRNWDT2', r_fet_cov_det(i_idx).chdrnum||'-'||r_fet_cov_det(i_idx).mbrno, substr(v_errormsg, 1, 200));
    lv_err_chk := true;
    continue;

end if;



--- For un-named policy, only mbrno -00001 exists and it will be always in one file.
--- It cannot have main-insured in one file and other insured in other file.

IF r_fet_cov_det(i_idx).mbrno = '00002' THEN
	SELECT
		COUNT(1)
	INTO lv_main_cncl
	FROM
		stagedbusr2.zmrage00
	WHERE
		substr(agecucd, 1, 8) = lv_pol_no
		AND substr(agecicd, - 2) = '01'
		AND ( agedlcd IN (
			'A1',
			'A3'
		)
			  --OR agetfce = 'A2' -- Letter code is not applicable for main insured
			  );

-- IG doesn't contain the coverage details of secondary insured, if the main-insured is already cancelled in ZMRAGE00     

	IF lv_main_cncl > 0 THEN
-- No need to error, Just need to skip that insured coveage details
--v_errormsg := 'policy no main-insured is cancelled in zmrage00';
--  DM_data_trans_gen.error_logs('TITDMGRNWDT2', c_fet_pol2.chdrnum, substr(v_errormsg, 1, 200));
		-- lv_err_chk := true;
		CONTINUE;
	END IF;
END IF;



-- To check for the coverages prod type '2951','3951'
select count(1) into lv_prod_cnt
from stagedbusr.itempf 
where itemtabl= 'TQ9GY'  
and itempfx = 'IT'
and Substr(Utl_Raw.Cast_To_Varchar2(Genarea),1,1) = 'C'
and substr(utl_raw.cast_to_varchar2(genarea),8,1) = '1'
and TRIM(itemitem) = r_fet_cov_det(i_idx).prodtyp;


if lv_prod_cnt <> 0 then --- c_fet_pol2.prodtyp in ('2951','3951') then

open  c_get_dprem (r_fet_cov_det(i_idx).chdrnum,r_fet_cov_det(i_idx).mbrno);
fetch c_get_dprem into lv_dprem;
close c_get_dprem;

end if;

insert into titdmgrnwdt2
values
(r_fet_cov_det(i_idx).chdrnum,
r_fet_cov_det(i_idx).mbrno,
r_fet_cov_det(i_idx).dpntno,
r_fet_cov_det(i_idx).prodtyp,
r_fet_cov_det(i_idx).hsuminsu,
nvl(lv_dprem,r_fet_cov_det(i_idx).aprem),
r_fet_cov_det(i_idx).zinstype,
r_fet_cov_det(i_idx).prodtyp02,
r_fet_cov_det(i_idx).ndrprem,
'ZMRHR00'
);



commit;

v_output_count := v_output_count + 1;

end loop;

exit when c_fet_cov_det%notfound;
end loop;
close c_fet_cov_det;



IF  not lv_err_chk  THEN

       temp_no := DM_data_trans_gen.control_log('P2_RECORDS', 'TITDMGRNWDT2', systimestamp, l_app_old, 'SUCCESS',
                      'S', v_input_count, v_output_count); 

ELSE

    temp_no := DM_data_trans_gen.control_log('P2_RECORDS', 'TITDMGRNWDT2', systimestamp, l_app_old, 'COMPLETED WITH ERROR',
                      'F', v_input_count, v_output_count);
END IF;


exception when others then

dbms_output.put_line('sqlerrm '||sqlerrm);
v_errormsg := v_errormsg
                          || ' '
                          || sqlerrm;
            stagedbusr2.DM_data_trans_gen.error_logs('ZMRHR00',lv_pol_no, substr(v_errormsg, 1, 200));


end dm_zmrhr_renew_det;

PROCEDURE dm_rnwasis_renew_det(p_array_size IN PLS_INTEGER DEFAULT 1000) IS
--- Cursor declaration

  /*  CURSOR c_fet_policy IS
    SELECT DISTINCT
        a.apcucd   chdrnum,
        a.icicd    insured_no,
        b.maturity_date,
        b.mbrno,
        b.zinsrole,
        b.clientno,
        NULL ins_age,
        b.zplancde
    FROM
        stagedbusr2.renew_as_is   a,
        trnh_ren_records          b
    WHERE
        a.apcucd = b.chdrnum
        AND lpad(a.icicd, 5, '00000') = b.mbrno;
      */  
        
 --- Below cursor is change to improve the performance       
/*    CURSOR c_fet_policy IS
    SELECT a.chdrnum, a.insured_no, a.maturity_date, a.mbrno, a.zinsrole, a.clientno, a.ins_age, a.zplancde, a.effdate,
            b.statcode   policy_stat_code,
        b.Zpoltdate  policy_cncl_date
    FROM Renew_as_is_p1 a left outer join policy_statcode b on a.chdrnum = b.chdrnum order by chdrnum,mbrno;        
*/  

    CURSOR c_fet_policy IS
    SELECT distinct a.chdrnum, a.insured_no, a.maturity_date, a.mbrno, a.zinsrole, a.clientno, a.ins_age, a.zplancde, a.effdate,
            b.statcode   policy_stat_code,
        b.Zpoltdate  policy_cncl_date,
        substr(p2.refnum, 1, 8) p1chdrnum,
        p2.refnum p2chdrnum
    FROM Renew_as_is_p1 a left outer join policy_statcode b on a.chdrnum = b.chdrnum
    left outer join stagedbusr2.titdmgmbrindp1 p1 on a.chdrnum = substr(p1.refnum, 1, 8)
    left outer join stagedbusr2.titdmgmbrindp2 p2 on a.chdrnum = p2.refnum
    order by chdrnum,mbrno;



 /*   CURSOR c_fet_cov_det IS
    SELECT
        refnum chdrnum,
        mbrno,
        dpntno,
        prodtyp,
        hsuminsu,
        zinstype,
        prodtyp02,
        ndrprem,
        aprem
    FROM
        p2_ren_records;*/
        
cursor c_fet_cov_det is
select distinct p2.refnum chdrnum, p2.mbrno,p2.dpntno,p2.Prodtyp,p2.hsuminsu,p2.zinstype,p2.prodtyp02,p2.ndrprem,p2.aprem
from stagedbusr2.Renew_as_is_p1 src,
     stagedbusr2.titdmgmbrindp2 p2
where src.chdrnum = p2.refnum
and src.mbrno = p2.mbrno
and src.effdate = p2.effdate
and (substr(src.mbrno,-2) = '01' or
    (substr(src.mbrno,-2) = '02' AND NOT EXISTS  (SELECT 1 FROM stagedbusr.itempf it WHERE p2.prodtyp= RTRIM(it.itemitem) AND it.itemtabl='TQ9GY'
                                      AND it.itempfx='IT' AND it.validflag='1' AND TRIM(substr(UTL_RAW.CAST_TO_VARCHAR2(it.genarea),1,5))='C'
                                      AND substr(UTL_RAW.CAST_TO_VARCHAR2(genarea),9,1)='Y')
                                      ));

    TYPE t_fet_policy IS
        TABLE OF c_fet_policy%rowtype;
    r_fet_policy       t_fet_policy;
    TYPE t_fet_cov_det IS
        TABLE OF c_fet_cov_det%rowtype;
    r_fet_cov_det      t_fet_cov_det;

--- local variable declaration
    lv_pol_no          stagedbusr2.zmrage00.agecucd%TYPE;
    lv_dprem           stagedbusr2.zmrhr00.hrcvva1%TYPE;
    lv_pol_indp1_chk   PLS_INTEGER := 0;
    lv_pol_indp2_chk   PLS_INTEGER := 0;
    lv_ren_to_date     VARCHAR2(25);
--lv_pol_cnt         pls_integer := 0;
    lv_main_cncl       PLS_INTEGER := 0;
    lv_zterm           stagedbusr2.titdmgrnwdt1.ztermflg%TYPE;
    lv_cnt             PLS_INTEGER;
    lv_busdate         stagedbusr.busdpf.busdate%TYPE;
    lv_pol_chk_cnt     NUMBER;
    v_errormsg         VARCHAR2(2000) := NULL;
    v_output_count     NUMBER;
    v_input_count      NUMBER;
    l_app_old          VARCHAR2(60) := NULL;
    temp_no            NUMBER;
    lv_err_chk         BOOLEAN := false;
    lv_typ             VARCHAR2(15);
    lv_pol_cnt         PLS_INTEGER;
    c_limit            PLS_INTEGER := p_array_size;
    rec_chk            number;
    
    
BEGIN
    dm_data_trans_gen.stg_starttime := systimestamp;
    SELECT
        busdate
    INTO lv_busdate
    FROM
        stagedbusr.busdpf
    WHERE
        company = 1;

    /*SELECT
        COUNT(1)
    INTO v_input_count
    FROM
        (
            SELECT DISTINCT
                a.apcucd   chdrnum,
                a.icicd    insured_no,
                b.maturity_date,
                b.mbrno,
                b.zinsrole,
                b.clientno,
                NULL ins_age,
                b.zplancde
            FROM
                stagedbusr2.renew_as_is   a,
                trnh_ren_records          b
            WHERE
                a.apcucd = b.chdrnum
                AND lpad(a.icicd, 5, '00000') = b.mbrno
        );*/
        
    SELECT
        COUNT(1)
    INTO v_input_count
    from stagedbusr2.renew_as_is;
    
--- Below changes to improve performance and minimize the temp views

Insert into Renew_as_is_p1
(select distinct src.apcucd Chdrnum,p1i.mbrno insured_no,p1.crdate maturity_date,trn.mbrno mbrno,trn.zinsrole zinsrole,trn.clientno,null ins_age,p1i.zplancde,
trn.effdate
from stagedbusr2.renew_as_is src,
     stagedbusr2.titdmgmbrindp1 p1,
     stagedbusr2.titdmgpoltrnh trn,
     stagedbusr2.titdmgmbrindp1 p1i
where substr(p1.refnum,1,8) = src.apcucd
and substr(p1.refnum,1,8) = trn.chdrnum
and substr(p1i.refnum,1,8) = trn.chdrnum
and substr(p1i.mbrno,-2) = src.icicd
and substr(trn.mbrno,-2) = p1i.mbrno
and to_date(trn.effdate,'yyyymmdd') = to_date(p1.effdate,'yyyymmdd')
and p1.client_category = '0'
and p1i.client_category = '1'
and p1.effdate = (select max(p1m.effdate) 
                   from titdmgmbrindp1 p1m 
                   where substr(p1m.refnum,1,8) = src.apcucd
                   and p1.client_category = p1m.client_category)---JD, This condition is required to get max?
);

v_output_count := 0;


    OPEN c_fet_policy;
    LOOP
        FETCH c_fet_policy BULK COLLECT INTO r_fet_policy LIMIT c_limit;
        FOR i_indx IN 1..r_fet_policy.count LOOP

/*for c_fet_policy in (select distinct  a.apcucd chdrnum,
                              a.icicd insured_no,
                              b.maturity_date, 
                              b.mbrno,
                              b.zinsrole,
                              b.clientno,
                              null ins_age,
                              b.zplancde
                    from stagedbusr2.renew_as_is a,
                         trnh_ren_records b
                    where a.apcucd = b.chdrnum
                    and lpad(A.icicd,5,'00000') = b.mbrno)*/
            lv_pol_no := r_fet_policy(i_indx).chdrnum;
            v_errormsg := 'Insertion into titdmgrnwdt1 ';
            BEGIN
            --- Code is changed to remove validataion check for zmrhr00 as part of HR-2
                SELECT
                    typ,
                    COUNT(1)
                INTO
                    lv_typ,
                    lv_pol_cnt
                FROM
                    (
           -- select 'v_zmrhr00' typ,count(chdrnum) pol_cnt
          --  from v_zmrhr00
          --  where chdrnum = c_fet_policy.chdrnum
          --  group by 'v_zmrhr00'
           -- union
                        SELECT
                            'asrf' typ,
                            COUNT(chdrnum) pol_cnt
                        FROM
                            asrf_rnw_dtrm
                        WHERE
                            chdrnum = r_fet_policy(i_indx).chdrnum
                        GROUP BY
                            'asrf'
                    )
                WHERE
                    pol_cnt > 0
                GROUP BY
                    typ;

            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;

            /*if nvl(lv_typ,'x') = 'v_zmrhr00' and nvl(lv_pol_cnt,0) > 0 then

              v_errormsg := 'policy no exists in v_zmrhr00';
              DM_data_trans_gen.error_logs('TITDMGRNWDT1', c_fet_policy.chdrnum, substr(v_errormsg, 1, 200));
              lv_err_chk := true;
              continue;

              elsif nvl(lv_typ,'x') = 'asrf' and nvl(lv_pol_cnt,0) > 0 then
              */

            IF nvl(lv_typ, 'x') = 'asrf' AND nvl(lv_pol_cnt, 0) > 0 THEN
                v_errormsg := 'policy no exists in asrf';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            END IF;
/*
            SELECT
                COUNT(1)
            INTO lv_pol_indp1_chk
            FROM
                stagedbusr2.titdmgmbrindp1
            WHERE
                substr(refnum, 1, 8) = r_fet_policy(i_indx).chdrnum;

            SELECT
                COUNT(1)
            INTO lv_pol_indp2_chk
            FROM
                stagedbusr2.titdmgmbrindp2
            WHERE
                substr(refnum, 1, 8) = r_fet_policy(i_indx).chdrnum;
*/
            SELECT
                COUNT(1)
            INTO lv_pol_cnt
            FROM
                stagedbusr2.renew_as_is
            WHERE
                apcucd = r_fet_policy(i_indx).chdrnum
                AND icicd = r_fet_policy(i_indx).insured_no;

            IF r_fet_policy(i_indx).p1chdrnum is null THEN
                v_errormsg := 'policy no doesnt exists in titdmgmbrindp1';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            ELSIF r_fet_policy(i_indx).p2chdrnum is null THEN
                v_errormsg := 'policy no doesnt exists in titdmgmbrindp2';
                dm_data_trans_gen.error_logs('TITDMGRNWDT2', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            ELSIF lv_pol_cnt > 1 THEN
                v_errormsg := 'Duplicate record in Renew_As_Is';
                dm_data_trans_gen.error_logs('TITDMGRNWDT2', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            END IF;

             if trim(r_fet_policy(i_indx).policy_stat_code) = 'CA' then
                    v_errormsg := 'policy no - '
                                  || r_fet_policy(i_indx).chdrnum  || ' Ins ' || r_fet_policy(i_indx).mbrno                
                                  || ' is already in cancelled status';
            
                    dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));
            
                    lv_err_chk := true;
                    CONTINUE;    
                elsif trim(r_fet_policy(i_indx).policy_cncl_date)  <> '99999999' then 
                    v_errormsg := 'policy no - '
                                  || r_fet_policy(i_indx).chdrnum  || ' Ins ' || r_fet_policy(i_indx).mbrno                 
                                  || ' has future dated cancellation transaction';
            
                    dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum, substr(v_errormsg, 1, 200));
            
                    lv_err_chk := true;
                    CONTINUE;     
                
                
             end if;
            

            IF r_fet_policy(i_indx).mbrno = '00002' THEN
                SELECT
                    COUNT(1)
                INTO lv_cnt
                FROM
                    stagedbusr2.zmrage00
                WHERE
                    substr(agecucd, 1, 8) = r_fet_policy(i_indx).chdrnum
                    AND substr(agecicd, - 2) = '01'
                    AND ( agedlcd IN (
                        'A1',
                        'A3'
                    )
                          --OR agetfce = 'A2'-- Letter code is not applicable for main insured
                          );

                IF lv_cnt > 0 THEN
                    lv_zterm := 'Y';
                ELSE
                    lv_zterm := NULL;
                END IF;

			ELSE

	
				lv_zterm := NULL;

            END IF;
            
            select count(1) into rec_chk 
            from stagedbusr2.titdmgrnwdt1
            where chdrnum = r_fet_policy(i_indx).chdrnum
            and mbrno = r_fet_policy(i_indx).mbrno;
            
            if rec_chk > 0 then
                v_errormsg := 'Policy Insured already exists in TITDMGRNWDT1';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_fet_policy(i_indx).chdrnum
                                                             || '-'
                                                             || r_fet_policy(i_indx).mbrno, substr(v_errormsg, 1, 200));
            
                lv_err_chk := true;
                CONTINUE; 
            
            
            end if;



            INSERT INTO stagedbusr2.titdmgrnwdt1 VALUES (
                r_fet_policy(i_indx).chdrnum,
                r_fet_policy(i_indx).mbrno,
                r_fet_policy(i_indx).maturity_date,
                to_number(to_char(add_months(to_date(to_date(r_fet_policy(i_indx).maturity_date, 'yyyymmdd')), 12) - 1, 'yyyymmdd'
                )),
    --lv_ren_to_date,
                NULL,---- ZALTRCDE
                lv_busdate,---- ZRNDTREG
                lv_busdate,---- ZRNDTAPP
                r_fet_policy(i_indx).zinsrole,
                r_fet_policy(i_indx).clientno,
                lv_zterm,--- ZTERMFLG
                r_fet_policy(i_indx).zplancde,
                NULL,-- ZRNDTRCD
                r_fet_policy(i_indx).ins_age,
                'RENEW_AS_IS'
            );

            l_app_old := r_fet_policy(i_indx).chdrnum;
            v_output_count := v_output_count + 1;
            COMMIT;
        END LOOP;

        EXIT WHEN c_fet_policy%notfound;
    END LOOP;

    CLOSE c_fet_policy;
    COMMIT;
    IF NOT lv_err_chk THEN
        temp_no := dm_data_trans_gen.control_log('RENEW_AS_IS', 'TITDMGRNWDT1', systimestamp, l_app_old, 'SUCCESS'
        ,
                              'S', v_input_count, v_output_count);
    ELSE
        temp_no := dm_data_trans_gen.control_log('RENEW_AS_IS', 'TITDMGRNWDT1', systimestamp, l_app_old, 'COMPLETED WITH ERROR'
        ,
                              'F', v_input_count, v_output_count);
    END IF;

    SELECT
        COUNT(1)
    INTO v_input_count
    FROM
        Renew_as_is_p1;

    v_output_count := 0;
    lv_err_chk := false;

/*for c_fet_pol2 in (select refnum chdrnum, 
                  mbrno,dpntno,prodtyp,hsuminsu,zinstype,prodtyp02,ndrprem,aprem
                  from p2_ren_records)
loop
*/
    OPEN c_fet_cov_det;
    LOOP
        FETCH c_fet_cov_det BULK COLLECT INTO r_fet_cov_det LIMIT c_limit;
        FOR i_indx IN 1..r_fet_cov_det.count LOOP
            lv_pol_no := r_fet_cov_det(i_indx).chdrnum;

--- To check whether renewal determination header has the policy number and insured details
--- If not, we shouldn't write records into detail table
            SELECT
                COUNT(1)
            INTO lv_pol_chk_cnt
            FROM
                stagedbusr2.titdmgrnwdt1
            WHERE
                chdrnum = r_fet_cov_det(i_indx).chdrnum
                AND mbrno = r_fet_cov_det(i_indx).mbrno;

            IF lv_pol_chk_cnt = 0 THEN
                v_errormsg := 'policy and member is not available in TITDMGRNWDT1';
                dm_data_trans_gen.error_logs('TITDMGRNWDT2', r_fet_cov_det(i_indx).chdrnum
                                                             || '-'
                                                             || r_fet_cov_det(i_indx).mbrno, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            END IF;

--- For un-named policy, only mbrno -00001 exists and it will be always in one file.
--- It cannot have main-insured in one file and other insured in other file.

            IF r_fet_cov_det(i_indx).mbrno = '00002' THEN
                SELECT
                    COUNT(1)
                INTO lv_main_cncl
                FROM
                    stagedbusr2.zmrage00
                WHERE
                    substr(agecucd, 1, 8) = lv_pol_no
                    AND substr(agecicd, - 2) = '01'
                    AND ( agedlcd IN (
                        'A1',
                        'A3'
                    )
                          --OR agetfce = 'A2' -- Letter code is not applicable for main insured
                          );

 -- IG doesn't contain the coverage details of secondary insured, if the main-insured is already cancelled in ZMRAGE00     

                IF lv_main_cncl > 0 THEN
            -- No need to error, Just need to skip that insured coveage details
            --v_errormsg := 'policy no main-insured is cancelled in zmrage00';
          --  DM_data_trans_gen.error_logs('TITDMGRNWDT2', c_fet_pol2.chdrnum, substr(v_errormsg, 1, 200));
                   --  lv_err_chk := true;
                    CONTINUE;
                END IF;
            END IF;

            INSERT INTO stagedbusr2.titdmgrnwdt2 VALUES (
                r_fet_cov_det(i_indx).chdrnum,
                r_fet_cov_det(i_indx).mbrno,
                r_fet_cov_det(i_indx).dpntno,
                r_fet_cov_det(i_indx).prodtyp,
                r_fet_cov_det(i_indx).hsuminsu,
                r_fet_cov_det(i_indx).aprem,
                r_fet_cov_det(i_indx).zinstype,
                r_fet_cov_det(i_indx).prodtyp02,
                r_fet_cov_det(i_indx).ndrprem,
                'RENEW_AS_IS'
            );

            l_app_old := r_fet_cov_det(i_indx).chdrnum;
            v_output_count := v_output_count + 1;
            COMMIT;
        END LOOP;

        EXIT WHEN c_fet_cov_det%notfound;
    END LOOP;

    CLOSE c_fet_cov_det;
    IF NOT lv_err_chk THEN
        temp_no := dm_data_trans_gen.control_log('RENEW_AS_IS_P1', 'TITDMGRNWDT2', systimestamp, l_app_old, 'SUCCESS',
                              'S', v_input_count, v_output_count);
    ELSE
        temp_no := dm_data_trans_gen.control_log('RENEW_AS_IS_P1', 'TITDMGRNWDT2', systimestamp, l_app_old, 'COMPLETED WITH ERROR'
        ,
                              'F', v_input_count, v_output_count);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('sqlerrm ' || sqlerrm);
        v_errormsg := v_errormsg
                      || ' '
                      || sqlerrm;
        stagedbusr2.dm_data_trans_gen.error_logs('RENEW_AS_IS', lv_pol_no, substr(v_errormsg, 1, 200));


END dm_rnwasis_renew_det;


PROCEDURE dm_asrf_renew_det (
    p_array_size IN PLS_INTEGER DEFAULT 1000
) IS

-- cursor declaration

    CURSOR c_get_asrf_dets IS
    SELECT DISTINCT
        ard.chdrnum,
        decode(ard.cancelcode, 'Q1', 'Q01', 'Q3', 'Q03') cancelcode,
        --ard.kana_full_name,
        mp.maxapcucd   maxpolnum,
        zmis.isbtig    ris_kananame,
        substr(zmis.iscicd, - 1) ins_no,
        ps.statcode   policy_stat_code,
        ps.Zpoltdate  policy_cncl_date
    FROM
        asrf_rnw_dtrm   ard
        JOIN maxpolnum       mp ON substr(ard.chdrnum, 1, 8) = mp.apcucd
        LEFT OUTER JOIN zmris00         zmis ON
--trim(ard.kana_full_name) = trim(zmis.isbtig) and 
         mp.maxapcucd = zmis.iscucd
        LEFT OUTER JOIN policy_statcode ps on ard.chdrnum = ps.chdrnum;

    CURSOR c_ins_asrf IS
    SELECT
        chdrnum,
        ins_number,
        asrf_code,
        maturity_date,
        COUNT(1) OVER(
            PARTITION BY chdrnum
        ) cnt_rec
    FROM
        stagedbusr2.asrf_rnw_intermediate
    ORDER BY
        chdrnum,
        ins_number;

    CURSOR c_get_insur_role (
        cp_chdrnum   persnl_clnt_flg.apcucd%TYPE,
        cp_ins_no    CHAR
    ) IS
    SELECT DISTINCT
        substr(pcf.insur_role, - 1) insur_role,
        cm.stageclntno stg_clntnum
    FROM
        persnl_clnt_flg   pcf,
        titdmgclntmap     cm
    WHERE
        substr(pcf.apcucd, 1, 8) = cp_chdrnum
        AND cm.refnum = pcf.stg_clntnum
        AND pcf.insur_typ = 'I'
        AND substr(pcf.iscicd, - 2, length(pcf.iscicd)) = '0' || cp_ins_no
        AND pcf.isa4st IS NOT NULL;



-- variable declaration

    TYPE t_get_asrf_dets IS
        TABLE OF c_get_asrf_dets%rowtype;
    r_get_asrf_dets   t_get_asrf_dets;
    TYPE t_ins_asrf IS
        TABLE OF c_ins_asrf%rowtype;
    r_ins_asrf        t_ins_asrf;
    v_errormsg        VARCHAR2(2000) := NULL;
    lv_pol_no         stagedbusr2.zmrage00.agecucd%TYPE;
    lv_typ            VARCHAR2(10);
    lv_pol_cnt        NUMBER := 0;
    lv_maturity_dt    NUMBER(8);
    lv_ins_no         CHAR(1);
    lv_busdate        stagedbusr.busdpf.busdate%TYPE;
    lv_main_det_cde   CHAR(3);
    lv_sec_det_cde    CHAR(3);
    lv_alt_cde        CHAR(3);
    lv_ins_role       stagedbusr2.titdmgrnwdt1.zinsrole%TYPE;
    lv_stg_clntnum    VARCHAR2(15 CHAR);
    lv_pol2_cnt       NUMBER;
    v_output_count    NUMBER;
    v_input_count     NUMBER;
    l_app_old         VARCHAR2(60) := NULL;
    temp_no           NUMBER;
    lv_err_chk        BOOLEAN := false;
    c_limit           PLS_INTEGER := p_array_size;
    rec_chk           number;
    
    
BEGIN
    dm_data_trans_gen.stg_starttime := systimestamp;

--- Setting up the business date
    SELECT
        busdate
    INTO lv_busdate
    FROM
        stagedbusr.busdpf
    WHERE
        company = 1;
		
	
v_output_count := 0;
	

-- below cursor has been changed for the Requirement AS-1
-- To remove the kana full name from the ASRF file

--- Refactor to set with collections

/*   for c_get_asrf_dets in (select distinct ard.chdrnum, 
                          decode(ard.cancelcode,'Q1','Q01','Q3','Q03') cancelcode,
                          ard.kana_full_name,
                          mp.maxapcucd maxpolnum
                          ,zmis.isbtig ris_kananame
                          ,substr(zmis.iscicd,-1) ins_no
                          from asrf_rnw_dtrm ard 
                          join maxpolnum mp on substr(ard.chdrnum,1,8) = mp.Apcucd
                          left outer join zmris00 zmis on
                          --trim(ard.kana_full_name) = trim(zmis.isbtig) 
                          and  mp.maxapcucd = zmis.iscucd) */

    OPEN c_get_asrf_dets;
    LOOP
        FETCH c_get_asrf_dets BULK COLLECT INTO r_get_asrf_dets LIMIT c_limit;
        FOR l_apindx IN 1..r_get_asrf_dets.count LOOP


                        --- Below code to check if the same policy number exists in anyother files, then validate it
            BEGIN
                SELECT
                    typ,
                    COUNT(1)
                INTO
                    lv_typ,
                    lv_pol_cnt
                FROM
                    (
                        SELECT
                            'zmrhr00' typ,
                            COUNT(substr(HRCUCD, 1, 8)) pol_cnt
                        FROM
                            zmrhr00
                        WHERE
                            substr(HRCUCD,1,8) = r_get_asrf_dets(l_apindx).chdrnum
                        GROUP BY
                            'zmrhr00'
                        UNION
                        SELECT
                            'zmrage00' typ,
                            COUNT(substr(agecucd, 1, 8)) pol_cnt
                        FROM
                            zmrage00
                        WHERE
                            substr(agecucd, 1, 8) = r_get_asrf_dets(l_apindx).chdrnum
                        GROUP BY
                            'zmrage00'
                        UNION
                        SELECT
                            'renew_As_is' typ,
                            COUNT(apcucd) pol_cnt
                        FROM
                            renew_as_is
                        WHERE
                            apcucd = r_get_asrf_dets(l_apindx).chdrnum
                        GROUP BY
                            'renew_As_is'
                    )
                WHERE
                    pol_cnt > 0
                    and rownum < 2
                GROUP BY
                    typ;

            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;

            IF lv_typ = 'zmrhr00' AND lv_pol_cnt > 0 THEN
                v_errormsg := 'policy no '
                              || r_get_asrf_dets(l_apindx).chdrnum
                              || ' exists in zmrhr00 file';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_get_asrf_dets(l_apindx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            ELSIF lv_typ = 'zmrage00' AND lv_pol_cnt > 0 THEN
                v_errormsg := 'policy no '
                              || r_get_asrf_dets(l_apindx).chdrnum
                              || ' exists in zmrage00 file';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_get_asrf_dets(l_apindx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            ELSIF lv_typ = 'renew_As_is' AND lv_pol_cnt > 0 THEN
                v_errormsg := 'policy no '
                              || r_get_asrf_dets(l_apindx).chdrnum
                              || ' exists in renew_As_is file';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_get_asrf_dets(l_apindx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            END IF;

            IF r_get_asrf_dets(l_apindx).ris_kananame IS NULL THEN
                v_errormsg := 'ASRF input not in ZMRIS00';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_get_asrf_dets(l_apindx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            END IF;

            
             if trim(r_get_asrf_dets(l_apindx).policy_stat_code) = 'CA' then
                    v_errormsg := 'policy no - '
                                  || r_get_asrf_dets(l_apindx).chdrnum  || ' Ins ' || r_get_asrf_dets(l_apindx).ins_no                
                                  || ' is already in cancelled status';
            
                    dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_get_asrf_dets(l_apindx).chdrnum, substr(v_errormsg, 1, 200));
            
                    lv_err_chk := true;
                    CONTINUE;    
                elsif trim(r_get_asrf_dets(l_apindx).policy_cncl_date)  <> '99999999' then 
                    v_errormsg := 'policy no - '
                                  || r_get_asrf_dets(l_apindx).chdrnum  || ' Ins ' || r_get_asrf_dets(l_apindx).ins_no                 
                                  || ' has future dated cancellation transaction';
            
                    dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_get_asrf_dets(l_apindx).chdrnum, substr(v_errormsg, 1, 200));
            
                    lv_err_chk := true;
                    CONTINUE;     
                
                
             end if;            
            

  --- AS-1, Since kana name is removed from ASRF, below code validation is not required.
  /*
  select count(1) into lv_pol_cnt 
  from zmris00 zmis
  where zmis.iscucd = c_get_asrf_dets.maxpolnum
  and trim(zmis.isbtig) = trim(c_get_asrf_dets.ris_kananame);

  if lv_pol_cnt > 1 then
      v_errormsg := 'ASRF input duplicate in ZMRIS00';
      DM_data_trans_gen.error_logs('TITDMGRNWDT1', c_get_asrf_dets.chdrnum, substr(v_errormsg, 1, 200));
     continue;
  end if;
  */

            BEGIN
                SELECT
                    zmrp.apbedt
                INTO lv_maturity_dt
                FROM
                    zmrap00 zmrp
                WHERE
                    zmrp.apcucd = r_get_asrf_dets(l_apindx).maxpolnum;

            EXCEPTION
                WHEN no_data_found THEN
                    v_errormsg := 'ASRF input not in ZMRAP00';
                    dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_get_asrf_dets(l_apindx).chdrnum, substr(v_errormsg, 1, 200));

                    lv_err_chk := true;
                    CONTINUE;
            END;

            IF lv_maturity_dt IS NULL THEN
                v_errormsg := 'maturity date is null in ZMRAP00';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_get_asrf_dets(l_apindx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            END IF;

            INSERT INTO stagedbusr2.asrf_rnw_intermediate VALUES (
                r_get_asrf_dets(l_apindx).chdrnum,
                r_get_asrf_dets(l_apindx).ins_no,
                r_get_asrf_dets(l_apindx).cancelcode,
                lv_maturity_dt
            );

-- AS-1 Below code is no more required, as the main cursor has both the insured information.
/*

            dbms_output.put_line('c_get_asrf_dets.maxpolnum '||c_get_asrf_dets.maxpolnum);
            dbms_output.put_line('c_get_asrf_dets.ins_no '||c_get_asrf_dets.ins_no);

            Check if there is another insured in ZMRIS00 for Given policy. 
              if exists, we need to insert record for that Insured in   ASRF_RNW_INTERMEDIATE.

              select substr(zmis.iscicd,-1) into lv_ins_no
              from zmris00 zmis
              where zmis.iscucd = c_get_asrf_dets.maxpolnum
              and substr(zmis.Iscicd,-2) <> '0'||c_get_asrf_dets.ins_no;

              dbms_output.put_line('lv_ins_no '||lv_ins_no);

              if lv_ins_no is not null then

                        insert into stagedbusr2.asrf_rnw_intermediate
                        values (c_get_asrf_dets.chdrnum,lv_ins_no,null,lv_maturity_dt);  
                          end if;
*/

            COMMIT;
        END LOOP;

        EXIT WHEN c_get_asrf_dets%notfound;
    END LOOP;

    CLOSE c_get_asrf_dets;
    COMMIT;
    SELECT
        COUNT(1)
    INTO v_input_count
    FROM
        stagedbusr2.asrf_rnw_intermediate;

    OPEN c_ins_asrf;
    FETCH c_ins_asrf BULK COLLECT INTO r_ins_asrf LIMIT c_limit;
    LOOP
        FOR l_apindx IN 1..r_ins_asrf.count LOOP 
/*    FOR c_ins_asrf IN (
        SELECT
            chdrnum,
            ins_number,
            asrf_code,
            maturity_date,
            COUNT(1) OVER(
                PARTITION BY chdrnum
            ) cnt_rec
        FROM
            stagedbusr2.asrf_rnw_intermediate
        ORDER BY
            chdrnum,
            ins_number
    ) LOOP
	*/
            IF nvl(lv_pol_no, 'x') <> r_ins_asrf(l_apindx).chdrnum THEN
                lv_main_det_cde := NULL;
                lv_sec_det_cde := NULL;
            END IF;

            lv_pol_no := r_ins_asrf(l_apindx).chdrnum;
            SELECT
                COUNT(1)
            INTO lv_pol2_cnt
            FROM
                asrf_rnw_intermediate
            WHERE
                chdrnum = r_ins_asrf(l_apindx).chdrnum
                AND ins_number = r_ins_asrf(l_apindx).ins_number;

            IF lv_pol2_cnt > 1 THEN
                v_errormsg := ' Duplicate record in ASRF_RNW_INTERMEDIATE';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_ins_asrf(l_apindx).chdrnum, substr(v_errormsg, 1, 200));

                lv_err_chk := true;
                CONTINUE;
            END IF;

            OPEN c_get_insur_role(lv_pol_no, r_ins_asrf(l_apindx).ins_number);
            FETCH c_get_insur_role INTO
                lv_ins_role,
                lv_stg_clntnum;
            CLOSE c_get_insur_role;
            
            select count(1) into rec_chk
            from stagedbusr2.titdmgrnwdt1
            where chdrnum = r_ins_asrf(l_apindx).chdrnum
            and mbrno = '0000' || r_ins_asrf(l_apindx).ins_number;
            
            if rec_chk > 0 then
                v_errormsg := 'Policy Insured already exists in TITDMGRNWDT1';
                dm_data_trans_gen.error_logs('TITDMGRNWDT1', r_ins_asrf(l_apindx).chdrnum
                                                             || '-'
                                                             || '0000' || r_ins_asrf(l_apindx).ins_number, substr(v_errormsg, 1, 200));
            
                lv_err_chk := true;
                CONTINUE; 
            
            
            end if;            
            
            INSERT INTO stagedbusr2.titdmgrnwdt1 VALUES (
                r_ins_asrf(l_apindx).chdrnum,
                '0000' || r_ins_asrf(l_apindx).ins_number,
                r_ins_asrf(l_apindx).maturity_date,
                to_number(to_char(add_months(to_date(to_date(r_ins_asrf(l_apindx).maturity_date, 'yyyymmdd')), 12) - 1, 'yyyymmdd'
                )),
                r_ins_asrf(l_apindx).asrf_code, ---NULL,
                lv_busdate,
                lv_busdate,
                lv_ins_role,
                lv_stg_clntnum,
                'Y',
                ' ',
                r_ins_asrf(l_apindx).asrf_code,
                NULL,
                'ASRF_RNW_DTRM'
            );

	--- Set the alteration code
		/*Below set of code is no more valid, as the cancellation code 
		will be same for both the insured as per AS-1. Hence it has the same alteration code.*/

		/*
        IF c_ins_asrf.ins_number = 1 THEN
            lv_main_det_cde := c_ins_asrf.asrf_code;
        ELSIF c_ins_asrf.ins_number = 2 THEN
            lv_sec_det_cde := c_ins_asrf.asrf_code;
        END IF;

        IF c_ins_asrf.cnt_rec = 1 THEN
            IF lv_main_det_cde = 'Q01' THEN
                lv_alt_cde := 'Q01';
            ELSIF lv_main_det_cde = 'Q03' THEN
                lv_alt_cde := 'Q03';
            END IF;

            IF lv_sec_det_cde = 'Q01' THEN
                lv_alt_cde := 'Q01';
            ELSIF lv_sec_det_cde = 'Q03' THEN
                lv_alt_cde := 'Q03';
            END IF;

            UPDATE stagedbusr2.titdmgrnwdt1
            SET
                zaltrcde = lv_alt_cde
            WHERE
                chdrnum = c_ins_asrf.chdrnum;

        ELSIF c_ins_asrf.cnt_rec = 2 AND c_ins_asrf.ins_number = 2 THEN
            IF lv_main_det_cde IS NULL AND lv_sec_det_cde IN (
                'Q01',
                'Q03'
            ) THEN
                lv_alt_cde := lv_sec_det_cde;
            ELSIF lv_main_det_cde IN (
                'Q01',
                'Q03'
            ) THEN
                lv_alt_cde := lv_main_det_cde;
            END IF;

            UPDATE stagedbusr2.titdmgrnwdt1
            SET
                zaltrcde = lv_alt_cde
            WHERE
                chdrnum = c_ins_asrf.chdrnum;

        END IF;
		*/

            v_output_count := v_output_count + 1;
            l_app_old := r_ins_asrf(l_apindx).chdrnum;
            COMMIT;
        END LOOP;

        EXIT WHEN c_ins_asrf%notfound;
    END LOOP;

    CLOSE c_ins_asrf;
    COMMIT;
    IF NOT lv_err_chk THEN
        temp_no := dm_data_trans_gen.control_log('ASRF_RNW_INTERMEDIATE', 'TITDMGRNWDT1', systimestamp, l_app_old, 'SUCCESS',
                              'S', v_input_count, v_output_count);
    ELSE
        temp_no := dm_data_trans_gen.control_log('ASRF_RNW_INTERMEDIATE', 'TITDMGRNWDT1', systimestamp, l_app_old, 'COMPLETED WITH ERROR'
        ,
                              'F', v_input_count, v_output_count);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('sqlerrm ' || sqlerrm);
        v_errormsg := v_errormsg
                      || ' '
                      || sqlerrm;
        stagedbusr2.dm_data_trans_gen.error_logs('RENEW_AS_IS', lv_pol_no, substr(v_errormsg, 1, 200));

END dm_asrf_renew_det;



end dm_data_trans_renew_det;

/

