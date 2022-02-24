MERGE INTO ZREPPF A USING ZRLEPF_EXT B
ON (A.UNIQUE_NUMBER = B.UNIQUE_NUMBER)
WHEN MATCHED THEN
    UPDATE SET
                A.ZKANASNM    = B.ZKANASNM
                A.ZKANAGNM = B.ZKANAGNM;
