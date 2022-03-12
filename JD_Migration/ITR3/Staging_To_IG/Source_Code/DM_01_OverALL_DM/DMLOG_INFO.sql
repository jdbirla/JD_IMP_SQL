create or replace procedure DMLOG_INFO(i_LKEY  IN VARCHAR2,
                                       i_LTEXT IN VARCHAR2) is
  /**
  * File Name        : DMLOG_INFO
  * Author           : Jitendra Birla
  * Creation Date    : March 12,2018
  * Project          : -----
  -----(formerly jdc Technologies India Private Limited)
  * Description      : Data Migration logging dynamically when Procedure called by Batch program, 
  it will log the user specific information without commit the whole transaction
  **/

  PRAGMA AUTONOMOUS_TRANSACTION;
begin

  Delete from DMLOG;
  insert into DMLOG (LKEY, LTEXT) values (i_LKEY, i_LTEXT);
  Commit;
end DMLOG_INFO;
/