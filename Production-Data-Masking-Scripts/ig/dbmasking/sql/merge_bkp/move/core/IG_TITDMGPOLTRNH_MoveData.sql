MERGE INTO IG_TITDMGPOLTRNH A USING IG_TITDMGPOLTRNH_EXT B
ON (A.RECIDXPHIST = B.RECIDXPHIST)
WHEN MATCHED THEN
    UPDATE SET					
		A.CRDTCARD=B.CRDTCARD;   
                               
