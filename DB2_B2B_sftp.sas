DATA _NULL_; IF NOT (time()>HMS(06,00,00) AND time()<HMS(9,00,00)) THEN CALL EXECUTE ('ENDSAS;'); RUN;


options noxwait;

%LET Act_Date=%sysfunc(Date());
%PUT &Act_Date;
%LET WEEK=%sysfunc(week(%sysfunc(intnx(WEEK,%SYSFUNC(today()),1)),v));
%PUT &week;

/**/ 
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdmdm995130 as select * from connection to baan
   (SELECT 130 			AS Comp,
           a.t_cuno,
           a.t_dset,
		   a.t_dsca,
           a.t_cupn,
		   a.t_dist
FROM ttdmdm995130 a
	);  DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdmdm995300 as select * from connection to baan
   (SELECT 300 			AS Comp,
           a.t_cuno,
           a.t_dset,
		   a.t_dsca,
           a.t_cupn,
		   a.t_dist
FROM ttdmdm995300 a
	);  DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdmdm995400 as select * from connection to baan
   (SELECT 400 			AS Comp,
           a.t_cuno,
           a.t_dset,
		   a.t_dsca,
           a.t_cupn,
		   a.t_dist
FROM ttdmdm995400 a
	);  DISCONNECT from baan;
QUIT;
PROC SQL;
CREATE table work.tdmdm995 as 
    (SELECT a.*
FROM 			work.tdmdm995130 a 
UNION ALL
    SELECT  a.*
FROM 			work.tdmdm995300 a
UNION ALL
    SELECT  a.*
FROM 			work.tdmdm995400 a);
QUIT;
/**/

/**/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.Dimset_Active_Blocked_130 as select * from connection to baan
   (SELECT 130			AS Comp,
           a.t_dset, 
           a.t_dist, 
           b.t_tsls,
		   1			AS Check_Dimset_A_B
FROM ttdmdm995130 a 							LEFT OUTER JOIN ttdmdm012130 b ON a.t_dset=b.t_dset AND b.t_item='ALU' 
WHERE substr(a.t_dset,1,1)='1' AND (a.t_dist<>2 OR b.t_tsls<>1)
	);  DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.Dimset_Active_Blocked_300 as select * from connection to baan
   (SELECT 300			AS Comp,
           a.t_dset, 
           a.t_dist, 
           b.t_tsls,
		   1			AS Check_Dimset_A_B
FROM ttdmdm995300 a 							LEFT OUTER JOIN ttdmdm012300 b ON a.t_dset=b.t_dset AND b.t_item='ALU' 
WHERE substr(a.t_dset,1,1)='2' AND (a.t_dist<>2 OR b.t_tsls<>1)
	);  DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.Dimset_Active_Blocked_400 as select * from connection to baan
   (SELECT 400			AS Comp,
           a.t_dset, 
           a.t_dist, 
           b.t_tsls,
		   1			AS Check_Dimset_A_B
FROM ttdmdm995400 a 							LEFT OUTER JOIN ttdmdm012400 b ON a.t_dset=b.t_dset AND b.t_item='ALU' 
WHERE substr(a.t_dset,1,1)='1' AND (a.t_dist<>2 OR b.t_tsls<>1)
	);  DISCONNECT from baan;
QUIT;
PROC SQL;
CREATE table work.Dimset_Active_Blocked as 
    (SELECT a.*
FROM 			work.Dimset_Active_Blocked_130 a 
UNION ALL
    SELECT  a.*
FROM 			work.Dimset_Active_Blocked_300 a
UNION ALL
    SELECT  a.*
FROM 			work.Dimset_Active_Blocked_400 a);
QUIT;
/**/

/**/
/*t_imth: 1=Discreet; 3=non-discreet*/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdmdm012400 as select * from connection to baan
   (SELECT 400			AS Comp,
           a.t_item,
           a.t_dset, 
           a.t_imth
FROM ttdmdm012400 a  
WHERE a.t_item IN('TOLALU')
	);  DISCONNECT from baan;
QUIT;
/**/

/**/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdprd900130 as select * from connection to baan
   (SELECT "130"			AS Comp,
           a.t_cuno,
		   a.t_fnam
FROM ttdprd900130 a
	); DISCONNECT from baan;
QUIT;
PROC SORT DATA=work.tdprd900130 nodup; BY t_cuno; RUN;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdprd900300 as select * from connection to baan
   (SELECT "300" 			AS Comp,
           a.t_cuno,
		   a.t_fnam
FROM ttdprd900300 a
	); DISCONNECT from baan;
QUIT;
PROC SORT DATA=work.tdprd900300 nodup; BY t_cuno; RUN;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdprd900400 as select * from connection to baan
   (SELECT "400" 			AS Comp,
           a.t_cuno,
		   a.t_fnam
FROM ttdprd900400 a
	); DISCONNECT from baan;
QUIT;
PROC SORT DATA=work.tdprd900400 nodup; BY t_cuno; RUN;

PROC SQL;
CREATE table work.tdprd900 as 
    (SELECT a.*
FROM 			work.tdprd900130 a 
UNION ALL
    SELECT  a.*
FROM 			work.tdprd900300 a
UNION ALL
    SELECT  a.*
FROM 			work.tdprd900400 a);
QUIT;

%macro keep_files (t_cuno, comp);
Filename files pipe "dir ""D:\SAS_SFTP\&comp\&t_cuno\""";
DATA work.Filelist;
FORMAT comp $3.;
FORMAT t_cuno $6.;
   comp="&comp";
   t_cuno="&t_cuno";
 infile files lrecl=300 truncover;  input line $200.;
  IF not index(LOWCASE(line),".txt") THEN DELETE;
   Filename=Strip(Substr(line,40,50));
 keep comp t_cuno line filename;
run;

PROC APPEND BASE=work.Filelist1 DATA=work.Filelist; RUN;

DATA work.Filelist2;
FORMAT t_cuno $6.;
FORMAT comp $3.;
   comp="&comp";
   t_cuno="&t_cuno";
 infile files lrecl=300 truncover;  input line $200.;
  IF not index(LOWCASE(line),".csv") THEN DELETE;
   Filename=Strip(Substr(line,40,50));
 keep comp t_cuno line filename;
run;

PROC APPEND BASE=work.Filelist1 DATA=work.Filelist2; RUN;

DATA work.Filelist3;
FORMAT comp $3.;
FORMAT t_cuno $6.;
   comp="&comp";
   t_cuno="&t_cuno";
 infile files lrecl=300 truncover;  input line $200.;
  IF not index(LOWCASE(line),".xlsx") THEN DELETE;
   Filename=Strip(Substr(line,40,50));
 keep comp t_cuno line filename wknr;
run;

PROC SORT DATA=work.Filelist3; BY descending Filename; RUN;
DATA work.Filelist3; SET work.Filelist3; IF _N_ >1 THEN DELETE; RUN;

PROC APPEND BASE=work.Filelist1 DATA=work.Filelist3; RUN;

DATA work.Filelist4;
FORMAT comp $3.;
FORMAT t_cuno $6.;
   comp="&comp";
   t_cuno="&t_cuno";
 infile files lrecl=300 truncover;  input line $200.;
  IF not index(LOWCASE(line),".xls ") THEN DELETE;
   Filename=Strip(Substr(line,40,50));
 keep comp t_cuno line filename wknr;
run;

PROC SORT DATA=work.Filelist4; BY descending Filename; RUN;
DATA work.Filelist4; SET work.Filelist4; IF _N_ >1 THEN DELETE; RUN;

PROC APPEND BASE=work.Filelist1 DATA=work.Filelist4; RUN;


%Mend keep_files;

DATA Keep_files; SET work.tdprd900;
CALL EXECUTE ('%keep_files('||t_cuno||','||comp||')');
RUN;

PROC SQL;
CREATE TABLE work.Execute AS
SELECT  a.comp,
        a.t_cuno,
        a.t_fnam,
        b.Filename   
FROM  	work.tdprd900 a  LEFT OUTER JOIN work.Filelist1 b ON a.comp=b.comp AND a.t_cuno=b.t_cuno;
QUIT;

DATA work.Execute1;
SET work.Execute;
Yesterday=put(&Act_Date-1, YYMMDDN8.);
Act_Date=put(&Act_Date, YYMMDDN8.);
Act_Date_txt=TRANSLATE(PUT(YEAR(&Act_date),4.0)||"_"||PUT(MONTH(&Act_date),2.0)||"_"||PUT(DAY(&Act_date),2.0),"0"," ");
Act_date_txt2=TRANSLATE(PUT(DAY(&Act_date),2.0)||"."||PUT(MONTH(&Act_date),2.0)||"."||PUT(YEAR(&Act_date),4.0),"0"," ");
IF INDEX(Filename,Act_Date)> 0 OR INDEX(Filename,Act_Date_txt)> 0 OR INDEX(Filename,Act_Date_txt2)> 0 OR (comp="130" AND t_cuno="013330") OR (comp="300" AND t_cuno="068738") OR (comp="300" AND t_cuno="068740") OR (comp="300" AND t_cuno="042970") 
                               OR (comp="400" AND t_cuno="018851") 	THEN DELETE;
IF Comp="130" AND t_cuno="025000" AND INDEX(Filename,Yesterday)> 0	THEN DELETE;
RUN;


/**/
%Macro _013000_1 (Act_Date, comp);
/*013000*/
X del "d:\SAS_SFTP\&comp\013000\*.txt";
X del "D:\SAS_SFTP\&comp\013000\SFTP013000run.bat";
X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\013000\SFTP_013000.bat) -replace 'YYYYMMDD', '&Act_Date' -replace 'COMPANY', '&comp' | Out-File -encoding ASCII D:\SAS_SFTP\&comp\013000\SFTP013000run.bat";
X D:\SAS_SFTP\&comp\013000\SFTP013000run.bat;
%Mend _013000_1;

DATA work.Execute1_1;
SET work.Execute1;
CALL EXECUTE('%_013000_1('||Act_Date||','||comp||')'); WHERE t_cuno="013000";
RUN;

%Macro _016400_1 (Act_Date_txt2, comp);
/*016400/016410 - Gecombineerde file*/
X del "d:\SAS_SFTP\&comp\016400\*.csv";
X del "D:\SAS_SFTP\&comp\016400\SFTP016400run.bat";
X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\016400\SFTP_016400.bat) -replace 'DD.MM.YYYY', '&Act_Date_txt2' -replace 'COMPANY', '&comp' | Out-File -encoding ASCII D:\SAS_SFTP\&comp\016400\SFTP016400run.bat";
X D:\SAS_SFTP\&comp\016400\SFTP016400run.bat;
%Mend _016400_1;

DATA work.Execute1_1;
SET work.Execute1;
CALL EXECUTE('%_016400_1('||Act_Date_txt2||','||comp||')'); WHERE t_cuno="016400";
RUN;

%Macro _023000_1 (Act_Date, comp);
/*023000*/
X del "d:\SAS_SFTP\&comp\023000\*.txt";
X del "D:\SAS_SFTP\&comp\023000\SFTP023000run.bat";
X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\023000\SFTP_023000.bat) -replace 'YYYYMMDD', '&Act_Date' -replace 'COMPANY', '&comp'| Out-File -encoding ASCII D:\SAS_SFTP\&comp\023000\SFTP023000run.bat";
X D:\SAS_SFTP\&comp\023000\SFTP023000run.bat;
%Mend _023000_1;

DATA work.Execute1_1;
SET work.Execute1;
CALL EXECUTE('%_023000_1('||Act_Date||','||comp||')'); WHERE t_cuno="023000";
RUN;

/*%Macro _025000_1 (Act_Date, comp);*/
/*025000*/
/*X del "d:\SAS_SFTP\&comp\025000\*.txt";*/
/*X del "D:\SAS_SFTP\&comp\025000\SFTP025000run.bat";*/
/*X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\025000\SFTP_025000.bat) -replace 'YYYYMMDD', '&Act_Date' -replace 'COMPANY', '&comp'| Out-File -encoding ASCII D:\SAS_SFTP\&comp\025000\SFTP025000run.bat";*/
/*X D:\SAS_SFTP\&comp\025000\SFTP025000run.bat;*/
/*%Mend _025000_1;*/
/**/
/*DATA work.Execute1_1;*/
/*SET work.Execute1;*/
/*CALL EXECUTE('%_025000_1('||Act_Date||','||comp||')'); WHERE t_cuno="025000";*/
/*RUN;*/

%Macro _025000_1 (Yesterday, comp); /*DV 06-02-2024 n.a.v. nieuw update moment*/
/*025000*/
X del "d:\SAS_SFTP\&comp\025000\*.txt";
X del "D:\SAS_SFTP\&comp\025000\SFTP025000run.bat";
X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\025000\SFTP_025000.bat) -replace 'YYYYMMDD', '&Yesterday' -replace 'COMPANY', '&comp'| Out-File -encoding ASCII D:\SAS_SFTP\&comp\025000\SFTP025000run.bat";
X D:\SAS_SFTP\&comp\025000\SFTP025000run.bat;
%Mend _025000_1;

DATA work.Execute1_1;
SET work.Execute1;
CALL EXECUTE('%_025000_1('||Yesterday||','||comp||')'); WHERE t_cuno="025000";
RUN;

%Macro _023200_1 (Act_Date_txt, comp);
/*023200*/
X del "d:\SAS_SFTP\&comp\023200\*.txt";
X del "D:\SAS_SFTP\&comp\023200\SFTP023200run.bat";
X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\023200\SFTP_023200.bat) -replace 'YYYY_MM_DD', '&Act_Date_txt' -replace 'COMPANY', '&comp'| Out-File -encoding ASCII D:\SAS_SFTP\&comp\023200\SFTP023200run.bat";
X D:\SAS_SFTP\&comp\023200\SFTP023200run.bat;
%Mend _023200_1;

DATA work.Execute1_1;
SET work.Execute1;
CALL EXECUTE('%_023200_1('||Act_Date_txt||','||comp||')'); WHERE t_cuno="023200";
RUN;

%Macro _051050_1 (Act_Date, comp);
/*051050*/
X del "d:\SAS_SFTP\&comp\051050\*.CSV";
X del "D:\SAS_SFTP\&comp\051050\SFTP051050run.bat";
X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\051050\SFTP_051050.bat) -replace 'YYYYMMDD', '&Act_Date' -replace 'COMPANY', '&comp' | Out-File -encoding ASCII D:\SAS_SFTP\&comp\051050\SFTP051050run.bat";
X D:\SAS_SFTP\&comp\051050\SFTP051050run.bat;
%Mend _051050_1;

DATA work.Execute1_1;
SET work.Execute1;
CALL EXECUTE('%_051050_1('||Act_Date||','||comp||')'); WHERE t_cuno="051050";
RUN;

%Macro _054500_1 (Act_Date, comp);
/*054500*/
X del "d:\SAS_SFTP\&comp\054500\*.txt";
X del "D:\SAS_SFTP\&comp\054500\SFTP054500run.bat";
X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\054500\SFTP_054500.bat) -replace 'YYYYMMDD', '&Act_Date' -replace 'COMPANY', '&comp' | Out-File -encoding ASCII D:\SAS_SFTP\&comp\054500\SFTP054500run.bat";
X D:\SAS_SFTP\&comp\054500\SFTP054500run.bat;
%Mend _054500_1;

DATA work.Execute1_1;
SET work.Execute1;
CALL EXECUTE('%_054500_1('||Act_Date||','||comp||')'); WHERE t_cuno="054500";
RUN;

%Macro _063460_1 (Act_Date, comp);
/*063460*/
X del "d:\SAS_SFTP\&comp\063460\*.txt";
X del "D:\SAS_SFTP\&comp\063460\SFTP063460run.bat";
X cmd /c powershell -Command "(gc D:\SAS_SFTP\&comp\063460\SFTP_063460.bat) -replace 'YYYYMMDD', '&Act_Date' -replace 'COMPANY', '&comp' | Out-File -encoding ASCII D:\SAS_SFTP\&comp\063460\SFTP063460run.bat";
X D:\SAS_SFTP\&comp\063460\SFTP063460run.bat;
%Mend _063460_1;

DATA work.Execute1_1;
SET work.Execute1;
CALL EXECUTE('%_063460_1('||Act_Date||','||comp||')'); WHERE t_cuno="063460";
RUN;
/**/


%macro keep_files (t_cuno, comp);
Filename files pipe "dir ""D:\SAS_SFTP\&comp\&t_cuno\""";
DATA work.Filelist_1_1;
FORMAT comp $3.;
FORMAT t_cuno $6.;
   comp="&comp";
   t_cuno="&t_cuno";
 infile files lrecl=300 truncover;  input line $200.;
  IF not index(LOWCASE(line),".txt") THEN DELETE;
   Filename=Strip(Substr(line,40,50));
 keep comp t_cuno line filename;
run;

PROC APPEND BASE=work.Filelist_1 DATA=work.Filelist_1_1; RUN;

DATA work.Filelist_1_2;
FORMAT t_cuno $6.;
FORMAT comp $3.;
   comp="&comp";
   t_cuno="&t_cuno";
 infile files lrecl=300 truncover;  input line $200.;
  IF not index(LOWCASE(line),".csv") THEN DELETE;
   Filename=Strip(Substr(line,40,50));
 keep comp t_cuno line filename;
run;

PROC APPEND BASE=work.Filelist_1 DATA=work.Filelist_1_2; RUN;

DATA work.Filelist_1_3;
FORMAT comp $3.;
FORMAT t_cuno $6.;
   comp="&comp";
   t_cuno="&t_cuno";
 infile files lrecl=300 truncover;  input line $200.;
  IF not index(LOWCASE(line),".xlsx") THEN DELETE;
   Filename=Strip(Substr(line,40,50));
 keep comp t_cuno line filename wknr;
run;

PROC SORT DATA=work.Filelist_1_3; BY descending Filename; RUN;
DATA work.Filelist_1_3; SET work.Filelist_1_3; IF _N_ >1 THEN DELETE; RUN;

PROC APPEND BASE=work.Filelist_1 DATA=work.Filelist_1_3; RUN;

DATA work.Filelist_1_4;
FORMAT comp $3.;
FORMAT t_cuno $6.;
   comp="&comp";
   t_cuno="&t_cuno";
 infile files lrecl=300 truncover;  input line $200.;
  IF not index(LOWCASE(line),".xls ") THEN DELETE;
   Filename=Strip(Substr(line,40,50));
 keep comp t_cuno line filename wknr;
run;

PROC SORT DATA=work.Filelist_1_4; BY descending Filename; RUN;
DATA work.Filelist_1_4; SET work.Filelist_1_4; IF _N_ >1 THEN DELETE; RUN;

PROC APPEND BASE=work.Filelist_1 DATA=work.Filelist_1_4; RUN;

%Mend keep_files;

DATA Keep_files; SET work.tdprd900;
CALL EXECUTE ('%keep_files('||t_cuno||','||comp||')');
RUN;

PROC SQL;
CREATE TABLE work.Execute AS
SELECT  a.comp,
        a.t_cuno,
        a.t_fnam,
        b.Filename   
FROM  	work.tdprd900 a  LEFT OUTER JOIN work.Filelist_1 b ON a.comp=b.comp AND a.t_cuno=b.t_cuno;
QUIT;

DATA work.Execute2;
SET work.Execute;
IF t_fnam=Filename OR Filename="" 				THEN DELETE;
RUN;


/***********************/
/**** Get b2b files ****/
/***********************/
/**** 013000 ***********/
%Macro _013000_ (t_cuno, Filename, comp);
filename myfile "D:\SAS_SFTP\&comp\&t_cuno\&filename"; ;
proc import datafile= myfile out=HymerFTP_013000 dbms=dlm replace; getnames=no; delimiter=";"; GUESSINGROWS=MAX; RUN;
DATA HymerFTP_013000; SET HymerFTP_013000; Customer_nr="013000"; Filename="&Filename"; Line=_N_; RUN;

DATA HymerFTP_013000_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET HymerFTP_013000; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var1,8.));
t_dsca=var2;							
FORMAT t_sern $10.; t_sern=PUT(var4,10.);       											IF t_sern=. THEN t_sern="";
t_pord=input(var5,12.2);
FORMAT t_cdd1 DATE9.; t_cdd1=var8; 								     						IF t_cdd1=. THEN t_cdd1=0;
FORMAT t_cdd2 DATE9.; t_cdd2=var10;														  	IF t_cdd2=. THEN t_cdd2=0;
t_oqua=input(TRANSLATE(var11,".",","),12.3); 												IF t_oqua=. THEN t_oqua=0;
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
FORMAT t_odat DATE9.; t_odat=var14;															IF t_odat=. THEN t_odat=0;
t_dela=var15;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
t_cuni=var17;
t_dqui=input(TRANSLATE(var18,".",","),12.3); 												IF t_dqui=. THEN t_dqui=0;
t_bqui=input(TRANSLATE(var19,".",","),12.3); 												IF t_bqui=. THEN t_bqui=0;
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
t_band=input(var23,12.0); 																	IF t_band=. THEN t_band=0; 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC SQL;
CREATE TABLE work.HymerFTP_013000_1 AS
SELECT a.*,
       b.t_dist,
       b.t_dset					AS Dimset_check		LABEL='Dimset_check',
	   COUNT(b.t_dset)			AS COUNT_DIM		LABEL='COUNT_DIM',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B		LABEL='COUNT_A_B',
	   c.check_dimset_a_b
FROM HymerFTP_013000_1 a		LEFT OUTER JOIN tdmdm995 					b ON a.t_citm=b.t_cupn AND b.Comp=&Comp AND b.t_cuno="&t_cuno"
                                LEFT OUTER JOIN work.Dimset_Active_Blocked 	c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

DATA work.HymerFTP_013000_2 (DROP=t_dist COUNT_DIM COUNT_A_B check_dimset_a_b) ;
SET work.HymerFTP_013000_1;
FORMAT Comment $75.;
/*Missing dimset B2B - Retrieved from BaaN*/
IF t_dset="" AND Dimset_check NE "" AND COUNT_DIM=1 								THEN DO; t_dset=Dimset_check; Comment="Missing dimset B2B - Retrieved from BaaN"; 		Check=1; END;
/*Missing dimset in BaaN*/
IF Dimset_check=""																	THEN DO; Comment="No matching dimset found in BaaN based on itemnumber (cust_part_nr)"; Check=2; END;
/*Missing dimset B2B - Also not found in BaaN*/
IF t_dset="" AND Dimset_Check=""													THEN DO; Comment="Missing dimset B2B - Also not found in BaaN"; 						Check=3; END;
/*Dimset B2B not equal to Dimset Euramax*/
IF t_dset NE "" AND Dimset_check NE "" AND t_dset NE Dimset_check AND COUNT_DIM<2	THEN DO; Comment="BaaN-dimset not equals B2B-dimset"; 									Check=4; END;
/*Cust_part_nr occurs in multiple dimsets*/
IF COUNT_DIM>1 AND COUNT_A_B=1														THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN"; 						Check=5; END;
/*Cust_part_nr occurs in multiple dimsets - Active/blocked*/
IF COUNT_DIM > 1 AND COUNT_A_B>1													THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked"; 		Check=6; END;
/*Blocked dimset B2B*/
IF check_dimset_a_b=1																THEN DO; Comment="Blocked dimset used in B2B-file";										Check=7; END;
RUN;

PROC SORT DATA=HymerFTP_013000_2 (DROP=Comment Check Dimset_check) OUT=HymerFTP_013000_1	NODUPKEY; BY t_line; RUN;	

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="013000") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.HymerFTP_013000_1 FORCE; RUN;

DATA work.HymerFTP_013000_Mail (KEEP=Cust_nr Cust_part_nr Order_nr Dimset_B2B Comment Dimset_BaaN);
SET work.HymerFTP_013000_2;
IF Comment="" 								THEN DELETE;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
Dimset_B2B=t_dset;
Dimset_BaaN=Dimset_check;
IF CHECK IN(4)								THEN Order_nr=.;  
RUN;

PROC SQL;
CREATE TABLE work.HymerFTP_013000_Mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset_B2B,  
       a.Dimset_BaaN,
       COUNT(a.Order_nr)		AS Aantal_orders
FROM work.HymerFTP_013000_Mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset_B2B, a.Dimset_BaaN;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM HymerFTP_013000_Mail a;
QUIT;

%macro MailTriggerB2BMissingData013000();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Missing dimsets 013000 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Missing dimsets 013000";
PROC PRINT NOOBS DATA=work.HymerFTP_013000_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData013000()');
RUN;
%Mend _013000_;

DATA work._013000_; 
SET work.Execute2;
CALL EXECUTE('%_013000_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="013000";
RUN;


/**** 016400/016410 ***********/
%Macro _016400_ (t_cuno, Filename, comp);
filename myfile "D:\SAS_SFTP\&comp\&t_cuno\&filename"; ;
proc import datafile= myfile out=CarthagoFTP_016400 dbms=dlm replace; getnames=no; delimiter=";"; GUESSINGROWS=MAX; RUN;
DATA CarthagoFTP_016400; SET CarthagoFTP_016400; Customer_nr="016400"; Filename="&Filename"; Line=_N_; RUN;

DATA CarthagoFTP_016400_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET CarthagoFTP_016400; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var1,8.));
t_dsca=var2;							
FORMAT t_sern $10.; t_sern=PUT(var4,10.);       											IF t_sern=. THEN t_sern="";
t_pord=input(var5,12.2);                                                                    IF t_pord=. THEN t_pord=0;
FORMAT t_cdd1 DATE9.; t_cdd1=var8; 								     						IF t_cdd1=. THEN t_cdd1=0;
FORMAT t_cdd2 DATE9.; t_cdd2=var10;														  	IF t_cdd2=. THEN t_cdd2=0;
t_oqua=input(TRANSLATE(var11,".",","),12.3); 												IF t_oqua=. THEN t_oqua=0;
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
FORMAT t_odat DATE9.; t_odat=var14;															IF t_odat=. THEN t_odat=0;
t_dela=var15;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
t_cuni=var17;
t_dqui=input(TRANSLATE(var18,".",","),12.3); 												IF t_dqui=. THEN t_dqui=0;
t_bqui=input(TRANSLATE(var19,".",","),12.3); 												IF t_bqui=. THEN t_bqui=0;
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
t_band=input(var23,12.0); 																	IF t_band=. THEN t_band=0; 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC SQL;
CREATE TABLE work.CarthagoFTP_016400_1 AS
SELECT a.*,
       b.t_dist,
       b.t_dset					AS Dimset_check		LABEL='Dimset_check',
	   COUNT(b.t_dset)			AS COUNT_DIM		LABEL='COUNT_DIM',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B		LABEL='COUNT_A_B',
	   c.check_dimset_a_b,
	   b.t_cuno					AS Customer_check 	LABEL='Customer_check'
FROM CarthagoFTP_016400_1 a		LEFT OUTER JOIN tdmdm995 					b ON a.t_citm=b.t_cupn AND b.Comp=&Comp AND b.t_cuno="&t_cuno"
                                LEFT OUTER JOIN work.Dimset_Active_Blocked 	c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

PROC SQL;
CREATE TABLE work.CarthagoFTP_016400_1 AS
SELECT a.*,
       b.t_dist,
	   COUNT(b.t_dset)			AS COUNT_DIM2		LABEL='COUNT_DIM2',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B2		LABEL='COUNT_A_B2',
       b.t_cuno					AS Customer_check_2	LABEL='Customer_check_2',
	   b.t_dset					AS Dimset_check_2	LABEL='Dimset_check_2',
	   c.check_dimset_a_b		AS check_dimset_a_b2
FROM work.CarthagoFTP_016400_1 a	LEFT OUTER JOIN work.tdmdm995               b ON a.t_dset=b.t_dset AND a.t_citm=b.t_cupn AND b.Comp=&Comp
                                    LEFT OUTER JOIN work.Dimset_Active_Blocked 	c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

DATA work.CarthagoFTP_016400_1 (DROP=Customer_check Count_dim2 Count_A_B2 Customer_check_2 Dimset_check_2 check_dimset_a_b2);
SET work.CarthagoFTP_016400_1;
IF Customer_check=""	THEN DO; Dimset_check=Dimset_check_2; t_cuno=Customer_check_2; Count_dim=Count_dim2; Count_A_B=Count_A_B2; END;
RUN;

DATA work.CarthagoFTP_016400_2 (DROP=t_dist COUNT_DIM COUNT_A_B check_dimset_a_b) ;
SET work.CarthagoFTP_016400_1;
FORMAT Comment $75.;
/*Missing dimset B2B - Retrieved from BaaN*/
IF t_dset="" AND Dimset_check NE "" AND COUNT_DIM=1 								THEN DO; t_dset=Dimset_check; Comment="Missing dimset B2B - Retrieved from BaaN"; 		Check=1; END;
/*Missing dimset in BaaN*/
IF Dimset_check=""																	THEN DO; Comment="No matching dimset found in BaaN based on itemnumber (cust_part_nr)"; Check=2; END;
/*Missing dimset B2B - Also not found in BaaN*/
IF t_dset="" AND Dimset_Check=""													THEN DO; Comment="Missing dimset B2B - Also not found in BaaN"; 						Check=3; END;
/*Dimset B2B not equal to Dimset Euramax*/
IF t_dset NE "" AND Dimset_check NE "" AND t_dset NE Dimset_check AND COUNT_DIM<2	THEN DO; Comment="BaaN-dimset not equals B2B-dimset"; 									Check=4; END;
/*Cust_part_nr occurs in multiple dimsets*/
IF COUNT_DIM>1 AND COUNT_A_B=1														THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN"; 						Check=5; END;
/*Cust_part_nr occurs in multiple dimsets - Active/blocked*/
IF COUNT_DIM > 1 AND COUNT_A_B>1													THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked"; 		Check=6; END;
/*Blocked dimset B2B*/
IF check_dimset_a_b=1																THEN DO; Comment="Blocked dimset used in B2B-file";										Check=7; END;
RUN;

PROC SORT DATA=CarthagoFTP_016400_2 (DROP=Comment Check Dimset_check) OUT=CarthagoFTP_016400_1	NODUPKEY; BY t_line; RUN;	

DATA work.CarthagoFTP_016400_1_016400;
SET work.CarthagoFTP_016400_1;
WHERE t_cuno="016400";
t_line=_N_;
RUN;
DATA work.CarthagoFTP_016400_1_016410;
SET work.CarthagoFTP_016400_1;
WHERE t_cuno="016410";
t_line=_N_;
RUN;
DATA work.CarthagoFTP_016400_1;
SET work.CarthagoFTP_016400_1_016400;
RUN;

PROC APPEND BASE=work.CarthagoFTP_016400_1 DATA=CarthagoFTP_016400_1_016410; RUN;


PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno IN("016400","016410")) by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.CarthagoFTP_016400_1 FORCE; RUN;

DATA work.CarthagoFTP_016400_Mail (KEEP=Cust_nr Cust_part_nr Order_nr Dimset_B2B Comment Dimset_BaaN);
SET work.CarthagoFTP_016400_2;
IF Comment="" 								THEN DELETE;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
Dimset_B2B=t_dset;
Dimset_BaaN=Dimset_check;
IF CHECK IN(4)								THEN Order_nr=.;  
RUN;

PROC SQL;
CREATE TABLE work.CarthagoFTP_016400_Mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset_B2B,  
       a.Dimset_BaaN,
       COUNT(a.Order_nr)		AS Aantal_orders
FROM work.CarthagoFTP_016400_Mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset_B2B, a.Dimset_BaaN;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM work.CarthagoFTP_016400_Mail a;
QUIT;

%macro MailTriggerB2BMissingData016400();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Missing dimsets 016400/016410 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Missing dimsets 016400/016410";
PROC PRINT NOOBS DATA=work.CarthagoFTP_016400_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData016400()');
RUN;
%Mend _016400_;

DATA work._016400_; 
SET work.Execute2;
CALL EXECUTE('%_016400_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="016400";
RUN;


/**** 023000 ***********/
%Macro _023000_ (t_cuno, Filename, comp);
filename myfile "D:\SAS_SFTP\&comp\&t_cuno\&Filename" ;
PROC IMPORT datafile=myfile out=DethleffsFTP_023000 dbms=dlm replace; getnames=no; delimiter=";"; GUESSINGROWS=MAX; RUN;
DATA DethleffsFTP_023000; SET DethleffsFTP_023000; Customer_nr="023000"; Filename="&Filename"; Line=_N_; RUN;

DATA DethleffsFTP_023000_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET DethleffsFTP_023000; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var29,13.));
t_dsca=var2;							
FORMAT t_sern $10.; t_sern=var4;			       											
t_pord=input(var5,12.2);																	IF t_pord=. THEN t_pord=0;
FORMAT t_cdd1 DATE9.; t_cdd1=MDY(substr(var8,4,2),substr(var8,1,2),substr(var8,7,4));    	IF t_cdd1=. THEN t_cdd1=0;
FORMAT t_cdd2 DATE9.; t_cdd2=var10;														  	IF t_cdd2=. THEN t_cdd2=0;
t_oqua=input(TRANSLATE(var11,".",","),12.3); 												IF t_oqua=. THEN t_oqua=0;
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
t_odat=MDY(substr(var14,4,2),substr(var14,1,2),substr(var14,7,4)); FORMAT t_odat DATE9.; 	IF t_odat=. THEN t_odat=0;
t_dela=var15;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
t_cuni=var17;
t_dqui=input(TRANSLATE(var18,".",","),12.3); 												IF t_dqui=. THEN t_dqui=0;
t_bqui=input(TRANSLATE(var19,".",","),12.3); 												IF t_bqui=. THEN t_bqui=0;
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
t_band=input(var23,12.0); 																	IF t_band=. THEN t_band=0; 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC SQL;
CREATE TABLE work.DethleffsFTP_023000_1 AS
SELECT a.*,
       b.t_dist,
       b.t_dset					AS Dimset_check		LABEL='Dimset_check',
	   COUNT(b.t_dset)			AS COUNT_DIM		LABEL='COUNT_DIM',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B		LABEL='COUNT_A_B',
	   c.check_dimset_a_b
FROM DethleffsFTP_023000_1 a		LEFT OUTER JOIN tdmdm995 					b ON a.t_citm=b.t_cupn AND b.Comp=&Comp AND b.t_cuno="&t_cuno"
                                    LEFT OUTER JOIN work.Dimset_Active_Blocked 	c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

DATA work.DethleffsFTP_023000_2 (DROP=t_dist COUNT_DIM COUNT_A_B check_dimset_a_b) ;
SET work.DethleffsFTP_023000_1;
FORMAT Comment $75.;
/*Missing dimset B2B - Retrieved from BaaN*/
IF t_dset="" AND Dimset_check NE "" AND COUNT_DIM=1 								THEN DO; t_dset=Dimset_check; Comment="Missing dimset B2B - Retrieved from BaaN"; 		Check=1; END;
/*Missing dimset in BaaN*/
IF Dimset_check=""																	THEN DO; Comment="No matching dimset found in BaaN based on itemnumber (cust_part_nr)"; Check=2; END;
/*Missing dimset B2B - Also not found in BaaN*/
IF t_dset="" AND Dimset_Check=""													THEN DO; Comment="Missing dimset B2B - Also not found in BaaN"; 						Check=3; END;
/*Dimset B2B not equal to Dimset Euramax*/
IF t_dset NE "" AND Dimset_check NE "" AND t_dset NE Dimset_check AND COUNT_DIM<2	THEN DO; Comment="BaaN-dimset not equals B2B-dimset"; 									Check=4; END;
/*Cust_part_nr occurs in multiple dimsets*/
IF COUNT_DIM>1 AND COUNT_A_B=1														THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN"; 						Check=5; END;
/*Cust_part_nr occurs in multiple dimsets - Active/blocked*/
IF COUNT_DIM > 1 AND COUNT_A_B>1													THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked"; 		Check=6; END;
/*Blocked dimset B2B*/
IF check_dimset_a_b=1																THEN DO; Comment="Blocked dimset used in B2B-file";										Check=7; END;
RUN;

PROC SORT DATA=DethleffsFTP_023000_2 (DROP=Comment Check Dimset_check) OUT=DethleffsFTP_023000_1	NODUPKEY; BY t_line; RUN;	

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="023000") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.DethleffsFTP_023000_1 FORCE; RUN;

DATA work.DethleffsFTP_023000_Mail (KEEP=Cust_nr Cust_part_nr Order_nr Dimset_B2B Comment Dimset_BaaN);
SET work.DethleffsFTP_023000_2;
IF Comment="" 								THEN DELETE;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
Dimset_B2B=t_dset;
Dimset_BaaN=Dimset_check;
IF CHECK IN(4)								THEN Order_nr=.;  
RUN;

PROC SQL;
CREATE TABLE work.DethleffsFTP_023000_Mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset_B2B,  
       a.Dimset_BaaN,
       COUNT(a.Order_nr)		AS Aantal_orders
FROM work.DethleffsFTP_023000_Mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset_B2B, a.Dimset_BaaN;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM DethleffsFTP_023000_Mail a;
QUIT;

%macro MailTriggerB2BMissingData023000();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Missing dimsets 023000 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Missing dimsets 023000";
PROC PRINT NOOBS DATA=work.DethleffsFTP_023000_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData023000()');
RUN;
%Mend _023000_;

DATA work._023000_; 
SET work.Execute2;
CALL EXECUTE('%_023000_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="023000";
RUN;


/**** 023200 - NEW2 ***********/
/*DV: 20250519 in overleg met Andr� Jungbauer terug naar oude concept middels B2B-file en zonder productieplanning voor de forecast.*/
%Macro _023200_ (t_cuno, Filename, comp);
filename myfile "D:\SAS_SFTP\&comp\&t_cuno\&filename" ;
PROC IMPORT datafile= myfile out=work.CapronFTP_023200 dbms=dlm replace; getnames=no; delimiter=";"; GUESSINGROWS=MAX; RUN;
DATA work.CapronFTP_023200; SET work.CapronFTP_023200; Customer_nr="023200"; Filename="&Filename"; Line=_N_; RUN;

DATA CapronFTP_023200_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET CapronFTP_023200; 
t_cuno=Customer_nr;
FORMAT t_fnam $50.;  t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var1,8.));
t_dsca=var2;							
FORMAT t_sern $10.; t_sern=PUT(var4,10.);       											IF t_sern=. THEN t_sern="";
t_pord=input(var5,12.2);
FORMAT t_cdd1 DATE9.; t_cdd1=var8; 								     						IF t_cdd1=. THEN t_cdd1=0;
FORMAT t_cdd2 DATE9.; t_cdd2=var10;														  	IF t_cdd2=. THEN t_cdd2=0;
t_oqua=input(TRANSLATE(var11,".",","),12.3); 												IF t_oqua=. THEN t_oqua=0;
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
FORMAT t_odat DATE9.; t_odat=var14;															IF t_odat=. THEN t_odat=0;
t_dela=var15;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
FORMAT t_cuni $2.; t_cuni=var17;
t_dqui=input(TRANSLATE(var18,".",","),12.3); 												IF t_dqui=. THEN t_dqui=0;
t_bqui=input(TRANSLATE(var19,".",","),12.3); 												IF t_bqui=. THEN t_bqui=0;
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
t_band=input(var23,12.0); 																	IF t_band=. THEN t_band=0; 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
IF STRIP(t_dset)="104766" THEN t_dset="1044766";
RUN;

PROC SQL;
CREATE TABLE work.CapronFTP_023200_1 AS
SELECT a.*,
       b.t_dist,
       b.t_dset					AS Dimset_check		LABEL='Dimset_check',
	   COUNT(b.t_dset)			AS COUNT_DIM		LABEL='COUNT_DIM',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B		LABEL='COUNT_A_B',
	   c.check_dimset_a_b
FROM work.CapronFTP_023200_1 a		LEFT OUTER JOIN tdmdm995 					b ON a.t_citm=b.t_cupn AND b.Comp=&Comp AND b.t_cuno="&t_cuno"
                                	LEFT OUTER JOIN work.Dimset_Active_Blocked 	c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

DATA work.CapronFTP_023200_2 (DROP=t_dist COUNT_DIM COUNT_A_B check_dimset_a_b) ;
SET work.CapronFTP_023200_1;
FORMAT Comment $75.;
/*Missing dimset B2B - Retrieved from BaaN*/
IF t_dset="" AND Dimset_check NE "" AND COUNT_DIM=1 								THEN DO; t_dset=Dimset_check; Comment="Missing dimset B2B - Retrieved from BaaN"; 		Check=1; END;
/*Missing dimset in BaaN*/
IF Dimset_check=""																	THEN DO; Comment="No matching dimset found in BaaN based on itemnumber (cust_part_nr)"; Check=2; END;
/*Missing dimset B2B - Also not found in BaaN*/
IF t_dset="" AND Dimset_Check=""													THEN DO; Comment="Missing dimset B2B - Also not found in BaaN"; 						Check=3; END;
/*Dimset B2B not equal to Dimset Euramax*/
IF t_dset NE "" AND Dimset_check NE "" AND t_dset NE Dimset_check AND COUNT_DIM<2	THEN DO; Comment="BaaN-dimset not equals B2B-dimset"; 									Check=4; END;
/*Cust_part_nr occurs in multiple dimsets*/
IF COUNT_DIM>1 AND COUNT_A_B=1														THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN"; 						Check=5; END;
/*Cust_part_nr occurs in multiple dimsets - Active/blocked*/
IF COUNT_DIM > 1 AND COUNT_A_B>1													THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked"; 		Check=6; END;
/*Blocked dimset B2B*/
IF check_dimset_a_b=1																THEN DO; Comment="Blocked dimset used in B2B-file";										Check=7; END;
RUN;

PROC SORT DATA=work.CapronFTP_023200_2 (DROP=Comment Check Dimset_check) OUT=work.CapronFTP_023200_1	NODUPKEY; BY t_line; RUN;	

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="023200") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.CapronFTP_023200_1 FORCE;    RUN;


/*Mail check - B2B*/
DATA work.CapronFTP_023200_Mail (KEEP=Cust_nr Cust_part_nr Order_nr Dimset_B2B Comment Dimset_BaaN);
SET work.CapronFTP_023200_2;
IF Comment="" 								THEN DELETE;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
Dimset_B2B=t_dset;
Dimset_BaaN=Dimset_check;
IF CHECK IN(4)								THEN Order_nr=.;  
RUN;

PROC SQL;
CREATE TABLE work.CapronFTP_023200_Mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset_B2B,  
       a.Dimset_BaaN,
       COUNT(a.Order_nr)		AS Aantal_orders
FROM work.CapronFTP_023200_Mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset_B2B, a.Dimset_BaaN;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM CapronFTP_023200_Mail a;
QUIT;

%macro MailTriggerB2B();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Missing dimsets 023200 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Missing dimsets 023200";
PROC PRINT NOOBS DATA=work.CapronFTP_023200_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2B()');
RUN;
%Mend _023200_;

DATA work._023200_; 
SET work.Execute2;
CALL EXECUTE('%_023200_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="023200";
RUN;


/**** 025000 ***********/
%Macro _025000_ (t_cuno, Filename, comp);
filename myfile "D:\SAS_SFTP\&comp\&t_cuno\&filename" ;
proc import datafile= myfile out=Hymer_025000 dbms=dlm replace; getnames=no; delimiter=";"; GUESSINGROWS=MAX; RUN;
DATA Hymer_025000; 
SET Hymer_025000; 
Customer_nr="025000"; 
Filename="&Filename"; 
Line=_N_; 
IF var15="Hymer Holzstra�e 19"	THEN var15="Hymer Holzstr. 19 Tor 33c";	
RUN;

DATA Hymer_025000_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET Hymer_025000; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var1,8.));
t_dsca=var2;							
FORMAT t_sern $10.; t_sern=PUT(var4,10.);       											IF t_sern=. THEN t_sern="";
t_pord=input(var5,12.2);																	IF t_pord=. THEN t_pord=0;
FORMAT t_cdd1 DATE9.; t_cdd1=var8; 								     						IF t_cdd1=. THEN t_cdd1=0;
FORMAT t_cdd2 DATE9.; t_cdd2=var10;														  	IF t_cdd2=. THEN t_cdd2=0;
t_oqua=input(TRANSLATE(var11,".",","),12.3); 												IF t_oqua=. THEN t_oqua=0;
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
FORMAT t_odat DATE9.; t_odat=var14;															IF t_odat=. THEN t_odat=0;
t_dela=var15;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
t_cuni=var17;
t_dqui=input(TRANSLATE(var18,".",","),12.3); 												IF t_dqui=. THEN t_dqui=0;
t_bqui=input(TRANSLATE(var19,".",","),12.3); 												IF t_bqui=. THEN t_bqui=0;
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
t_band=input(var23,12.0); 																	IF t_band=. THEN t_band=0; 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC SQL;
CREATE TABLE work.Hymer_025000_1 AS
SELECT a.*,
       b.t_dist,
       b.t_dset					AS Dimset_check		LABEL='Dimset_check',
	   COUNT(b.t_dset)			AS COUNT_DIM		LABEL='COUNT_DIM',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B		LABEL='COUNT_A_B',
	   c.check_dimset_a_b
FROM Hymer_025000_1 a		LEFT OUTER JOIN tdmdm995 				   b ON a.t_citm=b.t_cupn AND b.Comp=&Comp AND b.t_cuno="&t_cuno"
                            LEFT OUTER JOIN work.Dimset_Active_Blocked c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

DATA work.Hymer_025000_2 (DROP=t_dist COUNT_DIM COUNT_A_B check_dimset_a_b) ;
SET work.Hymer_025000_1;
FORMAT Comment $75.;
/*Missing dimset B2B - Retrieved from BaaN*/
IF t_dset="" AND Dimset_check NE "" AND COUNT_DIM=1 								THEN DO; t_dset=Dimset_check; Comment="Missing dimset B2B - Retrieved from BaaN"; 		Check=1; END;
/*Missing dimset in BaaN*/
IF Dimset_check=""																	THEN DO; Comment="No matching dimset found in BaaN based on itemnumber (cust_part_nr)"; Check=2; END;
/*Missing dimset B2B - Also not found in BaaN*/
IF t_dset="" AND Dimset_Check=""													THEN DO; Comment="Missing dimset B2B - Also not found in BaaN"; 						Check=3; END;
/*Dimset B2B not equal to Dimset Euramax*/
IF t_dset NE "" AND Dimset_check NE "" AND t_dset NE Dimset_check AND COUNT_DIM<2	THEN DO; Comment="BaaN-dimset not equals B2B-dimset"; 									Check=4; END;
/*Cust_part_nr occurs in multiple dimsets*/
IF COUNT_DIM>1 AND COUNT_A_B=1														THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN"; 						Check=5; END;
/*Cust_part_nr occurs in multiple dimsets - Active/blocked*/
IF COUNT_DIM > 1 AND COUNT_A_B>1													THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked"; 		Check=6; END;
/*Blocked dimset B2B*/
IF check_dimset_a_b=1																THEN DO; Comment="Blocked dimset used in B2B-file";										Check=7; END;
RUN;

PROC SORT DATA=Hymer_025000_2 (DROP=Comment Check Dimset_check) OUT=Hymer_025000_1	NODUPKEY; BY t_line; RUN;	

/**/
/*Update tdprd900*/
PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="025000") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.Hymer_025000_1 FORCE;    RUN;
/**/

/**/
/*Dimset issues*/
DATA work.Hymer_025000_Mail (KEEP=Cust_nr Cust_part_nr Order_nr Dimset_B2B Comment Dimset_BaaN);
SET work.Hymer_025000_2;
IF Comment="" 								THEN DELETE;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
Dimset_B2B=t_dset;
Dimset_BaaN=Dimset_check;
IF CHECK IN(4)								THEN Order_nr=.;  
RUN;

PROC SQL;
CREATE TABLE work.Hymer_025000_Mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset_B2B,  
       a.Dimset_BaaN,
       COUNT(a.Order_nr)		AS Aantal_orders
FROM work.Hymer_025000_Mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset_B2B, a.Dimset_BaaN;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM Hymer_025000_Mail a;
QUIT;

%macro MailTriggerB2BMissingData025000();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Missing dimsets 025000 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Missing dimsets 025000";
PROC PRINT NOOBS DATA=work.Hymer_025000_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData025000()');
RUN;
/**/


/**/
/*Sheet - not correct orderunit*/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdprd900130025000 as select * from connection to baan
   (SELECT &comp 			AS Comp,
           a.t_citm,
		   a.t_ponc,
           a.t_cuno,
           a.t_dset,
		   a.t_oqua,
		   a.t_oqui,
		   a.t_cuni,
		   b.t_imth,
		   "Sheet dimset; Ordereenheid ongelijk aan St�, stk, ST"	AS Commentaar
FROM ttdprd900&comp a				LEFT OUTER JOIN ttdmdm012&comp b ON a.t_dset=b.t_dset
WHERE a.t_cuno=&t_cuno AND b.t_imth=1 AND a.t_cuni NOT IN("ST","St�","stk")
	);  DISCONNECT from baan;
QUIT;

DATA work.tdprd900130025000 (DROP=comp t_citm t_ponc t_cuno t_dset t_oqua t_oqui t_cuni t_imth commentaar);
SET work.tdprd900130025000;
Company=comp;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
FORMAT Orderhoeveelheid 12.3;
FORMAT B2B_Forecast $8.;
IF Order_nr>0		THEN DO; Orderhoeveelheid=t_oqui; B2B_Forecast="B2B"		; END;
IF Order_nr=0		THEN DO; Orderhoeveelheid=t_oqua; B2B_Forecast="Forecast"	; END;
Order_eenheid=t_cuni;
Comment=Commentaar;
RUN;

PROC SQL;
CREATE TABLE work.Mail_check_OrderUnit AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM work.tdprd900130025000 a;
QUIT;
/**/

%macro MailTriggerB2BOrderunit025000();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Sheet - Not correct order unit - 025000 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Sheet - Not correct order unit - 025000";
PROC PRINT NOOBS DATA=work.tdprd900130025000;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check_OrderUnit;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BOrderunit025000()');
RUN;

/*Prijsverschillen*/
DATA Hymer_025000_2 (keep=t_cuno t_line t_citm t_ponc t_popc t_oqui t_cuni t_dset tot_price);
SET Hymer_025000; 
t_cuno=Customer_nr;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var1,8.));
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
t_cuni=var17;
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
tot_price=var33;
WHERE var33 NE .;
RUN;
PROC SORT DATA=Hymer_025000_2; BY t_line; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdprd202130 as select * from connection to baan
   (SELECT a.*
FROM ttdprd202130 a
WHERE a.t_cuno="025000"
	);  DISCONNECT from baan;
QUIT;

PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdsls041130 as select * from connection to baan
   (SELECT a.*
FROM ttdsls041130 a
WHERE a.t_cuno="025000"
	);  DISCONNECT from baan;
QUIT;

PROC SQL;
CREATE TABLE work.Hymer AS
SELECT a.t_line,
       a.t_cuno,
       a.t_citm,
	   a.t_ponc,
	   a.t_popc,
	   b.t_oqui,
	   a.t_cuni,
	   a.t_dset,
       b.t_slso,
	   b.t_slsp,
       c.t_oqua     AS Ord_quan			LABEL='Ord_quan',
	   c.t_cuqs     AS Ord_unit			LABEL='Ord_unit',
	   c.t_quau_c   AS Ord_quan_alt		LABEL='Ord_quan_alt',
	   c.t_acun_c   AS Ord_unit_alt		LABEL='Ord_unit_alt',
	   c.t_pric,
	   a.tot_price 	AS B2BPrice			LABEL='B2BPrice',
	   c.t_amta		AS BaaNPrice		LABEL='BaaNPrice'
FROM work.Hymer_025000_2 a			LEFT OUTER JOIN work.tdprd202130 b ON a.t_cuno=b.t_cuno AND a.t_citm=b.t_citm AND a.t_popc=b.t_popc*10  AND a.t_ponc=INPUT(b.t_refa,10.)
                                    LEFT OUTER JOIN work.tdsls041130 c ON b.t_slso=c.t_orno AND b.t_slsp=c.t_pono
WHERE a.tot_price NE c.t_amta
ORDER BY a.t_line;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check_2 AS
SELECT COUNT(a.t_cuno) AS COUNT
FROM work.Hymer a;
QUIT;

%macro MailTriggerB2BPriceDiff025000();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="mblanckers@euramax.eu""jfeyen@euramax.eu"  /*CC="dverbert@euramax.eu"*/
SUBJECT="**** B2B - PriceDifferences 025000 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - PriceDifferences 025000";
PROC PRINT NOOBS DATA=work.Hymer;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_3; SET work.Mail_check_2;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BPriceDiff025000()');
RUN;

%Mend _025000_;

DATA work._025000_; 
SET work.Execute2;
CALL EXECUTE('%_025000_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="025000";
RUN;


/**** 051050 ***********/
%Macro _051050_ (t_cuno, Filename, comp);
filename myfile "D:\SAS_SFTP\&comp\&t_cuno\&filename" ;
proc import datafile= myfile out=Knaus_051050 dbms=dlm replace; getnames=no; delimiter=";"; GUESSINGROWS=MAX; RUN;
DATA Knaus_051050; SET Knaus_051050; Customer_nr="051050"; Filename="&Filename"; Line=_N_; RUN;

DATA Knaus_051050_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET Knaus_051050; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var1,12.));
t_dsca=var2;							
FORMAT t_sern $10.; t_sern=PUT(var4,10.);       											IF t_sern=. THEN t_sern="";
t_pord=input(var5,12.2);																	IF t_pord=. THEN t_pord=0;
FORMAT t_cdd1 DATE9.; t_cdd1=var8; 								     						IF t_cdd1=. THEN t_cdd1=0;
FORMAT t_cdd2 DATE9.; t_cdd2=var10;														  	IF t_cdd2=. THEN t_cdd2=0;
t_oqua=input(TRANSLATE(var11,".",","),12.3); 												IF t_oqua=. THEN t_oqua=0;
/*t_oqua=var11; 												IF t_oqua=. THEN t_oqua=0;*/
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
FORMAT t_odat DATE9.; t_odat=var14;															IF t_odat=. THEN t_odat=0;
t_dela=var15;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
/*t_oqui=var16; 												IF t_oqui=. THEN t_oqui=0;*/
t_cuni=var17;
t_dqui=input(TRANSLATE(var18,".",","),12.3); 												IF t_dqui=. THEN t_dqui=0;
/*t_dqui=var18; 												IF t_dqui=. THEN t_dqui=0;*/
t_bqui=input(TRANSLATE(var19,".",","),12.3); 												IF t_bqui=. THEN t_bqui=0;
/*t_bqui=var19; 												IF t_bqui=. THEN t_bqui=0;*/
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
t_band=input(var23,12.0); 																	IF t_band=. THEN t_band=0; 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC SQL;
CREATE TABLE work.Knaus_051050_1 AS
SELECT a.*,
       b.t_dist,
       b.t_dset					AS Dimset_check		LABEL='Dimset_check',
	   COUNT(b.t_dset)			AS COUNT_DIM		LABEL='COUNT_DIM',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B		LABEL='COUNT_A_B',
	   c.check_dimset_a_b
FROM Knaus_051050_1 a		LEFT OUTER JOIN tdmdm995 					b ON a.t_citm=b.t_cupn AND b.Comp=&Comp AND b.t_cuno="&t_cuno"
                            LEFT OUTER JOIN work.Dimset_Active_Blocked 	c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

DATA work.Knaus_051050_2 (DROP=t_dist COUNT_DIM COUNT_A_B check_dimset_a_b) ;
SET work.Knaus_051050_1;
FORMAT Comment $75.;
/*Missing dimset B2B - Retrieved from BaaN*/
IF t_dset="" AND Dimset_check NE "" AND COUNT_DIM=1 								THEN DO; t_dset=Dimset_check; Comment="Missing dimset B2B - Retrieved from BaaN"; 		Check=1; END;
/*Missing dimset in BaaN*/
IF Dimset_check=""																	THEN DO; Comment="No matching dimset found in BaaN based on itemnumber (cust_part_nr)"; Check=2; END;
/*Missing dimset B2B - Also not found in BaaN*/
IF t_dset="" AND Dimset_Check=""													THEN DO; Comment="Missing dimset B2B - Also not found in BaaN"; 						Check=3; END;
/*Dimset B2B not equal to Dimset Euramax*/
IF t_dset NE "" AND Dimset_check NE "" AND t_dset NE Dimset_check AND COUNT_DIM<2	THEN DO; Comment="BaaN-dimset not equals B2B-dimset"; 									Check=4; END;
/*Cust_part_nr occurs in multiple dimsets*/
IF COUNT_DIM>1 AND COUNT_A_B=1														THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN"; 						Check=5; END;
/*Cust_part_nr occurs in multiple dimsets - Active/blocked*/
IF COUNT_DIM > 1 AND COUNT_A_B>1													THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked"; 		Check=6; END;
/*Blocked dimset B2B*/
IF check_dimset_a_b=1																THEN DO; Comment="Blocked dimset used in B2B-file";										Check=7; END;
RUN;

PROC SORT DATA=Knaus_051050_2 (DROP=Comment Check Dimset_check) OUT=Knaus_051050_1	NODUPKEY; BY t_line; RUN;	

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="051050") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.Knaus_051050_1 FORCE; RUN;

DATA work.Knaus_051050_Mail (KEEP=Cust_nr Cust_part_nr Order_nr Dimset_B2B Comment Dimset_BaaN);
SET work.Knaus_051050_2;
IF Comment="" 								THEN DELETE;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
Dimset_B2B=t_dset;
Dimset_BaaN=Dimset_check;
IF CHECK IN(4)								THEN Order_nr=.;  
RUN;

PROC SQL;
CREATE TABLE work.Knaus_051050_Mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset_B2B,  
       a.Dimset_BaaN,
       COUNT(a.Order_nr)		AS Aantal_orders
FROM work.Knaus_051050_Mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset_B2B, a.Dimset_BaaN;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM Knaus_051050_Mail a;
QUIT;

%macro MailTriggerB2BMissingData051050();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Missing dimsets 051050 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Missing dimsets 051050";
PROC PRINT NOOBS DATA=work.Knaus_051050_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData051050()');
RUN;
%Mend _051050_;

DATA work._051050_; 
SET work.Execute2;
CALL EXECUTE('%_051050_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="051050";
RUN;


/**** 054500 ***********/
%Macro _054500_ (t_cuno, Filename, comp);
filename myfile "D:\SAS_SFTP\&comp\&t_cuno\&filename" ;
proc import datafile= myfile out=work.LMC_054500 dbms=dlm replace; getnames=no; delimiter=";"; GUESSINGROWS=MAX; RUN;
DATA work.LMC_054500; SET work.LMC_054500; Customer_nr="054500"; Filename="&Filename"; Line=_N_; RUN;

DATA work.LMC_054500_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET work.LMC_054500; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var1,8.));
t_dsca=var2;							
FORMAT t_sern $10.; t_sern=var4;       											
t_pord=input(var5,12.2);																	IF t_pord=. THEN t_pord=0;
FORMAT t_cdd1 DATE9.; t_cdd1=MDY(substr(var8,4,2),substr(var8,1,2),substr(var8,7,4));    	IF t_cdd1=. THEN t_cdd1=0; 
FORMAT t_cdd2 DATE9.; t_cdd2=var10;														  	IF t_cdd2=. THEN t_cdd2=0;
t_oqua=input(TRANSLATE(var11,".",","),12.3); 												IF t_oqua=. THEN t_oqua=0;
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
FORMAT t_odat DATE9.; t_odat=MDY(substr(var14,4,2),substr(var14,1,2),substr(var14,7,4));    IF t_odat=. THEN t_odat=0;
t_dela=var15;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
t_cuni=var17;
t_dqui=input(TRANSLATE(var18,".",","),12.3); 												IF t_dqui=. THEN t_dqui=0;
t_bqui=input(TRANSLATE(var19,".",","),12.3); 												IF t_bqui=. THEN t_bqui=0;
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
t_band=input(var23,12.0); 																	IF t_band=. THEN t_band=0; 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC SQL;
CREATE TABLE work.LMC_054500_1 AS
SELECT a.*,
       b.t_dist,
       b.t_dset					AS Dimset_check		LABEL='Dimset_check',
	   COUNT(b.t_dset)			AS COUNT_DIM		LABEL='COUNT_DIM',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B		LABEL='COUNT_A_B',
	   c.check_dimset_a_b
FROM LMC_054500_1 a		LEFT OUTER JOIN tdmdm995 					b ON a.t_citm=b.t_cupn AND b.Comp=&Comp AND b.t_cuno="&t_cuno"
                        LEFT OUTER JOIN work.Dimset_Active_Blocked 	c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

DATA work.LMC_054500_2 (DROP=t_dist COUNT_DIM COUNT_A_B check_dimset_a_b) ;
SET work.LMC_054500_1;
FORMAT Comment $75.;
/*Missing dimset B2B - Retrieved from BaaN*/
IF t_dset="" AND Dimset_check NE "" AND COUNT_DIM=1 								THEN DO; t_dset=Dimset_check; Comment="Missing dimset B2B - Retrieved from BaaN"; 		Check=1; END;
/*Missing dimset in BaaN*/
IF Dimset_check=""																	THEN DO; Comment="No matching dimset found in BaaN based on itemnumber (cust_part_nr)"; Check=2; END;
/*Missing dimset B2B - Also not found in BaaN*/
IF t_dset="" AND Dimset_Check=""													THEN DO; Comment="Missing dimset B2B - Also not found in BaaN"; 						Check=3; END;
/*Dimset B2B not equal to Dimset Euramax*/
IF t_dset NE "" AND Dimset_check NE "" AND t_dset NE Dimset_check AND COUNT_DIM<2	THEN DO; Comment="BaaN-dimset not equals B2B-dimset"; 									Check=4; END;
/*Cust_part_nr occurs in multiple dimsets*/
IF COUNT_DIM>1 AND COUNT_A_B=1														THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN"; 						Check=5; END;
/*Cust_part_nr occurs in multiple dimsets - Active/blocked*/
IF COUNT_DIM > 1 AND COUNT_A_B>1													THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked"; 		Check=6; END;
/*Blocked dimset B2B*/
IF check_dimset_a_b=1																THEN DO; Comment="Blocked dimset used in B2B-file";										Check=7; END;
RUN;

PROC SORT DATA=LMC_054500_2 (DROP=Comment Check Dimset_check) OUT=LMC_054500_1	NODUPKEY; BY t_line; RUN;	

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="054500") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.LMC_054500_1 FORCE; RUN;

DATA work.LMC_054500_Mail (KEEP=Cust_nr Cust_part_nr Order_nr Dimset_B2B Comment Dimset_BaaN);
SET work.LMC_054500_2;
IF Comment="" 								THEN DELETE;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
Dimset_B2B=t_dset;
Dimset_BaaN=Dimset_check;
IF CHECK IN(4)								THEN Order_nr=.;  
RUN;

PROC SQL;
CREATE TABLE work.LMC_054500_Mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset_B2B,  
       a.Dimset_BaaN,
       COUNT(a.Order_nr)		AS Aantal_orders
FROM work.LMC_054500_Mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset_B2B, a.Dimset_BaaN;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM LMC_054500_Mail a;
QUIT;

%macro MailTriggerB2BMissingData054500();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Missing dimsets 054500 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Missing dimsets 054500";
PROC PRINT NOOBS DATA=work.LMC_054500_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData054500()');
RUN;

/**/
/*Sheet - not correct orderunit*/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdprd900130054500 as select * from connection to baan
   (SELECT &comp 			AS Comp,
           a.t_citm,
		   a.t_ponc,
           a.t_cuno,
           a.t_dset,
		   a.t_oqua,
		   a.t_oqui,
		   a.t_cuni,
		   b.t_imth,
		   "Sheet dimset; Ordereenheid ongelijk aan St�, stk, ST"	AS Commentaar
FROM ttdprd900&comp a				LEFT OUTER JOIN ttdmdm012&comp b ON a.t_dset=b.t_dset
WHERE a.t_cuno=&t_cuno AND b.t_imth=1 AND a.t_cuni NOT IN("ST","St�","stk")
	);  DISCONNECT from baan;
QUIT;

DATA work.tdprd900130054500 (DROP=comp t_citm t_ponc t_cuno t_dset t_oqua t_oqui t_cuni t_imth commentaar);
SET work.tdprd900130054500;
Company=comp;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
FORMAT Orderhoeveelheid 12.3;
FORMAT B2B_Forecast $8.;
IF Order_nr>0		THEN DO; Orderhoeveelheid=t_oqui; B2B_Forecast="B2B"		; END;
IF Order_nr=0		THEN DO; Orderhoeveelheid=t_oqua; B2B_Forecast="Forecast"	; END;
Order_eenheid=t_cuni;
Comment=Commentaar;
RUN;

PROC SQL;
CREATE TABLE work.Mail_check_OrderUnit AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM work.tdprd900130054500 a;
QUIT;
/**/

%macro MailTriggerB2BOrderunit054500();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Sheet - Not correct order unit - 054500 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Sheet - Not correct order unit - 054500";
PROC PRINT NOOBS DATA=work.tdprd900130054500;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check_OrderUnit;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BOrderunit054500()');
RUN;

%Mend _054500_;

DATA work._054500_; 
SET work.Execute2;
CALL EXECUTE('%_054500_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="054500";
RUN;


/**** 063460 ***********/
%Macro _063460_ (t_cuno, Filename, comp);
filename myfile "D:\SAS_SFTP\&comp\&t_cuno\&filename"; ;
proc import datafile= myfile out=work.NiBiFTP_063460 dbms=dlm replace; getnames=no; delimiter=";"; GUESSINGROWS=MAX; RUN;
DATA work.NiBiFTP_063460; SET work.NiBiFTP_063460; Customer_nr="063460"; Filename="&Filename"; Line=_N_; RUN;

DATA work.NiBiFTP_063460_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET work.NiBiFTP_063460; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=STRIP(PUT(var1,8.));
t_dsca=var2;							
FORMAT t_sern $10.; t_sern=PUT(var4,10.);       											IF t_sern=. THEN t_sern="";
t_pord=input(var5,12.2);                                                                    IF t_pord=. THEN t_pord=0;
FORMAT t_cdd1 DATE9.; t_cdd1=var8; 								     						IF t_cdd1=. THEN t_cdd1=0;
FORMAT t_cdd2 DATE9.; t_cdd2=var10;														  	IF t_cdd2=. THEN t_cdd2=0;
t_oqua=input(TRANSLATE(var11,".",","),12.3); 												IF t_oqua=. THEN t_oqua=0;
t_ponc=input(var12,12.0);  																	IF t_ponc=. THEN t_ponc=0;
t_popc=input(var13,12.0); 																	IF t_popc=. THEN t_popc=0;
FORMAT t_odat DATE9.; t_odat=var14;															IF t_odat=. THEN t_odat=0;
t_dela=var15;
t_oqui=input(TRANSLATE(var16,".",","),12.3); 												IF t_oqui=. THEN t_oqui=0;
t_cuni=var17;
t_dqui=input(TRANSLATE(var18,".",","),12.3); 												IF t_dqui=. THEN t_dqui=0;
t_bqui=input(TRANSLATE(var19,".",","),12.3); 												IF t_bqui=. THEN t_bqui=0;
FORMAT t_dset $11.; t_dset=PUT(var21,7.);													IF t_dset=. THEN t_dset="";
t_band=input(var23,12.0); 																	IF t_band=. THEN t_band=0; 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC SQL;
CREATE TABLE work.NiBiFTP_063460_1 AS
SELECT a.*,
       b.t_dist,
       b.t_dset					AS Dimset_check		LABEL='Dimset_check',
	   COUNT(b.t_dset)			AS COUNT_DIM		LABEL='COUNT_DIM',
	   COUNT(DISTINCT b.t_dist)	AS COUNT_A_B		LABEL='COUNT_A_B',
	   c.check_dimset_a_b
FROM work.NiBiFTP_063460_1 a		LEFT OUTER JOIN tdmdm995 					b ON a.t_citm=b.t_cupn AND b.Comp=&Comp AND b.t_cuno="&t_cuno"
                                	LEFT OUTER JOIN work.Dimset_Active_Blocked 	c ON a.t_dset=c.t_dset AND c.Comp=&Comp
GROUP BY a.t_line
ORDER BY a.t_line;
QUIT;

DATA work.NiBiFTP_063460_2 (DROP=t_dist COUNT_DIM COUNT_A_B check_dimset_a_b) ;
SET work.NiBiFTP_063460_1;
FORMAT Comment $75.;
/*Missing dimset B2B - Retrieved from BaaN*/
IF t_dset="" AND Dimset_check NE "" AND COUNT_DIM=1 								THEN DO; t_dset=Dimset_check; Comment="Missing dimset B2B - Retrieved from BaaN"; 		Check=1; END;
/*Missing dimset in BaaN*/
IF Dimset_check=""																	THEN DO; Comment="No matching dimset found in BaaN based on itemnumber (cust_part_nr)"; Check=2; END;
/*Missing dimset B2B - Also not found in BaaN*/
IF t_dset="" AND Dimset_Check=""													THEN DO; Comment="Missing dimset B2B - Also not found in BaaN"; 						Check=3; END;
/*Dimset B2B not equal to Dimset Euramax*/
IF t_dset NE "" AND Dimset_check NE "" AND t_dset NE Dimset_check AND COUNT_DIM<2	THEN DO; Comment="BaaN-dimset not equals B2B-dimset"; 									Check=4; END;
/*Cust_part_nr occurs in multiple dimsets*/
IF COUNT_DIM>1 AND COUNT_A_B=1														THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN"; 						Check=5; END;
/*Cust_part_nr occurs in multiple dimsets - Active/blocked*/
IF COUNT_DIM > 1 AND COUNT_A_B>1													THEN DO; Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked"; 		Check=6; END;
/*Blocked dimset B2B*/
IF check_dimset_a_b=1																THEN DO; Comment="Blocked dimset used in B2B-file";										Check=7; END;
RUN;

PROC SORT DATA=work.NiBiFTP_063460_2 (DROP=Comment Check Dimset_check) OUT=work.NiBiFTP_063460_1	NODUPKEY; BY t_line; RUN;	

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="063460") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.NiBiFTP_063460_1 FORCE; RUN;

DATA work.NiBiFTP_063460_Mail (KEEP=Cust_nr Cust_part_nr Order_nr Dimset_B2B Comment Dimset_BaaN);
SET work.NiBiFTP_063460_2;
IF Comment="" 								THEN DELETE;
Cust_nr=t_cuno;
Cust_part_nr=t_citm;
Order_nr=t_ponc;
Dimset_B2B=t_dset;
Dimset_BaaN=Dimset_check;
IF CHECK IN(4)								THEN Order_nr=.;  
RUN;

PROC SQL;
CREATE TABLE work.NiBiFTP_063460_Mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset_B2B,  
       a.Dimset_BaaN,
       COUNT(a.Order_nr)		AS Aantal_orders
FROM work.NiBiFTP_063460_Mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset_B2B, a.Dimset_BaaN;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM work.NiBiFTP_063460_Mail a;
QUIT;

%macro MailTriggerB2BMissingData063460();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="RV-TP-CustomerSupport@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Missing dimsets 063460 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Missing dimsets 063460";
PROC PRINT NOOBS DATA=work.NiBiFTP_063460_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData063460()');
RUN;
%Mend _063460_;

DATA work._063460_; 
SET work.Execute2;
CALL EXECUTE('%_063460_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="063460";
RUN;


/**/
/*%LET Comp=300;*/
/*%PUT &Comp;*/
/*%LET t_cuno=068738;*/
/*%PUT &t_cuno;*/
/*%LET Filename=2023 KW42 Euramax.xlsx;*/
/*%PUT &Filename;*/

/**** 068738 ***********/
%Macro _068738_ (t_cuno, Filename, comp);
PROC IMPORT OUT= WORK.Prefa_forecast 	DATAFILE= "D:\SAS_SFTP\&Comp\&t_cuno\&Filename" DBMS=XLSX REPLACE; RANGE="Feinplanung Euramax$A5:AO1000"; GETNAMES=YES; RUN;
DATA work.Prefa_forecast; SET work.Prefa_forecast; Customer_nr="&t_cuno"; Filename="&Filename"; RUN;
PROC IMPORT OUT= WORK.Prefa_wknr 		DATAFILE= "D:\SAS_SFTP\&Comp\&t_cuno\&Filename" DBMS=XLSX REPLACE; RANGE="Feinplanung Euramax$D6:D6";   GETNAMES=NO;  RUN;

DATA WORK.Prefa_forecast_1 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=H;
IF H EQ . OR H EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=H 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=H;
RUN;
DATA WORK.Prefa_forecast_2 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=I;
IF I EQ . OR I EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=I 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=I;
RUN;
DATA WORK.Prefa_forecast_3 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=J;
IF J EQ . OR J EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=J 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=J;
RUN;
DATA WORK.Prefa_forecast_4 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=K;
IF K EQ . OR K EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=K 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=K;
RUN;
DATA WORK.Prefa_forecast_5 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=L;
IF L EQ . OR L EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=L 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=L;
RUN;
DATA WORK.Prefa_forecast_6 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=M;
IF M EQ . OR M EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=M 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=M;
RUN;
DATA WORK.Prefa_forecast_7 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=N;
IF N EQ . OR N EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=N 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=N;
RUN;
DATA WORK.Prefa_forecast_8 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=O;
IF O EQ . OR O EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=O 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=O;
RUN;
DATA WORK.Prefa_forecast_9 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=P;
IF P EQ . OR P EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=P 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=P;
RUN;
DATA WORK.Prefa_forecast_10 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=Q;
IF Q EQ . OR Q EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=Q 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=Q;
RUN;
DATA WORK.Prefa_forecast_11 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=R;
IF R EQ . OR R EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=R 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=R;
RUN;
DATA WORK.Prefa_forecast_12 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=S;
IF S EQ . OR S EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=S 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=S;
RUN;
DATA WORK.Prefa_forecast_13 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=T;
IF T EQ . OR T EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=T 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=T;
RUN;
DATA WORK.Prefa_forecast_14 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=U;
IF U EQ . OR U EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=U 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=U;
RUN;
DATA WORK.Prefa_forecast_15 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=V;
IF V EQ . OR V EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=V 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=V;
RUN;
DATA WORK.Prefa_forecast_16 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=W;
IF W EQ . OR W EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=W 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=W;
RUN;
DATA WORK.Prefa_forecast_17 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=X;
IF X EQ . OR X EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=X 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=X;
RUN;
DATA WORK.Prefa_forecast_18 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=Y;
IF Y EQ . OR Y EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=Y 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=Y;
RUN;
DATA WORK.Prefa_forecast_19 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  									THEN WkNr=Z;
IF Z EQ . OR Z EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=Z 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=Z;
RUN;
DATA WORK.Prefa_forecast_20 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AA;
IF AA EQ . OR AA EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AA 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AA;
RUN;
DATA WORK.Prefa_forecast_21 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AB;
IF AB EQ . OR AB EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AB 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AB;
RUN;
DATA WORK.Prefa_forecast_22 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AC;
IF AC EQ . OR AC EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AC 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AC;
RUN;
DATA WORK.Prefa_forecast_23 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AD;
IF AD EQ . OR AD EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AD 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AD;
RUN;
DATA WORK.Prefa_forecast_24 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AE;
IF AE EQ . OR AE EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AE 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AE;
RUN;
DATA WORK.Prefa_forecast_25 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AF;
IF AF EQ . OR AF EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AF 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AF;
RUN;
DATA WORK.Prefa_forecast_26 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AG;
IF AG EQ . OR AG EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AG 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AG;
RUN;
DATA WORK.Prefa_forecast_27 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AH;
IF AH EQ . OR AH EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AH 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AH;
RUN;
DATA WORK.Prefa_forecast_28 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AI;
IF AI EQ . OR AI EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AI 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AI;
RUN;
DATA WORK.Prefa_forecast_29 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AJ;
IF AJ EQ . OR AJ EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AJ 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AJ;
RUN;
DATA WORK.Prefa_forecast_30 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AK;
IF AK EQ . OR AK EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AK 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AK;
RUN;
DATA WORK.Prefa_forecast_31 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AL;
IF AL EQ . OR AL EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AL 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AL;
RUN;
DATA WORK.Prefa_forecast_32 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AM;
IF AM EQ . OR AM EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AM 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AM;
RUN;
DATA WORK.Prefa_forecast_33 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AN;
IF AN EQ . OR AN EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AN 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AN;
RUN;
DATA WORK.Prefa_forecast_34 (KEEP= Customer_nr Filename Cust_Item Description Dimset Weight WkNr); SET WORK.Prefa_forecast;
FORMAT Weight $7.;
RETAIN WkNr; IF _N_=1  										THEN WkNr=AO;
IF AO EQ . OR AO EQ 0 OR A="Summe:" OR C EQ "" OR WkNr=AO 	THEN DELETE;
Cust_Item=A ;Dimset=B; Description=C; Weight=AO;
RUN;


PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_1  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_2  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_3  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_4  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_5  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_6  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_7  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_8  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_9  FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_10 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_11 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_12 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_13 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_14 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_15 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_16 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_17 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_18 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_19 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_20 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_21 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_22 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_23 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_24 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_25 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_26 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_27 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_28 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_29 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_30 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_31 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_32 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_33 FORCE; WHERE WkNr>0; RUN;
PROC APPEND BASE=WORK.Prefa_forecast_f DATA= WORK.Prefa_forecast_34 FORCE; WHERE WkNr>0; RUN;

PROC SQL;
CREATE TABLE WORK.Prefa_forecast_f1 AS
SELECT 	Monotonic() AS Line			LABEL="Line",
        a.*,
		b.D 		AS FileWkNr 	LABEL="FileWkNr",
		CASE WHEN a.WkNr>b.D THEN Year(date()) ELSE Year(date())+1 END AS Fin_Year
FROM WORK.Prefa_forecast_f a 	LEFT OUTER JOIN Prefa_wknr b ON b.D>.;
QUIT;

PROC SQL;
CREATE TABLE WORK.Prefa_forecast_f1 AS
SELECT 	a.*,
		b.Date
FROM WORK.Prefa_forecast_f1 a 	LEFT OUTER JOIN db2data.periods b ON a.WkNr=b.WEEK_NUMBER AND a.Fin_year=b.Fin_year AND b.Week_Day=5
ORDER BY a.Line;
QUIT;

DATA Prefa_068738_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET Prefa_forecast_f1; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=Cust_Item;
t_dsca=Description;		
FORMAT t_sern $10.; t_sern="";   
FORMAT t_pord 12.2; t_pord=0;
FORMAT t_cdd1 DATE9.; t_cdd1=0; 								     						
FORMAT t_cdd2 DATE9.; t_cdd2=DATE;
FORMAT t_oqua 6.; t_oqua=Weight; 	
t_ponc=0;  																	
t_popc=0; 																	
FORMAT t_odat DATE9.; t_odat=today();
t_dela="";
t_oqui=0; 												
t_cuni="kg";
t_dqui=0; 												
t_bqui=0; 												
FORMAT t_dset $11.; t_dset=Dimset;													
t_band=0; 													 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="068738") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.Prefa_068738_1 FORCE;    RUN;
%Mend _068738_;

DATA work._068738_; 
SET work.Execute2;
CALL EXECUTE('%_068738_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="068738";
RUN;



/**** 068740 ***********/
%Macro _068740_ (t_cuno, Filename, comp);
PROC IMPORT OUT= WORK.Prefa1_forecast 	DATAFILE= "D:\SAS_SFTP\&Comp\&t_cuno\&Filename" DBMS=XLSX REPLACE; RANGE="Tabelle1$A1:AV1000"; GETNAMES=NO; RUN; /*Let op bereik*/
DATA WORK.Prefa1_forecast;             SET work.Prefa1_forecast; Customer_nr="&t_cuno"; Filename="&Filename"; RUN;
PROC IMPORT OUT= WORK.Prefa1_wknr 		DATAFILE= "D:\SAS_SFTP\&Comp\&t_cuno\&Filename" DBMS=XLSX REPLACE; RANGE="Tabelle1$G1:G1";   GETNAMES=NO;  RUN;
DATA WORK.Prefa1_wknr (KEEP=FileWkNr); SET WORK.Prefa1_wknr; G=Substr(G,3); FORMAT FileWkNr 2.; FileWkNr=input(G,2.);     RUN;


DATA WORK.Prefa1_forecast_1 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(L,3);
IF F IN("Woche","Monat","Z�hler","kg") OR L EQ "" OR L EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=L;
RUN;
DATA WORK.Prefa1_forecast_2 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(M,3);
IF F IN("Woche","Monat","Z�hler","kg") OR M EQ "" OR M EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=M;
RUN;
DATA WORK.Prefa1_forecast_3 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(N,3);
IF F IN("Woche","Monat","Z�hler","kg") OR N EQ "" OR N EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=N;
RUN;
DATA WORK.Prefa1_forecast_4 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(O,3);
IF F IN("Woche","Monat","Z�hler","kg") OR O EQ "" OR O EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=O;
RUN;
DATA WORK.Prefa1_forecast_5 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(P,3);
IF F IN("Woche","Monat","Z�hler","kg") OR P EQ "" OR P EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=P;
RUN;
DATA WORK.Prefa1_forecast_6 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(Q,3);
IF F IN("Woche","Monat","Z�hler","kg") OR Q EQ "" OR Q EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=Q;
RUN;
DATA WORK.Prefa1_forecast_7 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(R,3);
IF F IN("Woche","Monat","Z�hler","kg") OR R EQ "" OR R EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=R;
RUN;
DATA WORK.Prefa1_forecast_8 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(S,3);
IF F IN("Woche","Monat","Z�hler","kg") OR S EQ "" OR S EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=S;
RUN;
DATA WORK.Prefa1_forecast_9 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(T,3);
IF F IN("Woche","Monat","Z�hler","kg") OR T EQ "" OR T EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=T;
RUN;
DATA WORK.Prefa1_forecast_10 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(U,3);
IF F IN("Woche","Monat","Z�hler","kg") OR U EQ "" OR U EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=U;
RUN;
DATA WORK.Prefa1_forecast_11 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(V,3);
IF F IN("Woche","Monat","Z�hler","kg") OR V EQ "" OR V EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=V;
RUN;
DATA WORK.Prefa1_forecast_12 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(W,3);
IF F IN("Woche","Monat","Z�hler","kg") OR W EQ "" OR W EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=W;
RUN;
DATA WORK.Prefa1_forecast_13 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(X,3);
IF F IN("Woche","Monat","Z�hler","kg") OR X EQ "" OR X EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=X;
RUN;
DATA WORK.Prefa1_forecast_14 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(Y,3);
IF F IN("Woche","Monat","Z�hler","kg") OR Y EQ "" OR Y EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=Y;
RUN;
DATA WORK.Prefa1_forecast_15 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																THEN WkNr1=Substr(Z,3);
IF F IN("Woche","Monat","Z�hler","kg") OR Z EQ "" OR Z EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=Z;
RUN;
DATA WORK.Prefa1_forecast_16 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AA,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AA EQ "" OR AA EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AA;
RUN;
DATA WORK.Prefa1_forecast_17 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AB,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AB EQ "" OR AB EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AB;
RUN;
DATA WORK.Prefa1_forecast_18 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AC,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AC EQ "" OR AC EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AC;
RUN;
DATA WORK.Prefa1_forecast_19 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AD,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AD EQ "" OR AD EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AD;
RUN;
DATA WORK.Prefa1_forecast_20 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AE,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AE EQ "" OR AE EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AE;
RUN;
DATA WORK.Prefa1_forecast_21 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AF,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AF EQ "" OR AF EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AF;
RUN;
DATA WORK.Prefa1_forecast_22 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AG,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AG EQ "" OR AG EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AG;
RUN;
DATA WORK.Prefa1_forecast_23 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AH,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AH EQ "" OR AH EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AH;
RUN;
DATA WORK.Prefa1_forecast_24 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AI,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AI EQ "" OR AI EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AI;
RUN;
DATA WORK.Prefa1_forecast_25 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AJ,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AJ EQ "" OR AJ EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AJ;
RUN;
DATA WORK.Prefa1_forecast_26 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AK,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AK EQ "" OR AK EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AK;
RUN;
DATA WORK.Prefa1_forecast_27 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AL,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AL EQ "" OR AL EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AL;
RUN;
DATA WORK.Prefa1_forecast_28 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AM,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AM EQ "" OR AM EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AM;
RUN;
DATA WORK.Prefa1_forecast_29 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AN,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AN EQ "" OR AN EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AN;
RUN;
DATA WORK.Prefa1_forecast_30 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AO,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AO EQ "" OR AO EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AO;
RUN;
DATA WORK.Prefa1_forecast_31 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AP,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AP EQ "" OR AP EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AP;
RUN;
DATA WORK.Prefa1_forecast_32 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AQ,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AQ EQ "" OR AQ EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AQ;
RUN;
DATA WORK.Prefa1_forecast_33 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AR,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AR EQ "" OR AR EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AR;
RUN;
DATA WORK.Prefa1_forecast_34 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AS,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AS EQ "" OR AS EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AS;
RUN;
DATA WORK.Prefa1_forecast_35 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AT,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AT EQ "" OR AT EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AT;
RUN;
DATA WORK.Prefa1_forecast_36 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AU,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AU EQ "" OR AU EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AU;
RUN;
DATA WORK.Prefa1_forecast_37 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AV,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AV EQ "" OR AV EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AV;
RUN;
DATA WORK.Prefa1_forecast_38 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AW,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AW EQ "" OR AW EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AW;
RUN;
DATA WORK.Prefa1_forecast_39 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AX,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AX EQ "" OR AX EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AX;
RUN;
DATA WORK.Prefa1_forecast_40 (KEEP= Customer_nr Filename Cust_Item Description Weight WkNr1); SET WORK.Prefa1_forecast;
FORMAT Weight $7.;
RETAIN WkNr1; IF _N_=1  																	THEN WkNr1=Substr(AY,3);
IF F IN("Woche","Monat","Z�hler","kg") OR AY EQ "" OR AY EQ "0" OR C="Summe" OR C EQ "" 	THEN DELETE;
Cust_Item="0"||B ; Description=C; Weight=AY;
RUN;


PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_1 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_2 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_3 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_4 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_5 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_6 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_7 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_8 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_9 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_10 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_11 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_12 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_13 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_14 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_15 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_16 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_17 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_18 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_19 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_20 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_21 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_22 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_23 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_24 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_25 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_26 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_27 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_28 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_29 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_30 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_31 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_32 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_33 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_34 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_35 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_36 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_37 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_38 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_39 FORCE; RUN;
PROC APPEND BASE=WORK.Prefa1_forecast_f DATA= WORK.Prefa1_forecast_40 FORCE; RUN;


DATA WORK.Prefa1_forecast_f (DROP=WkNr1); SET WORK.Prefa1_forecast_f; FORMAT WkNr 2.; WkNr=input(WkNr1,2.); RUN;

PROC SQL;
CREATE TABLE WORK.Prefa1_forecast_f1 AS
SELECT 	Monotonic() 															AS Line			LABEL="Line",
        a.*,
		b.FileWkNr,
		CASE WHEN a.WkNr>b.FileWkNr THEN Year(date()) ELSE Year(date())+1 END 	AS Fin_Year
FROM WORK.Prefa1_forecast_f a 	LEFT OUTER JOIN Prefa1_wknr b ON b.FileWkNr>.;
QUIT;

PROC SQL;
CREATE TABLE WORK.Prefa1_forecast_f1 AS
SELECT 	a.*,
		b.Date
FROM WORK.Prefa1_forecast_f1 a 	LEFT OUTER JOIN db2data.periods b ON a.WkNr=b.WEEK_NUMBER AND a.Fin_year=b.Fin_year AND b.Week_Day=5
ORDER BY a.Line;
QUIT;

PROC SQL;
CREATE TABLE WORK.Prefa1_forecast_f1 AS
SELECT 	a.*,
		b.t_dset			AS Dimset		LABEL='Dimset'		
FROM WORK.Prefa1_forecast_f1 a 	LEFT OUTER JOIN tdmdm995 b ON a.Customer_nr=b.t_cuno AND a.Cust_item=substr(b.t_cupn,1,6) AND b.Comp=&Comp AND b.t_dist=2
ORDER BY a.Line;
QUIT;

PROC SQL;
CREATE TABLE WORK.Prefa1_forecast_f1 AS
SELECT a.line,
       a.Customer_nr,
	   a.Filename,
	   a.Cust_item,
	   a.Description,
	   a.Weight,
	   a.WkNr,
	   a.Fin_Year,
	   a.Date,
	   a.Dimset,
	   CASE WHEN COUNT(a.Dimset)>1				THEN "Cust_part_nr occurs in multiple dimsets BaaN" 
       ELSE CASE WHEN a.Dimset=""				THEN "No matching dimset found in BaaN based on itemnumber (cust_part_nr)" 
       ELSE ""																												END END AS Comment
FROM WORK.Prefa1_forecast_f1 a
GROUP BY a.Line;
QUIT;

PROC SORT DATA=WORK.Prefa1_forecast_f1    OUT=Prefa_068740_Mail;  WHERE Comment NE ""	; BY Line; RUN;
PROC SORT DATA=WORK.Prefa1_forecast_f1    OUT=Prefa1_forecast_f1; WHERE Comment =  ""	; BY Line; RUN;

DATA Prefa_068740_1 (keep=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd1 t_cdd2 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET Prefa1_forecast_f1; 
t_cuno=Customer_nr;
t_fnam=Filename;
t_line=Line;
FORMAT t_citm $50.; t_citm=Cust_Item;
t_dsca=Description;		
FORMAT t_sern $10.; t_sern="";   
FORMAT t_pord 12.2; t_pord=0;
FORMAT t_cdd1 DATE9.; t_cdd1=0; 								     						
FORMAT t_cdd2 DATE9.; t_cdd2=DATE;
FORMAT t_oqua 6.; t_oqua=Weight; 	
t_ponc=0;  																	
t_popc=0; 																	
FORMAT t_odat DATE9.; t_odat=today();
t_dela="";
t_oqui=0; 												
t_cuni="kg";
t_dqui=0; 												
t_bqui=0; 												
FORMAT t_dset $11.; t_dset=Dimset;													
t_band=0; 													 
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
RUN;

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900&comp WHERE t_cuno="068740") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900&comp data=work.Prefa_068740_1 FORCE; RUN;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Customer_nr) AS COUNT
FROM Prefa_068740_Mail a;
QUIT;

%macro MailTriggerB2BMissingData068740();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="dverbert@euramax.eu"  /*CC="team-bi@euramax.eu"*/
SUBJECT="**** Forecast - missing data 068740 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "Forecast - missing data 068740";
PROC PRINT NOOBS DATA=work.Prefa_068740_Mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData068740()');
RUN;
%Mend _068740_;

DATA work._068740_; 
SET work.Execute2;
CALL EXECUTE('%_068740_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="068740";
RUN;




/**** 018851 ***********/
%Macro _018851_ (t_cuno, Filename, comp);
FILENAME myfile "D:\SAS_SFTP\&comp\&t_cuno\&filename" ;
PROC IMPORT DATAFILE=myfile OUT=work.KSI_018851 DBMS=xls REPLACE; GETNAMES=YES; RANGE="Carnet S $A2:AC200"; RUN;
DATA work.KSI_018851; SET work.KSI_018851; Cust_nr="018851"; Filename="&Filename"; Line=_N_;
RENAME Article=Cust_part_nr;
LABEL  Article=Cust_part_nr;
WHERE Week NE .; 
RUN;
PROC SORT DATA=work.KSI_018851; BY Week Ack__Item; RUN;


PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tccom013400 as select * from connection to baan
   (SELECT 400 			AS Comp,
           a.*
FROM ttccom013400 a
	);  DISCONNECT from baan;
QUIT;

PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tdlra220400 as select * from connection to baan
   (SELECT 400 			AS Comp,
           a.t_dset, a.t_spec, a.t_nval
FROM ttdlra220400 a
WHERE a.t_spec IN ('000010','001000','001010', '001100') AND a.t_item IN ('TOLALU')
	);  DISCONNECT from baan;
QUIT;


PROC SQL;
CREATE TABLE work.KSI_018851 AS
SELECT a.*,
       b.t_dset,
	   b.t_dsca,
	   g.Date					AS Del_date				LABEL='Del_date',
	   c.t_nval					AS SG					LABEL='SG',
	   d.t_nval 				AS WD					LABEL='WD',
	   e.t_nval 				AS TH					LABEL='TH',
	   f.t_nval 				AS LG					LABEL='LG',
	   h.Check_dimset_a_b,
	   COUNT(b.t_dset)			AS Count_dim			LABEL='Count_dim',
	   COUNT(DISTINCT b.t_dist)	AS Count_a_b			LABEL='Count_a_b',
	   t_imth					AS Discreet_NonDiscreet	LABEL='Discreet_NonDiscreet'
FROM work.KSI_018851 a				LEFT OUTER JOIN work.tdmdm995              b ON b.Comp=&Comp            AND a.Cust_nr=b.t_cuno AND a.Cust_part_nr=Substr(b.t_cupn,1,14) AND b.t_dist=2
									LEFT OUTER JOIN work.tdlra220400           c ON b.t_dset=c.t_dset       AND c.t_spec='000010'
									LEFT OUTER JOIN work.tdlra220400           d ON b.t_dset=d.t_dset       AND d.t_spec='001000'
									LEFT OUTER JOIN work.tdlra220400           e ON b.t_dset=e.t_dset       AND e.t_spec='001010'
                                    LEFT OUTER JOIN work.tdlra220400           f ON b.t_dset=f.t_dset       AND f.t_spec='001100'
                                    INNER JOIN      DB2data.Periods            g ON a.Week=g.Fin_yr_wk      AND g.Week_day=1
                                    LEFT OUTER JOIN work.Dimset_Active_Blocked h ON h.Comp=&Comp            AND b.t_dset=h.t_dset
									LEFT OUTER JOIN work.tdmdm012400 		   i ON b.t_dset=i.t_dset
GROUP BY a.Line;
QUIT;

DATA work.KSI_018851; SET work.KSI_018851;
SGV=INPUT(SG,12.0); WDV=INPUT(WD,12.1); THV=INPUT(TH,12.2); LGV=INPUT(LG,12.3);
Stk=FLOOR(Net_Weight/((LGV*WDV*THV*SGV)/1000000000));
/*M2=ROUND(Poids_net/THV/SGV*1000000,0.001);*/
RUN;

DATA work.KSI_018851_1 (DROP=Check_dimset_a_b Count_dim Count_a_b); 
SET work.KSI_018851;
FORMAT Comment $75.;
IF Count_dim>1 AND Count_a_b=1		THEN Comment="Cust_part_nr occurs in multiple dimsets BaaN";
IF Count_dim>1 AND Count_a_b>1		THEN Comment="Cust_part_nr occurs in multiple dimsets BaaN - Active/blocked";
IF Check_dimset_a_b=1				THEN Comment="Blocked dimset used in B2B-file";
IF t_dset=""   AND Ack NE "STOCK"	THEN Comment="No matching cust part nr in BaaN";	
IF Discreet_NonDiscreet > 1			THEN Comment="Dimset non_discreet in stead of discreet";
RUN;

PROC SORT DATA=KSI_018851_1 (DROP=Comment) OUT=KSI_018851	NODUPKEY; BY Line; RUN;	

DATA work.KSI_1 (KEEP=t_cuno t_fnam t_line t_citm t_dsca t_sern t_pord t_cdd2 t_cdd1 t_oqua t_ponc t_popc t_odat t_dela t_oqui t_cuni t_dqui t_bqui t_dset t_band t_proc t_errm t_datp t_refcntd t_refcntu);
SET work.KSI_018851;
t_cuno=Cust_nr;
t_fnam=Filename;
t_line=_N_;
FORMAT t_citm $50.;		t_citm=Cust_part_nr;
t_dsca=t_dsca;
t_sern="";
t_pord=0;
FORMAT t_cdd2 DATE9.; 	t_cdd2=Del_date;		
FORMAT t_cdd1 DATE9.;  	t_cdd1=0; 
t_oqua=0;
FORMAT t_ponc 6.;		t_ponc=Ack;
t_popc=IT;
FORMAT t_odat DATE9.;   t_odat=DATE();
t_dela=Customer;
t_oqui=Stk; 			IF t_oqui=.	THEN t_oqui=0;
t_cuni="stk";      /* Transfer to stk Constellium TOLALU */
t_dqui=0;
t_bqui=Stk; 			IF t_bqui=.	THEN t_bqui=0; 
t_dset=t_dset;
t_band=0; 																	
t_proc=2;
t_errm="";
t_datp=0;
t_refcntd=0;
t_refcntu=0;
/*WHERE t_dset IS NOT MISSING;*/
RUN;

PROC sql;
CONNECT to odbc as baan (dsn='InfAdmin');
EXECUTE (DELETE FROM ttdprd900400 WHERE t_cuno="018851") by baan; 
DISCONNECT from baan;
QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND base=baan.ttdprd900400 data=work.KSI_1 FORCE; RUN;

/*Delivery address kopi�ren naar tdcox023400*/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.tccom013400  as select * from connection to baan
   (SELECT  a.t_cuno,
            a.t_cdel,
            a.t_nama	FROM     	ttccom013400 a 	
   WHERE a.t_cuno="018851" 
	); DISCONNECT from baan;
QUIT;

DATA work.tdcox023400 (KEEP=t_cuno t_cdel t_dela t_refcntd t_refcntu);
SET work.tccom013400;
t_cuno=t_cuno;
t_cdel=t_cdel;
t_dela=t_nama;
t_refcntd=0;
t_refcntu=0;
RUN;
PROC SORT DATA=work.tdcox023400 NODUPKEY; BY t_cuno t_dela; RUN;

PROC sql; CONNECT to odbc as baan (dsn='InfAdmin'); EXECUTE (DELETE FROM ttdcox023400 a) by baan; QUIT;
libname baan odbc dsn='InfAdmin'; 
PROC APPEND BASE=baan.ttdcox023400 DATA=work.tdcox023400 FORCE; RUN;

/**/
/*Mail dimset issues*/
DATA work.KSI_018851_mail (KEEP=Cust_nr Ordernummer Cust_part_nr Dimset Comment );
SET work.KSI_018851_1;
IF Comment="" 								THEN DELETE;
Ordernummer=Ack;
Dimset=t_dset;
RUN;

PROC SQL;
CREATE TABLE work.KSI_018851_mail AS
SELECT a.Comment, 
       a.Cust_nr,
       a.Cust_part_nr, 
       a.Dimset,
       COUNT(a.Ordernummer)		AS Aantal_orders
FROM work.KSI_018851_mail a
GROUP BY a.Comment, a.Cust_nr, a.Cust_part_nr, a.Dimset;
QUIT;

PROC SQL;
CREATE TABLE work.Mail_check AS
SELECT COUNT(a.Cust_nr) AS COUNT
FROM KSI_018851_mail a;
QUIT;

%macro MailTriggerB2BMissingData018851();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="hgoor@euramax.eu""rvanbuggenum@euramax.eu"  CC="dverbert@euramax.eu"
SUBJECT="**** B2B - 018851 ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - 018851";
PROC PRINT NOOBS DATA=work.KSI_018851_mail;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.Mail_check;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BMissingData018851()');
RUN;
%Mend _018851_;

DATA work._018851_; 
SET work.Execute2;
CALL EXECUTE('%_018851_('||t_cuno||','||Filename||','||comp||')'); WHERE t_cuno="018851";
RUN;




/**/
/*Sheet - Ordereenheid incorrect - Create script*/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.CreateScript130 as select * from connection to baan
   (SELECT a.t_cuno
FROM ttdprd900130 a				LEFT OUTER JOIN ttdmdm012130 b ON a.t_dset=b.t_dset
WHERE b.t_imth=1 AND a.t_cuni NOT IN("ST","St�","stk")
GROUP BY a.t_cuno
	);  DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan; 
CREATE table work.CreateScript300 as select * from connection to baan
   (SELECT a.t_cuno
FROM ttdprd900300 a				LEFT OUTER JOIN ttdmdm012300 b ON a.t_dset=b.t_dset
WHERE b.t_imth=1 AND a.t_cuni NOT IN("ST","St�","stk")
GROUP BY a.t_cuno
	);  DISCONNECT from baan;
QUIT;
DATA work.CreateScript; SET work.CreateScript130; RUN;
PROC APPEND BASE=work.CreateScript DATA=work.CreateScript300; RUN;

DATA work.CreateScript;
SET CreateScript;
IF t_cuno IN("025000","054500")	THEN DELETE;
RUN;

PROC SQL;
CREATE TABLE work.CreateScriptSheetUnit AS
SELECT COUNT(a.t_cuno)	AS COUNT
FROM work.CreateScript a;
QUIT;

%macro MailTriggerB2BSheetOrderunit();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="dverbert@euramax.eu"  CC="team-bi@euramax.eu"
SUBJECT="**** B2B - Sheet - Create script DB2_B2B_sftp - incorrect order unit ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE "B2B - Sheet - Create script DB2_B2B_sftp - incorrect order unit";
PROC PRINT NOOBS DATA=work.CreateScript;  RUN;

ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Mail_check_1; SET work.CreateScriptSheetUnit;
IF COUNT>0 THEN CALL EXECUTE('%MailTriggerB2BSheetOrderunit()');
RUN;
