--P2-5718 -> Insert Missint Insured Details in ZMRISA00
-- As confirmed by Jdrich, missing Insured Details is expected in Extracted data
-- and below scripts is approved to be used to fix the missing Insured Details
INSERT INTO ZMRISA00
    (
        ISACUCD,ISACICD,ISAA4ST,ISAFLAG,ISAC9CD,
        ISADICD,ISAB0TX,ISAB1TX,ISAB2TX,ISAB3TX,
        ISAB7IG,ISAB8IG,ISAB9IG,ISACAIG,ISAB4TX,
        ISAYOB1,ISAYOB2,ISAYOB3,ISAYOB4,ISAYOB5,
        ISAYOB6,ISAYOB7,ISAYOB8,ISABOCD,ISABPCD,
        ISAAMDT,ISAAATM,ISABQCD,ISAANDT,ISAABTM,
        ISABRCD,ISAB6IG
    )
    SELECT
            RIS.ISCUCD,RIS.ISCICD,RIS.ISA4ST,null,RAP.APC9CD,
            null,RAP.APB0TX,RAP.APB1TX,null,null,
            RAP.APB7IG,RAP.APB8IG,RAP.APB9IG,null,RAP.APB4TX,
            null,null,null,null,0,
            0,0,0,RIS.ISBOCD,RIS.ISBPCD,
            RIS.ISAMDT,RIS.ISAATM,RIS.ISBQCD,RIS.ISANDT,RIS.ISABTM,
            RIS.ISBRCD,RIS.ISB6IG 
    from 
        ZMRAP00 RAP 
        INNER JOIN zmris00 ris ON (RAP.APCUCD = RIS.ISCUCD)
        left outer join zmrisa00 risa
        on (ris.iscicd = risa.isacicd)
        where risa.isacicd is null
        and ris.ISA4ST <> 1;