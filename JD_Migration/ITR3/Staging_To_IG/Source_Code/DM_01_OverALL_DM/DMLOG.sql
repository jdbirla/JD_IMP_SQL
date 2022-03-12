
create table DMLOG
(
  id    NUMBER generated always as identity,
  ldate DATE default sysdate not null,
  lkey  VARCHAR2(2000) not null,
  ltext VARCHAR2(2000) not null
);
-- Add comments to the columns 
comment on column DMLOG.id
  is 'Log ID';
comment on column DMLOG.ldate
  is 'Log Daate';
comment on column DMLOG.lkey
  is 'Logging key';
comment on column DMLOG.ltext
  is 'Logging text';