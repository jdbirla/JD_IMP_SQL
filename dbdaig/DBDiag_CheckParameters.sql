set SERVEROUTPUT ON
declare
cursor my_c is
select name, value from v$parameter 
where name in (
'db_name',
'processes',
'sessions',
'open_cursors',
'cpu_count',
'sga_max_size',
'shared_pool_size',
'sga_target',
'pga_aggregate_limit',
'memory_target',
'memory_max_target',
'pga_aggregate_target',
'workarea_size_policy',
'large_pool_size',
'java_pool_size',
'streams_pool_size',
'shared_pool_reserved_size',
'db_cache_advice',
'compatible',
'log_buffer',
'dml_locks',
'transactions',
'temp_undo_enabled',
'undo_management',
'undo_retention',
'recyclebin',
'session_cached_cursors',
'cursor_sharing',
'result_cache_mode',
'parallel_min_servers',
'parallel_max_servers',
'hash_area_size',
'result_cache_max_size',
'commit_logging',
'sort_area_size',
'optimizer_mode',
'parallel_degree_policy',
'parallel_threads_per_cpu',
'optimizer_index_cost_adj',
'query_rewrite_enabled',
'statistics_level',
'parallel_degree_limit',
'parallel_force_local'
) order by name desc;

type para_tbl is table of my_c%ROWTYPE index by PLS_INTEGER;
acc_para_vals para_tbl;

begin
    open my_c;
    fetch my_c
    bulk collect into acc_para_vals; 
    
    for idx in 1..acc_para_vals.COUNT
    loop
        dbms_output.put_line( rpad(acc_para_vals(idx).name,35)|| '= '||CHR(9)|| acc_para_vals(idx).value);    
    end loop;
end;
/
