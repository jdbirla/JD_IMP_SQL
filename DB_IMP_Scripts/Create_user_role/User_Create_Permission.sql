---Create user with permissions
create user jpacpr identified by ".....";
grant create session to jpacpr;
grant create table to jpacpr;
alter user jpacpr quota unlimited on users;
grant create view, create procedure, create sequence to jpacpr;

--============================================================================================================================
--- The script to give access of vm1dta to ckphelper. To be run from VM1DTA schema.
--- Usage:  exec grant_dml_toschema('VM1DTA','CKPHELPER'); 
CREATE PROCEDURE grant_dml_toschema(
    username VARCHAR2, 
    grantee VARCHAR2)
AS   
BEGIN
    FOR r IN (
        SELECT owner, table_name 
        FROM all_tables 
        WHERE owner = username
    )
    LOOP
        EXECUTE IMMEDIATE 
            'GRANT SELECT,INSERT, UPDATE, DELETE ON '||r.owner||'.'||r.table_name||' to ' || grantee;
    END LOOP;
	
	/*-- for all the views also -- if ther is any view which is not compiled or have error then this part will give error.
	FOR v IN (
        SELECT owner, view_name 
        FROM all_views 
        WHERE owner = username
    )
	LOOP
		EXECUTE  IMMEDIATE
			'GRANT SELECT ON ' ||v.owner||'.'||v.view_name||' to ' || grantee ;
	END LOOP;*/
	
END;
/
--============================================================================================================================
