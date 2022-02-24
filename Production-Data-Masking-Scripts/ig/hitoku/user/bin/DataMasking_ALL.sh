#!/usr/bin/ksh

export LANG=Ja_JP

rm -rf /opt/ig/hitoku/user/output/*

/opt/ig/hitoku/user/bin/TITPAMCAMPAIGN.sh
/opt/ig/hitoku/user/bin/TITPAMMONTRF.sh
#/opt/ig/hitoku/user/bin/CHDRPF_Mask.sh
/opt/ig/hitoku/user/bin/CLNTPF_Mask.sh
/opt/ig/hitoku/user/bin/ZALTPF_Mask.sh
/opt/ig/hitoku/user/bin/AUDIT_ASRDPF_Mask.sh
/opt/ig/hitoku/user/bin/AUDIT_CLEXPF_Mask.sh
/opt/ig/hitoku/user/bin/AUDIT_CLNT_Mask.sh
/opt/ig/hitoku/user/bin/AUDIT_CLNTPF.sh
#/opt/ig/hitoku/user/bin/BABRPF_Mask.sh
/opt/ig/hitoku/user/bin/CLBAPF_Mask.sh
/opt/ig/hitoku/user/bin/CLEXPF_Mask.sh
/opt/ig/hitoku/user/bin/CLNTQY.sh
/opt/ig/hitoku/user/bin/GMHDPF.sh
/opt/ig/hitoku/user/bin/GMHIPF.sh
#/opt/ig/hitoku/user/bin/IG_TITDMGPOLTRNH.sh
/opt/ig/hitoku/user/bin/MIOKPF.sh
#/opt/ig/hitoku/user/bin/MV_ZMCIPF_Mask.sh
#/opt/ig/hitoku/user/bin/MV_ZMCIPF_CRDT_Mask.sh
#/opt/ig/hitoku/user/bin/NAME_Mask.sh
#/opt/ig/hitoku/user/bin/POLDATATEMP_Mask.sh
/opt/ig/hitoku/user/bin/ZCLNPF.sh
/opt/ig/hitoku/user/bin/ZCORPF_Mask.sh
/opt/ig/hitoku/user/bin/ZMCIPF_Mask.sh
/opt/ig/hitoku/user/bin/ZMIEPF_Mask.sh
/opt/ig/hitoku/user/bin/ZMUPPF_Mask.sh
/opt/ig/hitoku/user/bin/ZPDAPF_Mask.sh
/opt/ig/hitoku/user/bin/ZREPPF_Mask.sh
/opt/ig/hitoku/user/bin/ZSTGPF_Mask.sh
/opt/ig/hitoku/user/bin/ZVCHPF_Mask.sh
/opt/ig/hitoku/user/bin/ZERRPF_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGMBRINDP1_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGPOLTRNH_FREE_PLANS_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGPOLTRNH_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGREF1_Mask.sh


/opt/ig/hitoku/user/bin/TITDMGCLNTBANK_FREEPLAN_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGCLNTBANK_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGCLNTPRSN_FREEPLAN_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGCLNTPRSN_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGMBRINDP1_FREEPLAN_Mask.sh
/opt/ig/hitoku/user/bin/TITPAMBILLSTOP_Mask.sh
/opt/ig/hitoku/user/bin/TITPAMVALCHKDR_Mask.sh

/opt/ig/hitoku/user/bin/TITDMGCLTRNHIS_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGCLTRNHIS_FREEPLAN_Mask.sh

/opt/ig/hitoku/user/bin/CLRRPF_Mask.sh
/opt/ig/hitoku/user/bin/AUDIT_CLRRPF_Mask.sh

#rm -rf /opt/ig/hitoku/user/input/*

exit 0
