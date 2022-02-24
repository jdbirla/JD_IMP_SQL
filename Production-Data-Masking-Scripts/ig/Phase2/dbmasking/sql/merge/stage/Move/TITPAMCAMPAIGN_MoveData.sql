MERGE INTO TITPAMCAMPAIGN A USING TITPAMCAMPAIGN_EXT B
ON (A.RECIDXCAMP = B.RECIDXCAMP)
WHEN MATCHED THEN
    UPDATE SET
		A.CREDITCARDNO = B.CREDITCARDNO,
		A.ACCHOLDERNAME_COLLECT = B.ACCHOLDERNAME_COLLECT,
		A.BK_ACC_NO_PAYM = B.BK_ACC_NO_PAYM,
		A.ACCHOLDERNAME_PAYM = B.ACCHOLDERNAME_PAYM,
		A.SURNAMEKANA = B.SURNAMEKANA,
		A.GIVENNAMEKANA = B.GIVENNAMEKANA,
		A.SURNAMEKANJI = B.SURNAMEKANJI,
		A.GIVENNAMEKANJI = B.GIVENNAMEKANJI,
		A.ADDRESSINKANA_1 = B.ADDRESSINKANA_1,
		A.ADDRESSINKANA_2 = B.ADDRESSINKANA_2,
		A.ADDRESSINKANA_3 = B.ADDRESSINKANA_3,
		A.ADDRESSINKANA_4 = B.ADDRESSINKANA_4,
		A.ADDRESSINKANJI_1 = B.ADDRESSINKANJI_1,
		A.ADDRESSINKANJI_2 = B.ADDRESSINKANJI_2,
		A.ADDRESSINKANJI_3 = B.ADDRESSINKANJI_3,
		A.ADDRESSINKANJI_4 = B.ADDRESSINKANJI_4,
		A.SURNAMEGUARDIANKANJI = B.SURNAMEGUARDIANKANJI,
		A.GIVENNAMEGUARDIANKANJI = B.GIVENNAMEGUARDIANKANJI,
		A.SURNAMEGUARDIANKANA = B.SURNAMEGUARDIANKANA,
		A.GIVENNAMEGUARDIANKANA = B.GIVENNAMEGUARDIANKANA,
		A.POSTALCODEGUARDIAN = B.POSTALCODEGUARDIAN,
		A.ADDRGUARDIANKANA_1 = B.ADDRGUARDIANKANA_1,
		A.ADDRGUARDIANKANA_2 = B.ADDRGUARDIANKANA_2,
		A.ADDRGUARDIANKANA_3 = B.ADDRGUARDIANKANA_3,
		A.ADDRGUARDIANKANA_4 = B.ADDRGUARDIANKANA_4,
		A.ADDRGUARDIANKANJI_1 = B.ADDRGUARDIANKANJI_1,
		A.ADDRGUARDIANKANJI_2 = B.ADDRGUARDIANKANJI_2,
		A.ADDRGUARDIANKANJI_3 = B.ADDRGUARDIANKANJI_3,
		A.ADDRGUARDIANKANJI_4 = B.ADDRGUARDIANKANJI_4,
		A.TELNOGUARDIAN = B.TELNOGUARDIAN;
