create or replace PROCEDURE UPDATE_TITDMGCAMPCDE
IS

    Y_BEFORE_UPDATE   NUMBER;
    Y_AFTER_UPDATE    NUMBER;
    N_BEFORE_UPDATE   NUMBER;
    N_AFTER_UPDATE    NUMBER;
BEGIN

SELECT
    COUNT(*) INTO Y_BEFORE_UPDATE
    FROM TITDMGCAMPCDE
        WHERE
        ZCCODIND = 'Y';
        DBMS_OUTPUT.PUT_LINE('NUMBER OF ROWS IN COLUMN ZCCODIND with value Y'|| Y_BEFORE_UPDATE);
 SELECT
    COUNT(*) INTO N_BEFORE_UPDATE
    FROM TITDMGCAMPCDE
        WHERE
        ZCCODIND = 'N';
        DBMS_OUTPUT.PUT_LINE('NUMBER OF ROWS IN COLUMN ZCCODIND WITH VALUE N'|| N_BEFORE_UPDATE);
        UPDATE STAGEDBUSR2.TITDMGCAMPCDE SET ZCCODIND = 'N';
        N_AFTER_UPDATE :=SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE( 'NUMBER OF ROWS UPDATED WITH VALUE N' ||N_AFTER_UPDATE);
        COMMIT;
        UPDATE STAGEDBUSR2.TITDMGCAMPCDE SET ZCCODIND = 'Y' WHERE TRIM(ZCMPCODE) LIKE 'C%';
        Y_AFTER_UPDATE :=SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE( 'NUMBER OF ROWS UPDATED WITH VALUE Y' ||Y_AFTER_UPDATE);
        COMMIT;
        Update stagedbusr2.TITDMGCAMPCDE A set  ZAPPDATE = (select CPAMDT from stagedbusr2.ZMRCP00 B where B.CPBCCD = A.ZCMPCODE and B.CPBDCD = A.ZENDCODE);
commit;

Update stagedbusr2.TITDMGCAMPCDE A set  EFFDATE = (select CPAMDT from stagedbusr2.ZMRCP00 B where B.CPBCCD = A.ZCMPCODE and B.CPBDCD = A.ZENDCODE);
commit;
Update stagedbusr2.TITDMGCAMPCDE A set  ZAPPDATE = case
    -- To check for 6 Characters (YYMMDD) and year is between 2000 and 2030
    when length(ZAPPDATE)= 6 and to_number(substr(ZAPPDATE,1,2)) <= 30 then concat('20',ZAPPDATE)
    -- To check for 6 Characters (YYMMDD) and year is between 1931 and 1999
    when length(ZAPPDATE)= 6 and to_number(substr(ZAPPDATE,1,2)) between 31 and 100 then concat('19',ZAPPDATE)
    -- To check for 5 Characters (YMMDD) and year is 2000
    when length(ZAPPDATE)= 5 and to_number(substr(ZAPPDATE,1,1)) between 0 and 9 then concat('200',ZAPPDATE)
    -- To check for 4 Characters (MMDD) and year is 2000, month is between 01 and 09
    when length(ZAPPDATE)= 4 then concat('2000',ZAPPDATE)
    -- To check for 3 Characters (MDD) and year is 2000, month is between 1 and 9
    when length(ZAPPDATE)= 3 then concat('20000',ZAPPDATE)

						   end,
                           EFFDATE =  case
    -- To check for 6 Characters (YYMMDD) and year is between 2000 and 2030
    when length(EFFDATE)= 6 and to_number(substr(EFFDATE,1,2)) <= 30 then concat('20',EFFDATE)
    -- To check for 6 Characters (YYMMDD) and year is between 1931 and 1999
    when length(EFFDATE)= 6 and to_number(substr(EFFDATE,1,2)) between 31 and 100 then concat('19',EFFDATE)
    -- To check for 5 Characters (YMMDD) and year is 2000
    when length(EFFDATE)= 5 and to_number(substr(EFFDATE,1,1)) between 0 and 9 then concat('200',EFFDATE)
    -- To check for 4 Characters (MMDD) and year is 2000, month is between 01 and 09
    when length(EFFDATE)= 4 then concat('2000',EFFDATE)
    -- To check for 3 Characters (MDD) and year is 2000, month is between 1 and 9
    when length(EFFDATE)= 3 then concat('20000',EFFDATE)
	end ; -- 3,283 updated
update stagedbusr2.TITDMGCAMPCDE set ZPOLCLS = 'I'
where ZPOLCLS = '1';

update stagedbusr2.TITDMGCAMPCDE set ZPOLCLS = 'G'
where ZPOLCLS = '2';							

update stagedbusr2.TITDMGCAMPCDE set ZVEHICLE = 'DM',ZSTAGE = 'B',ZSCHEME01 = 'CNV', ZSCHEME02 = 'CNV', ZCRTUSR = 'DataMig';							

commit;
end UPDATE_TITDMGCAMPCDE;