MERGE INTO CLNTQY A USING CLNTQY_EXT B
ON (A.UNIQUE_NUMBER = B.UNIQUE_NUMBER)
WHEN MATCHED THEN
    UPDATE SET		
			
		A.SURNAME=B.SURNAME,
        A.GIVNAME=B.GIVNAME,
        A.CLTADDR01=B.CLTADDR01,
        A.CLTADDR02=B.CLTADDR02,
        A.CLTADDR03=B.CLTADDR03,
        A.CLTADDR04=B.CLTADDR04,
        A.CLTADDR05=B.CLTADDR05;

       
        
                               
