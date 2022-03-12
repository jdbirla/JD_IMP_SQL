create or replace PACKAGE  DM_data_trans_letter
 AS

  PROCEDURE DM_LETTERHIST_TRANSFORM(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N');


END DM_data_trans_letter;
/

create or replace PACKAGE BODY DM_data_trans_letter as

    application_no   VARCHAR2(13);
    v_input_count    NUMBER;
    v_output_count   NUMBER;
    stg_starttime    TIMESTAMP;
    l_err_flg        NUMBER := 0;
    g_err_flg        NUMBER := 0;

PROCEDURE DM_LETTERHIST_TRANSFORM(p_array_size IN PLS_INTEGER DEFAULT 1000,p_delta IN CHAR DEFAULT 'N')
	AS
	V_ERRORMSG VARCHAR2(2000);
    L_CNT_CHK NUMBER(2);
    V_ZLEDEST NUMBER(1);
    V_OUTPUT_COUNT NUMBER := 0;
    V_INPCOUNT NUMBER :=0;
    V_INPCOUNTF NUMBER :=0;
    V_COUNT NUMBER :=0;
	V_IGCODE CHAR(5);
	V_LHCQCD VARCHAR(4);
	V_LHCUCD VARCHAR2(11);
    V_CNT   NUMBER(7):= 0;
    temp_no NUMBER:=0;
    temp_IGCODE CHAR(5) :='     ';--bhupendra change
	temp_LHCUCD VARCHAR2(11) :='           '; --bhupendra change
	temp_V_LHCUCD VARCHAR2(11) :='           '; --bhupendra change
	temp_LHAWDT VARCHAR2(8):='        '; --bhupendra change
	v_zlettrno NUMBER :=1;--bhupendra change
    VARD varchar2(13);
    STG_ENDTIMe TIMESTAMP;
        CURSOR CUR_ZMRLH00
        IS
          SELECT SUBSTR(LHCQCD,1,2) V_LHCQCD,
                 LHAWDT,
                 LHCUCD,
                 SUBSTR(LHCUCD,1,8) V_LHCUCD,
                 LHCQCD,
                 (SELECT IGCODE FROM LETTER_CODE where DMCODE=SUBSTR(ZA.LHCQCD,1,2)) AS V_IGCODE,
				 (SELECT STAGECLNTNO FROM TITDMGCLNTMAP where REFNUM=(SUBSTR(ZA.LHCUCD,1,8))||'00') AS V_STAGECLNTNO,
                -- NVL((CASE WHEN ZMRAP.APEVST='1' THEN 'Y' ELSE 'N' END)  ,'N') AS ZAPSTMPD, -- ITR4 changes addition
                 ' ' AS ZDESPER -- ITR4 changes
            FROM ZMRLH00 ZA
              --   ZMRAP00 ZMRAP   -- ITR4 changes addition
           WHERE
		   --ZA.LHCUCD = ZMRAP.APCUCD AND -- ITR4 changes addition
              NOT EXISTS (SELECT 'X' FROM TITDMGLETTER LT ,LETTER_CODE
                              WHERE CHDRNUM =  SUBSTR(LHCUCD,1,8) and
                               IGCODE = LT.LETTYPE
                               AND dmcode = SUBSTR(NVL(ZA.LHCQCD,'        '),1,2)
                               AND LREQDATE = ZA.LHAWDT
                            )
           --  ORDER BY 3;
		 ORDER BY LHCUCD,LHAWDT,V_IGCODE; --bhupendra change

    REC_ZMRLH00 CUR_ZMRLH00%ROWTYPE;

     TYPE RECD_ZMRLH00 IS TABLE OF CUR_ZMRLH00%ROWTYPE;
     L_DATA RECD_ZMRLH00;

   CHK_CNT NUMBER:=0;

BEGIN
    dm_data_trans_gen.stg_starttime := systimestamp;
    L_ERR_FLG :=0;
    G_ERR_FLG :=0;


     V_ERRORMSG:= 'DM_LETTERHIST_TRANSFORM:';
      IF p_delta = 'Y' THEN
             V_ERRORMSG:= 'For Delta Load:';
             DELETE FROM TITDMGLETTER WHERE EXISTS (SELECT 'X' FROM TMP_ZMRLH00 ZA
                                                     WHERE SUBSTR(ZA.LHCUCD,1,8) = TITDMGLETTER.CHDRNUM
                                                     );
             COMMIT;
         -- Delete the records for all the records exists in TITDMGLETTER for Delta Load
      END IF;

    V_ERRORMSG:='CURSOR_F-';
    OPEN CUR_ZMRLH00;
    LOOP
      FETCH CUR_ZMRLH00
        BULK COLLECT INTO L_DATA LIMIT p_array_size;

        V_INPCOUNT := V_INPCOUNT + L_DATA.COUNT;

        FOR cnt IN 1 .. L_DATA.COUNT
        LOOP
        vard := L_DATA(cnt).LHCUCD;

/* comments - Bhupendra
     --   IF L_DATA(cnt).LHCQCD IN ('SB0D','SB1E','SB2E','SB3E','SB4E','SB5E','SB7E','SB9E','PL1E','PL2E','PL3E','PL4E','PL5E','PL7E','PL9E') THEN
   --       V_ZLEDEST := 1;
    --    ELSE
    --      V_ZLEDEST := 2;
    --    END IF;
*/

       BEGIN
        V_ERRORMSG:='CURSOR_MT-';
        IF L_DATA(cnt).LHCUCD is not null THEN
        IF L_DATA(cnt).V_IGCODE IS NOT NULL THEN
         IF (temp_V_LHCUCD = L_DATA(cnt).V_LHCUCD) THEN --bhupendra change
                        v_zlettrno := v_zlettrno + 1;--bhupendra change
                ELSE
                       
						temp_V_LHCUCD := L_DATA(cnt).V_LHCUCD;--bhupendra change
						v_zlettrno := 1;--bhupendra change
                END IF;
             INSERT INTO TITDMGLETTER(LETTYPE,LREQDATE,CHDRNUM,ZDSPCATG,ZLETVERN,ZLETDEST,ZCOMADDR,ZLETCAT,ZAPSTMPD,ZDESPER,ZLETEFDT,ZLETTRNO,STAGECLNTNO)--bhupendra change add ZLETTRNO
                               VALUES(L_DATA(cnt).V_IGCODE, L_DATA(cnt).LHAWDT, L_DATA(cnt).V_LHCUCD,'2','000','2','POLHLD','M','N',L_DATA(cnt).ZDESPER, L_DATA(cnt).LHAWDT,v_zlettrno,L_DATA(cnt).V_STAGECLNTNO);--bhupendra change add ZLETTRNO
             V_OUTPUT_COUNT := V_OUTPUT_COUNT + SQL%ROWCOUNT;
             DELETE FROM TAB_NOT_FOUND_LIST WHERE LHCUCD=L_DATA(cnt).LHCUCD;
        ELSE
            CHK_CNT :=0;
            SELECT COUNT(1) INTO CHK_CNT FROM TAB_NOT_FOUND_LIST WHERE LHCUCD=L_DATA(cnt).LHCUCD;
            IF CHK_CNT = 0 THEN
               INSERT INTO TAB_NOT_FOUND_LIST(LHCUCD,LHCQCD) VALUES (L_DATA(cnt).LHCUCD, L_DATA(cnt).V_LHCQCD);
            END IF;
            V_OUTPUT_COUNT := V_OUTPUT_COUNT + SQL%ROWCOUNT;
        END IF;
        ELSE
            V_ERRORMSG:='LHCUCD CANNOT BE NULL. LETTYPE:'||L_DATA(cnt).V_LHCQCD||'-LREQDATE:'||L_DATA(cnt).LHAWDT;
            DM_data_trans_gen.ERROR_LOGS('TITDMGLETTER',vard,V_ERRORMSG);
        END IF;
       EXCEPTION
       WHEN OTHERS  THEN
          V_ERRORMSG := V_ERRORMSG ||'-'||sqlerrm;
          DM_data_trans_gen.ERROR_LOGS('TITDMGLETTER',vard,V_ERRORMSG);
        END;

        COMMIT;

        END LOOP;
      EXIT WHEN CUR_ZMRLH00%NOTFOUND;
    END LOOP;

    CLOSE CUR_ZMRLH00;

        IF L_ERR_FLG = 1 THEN
        --ROLLBACK;
          L_ERR_FLG := 0;
        END IF;

COMMIT;

    IF G_ERR_FLG = 0 THEN
       V_ERRORMSG := 'SUCCESS';
       temp_no := DM_data_trans_gen.CONTROL_LOG('ZMRLH00', 'TITDMGLETTER', SYSTIMESTAMP,vard,V_ERRORMSG, 'S',V_INPCOUNT, V_OUTPUT_COUNT);
    ELSE
       V_ERRORMSG := 'COMPLETED WITH ERROR';
       temp_no := DM_data_trans_gen.CONTROL_LOG('ZMRLH00', 'TITDMGLETTER', SYSTIMESTAMP,vard,V_ERRORMSG, 'F',V_INPCOUNT, V_OUTPUT_COUNT);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       V_ERRORMSG:=V_ERRORMSG||'-'||sqlerrm;
       temp_no := DM_data_trans_gen.CONTROL_LOG('ZMRLH00', 'TITDMGLETTER', SYSTIMESTAMP,vard,V_ERRORMSG, 'F',V_INPCOUNT, V_OUTPUT_COUNT);
END DM_LETTERHIST_TRANSFORM;

-- Procedure for DM DM_LETTERHIST_TRANSFORM <ENDS> Here

end DM_data_trans_letter;

/

