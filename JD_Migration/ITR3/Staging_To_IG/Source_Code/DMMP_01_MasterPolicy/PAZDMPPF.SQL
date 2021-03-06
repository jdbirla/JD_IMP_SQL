CREATE TABLE Jd1dta.PAZDMPPF 
(
  RECIDXCLIENT NUMBER(*, 0) GENERATED ALWAYS AS IDENTITY INCREMENT BY 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 CACHE 20 NOT NULL 
, RECSTATUS VARCHAR2(10 CHAR) DEFAULT 'New' 
, PREFIX VARCHAR2(2 CHAR) 
, ZENTITY VARCHAR2(50 CHAR) 
, ZIGVALUE VARCHAR2(50 CHAR) 
, JOBNUM NUMBER(8, 0) 
, JOBNAME VARCHAR2(10 CHAR) 
) 
LOGGING 
TABLESPACE USERS 
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOCOMPRESS 
NOPARALLEL
