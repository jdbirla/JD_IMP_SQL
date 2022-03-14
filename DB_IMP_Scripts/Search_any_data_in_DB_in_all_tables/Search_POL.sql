/*
    
*/
DEFINE SQL_LOG_PATH = "H:\SIT_STAGE_DATA\Phase-2\ITR3\SEARCH_POL"
column log_date new_value log_date_text noprint
select to_char(sysdate,'yyyymmdd') log_date from dual;

set head on
set echo off
set feed on
set termout on


spool "&SQL_LOG_PATH.\MAS_pol_PA_&log_date_text..txt"

PROMPT  ******** 
PROMPT  ******** Migrating Tables ********
PROMPT  ******** 

set trimspool on 
set pages 0 
set head off 
set lines 2000 
set serveroutput on
SET VERIFY OFF

set feed on
set echo on
set termout on

Declare

  v_match_count INTEGER;
  v_data_count  INTEGER;

  v_counter INTEGER;

  v_owner         VARCHAR2(255) := 'jdVM1DTA';
  v_search_string VARCHAR2(4000) := '700A5733';
  v_data_type     VARCHAR2(255) := 'CHAR';
  v_sql           CLOB := '';
  v_sql_1         CLOB := '';

BEGIN
  FOR cur_tables IN (SELECT owner, table_name
                       FROM all_tables
                      WHERE owner = v_owner
                        AND table_name IN
                            (SELECT table_name
                               FROM all_tab_columns
                              WHERE owner = all_tables.owner
                                AND data_type LIKE
                                    '%' || UPPER(v_data_type) || '%')
                      ORDER BY table_name) LOOP
    v_counter := 0;
    v_sql     := '';

    FOR cur_columns IN (SELECT column_name, table_name
                          FROM all_tab_columns
                         WHERE owner = v_owner
                           AND table_name = cur_tables.table_name
                           AND data_type LIKE
                               '%' || UPPER(v_data_type) || '%') LOOP
      IF v_counter > 0 THEN
        v_sql := v_sql || ' or ';
      END IF;

      IF cur_columns.column_name is not null THEN
        v_sql := v_sql || '(trim(' || cur_columns.column_name || ')) =''' ||
                 UPPER(trim(v_search_string)) || '''';

        v_counter := v_counter + 1;
      END IF;

    END LOOP;
    v_sql_1 := 'select count(*) from ' || v_owner || '.' ||
               cur_tables.table_name;
    EXECUTE IMMEDIATE v_sql_1
      INTO v_data_count;

    IF (v_data_count > 0) THEN
      IF v_sql is null THEN
        v_sql := 'select count(*) from ' || v_owner || '.' ||
                 cur_tables.table_name;

      END IF;

      IF v_sql is not null THEN
        v_sql := 'select count(*) from ' || v_owner || '.' ||
                 cur_tables.table_name || ' where ' || v_sql;
      END IF;

      --v_sql := 'select count(*) from ' ||v_owner||'.'|| cur_tables.table_name ||' where '||  v_sql;

      --dbms_output.put_line(v_sql);
      --DBMS_OUTPUT.put_line (v_sql);

      EXECUTE IMMEDIATE v_sql
        INTO v_match_count;

      IF v_match_count > 0 THEN
        DBMS_OUTPUT.put_line(v_sql || ';');
        dbms_output.put_line('Match in ' || cur_tables.owner || ': ' ||
                             cur_tables.table_name || ' - ' ||
                             v_match_count || ' records');
      END IF;

      -- ELSE
      -- DBMS_OUTPUT.put_line('v_sql_1: no data ' || v_sql_1);
    END IF;

  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error when executing the following: ' ||
                         DBMS_LOB.SUBSTR(v_sql, 32600));

END SEARCH_POL;
/



spool off
