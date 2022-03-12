DECLARE
  p_exitcode number;
  p_exittext varchar2(2000);
  
BEGIN
	INSERT /*+ APPEND*/ INTO Jd1dta.ZCORPF NOLOGGING
	(
	CHDRCOY,
	CHDRNUM,
	TRANNO,
	ZKANASNM,
	ZKANAGNM,
	LSURNAME,
	LGIVNAME,
	ZRCORADR,
	CLTPCODE,
	CLTADDR01,
	CLTADDR02,
	CLTADDR03,
	CLTADDR04,
	ZKANADDR01,
	ZKANADDR02,
	ZKANADDR03,
	ZKANADDR04,
	CLTPHONE01,
	USRPRF,
	JOBNM,
	DATIME,
	EFFDATE
	) 
	SELECT   
	'1',
	A.CHDRNUM,
	A.TRANNO,
    B.ZKANASNM,
	B.ZKANAGNM,
	B.LSURNAME,
	B.LGIVNAME,
	'Y',
	B.CLTPCODE,
	B.CLTADDR01,
	B.CLTADDR02,
	B.CLTADDR03,
	B.CLTADDR04,
	B.ZKANADDR01,
	B.ZKANADDR02,
	B.ZKANADDR03,
	B.ZKANADDR04,
	B.CLTPHONE01,
	'JBIRLA',
	'G1ZDPOLHST',
	CAST(sysdate AS TIMESTAMP),
    A.EFDATE
	FROM Jd1dta.ZTRAPF A
	INNER JOIN stagedbusr.titdmgcoraddr@dmstagedblink B on A.chdrnum = B.chdrnum
    Inner join Jd1dta.pazdptpf r on r.zentity = a.chdrnum and r.tranno = a.tranno and r.effdate = a.effdate and r.mbrno='00001'
    WHERE A.ZTRXSTAT = 'AP' 
    order by A.chdrnum,a.tranno;
 
	COMMIT;
	
	merge into Jd1dta.zaltpf fn
	using (
		select za.unique_number, za.chdrnum, za.tranno,
		zc.zkanasnm,
		zc.zkanagnm,
		zc.lsurname,
		zc.lgivname,
		'Y' as zrcoradr,
		zc.cltpcode,
		zc.cltaddr01,
		zc.cltaddr02,
		zc.cltaddr03,
		zc.cltaddr04,
		zc.zkanaddr01,
		zc.zkanaddr02,
		zc.zkanaddr03,
		zc.zkanaddr04,
		zc.cltphone01
		from zaltpf za
		inner join stagedbusr.titdmgcoraddr@dmstagedblink zc ON za.chdrnum = zc.chdrnum
	)od 
	on (fn.unique_number = od.unique_number and fn.chdrnum = od.chdrnum and fn.tranno = od.tranno)
	when matched then
	update set fn.zkanasnm = od.zkanasnm,
	fn.zkanagnm = od.zkanagnm,
	fn.kanjisurname = od.lsurname,
	fn.kanjigivname = od.lgivname,
	fn.zrcoradr = od.zrcoradr,
	fn.cltpcode = od.cltpcode,
	fn.kanjicltaddr01 = od.cltaddr01,
	fn.kanjicltaddr02 = od.cltaddr02,
	fn.kanjicltaddr03 = od.cltaddr03,
	fn.kanjicltaddr04 = od.cltaddr04,
	fn.zkanaddr01 = od.zkanaddr01,
	fn.zkanaddr02 = od.zkanaddr02,
	fn.zkanaddr03 = od.zkanaddr03,
	fn.zkanaddr04 = od.zkanaddr04,
	fn.cltphone01 = od.cltphone01
	;

	COMMIT;
	

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    p_exitcode := SQLCODE;
    p_exittext := 'CORRESPONDENCE_ADDRESS_INSERT_ZCORPF : ' ||
                  DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm;

    insert into Jd1dta.dmberpf
      (schedule_name, JOB_NUM, error_code, error_text, DATIME)
    values
      ('G1ZDPOLHST', '00000', p_exitcode, p_exittext, sysdate);
       raise;
    commit;
END;