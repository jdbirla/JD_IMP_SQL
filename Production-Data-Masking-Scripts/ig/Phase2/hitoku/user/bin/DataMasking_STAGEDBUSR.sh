#!/usr/bin/ksh

export LANG=Ja_JP

#rm -r /opt/ig/hitoku/user/output/*

/opt/ig/hitoku/user/bin/TITPAMCAMPAIGN.sh
/opt/ig/hitoku/user/bin/TITPAMMONTRF.sh

/opt/ig/hitoku/user/bin/TITDMGMBRINDP1_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGPOLTRNH_FREE_PLANS_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGPOLTRNH_Mask.sh
/opt/ig/hitoku/user/bin/TITDMGREF1_Mask.sh



###rm -r /opt/ig/hitoku/user/input/*