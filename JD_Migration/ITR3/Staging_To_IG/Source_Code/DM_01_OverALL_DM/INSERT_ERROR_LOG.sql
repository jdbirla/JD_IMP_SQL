create or replace PROCEDURE insert_error_log   (in_error_code    IN error_log.v_error_code%TYPE
                            ,in_error_message         IN error_log.v_error_message%TYPE DEFAULT NULL
                            ,in_prog         IN error_log.v_prog%TYPE DEFAULT NULL
                            )
IS

/*****************************************************************************************************
  Program Type    : Procedure
  Program Name    : insert_error_log
  Trigger Event   :
  Description     : This procedure is introduced to log the errors into ERROR_LOG table

  Version History :
  Version    Date           Author            Description of changes
  -----------------------------------------------------------------------------------------------------
  1.0       20/10/2020    Lakshmanaprabu K     Initial version
 *******************************************************************************************************/

PRAGMA AUTONOMOUS_TRANSACTION;
v_error_code error_log.v_error_code%TYPE :=0;


BEGIN

IF in_error_code is null then
v_error_code := 0;
else
v_error_code := in_error_code;
end if;

    INSERT INTO error_log
        (v_err_seq
        ,v_error_code
        ,v_error_message
        ,v_error_stack
        ,v_call_stack
        ,v_error_backtrace
        ,v_created_by
        ,v_prog
        ,d_created_on
        )
        VALUES
        (error_log_seq.NEXTVAL
        ,v_error_code
        ,substr(in_error_message,1,4000)
        ,substr(dbms_utility.format_error_stack,1,4000)
        ,substr(dbms_utility.format_call_stack,1,4000)
        ,substr(dbms_utility.format_error_backtrace,1,4000)
        ,sys_context('USERENV','SESSION_USER')||'-'||sys_context('USERENV','SID')
        ,in_prog
        ,sysdate
        );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR (-20001, 'Problem while logging errors. '||SQLCODE||SQLERRM);

END insert_error_log;