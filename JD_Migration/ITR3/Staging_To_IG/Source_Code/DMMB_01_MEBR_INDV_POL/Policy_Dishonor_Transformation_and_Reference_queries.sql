----------------------------------
-------REFERENCE Queries----------
----------------------------------
-------- R1 --------
SELECT src.OLDPOLNUM AS SRC_OLDPOLNUM, ig.ZPRVCHDR AS IG_OLDPOLNUM,
ig.CHDRNUM AS IG_ZCHDRNUM FROM STAGEDBUSR2.TITDMGMBRINDP3@DMSTAGEDBLINK src 
LEFT JOIN  Jd1dta.GCHD ig ON src.OLDPOLNUM = ig.ZPRVCHDR
;