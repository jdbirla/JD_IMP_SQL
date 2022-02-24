set pagesize 0 trimspool on linesize 32700 underline off term off feed off

spool &1/TOTPAMPOLDATA.csv;
select '"'||RECIDXPOLDATA||'","'||PHSURNAME||'","'||PHGIVNAME||'","'||PHBSURNAMEJ||'","'||PHBGIVNAMEJ||'","'||PHCLTHPHONE||'","'||PHCLTOPHONE||'","'||PHFAXNO||'","'||PHMOBILE||'","'||PHBPOSTCODE||'","'||PHBADD1R||'","'||PHBADD2R||'","'||PHBADD3R||'","'||PHBADD4R||'","'||PHBADD5R||'","'||PHBADD6R||'","'||PHBADD7R||'","'||PHBADD8R||'","'||PHBANKACCKEY||'","'||PHBANKACCDSC||'","'||PHCARDNMB||'","'||PHCARDNAME||'","'||ISSURNAME||'","'||ISGIVNAME||'","'||ISBSURNAMEJ||'","'||ISBGIVNAMEJ||'","'||ISCLTHPHONE||'","'||ISCLTOPHONE||'","'||ISFAXNO||'","'||ISMOBILE||'","'||ISBADD1R||'","'||ISBADD2R||'","'||ISBADD3R||'","'||ISBADD4R||'","'||ISBADD5R||'","'||ISBADD6R||'","'||ISBADD7R||'","'||ISBADD8R||'","'||CCARD||'"' from STAGEDBUSR.TOTPAMPOLDATA;
spool off;
