create or replace PROCEDURE          "BQ9UX_BL01_REFUNDBL" ( i_scheduleName  IN VARCHAR2, 
																		i_scheduleNumber IN VARCHAR2, 
																		i_zprvaldYN      IN VARCHAR2, 
																		i_company        IN VARCHAR2, 
																		i_userProfile    IN VARCHAR2, 
																		i_branch         IN VARCHAR2, 
																		i_transCode      IN VARCHAR2,
																		i_vrcmtime		   IN NUMBER,
																		i_vrcmuser		   IN NUMBER,																
																		i_acctYear       IN NUMBER, 
																		i_acctMonth      IN NUMBER, 
																		i_vrcmTermid     IN VARCHAR2,
																		i_array_size     IN PLS_INTEGER DEFAULT 1000,
																		start_id         IN NUMBER,
																		end_id           IN NUMBER) 
		AUTHID current_user AS 
		/*************************************************************************************************** 
		* Amendment History: RF01 Billing Refund 
		* Date    Initials   Tag   Decription 
		* -----   ---------  ----  ---------------------------------------------------------------------------- 
		* MMMDD   XXX   		 RF0   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
		* JUL14   SRI   		 RF1   PA New Implementation
        * FEB22   PRABU          RF2   ITR3 FT code fixes
		* FEB26	  PRABU			 RF3   ITR3 FT Data validation issues fix
		* JUN28   PRABU			 RF4   Changes for ZJNPG-9739, included RJ transactions and added prevalidation checks for cursor 3 and 4
        * JUL7    PRABU          RF5   ZJNPG-9739, Adding the registry table into the cursor
		* NOV1 	  PRABU			 RF6   ZJNPG-10039, Bank key format should be 4 digit bankcode + 3 spaces + 3 digit branch code for proper display in IG
		* NOV1	  PRABU			 RF7   ZJNPG-10060,  Duplicate records are inserted because of incorrect joining in cursor	
		* DEC21   PRABU          RF8   ZJNPG-10273, Fixing for the bankkey value
		* MAR22   PRABU			 RF9   ZJNPG-10039,  set the bank key value from clbapf table
		*******************************************************************************************************/ 
		-- Local Variables Declaration for Billing Refund START ------------ 
		v_timestart 		    NUMBER := dbms_utility.get_time; 
		v_recidxrefb1 		  NUMBER(38,0);
		v_recidxrefb3		    NUMBER(38,0);
		v_refnum 			      VARCHAR2(15 CHAR); 
		v_refnum1 			    VARCHAR2(15 CHAR); 
		v_refnum2			      VARCHAR2(15 CHAR); 
		v_refnum3			      VARCHAR2(15 CHAR); 
		v_chdrnum1 			    VARCHAR2(8 CHAR); 
    v_chdrnm1 			    VARCHAR2(8 CHAR);
		v_zrefmtcd1 		    VARCHAR2(3 CHAR); 
		v_effdate 			    NUMBER(8,0); 
		v_prbilfdt 			    NUMBER(8,0); 
		v_prbiltdt 			    NUMBER(8,0); 
		v_zposbdsm 			    NUMBER(2,0); 
		v_zposbdsy 			    NUMBER(4,0); 
		v_zaltrcde01 		    VARCHAR2(4 CHAR); 
		v_m_zaltrcde01 		  VARCHAR2(4 CHAR);
		v_zrefundbe 		    NUMBER(17,2); 
		v_zrefundbz 		    NUMBER(17,2); 
		v_zenrfdst 			    VARCHAR2(2 CHAR); 
		v_zzhrfdst 			    VARCHAR2(2 CHAR); 
		v_bankkey 			    VARCHAR2(10 CHAR); 
		v_bankacount 		    VARCHAR2(20 CHAR); 
    v_bankacountkey 		VARCHAR2(20 CHAR);
		v_bankaccdsc 		    VARCHAR2(30 CHAR); 
		v_bnkactyp 			    VARCHAR2(4 CHAR); 
		v_zrqbkrdf 			    VARCHAR2(1 CHAR); 
		v_reqdate			      NUMBER(8,0); 
		v_paydate 			    NUMBER(8,0); 
		v_rdocpfx 			    VARCHAR2(2 CHAR); 
		v_rdoccoy 			    VARCHAR2(1 CHAR); 
		v_rdocnum 			    VARCHAR2(8 CHAR);
    v_nrflg             VARCHAR2(1 CHAR);
		v_recidxrefb2 		  NUMBER(38,0); 
		v_trrefnum2 		    VARCHAR2(15 CHAR); 
		v_trrefnum3 		    VARCHAR2(15 CHAR);
		v_chdrnum2 			    VARCHAR2(8 CHAR); 
		v_chdrnum3 			    VARCHAR2(8 CHAR);
		v_zreflist			    VARCHAR2(1 CHAR);
		v_zrefmtcd2 		    VARCHAR2(3 CHAR); 
		v_zrefmtcd3 		    VARCHAR2(3 CHAR);
		v_prodtyp2 			    VARCHAR2(4 CHAR); 
		v_prodtyp3 			    VARCHAR2(4 CHAR); 
		v_mbrno2       		  CHAR(5 CHAR); 
		v_dpntno2      		  CHAR(2 CHAR);
		v_mbrno3       		  CHAR(5 CHAR); 
		v_dpntno3      		  CHAR(2 CHAR);
		v_bprem2 			      NUMBER(15,2); 	  
		v_bprem3 			      NUMBER(15,2); 	
		temp_val 			      NUMBER DEFAULT 0; 
		isDateValid        	VARCHAR2(20 CHAR); 
		b_isNoError1       	BOOLEAN := TRUE; 
		b_isNoError2       	BOOLEAN := TRUE; 
		b_isNoError3       	BOOLEAN := TRUE; 
		n_isValid          	NUMBER(1) DEFAULT 0; 
		isDuplicate        	NUMBER(1) DEFAULT 0; 
		v_code             	NUMBER; 
		v_errm             	VARCHAR2(64 CHAR); 
		v_errorCount1      	NUMBER(1) DEFAULT 0; 
		v_errorCount2      	NUMBER(1) DEFAULT 0; 
		v_zsalplan         	VARCHAR2(30 CHAR); 
		v_tableNametemp    	VARCHAR2(10); 
		v_tableName        	VARCHAR2(10); 
		v_temp_billno      	VARCHAR2(20); 
		v_isagentExists    	NUMBER(1) DEFAULT 0; 
		C_RECORDSKIPPED    	CONSTANT VARCHAR2(17) := 'Record skipped'; 
		C_RECORDSUCCESS    	CONSTANT VARCHAR2(20) := 'Record successful'; 
		C_SUCCESS          	CONSTANT VARCHAR2(3)  := 'S'; 
		C_ERROR            	CONSTANT VARCHAR2(3)  := 'E'; 
		b_globalError      	BOOLEAN               := TRUE; 
		b_memberpolicyFlag 	BOOLEAN               := FALSE; 
		b_convertedindpol  	BOOLEAN               := FALSE; 
		b_indpolicyFlag    	BOOLEAN               := FALSE; 
		b_zreppfFlag       	BOOLEAN               := FALSE; 
		n_cmrate           	NUMBER(3); 
		n_check            	NUMBER(1) DEFAULT 0; 
		n_new              	NUMBER(1) DEFAULT 0; 
		v_maxdate          	CONSTANT VARCHAR2(10) := '99999999'; 
		i_chdrnum          	VARCHAR2(10); 
		temp_zreppf        	VARCHAR2(100); 
		v_trano        		  NUMBER(5,0); 
		temp_cmrate        	NUMBER(38, 2) DEFAULT 0; 
		tempGagntsel       	VARCHAR2(200); 
		tempZagptnum       	VARCHAR2(200); 
		temp_effdate       	VARCHAR2(10); 
		temp_zagptnum      	VARCHAR2(10); 
		temp_zcmpcode      	VARCHAR2(10); 
		temp_refKey1       	VARCHAR2(100 CHAR); 
		temp_refKey2       	VARCHAR2(100 CHAR); 
		temp_refKey3       	VARCHAR2(100 CHAR);
		V_TEMP_KEY         	VARCHAR2(100 CHAR); 
		v_temp_key2         VARCHAR2(100 CHAR); 
		v_temp_key3         VARCHAR2(100 CHAR); 
		v_last_rowcnt     	NUMBER DEFAULT 0;
		C_limit             PLS_INTEGER := i_array_size;
		p_exitcode         	NUMBER;	
		p_exittext         	VARCHAR2(2000);		
		-- Local Variables Declaration for Billing Refund END ------------  
		  
		--  Default Values from DMDEFVALPF START--- 
		
		v_last_rowcnt 		  NUMBER DEFAULT 0; 
		zreduplicate  		  NUMBER DEFAULT 0; 
		
		--  Default Values from DMDEFVALPF END--- 
		  
		------Define Constant -------------------- 
		C_prefix CONSTANT VARCHAR2(2) := Jd1dta.GET_MIGRATION_PREFIX('RFBL', i_company); 
		C_BQ9UX CONSTANT VARCHAR2(5)  := 'BQ9UX'; 
		C_TR338 CONSTANT VARCHAR2(6)  := 'TR338'; -- CHECK IF BANKACCUNT TYPE IS EXIST IN T - TABLE : TR338 or not
		C_TQ9G7 CONSTANT VARCHAR2(6)  := 'TQ9G7'; -- T-Table for Refund Method Check
		C_TQ9NW CONSTANT VARCHAR2(6)  := 'TQ9NW'; -- Endorser or Jdrich STATUS must be valid in TQ9NW
		C_T9797 CONSTANT VARCHAR2(6)  := 'T9797'; -- Check IF PRODTYP is Valid in T9797 or not
		C_Z004  CONSTANT VARCHAR2(5)  := 'RQLK'; -- Input file 2 does not exist 
		C_Z113  CONSTANT VARCHAR2(5)  := 'RQOJ'; -- Missing REFNUM 
		C_Z031  CONSTANT VARCHAR2(5)  := 'RQMB'; -- Pol is not yet migr   
		C_Z013  CONSTANT VARCHAR2(5)  := 'RQLT'; --Invalid Date 
		C_Z105  CONSTANT VARCHAR2(5)  := 'RQOB'; -- Must be valid in TQ9G7 
		C_Z106  CONSTANT VARCHAR2(5)  := 'RQOC'; -- Missing prem frm Endos 
		C_Z107  CONSTANT VARCHAR2(5)  := 'RQOD'; -- Missing prem from Jdrich 
		C_Z108  CONSTANT VARCHAR2(5)  := 'RQOE'; -- Must be valid in TQ9NW  
		C_Z109  CONSTANT VARCHAR2(5)  := 'RQOF'; --Invalid Bank Key 
		C_Z110  CONSTANT VARCHAR2(5)  := 'RQOG'; --Invalid Account Key 
		C_Z035  CONSTANT VARCHAR2(5)  := 'RQMF'; --Must be in TR383 
		C_Z028  CONSTANT VARCHAR2(5)  := 'RQM8'; --Must be Y or N 
		C_Z111  CONSTANT VARCHAR2(5)  := 'RQOH'; --PAYDATE >= TODAY 
		C_Z116  CONSTANT VARCHAR2(5)  := 'RQOM'; -- Missing RDOCPFX
		C_Z117  CONSTANT VARCHAR2(5)  := 'RQON'; --Missing RDOCCOY 
		C_Z117  CONSTANT VARCHAR2(5)  := 'RQOO'; --Missing RDOCNUM 
		C_Z119  CONSTANT VARCHAR2(5)  := 'RQOP'; --Missing PAYDATE
		C_Z112  CONSTANT VARCHAR2(5)  := 'RQOI'; --Refund Bill already migrated 
		C_Z014  CONSTANT VARCHAR2(5)  := 'RQLU'; --Product code not in T9797 
		C_Z023  CONSTANT VARCHAR2(5)  := 'RQM3'; --Invalid Agent Number 
		C_Z033  CONSTANT VARCHAR2(5)  := 'RQMD'; --Total Comm. rate must not exceed 100% 
		C_Z057  CONSTANT VARCHAR2(5)  := 'RQN1'; --Commission rate cannot be blank 
		C_Z074  CONSTANT VARCHAR2(5)  := 'RQNI'; --Agent Gross Premium must be provided 		
		C_Z132  CONSTANT VARCHAR2(5)  := 'RQWJ'; --Agnt not in Agcy Pattern 
		------Define Constant End----------------- 
		
		
		--------Null and spaces START-----------
		C_ZPBACNO 	CONSTANT VARCHAR2(8 CHAR)  := '       ';
		C_ZPBCODE	CONSTANT VARCHAR2(6 CHAR)    := '     ';
		C_ZPBCTYPE	CONSTANT VARCHAR2(4 CHAR)  := '    ';
		C_SUBSCOY	CONSTANT CHAR(1 CHAR)        := ' ';
		C_SUBSNUM 	CONSTANT CHAR(8 CHAR)      := '       ';
		C_MBRNO		CONSTANT CHAR(5 CHAR)        := ' ';-- null; -- RF3 Changes 
		C_ZSTPBLYN	CONSTANT VARCHAR2(1 CHAR)  := ' ';
		C_BATCBATCH	CONSTANT CHAR(5 CHAR)      := '     ';
		C_CLASSINS 	CONSTANT CHAR(2 CHAR)      := '  ';
		C_GSTCOM1	CONSTANT NUMBER(9,2)         := null;
		C_GSTCOM2	CONSTANT NUMBER(9,2)         := null;
		C_PPMCCOST	CONSTANT NUMBER(11,2)      := null;
		 
		--------Null and spaces END-----------
		
		
		
		--------------COMMON FUNCTION START--------- 
		o_defaultvalues 	          pkg_dm_common_operations.defaultvaluesmap; 
		itemexist 					        pkg_dm_common_operations.itemschec; 
		o_errortext 				        pkg_dm_common_operations.errordesc; 
		i_zdoe_info1 				        pkg_dm_common_operations.obj_zdoe; 
		i_zdoe_info2 				        pkg_dm_common_operations.obj_zdoe; 
		i_zdoe_info3 				        pkg_dm_common_operations.obj_zdoe; 
		i_zdoe_err_info2 			      pkg_dm_common_operations.obj_zdoe; 
		i_zdoe_err_info3 			      pkg_dm_common_operations.obj_zdoe; 
		i_zdoe_info_temp 			      pkg_dm_common_operations.obj_zdoe;  
		-- checkduplicate 				      pkg_common_dmbl.zdrfpftype;  --- Changes for RF5
		checkduplicateIntitdmgref2 	pkg_common_dmbl.titdmgref2; 
		refbilinfo 					        pkg_common_dmbl.refbilltype; 
		---------------COMMON FUNCTION END----------- 

		  ------IG table obj start--- 
		  
		  obj_VIEW_DM_ZREPPF Jd1dta.VIEW_DM_ZREPPF%rowtype; 
		  obj_VIEW_DM_ZREPPF_updated Jd1dta.VIEW_DM_ZREPPF%rowtype; 
		  obj_VIEW_DM_ZREPPF_l Jd1dta.VIEW_DM_ZREPPF%rowtype; 
		  obj_VIEW_DM_ZDRFPF Jd1dta.VIEW_DM_PAZDRFPF%rowtype;
		  obj_VIEW_DM_GBIHPF Jd1dta.VIEW_DM_GBIHPF%rowtype;
		  obj_VIEW_DM_GBIDPF Jd1dta.VIEW_DM_GBIDPF%rowtype;
		  obj_VIEW_DM_GPMDPF Jd1dta.VIEW_DM_GPMDPF%rowtype;
		  obj_VIEW_DM_ZRFDPF Jd1dta.VIEW_DM_ZRFDPF%rowtype;
		  ------IG table obj End--- 
		  
		--Temporary Variables--- 
		temp_cownnum 		     CHAR(8 CHAR);  
		temp_ptdate 		     NUMBER(8); 
		temp_btdate 		     NUMBER(8); 
		v_tranno1			       NUMBER(5,0);
		v_tranno2			       NUMBER(5,0);
		v_tranno3			       NUMBER(5,0);
		temp_zrefundam 		   NUMBER(17,2); 
		temp_zrefundam1 	   NUMBER(17,2); 
		update_zrefundam 	   NUMBER(17,2); 
		temp_zrefmtcd 		   VARCHAR2(3 CHAR); 
		update_zrefmtcd 	   VARCHAR2(3 CHAR); 
		temp_zrefundbe 		   NUMBER(17,2); 
		update_zrefundbe 	   NUMBER(17,2); 
		temp_zrefundbz 		   NUMBER(17,2); 
		update_zrefundbz 	   NUMBER(17,2); 
		temp_zenrfdst 		   VARCHAR2(2 CHAR); 
		update_zenrfdst 	   VARCHAR2(2 CHAR); 
		temp_zzhrfdst 		   VARCHAR2(2 CHAR); 
		update_zzhrfdst 	   VARCHAR2(2 CHAR); 
		temp_zrfdst_zenrfdst VARCHAR2(2 CHAR); 
		temp_zrfdst_zzhrfdst VARCHAR2(2 CHAR); 
		update_zrfdst 		   VARCHAR2(2 CHAR); 
		n_trdt 				       NUMBER(6,0); 
		gchp_zgporipcls 	   CHAR(8 CHAR); 
		gchp_zconvindpol 	   VARCHAR2(8 CHAR); 
		v_zcmpcode 			     VARCHAR2(6 CHAR); 		  
		v_zrefundbe_l 		   NUMBER(17,2); 
		v_zrefundbz_l 		   NUMBER(17,2); 
		v_zrefundam_l 		   NUMBER(17,2); 
		v_zrefmtcd_l 		     VARCHAR2(3 CHAR); 
		v_zenrfdst_l 		     VARCHAR2(2 CHAR); 
		v_zzhrfdst_l 		     VARCHAR2(2 CHAR); 
		v_zrfdst_l 			     VARCHAR2(2 CHAR); 
		v_rowcount 			     NUMBER DEFAULT 0; 
		b_zrefundam 		     NUMBER(17,2); 
		b_zrefmtcd 			     VARCHAR2(3 CHAR); 
		b_zrefundbe 		     NUMBER(17,2); 
		b_zrefundbz 		     NUMBER(17,2); 
		b_zenrfdst 			     VARCHAR2(2 CHAR); 
		b_zzhrfdst 			     VARCHAR2(2 CHAR); 
		v_zrefundam_r 		   VARCHAR2(3 CHAR); 
		v_zrefundam_u 		   VARCHAR2(3 CHAR); 
		v_UNIQ_GBIHPF       NUMBER(18,0);
    v_UNIQ_GBIDPF       NUMBER(18,0);
    v_UNIQ_GPMDPF       NUMBER(18,0);
    v_UNIQ_ZREPPF       NUMBER(18,0);
    v_UNIQ_ZRFDPF       NUMBER(18,0);
		
		--Error cont start 
		TYPE obj_zdoe 
		IS 
		RECORD 
		( 
			i_tablecnt  	    NUMBER(1), 
			i_tableName 	    VARCHAR2(10), 
			i_refKey 		      VARCHAR2(100 CHAR), 
			i_zfilename 	    VARCHAR2(20 CHAR), 
			i_indic 		      VARCHAR2(1 CHAR), 
			i_prefix 		      VARCHAR2(2), 
			i_scheduleno 	    NUMBER(8,0), 
			i_error01 		    VARCHAR2(4 CHAR), 
			i_errormsg01    	VARCHAR2(250 CHAR), 
			i_errorfield01 	  VARCHAR2(10 CHAR), 
			i_fieldvalue01 	  VARCHAR2(100 CHAR), 
			i_errorprogram01  VARCHAR2(10 CHAR)
		); 
		obj_error 		obj_zdoe; 
		type ercode_tab 
		IS 
			TABLE OF VARCHAR(4) INDEX BY BINARY_INTEGER; 
			t_ercode ercode_tab; 
			t_ercode2 ercode_tab; 
			t_ercode3 ercode_tab;
		type errorfield_tab 
		IS 
			TABLE OF VARCHAR(10) INDEX BY BINARY_INTEGER; 
			t_errorfield errorfield_tab; 
			t_errorfield2 errorfield_tab; 
			t_errorfield3 errorfield_tab; 
		type errormsg_tab 
		IS 
			TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER; 
			t_errormsg errormsg_tab; 
			t_errormsg2 errormsg_tab; 
			t_errormsg3 errormsg_tab; 
		type errorfieldvalue_tab 
		IS 
			TABLE OF VARCHAR(2000) INDEX BY BINARY_INTEGER; 
			t_errorfieldval errorfieldvalue_tab; 
			t_errorfieldval2 errorfieldvalue_tab; 
			t_errorfieldval3 errorfieldvalue_tab; 
		type errorprogram_tab 
		IS 
			TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER; 
			t_errorprogram errorprogram_tab; 
			t_errorprogram2 errorprogram_tab; 
			t_errorprogram3 errorprogram_tab; 
			idx PLS_INTEGER; 
			idx1 VARCHAR2(2000); 
		type error_type 
		IS 
			TABLE OF obj_zdoe; 
			error_list error_type := error_type(); 
			errindex INTEGER      := 0; 
		
		  
		type gbidpf_type 
		IS 
			TABLE OF GBIDPF%rowtype; 
			gbidpf_list gbidpf_type := gbidpf_type(); 
			gbidpfindex INTEGER     := 0; 
			
		type gpmdpf_type 
		IS 
			TABLE OF GPMDPF%rowtype; 
			gpmdpf_list gpmdpf_type := gpmdpf_type(); 
			gpmdpfindex INTEGER     := 0; 

		TYPE zreppfarr_type 
		IS 
			TABLE OF ZREPPF%rowtype INDEX BY VARCHAR2(50); 
			zreppfarr_list1 zreppfarr_type; 
			zreppfarrindex INTEGER := 0;  
		
		--  Define a Cursor to read StageDB TITDMGREF1 -----------------
		-- Rf6 Changes on BANKACCKEY column as per IG expectation
		-- RF8 Trim the bank key value incase of null values 
		-- RF9 changes
		CURSOR refundBills_cursor1 
		IS 
			SELECT distinct A.*, B.CHDRNUM AS CHDRNM, 
            --trim(substr(trim(C.BANKACCKEY),1,4)||lpad(' ',3)||substr(trim(C.BANKACCKEY),-3)) AS BANKACCKEY, 
            trim(C.BANKKEY) AS BANKACCKEY,
            mig.chdrnum mig_pol 
            FROM Jd1dta.DMIGTITDMGREF1 A 
      LEFT OUTER JOIN Jd1dta.GCHD B ON A.CHDRNUM = B.CHDRNUM AND TRIM(B.CHDRCOY) = i_company
      LEFT OUTER JOIN Jd1dta.CLBAPF C on TRIM(A.BANKACOUNT) = TRIM(C.BANKACCKEY) AND TRIM(B.COWNNUM) = TRIM(C.CLNTNUM)
                                        AND trim(A.BANKKEY) = TRIM(replace(C.BANKKEY,'   ','')) 
      LEFT OUTER JOIN Jd1dta.PAZDRFPF mig ON mig.chdrnum = a.chdrnum
			WHERE A.REFNUMCHUNK between start_id and end_id
			ORDER BY A.CHDRNUM ASC,              
			to_number(A.REFNUM) ASC,            
			a.ZREFMTCD ASC;                    
		obj_refundBills1 refundBills_cursor1%rowtype; 
		 
		type t_refund_list1 is table of refundBills_cursor1%rowtype;
		refund_list1 t_refund_list1;
		
		-- Define a Cursor to read StageDB TITDMGREF2 --------------------
        -----RF2 ITR3 code fix to make a left outer join to execute for pre-validation time
		-- RF7 Below cursor is changed to fetch distinct records of refunds
		CURSOR refundBills_cursor2 
		IS 
			SELECT DISTINCT A.*,  B.ZIGVALUE 
			FROM Jd1dta.DMIGTITDMGREF2 A 
			LEFT OUTER JOIN Jd1dta.PAZDRFPF B on TRIM(A.CHDRNUM) = TRIM(B.CHDRNUM) AND TRIM(A.TRREFNUM)=TRIM(B.ZENTITY)
											 AND TRIM(A.ZREFMTCD) = TRIM(B.ZREFMTCD)
			WHERE REFNUMCHUNK between start_id and end_id 
			order by A.chdrnum asc, to_number(A.trrefnum) asc;            
		obj_refundBills2 refundBills_cursor2%rowtype; 
		
		type t_refund_list2 is table of refundBills_cursor2%rowtype;
		refund_list2 t_refund_list2;
		--RF2 ITR3 code fix to make a left outer join to execute for pre-validation time
		-- RF7 Below cursor is changed to fetch distinct records of refunds
		CURSOR refundBills_cursor3
		IS
		SELECT DISTINCT A.CHDRNUM, A.TRANNO, B.ZIGVALUE, A.PRODTYP, SUM(A.BPREM) BPREM
		FROM Jd1dta.DMIGTITDMGREF2 A
		LEFT OUTER JOIN Jd1dta.PAZDRFPF B
		ON TRIM(A.CHDRNUM) = TRIM(B.CHDRNUM)
		AND TRIM(A.TRREFNUM) = TRIM(B.ZENTITY)
				AND TRIM(A.ZREFMTCD) = TRIM(B.ZREFMTCD)
		WHERE REFNUMCHUNK between start_id and end_id 
		GROUP BY A.chdrnum, A.TRANNO, B.ZIGVALUE, A.PRODTYP
		ORDER BY A.chdrnum, A.TRANNO, B.ZIGVALUE, A.PRODTYP;
		
		obj_refundBills3 refundBills_cursor3%rowtype;  
		
		type t_refund_list3 is table of refundBills_cursor3%rowtype;
		refund_list3 t_refund_list3;

		BEGIN 
			---------COMMON FUNCTION CALLING START------------ 
			pkg_dm_common_operations.getdefval(i_module_name   => C_BQ9UX, o_defaultvalues => o_defaultvalues);
			pkg_dm_common_operations.checkitemexist(i_module_name => 'DMRF', itemexist => itemexist);
			pkg_dm_common_operations.geterrordesc(i_module_name => 'DMRF', o_errortext => o_errortext); 
			v_tableNametemp := 'ZDOE' || TRIM(C_prefix) || LPAD(TRIM(i_scheduleNumber), 4, '0'); 
			v_tableName     := TRIM(v_tableNametemp);
	--		pkg_dm_common_operations.createzdoepf(i_tablename => v_tableName); 	
	--		pkg_common_dmbl.checkduplicate(checkduplicate => checkduplicate);  -- changes for RF5
			pkg_common_dmbl.checkduplicateIntitdmgref2(checkduplicateIntitdmgref2 => checkduplicateIntitdmgref2);
			pkg_common_dmbl.getrefundbillinfo(refbilinfo => refbilinfo);  
			  
			 --------------------------COMMON FUNCTION CALLING END----------------------------------------------------------------------- 
			  			  
			p_exitcode := 0;
			p_exittext := 'ERROR'; 

			
			--------------------- TRDT From BUSDPF ------------------------ 
			 
			SELECT TO_CHAR(to_date(BUSDATE, 'YYYYMMDD'), 'YYMMDD') 
			INTO n_trdt 
			FROM Jd1dta.BUSDPF 
			WHERE COMPANY = '1'; 
			
		  
			OPEN refundBills_cursor1; 

			LOOP 
				FETCH refundBills_cursor1 bulk collect INTO refund_list1 limit C_limit;
				-- dbms_output.put_line('bulk collect call');
			<<again_start>> --- RF2 Changes, This should be placed after the loop condition
				
				for i in 1 .. refund_list1.count loop
    
				obj_refundBills1 := refund_list1(i);
					
				v_recidxrefb1 			  	    := obj_refundBills1.RECIDXREFB1; 
				v_refnum1      			  	    := TRIM(obj_refundBills1.REFNUM); 
				v_chdrnum1    			  	    := TRIM(obj_refundBills1.CHDRNUM); 
        v_chdrnm1    			  	      := TRIM(obj_refundBills1.CHDRNM);
				v_rowcount    			  	    := refundBills_cursor1%rowcount;		
				v_zrefmtcd1               	:= TRIM(obj_refundBills1.ZREFMTCD); 
				v_effdate                 	:= obj_refundBills1.EFFDATE; 
				v_tranno1                 	:= obj_refundBills1.TRANNO;
				v_prbilfdt                	:= obj_refundBills1.PRBILFDT; 
				v_prbiltdt                	:= obj_refundBills1.PRBILTDT; 
				v_zposbdsm                	:= obj_refundBills1.ZPOSBDSM; 
				v_zposbdsy                	:= obj_refundBills1.ZPOSBDSY; 
				v_zrefundbe               	:= obj_refundBills1.ZREFUNDBE; 
				v_zrefundbz               	:= obj_refundBills1.ZREFUNDBZ; 
				v_zenrfdst                	:= TRIM(obj_refundBills1.ZENRFDST); 
				v_zzhrfdst                	:= TRIM(obj_refundBills1.ZZHRFDST); 
				v_bankkey                 	:= TRIM(obj_refundBills1.BANKACCKEY); --- TRIM(obj_refundBills1.BANKKEY); -- RF8 Changes
				v_bankacount              	:= TRIM(obj_refundBills1.BANKACOUNT); 
        v_bankacountkey             := TRIM(obj_refundBills1.BANKACCKEY);
				v_bankaccdsc              	:= TRIM(obj_refundBills1.BANKACCDSC); 
				v_bnkactyp                	:= TRIM(obj_refundBills1.BNKACTYP); 
				v_zrqbkrdf                	:= TRIM(obj_refundBills1.ZRQBKRDF); 
				v_reqdate                 	:= obj_refundBills1.REQDATE; 
				v_paydate                 	:= obj_refundBills1.PAYDATE; 
				v_rdocpfx                 	:= obj_refundBills1.RDOCPFX; 
				v_rdoccoy                 	:= obj_refundBills1.RDOCCOY; 
				v_rdocnum                 	:= obj_refundBills1.RDOCNUM; 
        v_nrflg                     := obj_refundBills1.NRFLAG;
				b_isNoError1              	:= TRUE; 
				b_isNoError2              	:= TRUE; 
				b_isNoError3              	:= TRUE;
				v_errorCount1             	:= 0; 
				isDuplicate               	:= 0; 
				b_memberpolicyFlag        	:= FALSE; 
				b_convertedindpol         	:= FALSE; 
				b_indpolicyFlag           	:= FALSE; 
				b_zreppfFlag              	:= FALSE; 
				t_ercode(1)               	:= NULL; 
				t_ercode(2)               	:= NULL; 
				t_ercode(3)               	:= NULL; 
				t_ercode(4)               	:= NULL; 
				t_ercode(5)               	:= NULL; 
				temp_refKey1              	:= ' '; 
				temp_refKey1              	:= (v_chdrnum1 || '_' || v_refnum1 || '_' || v_zrefmtcd1);
				i_zdoe_info1              	:= i_zdoe_info_temp; 
				i_zdoe_info1.i_zfilename  	:= 'TITDMGREF1'; 
				i_zdoe_info1.i_prefix     	:= C_prefix; 
				i_zdoe_info1.i_scheduleno 	:= i_scheduleNumber; 
				i_zdoe_info1.i_tableName  	:= v_tableName; 
				i_zdoe_info1.i_refKey     	:= TRIM(temp_refKey1); 
				errindex             		    := 0; 
				n_check              		    := 0; 
				temp_zrefundam       		    := 0; 
				temp_zrefundam1      		    := 0; 
				update_zrefundam     		    := 0; 
				temp_zrefmtcd        		    := ''; 
				update_zrefmtcd      		    := ''; 
				temp_zrefundbe       		    := 0; 
				update_zrefundbe     		    := 0; 
				temp_zrefundbz       		    := 0; 
				update_zrefundbz     		    := 0; 
				temp_zenrfdst        		    := ''; 
				update_zenrfdst      		    := ''; 
				temp_zzhrfdst        		    := ''; 
				update_zzhrfdst      		    := ''; 
				temp_zrfdst_zenrfdst 		    := ''; 
				temp_zrfdst_zzhrfdst 		    := ''; 
				update_zrfdst        		    := ''; 
				gbidpfindex          		    := 0; 
				gpmdpfindex          		    := 0; 
				gbidpf_list          		    := gbidpf_type(); 
				gpmdpf_list          		    := gpmdpf_type(); 
				n_new                		    := 0; 
				b_zrefundam          		    := 0; 
				b_zrefmtcd           		    := NULL; 
				b_zrefundbe          		    := 0; 
				b_zrefundbz          		    := 0; 
				b_zenrfdst           		    := NULL; 
				b_zzhrfdst           		    := NULL; 
			
			-- Check ZREPPF table if any records already there with the same CHDRNUM
				SELECT COUNT(CHDRNUM) 
				INTO n_new 
				FROM Jd1dta.ZREPPF 
				WHERE CHDRNUM = v_chdrnum1; 
				IF n_new      > 0 THEN 
					SELECT zrefundam, 
						zrefmtcd, 
						zrefundbe, 
						zrefundbz, 
						zenrfdst, 
						zzhrfdst 
						INTO b_zrefundam, 
						b_zrefmtcd, 
						b_zrefundbe, 
						b_zrefundbz, 
						b_zenrfdst, 
						b_zzhrfdst 
					FROM Jd1dta.zreppf 
					WHERE chdrnum = v_chdrnum1; 
					b_zreppfFlag := true; 
				END IF;
				
				BEGIN
				 SELECT  COWNNUM, PTDATE, BTDATE
				 INTO 	temp_cownnum, 
						 temp_ptdate, 
						 temp_btdate 
				 FROM Jd1dta.GCHD where CHDRNUM = TRIM(v_chdrnum1) and TRANLUSED = TRIM(v_tranno1);
         
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
           temp_cownnum := null;
           temp_ptdate := null;
           temp_btdate := null;
        END;
			
				--Validation Start For TITDMGREF1 ------------------------------- 
				-- IF i_zprvaldYN         ='Y' THEN 				
				--1) CHECK for Duplicate Records in TITDMGREF2 when appending with CHDRNUM, ZREFMTCD, REFNUM (INSTNO)
				IF NOT (checkduplicateIntitdmgref2.exists(TRIM(v_chdrnum1) || TRIM(v_zrefmtcd1) || TRIM(v_refnum1))) THEN 
					b_isNoError1                  := FALSE; 
					b_globalError                 := FALSE; 
					i_zdoe_info1.i_indic          := 'E'; 
					i_zdoe_info1.i_error01        := C_Z004; 
					i_zdoe_info1.i_errormsg01     := o_errortext(C_Z004); 
					i_zdoe_info1.i_errorfield01   := 'chdrnum1'; 
					i_zdoe_info1.i_fieldvalue01   := TRIM(v_chdrnum1); 
					i_zdoe_info1.i_errorprogram01 := i_scheduleName; 
					GOTO insertzdoe; 
				END IF; 
				
                    --- RF2 changes to check below one as part of pre-validation
                    BEGIN
				-- changes for RF4 --- ZJNPG-9739
                  /*  select TRIM(zaltrcde01)  into v_zaltrcde01 from Jd1dta.ZTRAPF 
                    where STATCODE = 'CA' and ZTRXSTAT = 'AP' and 
                    trim(zrcaltty) = 'TERM' and TRIM(CHDRNUM) = trim(v_chdrnum1);
                    */
                    
                    select TRIM(zaltrcde01)  into v_zaltrcde01 from Jd1dta.ZTRAPF 
                    where STATCODE = 'CA'
                    and ( (ZTRXSTAT = 'AP' and trim(zrcaltty) = 'TERM') or (ZTRXSTAT = 'RJ') ) 
                    and TRIM(CHDRNUM) = trim(v_chdrnum1);                    
                    
                    
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                        b_isNoError1                  := FALSE; 
                        i_zdoe_info1.i_indic          := 'E'; 
                        i_zdoe_info1.i_error01        := 'PA05'; 
                        i_zdoe_info1.i_errormsg01     := 'pol not in ZTRAPF'; 
                        i_zdoe_info1.i_errorfield01   := 'v_chdrnum1'; 
                        i_zdoe_info1.i_fieldvalue01   := trim(v_chdrnum1); 
                        i_zdoe_info1.i_errorprogram01 := i_scheduleName; 
                        
					GOTO insertzdoe;                     
                                       
                    
                    END;

				---- RF3 changes started
				
				IF temp_cownnum is null THEN
				
					b_isNoError1                  := FALSE; 
					i_zdoe_info1.i_indic          := 'E'; 
					i_zdoe_info1.i_error01        := 'PA06'; 
					i_zdoe_info1.i_errormsg01     := 'GCHD.Clntnum is null'; 
                        i_zdoe_info1.i_errorfield01   := 'refnum'; 
                        i_zdoe_info1.i_fieldvalue01   := trim(v_chdrnum1); 
                        i_zdoe_info1.i_errorprogram01 := i_scheduleName; 
					GOTO insertzdoe; 				
				
				END IF;
                        
				IF temp_ptdate is null THEN
				
					b_isNoError1                  := FALSE; 
					i_zdoe_info1.i_indic          := 'E'; 
					i_zdoe_info1.i_error01        := 'PA07'; 
					i_zdoe_info1.i_errormsg01     := 'GCHD.ptdate is null'; 
					i_zdoe_info1.i_errorfield01   := 'refnum'; 
					i_zdoe_info1.i_fieldvalue01   := TRIM(v_chdrnum1); 
					i_zdoe_info1.i_errorprogram01 := i_scheduleName; 
					GOTO insertzdoe;                     
                                       
				END IF;				
				
				IF temp_btdate is null THEN
                    
					b_isNoError1                  := FALSE; 
					i_zdoe_info1.i_indic          := 'E'; 
					i_zdoe_info1.i_error01        := 'PA07'; 
					i_zdoe_info1.i_errormsg01     := 'GCHD.btdate is null'; 
					i_zdoe_info1.i_errorfield01   := 'refnum'; 
					i_zdoe_info1.i_fieldvalue01   := TRIM(v_chdrnum1); 
					i_zdoe_info1.i_errorprogram01 := i_scheduleName; 
					GOTO insertzdoe; 				

				END IF;						

				---- RF3 changes ended

				
				-- 2) CHECK IF REFNUM or INSTNO  IS NULL---
				IF TRIM(v_refnum1)               IS NULL THEN 
					b_isNoError1                  := FALSE; 
					i_zdoe_info1.i_indic          := 'E'; 
					i_zdoe_info1.i_error01        := C_Z113; 
					i_zdoe_info1.i_errormsg01     := o_errortext(C_Z113); 
					i_zdoe_info1.i_errorfield01   := 'refnum'; 
					i_zdoe_info1.i_fieldvalue01   := TRIM(v_refnum1); 
					i_zdoe_info1.i_errorprogram01 := i_scheduleName; 
					GOTO insertzdoe; 
				END IF; 
			
				-- 3) CHECK for Duplicate whether Refund Bill already migrated or not
			--	IF (checkduplicate.exists(TRIM(v_chdrnum1) ||TRIM(v_zrefmtcd1) ||TRIM(v_refnum1) )) THEN 
              IF obj_refundBills1.mig_pol is not null THEN -- Changes for RF5
					b_isNoError1                  := FALSE; 
					i_zdoe_info1.i_indic          := 'E'; 
					i_zdoe_info1.i_error01        := C_Z112; 
					i_zdoe_info1.i_errormsg01     := o_errortext(C_Z112); 
					i_zdoe_info1.i_errorfield01   := 'chdrnum1'; 
					i_zdoe_info1.i_fieldvalue01   := TRIM(v_chdrnum1); 
					i_zdoe_info1.i_errorprogram01 := i_scheduleName; 
					GOTO insertzdoe; 
				END IF; 
				
				-- 4) CHECK If CHDRNUM EXISTS or not
				IF (v_chdrnm1 IS NULL) THEN 
					b_isNoError1 := FALSE; 
					v_errorCount1                  := v_errorCount1 + 1; 
					t_ercode(v_errorCount1)        := C_Z031; 
					t_errorfield(v_errorCount1)    := 'chdrnum1'; 
					t_errormsg(v_errorCount1)      := o_errortext(C_Z031); 
					t_errorfieldval(v_errorCount1) := TRIM(v_chdrnum1); 
					t_errorprogram(v_errorCount1)  := i_scheduleName; 
					IF v_errorCount1               >= 5 THEN 
						GOTO insertzdoe; 
					END IF; 
				END IF; 
			
				-- 5) CHECK IF BANKACCUNT IS NOT NULL
				IF TRIM(v_bankacount) IS NOT NULL THEN 
				  
					-- VALIDATE BANK ACCOUNT
					IF (v_bankacountkey IS NULL) THEN 
						b_isNoError1 := FALSE; 
						v_errorCount1                  := v_errorCount1 + 1; 
						t_ercode(v_errorCount1)        := C_Z110; 
						t_errorfield(v_errorCount1)    := 'bankacount'; 
						t_errormsg(v_errorCount1)      := o_errortext(C_Z110); 
						t_errorfieldval(v_errorCount1) := TRIM(v_bankacount); 
						t_errorprogram(v_errorCount1)  := i_scheduleName; 
						IF v_errorCount1               >= 5 THEN 
						  GOTO insertzdoe; 
						END IF; 
					END IF; 
				 
				END IF; 
				
				-- 6) CHECK IF BANKACCUNT TYPE IS NOT NULL
			
				IF TRIM(v_bnkactyp) IS NOT NULL THEN 
				
					-- CHECK IF BANKACCUNT TYPE IS EXIST IN T - TABLE : TR338 or not
					IF NOT (itemexist.exists(TRIM(C_TR338) || TRIM(v_bnkactyp) || 9)) THEN 
						b_isNoError1 := FALSE; 
						v_errorCount1                  := v_errorCount1 + 1; 
						t_ercode(v_errorCount1)        := C_Z035; 
						t_errorfield(v_errorCount1)    := 'bnkactyp'; 
						t_errormsg(v_errorCount1)      := o_errortext(C_Z035); 
						t_errorfieldval(v_errorCount1) := TRIM(v_bnkactyp); 
						t_errorprogram(v_errorCount1)  := i_scheduleName; 
						IF v_errorCount1               >= 5 THEN 
						  GOTO insertzdoe; 
						END IF; 
					END IF; 
				END IF; 
			
				-- 7) PERIOD BILL FROM DATE IS VALID OR NOT
				isDateValid                      := VALIDATE_DATE(v_prbilfdt); 
				IF isDateValid                   <> 'OK' THEN 
					b_isNoError1                   := FALSE; 
					v_errorCount1                  := v_errorCount1 + 1; 
					t_ercode(v_errorCount1)        := C_Z013; 
					t_errorfield(v_errorCount1)    := 'prbilfdt'; 
					t_errormsg(v_errorCount1)      := o_errortext(C_Z013); 
					t_errorfieldval(v_errorCount1) := TRIM(v_prbilfdt); 
					t_errorprogram(v_errorCount1)  := i_scheduleName; 
					IF v_errorCount1               >= 5 THEN 
						GOTO insertzdoe; 
					END IF; 
				END IF; 
			
				-- 8) PERIOD BILL TO DATE IS VALID OR NOT
				isDateValid                      := VALIDATE_DATE(v_prbiltdt); 
				IF isDateValid                   <> 'OK' THEN 
					b_isNoError1                   := FALSE; 
					v_errorCount1                  := v_errorCount1 + 1; 
					t_ercode(v_errorCount1)        := C_Z013; 
					t_errorfield(v_errorCount1)    := 'prbiltdt'; 
					t_errormsg(v_errorCount1)      := o_errortext(C_Z013); 
					t_errorfieldval(v_errorCount1) := TRIM(v_prbiltdt); 
					t_errorprogram(v_errorCount1)  := i_scheduleName; 
					IF v_errorCount1               >= 5 THEN 
						GOTO insertzdoe; 
					END IF; 
				END IF; 
			
				-- 9) CHECK IF REFUND METHOD IS EXIST IN T - TABLE : TQ9G7 or not
				IF NOT (itemexist.exists(TRIM(C_TQ9G7) || TRIM(v_zrefmtcd1) || i_company)) THEN 
					b_isNoError1                   := FALSE; 
					v_errorCount1                  := v_errorCount1 + 1; 
					t_ercode(v_errorCount1)        := C_Z105; 
					t_errorfield(v_errorCount1)    := 'zrefmtcd1'; 
					t_errormsg(v_errorCount1)      := o_errortext(C_Z105); 
					t_errorfieldval(v_errorCount1) := TRIM(v_zrefmtcd1); 
					t_errorprogram(v_errorCount1)  := i_scheduleName; 
					IF v_errorCount1               >= 5 THEN 
						GOTO insertzdoe; 
					END IF; 
				END IF; 
			
				-- 10) Missing prem frm Endos 
				IF v_zrefmtcd1                    = '002' AND TRIM(v_zrefundbe) IS NULL THEN 
					b_isNoError1                   := FALSE; 
					v_errorCount1                  := v_errorCount1 + 1; 
					t_ercode(v_errorCount1)        := C_Z106; 
					t_errorfield(v_errorCount1)    := 'zrefundbe'; 
					t_errormsg(v_errorCount1)      := o_errortext(C_Z106); 
					t_errorfieldval(v_errorCount1) := TRIM(v_zrefundbe); 
					t_errorprogram(v_errorCount1)  := i_scheduleName; 
					IF v_errorCount1               >= 5 THEN 
						GOTO insertzdoe; 
					END IF; 
				END IF; 
				
				-- 11) Missing prem from Jdrich
				IF v_zrefmtcd1                    = '001' AND TRIM(v_zrefundbz) IS NULL THEN 
					b_isNoError1                   := FALSE; 
					v_errorCount1                  := v_errorCount1 + 1; 
					t_ercode(v_errorCount1)        := C_Z107; 
					t_errorfield(v_errorCount1)    := 'zrefundbz'; 
					t_errormsg(v_errorCount1)      := o_errortext(C_Z107); 
					t_errorfieldval(v_errorCount1) := TRIM(v_zrefundbz); 
					t_errorprogram(v_errorCount1)  := i_scheduleName; 
					IF v_errorCount1               >= 5 THEN 
						GOTO insertzdoe; 
					END IF; 
				END IF; 
				
				-- 12) Endorser Status - Must be valid in TQ9NW
				IF (TRIM(v_zrefmtcd1) = '002') THEN 
					IF NOT (itemexist.exists(TRIM(C_TQ9NW) || TRIM(v_zenrfdst) || i_company)) THEN 
						b_isNoError1                   := FALSE; 
						v_errorCount1                  := v_errorCount1 + 1; 
						t_ercode(v_errorCount1)        := C_Z108; 
						t_errorfield(v_errorCount1)    := 'zenrfdst'; 
						t_errormsg(v_errorCount1)      := o_errortext(C_Z108); 
						t_errorfieldval(v_errorCount1) := TRIM(v_zenrfdst); 
						t_errorprogram(v_errorCount1)  := i_scheduleName; 
						IF v_errorCount1               >= 5 THEN 
						  GOTO insertzdoe; 
						END IF; 
					END IF; 
				END IF; 
				
				--13) Jdrich Status - Must be valid in TQ9NW
				IF (TRIM(v_zrefmtcd1) = '001') THEN 
					IF NOT (itemexist.exists(TRIM(C_TQ9NW) || TRIM(v_zzhrfdst) || i_company)) THEN  
						b_isNoError1                   := FALSE; 
						v_errorCount1                  := v_errorCount1 + 1; 
						t_ercode(v_errorCount1)        := C_Z108; 
						t_errorfield(v_errorCount1)    := 'zzhrfdst'; 
						t_errormsg(v_errorCount1)      := o_errortext(C_Z108); 
						t_errorfieldval(v_errorCount1) := TRIM(v_zzhrfdst); 
						t_errorprogram(v_errorCount1)  := i_scheduleName; 
						IF v_errorCount1               >= 5 THEN 
						  GOTO insertzdoe; 
						END IF; 
					END IF; 
				END IF; 
				
				--14) Require Bank Account for Refund Designation Form - Must be Y or N
				IF TRIM(v_zrqbkrdf)              <> 'Y' AND TRIM(v_zrqbkrdf) <> 'N' THEN 
					b_isNoError1                   := FALSE; 
					v_errorCount1                  := v_errorCount1 + 1; 
					t_ercode(v_errorCount1)        := C_Z028; 
					t_errorfield(v_errorCount1)    := 'zrqbkrdf'; 
					t_errormsg(v_errorCount1)      := o_errortext(C_Z028); 
					t_errorfieldval(v_errorCount1) := TRIM(v_zrqbkrdf); 
					t_errorprogram(v_errorCount1)  := i_scheduleName; 
					IF v_errorCount1               >= 5 THEN 
						GOTO insertzdoe; 
					END IF; 
				END IF;
				
				--15) Is PAYDATE Valid or not
                IF v_zrefmtcd1 <> '002' then --- RF2 ITR3 Code fix, As per MSD the refund by endoser will be set as 0 from source
				isDateValid                      := VALIDATE_DATE(v_paydate); 
				IF isDateValid                   <> 'OK' THEN 
					b_isNoError1                   := FALSE; 
					v_errorCount1                  := v_errorCount1 + 1; 
					t_ercode(v_errorCount1)        := C_Z013; 
					t_errorfield(v_errorCount1)    := 'v_paydate'; 
					t_errormsg(v_errorCount1)      := o_errortext(C_Z013); 
					t_errorfieldval(v_errorCount1) := TRIM(v_paydate); 
					t_errorprogram(v_errorCount1)  := i_scheduleName; 
					IF v_errorCount1               >= 5 THEN 
						GOTO insertzdoe; 
					END IF; 
                 END IF;   
				ELSE 
        
				--16) Check if PAYDATE >= TODAY
					IF (TRIM(v_paydate)                <> 0) AND (TRIM(v_paydate) <> NULL) AND (TRIM(v_paydate) <> 99999999) THEN 
						IF TRIM(v_paydate)               >= TO_CHAR(sysdate, 'YYYYMMDD') THEN 
							b_isNoError1                   := FALSE; 
							v_errorCount1                  := v_errorCount1 + 1; 
							t_ercode(v_errorCount1)        := C_Z111; 
							t_errorfield(v_errorCount1)    := 'v_paydate'; 
							t_errormsg(v_errorCount1)      := o_errortext(C_Z111); 
							t_errorfieldval(v_errorCount1) := TRIM(v_paydate); 
							t_errorprogram(v_errorCount1)  := i_scheduleName; 
							IF v_errorCount1               >= 5 THEN 
								GOTO insertzdoe; 
							END IF; 
						END IF; 
					END IF; 
				END IF; 
				--Validation END For TITDMGREF1 ---------- 
			
				----Common Business logic for inserting into ZDOEPF FOR TABLE TITDMGREF1--- 
				<<insertzdoe>> 
				IF (b_isNoError1                   = FALSE) THEN 
					IF TRIM(t_ercode(1))            IS NOT NULL THEN 
						i_zdoe_info1.i_indic          := 'E'; 
						i_zdoe_info1.i_error01        := t_ercode(1); 
						i_zdoe_info1.i_errormsg01     := t_errormsg(1); 
						i_zdoe_info1.i_errorfield01   := t_errorfield(1); 
						i_zdoe_info1.i_fieldvalue01   := t_errorfieldval(1); 
						i_zdoe_info1.i_errorprogram01 := t_errorprogram(1); 
					END IF; 
					IF TRIM(t_ercode(2))            IS NOT NULL THEN 
						i_zdoe_info1.i_indic          := 'E'; 
						i_zdoe_info1.i_error02        := t_ercode(2); 
						i_zdoe_info1.i_errormsg02     := t_errormsg(2); 
						i_zdoe_info1.i_errorfield02   := t_errorfield(2); 
						i_zdoe_info1.i_fieldvalue02   := t_errorfieldval(2); 
						i_zdoe_info1.i_errorprogram02 := t_errorprogram(2); 
					END IF; 
					IF TRIM(t_ercode(3))            IS NOT NULL THEN 
						i_zdoe_info1.i_indic          := 'E'; 
						i_zdoe_info1.i_error03        := t_ercode(3); 
						i_zdoe_info1.i_errormsg03     := t_errormsg(3); 
						i_zdoe_info1.i_errorfield03   := t_errorfield(3); 
						i_zdoe_info1.i_fieldvalue03   := t_errorfieldval(3); 
						i_zdoe_info1.i_errorprogram03 := t_errorprogram(3); 
					END IF; 
					IF TRIM(t_ercode(4))            IS NOT NULL THEN 
						i_zdoe_info1.i_indic          := 'E'; 
						i_zdoe_info1.i_error04        := t_ercode(4); 
						i_zdoe_info1.i_errormsg04     := t_errormsg(4); 
						i_zdoe_info1.i_errorfield04   := t_errorfield(4); 
						i_zdoe_info1.i_fieldvalue04   := t_errorfieldval(4); 
						i_zdoe_info1.i_errorprogram04 := t_errorprogram(4); 
					END IF; 
					IF TRIM(t_ercode(5))            IS NOT NULL THEN 
						i_zdoe_info1.i_indic          := 'E'; 
						i_zdoe_info1.i_error05        := t_ercode(5); 
						i_zdoe_info1.i_errormsg05     := t_errormsg(5); 
						i_zdoe_info1.i_errorfield05   := t_errorfield(5); 
						i_zdoe_info1.i_fieldvalue05   := t_errorfieldval(5); 
						i_zdoe_info1.i_errorprogram05 := t_errorprogram(5); 
					END IF; 
					pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info1); 
					CONTINUE again_start; 
				END IF; 
				IF b_isNoError1         = TRUE THEN 
					i_zdoe_info1.i_indic := 'S'; 
					pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info1); 
				END IF; 
				v_errorCount1 :=0; 
				
				IF b_isNoError1 = TRUE AND TRIM(i_zprvaldYN) = 'N' THEN 
				--------------------- PAZDRFPF Insertion Start for Migration Registry Table--------------------------- 


					--SELECT SEQ_BILLNO.nextval INTO v_temp_billno FROM dual;
                    v_temp_billno := SEQ_BILLNO.nextval; --PerfImprov


					---Insert into Data Migration Registry  table - PAZDRFPF START ---------
            
					obj_VIEW_DM_ZDRFPF.RECSTATUS 	:= 'OK';
					obj_VIEW_DM_ZDRFPF.ZENTITY    	:= v_refnum1;
					obj_VIEW_DM_ZDRFPF.CHDRNUM   	:= v_chdrnum1;
					obj_VIEW_DM_ZDRFPF.ZREFMTCD   	:= v_zrefmtcd1;
					obj_VIEW_DM_ZDRFPF.ZIGVALUE  	:= v_temp_billno;
					obj_VIEW_DM_ZDRFPF.JOBNUM    	:= i_scheduleNumber;
					obj_VIEW_DM_ZDRFPF.JOBNAME   	:= i_scheduleName;
					obj_VIEW_DM_ZDRFPF.ZPDATATXFLG  := obj_refundBills1.ZPDATATXFLG;
					Insert into VIEW_DM_PAZDRFPF values obj_VIEW_DM_ZDRFPF;
		
					---Insert into Data Migration Registry  table - PAZDRFPF END ---------
					
					
			
					--------------------- GBIHPF Insertion START -------------------------- 
					--SELECT SEQ_GBIHPF.nextval INTO v_UNIQ_GBIHPF FROM dual;
                    v_UNIQ_GBIHPF := SEQ_GBIHPF.nextval; --PerfImprov
                    obj_VIEW_DM_GBIHPF.UNIQUE_NUMBER := v_UNIQ_GBIHPF;
					obj_VIEW_DM_GBIHPF.BILLNO    := v_temp_billno; 
					obj_VIEW_DM_GBIHPF.CHDRCOY   := i_company; 
					obj_VIEW_DM_GBIHPF.CHDRNUM   := v_chdrnum1; 
					obj_VIEW_DM_GBIHPF.SUBSCOY   := C_SUBSCOY; 
					obj_VIEW_DM_GBIHPF.SUBSNUM   := C_SUBSNUM;
					obj_VIEW_DM_GBIHPF.MBRNO     := C_MBRNO;					
					obj_VIEW_DM_GBIHPF.BILLTYP   := o_defaultvalues('BILLTYP'); 
					obj_VIEW_DM_GBIHPF.PRBILFDT  := v_prbilfdt; 
					obj_VIEW_DM_GBIHPF.PRBILTDT  := v_prbiltdt; 
					obj_VIEW_DM_GBIHPF.INSTNO    := TO_NUMBER(v_refnum1); 
					obj_VIEW_DM_GBIHPF.PBILLNO   := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GBIHPF.TERMID    := i_vrcmTermid; 
					obj_VIEW_DM_GBIHPF.TRDT      := n_trdt; 
					obj_VIEW_DM_GBIHPF.TRTM      := i_vrcmtime;
					obj_VIEW_DM_GBIHPF.TRANNO    := v_tranno1;
					obj_VIEW_DM_GBIHPF.GRPGST    := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GBIHPF.GRPSDUTY  := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GBIHPF.VALIDFLAG := o_defaultvalues('VALIDFLAG'); 
					obj_VIEW_DM_GBIHPF.BILFLAG   := o_defaultvalues('BILFLAG');
					obj_VIEW_DM_GBIHPF.NRFLG     := v_nrflg; 
					obj_VIEW_DM_GBIHPF.TGTPCNT   := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GBIHPF.PREMOUT   := o_defaultvalues('PREMOUT'); 
					obj_VIEW_DM_GBIHPF.BILLDUEDT := v_effdate; 
					obj_VIEW_DM_GBIHPF.REVFLAG   := o_defaultvalues('REVFLAG'); 
					obj_VIEW_DM_GBIHPF.USER_T    := i_vrcmuser;
					obj_VIEW_DM_GBIHPF.ZGSTAFEE  := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GBIHPF.ZGSTCOM   := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GBIHPF.ZCOLFLAG  := o_defaultvalues('ZCOLFLAG'); 
					obj_VIEW_DM_GBIHPF.ZACMCLDT  := v_maxdate; 
					obj_VIEW_DM_GBIHPF.PAYDATE   := v_paydate; 
					obj_VIEW_DM_GBIHPF.ZPOSBDSM  := v_zposbdsm; 
					obj_VIEW_DM_GBIHPF.ZPOSBDSY  := v_zposbdsy; 
					obj_VIEW_DM_GBIHPF.RDOCPFX   := nvl(v_rdocpfx,' '); -- RF3 Changes
					obj_VIEW_DM_GBIHPF.RDOCCOY   := nvl(v_rdoccoy,' '); -- RF3 Changes
					obj_VIEW_DM_GBIHPF.RDOCNUM   := nvl(v_rdocnum,' '); -- RF3 Changes
					obj_VIEW_DM_GBIHPF.DATIME    := sysdate; 
					obj_VIEW_DM_GBIHPF.JOBNM     := i_scheduleName; 
					obj_VIEW_DM_GBIHPF.USRPRF    := i_userProfile; 
					obj_VIEW_DM_GBIHPF.ZBKTRFDT  := 99999999;   	
					obj_VIEW_DM_GBIHPF.ZSTPBLYN  := C_ZSTPBLYN;
					obj_VIEW_DM_GBIHPF.PPMCCOST  := C_PPMCCOST; 
									
					INSERT INTO Jd1dta.VIEW_DM_GBIHPF VALUES obj_VIEW_DM_GBIHPF; 
					
					v_errorCount1        := 0;           
					--------------------- GBIHPF Insertion END ---------------------------- 
					
					--------------------- ZRFDPF  Insertion START --------------------------
					--Refund by Endorser (002) is > ZERO and NOT NULL
					IF TRIM(v_zrefundbe) <> 0 AND TRIM(v_zrefundbe) IS NOT NULL THEN 
						temp_zrefundam1    := v_zrefundbe; 
					ELSE 
						temp_zrefundam1 := v_zrefundbz; 
					END IF;
					
										 
					obj_VIEW_DM_ZRFDPF.CHDRNUM  := v_chdrnum1; 
					obj_VIEW_DM_ZRFDPF.TRANNO  := v_tranno1; 
					obj_VIEW_DM_ZRFDPF.BILLNO  := v_temp_billno; 
					obj_VIEW_DM_ZRFDPF.EFFDATE  := v_effdate; 
					obj_VIEW_DM_ZRFDPF.ZREFMTCD  := v_zrefmtcd1;
					obj_VIEW_DM_ZRFDPF.ZREFUNDAM  := temp_zrefundam1; 
					obj_VIEW_DM_ZRFDPF.USRPRF  := i_userProfile; 
					obj_VIEW_DM_ZRFDPF.JOBNM  := i_scheduleName; 
					obj_VIEW_DM_ZRFDPF.DATIME  := sysdate; 
					INSERT INTO Jd1dta.VIEW_DM_ZRFDPF VALUES obj_VIEW_DM_ZRFDPF; 
			
					--------------------- ZRFDPF  Insertion END ---------------------------- 
			  
					--------------------- ZREPPF Insertion START -------------------------- 
					obj_VIEW_DM_ZREPPF.CHDRNUM    := v_chdrnum1; 
					obj_VIEW_DM_ZREPPF.EFFDATE    := v_effdate; 
					obj_VIEW_DM_ZREPPF.TRANNO     := v_tranno1; 
					-- changes for RF4 --- ZJNPG-9739
					/*
					select TRIM(zaltrcde01)  into v_zaltrcde01 from Jd1dta.ZTRAPF 
					where STATCODE = 'CA' and ZTRXSTAT = 'AP' and 
						  trim(zrcaltty) = 'TERM' and TRIM(CHDRNUM) = trim(v_chdrnum1);
                          */
                   begin
                   
                    select TRIM(zaltrcde01)  into v_zaltrcde01 from Jd1dta.ZTRAPF 
                    where STATCODE = 'CA'
                    and ( (ZTRXSTAT = 'AP' and trim(zrcaltty) = 'TERM') or (ZTRXSTAT = 'RJ') ) 
                    and TRIM(CHDRNUM) = trim(v_chdrnum1);  
				
                     EXCEPTION WHEN NO_DATA_FOUND THEN
                     null;
                     end;
				
					obj_VIEW_DM_ZREPPF.ZALTRCDE01 := v_zaltrcde01; 
					obj_VIEW_DM_ZREPPF.ZREFUNDAM  := 0; 
					obj_VIEW_DM_ZREPPF.ZREFUNDBE  := 0; 
					obj_VIEW_DM_ZREPPF.ZREFUNDBZ  := 0; 
					-------------ZREFUNDAM ---------- 
				
						IF TRIM(v_zrefundbe)   <> 0 AND TRIM(v_zrefundbe) IS NOT NULL THEN 
							obj_VIEW_DM_ZREPPF.ZREFUNDAM := NVL(v_zrefundbe,0) + temp_zrefundam; 
							update_zrefundam     := NVL(v_zrefundbe,0) + temp_zrefundam; 
						ELSE 
							obj_VIEW_DM_ZREPPF.ZREFUNDAM := NVL(v_zrefundbz,0) + temp_zrefundam; 
							update_zrefundam     := NVL(v_zrefundbz,0) + temp_zrefundam; 
						END IF; 
				
					-------------ZREFUNDAM  END---------- 
				
					-------------ZREFMTCD START---------- 
			  
						IF TRIM(temp_zrefmtcd) <> TRIM(v_zrefmtcd1) THEN 
						  obj_VIEW_DM_ZREPPF.ZREFMTCD  := o_defaultvalues('ZREFMTCD'); 
						  update_zrefmtcd      := o_defaultvalues('ZREFMTCD'); 
						ELSE 
						  obj_VIEW_DM_ZREPPF.ZREFMTCD := v_zrefmtcd1; 
						  update_zrefmtcd     := v_zrefmtcd1; 
						END IF; 
			
					-------------ZREFMTCD  END---------- 
				
					-------------ZREFUNDBE---------- 
								                                                 
					IF TRIM(v_zrefundbe)   <> 0 AND TRIM(v_zrefundbe) IS NOT NULL THEN 
						  obj_VIEW_DM_ZREPPF.ZREFUNDBE := v_zrefundbe + temp_zrefundbe; 
						  update_zrefundbe     := v_zrefundbe + temp_zrefundbe; 
					END IF; 
					-------------ZREFUNDBE END ---------- 
				
					-------------ZREFUNDBZ---------- 
			  
					IF TRIM(v_zrefundbz)   <> 0 AND TRIM(v_zrefundbz) IS NOT NULL THEN 
							obj_VIEW_DM_ZREPPF.ZREFUNDBZ := v_zrefundbz + v_zrefundbz; 
							update_zrefundbz     := v_zrefundbz + v_zrefundbz; 
					END IF; 
			 
				  -------------ZREFUNDBZ END---------- 
			  
				-------------ZENRFDST ---------- 
					IF TRIM(v_zenrfdst)    IS NOT NULL THEN 
						obj_VIEW_DM_ZREPPF.ZENRFDST  := TRIM(v_zenrfdst); 
						temp_zrfdst_zenrfdst := TRIM(v_zenrfdst); 
						update_zenrfdst      := TRIM(v_zenrfdst); 
					ELSE 
						obj_VIEW_DM_ZREPPF.ZENRFDST  := TRIM(temp_zenrfdst); 
						temp_zrfdst_zenrfdst := TRIM(temp_zenrfdst); 
						update_zenrfdst      := TRIM(temp_zenrfdst); 
					END IF; 
		
				-------------ZENRFDST END---------- 
			  
				-------------ZZHRFDST ---------- 
			
					IF TRIM(v_zzhrfdst)    IS NOT NULL THEN 
							obj_VIEW_DM_ZREPPF.ZZHRFDST  := TRIM(v_zzhrfdst); 
							temp_zrfdst_zenrfdst := TRIM(v_zzhrfdst); 
							update_zzhrfdst      := TRIM(v_zzhrfdst); 
					ELSE 
							obj_VIEW_DM_ZREPPF.ZZHRFDST  := TRIM(temp_zzhrfdst); 
							temp_zrfdst_zzhrfdst := TRIM(temp_zzhrfdst); 
							update_zzhrfdst      := TRIM(temp_zzhrfdst); 
					END IF; 
				-------------ZZHRFDST END---------- 
			  
				-------------ZRFDST ---------- 
			  
				IF temp_zrfdst_zenrfdst IS NOT NULL AND temp_zrfdst_zenrfdst <> 'RC' THEN 
						obj_VIEW_DM_ZREPPF.ZRFDST     := TRIM(temp_zrfdst_zenrfdst); 
						update_zrfdst         := TRIM(temp_zrfdst_zenrfdst); 
				ELSE 
						IF temp_zrfdst_zzhrfdst IS NOT NULL THEN 
							obj_VIEW_DM_ZREPPF.ZRFDST     := TRIM(temp_zrfdst_zzhrfdst); 
							update_zrfdst         := TRIM(temp_zrfdst_zzhrfdst); 
						ELSE 
							obj_VIEW_DM_ZREPPF.ZRFDST := TRIM(temp_zrfdst_zenrfdst); 
							update_zrfdst     := TRIM(temp_zrfdst_zenrfdst); 
						END IF; 
				END IF; 
				-------------ZRFDST END---------- 
			  
				obj_VIEW_DM_ZREPPF.CLNTNUM 	  := temp_cownnum; 
				obj_VIEW_DM_ZREPPF.BANKKEY    := v_bankkey;				
				obj_VIEW_DM_ZREPPF.BANKACOUNT := v_bankacount; 
				obj_VIEW_DM_ZREPPF.BANKACCDSC := v_bankaccdsc; 
				obj_VIEW_DM_ZREPPF.BNKACTYP   := v_bnkactyp; 
				obj_VIEW_DM_ZREPPF.ZRQBKRDF   := v_zrqbkrdf; 
				obj_VIEW_DM_ZREPPF.REQDATE    := v_reqdate; 
				obj_VIEW_DM_ZREPPF.ZCOLFLAG   := o_defaultvalues('ZCOLFLAG'); 
				obj_VIEW_DM_ZREPPF.ZPBCODE    := C_ZPBCODE; 
				obj_VIEW_DM_ZREPPF.ZPBACNO    := C_ZPBACNO; 
				obj_VIEW_DM_ZREPPF.ZPBCTYPE   := C_ZPBCTYPE; 
				obj_VIEW_DM_ZREPPF.CURRFROM   := v_maxdate;   
				obj_VIEW_DM_ZREPPF.PTDATE     := temp_ptdate; 	
				obj_VIEW_DM_ZREPPF.ZREFLIST   := o_defaultvalues('ZREFLIST');
				obj_VIEW_DM_ZREPPF.BTDATE     := temp_btdate; 
				obj_VIEW_DM_ZREPPF.USRPRF     := i_userProfile; 
				obj_VIEW_DM_ZREPPF.JOBNM      := i_scheduleName; 
				obj_VIEW_DM_ZREPPF.DATIME     := sysdate; 
			  
				IF b_zreppfFlag = TRUE THEN 
					v_zrefundbe_l        := b_ZREFUNDBE   + v_zrefundbe; 
					v_zrefundbz_l        := b_zrefundbz   + v_zrefundbz; 
					v_zrefundam_l        := v_zrefundbe_l + v_zrefundbz_l; 
					
					IF (TRIM(v_zenrfdst) IS NOT NULL) THEN 
						v_zenrfdst_l       := v_zenrfdst; 
					ELSE 
						v_zenrfdst_l := b_ZENRFDST; 
					END IF; 
					
					IF (TRIM(v_zzhrfdst) IS NOT NULL) THEN 
						v_zzhrfdst_l       := v_zzhrfdst; 
					ELSE 
						v_zzhrfdst_l := b_ZZHRFDST; 
					END IF; 
					
					IF (TRIM(b_zenrfdst) IS NOT NULL AND TRIm(b_zenrfdst) <> 'RC') THEN 
						v_zrfdst_l         := b_zenrfdst; 
					ELSE
						IF (TRIM(b_zzhrfdst) IS NOT NULL) THEN 
							v_zrfdst_l         := b_zzhrfdst; 
						ELSE 
							v_zrfdst_l := b_zenrfdst; 
						END IF; 
					END IF; 					
					
					IF TRIM(v_zrefmtcd1) = '001' THEN  
						v_zrefmtcd_l := '001';  
					END IF;                            
					IF TRIM(v_zrefmtcd1) = '002' THEN  
						v_zrefmtcd_l := '002'; 
					END IF;                            
					
					IF TRIM(b_ZREFMTCD) IS NULL THEN   
					   b_ZREFMTCD  := v_zrefmtcd_l;
					END IF; 
					
					
					IF TRIM(b_ZREFMTCD) <> TRIM(v_zrefmtcd_l) THEN  
					   v_zrefmtcd_l := o_defaultvalues('ZREFMTCD');  
					END IF; 
				
					UPDATE Jd1dta.VIEW_DM_ZREPPF 
					SET ZREFUNDAM       = v_zrefundam_l, 
					  ZREFMTCD          = v_zrefmtcd_l, 
					  ZREFUNDBE         = v_zrefundbe_l, 
					  ZREFUNDBZ         = v_zrefundbz_l, 
					  ZENRFDST          = v_zenrfdst_l, 
					  ZZHRFDST          = v_zzhrfdst_l, 
					  ZRFDST            = v_zrfdst_l 
					WHERE TRIM(CHDRNUM) = TRIM(v_chdrnum1) 
					AND TRIM(TRANNO)    = TRIM(v_tranno1);
					
					
				ELSE 
					IF (TRIM(v_zrefundbe) IS NOT NULL) THEN 
						v_zrefundbe_l       := v_zrefundbe; 
					ELSE 
						v_zrefundbe_l := 0.00; 
					END IF; 
					IF (TRIM(v_zrefundbz) IS NOT NULL) THEN 
						v_zrefundbz_l       := v_zrefundbz; 
					ELSE 
						v_zrefundbz_l := 0.00; 
					END IF; 
				
					v_zrefundam_l        := v_zrefundbe_l + v_zrefundbz_l; 
					v_zrefmtcd_l         := v_zrefmtcd1; 
					v_zenrfdst_l         := v_zenrfdst; 
					v_zzhrfdst_l         := v_zzhrfdst; 
					IF (TRIm(v_zenrfdst) IS NOT NULL AND TRIm(v_zenrfdst) <> 'RC') THEN 
						v_zrfdst_l         := v_zenrfdst; 
					ELSE 
						IF (TRIm(v_zzhrfdst) IS NOT NULL) THEN 
							v_zrfdst_l         := v_zzhrfdst; 
						ELSE 
							v_zrfdst_l := v_zenrfdst; 
						END IF; 
					END IF; 
					obj_VIEW_DM_ZREPPF.ZREFUNDBE := v_zrefundbe_l; 
					obj_VIEW_DM_ZREPPF.ZREFUNDBZ := v_zrefundbz_l; 
					obj_VIEW_DM_ZREPPF.ZREFUNDAM := v_zrefundam_l;				
					obj_VIEW_DM_ZREPPF.ZREFMTCD  := v_zrefmtcd_l; 
					obj_VIEW_DM_ZREPPF.ZENRFDST  := v_zenrfdst_l; 
					obj_VIEW_DM_ZREPPF.ZZHRFDST  := v_zzhrfdst_l; 
					obj_VIEW_DM_ZREPPF.ZRFDST    := v_zrfdst_l; 
					INSERT INTO VIEW_DM_ZREPPF VALUES obj_VIEW_DM_ZREPPF; 
				END IF; 
			 
			--------------------- ZREPPF Insertion END ---------------------------- 
			  
			END IF; 
			
			END LOOP; 
			EXIT WHEN refundBills_cursor1%notfound; 
		END LOOP; 
					
		------------Open Cursor 2 -----------------------------	
-- changes for RF4 --- ZJNPG-9739
IF TRIM(i_zprvaldYN) = 'N' THEN
		
		OPEN refundBills_cursor2 ;
			
			
			LOOP 
				FETCH refundBills_cursor2 bulk collect INTO refund_list2 limit C_limit;
                 <<again_start2>> --- RF2 changes, it should be placed for the loop
				-- dbms_output.put_line('bulk collect call'); 
				for i in 1 .. refund_list2.count loop
    
				obj_refundBills2 := refund_list2(i);
			
			v_temp_key2   := TRIM(obj_refundBills2.CHDRNUM) || TRIM(obj_refundBills2.TRREFNUM) || TRIM(obj_refundBills2.ZREFMTCD);
			IF (refbilinfo.exists(TRIM(v_temp_key2))) THEN     
				v_refnum2   := refbilinfo(TRIM(v_temp_key2)).refnum; 
				v_chdrnum1 := refbilinfo(TRIM(v_temp_key2)).chdrnum; 
				v_effdate  := refbilinfo(TRIM(v_temp_key2)).effdate; 
				v_prbilfdt := refbilinfo(TRIM(v_temp_key2)).prbilfdt; 
				v_prbiltdt := refbilinfo(TRIM(v_temp_key2)).prbiltdt; 
			ELSE       
				CONTINUE again_start2; 
			END IF; 
			v_recidxrefb2 := obj_refundBills2.RECIDXREFB2; 
			v_trrefnum2   := obj_refundBills2.TRREFNUM; 
			v_chdrnum2    := obj_refundBills2.CHDRNUM; 
			v_zrefmtcd2   := obj_refundBills2.ZREFMTCD; 
			v_prodtyp2    := obj_refundBills2.PRODTYP; 
			v_bprem2      := obj_refundBills2.BPREM * -1; 
			v_mbrno2	  := obj_refundBills2.MBRNO; 
			v_dpntno2	  := obj_refundBills2.DPNTNO; 
			v_tranno2	  := obj_refundBills2.TRANNO; 
			temp_cmrate   := 0; 
			t_ercode2(1)  := NULL; 
			t_ercode2(2)  := NULL; 
			t_ercode2(3)  := NULL; 
			t_ercode2(4)  := NULL; 
			t_ercode2(5)  := NULL; 
			temp_refKey2  := ' ';  
			temp_refKey2  := (v_chdrnum2 || '_' || v_trrefnum2 || '_' || v_zrefmtcd2 || '_' || v_prodtyp2 || '_' || v_mbrno2 ||'_' || v_dpntno2); 
			i_zdoe_info2.i_zfilename  := 'TITDMGREF2'; 
			i_zdoe_info2.i_prefix     := C_prefix; 
			i_zdoe_info2.i_scheduleno := i_scheduleNumber; 
			i_zdoe_info2.i_tableName  := v_tableName; 
			i_zdoe_info2.i_refKey     := TRIM(temp_refKey2); 
			v_errorCount2             := 0; 
			b_isNoError2 := TRUE; 
			
		
			--Validation Start For TITDMGREF2 ---------- 
			IF b_isNoError2 = TRUE THEN 
						 		 
				IF NOT (itemexist.exists(TRIM(C_T9797) || TRIM(v_prodtyp2) || 1)) THEN 
					b_isNoError2                    := FALSE; 
					b_globalError                   := FALSE; 
					v_errorCount2                   := v_errorCount2 + 1; 
					t_ercode2(v_errorCount2)        := C_Z014; 
					t_errorfield2(v_errorCount2)    := 'prodtyp'; 
					t_errormsg2(v_errorCount2)      := o_errortext(C_Z014); 
					t_errorfieldval2(v_errorCount2) := TRIM(v_prodtyp2); 
					t_errorprogram2(v_errorCount2)  := i_scheduleName; 
					IF v_errorCount2                >= 5 THEN 
						GOTO insertzdoe2; 
					END IF; 
				END IF; 
			
			
				-----------------RF2:Bil not migrated---- 
				IF (TRIM(obj_refundBills2.ZIGVALUE) IS NULL) 
                --AND i_zprvaldYN = 'N' -- RF2 ITR3 code fix, pre-validation flag as Y should work
                THEN 
					b_isNoError2                  := FALSE; 
					b_globalError                 := FALSE; 
					v_errorCount2                := v_errorCount2 + 1; 
					t_ercode2(v_errorCount2)        := 'BLNM'; 
					t_errorfield2(v_errorCount2)    := ' '; 
					t_errormsg2(v_errorCount2)      := 'Bill Not migrated'; 
					t_errorfieldval2(v_errorCount2) := ' '; 
					t_errorprogram2(v_errorCount2)  := i_scheduleName; 
					  GOTO insertzdoe2; 
				END IF; 
				
				--validation END For TITDMGREF2 ---------- 
				
	
				----Common Business logic for inserting into ZDOEPF FOR TABLE TITDMGREF2--- 
				<<insertzdoe2>> 
				IF (b_isNoError2                   = FALSE) THEN 
					IF TRIM(t_ercode2(1))           IS NOT NULL THEN 
						i_zdoe_info2.i_indic          := 'E'; 
						i_zdoe_info2.i_error01        := t_ercode2(1); 
						i_zdoe_info2.i_errormsg01     := t_errormsg2(1); 
						i_zdoe_info2.i_errorfield01   := t_errorfield2(1); 
						i_zdoe_info2.i_fieldvalue01   := t_errorfieldval2(1); 
						i_zdoe_info2.i_errorprogram01 := t_errorprogram2(1); 
					END IF; 
					IF TRIM(t_ercode2(2))           IS NOT NULL THEN 
						i_zdoe_info2.i_indic          := 'E'; 
						i_zdoe_info2.i_error02        := t_ercode2(2); 
						i_zdoe_info2.i_errormsg02     := t_errormsg2(2); 
						i_zdoe_info2.i_errorfield02   := t_errorfield2(2); 
						i_zdoe_info2.i_fieldvalue02   := t_errorfieldval2(2); 
						i_zdoe_info2.i_errorprogram02 := t_errorprogram2(2); 
					END IF; 
					IF TRIM(t_ercode2(3))           IS NOT NULL THEN 
						i_zdoe_info2.i_indic          := 'E'; 
						i_zdoe_info2.i_error03        := t_ercode2(3); 
						i_zdoe_info2.i_errormsg03     := t_errormsg2(3); 
						i_zdoe_info2.i_errorfield03   := t_errorfield2(3); 
						i_zdoe_info2.i_fieldvalue03   := t_errorfieldval2(3); 
						i_zdoe_info2.i_errorprogram03 := t_errorprogram2(3); 
					END IF; 
					IF TRIM(t_ercode2(4))           IS NOT NULL THEN 
						i_zdoe_info2.i_indic          := 'E'; 
						i_zdoe_info2.i_error04        := t_ercode2(4); 
						i_zdoe_info2.i_errormsg04     := t_errormsg2(4); 
						i_zdoe_info2.i_errorfield04   := t_errorfield2(4); 
						i_zdoe_info2.i_fieldvalue04   := t_errorfieldval2(4); 
						i_zdoe_info2.i_errorprogram04 := t_errorprogram2(4); 
					END IF; 
					IF TRIM(t_ercode2(5))           IS NOT NULL THEN 
						i_zdoe_info2.i_indic          := 'E'; 
						i_zdoe_info2.i_error05        := t_ercode2(5); 
						i_zdoe_info2.i_errormsg05     := t_errormsg2(5); 
						i_zdoe_info2.i_errorfield05   := t_errorfield2(5); 
						i_zdoe_info2.i_fieldvalue05   := t_errorfieldval2(5); 
						i_zdoe_info2.i_errorprogram05 := t_errorprogram2(5); 
					END IF; 
					pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info2); 
					v_errorCount2 :=0; 
					CONTINUE again_start2; 
				END IF; 
				
				
				---Fill the Error array 
				IF b_isNoError2           = TRUE THEN 
					i_zdoe_info2.i_indic := 'S'; 
					pkg_dm_common_operations.insertintozdoe(i_zdoe_info => i_zdoe_info2); 
				END IF; 
				IF b_isNoError2 = TRUE AND i_zprvaldYN = 'N' THEN 
					  
					-- Insert in  IG Jd1dta.GPMDPF table Start-------------------------------------------- 
					--SELECT SEQ_GPMDPF.nextval INTO v_UNIQ_GPMDPF FROM dual;
                    v_UNIQ_GPMDPF := SEQ_GPMDPF.nextval;
                    obj_VIEW_DM_GPMDPF.UNIQUE_NUMBER := v_UNIQ_GPMDPF;
					obj_VIEW_DM_GPMDPF.CHDRCOY    := i_company; 
					obj_VIEW_DM_GPMDPF.CHDRNUM    := v_chdrnum1; 
					obj_VIEW_DM_GPMDPF.PRODTYP    := v_prodtyp2; 
					obj_VIEW_DM_GPMDPF.HEADCNTIND := o_defaultvalues('HEADCNTIND'); 
					obj_VIEW_DM_GPMDPF.MBRNO      := v_mbrno2;  
					obj_VIEW_DM_GPMDPF.DPNTNO     := v_dpntno2; 
					obj_VIEW_DM_GPMDPF.TRANNO     := v_tranno2; 
					obj_VIEW_DM_GPMDPF.RECNO      := o_defaultvalues('RECNO'); 
					obj_VIEW_DM_GPMDPF.PLANNO     := o_defaultvalues('PLANNO'); 
					obj_VIEW_DM_GPMDPF.SUBSCOY    := C_SUBSCOY; 
					obj_VIEW_DM_GPMDPF.SUBSNUM    := C_SUBSNUM; 
					obj_VIEW_DM_GPMDPF.BILLTYP    := o_defaultvalues('BILLTYP'); 
					obj_VIEW_DM_GPMDPF.BILLNO     := obj_refundBills2.ZIGVALUE; 
					obj_VIEW_DM_GPMDPF.EFFDATE    := v_effdate; 
					obj_VIEW_DM_GPMDPF.PPREM      := v_bprem2;  
					obj_VIEW_DM_GPMDPF.PEMXTPRM   := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.POAXTPRM   := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.INSTNO     := v_trrefnum2; 
					obj_VIEW_DM_GPMDPF.PRMFRDT    := v_prbilfdt; 
					obj_VIEW_DM_GPMDPF.PRMTODT    := v_prbiltdt; 
					obj_VIEW_DM_GPMDPF.PNIND      := o_defaultvalues('PNIND'); 
					obj_VIEW_DM_GPMDPF.MMIND      := o_defaultvalues('MMIND'); 
					obj_VIEW_DM_GPMDPF.SRCDATA    := o_defaultvalues('SRCDATA'); 
					obj_VIEW_DM_GPMDPF.BATCCOY    := i_company; 
					obj_VIEW_DM_GPMDPF.BATCBRN    := i_branch; 
					obj_VIEW_DM_GPMDPF.BATCACTYR  := i_acctYear; 
					obj_VIEW_DM_GPMDPF.BATCACTMN  := i_acctMonth; 
					obj_VIEW_DM_GPMDPF.BATCTRCD   := i_transCode; 
					obj_VIEW_DM_GPMDPF.BATCBATCH  := C_BATCBATCH; 
					obj_VIEW_DM_GPMDPF.RECTYPE    := o_defaultvalues('RECTYPE'); 
					obj_VIEW_DM_GPMDPF.JOBNOUD    := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.FLATFEE    := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.FEES       := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.EVNTFEE    := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.MFJOBNO    := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.JOBNOISS   := i_scheduleNumber; 
					obj_VIEW_DM_GPMDPF.BBJOBNO    := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.JOBNOTPA   := o_defaultvalues('ZERO'); 
					obj_VIEW_DM_GPMDPF.USRPRF     := i_userProfile; 
					obj_VIEW_DM_GPMDPF.JOBNM      := i_scheduleName; 
					obj_VIEW_DM_GPMDPF.DATIME     := sysdate; 
					INSERT INTO Jd1dta.VIEW_DM_GPMDPF VALUES obj_VIEW_DM_GPMDPF; 
					
					-- Insert Jd1dta.GPMDPF values in End---------------------------- 
   
				END IF;
			END IF;
			END LOOP; 
			EXIT WHEN refundBills_cursor2%notfound; 
			END LOOP;
		
		----------Open Cursor 3 --------------
		OPEN refundBills_cursor3 ;
			
			LOOP 
				FETCH refundBills_cursor3 bulk collect INTO refund_list3 limit C_limit;
                		<<again_start3>> 

				-- dbms_output.put_line('bulk collect call'); 
				for i in 1 .. refund_list3.count loop
    
				obj_refundBills3 := refund_list3(i);
		
		/*	LOOP 
				FETCH refundBills_cursor3 INTO obj_refundBills3; 
				EXIT 
				WHEN refundBills_cursor3%notfound; */
		
		
			b_isNoError3 := TRUE; 
					
			--Validation Start For TITDMGREF2 ---------- 
					
	
				IF  i_zprvaldYN = 'N' THEN 
					
					--------------------- Insert GBIDPF values in obj_VIEW_DM_GBIDPF START---------------------------- 					
					    --SELECT SEQ_GBIDPF.nextval INTO v_UNIQ_GBIDPF FROM dual;
                        v_UNIQ_GBIDPF := SEQ_GBIDPF.nextval; --PerfImprov

                        obj_VIEW_DM_GBIDPF.UNIQUE_NUMBER := v_UNIQ_GBIDPF;
						obj_VIEW_DM_GBIDPF.CHDRCOY    := i_company; 
						obj_VIEW_DM_GBIDPF.BILLNO     := obj_refundBills3.ZIGVALUE; 
						obj_VIEW_DM_GBIDPF.PRODTYP    := obj_refundBills3.PRODTYP; 
						obj_VIEW_DM_GBIDPF.PLANNO     := o_defaultvalues('PLANNO'); 
						obj_VIEW_DM_GBIDPF.CLASSINS   := C_CLASSINS; 
						obj_VIEW_DM_GBIDPF.BPREM      := obj_refundBills3.BPREM * -1; 
						obj_VIEW_DM_GBIDPF.BEXTPRM    := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.BCOMM      := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.BOVCOMM01  := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.BOVCOMM02  := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.DISCRATE   := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.DISCAMT    := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.BADVRFUND  := o_defaultvalues('ZERO'); --  RF3 changes	
						obj_VIEW_DM_GBIDPF.BATCCOY    := i_company; 
						obj_VIEW_DM_GBIDPF.BATCBRN    := i_branch; 
						obj_VIEW_DM_GBIDPF.BATCACTYR  := i_acctYear; 
						obj_VIEW_DM_GBIDPF.BATCACTMN  := i_acctMonth; 
						obj_VIEW_DM_GBIDPF.BATCTRCDE  := i_transCode; 
						obj_VIEW_DM_GBIDPF.BATCBATCH  := C_BATCBATCH; 
						obj_VIEW_DM_GBIDPF.TERMID     := i_vrcmTermid; 
						obj_VIEW_DM_GBIDPF.TRDT       := n_trdt;					
						obj_VIEW_DM_GBIDPF.TRTM       := i_vrcmtime; 
						obj_VIEW_DM_GBIDPF.TRANNO     := obj_refundBills3.TRANNO; 
						obj_VIEW_DM_GBIDPF.FEES       := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.VALIDFLAG  := o_defaultvalues('VALIDFLAG'); 
						obj_VIEW_DM_GBIDPF.WKLADM     := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.DISCAMT1   := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.DISCAMT2   := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.DISCRATE1  := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.DISCRATE2  := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.RIBFEE     := o_defaultvalues('RIBFEE'); 
						obj_VIEW_DM_GBIDPF.RIBFGST    := o_defaultvalues('RIBFGST'); 	
						obj_VIEW_DM_GBIDPF.USER_T     := i_vrcmuser; 
						obj_VIEW_DM_GBIDPF.ZCTAXAMT01 := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.ZCTAXAMT02 := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.ZCTAXAMT03 := o_defaultvalues('ZERO'); 
						obj_VIEW_DM_GBIDPF.GSTCOM1 	  := C_GSTCOM1;
						obj_VIEW_DM_GBIDPF.GSTCOM2 	  := C_GSTCOM2;
						obj_VIEW_DM_GBIDPF.USRPRF     := i_userProfile; 
						obj_VIEW_DM_GBIDPF.JOBNM      := i_scheduleName; 
						obj_VIEW_DM_GBIDPF.DATIME     := sysdate;
								
						INSERT INTO Jd1dta.VIEW_DM_GBIDPF VALUES obj_VIEW_DM_GBIDPF; 
						
					
					--------------------- Insert GBIDPF values in obj_VIEW_DM_GBIDPF END---------------------------- 
					
			END IF;
			END LOOP; 
			EXIT WHEN refundBills_cursor3%notfound; 
		END LOOP;
		
		
		
		CLOSE refundBills_cursor3; 
		CLOSE refundBills_cursor2; 
        
END IF;        
		CLOSE refundBills_cursor1; 

	dbms_output.put_line('Procedure execution time = ' || (dbms_utility.get_time - v_timestart) / 100);
	dbms_output.put_line('End execution of BQ9UX_BL01_REFUNDBL, SC NO:  ' ||
                        i_scheduleNumber || ' Flag :' || i_zprvaldYN);
	commit;

	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			p_exitcode := SQLCODE;
			p_exittext := 'BQ9UX_BL01_REFUNDBL : ' || i_scheduleName || ' ' ||
					 DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm ;
  
			INSERT INTO Jd1dta.dmberpf
			  (schedule_name, JOB_NUM, error_code, error_text, DATIME)
			values
			  (i_scheduleName, i_scheduleNumber, p_exitcode, p_exittext, sysdate);
		  
			commit;
    raise;

END BQ9UX_BL01_REFUNDBL;