create or replace PROCEDURE GETBPORGRAM 
(abc   IN VARCHAR2 ) 
                                              AS 
                                              
                                              v_bpriorproc bpsrpf.bpriorproc%type;
                                              v_bsubseqprc  bpsrpf.bsubseqprc%type;
                                              v_bprocess  bpsrpf.bpriorproc%type;
                                             v_bprogram bprdpf.bprogram%type;
                                              
  CURSOR cur_schedules IS
  
  

select bschednam, bprocesnam from bspdpf where bschednam in ('G1ZPOLDATA',
'G1ZENDRSCH',
'G1MBRDATAI',
'G1ZCOLRES ',
'G1ZISSUE  ',
'G1ZPENDLST',
'G1ZINSTBIL',
'G1LETREXT ',
'G1ZSTOPBIL',
'G1ZODMRES ',
'G1SALPUPLD',
'G1AUTOALOC',
'G1CAMPDATA',
'G1ZINRGPOS',
'F9AUTOALOC',
'G1ZVALDTEX',
'G1ZFLNET  ',
'G1EXTLETPV',
'G1LDPJ2IG ',
'G1ZPJBLTR ',
'G1ZPODEXT ',
'G1ZINRGFPL',
'G1EXTLETBP');
  obj_schedule cur_schedules%rowtype;
  
  CURSOR cur_process (bprocess in VARCHAR2)IS
  select bpriorproc,bsubseqprc from bpsrpf where UPPER(TRIm(bpriorproc)) like rtrim(bprocess);
  obj_process cur_process%rowtype;


BEGIN
  OPEN cur_schedules;
  <<skipRecord>>
  LOOP
    FETCH cur_schedules
      INTO obj_schedule;
    EXIT WHEN cur_schedules%notfound;
    dbms_output.put_line('****************************************************');

dbms_output.put_line('obj_schedule : ' || obj_schedule.bschednam || ' '||  obj_schedule.bprocesnam);
   select r.bprocesnam,r.bprogram into v_bpriorproc,v_bprogram from bprdpf r where r.bprocesnam = obj_schedule.bprocesnam fetch first 1 rows only;

    dbms_output.put_line('first process : ' || v_bpriorproc || ' BProgram : ' ||v_bprogram);
    
 OPEN cur_process(obj_schedule.bprocesnam);
  <<skipRecord1>>
  LOOP
    FETCH cur_process
      INTO obj_process;
    EXIT WHEN cur_process%notfound;
  
   

     v_bprocess := obj_process.bpriorproc;
    LOOP
    
     if(trim(v_bprocess) is null)then
     exit;
     end if;
    if(trim(v_bprocess) is not null)then
    begin 
  select bpriorproc,bsubseqprc into  v_bpriorproc,v_bsubseqprc from bpsrpf where UPPER(TRIm(bpriorproc)) like rtrim(v_bprocess);
   dbms_output.put_line('Process Details : ''prior process : ' || v_bpriorproc || ' *** ' || 'subsequent process : ' ||v_bsubseqprc);
 select r.bprocesnam,r.bprogram into v_bpriorproc,v_bprogram from bprdpf r where r.bprocesnam = v_bpriorproc;
   select r.bprocesnam,r.bprogram  into v_bpriorproc,v_bprogram from bprdpf r where r.bprocesnam = v_bsubseqprc;
      dbms_output.put_line('Bprogram details : ''subsequent process  : ' ||v_bsubseqprc ||' *** ''B-Program  : ' || v_bprogram);


EXCEPTION
 WHEN OTHERS THEN
 exit;
end;
  
  end if;
v_bprocess:= v_bsubseqprc;
    

   EXIT WHEN trim(v_bprocess) is null;
END LOOP;

      END LOOP;
  CLOSE cur_process;
  
  END LOOP;
  CLOSE cur_schedules;


	


END GETBPORGRAM;