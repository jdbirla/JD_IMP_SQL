CREATE OR REPLACE EDITIONABLE PROCEDURE "Jd1dta"."DM_NAYOSE_UPDATE_UNIQUE_NUMBER" (
    i_schedulename     IN   VARCHAR2,
    i_schedulenumber   IN   VARCHAR2,
    i_zprvaldyn        IN   VARCHAR2,
    i_company          IN   VARCHAR2,
    i_usrprf           IN   VARCHAR2,
    i_branch           IN   VARCHAR2,
    i_transcode        IN   VARCHAR2,
    i_vrcmtermid       IN   VARCHAR2,
    start_id           IN   NUMBER,
    end_id             IN   NUMBER
)
    AUTHID current_user
AS
  /***************************************************************************************************
  * Amenment History: UN Update Unique number 
  * Date    Initials   Tag   		Decription
  * -----   --------   ---   		---------------------------------------------------------------------------
  * MMMDD    XXX       CP1   		XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * 15JAN    JDB       UN01   	    Inserting record in DMUNIQUENOUPDT table
  *										
  *****************************************************************************************************/

  ------IG table obj End---

    CURSOR cur_stagetable IS
    SELECT
        *
    FROM

        (
            SELECT
                chdrnum,
                clntnum,
                tranno,
                effdate,
                table_name,
                tab_unique
            FROM
                (
                    SELECT
                        ztra.chdrnum,
                        gchd.cownnum         AS clntnum,
                        ztra.tranno,
                        ztra.effdate,
                        'ZTRAPF' AS table_name,
                        ztra.unique_number   AS tab_unique
                    FROM
                        ztrapf     ztra
                        INNER JOIN gchd       gchd ON ztra.chdrnum = gchd.chdrnum
                )
            UNION ALL
            ( SELECT
                zins.chdrnum,
                zins.clntnum         AS clntnum,
                zins.tranno,
                zins.effdate,
                'ZINSDTLSPF' AS table_name,
                zins.unique_number   AS tab_unique
            FROM
                zinsdtlspf   zins
            )
        )DMFREEPLAN  INNER JOIN PAZDNYPF NY on
        DMFREEPLAN.clntnum = NY.zigvalue and NY.IS_UPDATE_REQ = 'Y';

    obj_cur_stagetab      cur_stagetable%rowtype;
    v_zcln_unique         zclnpf.unique_number%TYPE;
    obj_DMUNIQUENOUPDT   DMUNIQUENOUPDT%rowtype;
BEGIN
delete from DMUNIQUENOUPDT;
Commit;
    dbms_output.put_line('Start execution of DM_NAYOSE_UPDATE_UNIQUE_NUMBER, SC NO:  '
                         || i_schedulenumber
                         || ' Flag :'
                         || i_zprvaldyn);
    OPEN cur_stagetable;
    << skiprecord >> LOOP
        FETCH cur_stagetable INTO obj_cur_stagetab;
        EXIT WHEN cur_stagetable%notfound;
        BEGIN
        SELECT
            unique_number
        INTO v_zcln_unique
        FROM
            (
                SELECT
                    unique_number,
                    clntnum,
                    effdate,
                    ROW_NUMBER() OVER(
                        PARTITION BY clntnum
                        ORDER BY
                            effdate DESC
                    ) AS rnzclnt
                FROM
                    zclnpf
                WHERE
                    clntnum = obj_cur_stagetab.clntnum
                    AND effdate <= obj_cur_stagetab.effdate
            )
        WHERE
            rnzclnt = '1';
     EXCEPTION
            WHEN OTHERS THEN
            v_zcln_unique := 0;
            dbms_output.put_line('ZCLNPF effdate is empty => Clntnum ' || obj_cur_stagetab.clntnum ||
                        '  effdate :' || obj_cur_stagetab.effdate);
        END;
  --dbms_output.put_line();
        obj_DMUNIQUENOUPDT.chdrnum := obj_cur_stagetab.chdrnum;
        obj_DMUNIQUENOUPDT.clntnum := obj_cur_stagetab.clntnum;
        obj_DMUNIQUENOUPDT.tranno := obj_cur_stagetab.tranno;
        obj_DMUNIQUENOUPDT.effdate := obj_cur_stagetab.effdate;
        obj_DMUNIQUENOUPDT.table_name := obj_cur_stagetab.table_name;
        obj_DMUNIQUENOUPDT.tab_unique :=obj_cur_stagetab.tab_unique;
        obj_DMUNIQUENOUPDT.ZCLN_unique := v_zcln_unique;
        obj_DMUNIQUENOUPDT.is_updated := 'N';
        INSERT INTO DMUNIQUENOUPDT VALUES obj_DMUNIQUENOUPDT;

    END LOOP;
Commit;
    CLOSE cur_stagetable;
END dm_nayose_update_unique_number;

/
