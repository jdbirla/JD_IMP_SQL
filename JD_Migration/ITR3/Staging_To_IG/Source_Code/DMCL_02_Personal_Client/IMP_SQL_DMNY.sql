select * from Jd1dta.pazdnypf where zentity in (select refnum from DMIGTITNYCLT);
delete from Jd1dta.pazdnypf where zentity in (select refnum from DMIGTITNYCLT);
