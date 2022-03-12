create or replace PACKAGE          "PKG_DM_CORPORATE" as

  TYPE mplnum_tab IS
        TABLE OF VARCHAR(8) INDEX BY VARCHAR2(20);

  PROCEDURE getmasterpolicy(itemexist OUT mplnum_tab);


  TYPE instype_tab IS
        TABLE OF VARCHAR(3) INDEX BY VARCHAR2(3);

  ----CC5
  TYPE agntnum_tab IS
        TABLE OF VARCHAR(8) INDEX BY VARCHAR2(20);

  PROCEDURE getagent(itemexist OUT agntnum_tab);
  ----CC5
  
  PROCEDURE getinstype(i_itempfx IN VARCHAR2, i_company IN VARCHAR2, itemexist OUT instype_tab);

  PROCEDURE removeLegalPersonality(i_name IN VARCHAR2, o_name OUT VARCHAR2);
  
  PROCEDURE chkAllHalfSizeChar(i_charactors IN VARCHAR2, results OUT BOOLEAN);


end PKG_DM_CORPORATE;
/
create or replace PACKAGE BODY        PKG_DM_CORPORATE AS

  PROCEDURE getmasterpolicy(itemexist OUT mplnum_tab)
  
   is
    indexitems PLS_INTEGER;
    TYPE obj_stagef IS RECORD(
      i_clntkey   VARCHAR2(12),
      i_MPLNUM    VARCHAR2(08));	
    TYPE v_array IS TABLE OF obj_stagef;
    stagelist v_array;
    
    c_delimiter              CONSTANT CHAR(2) := '__';

  BEGIN

    SELECT 
          CLNTKEY
         ,MPLNUM
    BULK COLLECT
    into stagelist
    FROM
          stagedbusr.titdmgclntcorp@dmstagedblink
    WHERE
         TRIM(MPLNUM) IS NOT NULL
    ORDER BY clntkey ASC;

    FOR indexitems IN stagelist.first .. stagelist.last LOOP
        itemexist(TRIM(stagelist(indexitems).i_clntkey) || c_delimiter || indexitems) := TRIM(stagelist(indexitems).i_MPLNUM);
        ---DBMS_OUTPUT.PUT_LINE('[getmasterpolicy] : ' ||  TRIM(stagelist(indexitems).i_clntkey) || c_delimiter || indexitems || ']' || TRIM(stagelist(indexitems).i_MPLNUM));
    
    END LOOP;    

  END;


  PROCEDURE getinstype(i_itempfx IN VARCHAR2, i_company IN VARCHAR2, itemexist OUT instype_tab)
  
   is
    indexitems PLS_INTEGER;
    TYPE obj_itempf IS RECORD(
      i_cnttype  VARCHAR2(3),
      i_instype  VARCHAR2(3));
     	
    TYPE v_array IS TABLE OF obj_itempf;
    itempflist v_array;
    

  BEGIN

    SELECT
            substr(itemitem,1,3) cnttype
            ,substr(utl_raw.cast_to_varchar2(genarea),5,3) instype 
    BULK COLLECT
    into itempflist
    FROM
         itempf
    WHERE                    
            itemtabl = 'TR9GW'
            AND TRIM(itemitem) is not null
            AND substr(utl_raw.cast_to_varchar2(genarea),5,3) = 'SHI'
            AND itempfx = i_itempfx
            and itemcoy = i_company
            AND validflag = '1'
    GROUP BY 
            substr(itemitem,1,3)
           ,substr(utl_raw.cast_to_varchar2(genarea),5,3)
    ;

    FOR indexitems IN itempflist.first .. itempflist.last LOOP
    
        itemexist(TRIM(itempflist(indexitems).i_cnttype)) := TRIM(itempflist(indexitems).i_instype);
        ---DBMS_Output.PUT_LINE('[getinstype] cnttype :'  || TRIM(itempflist(indexitems).i_cnttype) || ', Instype : ' ||TRIM(itempflist(indexitems).i_instype));
        
    END LOOP;    

  END;
  

  PROCEDURE removeLegalPersonality(i_name IN VARCHAR2,  o_name OUT VARCHAR2)
  
   is
   
    TYPE v_array IS VARRAY(163) OF VARCHAR2(100);

    LegalPer v_array := v_array(
                                ' '
                               ,'　'
                               ,'ｲﾂﾊﾟﾝｻﾞｲﾀﾞﾝﾎｳｼﾞﾝ'
                               ,'ｺｳｴｷｻﾞｲﾀﾞﾝﾎｳｼﾞﾝ'
                               ,'ｲﾘﾖｳﾎｳｼﾞﾝｻﾞｲﾀﾞﾝ'
                               ,'ｻﾞｲﾀﾝｼﾔﾀﾟﾎｳｼﾞﾝ'
                               ,'ｲﾂﾊﾟﾝｼﾔﾀﾟﾎｳｼﾞﾝ'
                               ,'ｲﾘﾖｳﾎｳｼﾞﾝｼﾔﾀﾞﾝ'
                               ,'ﾄｸﾃｲﾋｴｲﾘﾎｳｼﾞﾝ'
                               ,'ｶﾌﾞｼｷｶﾞｲｼﾔ'
                               ,'ﾕｳｹﾞﾝｶﾞｲｼﾔ'
                               ,'ｺﾞｳﾒｲｶﾞｲｼﾔ'
                               ,'ｶﾞﾂｺｳﾎｳｼﾞﾝ'
                               ,'ｻﾞｲﾀﾝﾎｳｼﾞﾝ'
                               ,'ｶﾌﾞｼｷｶｲｼﾔ'
                               ,'ﾕｳｹﾞﾝｶｲｼﾔ'
                               ,'ｺﾞｳｼｶﾞｲｼﾔ'
                               ,'ｺﾞｳﾒｲｶｲｼﾔ'
                               ,'ｼﾔﾀﾟﾎｳｼﾞﾝ'
                               ,'ｺﾞｳｼｶﾞｲｼﾔ'
                               ,'ｲﾘﾖｳﾎｳｼﾞﾝ'
                               ,'.ｶﾌﾞ.'   
                               ,'ｺﾞｳｼｶｲｼﾔ'
                               ,'ｺﾞｳｼｶｲｼﾔ'
                               ,'ｴｲｷﾞﾖｳｼﾖ'
                               ,'ｼﾕﾂﾁﾖｳｼﾖ'
                               ,'.ｿ.'    
                               ,'.ｷﾖｳｸﾐ.'
                               ,'.ｷﾖｳｸﾐ)'
                               ,',ｷﾖｳｸﾐ,'
                               ,',ｷﾖｳｸﾐ)'
                               ,'.ｺﾞｳｼ.'
                               ,'.ｺﾞｳｼ)'
                               ,'.ｷﾖｳｸﾐ'
                               ,',ｺﾞｳｼ,'
                               ,',ｺﾞｳｼ)'
                               ,',ｷﾖｳｸﾐ'
                               ,',ﾄｸﾋ)' 
                               ,',ﾄｸﾋ)' 
                               ,'.ｶﾌﾞ' 
                               ,'.ｶﾌﾞ)'
                               ,'.ｺﾞｳｼ'
                               ,'.ｺﾞｳ.'
                               ,'.ｺﾞｳ)'
                               ,'.ｶﾞｸ.'
                               ,'.ｶﾞｸ)'
                               ,'.ｻﾞｲ.'
                               ,'.ｻﾞｲ)'
                               ,'.ｼﾕﾂ.'
                               ,'.ｼﾕﾂ)'
                               ,'.ｷﾖｳ.'
                               ,'.ｷﾖｳ)'
                               ,'.ｼﾕｳ.'
                               ,'.ｼﾕｳ)'
                               ,',ｶﾌﾞ,'
                               ,',ｶﾌﾞ)'
                               ,',ｺﾞｳｼ'
                               ,',ｺﾞｳ,'
                               ,',ｺﾞｳ)'
                               ,',ｶﾞｸ,'
                               ,',ｶﾞｸ)'
                               ,',ｻﾞｲ,'
                               ,',ｻﾞｲ)'
                               ,',ｼﾕﾂ,'
                               ,',ｼﾕﾂ)'
                               ,',ｷﾖｳ,'
                               ,',ｷﾖｳ)'
                               ,',ｼﾕｳ,'
                               ,',ｼﾕｳ)'
                               ,'ｷﾖｳｸﾐ'
                               ,'.ﾄｸﾋ.'
                               ,'.ﾄｸﾋ)'
                               ,',ﾄｸﾋ,'
                               ,',ﾄｸﾋ,'
                               ,'.ﾕｳ.'
                               ,'.ﾕｳ)'
                               ,'.ｺﾞｳ'
                               ,'.ｶﾞｸ'
                               ,'.ｻﾞｲ'
                               ,'.ｼﾔ.'
                               ,'.ｼﾔ)'
                               ,'.ｴｲ.'
                               ,'.ｴｲ)'
                               ,'.ｼﾕﾂ'
                               ,'.ｼﾕ.'
                               ,'.ｼﾕ)'
                               ,'.ｷﾖｳ'
                               ,'.ｼﾕｳ'
                               ,'.ﾌｸ.'
                               ,'.ﾌｸ)'
                               ,',ｶﾌﾞ'
                               ,',ﾕｳ,'
                               ,',ﾕｳ)'
                               ,',ｺﾞｳ'
                               ,',ﾒｲ,'
                               ,',ﾒｲ)'
                               ,',ｶﾞｸ'
                               ,',ｻﾞｲ'
                               ,',ｼﾔ,'
                               ,',ｼﾔ)'
                               ,',ｴｲ,'
                               ,',ｴｲ)'
                               ,',ｼﾕﾂ'
                               ,',ｼﾕ,'
                               ,',ｼﾕ)'
                               ,',ｷﾖｳ'
                               ,',ｼﾕｳ'
                               ,',ﾌｸ,'
                               ,',ﾌｸ)'
                               ,',ﾄﾞ,'
                               ,',ﾄﾞ)'
                               ,'.ﾄｸﾋ'
                               ,',ﾄｸﾋ'
                               ,',ﾄｸﾋ'
                               ,'.ｶ.'
                               ,'.ｶ)'
                               ,'.ﾕｳ'
                               ,'.ﾕ.'
                               ,'.ﾕ)'
                               ,'.ｿ)'
                               ,'.ﾒ.'
                               ,'.ﾒ)'
                               ,'.ｼﾔ'
                               ,'.ｼ.'
                               ,'.ｼ)'
                               ,'.ｲ.'
                               ,'.ｲ)'
                               ,'.ｴｲ'
                               ,'.ｼﾕ'
                               ,'.ﾌｸ'
                               ,',ｶ,'
                               ,',ｶ)'
                               ,',ﾕｳ'
                               ,',ﾕ,'
                               ,',ﾕ)'
                               ,',ｿ,'
                               ,',ｿ)'
                               ,',ﾒｲ'
                               ,',ﾒ,'
                               ,',ﾒ)'
                               ,',ｼﾔ'
                               ,',ｼ,'
                               ,',ｼ)'
                               ,',ｲ,'
                               ,',ｲ)'
                               ,',ｴｲ'
                               ,',ｴ,'
                               ,',ｴ,'
                               ,',ｼﾕ'
                               ,',ﾌｸ'
                               ,',ﾄﾞ'
                               ,'.ｶ'
                               ,'.ﾕ'
                               ,'.ｿ'
                               ,'.ﾒ'
                               ,'.ｼ'
                               ,'.ｲ'
                               ,',ﾕ'
                               ,',ｿ'
                               ,',ﾒ'
                               ,',ｼ'
                               ,',ｲ'
                               ,',ｴ'
                               ); 
    

  BEGIN

    o_name := i_name;
    FOR i IN LegalPer.first..LegalPer.last LOOP
        o_name := REPLACE(o_name, LegalPer(i),'');
    END LOOP;

  END;

  PROCEDURE chkAllHalfSizeChar(i_charactors IN VARCHAR2, results OUT BOOLEAN)
    is
    
    REF_HALFWIDTHKANA  constant VARCHAR2(500) := 'ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮﾟﾞｰ';
    i_halfKana                  BOOLEAN;
    
  BEGIN
        results := TRUE;
        FOR i IN 1 .. LENGTH(i_charactors) LOOP
            IF LENGTH(SUBSTR(i_charactors, i, 1)) <> LENGTHB(SUBSTR(i_charactors, i, 1)) THEN
                i_halfKana := FALSE;
                FOR j IN 1 .. LENGTH(REF_HALFWIDTHKANA) LOOP
                    IF SUBSTR(i_charactors, i, 1) = SUBSTR(REF_HALFWIDTHKANA, j, 1)  THEN
                       i_halfKana := TRUE;
                       EXIT;
                    END IF;               
                END LOOP;            
                IF i_halfKana = FALSE THEN
                    results := FALSE;
                    EXIT;
                END IF;
            END IF; 
        END LOOP;
  
  END;

  ----CC5
  PROCEDURE getagent(itemexist OUT agntnum_tab)
  
   is
    indexitems PLS_INTEGER;
    TYPE obj_stagef IS RECORD(
      i_clntkey   VARCHAR2(12),
      i_AGNTNUM    VARCHAR2(08));	
    TYPE v_array IS TABLE OF obj_stagef;
    stagelist v_array;
    
    c_delimiter              CONSTANT CHAR(2) := '__';

  BEGIN

    SELECT 
          CLNTKEY
         ,AGNTNUM
    BULK COLLECT
    into stagelist
    FROM
          stagedbusr.titdmgclntcorp@dmstagedblink
    WHERE
         TRIM(AGNTNUM) IS NOT NULL
    ORDER BY clntkey ASC;

    FOR indexitems IN stagelist.first .. stagelist.last LOOP
        itemexist(TRIM(stagelist(indexitems).i_clntkey) || c_delimiter || indexitems) := TRIM(stagelist(indexitems).i_AGNTNUM);
        ---DBMS_OUTPUT.PUT_LINE('[getagenty] : ' ||  TRIM(stagelist(indexitems).i_clntkey) || c_delimiter || indexitems || ']' || TRIM(stagelist(indexitems).i_AGNTNUM));
    
    END LOOP;    

  END;
  ----CC5
END PKG_DM_CORPORATE;
/