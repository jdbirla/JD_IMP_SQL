sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TITPAMCAMPAIGN.ctl' data='/opt/ig/hitoku/user/output/outputTITPAMCAMPAIGN.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TITPAMMONTRF.ctl' data='/opt/ig/hitoku/user/output/outputTITPAMMONTRF.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TOTPAMBILDAT.ctl' data='/opt/ig/hitoku/user/output/outputTOTPAMBILDAT.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TOTPAMDINECITI.ctl' data='/opt/ig/hitoku/user/output/outputTOTPAMDINECITI.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TOTPAMMISCLN.ctl' data='/opt/ig/hitoku/user/output/outputTOTPAMMISCLN.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TOTPAMMISTRA.ctl' data='/opt/ig/hitoku/user/output/outputTOTPAMMISTRA.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TOTPAMPOLDATA.ctl' data='/opt/ig/hitoku/user/output/outputTOTPAMPOLDATA.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TOTPAMPOSTTGTD.ctl' data='/opt/ig/hitoku/user/output/outputTOTPAMPOSTTGTD.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TOTPAMRFDPREM.ctl' data='/opt/ig/hitoku/user/output/outputTOTPAMRFDPREM.csv'
sqlldr STAGEDBUSR/Bt7PdKHE@jpaigdbp02:1521/STGPRD22 control='/opt/ig/dbmasking/ctl/stage/TOTPAMVALCHKD.ctl' data='/opt/ig/hitoku/user/output/outputTOTPAMVALCHKD.csv'
 
echo "Data Load into Temp Table Now start moving data into actual tables"

sh MoveData.sh | sqlplus

echo "Data loaded into actual tables"
 
exit 0