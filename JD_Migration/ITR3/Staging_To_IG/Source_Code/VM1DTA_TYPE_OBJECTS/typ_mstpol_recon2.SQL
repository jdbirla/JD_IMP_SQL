--Creation of the types for Master Policy Reconciliation Step 2

DROP TYPE typ_tbl_mstpol_recon2;
/
DROP TYPE typ_rec_mstpol_recon2;
/
create or replace type typ_rec_mstpol_recon2 is object (
       chdrnum    VARCHAR2(11 CHAR),
       cnttype    VARCHAR2(3 CHAR),
       ccdate     NUMBER(8,0),
       crdate     NUMBER(8,0),
       zendcde    VARCHAR2(10 CHAR),
       zplancls   CHAR(2 CHAR),
       zblnkpol   CHAR(1 CHAR),
       statcode   CHAR(2 CHAR),
       zagptnum   VARCHAR2(8 CHAR),
       zgrpcls    VARCHAR2(30 CHAR)
       ) ;
/
create or replace type  typ_tbl_mstpol_recon2 as table of typ_rec_mstpol_recon2;
/