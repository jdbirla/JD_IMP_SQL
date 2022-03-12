SET SERVEROUTPUT ON SIZE 1000000
BEGIN
  FOR cur_rec IN (SELECT owner,
                         object_name,
                         object_type,
                         DECODE(object_type, 'PACKAGE', 1,
                                             'PACKAGE BODY', 2, 2) AS recompile_order
                  FROM   dba_objects
                  WHERE  object_type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
                  AND    status != 'VALID'
                  AND    owner = 'STAGEDBUSR2'
                  ORDER BY 4)
  LOOP
    BEGIN
      IF cur_rec.object_type = 'PACKAGE BODY' THEN
        EXECUTE IMMEDIATE 'ALTER PACKAGE' || 
            ' "' || cur_rec.owner || '"."' || cur_rec.object_name || '" COMPILE BODY';
      ELSE
        EXECUTE IMMEDIATE 'ALTER ' || cur_rec.object_type || ' "' || cur_rec.owner || 
            '"."' || cur_rec.object_name || '" COMPILE';       
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Compilation Error on ' || cur_rec.object_type || ' "' || cur_rec.owner || '"."' || cur_rec.object_name || '"');
    END;
  END LOOP;
END;


