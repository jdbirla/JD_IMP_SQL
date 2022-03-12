create or replace PROCEDURE "DM_ARCH_POPULATE"(i_scheduleName   IN VARCHAR2,
                                                I_GRP_NAME IN VARCHAR2
                                                )
  AUTHID current_user AS
  /***************************************************************************************************
  * Amenment History: AR01    DM ARCH 
  * Date    Initials   Tag      Decription
  * -----   --------   ---      ---------------------------------------------------------------------------
  * MMMDD    XXX       AR01      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  * JUN30    JDB       AR01      Inserting records into arch tables

  *                   
  *****************************************************************************************************/
    p_exitcode        number;
  p_exittext        varchar2(200);
BEGIN
insert /*+ append */ into DMARCH_POL_INFO
select  b.apcucd,b.apc6cd,b.APC7CD,b.apevst,b.apc1cd, substr(apcucd,1,8),A.RPTFPST, CAST(sysdate AS TIMESTAMP),I_GRP_NAME
 from zmrap00 B inner join  zmrrpt00 A on  B.apc7cd =A.rptbtcd ;
 Commit;


insert /*+ append */ into	DMARCH_ASRF_RNW_DTRM	select * from 	ASRF_RNW_DTRM	;
insert /*+ append */ into	DMARCH_ASRF_RNW_INTERMEDIATE	select * from 	ASRF_RNW_INTERMEDIATE	;
insert /*+ append */ into	DMARCH_BTDATE_PTDATE_LIST	select * from 	BTDATE_PTDATE_LIST	;
insert /*+ append */ into	DMARCH_DMPR	select * from 	DMPR	;
insert /*+ append */ into	DMARCH_DMPR1	select * from 	DMPR1	;
insert /*+ append */ into	DMARCH_DPNTNO_TABLE	select * from 	DPNTNO_TABLE	;
insert /*+ append */ into	DMARCH_GRP_POLICY_FREE	select * from 	GRP_POLICY_FREE	;
insert /*+ append */ into	DMARCH_MIPHSTDB	select * from 	MIPHSTDB	;
insert /*+ append */ into	DMARCH_MSTPOLDB	select * from 	MSTPOLDB	;
insert /*+ append */ into	DMARCH_MSTPOLGRP	select * from 	MSTPOLGRP	;
commit;
insert /*+ append */ into	DMARCH_PERSNL_CLNT_FLG	select * from 	PERSNL_CLNT_FLG	;
insert /*+ append */ into	DMARCH_PJ_TITDMGCOLRES	select * from 	PJ_TITDMGCOLRES	;
insert /*+ append */ into	DMARCH_POLICY_STATCODE	select * from 	POLICY_STATCODE	;
insert /*+ append */ into	DMARCH_RENEW_AS_IS	select * from 	RENEW_AS_IS	;
insert /*+ append */ into	DMARCH_RND_COVERAGE_TABLE	select * from 	RND_COVERAGE_TABLE	;
insert /*+ append */ into	DMARCH_SRCNAYOSETBL	select * from 	SRCNAYOSETBL	;
insert /*+ append */ into	DMARCH_TITDMGAGENTPJ	select * from 	TITDMGAGENTPJ	;
insert /*+ append */ into	DMARCH_TITDMGAPIRNO	select * from 	TITDMGAPIRNO	;
insert /*+ append */ into	DMARCH_TITDMGAPIRNO_LOG	select * from 	TITDMGAPIRNO_LOG	;
commit;
insert /*+ append */ into	DMARCH_TITDMGBILL1	select * from 	TITDMGBILL1	;
insert /*+ append */ into	DMARCH_TITDMGBILL2	select * from 	TITDMGBILL2	;
commit;
insert /*+ append */ into	DMARCH_TITDMGBILL_COMB	select * from 	TITDMGBILL_COMB	;
insert /*+ append */ into	DMARCH_TITDMGBILL_COM_BILL	select * from 	TITDMGBILL_COM_BILL	;
insert /*+ append */ into	DMARCH_TITDMGCAMPCDE	select * from 	TITDMGCAMPCDE	;
insert /*+ append */ into	DMARCH_TITDMGCLNTBANK	select * from 	TITDMGCLNTBANK	;
insert /*+ append */ into	DMARCH_TITDMGCLNTCORP	select * from 	TITDMGCLNTCORP	;
insert /*+ append */ into	DMARCH_TITDMGCLNTMAP	select * from 	TITDMGCLNTMAP	;
insert /*+ append */ into	DMARCH_TITDMGCLNTPRSN	select * from 	TITDMGCLNTPRSN	;
insert /*+ append */ into	DMARCH_TITDMGCLTRNHIS	select * from 	TITDMGCLTRNHIS	;
commit;
insert /*+ append */ into	DMARCH_TITDMGCLTRNHIS_INT	select * from 	TITDMGCLTRNHIS_INT	;
insert /*+ append */ into	DMARCH_TITDMGCOLRES	select * from 	TITDMGCOLRES	;
insert /*+ append */ into	DMARCH_TITDMGENDCTPF	select * from 	TITDMGENDCTPF	;
insert /*+ append */ into	DMARCH_TITDMGINSSTPL	select * from 	TITDMGINSSTPL	;
insert /*+ append */ into	DMARCH_TITDMGLETTER	select * from 	TITDMGLETTER	;
insert /*+ append */ into	DMARCH_TITDMGMASPOL	select * from 	TITDMGMASPOL	;

commit;
insert /*+ append */ into	DMARCH_TITDMGMBRINDP1	select * from 	TITDMGMBRINDP1	;
insert /*+ append */ into	DMARCH_TITDMGMBRINDP2	select * from 	TITDMGMBRINDP2	;
insert /*+ append */ into	DMARCH_TITDMGMBRINDP3	select * from 	TITDMGMBRINDP3	;
insert /*+ append */ into	DMARCH_TITDMGPOLTRNH	select * from 	TITDMGPOLTRNH	;
commit;
insert /*+ append */ into	DMARCH_TITDMGREF1	select * from 	TITDMGREF1	;
insert /*+ append */ into	DMARCH_TITDMGREF2	select * from 	TITDMGREF2	;
insert /*+ append */ into	DMARCH_TITDMGRNWDT1	select * from 	TITDMGRNWDT1	;

commit;
insert /*+ append */ into	DMARCH_TITDMGZCSLPF	select * from 	TITDMGZCSLPF	;
insert /*+ append */ into	DMARCH_TRANNOTBL	select * from 	TRANNOTBL	;
insert /*+ append */ into	DMARCH_ZMRAGE00	select * from 	ZMRAGE00	;
insert /*+ append */ into	DMARCH_ZMRAP00	select * from 	ZMRAP00	;
commit;

insert /*+ append */ into	DMARCH_ZMRAT00	select * from 	ZMRAT00	;
insert /*+ append */ into	DMARCH_ZMRCP00	select * from 	ZMRCP00	;
insert /*+ append */ into	DMARCH_ZMREI00	select * from 	ZMREI00	;
insert /*+ append */ into	DMARCH_ZMRFCT00	select * from 	ZMRFCT00	;
commit;
insert /*+ append */ into	DMARCH_ZMRHR00	select * from 	ZMRHR00	;
insert /*+ append */ into	DMARCH_ZMRIC00	select * from 	ZMRIC00	;
insert /*+ append */ into	DMARCH_ZMRIS00	select * from 	ZMRIS00	;
insert /*+ append */ into	DMARCH_ZMRISA00	select * from 	ZMRISA00	;
insert /*+ append */ into	DMARCH_ZMRLH00	select * from 	ZMRLH00	;
insert /*+ append */ into	DMARCH_ZMRMP00	select * from 	ZMRMP00	;
insert /*+ append */ into	DMARCH_ZMRMT00	select * from 	ZMRMT00	;
commit;
insert /*+ append */ into	DMARCH_ZMRRC00	select * from 	ZMRRC00	;
insert /*+ append */ into	DMARCH_ZMRRP00	select * from 	ZMRRP00	;
insert /*+ append */ into	DMARCH_ZMRRPT00	select * from 	ZMRRPT00	;
insert /*+ append */ into	DMARCH_ZMRRR00	select * from 	ZMRRR00	;
insert /*+ append */ into	DMARCH_ZMRRS00	select * from 	ZMRRS00	;
insert /*+ append */ into	DMARCH_ZMRULA00	select * from 	ZMRULA00	;
insert /*+ append */ into	DMARCH_dmpacljobcde	select * from 	dmpacljobcde	;

commit;
exception
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'DM_ARCH_POPULATE : ' || ' ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;


dbms_output.put_line('DM_ARCH_POPULATE:  ' ||
                       p_exitcode ||  '   '|| p_exittext);

    raise;
END DM_ARCH_POPULATE;