# CKP:20211209
# When we have issue in pipeline function or there is a need to add any column, then we need to rebuild objects.
# For that we need to drop dependent objects in right order. This script is to ease that as the order is below. 

drop type APM_DBMASK_ZALTPF_TAB;
drop type APM_DBMASK_ZALTPF_OBJ;
drop function APM_DBMASK_ZALTPF_pipeline;
drop procedure APM_DBMASK_write_to_ZALTPF;
