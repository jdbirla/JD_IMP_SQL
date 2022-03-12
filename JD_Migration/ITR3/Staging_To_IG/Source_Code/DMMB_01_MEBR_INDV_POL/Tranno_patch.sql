
---
select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,a.tranlused,B.trannomax from gchd A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0;--170599  Rows
merge into GCHD T1
using 
(select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,a.tranlused,B.trannomax from gchd A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0)T2
ON (T1.chdrnum = T2.chdrnum and T1.UNIQUE_NUMBER = T2.UNIQUE_NUMBER)
WHEN MATCHED THEN 
update set T1.tranno = T2.trannomax , T1.tranlused = T2.trannomax;
----

merge into gchipf T1
using 
(select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,b.trannonbrn from gchipf A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0)T2
ON (T1.chdrnum = T2.chdrnum and T1.UNIQUE_NUMBER = T2.UNIQUE_NUMBER)
WHEN MATCHED THEN 
update set T1.tranno = T2.trannonbrn;

---
select * from gmhdpf where chdrnum in (select chdrnum from gchd where statcode = 'CA' and jobnm ='G1ZDMBRIND');--6595  Rows

merge into gmhdpf T1
using 
(select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,b.trannomax
from gmhdpf A INNER join
gchd G on A.chdrnum = G.chdrnum and G.statcode='CA' Inner join
dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0)T2
ON (T1.chdrnum = T2.chdrnum and T1.UNIQUE_NUMBER = T2.UNIQUE_NUMBER)
WHEN MATCHED THEN 
update set T1.tranno = T2.trannomax;
--
select * from gmhdpf where chdrnum in (select chdrnum from gchd where statcode != 'CA' and jobnm ='G1ZDMBRIND');-- 175562  Rows

 merge into gmhdpf T1
using 
(select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,b.trannomin
from gmhdpf A INNER join
gchd G on A.chdrnum = G.chdrnum and G.statcode!='CA' Inner join
dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0)T2
ON (T1.chdrnum = T2.chdrnum and T1.UNIQUE_NUMBER = T2.UNIQUE_NUMBER)
WHEN MATCHED THEN 
update set T1.tranno = T2.trannomin;

-----
select * from gmhipf where chdrnum in (select chdrnum from gchd where statcode = 'CA' and jobnm ='G1ZDMBRIND');--6595  Rows

merge into gmhipf T1
using 
(select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,b.trannomax
from gmhipf A INNER join
gchd G on A.chdrnum = G.chdrnum and G.statcode='CA' Inner join
dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0)T2
ON (T1.chdrnum = T2.chdrnum and T1.UNIQUE_NUMBER = T2.UNIQUE_NUMBER)
WHEN MATCHED THEN 
update set T1.tranno = T2.trannomax;


---

select * from gmhipf where chdrnum in (select chdrnum from gchd where statcode != 'CA' and jobnm ='G1ZDMBRIND');-- 175562  Rows

 merge into gmhipf T1
using 
(select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,b.trannomin
from gmhipf A INNER join
gchd G on A.chdrnum = G.chdrnum and G.statcode!='CA' Inner join
dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0)T2
ON (T1.chdrnum = T2.chdrnum and T1.UNIQUE_NUMBER = T2.UNIQUE_NUMBER)
WHEN MATCHED THEN 
update set T1.tranno = T2.trannomin;


------------------After patching cheking

select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,a.tranlused,B.trannomax 
from gchd A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0
and a.tranno != B.trannomax;

select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,B.trannomax 
from gchipf A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0
and a.tranno != b.trannonbrn;

select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,B.trannomax 
from gmhdpf A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0 and b.statcode='CA'
and a.TRANNO != B.trannomax;


select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,B.trannomax 
from gmhdpf A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0 and b.statcode!='CA'
and a.TRANNO != B.trannomin;

select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,B.trannomax 
from gmhipf A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0 and b.statcode='CA'
and a.TRANNO = B.trannomax;

select   A.UNIQUE_NUMBER,A.chdrnum,a.tranno,B.trannomax 
from gmhipf A INNER join dmigtitdmgmbrindp1 B on A.chdrnum =substr(B.refnum,1,8) and b.client_category=0 and b.statcode!='CA'
and a.TRANNO = B.trannomin;

----

/*
obj_gchd.TRANNO    := obj_mbrindp1.trannomax;
obj_gchd.TRANLUSED := obj_mbrindp1.trannomax; --MB12 : TRANNO == TRANLUSED
obj_gchipf.TRANNO := obj_mbrindp1.trannonbrn;



 IF (TRIM(obj_PolDatarec.statcode) = 'CA') THEN
              obj_gmhdpf.TRANNO := obj_mbrindp1.trannomax;
            ELSE
              obj_gmhdpf.TRANNO := obj_mbrindp1.trannomin;
            END IF;
            
             IF (TRIM(obj_PolDatarec.statcode) = 'CA') THEN
            obj_gmhipf.TRANNO := obj_mbrindp1.trannomax;
          ELSE
            obj_gmhipf.TRANNO := obj_mbrindp1.trannonbrn;
          END IF;*/