# CKP:20211209
# When we have issue in pipeline function or there is a need to add any column, then we need to rebuild objects.
# For that we need to drop dependent objects in right order. This script is to ease that as the order is below. 


drop type  APM_DBMASK_AUDIT_CLRRPF_tab;
drop type APM_DBMASK_AUDIT_CLRRPF_obj ;
drop function APM_DBMASK_AUDIT_CLRRPF_pip    ;
drop procedure APM_DBMASK_writetoAUDIT_CLRRPF;
