MERGE INTO GMHIPF A USING GMHIPF_EXT B
ON (A.UNIQUE_NUMBER = B.UNIQUE_NUMBER)
WHEN MATCHED THEN
    UPDATE SET		
		
		A.ZWORKPLCE1=B.ZWORKPLCE1,
        A.ZWORKPLCE2=B.ZWORKPLCE2;
        
                               