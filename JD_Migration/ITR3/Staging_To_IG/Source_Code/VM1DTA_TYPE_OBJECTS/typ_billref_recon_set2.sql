drop type o_data_set;
/
drop type r_data_set;
/
create or replace type r_data_set is object (
v_pol_no varchar2(8),
HR_EREF varchar2(40),
HR_ZREF varchar2(40),
REF_CNT varchar2(40),
EFF_DATE varchar2(8),
E_REF_STATUS varchar2(2),
Z_REF_STATUS varchar2(2),
REF_METHOD varchar2(3),
REF_BK varchar2(15),
REF_BA  varchar2(25),
REF_BD  varchar2(35),
REF_BAT  varchar2(10),
REF_BKRDF  varchar2(10),
REF_RQDT    VARCHAR2(10),
DT_REF varchar2(40),
PRODTYP varchar2(1000),
MBRNO varchar2(1000),
DPNTNO varchar2(1000),
BPREM varchar2(32767),
TRREFNUM varchar2(1000),
PRMFRDT  varchar2(32767),
PRMTODT varchar2(32767),
PAY_DT varchar2(32767),
PRBILFDT  varchar2(32767),
PRBILTDT   varchar2(32767),
BILLDUEDT varchar2(32767),
ZPOSBDSM varchar2(100),
ZPOSBDSY varchar2(500),
RDOCPFX varchar2(1000),
RDOCCOY varchar2(100),
RDOCNUM varchar2(32767),
GBD_PRODTYP varchar2(1000),
GBI_INSTNO varchar2(1000)
) ;
/
create or replace type o_data_set as table of r_data_set;
/