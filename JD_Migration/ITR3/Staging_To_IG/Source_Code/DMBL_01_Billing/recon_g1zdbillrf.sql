CREATE OR REPLACE PROCEDURE Jd1dta.recon_g1zdbillrf (
        i_schedulenumber IN   VARCHAR2
) AS
    


        v_timestart             NUMBER := dbms_utility.get_time; 
		c_stgusr2_titdmgref1    NUMBER(10) DEFAULT 0;
        c_stgusr2_titdmgref2    NUMBER(10) DEFAULT 0;
		c_stgusr2_titdmgref3    NUMBER(10) DEFAULT 0;
		c_stgusr2_titdmgref4    NUMBER(10) DEFAULT 0;
		c_stgusr2_titdmgref5    NUMBER(10) DEFAULT 0;
		c_stgusr_titdmgref1     NUMBER(10) DEFAULT 0;
        c_stgusr_titdmgref2     NUMBER(10) DEFAULT 0;
		c_stgusr_titdmgref3     NUMBER(10) DEFAULT 0;
		c_stgusr_titdmgref4     NUMBER(10) DEFAULT 0;
		c_stgusr_titdmgref5     NUMBER(10) DEFAULT 0;
		c_src_titdmgref1		NUMBER(10) DEFAULT 0;
		c_src_titdmgref2		NUMBER(10) DEFAULT 0;
		c_src_titdmgref3		NUMBER(10) DEFAULT 0;
		c_src_titdmgref4		NUMBER(10) DEFAULT 0;
		c_src_titdmgref5		NUMBER(10) DEFAULT 0;
		c_stg_titdmgref1		NUMBER(10) DEFAULT 0;
		c_stg_titdmgref2		NUMBER(10) DEFAULT 0;
		c_stg_titdmgref3		NUMBER(10) DEFAULT 0;
		c_stg_titdmgref4		NUMBER(10) DEFAULT 0;
		c_stg_titdmgref5		NUMBER(10) DEFAULT 0;
        c_GBIHPF                NUMBER(10) DEFAULT 0;
		c_zreppf                NUMBER(10) DEFAULT 0;
		c_zrfdpf                NUMBER(10) DEFAULT 0;
		c_GBIDPF                NUMBER(10) DEFAULT 0;
		c_GPMDPF                NUMBER(10) DEFAULT 0;
        p_exitcode              NUMBER;
        p_exittext              VARCHAR2(2000);
        v_status                VARCHAR2(8 CHAR) := 'Pass';
        v_recon_query_id        VARCHAR2(50 CHAR) := ' ';
        v_module_name           VARCHAR2(50 CHAR) := 'Billing Refund';
        v_group_clause          VARCHAR2(50 CHAR) := ' ';
        v_where_clause          VARCHAR2(50 CHAR) := ' ';
        v_validation_type       VARCHAR2(50 CHAR) := ' ';
        v_source_value          NUMBER(10) DEFAULT 0;
        v_staging_value         NUMBER(10) DEFAULT 0;
        v_ig_value              NUMBER(10) DEFAULT 0;
        v_lettype               VARCHAR2(8 CHAR);
        v_no_data_stag1         VARCHAR2(8 CHAR) := 'N';
        v_no_data_stag2         VARCHAR2(8 CHAR) := 'N';
		v_no_data_stag3         VARCHAR2(8 CHAR) := 'N';
        v_no_data_stag4         VARCHAR2(8 CHAR) := 'N';
		v_no_data_stag5         VARCHAR2(8 CHAR) := 'N';
		v_no_data_ig1           VARCHAR2(8 CHAR) := 'N';
		v_no_data_ig2           VARCHAR2(8 CHAR) := 'N';
		v_no_data_ig3           VARCHAR2(8 CHAR) := 'N';
		v_no_data_ig4           VARCHAR2(8 CHAR) := 'N';
		v_no_data_ig5           VARCHAR2(8 CHAR) := 'N';
        recon_masterindex       INTEGER := 0;
        obj_recon_master        recon_master%rowtype;
		
		
       
-- Create the Cursors for Header File: GBIHPF START -----------------------
		-- Create the Cursor for STAGEDBUSR2 TITDMGREF1 - SOURCE DB
        CURSOR c_stgusr2_src1 IS
        SELECT   CHDRNUM, ZREFMTCD, REFNUM, COUNT(1) AS src_cnt1
        FROM
				STAGEDBUSR2.titdmgref1@dmstagedblink group by CHDRNUM, ZREFMTCD, REFNUM;

        obj_src1    c_stgusr2_src1%rowtype;
		

		-- Create the Cursor for STAGEDBUSR TITDMGREF1 - Staging DB
		
		 CURSOR c_stgusr_stg_ref1 IS
        SELECT   CHDRNUM, ZREFMTCD, REFNUM, TRANNO, COUNT(1) AS stg_cnt1
        FROM
				STAGEDBUSR.titdmgref1@dmstagedblink 
				where TRIM(CHDRNUM) = trim(obj_src1.CHDRNUM) and REFNUM = obj_src1.REFNUM
				group by CHDRNUM, ZREFMTCD, REFNUM, TRANNO;
        obj_stg1    c_stgusr_stg_ref1%rowtype;
	
			
				
		-- Create the Cursor for IG GBIHPF
        CURSOR c_ig_GBIHPF IS
        SELECT   COUNT(1)  AS  ig_GBIHPF_cnt
        FROM
                Jd1dta.GBIHPF A
		where A.BILLTYP = 'A' and trim(A.CHDRNUM) = trim(obj_stg1.CHDRNUM) and A.TRANNO = obj_stg1.TRANNO 
        and  A.JOBNM = 'G1ZDBILLRF';
		
		obj_ig_GBIHPF     c_ig_GBIHPF%rowtype;
-- Create the Cursors for Header File: GBIHPF END -----------------------			


-- Create the Cursors for Header File: ZREPPF START -----------------------
		-- Create the Cursor for STAGEDBUSR2 TITDMGREF1 - SOURCE DB
        CURSOR c_stgusr2_src2 IS
        SELECT   CHDRNUM, ZREFMTCD, REFNUM, COUNT(1) AS src_cnt2
        FROM
				STAGEDBUSR2.titdmgref1@dmstagedblink group by CHDRNUM, ZREFMTCD, REFNUM;

        obj_src2    c_stgusr2_src2%rowtype;
		

		-- Create the Cursor for STAGEDBUSR TITDMGREF1 - Staging DB
		
		 CURSOR c_stgusr_stg_ref2 IS
        SELECT   CHDRNUM, ZREFMTCD, REFNUM, TRANNO, COUNT(1) AS stg_cnt2
        FROM
				STAGEDBUSR.titdmgref1@dmstagedblink 
				where TRIM(CHDRNUM) = trim(obj_src2.CHDRNUM) and REFNUM = obj_src2.REFNUM
				group by CHDRNUM, ZREFMTCD, REFNUM, TRANNO;
        obj_stg2    c_stgusr_stg_ref2%rowtype;
	
			
				
		-- Create the Cursor for IG ZREPPF
        CURSOR c_ig_ZREPPF IS
        SELECT   COUNT(1)  AS  ig_ZREPPF_cnt
        FROM
                Jd1dta.ZREPPF A
		where trim(A.CHDRNUM) = trim(obj_stg2.CHDRNUM) and A.TRANNO = obj_stg2.TRANNO 
        and  A.JOBNM = 'G1ZDBILLRF' and trim(A.ZREFMTCD) = TRIM(obj_stg2.ZREFMTCD);
		
		obj_ig_ZREPPF     c_ig_ZREPPF%rowtype;
-- Create the Cursors for Header File: ZREPPF END -----------------------	



-- Create the Cursors for Header File: ZRFDPF START -----------------------
		-- Create the Cursor for STAGEDBUSR2 TITDMGREF1 - SOURCE DB
        CURSOR c_stgusr2_src3 IS
        SELECT   CHDRNUM, ZREFMTCD, REFNUM, COUNT(1) AS src_cnt3
        FROM
				STAGEDBUSR2.titdmgref1@dmstagedblink group by CHDRNUM, ZREFMTCD, REFNUM;

        obj_src3    c_stgusr2_src3%rowtype;
		

		-- Create the Cursor for STAGEDBUSR TITDMGREF1 - Staging DB
		
		 CURSOR c_stgusr_stg_ref3 IS
        SELECT   CHDRNUM, ZREFMTCD, REFNUM, TRANNO, COUNT(1) AS stg_cnt3
        FROM
				STAGEDBUSR.titdmgref1@dmstagedblink 
				where TRIM(CHDRNUM) = trim(obj_src3.CHDRNUM) and REFNUM = obj_src3.REFNUM
				group by CHDRNUM, ZREFMTCD, REFNUM, TRANNO;
        obj_stg3    c_stgusr_stg_ref3%rowtype;
	
			
				
		-- Create the Cursor for IG ZRFDPF
        CURSOR c_ig_ZRFDPF IS
        SELECT   COUNT(1)  AS  ig_ZRFDPF_cnt
        FROM
                Jd1dta.ZRFDPF A
		where trim(A.CHDRNUM) = trim(obj_stg3.CHDRNUM) and A.TRANNO = obj_stg3.TRANNO 
        and  A.JOBNM = 'G1ZDBILLRF' and trim(A.ZREFMTCD) = TRIM(obj_stg3.ZREFMTCD);
		
		obj_ig_ZRFDPF     c_ig_ZRFDPF%rowtype;
-- Create the Cursors for Header File: ZRFDPF END -----------------------	




-- Create the Cursors for Details File for GPMDPF Start -----------------------

		-- Create the Cursor for STAGEDBUSR2 TITDMGREF2 - SOURCE DB
        CURSOR c_stgusr2_src4 IS
        SELECT   A.CHDRNUM, A.TRREFNUM, COUNT(1) AS src_cnt4
        FROM
				STAGEDBUSR2.titdmgref2@dmstagedblink A
		group by A.CHDRNUM, A.TRREFNUM;
		
        obj_src4    c_stgusr2_src4%rowtype;
			

		-- Create the Cursor for STAGEDBUSR TITDMGREF2 - Staging DB
		
		 CURSOR c_stgusr_stg_ref4 IS
        SELECT   A.CHDRNUM, A.TRREFNUM, A.TRANNO, COUNT(1) AS stg_cnt4
        FROM
				STAGEDBUSR.titdmgref2@dmstagedblink A
				where TRIM(A.CHDRNUM) = trim(obj_src1.CHDRNUM) and trim(A.TRREFNUM) = trim(obj_src1.REFNUM)
				and TRIM(A.CHDRNUM) = trim(obj_src4.CHDRNUM)
				group by A.CHDRNUM, A.TRREFNUM, A.TRANNO;				

        obj_stg4    c_stgusr_stg_ref4%rowtype;
		
		
		-- Create the Cursor for IG GPMDPF
        CURSOR c_ig_GPMDPF IS
        SELECT   A.CHDRNUM, A.TRANNO, COUNT(1)  AS  ig_GPMDPF_cnt
        FROM
                Jd1dta.GPMDPF A, Jd1dta.GBIHPF B
		where B.BILLTYP = 'A' and trim(B.CHDRNUM) = trim(obj_stg4.CHDRNUM) and B.TRANNO = obj_stg4.TRANNO
		and trim(B.CHDRNUM) = trim(A.CHDRNUM) and A.BILLNO = B.BILLNO and A.TRANNO = B.TRANNO
		group by A.CHDRNUM, A.TRANNO
		order by A.CHDRNUM, A.TRANNO;	
	
		obj_ig_GPMDPF     c_ig_GPMDPF%rowtype;
		

-- Create the Cursors for Details File: GPMDPF END -------------------------

-- Create the Cursors for Details File: GBIDPF Start -----------------------

		-- Create the Cursor for STAGEDBUSR2 TITDMGREF2 - SOURCE DB
        CURSOR c_stgusr2_src5 IS
        SELECT   A.CHDRNUM, A.ZREFMTCD, A.PRODTYP, A.TRREFNUM, SUM(A.BPREM) as BPREM, COUNT(1) AS src_cnt5
        FROM
				STAGEDBUSR2.titdmgref2@dmstagedblink A
		group by A.CHDRNUM, A.ZREFMTCD, A.PRODTYP,A.TRREFNUM;
		
        obj_src5    c_stgusr2_src5%rowtype;
		
		

		-- Create the Cursor for STAGEDBUSR TITDMGREF2 - Staging DB
		
		CURSOR c_stgusr_stg_ref5 IS
        SELECT   A.CHDRNUM, A.PRODTYP, A.TRREFNUM, A.TRANNO, SUM(A.BPREM) as BPREM,  COUNT(1) AS stg_cnt5
        FROM
				STAGEDBUSR.titdmgref2@dmstagedblink A
				where TRIM(A.CHDRNUM) = trim(obj_src5.CHDRNUM) and trim(A.TRREFNUM) = trim(obj_src5.TRREFNUM)
				group by A.CHDRNUM,A.PRODTYP, A.TRREFNUM, A.TRANNO;				

        obj_stg5    c_stgusr_stg_ref5%rowtype;
		
				
		-- Create the Cursor for IG GBIDPF
        CURSOR c_ig_GBIDPF IS
        SELECT   A.BILLNO, A.PRODTYP, A.TRANNO, A.BPREM, COUNT(1)  AS  ig_GBIDPF_cnt
        FROM
                Jd1dta.GBIDPF A, Jd1dta.GBIHPF B 
		where B.BILLTYP = 'A' and trim(B.CHDRNUM) = trim(obj_stg5.CHDRNUM) and A.TRANNO = obj_stg5.TRANNO
		 and  B.BILLNO = A.BILLNO 
		group by A.BILLNO, A.PRODTYP, A.TRANNO,A.BPREM;
		
		obj_ig_GBIDPF     c_ig_GBIDPF%rowtype;	

BEGIN
        dbms_output.put_line('Start execution of recon_g1zdbillrf, SC NO:  '
                             || i_schedulenumber
                             || ' Flag :'
                             || 'Y');
							 
-- Create the Cursors for HEADER COUNT START ---------------------------------------------

-- Create the Cursors for HEADER Table: GBIHPF START -----------------------		
		--Source Count					 
		SELECT
                COUNT(1)
        INTO c_src_titdmgref1
        FROM
                STAGEDBUSR2.titdmgref1@dmstagedblink;		
		dbms_output.put_line('Source Table Count: '||' '|| c_src_titdmgref1);
				
        --Staging Count
		SELECT
                COUNT(1)
        INTO c_stg_titdmgref1
        FROM
                STAGEDBUSR.titdmgref1@dmstagedblink ;
		dbms_output.put_line('Staging Table Count: '||' '|| c_stg_titdmgref1);
				
		--IG Table: GBIHPF Count
		
		SELECT
                COUNT(1) into c_GBIHPF
        FROM  Jd1dta.gbihpf A
        where  A.JOBNM = 'G1ZDBILLRF' and A.BILLTYP = 'A';
        dbms_output.put_line('IG Table: GBIHPF - Count: '||' '|| c_GBIHPF); 
		
-- Create the Cursors for HEADER Table: GBIHPF END ---------------------------------


	
							 
-- Create the Cursors for HEADER Table: ZREPPF START -----------------------	
		--Source Count					 
		SELECT
                 COUNT(distinct CHDRNUM)
        INTO c_src_titdmgref2
        FROM
                STAGEDBUSR2.titdmgref1@dmstagedblink;		
		dbms_output.put_line('Source Table Count: '||' '|| c_src_titdmgref2);
				
        --Staging Count
		SELECT
				COUNT(distinct CHDRNUM)
        INTO c_stg_titdmgref2
        FROM
                STAGEDBUSR.titdmgref1@dmstagedblink ;
		dbms_output.put_line('Staging Table Count: '||' '|| c_stg_titdmgref2);
				
		
		--IG Table: ZREPPF Count
		
		SELECT
                COUNT(1) into c_ZREPPF
        FROM  Jd1dta.ZREPPF A
        where  A.JOBNM = 'G1ZDBILLRF';
        dbms_output.put_line('IG Table: ZREPPF Count: '||' '|| c_ZREPPF);
-- Create the Cursors for HEADER Table: ZREPPF END ---------------------------------


-- Create the Cursors for HEADER Table: ZRFDPF START -----------------------	
		--Source Count					 
		SELECT
                COUNT(1)
        INTO c_src_titdmgref3
        FROM
                STAGEDBUSR2.titdmgref1@dmstagedblink;		
		dbms_output.put_line('Source Table Count: '||' '|| c_src_titdmgref3);
				
        --Staging Count
		SELECT
                COUNT(1)
        INTO c_stg_titdmgref3
        FROM
                STAGEDBUSR.titdmgref1@dmstagedblink ;
		dbms_output.put_line('Staging Table Count: '||' '|| c_stg_titdmgref3);
			

		--IG Table: ZRFDPF Count
		
		SELECT
                COUNT(1) into c_ZRFDPF
        FROM  Jd1dta.ZRFDPF A
        where  A.JOBNM = 'G1ZDBILLRF';
        dbms_output.put_line('IG Table: ZRFDPF - Count: '||' '|| c_ZRFDPF);
					
-- Create the Cursors for HEADER Table: ZRFDPF END ---------------------------------


-- Create the Cursors for DETAIL: GPMDPF COUNT START -----------------------
--Source Count					 
		SELECT
                COUNT(1)
        INTO c_src_titdmgref4
        FROM
                STAGEDBUSR2.titdmgref2@dmstagedblink;		
		dbms_output.put_line('Source Table Count: '||' '|| c_src_titdmgref4);
				
        --Staging Count
		SELECT
                COUNT(1)
        INTO c_stg_titdmgref4
        FROM
                STAGEDBUSR.titdmgref2@dmstagedblink ;
		dbms_output.put_line('Staging Table Count: '||' '|| c_stg_titdmgref4);
				
		--IG Table: GPMDPF Count
		
		SELECT
                COUNT(1) INTO c_GPMDPF
        FROM  Jd1dta.GPMDPF A, Jd1dta.GBIHPF B
        where  A.JOBNM = 'G1ZDBILLRF' and B.JOBNM = A.JOBNM and B.BILLTYP = 'A'
        and TRIM(A.CHDRNUM) = TRIM(B.CHDRNUM) 
        and A.TRANNO = B.TRANNO and A.BILLNO = B.BILLNO;
        dbms_output.put_line('IG Table GPMDPF Count  : '||' '|| c_GPMDPF); 
-- Create the Cursors for DETAIL: GPMDPF COUNT END -------------------------

-- Create the Cursors for DETAIL: GBIDPF COUNT START -----------------------
		--Source Count	
		SELECT
                COUNT(1) INTO c_src_titdmgref5
        FROM
                (SELECT
                A.CHDRNUM, A.ZREFMTCD, A.PRODTYP, A.TRREFNUM, COUNT(1) 
        FROM
                STAGEDBUSR2.titdmgref2@dmstagedblink A
		group by A.CHDRNUM, A.ZREFMTCD, A.PRODTYP,A.TRREFNUM);		
		dbms_output.put_line('Source Table Count for GBIDPF: '||' '|| c_src_titdmgref5);
			
        --Staging Count
		SELECT  COUNT(1) INTO c_stg_titdmgref5
        FROM (SELECT   A.CHDRNUM,  A.PRODTYP, A.TRREFNUM, COUNT(1) 
        FROM 
				STAGEDBUSR.titdmgref2@dmstagedblink A
				group by A.CHDRNUM,  A.PRODTYP, A.TRREFNUM);
		dbms_output.put_line('Staging Table Count for GBIDPF: '||' '|| c_stg_titdmgref5);

				
		--IG Table: GBIDPF  Count
		
		SELECT COUNT(1) into c_GBIDPF
        FROM  Jd1dta.gbihpf A, Jd1dta.GBIDPF B
        where  A.JOBNM = 'G1ZDBILLRF' and B.JOBNM = A.JOBNM and A.BILLNO = B.BILLNO and A.BILLTYP = 'A'
        and A.TRANNO = B.TRANNO ;	
        dbms_output.put_line('IG Table Count GBIDPF : '||' '|| c_GBIDPF); 
-- Create the Cursors for DETAIL: GBIDPF COUNT END -------------------------


		
--------------------------------------------------------------------------------------------------------------
-------------GBIHPF START --------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------		
        IF c_src_titdmgref1 <> c_stg_titdmgref1 OR c_stg_titdmgref1 <> c_GBIHPF THEN
				
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
                obj_recon_master.where_clause := 'BILL TYPE = A';
				obj_recon_master.group_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref1;
                obj_recon_master.staging_value := c_stg_titdmgref1;
                obj_recon_master.ig_value := c_GBIHPF;
                obj_recon_master.status := 'Fail';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: GBIHPF';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                OPEN c_stgusr2_src1;
                << skiprecord >> LOOP
                        FETCH c_stgusr2_src1 INTO obj_src1;
                        EXIT WHEN c_stgusr2_src1%notfound;
                        recon_masterindex := recon_masterindex + 1;
                        v_no_data_stag1 := 'Y';
                        OPEN c_stgusr_stg_ref1;
                        << skiprecord >> LOOP
                                FETCH c_stgusr_stg_ref1 INTO obj_stg1;
                                EXIT WHEN c_stgusr_stg_ref1%notfound;
                                v_no_data_stag1 := 'N';
                                v_no_data_ig1 := 'Y';
                                OPEN c_ig_GBIHPF;
                                << skiprecord >> LOOP
                                        FETCH c_ig_GBIHPF INTO obj_ig_GBIHPF;
                                        EXIT WHEN c_ig_GBIHPF%notfound;
																				
												v_no_data_ig1 := 'N';
												IF obj_src1.src_cnt1 <> obj_stg1.stg_cnt1 OR obj_stg1.stg_cnt1 <> obj_ig_GBIHPF.ig_GBIHPF_cnt THEN

													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, REFNUM';
													obj_recon_master.where_clause := 'BILLTYPE  = A ' ;
													obj_recon_master.validation_type := 'Count OF ' || obj_src1.CHDRNUM || ' - ' || obj_src1.ZREFMTCD || ' - ' || obj_src1.REFNUM;
													obj_recon_master.source_value := obj_src1.src_cnt1;
													obj_recon_master.staging_value := obj_stg1.stg_cnt1;
													obj_recon_master.ig_value := obj_ig_GBIHPF.ig_GBIHPF_cnt;
													obj_recon_master.status := 'Fail';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: GBIHPF';

												ELSE
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, REFNUM';
													obj_recon_master.where_clause := 'BILLTYPE  =  A' ;
													obj_recon_master.validation_type := 'Count OF ' || obj_src1.CHDRNUM || ' - ' || obj_src1.ZREFMTCD || ' - ' || obj_src1.REFNUM;
													obj_recon_master.source_value := obj_src1.src_cnt1;
													obj_recon_master.staging_value := obj_stg1.stg_cnt1;
													obj_recon_master.ig_value := obj_ig_GBIHPF.ig_GBIHPF_cnt;	
													obj_recon_master.status := 'Pass';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: GBIHPF';

												END IF;
											
                                END LOOP;
								
								
                                CLOSE c_ig_GBIHPF;
                                IF v_no_data_ig1 = 'Y' THEN
                                        obj_recon_master.schedule_id := i_schedulenumber;
                                        obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                        obj_recon_master.module_name := 'BILLREFUND';
										obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, REFNUM';
                                        obj_recon_master.where_clause := 'BILLTYPE  = A ';
                                        obj_recon_master.validation_type := 'Count OF ' || obj_src1.CHDRNUM || ' - ' || obj_src1.ZREFMTCD || ' - ' || obj_src1.REFNUM;
                                        obj_recon_master.source_value := obj_src1.src_cnt1;
                                        obj_recon_master.staging_value := obj_stg1.stg_cnt1;
                                        obj_recon_master.ig_value := 0;
                                        obj_recon_master.status := 'Fail';
                                        obj_recon_master.rundate := SYSDATE;
										obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: GBIHPF';
                                        v_no_data_ig1 := 'N';
                                END IF;

                        END LOOP;

                        CLOSE c_stgusr_stg_ref1;
                        IF v_no_data_stag1 = 'Y' THEN
                                obj_recon_master.schedule_id := i_schedulenumber;
                                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                obj_recon_master.module_name := 'BILLREFUND';
								obj_recon_master.group_clause := 'CHDRNUM';
                                obj_recon_master.where_clause := 'BILLTYPE  =  A' ;
                                obj_recon_master.validation_type := 'Count OF ' || obj_src1.CHDRNUM;
                                obj_recon_master.source_value := obj_src1.src_cnt1;
                                obj_recon_master.staging_value := 0;
                                obj_recon_master.status := 'Fail';
                                obj_recon_master.rundate := SYSDATE;
								obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: GBIHPF';
                                v_no_data_stag1 := 'N';
                        END IF;

                        INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                END LOOP;

                CLOSE c_stgusr2_src1;
        ELSE
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
                obj_recon_master.where_clause := 'BILL TYPE = A';
                obj_recon_master.group_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref1;
                obj_recon_master.staging_value := c_stg_titdmgref1;
                obj_recon_master.ig_value := c_GBIHPF;
                obj_recon_master.status := 'Pass';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: GBIHPF';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

        END IF;
------------------------------------------------------------------------------------------------------------
-------------GBIHPF END --------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------


		
--------------------------------------------------------------------------------------------------------------
-------------ZREPPF START-------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------		
        IF c_src_titdmgref2 <> c_stg_titdmgref2 OR c_stg_titdmgref2 <> c_ZREPPF THEN
				
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
                obj_recon_master.where_clause := '';
				obj_recon_master.group_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref2;
                obj_recon_master.staging_value := c_stg_titdmgref2;
                obj_recon_master.ig_value := c_ZREPPF;
                obj_recon_master.status := 'Fail';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZREPPF';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                OPEN c_stgusr2_src2;
                << skiprecord >> LOOP
                        FETCH c_stgusr2_src2 INTO obj_src2;
                        EXIT WHEN c_stgusr2_src2%notfound;
                        recon_masterindex := recon_masterindex + 1;
                        v_no_data_stag2 := 'Y';
                        OPEN c_stgusr_stg_ref2;
                        << skiprecord >> LOOP
                                FETCH c_stgusr_stg_ref2 INTO obj_stg1;
                                EXIT WHEN c_stgusr_stg_ref2%notfound;
                                v_no_data_stag2 := 'N';
                                v_no_data_ig2 := 'Y';
                                OPEN c_ig_ZREPPF;
                                << skiprecord >> LOOP
                                        FETCH c_ig_ZREPPF INTO obj_ig_GBIHPF;
                                        EXIT WHEN c_ig_ZREPPF%notfound;
																				
												v_no_data_ig2 := 'N';
												IF obj_src2.src_cnt2 <> obj_stg2.stg_cnt2 OR obj_stg2.stg_cnt2 <> obj_ig_ZREPPF.ig_ZREPPF_cnt THEN
											  
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, REFNUM';
													obj_recon_master.where_clause := '' ;
													obj_recon_master.validation_type := 'Count';
													obj_recon_master.source_value := obj_src2.src_cnt2;
													obj_recon_master.staging_value := obj_stg2.stg_cnt2;
													obj_recon_master.ig_value := obj_ig_ZREPPF.ig_ZREPPF_cnt;
													obj_recon_master.status := 'Fail';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZREPPF';

												ELSE
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, REFNUM';
													obj_recon_master.where_clause := '' ;
													obj_recon_master.validation_type := 'Count';
													obj_recon_master.source_value := obj_src2.src_cnt2;
													obj_recon_master.staging_value := obj_stg2.stg_cnt2;
													obj_recon_master.ig_value := obj_ig_ZREPPF.ig_ZREPPF_cnt;	
													obj_recon_master.status := 'Pass';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZREPPF';

												END IF;
											
                                END LOOP;
								
								
                                CLOSE c_ig_ZREPPF;
                                IF v_no_data_ig2 = 'Y' THEN
                                        obj_recon_master.schedule_id := i_schedulenumber;
                                        obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                        obj_recon_master.module_name := 'BILLREFUND';
										obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, REFNUM';
                                        obj_recon_master.where_clause := '';
                                        obj_recon_master.validation_type := 'Count';
                                        obj_recon_master.source_value := obj_src2.src_cnt2;
                                        obj_recon_master.staging_value := obj_stg2.stg_cnt2;
                                        obj_recon_master.ig_value := 0;
                                        obj_recon_master.status := 'Fail';
                                        obj_recon_master.rundate := SYSDATE;
										obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZREPPF';
                                        v_no_data_ig2 := 'N';
                                END IF;

                        END LOOP;

                        CLOSE c_stgusr_stg_ref2;
                        IF v_no_data_stag2 = 'Y' THEN
                                obj_recon_master.schedule_id := i_schedulenumber;
                                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                obj_recon_master.module_name := 'BILLREFUND';
								obj_recon_master.group_clause := 'CHDRNUM';
                                obj_recon_master.where_clause := '' ;
                                obj_recon_master.validation_type := 'Count';
                                obj_recon_master.source_value := obj_src2.src_cnt2;
                                obj_recon_master.staging_value := 0;
                                obj_recon_master.status := 'Fail';
                                obj_recon_master.rundate := SYSDATE;
								obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZREPPF';
                                v_no_data_stag2 := 'N';
                        END IF;

                        INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                END LOOP;

                CLOSE c_stgusr2_src2;
        ELSE
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
                obj_recon_master.where_clause := '';
                obj_recon_master.group_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref2;
                obj_recon_master.staging_value := c_stg_titdmgref2;
                obj_recon_master.ig_value := c_ZREPPF;
                obj_recon_master.status := 'Pass';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZREPPF';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

        END IF;
------------------------------------------------------------------------------------------------
------------- ZREPPF END -----------------------------------------------------------------------
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
-------------------ZRFDPF START ----------------------------------------------------------------
------------------------------------------------------------------------------------------------

									
        IF c_src_titdmgref3 <> c_stg_titdmgref3 OR c_stg_titdmgref3 <> c_ZRFDPF THEN
					
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
                obj_recon_master.where_clause := '';
				obj_recon_master.group_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref3;
                obj_recon_master.staging_value := c_stg_titdmgref3;
                obj_recon_master.ig_value := c_ZRFDPF;
                obj_recon_master.status := 'Fail';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZRFDPF';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                OPEN c_stgusr2_src3;
                << skiprecord >> LOOP
                        FETCH c_stgusr2_src3 INTO obj_src1;
                        EXIT WHEN c_stgusr2_src3%notfound;
                        recon_masterindex := recon_masterindex + 1;
                        v_no_data_stag3 := 'Y';
                        OPEN c_stgusr_stg_ref3;
                        << skiprecord >> LOOP
                                FETCH c_stgusr_stg_ref3 INTO obj_stg1;
                                EXIT WHEN c_stgusr_stg_ref3%notfound;
                                v_no_data_stag3 := 'N';
                                v_no_data_ig3 := 'Y';
                                OPEN c_ig_ZRFDPF;
                                << skiprecord >> LOOP
                                        FETCH c_ig_ZRFDPF INTO obj_ig_ZRFDPF;
                                        EXIT WHEN c_ig_ZRFDPF%notfound;
																				
												v_no_data_ig3 := 'N';
												IF obj_src3.src_cnt3 <> obj_stg3.stg_cnt3 OR obj_stg3.stg_cnt3 <> obj_ig_ZRFDPF.ig_ZRFDPF_cnt THEN
										
									  
													dbms_output.put_line('IG Value: '||' '|| obj_ig_ZRFDPF.ig_ZRFDPF_cnt);
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, TRREFNUM';
													obj_recon_master.where_clause := '' ;
													obj_recon_master.validation_type := 'Count';
													obj_recon_master.source_value := obj_src3.src_cnt3;
													obj_recon_master.staging_value := obj_stg3.stg_cnt3;
													obj_recon_master.ig_value := obj_ig_ZRFDPF.ig_ZRFDPF_cnt;
													obj_recon_master.status := 'Fail';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZRFDPF';

												ELSE
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, REFNUM';
													obj_recon_master.where_clause := '' ;
													obj_recon_master.validation_type := 'Count';
													obj_recon_master.source_value := obj_src3.src_cnt3;
													obj_recon_master.staging_value := obj_stg3.stg_cnt3;
													obj_recon_master.ig_value := obj_ig_ZRFDPF.ig_ZRFDPF_cnt;		
													obj_recon_master.status := 'Pass';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZRFDPF';

												END IF;
											
                                END LOOP;
								
								
                                CLOSE c_ig_ZRFDPF;
                                IF v_no_data_ig3 = 'Y' THEN
                                        obj_recon_master.schedule_id := i_schedulenumber;
                                        obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                        obj_recon_master.module_name := 'BILLREFUND';
										obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, REFNUM';
                                        obj_recon_master.where_clause := '';
                                        obj_recon_master.validation_type := 'Count';
                                        obj_recon_master.source_value := obj_src3.src_cnt3;
                                        obj_recon_master.staging_value := obj_stg3.stg_cnt3;
                                        obj_recon_master.ig_value := 0;
                                        obj_recon_master.status := 'Fail';
                                        obj_recon_master.rundate := SYSDATE;
										obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZRFDPF';
                                        v_no_data_ig3 := 'N';
                                END IF;

                        END LOOP;

                        CLOSE c_stgusr_stg_ref3;
                        IF v_no_data_stag3 = 'Y' THEN
                                obj_recon_master.schedule_id := i_schedulenumber;
                                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                obj_recon_master.module_name := 'BILLREFUND';
								obj_recon_master.group_clause := 'CHDRNUM';
                                obj_recon_master.where_clause := '' ;
                                obj_recon_master.validation_type := 'Count';
                                obj_recon_master.source_value := obj_src3.src_cnt3;
                                obj_recon_master.staging_value := 0;
                                obj_recon_master.status := 'Fail';
                                obj_recon_master.rundate := SYSDATE;
								obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZRFDPF';
                                v_no_data_stag3 := 'N';
                        END IF;

                        INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                END LOOP;

                CLOSE c_stgusr2_src3;
        ELSE
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
                obj_recon_master.where_clause := '';
                obj_recon_master.group_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref3;
                obj_recon_master.staging_value := c_stg_titdmgref3;
                obj_recon_master.ig_value := c_ZRFDPF;
                obj_recon_master.status := 'Pass';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF1 || stg count: STAGEDBUSR.TITDMGREF1 || IG count: ZRFDPF';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

        END IF;
--------------------------------------------------------------------------------------------------------------
------------- ZRFDPF END -------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
	
		
----------------------------------------------------------------------------------------------
-------------GPMDPF START --------------------------------------------------------------------
----------------------------------------------------------------------------------------------

IF c_src_titdmgref4 <> c_stg_titdmgref4 OR c_stg_titdmgref4 <> c_GPMDPF THEN
				
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
				obj_recon_master.group_clause := '';
				obj_recon_master.where_clause := 'BILL TYPE = A';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref4;
                obj_recon_master.staging_value := c_stg_titdmgref4;
                obj_recon_master.ig_value := c_GPMDPF;
                obj_recon_master.status := 'Fail';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GPMDPF';
				
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                OPEN c_stgusr2_src4;
                << skiprecord >> LOOP
                        FETCH c_stgusr2_src4 INTO obj_src4;
                        EXIT WHEN c_stgusr2_src4%notfound;
                        recon_masterindex := recon_masterindex + 1;
                        v_no_data_stag4 := 'Y';
                        OPEN c_stgusr_stg_ref4;
                        << skiprecord >> LOOP
                                FETCH c_stgusr_stg_ref4 INTO obj_stg4;
                                EXIT WHEN c_stgusr_stg_ref4%notfound;
                                v_no_data_stag4 := 'N';
                                v_no_data_ig4 := 'Y';
                                OPEN c_ig_GPMDPF;
                                << skiprecord >> LOOP
                                        FETCH c_ig_GPMDPF INTO obj_ig_GPMDPF;
                                        EXIT WHEN c_ig_GPMDPF%notfound;
																				
												v_no_data_ig4 := 'N';
												IF obj_src4.src_cnt4 <> obj_stg4.stg_cnt4 OR obj_stg4.stg_cnt4 <> obj_ig_GPMDPF.ig_GPMDPF_cnt THEN
										
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM';
													obj_recon_master.where_clause := 'BILLTYPE  = A ' ;
													obj_recon_master.validation_type := 'Count'  ;
													obj_recon_master.source_value := obj_src4.src_cnt4;
													obj_recon_master.staging_value := obj_stg4.stg_cnt4;
													obj_recon_master.ig_value := obj_ig_GPMDPF.ig_GPMDPF_cnt;
													obj_recon_master.status := 'Fail';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GPMDPF';

												ELSE
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM';
													obj_recon_master.where_clause := 'BILLTYPE  =  A' ;
													obj_recon_master.validation_type := 'Count' ;
													obj_recon_master.source_value := obj_src4.src_cnt4;
													obj_recon_master.staging_value := obj_stg4.stg_cnt4;
													obj_recon_master.ig_value := obj_ig_GPMDPF.ig_GPMDPF_cnt;		
													obj_recon_master.status := 'Pass';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GPMDPF';

												END IF;
											
                                END LOOP;
								
								
                                CLOSE c_ig_GPMDPF;
                                IF v_no_data_ig4 = 'Y' THEN
                                        obj_recon_master.schedule_id := i_schedulenumber;
                                        obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                        obj_recon_master.module_name := 'BILLREFUND';
										obj_recon_master.group_clause := 'CHDRNUM, TRREFNUM';
                                        obj_recon_master.where_clause := 'BILLTYPE  = A ';
                                        obj_recon_master.validation_type := 'Count';
                                        obj_recon_master.source_value := obj_src4.src_cnt4;
                                        obj_recon_master.staging_value := obj_stg4.stg_cnt4;
                                        obj_recon_master.ig_value := 0;
                                        obj_recon_master.status := 'Fail';
                                        obj_recon_master.rundate := SYSDATE;
										obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GPMDPF';
                                        v_no_data_ig4 := 'N';
                                END IF;

                        END LOOP;

                        CLOSE c_stgusr_stg_ref4;
                        IF v_no_data_stag4 = 'Y' THEN
                                obj_recon_master.schedule_id := i_schedulenumber;
                                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                obj_recon_master.module_name := 'BILLREFUND';
								obj_recon_master.group_clause := 'CHDRNUM, TRREFNUM';
                                obj_recon_master.where_clause := 'BILLTYPE  =  A' ;
                                obj_recon_master.validation_type := 'Count';
                                obj_recon_master.source_value := obj_src4.src_cnt4;
                                obj_recon_master.staging_value := 0;
                                obj_recon_master.status := 'Fail';
                                obj_recon_master.rundate := SYSDATE;
								obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GPMDPF';
                                v_no_data_stag4 := 'N';
                        END IF;

                        INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                END LOOP;

                CLOSE c_stgusr2_src4;
        ELSE
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
				obj_recon_master.group_clause := '';
                obj_recon_master.where_clause := 'BILL TYPE = A';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref4;
                obj_recon_master.staging_value := c_stg_titdmgref4;
                obj_recon_master.ig_value := c_GPMDPF;
                obj_recon_master.status := 'Pass';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GPMDPF';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

        END IF;
--------------------------------------------------------------------------------------------
-------------GPMDPF END --------------------------------------------------------------------
--------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-------------GBIDPF START --------------------------------------------------------------------
----------------------------------------------------------------------------------------------

IF c_src_titdmgref5 <> c_stg_titdmgref5 OR c_stg_titdmgref5 <> c_GBIDPF THEN
				
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
                obj_recon_master.group_clause := 'CHDRNUM , PRODTYP, TRANNO';
                obj_recon_master.where_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref5;
                obj_recon_master.staging_value := c_stg_titdmgref5;
                obj_recon_master.ig_value := c_GBIDPF;
                obj_recon_master.status := 'Fail';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GBIDPF';
                INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                OPEN c_stgusr2_src5;
                << skiprecord >> LOOP
                        FETCH c_stgusr2_src5 INTO obj_src5;
                        EXIT WHEN c_stgusr2_src5%notfound;
                        recon_masterindex := recon_masterindex + 1;
                        v_no_data_stag5 := 'Y';
                        OPEN c_stgusr_stg_ref5;
                        << skiprecord >> LOOP
                                FETCH c_stgusr_stg_ref5 INTO obj_stg5;
                                EXIT WHEN c_stgusr_stg_ref5%notfound;
                                v_no_data_stag5 := 'N';
                                v_no_data_ig5 := 'Y';
                                OPEN c_ig_GBIDPF;
                                << skiprecord >> LOOP
                                        FETCH c_ig_GBIDPF INTO obj_ig_GBIDPF;
                                        EXIT WHEN c_ig_GBIDPF%notfound;
																				
												v_no_data_ig5 := 'N';
												IF obj_src5.src_cnt5 <> obj_stg5.stg_cnt5 OR obj_stg5.stg_cnt5 <> obj_ig_GBIDPF.ig_GBIDPF_cnt THEN
										
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, TRREFNUM';
													obj_recon_master.where_clause := '' ;
													obj_recon_master.validation_type := 'Count';
													obj_recon_master.source_value := obj_src5.src_cnt5;
													obj_recon_master.staging_value := obj_stg5.stg_cnt5;
													obj_recon_master.ig_value := obj_ig_GBIDPF.ig_GBIDPF_cnt;
													obj_recon_master.status := 'Fail';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GBIDPF';

												ELSE
													obj_recon_master.schedule_id := i_schedulenumber;
													obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
													obj_recon_master.module_name := 'BILLREFUND';
													obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, TRREFNUM';
													obj_recon_master.where_clause := '' ;
													obj_recon_master.validation_type := 'Count';
													obj_recon_master.source_value := obj_src5.src_cnt5;
													obj_recon_master.staging_value := obj_stg5.stg_cnt5;
													obj_recon_master.ig_value := obj_ig_GBIDPF.ig_GBIDPF_cnt;	
													obj_recon_master.status := 'Pass';
													obj_recon_master.rundate := SYSDATE;
													obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GBIDPF';

												END IF;
											
                                END LOOP;
								
								
                                CLOSE c_ig_GBIDPF;
                                IF v_no_data_ig5 = 'Y' THEN
                                        obj_recon_master.schedule_id := i_schedulenumber;
                                        obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                        obj_recon_master.module_name := 'BILLREFUND';
										obj_recon_master.group_clause := 'CHDRNUM, ZREFMTCD, TRREFNUM';
                                        obj_recon_master.where_clause := '';
                                        obj_recon_master.validation_type := 'Count';
                                        obj_recon_master.source_value := obj_src5.src_cnt5;
                                        obj_recon_master.staging_value := obj_stg5.stg_cnt5;
                                        obj_recon_master.ig_value := 0;
                                        obj_recon_master.status := 'Fail';
                                        obj_recon_master.rundate := SYSDATE;
										obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GBIDPF';
                                        v_no_data_ig5 := 'N';
                                END IF;

                        END LOOP;

                        CLOSE c_stgusr_stg_ref5;
                        IF v_no_data_stag5 = 'Y' THEN
                                obj_recon_master.schedule_id := i_schedulenumber;
                                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                                obj_recon_master.module_name := 'BILLREFUND';
								obj_recon_master.group_clause := 'CHDRNUM';
                                obj_recon_master.where_clause := 'BILLTYPE  =  A' ;
                                obj_recon_master.validation_type := 'Count' ;
                                obj_recon_master.source_value := obj_src5.src_cnt5;
                                obj_recon_master.staging_value := 0;
                                obj_recon_master.status := 'Fail';
                                obj_recon_master.rundate := SYSDATE;
								obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GBIDPF';
                                v_no_data_stag5 := 'N';
                        END IF;

                        INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;

                END LOOP;

                CLOSE c_stgusr2_src5;
        ELSE
                recon_masterindex := recon_masterindex + 1;
                obj_recon_master.schedule_id := i_schedulenumber;
                obj_recon_master.recon_query_id := 'BILLREFUND0' || recon_masterindex;
                obj_recon_master.module_name := 'BILLREFUND';
				obj_recon_master.group_clause := 'CHDRNUM, PRODTYP, TRANNO';
                obj_recon_master.where_clause := '';
                obj_recon_master.validation_type := 'Count';
                obj_recon_master.source_value := c_src_titdmgref5;
                obj_recon_master.staging_value := c_stg_titdmgref5;
                obj_recon_master.ig_value := c_GBIDPF;
                obj_recon_master.status := 'Pass';
                obj_recon_master.rundate := SYSDATE;
				obj_recon_master.QUERY_DESC := 'Src count: STAGEDBUSR2.TITDMGREF2 || stg count: STAGEDBUSR.TITDMGREF2 || IG count: GBIDPF';
				INSERT INTO Jd1dta.recon_master VALUES obj_recon_master;
				

        END IF;
--------------------------------------------------------------------------------------------
-------------GBIDPF END --------------------------------------------------------------------
--------------------------------------------------------------------------------------------

        COMMIT;
EXCEPTION
        WHEN OTHERS THEN
                p_exitcode := SQLCODE;
                p_exittext := 'DMBL - Billing Refund '
                              || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                              || ' - '
                              || sqlerrm;
                
                raise_application_error(-20001, p_exitcode || p_exittext);
END recon_g1zdbillrf;