MERGE INTO AUDIT_CLEXPF A USING AUDIT_CLEXPF_EXT B
ON (A.UNIQUE_NUMBER = B.UNIQUE_NUMBER)
WHEN MATCHED THEN
    UPDATE SET					
		A.OLDFAXNO=B.OLDFAXNO,
        A.NEWFAXNO=B.NEWFAXNO;
        
		
        