select * from Jd1dta.pazdclpf where zentity in (select refnum from dmigtitdmgcltrnhis);
select * from Jd1dta.clntpf where clntnum in (select zigvalue from Jd1dta.pazdclpf where zentity in (select refnum from dmigtitdmgcltrnhis));
select * from Jd1dta.clexpf where clntnum in (select zigvalue from Jd1dta.pazdclpf where zentity in (select refnum from dmigtitdmgcltrnhis));


Delete from Jd1dta.clntpf where clntnum in (select zigvalue from Jd1dta.pazdnypf where zentity in (select refnum from dmigtitdmgcltrnhis) and clntstas='NW');
Delete from Jd1dta.clexpf where clntnum in (select zigvalue from Jd1dta.pazdnypf where zentity in (select refnum from dmigtitdmgcltrnhis) and clntstas='NW');
delete from Jd1dta.pazdclpf where zentity in (select refnum from dmigtitdmgcltrnhis);



/*

   INSERT INTO clntpf 
    (SELECT * FROM clntpf AS OF TIMESTAMP 
    TO_TIMESTAMP('2021-01-14 01:00:00','YYYY-MM-DD HH:MI:SS')
      where clntnum ='50582332');
*/