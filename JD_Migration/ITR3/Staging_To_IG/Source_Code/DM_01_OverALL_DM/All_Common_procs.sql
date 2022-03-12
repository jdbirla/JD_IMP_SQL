--------------------------------------------------------
--  File created - Monday-December-17-2018   
--------------------------------------------------------

--------------------------------------------------------
--  DDL for procedure increament sequnce value
--------------------------------------------------------


create or replace procedure Jd1dta.incr_seq( p_seq_name in varchar2, p_incr_val in number )
is
    l_val number;
begin
   execute immediate   'select ' || p_seq_name || '.nextval from dual' INTO l_val;
 dbms_output.put_line('Current Value of sequence : '||l_val );

 dbms_output.put_line('Increment Value of sequence by : '||p_incr_val );

    execute immediate
    'alter sequence ' || p_seq_name || ' increment by ' || p_incr_val;

    execute immediate
    'select ' || p_seq_name || '.nextval from dual' INTO l_val;

 dbms_output.put_line('After increment value of sequnce current value ' || l_val);
   
    execute immediate
    'alter sequence ' || p_seq_name || ' increment by 1';
    
end;



/