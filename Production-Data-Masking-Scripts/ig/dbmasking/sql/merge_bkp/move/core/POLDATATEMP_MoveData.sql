MERGE INTO POLDATATEMP A USING POLDATATEMP_EXT B
ON (A.CHDRNUM = B.CHDRNUM) AND
      (A.TRANNO=B.TRANNO)
	  
WHEN MATCHED THEN
    UPDATE SET		
			
		A.GAGNTSEL01=B.GAGNTSEL01,
        A.ZKANASNM=B.ZKANASNM,
        A.ZKANAGNM=B.ZKANAGNM,
        A.LSURNAME=B.LSURNAME,
        A.LGIVNAME=B.LGIVNAME,
        A.CLTPHONE01=B.CLTPHONE01,
        A.CLTPHONE02=B.CLTPHONE02,
        A.CLTADDR01=B.CLTADDR01,
        A.CLTADDR02=B.CLTADDR02,
        A.CLTADDR03=B.CLTADDR03,
        A.CLTADDR04=B.CLTADDR04,
        A.ZKANADDR01=B.ZKANADDR01,
        A.ZKANADDR02=B.ZKANADDR02,
        A.ZKANADDR03=B.ZKANADDR03,
        A.ZKANADDR04=B.ZKANADDR04,
        A.FAXNO=B.FAXNO,
        A.CLTADDR05=B.CLTADDR05,
        A.ZKANADDR05=B.ZKANADDR05,
        A.CRDTCARD=B.CRDTCARD;
      