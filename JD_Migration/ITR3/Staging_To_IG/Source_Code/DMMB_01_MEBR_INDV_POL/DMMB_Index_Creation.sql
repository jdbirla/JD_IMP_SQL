create index BENCH_CHDR on CHDRPF (CHDRCOY, CHDRNUM, TRANNO, VALIDFLAG)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index BENCH_CHDR2 on CHDRPF (CHDRPFX, CHDRCOY, CHDRNUM, VALIDFLAG, CURRFROM DESC, TRANNO DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index BENCH_CHDR3 on CHDRPF (CHDRNUM, STATCODE)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHAG on CHDRPF (AGNTPFX, AGNTCOY, AGNTNUM, CHDRPFX, CHDRCOY, CHDRNUM, CURRFROM DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHAGWEB on CHDRPF (AGNTPFX, AGNTCOY, AGNTNUM, CHDRPFX, CHDRCOY, CHDRNUM, CURRFROM)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHBA on CHDRPF (FACTHOUS, BANKKEY, BANKACCKEY, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHBM on CHDRPF (SERVUNIT, BILLCHNL, ACCTMETH, CNTCURR, FACTHOUS, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHBN on CHDRPF (CHDRCOY, SERVUNIT, BILLCHNL, FACTHOUS, CNTCURR, BTDATE DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHDR on CHDRPF (CHDRPFX, CHDRCOY, CHDRNUM, VALIDFLAG, CURRFROM DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHDRAFI on CHDRPF (CHDRCOY, CHDRNUM, TRANNO)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHDRAGT on CHDRPF (AGNTPFX, AGNTCOY, AGNTNUM, VALIDFLAG, CHDRCOY, CHDRNUM)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHDRARC on CHDRPF (CHDRCOY, CHDRNUM)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHDROWN on CHDRPF (COWNPFX, COWNCOY, COWNNUM, MANDREF, CHDRNUM, CCDATE DESC, TRANNO DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index CHDRPYR on CHDRPF (PAYRPFX, PAYRCOY, PAYRNUM, MANDREF, CHDRNUM, CCDATE DESC, TRANNO DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GCHDOWN on CHDRPF (COWNCOY, COWNNUM, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index HCHRMPS on CHDRPF (CHDRCOY)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index PRCC on CHDRPF (CHDRPFX, CHDRCOY, CHDRNUM, STATCODE, CURRFROM DESC, TRANNO DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index PRCT on CHDRPF (CHDRPFX, CHDRCOY, CHDRNUM, VALIDFLAG, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
  -------------
  
  create index GCAG on GCHIPF (AGNTPFX, AGNTCOY, AGNTNUM, CHDRCOY, CHDRNUM, EFFDATE DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GCHI on GCHIPF (CHDRCOY, CHDRNUM, EFFDATE DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GCHIASC on GCHIPF (CHDRCOY, CHDRNUM, EFFDATE, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GCHIPYR on GCHIPF (PAYRPFX, PAYRCOY, PAYRNUM, MANDREF, CHDRNUM, CCDATE DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GCHIRNL on GCHIPF (CHDRCOY, CRDATE DESC, CNTBRANCH, CHDRNUM, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GCHITRN on GCHIPF (CHDRCOY, CHDRNUM, TRANNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  ----
  create index BENCH_GMHD on GMHDPF (CHDRCOY, CLNTNUM, CHDRNUM, MBRNO, DPNTNO, DTETRM, CLNTPFX, FSUCO, EMPNO, INFORCE)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

create index GMHDCLI on GMHDPF (CLNTPFX, FSUCO, CLNTNUM, HEADCNT, CHDRCOY, CHDRNUM, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMHDCLN on GMHDPF (CHDRCOY, CHDRNUM, CLNTPFX, FSUCO, CLNTNUM, HEADCNT, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMHDCLT on GMHDPF (CHDRCOY, CHDRNUM, CLNTPFX, FSUCO, CLNTNUM, HEADCNT, DTEATT, MBRNO, DPNTNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMHDEMP on GMHDPF (CHDRCOY, CHDRNUM, EMPNO, DPNTNO, UNIQUE_NUMBER DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMHDENO on GMHDPF (CHDRCOY, EMPNO, CHDRNUM, MBRNO, DPNTNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
 
create index GMHIEFF on GMHIPF (CHDRCOY, CHDRNUM, EFFDATE DESC, UNIQUE_NUMBER DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

create index GMHISUM on GMHIPF (CHDRCOY, CHDRNUM, SUBSCOY, SUBSNUM, MBRNO, DPNTNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  ------
 
create index GXHIHDC on GXHIPF (CHDRCOY, CHDRNUM, HEADNO, MBRNO, DPNTNO, PRODTYP, PLANNO, EFFDATE, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHIMBR on GXHIPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, PRODTYP, PLANNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHIMDE on GXHIPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, EFFDATE DESC, PRODTYP, PLANNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHIMPD on GXHIPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, PRODTYP, EFFDATE DESC, PLANNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHINEW on GXHIPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, PRODTYP, EFFDATE DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHIPEM on GXHIPF (CHDRCOY, CHDRNUM, PRODTYP, PLANNO, EFFDATE, MBRNO, DPNTNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHIPLN on GXHIPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, PLANNO, PRODTYP, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHIPMP on GXHIPF (CHDRCOY, CHDRNUM, PRODTYP, MBRNO, DPNTNO, PLANNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHIPRD on GXHIPF (CHDRCOY, CHDRNUM, PRODTYP, PLANNO, MBRNO, DPNTNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GXHITRN on GXHIPF (CHDRCOY, CHDRNUM, PLANNO, TRANNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
  create index GAPH on GAPHPF (CHDRCOY, CHDRNUM, HEADCNTIND, MBRNO, DPNTNO, PRODTYP, EFFDATE, TRANNO DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GAPHBIL on GAPHPF (CHDRCOY, CHDRNUM, HEADCNTIND, MBRNO, DPNTNO, PRODTYP, EFFDATE DESC, TRANNO DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GAPHEFF on GAPHPF (CHDRCOY, CHDRNUM, HEADCNTIND, MBRNO, DPNTNO, PRODTYP, EFFDATE, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GAPHMEF on GAPHPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, EFFDATE DESC, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GAPHMPP on GAPHPF (CHDRCOY, CHDRNUM, EFFDATE DESC, HEADCNTIND, MBRNO, DPNTNO, UNIQUE_NUMBER DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
  ---
  create index MTRN on MTRNPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, TRANNO, RLDPNTNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index MTRNCHE on MTRNPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, CHGTYPE, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index MTRNRIE on MTRNPF (CHDRCOY, CHDRNUM, MBRNO, DPNTNO, TRANNO, UNIQUE_NUMBER)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index MTRNTNO on MTRNPF (CHDRCOY, CHDRNUM, TRANNO, UNIQUE_NUMBER DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  ----
  create index GMOV on GMOVPF (CHDRCOY, CHDRNUM, RFMT, REFKEY, EFFDATE, TRANNO)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMOVBLL on GMOVPF (CHDRCOY, CHDRNUM, TRANNO, RIPRIOR, REFKEY)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMOVCHK on GMOVPF (CHDRCOY, CHDRNUM, TRANNO DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMOVFUN on GMOVPF (CHDRCOY, CHDRNUM, TRANNO, REFKEY, FUNCCODE)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMOVRED on GMOVPF (CHDRCOY, CHDRNUM, TRANNO)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMOVREF on GMOVPF (CHDRCOY, CHDRNUM, TRANNO, FUNCCODE, RFMT, REFKEY)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index GMOVRFM on GMOVPF (CHDRCOY, CHDRNUM, TRANNO, RFMT, REFKEY)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

  create index ZTIERPF_SORT_IDX on ZTIERPF (CHDRCOY, CHDRNUM DESC, MBRNO DESC, PRODTYP DESC, TRANNO DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
  
  create index ZTEMPTIERPF_SORT_IDX on ZTEMPTIERPF (CHDRCOY, CHDRNUM DESC, MBRNO DESC, PRODTYP DESC, TRANNO DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
  
  create index ZTEMPCOVPF_SORT_IDX on ZTEMPCOVPF (CHDRCOY DESC, CHDRNUM DESC, MBRNO DESC, TRANNO DESC, PRODTYP DESC)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );