--Jd1dta user setup
---Step1: All required  common obbjects Setup
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\IG_DM_TABLES\DM_IG_Tables.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\IG_DM_TABLES\CONFIG_INSERT.sql;
--@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\DMSTAGDBLINK_ZURICHJD1.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\VM1DTA_SEQs\All_Sequence.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\Vm1dta_views\All_View.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\dm_recreate_index.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\dm_save_drop_index.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\SETDMBARG.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\rebuild_Vm1dta_indexes.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\ErrorPf_DM_All_Error_Codes.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\All_common_Function.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\PKG_DM_COMMON_OPERATIONS.sql;
--@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\BQ9SS_DM01_OVERALLDM.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\All_Common_procs.sql;


--- Set2 Reconciliation report
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\INSERT_ERROR_LOG.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\VM1DTA_DB_TABLES_INSERT_QUERIES\Jd1dta.DM_DATA_VALIDATION_ATTRIB.sql
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\VM1DTA_TYPE_OBJECTS\typ_billref_recon_set2.sql
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\dm_report_gen_recon_set2.sql


---Module Wise pkg and procs

--DMAG
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMAG_01_Agency\PKG_DM_AGENCY.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMAG_01_Agency\BQ9S5_AG01_AGENCY.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMAG_01_Agency\DM2_G1ZDAGENCY_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMAG_01_Agency\PV_AG_G1ZDAGNCY.sql;

--DMCL
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_01_Client_Corporate\PKG_DM_CORPORATE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_01_Client_Corporate\BQ9Q7_CL01_CORPCLT.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_01_Client_Corporate\PV_CC_G1ZDCOPCLT.sql;





--DMCP
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\PKG_COMMON_DMCP.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\BQ9Q6_CL02_PERCLT.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\DM2_G1ZDPERCLT_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\PV_CP_G1ZDPERCLT.sql;

--DMCH
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\PKG_COMMON_DMCH.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\BQ9TV_CL02_2_CLNTHIST.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\DM2_G1ZDPCLHIS_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\PV_CH_G1ZDPCLHIS.sql;

--DMNY
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\BQ9Q5_CL_NAYOCL.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\DM2_G1ZDNAYCLT_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\PV_CP_G1ZDPERCLT.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCL_02_Personal_Client\DM_nayose_update_unique_number.sql;


--DMCB
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCB_01_Client_Bank\PKG_COMMON_DMCB.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCB_01_Client_Bank\BQ9RU_CB01_CLTBNK.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCB_01_Client_Bank\DM2_G1ZDCLTBNK_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCB_01_Client_Bank\PV_CB_G1ZDCLTBNK.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCB_01_Client_Bank\DM_CLIENT_BANK_RECON_SET2.sql
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\VM1DTA_TYPE_OBJECTS\typ_client_bank_recon_set2.sql
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCB_01_Client_Bank\RECON_G1ZDCLTBNK.sql



--DMSL
--@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMSP_01_Sales_Plan\BQ9SF_SP01_SALPLN.sql

--DMCM
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCM_01_Campaign_Code\PKG_COMMON_DMCM.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCM_01_Campaign_Code\BQ9S8_CM01_CAMPCD.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCM_01_Campaign_Code\DM2_G1ZDCAMPCD_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMCM_01_Campaign_Code\PV_CM_G1ZDCAMPCD.sql;



--DMMB01
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\PKG_COMMON_DMMB.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\BQ9SC_MB01_MBRIND.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\DM2_G1ZDMBRIND_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\PV_CH_G1ZDMBRIND.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\recon_g1zdmbrind.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\DM_MEMBER_IND_POL_RECON_SET2.SQL;





--DMPH policy History
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\PKG_COMMON_DMMB_PHST.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\BQ9UU_MB01_POLHIST.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\BQ9SA_PC01_POLCOV.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\BQ9SR_RN01_APIRNO.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\DM2_G1ZDPOLHST_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\DM2_G1ZDPOLCOV_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\DM2_GIZDAPIRNO_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\recon_g1zdpolhst.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\PV_PC_G1ZDPOLCOV.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMPH_01_Policy_History\DM_POLHIST_RECON_SET2.sql;

--DMBL
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\PKG_COMMON_DMBL.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\BQ9TK_BL01_BILLHIST.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\DM2_G1ZDBILLIN_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\PV_BL_G1ZDBILLIN.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\RECON_G1ZDBILLIN.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\DM_BILLINST_RECON_SET2.sql;

--Billing Refund
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\BQ9UX_BL01_REFUNDBL.SQl;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\DM2_G1ZDBILLRF_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\PV_BL_G1ZDBILLRF.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\recon_g1zdbillrf.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\dm_billref_recon_set2.sql

--ColRES
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\BQ9TL_BL01_COLLRSLT.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\DM2_G1ZDCOLRES_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\PV_CR_G1ZDCOLRES.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\RECON_CR_G1ZDCOLRES.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMBL_01_Billing\DM_COLRES_RECON_SET2.sql

--Dishonor

@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\PKG_COMMON_DMMB_PDSH.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\BQ9UT_MB01_DISHONOR.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\DM2_G1ZDPOLDSH_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\PV_PD_G1ZDPOLDSH.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\RECON_G1ZDPOLDSH.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMB_01_MEBR_INDV_POL\DM_POLDIS_RECON_SET2.sql;
--DMLT
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMLT_01_Letter\PKG_COMMON_DMLT.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMLT_01_Letter\BQ9RF_LT01_LETR.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMLT_01_Letter\DM2_G1ZDLETR_PARALLEL_EXE.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMLT_01_Letter\PV_LT_G1ZDLETR.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMLT_01_Letter\RECON_LT_G1ZDLETR.sql;

---DMMP
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMP_01_MasterPolicy\PKG_DM_MASTPOLICY.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMP_01_MasterPolicy\BQ9EC_MP01_MSTRPL.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMP_01_MasterPolicy\PV_MP_G1ZDMSTPOL.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMP_01_MasterPolicy\typ_mstpol_recon2.SQL;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMP_01_MasterPolicy\recon_g1zdmstpol.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMP_01_MasterPolicy\DM_Mstpol_Recon_Set2.sql;
--@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMMP_01_MasterPolicy\DataPatch\SCRIPTS\BQ9EC_MP01_MSTRPL_DataPatch.sql;

-- Renewal Determination
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMRD_01_Renewal_Determination\01_01_BQ9UY_RD01_RWRD_INIT.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMRD_01_Renewal_Determination\01_02_BQ9UY_RD01_RWRD_VALID.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMRD_01_Renewal_Determination\01_03_BQ9UY_RD01_RWRD_PROCESS.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMRD_01_Renewal_Determination\01_04_BQ9UY_RD01_RWRD.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMRD_01_Renewal_Determination\02_RECON_G1ZDRNWDTM.sql;

@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DMRD_01_Renewal_Determination\dm_renewal_recon_set2.sql
--Final DM2_Migration
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\DM2-MIGRATION_EXECUTION.sql;

--- Reconciliation Report
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\PKG_WRITE_XLSX.sql;
@C:\D_Drive\Zurich_Product\PA_Data_Migration\integral-CustomerZurichJpnDM\Documentation\DataChange\Oracle\Phase-2\ITR3\Staging_To_IG\Source_Code\DM_01_OverALL_DM\RECONCILIATION_REPORT.sql;



ALTER PROCEDURE BQ9S5_AG01_AGENCY COMPILE;
ALTER PROCEDURE BQ9TL_BL01_COLLRSLT COMPILE ;
ALTER PROCEDURE BQ9RU_CB01_CLTBNK COMPILE;
ALTER PROCEDURE BQ9Q7_CL01_CORPCLT COMPILE;
ALTER PROCEDURE BQ9Q6_CL02_PERCLT COMPILE;
ALTER PROCEDURE BQ9TV_CL02_2_CLNTHIST COMPILE;
ALTER PROCEDURE BQ9S8_CM01_CAMPCD COMPILE;
ALTER PROCEDURE BQ9RF_LT01_LETR COMPILE;
ALTER PROCEDURE BQ9SC_MB01_MBRIND COMPILE;
--ALTER PROCEDURE BQ9SF_SP01_SALPLN COMPILE;
ALTER PROCEDURE BQ9UT_MB01_DISHONOR COMPILE;
ALTER PROCEDURE BQ9TK_BL01_BILLHIST COMPILE;
ALTER PROCEDURE BQ9UU_MB01_POLHIST COMPILE;
ALTER PROCEDURE BQ9UX_BL01_REFUNDBL COMPILE;
ALTER PROCEDURE BQ9EC_MP01_MSTRPL COMPILE;
ALTER PROCEDURE BQ9SA_PC01_POLCOV COMPILE;
ALTER PROCEDURE BQ9SR_RN01_APIRNO COMPILE;
ALTER PROCEDURE BQ9UY_RD01_RWRD_INIT COMPILE;
ALTER PROCEDURE BQ9UY_RD01_RWRD_VALID COMPILE;
ALTER PROCEDURE BQ9UY_RD01_RWRD_PROCESS COMPILE;
ALTER PROCEDURE BQ9UY_RD01_RWRD COMPILE;
ALTER PROCEDURE rebuild_Vm1dta_indexes compile;


COMMIT;

