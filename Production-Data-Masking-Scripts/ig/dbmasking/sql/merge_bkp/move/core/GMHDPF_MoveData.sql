MERGE INTO GMHDPF A USING GMHDPF_EXT B
ON (A.UNIQUE_NUMBER = B.UNIQUE_NUMBER)
WHEN MATCHED THEN
    UPDATE SET		
		
		A.BANKACCKEY=B.BANKACCKEY;
       
        
                               
