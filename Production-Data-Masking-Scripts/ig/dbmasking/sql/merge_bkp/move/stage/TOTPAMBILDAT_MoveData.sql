MERGE INTO TOTPAMBILDAT A USING TOTPAMBILDAT_EXT B
ON (A.RECIDXBILDAT = B.RECIDXBILDAT)
WHEN MATCHED THEN
    UPDATE SET
		A.CCARD      = B.CCARD     ,
		A.BANKACCKEY = B.BANKACCKEY,
		A.MBRNAM     = B.MBRNAM    ,
		A.CRDNAM     = B.CRDNAM    ;
