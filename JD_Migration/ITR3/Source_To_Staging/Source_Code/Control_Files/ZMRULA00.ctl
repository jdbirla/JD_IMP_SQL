--------------------------------------------------------------------------------------------------------
--DATA MIGRATION SCRIPT FOR SQL LOADER TO LOAD DATA INTO SATGE 1 TABLE FROM CSV FILE
--CODE DEVELOPED BY jdc
--DATE 25 MAY 2020
--VERSION 0.1
--THIS IS THE SQL LOADER CONTROL FILE
--THE FOLLOWING SCRIPT LOADS THE DATA INTO ZMRULA00 TABLE FROM CSV FILE
--------------------------------------------------------------------------------------------------------
LOAD DATA
CHARACTERSET JA16SJIS
REPLACE INTO TABLE ZMRULA00
FIELDS TERMINATED BY ","
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
ULAC6CD,
ULAC7CD, 
ULANWLT,    
ULAB0NB,         
ULABLST,  
ULAYOB1, 
ULAYOB2, 
ULAYOB3, 
ULAYOB4, 
ULAYOB5, 
ULABOCD, 
ULABPCD,
ULAAMDT,  
ULAAATM,      
ULBQCD,
ULABOCDU,
ULABPCDU, 
ULAANDT,        
ULAABTM,         
ULBRCD, 
ULAB6IG
)

