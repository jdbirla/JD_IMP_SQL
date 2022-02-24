MERGE INTO ZPDAPF A USING ZPDAPF_EXT B
ON (A.UNIQUE_NUMBER = B.UNIQUE_NUMBER)
WHEN MATCHED THEN
    UPDATE SET					
		A.ZKANASNM01=B.ZKANASNM01,
        A.ZKANAGNM01=B.ZKANAGNM01,
        A.LSURNAME01=B.LSURNAME01,
        A.LGIVNAME01=B.LGIVNAME01,
        A.CLNTPHONE01=B.CLNTPHONE01,
        A.CLNTPHONE02=B.CLNTPHONE02,
        A.FAXNO01=B.FAXNO01,
        A.RMBLPHONE01=B.RMBLPHONE01,
        A.ZKANADDR01=B.ZKANADDR01,
        A.CLTADDR01=B.CLTADDR01,
        A.ZKANADDR02=B.ZKANADDR02,
        A.CLTADDR02=B.CLTADDR02,
        A.ZKANADDR03=B.ZKANADDR03,
        A.CLTADDR03=B.CLTADDR03,
        A.ZKANADDR04=B.ZKANADDR04,
        A.CLTADDR04=B.CLTADDR04,
        A.BANKACCKEY01=B.BANKACCKEY01,
        A.BANKACCDSC01=B.BANKACCDSC01,
        A.ZKANASNM02=B.ZKANASNM02,
        A.ZKANAGNM02=B.ZKANAGNM02,
        A.LSURNAME02=B.LSURNAME02,
        A.LGIVNAME02=B.LGIVNAME02,
        A.CLNTPHONE03=B.CLNTPHONE03,
        A.CLNTPHONE04=B.CLNTPHONE04,
        A.FAXNO02=B.FAXNO02,
        A.RMBLPHONE02=B.RMBLPHONE02,
        A.ZKANADDR05=B.ZKANADDR05,
        A.CLTADDR05=B.CLTADDR05,
        A.ZKANADDR06=B.ZKANADDR06,
        A.CLTADDR06=B.CLTADDR06,
        A.ZKANADDR07=B.ZKANADDR07,
        A.CLTADDR07=B.CLTADDR07,
        A.ZKANADDR08=B.ZKANADDR08,
        A.CLTADDR08=B.CLTADDR08;

		
                               