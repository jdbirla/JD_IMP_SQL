select * from Jd1dta.pazdchpf where zentity in (select refnum from dmigtitdmgcltrnhis);
select * from Jd1dta.zclnpf where clntnum in (select zigvalue from Jd1dta.pazdchpf where zentity in (select refnum from dmigtitdmgcltrnhis));
select * from Jd1dta.audit_clntpf where newclntnum in (select zigvalue from Jd1dta.pazdchpf where zentity in (select refnum from dmigtitdmgcltrnhis));
select * from Jd1dta.audit_clnt where clntnum in (select zigvalue from Jd1dta.pazdchpf where zentity in (select refnum from dmigtitdmgcltrnhis));
select * from Jd1dta.audit_clexpf where newclntnum in (select zigvalue from Jd1dta.pazdchpf where zentity in (select refnum from dmigtitdmgcltrnhis));
select * from Jd1dta.versionpf where clntnum in (select zigvalue from Jd1dta.pazdchpf where zentity in (select refnum from dmigtitdmgcltrnhis));



Delete from Jd1dta.zclnpf where clntnum in (select zigvalue from Jd1dta.pazdnypf where zentity in (select refnum from dmigtitdmgcltrnhis) and clntstas='NW');
Delete from Jd1dta.audit_clntpf where newclntnum in (select zigvalue from Jd1dta.pazdnypf where zentity in (select refnum from dmigtitdmgcltrnhis) and clntstas='NW');
Delete from Jd1dta.audit_clnt where clntnum in (select zigvalue from Jd1dta.pazdnypf where zentity in (select refnum from dmigtitdmgcltrnhis) and clntstas='NW');
Delete from Jd1dta.audit_clexpf where newclntnum in (select zigvalue from Jd1dta.pazdnypf where zentity in (select refnum from dmigtitdmgcltrnhis) and clntstas='NW');
Delete from Jd1dta.versionpf where clntnum in (select zigvalue from Jd1dta.pazdnypf where zentity in (select refnum from dmigtitdmgcltrnhis) and clntstas='NW');
Delete from Jd1dta.pazdchpf where zentity in (select refnum from dmigtitdmgcltrnhis);


