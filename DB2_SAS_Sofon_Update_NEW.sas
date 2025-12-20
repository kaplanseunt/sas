libname db2data  odbc dsn='db2ecp' schema=DB2ADMIN user=db2admin password=aachen;
libname db2fin   odbc dsn='db2ecp' schema=DB2FIN   user=db2admin password=aachen;

libname sofona_l odbc dsn='SofonA_Live' user=Sofon password=Sofon ;
libname sofonq_l odbc dsn='SofonQ_Live' user=Sofon password=Sofon ;

libname sofona_d odbc dsn='SofonA_Dev'  user=Sofon password=Sofon ;
libname sofonq_d odbc dsn='SofonQ_Dev'  user=Sofon password=Sofon ;




/* Update macro definitions */
%MACRO UpdateCheck(Source_Table,Update_Table);
%PUT &Source_Table; %PUT &Update_Table;
DATA work.UpdateTable; SET &Source_Table; DELETE ; RUN; PROC APPEND BASE=work.UpdateTable DATA=&Update_Table FORCE; RUN;     	/* Create correct column formation 	*/
DATA work.SourceTable; SET &Source_Table; RUN;																			/* Create copy of Source data      	*/
PROC SQL; CREATE TABLE work.different AS SELECT * FROM work.UpdateTable EXCEPT SELECT * FROM work.SourceTable; QUIT;    /* Get differences new/change		*/
PROC SQL; CREATE TABLE work.differentD AS SELECT * FROM work.SourceTable EXCEPT SELECT * FROM work.UpdateTable; QUIT;	/* Get differences deleted/changed	*/
PROC APPEND BASE=work.differentC DATA=work.different FORCE; RUN; PROC APPEND BASE=work.differentC DATA=work.differentD FORCE; RUN;  DATA work.differentC; SET work.differentC; Check=1; RUN;  /* Merge diferences 	*/
PROC SQL; CREATE TABLE work.rec_check AS SELECT count(check) AS Count FROM work.differentC; QUIT:						/* Check for number of differences to double check update rule 					*/
DATA work.rec_check; SET work.rec_check; SourceTable="&Source_Table"; IF Count>0 THEN CALL EXECUTE('%UpdateRecs('||SourceTable||')'); RUN;   /* Call update table if any differences at all 			*/
PROC DELETE data=work.UpdateTable work.SourceTable work.different work.differentD work.differentC work.rec_check; RUN;
%MEND;

/**********************************************************************/
/***			Calculate Capacity Factor and store in Sofon 		**�E/
/**********************************************************************/

PROC SQL;
CREATE TABLE work.ECP_Forecast_Capacity AS
SELECT	a.fin_year			AS Year,
		a.fin_per			AS Period,
		SUM(a.forc_weight) 	AS Forecast
FROM db2data.Rol_reforcast_new a 
LEFT JOIN db2data.dimsets b 	ON 	a.Company=b.Company AND a.dimset=b.Dimset
LEFT JOIN db2data.Fin_views c 	ON	a.Company=c.Company AND a.Led_acc_NR=c.Led_Acc_Nr
Left JOIN db2data.customers d 	ON 	a.Company=d.Company AND a.cust_nr=d.cust_nr
WHERE b.width_group="Stnd" AND c.Led_Acc_Check=1
GROUP BY a.fin_year, a.fin_per;
QUIT;
/*
PROC APPEND BASE=sofona_d.ECP_Forecast_Capacity DATA=work.ECP_Forecast_Capacity; RUN;
PROC APPEND BASE=sofona_l.ECP_Forecast_Capacity DATA=work.ECP_Forecast_Capacity; RUN;
*/
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE a.Year=b.Year AND a.Period=b.Period ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																				/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_Forecast_Capacity';
UpdateTable='work.ECP_Forecast_Capacity';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

DATA _null_; 
SourceTable='sofona_d.ECP_Forecast_Capacity';
UpdateTable='work.ECP_Forecast_Capacity';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

/************************************************************************/
/***** 			Update ECP_Uplift Tabel SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Uplift
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
    		RANGE="CM_Uplift%$A2:G200"; GETNAMES=YES;
RUN;

/*PROC APPEND BASE=sofona_l.ECP_Uplift DATA=work.ECP_Uplift FORCE; RUN;*/

%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE a.Upl_Code=b.Upl_Code ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_Uplift';
UpdateTable='work.ECP_Uplift';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

DATA _null_; 
SourceTable='sofona_d.ECP_Uplift';
UpdateTable='work.ECP_Uplift';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

/************************************************************************/
/***** Update Paints Tabel SOFON									*****/
/************************************************************************/
DATA work.Paints (Keep=Company PaintCode);
SET db2data.finishes;
IF Pr_code ne '-' 	THEN DO; PaintCode=Pr_code; 	OUTPUT; END;
IF L1_paint ne '-' 	THEN DO; PaintCode=L1_paint; 	OUTPUT; END;
IF L2_paint ne '-' 	THEN DO; PaintCode=L2_paint; 	OUTPUT; END;
IF L3_paint ne '-' 	THEN DO; PaintCode=L3_paint; 	OUTPUT; END;
RUN;

DATA work.PaintsD (Keep=Company PaintCode);
SET db2data.designs;
IF Design_DEC1_code ne '-' 	THEN DO; PaintCode=Design_DEC1_code; 	OUTPUT; END;
IF Design_DEC2_code ne '-' 	THEN DO; PaintCode=Design_DEC2_code; 	OUTPUT; END;
IF Design_DEC3_code ne '-' 	THEN DO; PaintCode=Design_DEC3_code; 	OUTPUT; END;
IF Design_DEC4_code ne '-' 	THEN DO; PaintCode=Design_DEC4_code; 	OUTPUT; END;
IF Design_DEC5_code ne '-' 	THEN DO; PaintCode=Design_DEC5_code; 	OUTPUT; END;
IF Design_DEC6_code ne '-' 	THEN DO; PaintCode=Design_DEC6_code; 	OUTPUT; END;
where Design_Finish_code_fs ne '-';
RUN;

PROC APPEND base=work.Paints DATA=work.PaintsD; RUN;

PROC SQL;
CREATE TABLE work.paints AS
SELECT	a.Company,
		a.PaintCode,
		b.Paint_suppl			AS PaintSuppl,
		b.Paint_Syst			AS PaintSystem,
		b.Paint_Type			AS PaintType,
		b.Paint_coverage_Suppl	AS PaintCoverage,
		b.Paint_coverage		AS ActCoverage,
		b.Paint_Stat			AS PaintStat,
		count(a.PaintCode)		AS Count1
FROM work.Paints a,	db2data.dimsets b
WHERE a.Company=b.Company AND a.PaintCode=b.Dimset
GROUP BY a.Company, a.PaintCode, b.Paint_suppl, b.Paint_syst, b.Paint_Type, b.Paint_coverage_Suppl, b.Paint_Coverage, b.Paint_Stat;
QUIT;

PROC SQL;
CREATE TABLE work.paints AS
SELECT	a.*,
		b.Paint_spec_Value_num	AS SolWeight
FROM work.Paints a LEFT OUTER JOIN db2data.Paint_specs b 
ON a.Company=b.Company AND a.PaintCode=b.Paint_Code AND A.PaintSuppl=b.Suppl_nr AND b.Paint_Spec='SOL_WGHT';
QUIT;

DATA work.PurchasePricelists; 	SET db2data.PurchasePricelists; 											RUN;
DATA work.PurchasePricelists1; 	SET db2data.PurchasePricelists; suppl_nr=' 00110'; WHERE suppl_nr=' 05108'; RUN;

PROC APPEND BASE=work.PurchasePricelists DATA=work.PurchasePricelists1; RUN; 

PROC SORT DATA=work.PurchasePricelists;
BY Company dimset suppl_nr DESCENDING price_start_date ;
RUN;

data work.PurchasePricelists;
SET work.PurchasePricelists;
BY Company dimset suppl_nr DESCENDING price_start_date ;
IF not first.suppl_nr THEN DELETE;
RUN;


PROC SQL;
CREATE TABLE work.paints AS
SELECT	a.*,
		b.Base_Price	AS Price
FROM work.Paints a LEFT OUTER JOIN work.PurchasePricelists b 
ON a.Company=b.Company AND a.PaintCode=b.Dimset AND A.PaintSuppl=b.Suppl_nr AND (b.Price_End_Date>Date() OR b.Price_End_Date=.) ;
QUIT; 

PROC SORT DATA=work.Paints nodups;
BY Company PaintCode;
RUN;


PROC IMPORT OUT= work.surcharge
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
    		RANGE="Surcharge$A2:E50"; GETNAMES=YES;
RUN;


DATA work.paints; SET work.paints;
FORMAT Surcharge $11.;
IF PaintSystem='PVDF' THEN Surcharge='PVDF'; ELSE Surcharge='OtherPaints'; 
RUN;

PROC SQL;
CREATE TABLE work.paints AS
SELECT  a.*,
		b.ExtraValue_per,
		b.Extra_value_eur
FROM work.paints a LEFT OUTER JOIN work.surcharge b ON a.surcharge=b.surcharge AND date()>Start_Date AND date()<End_Date;
QUIT;

DATA work.paints (DROP=Count1);
SET work.paints;
IF PaintSuppl="" 						THEN PaintSuppl='-';
IF PaintCode eq "0" 					THEN DELETE;
IF Price=. 								THEN Price=0;
IF SolWeight=. 							THEN SolWeight=0;
IF PaintCoverage=. AND ActCoverage<1 	THEN DELETE;
IF PaintSuppl="-" 						THEN DELETE;
/* Paint Price calculation */
/*IF Price=Price+Extra_value_eur; */
Price=Price*ExtraValue_per; 
RUN;

PROC IMPORT OUT= WORK.Painttrayf
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
    		RANGE="Paint_Tray$A1:F1000"; GETNAMES=YES;
RUN;

DATA work.Painttrayf_EAP; SET work.Painttrayf; Company='EAP'; WHERE Company='Roe'; RUN;
PROC APPEND BASE=work.Painttrayf DATA=work.Painttrayf_EAP; RUN;

PROC SQL;
CREATE TABLE work.paints AS
SELECT   a.*,
		 b.*
FROM  work.paints a LEFT OUTER JOIN WORK.Painttrayf b ON a.COmpany=b.Company AND a.PaintSystem=b.PaintSystem AND a.PaintType=b.PaintType;
QUIT;

PROC IMPORT OUT= WORK.PaintLineSp
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
    		RANGE="LineSpeedRefs$A2:E1000"; GETNAMES=YES;
RUN;

PROC SQL;
CREATE TABLE work.paints AS
SELECT   a.*,
		 b.SPLSpeedRef,
		 b.WPLSpeedRef,
		 b.DLSpeedRef
FROM  work.paints a LEFT OUTER JOIN WORK.PaintLineSp b ON a.PaintSystem=b.PaintSystem;
QUIT;

DATA work.paints; SET work.paints;
IF ActCoverage=. OR ActCoverage=<1 	THEN ActCoverage=0;
IF PaintCoverage=. 					THEN PaintCoverage=0;
IF TrayFillSPL=. 					THEN TrayFillSPL=0;
IF TrayFillWPL=. 					THEN TrayFillWPL=0;
IF TrayFillDL=. 					THEN TrayFillDL=0;
RUN;


/* DM Added 6-4-2022 Paint Recipe */
PROC SQL;
CREATE TABLE work.paints AS
SELECT   a.*,
		 b.Paint_Recipe
		 FROM  work.paints a LEFT OUTER JOIN DB2Data.Paints b ON a.company=b.company AND a.paintcode=b.paint_code;
QUIT;

/* DM Added 6-4-2022 Paint Recipe */

/* Update Paints data to DB2 for pricing check Purchase  */
PROC SQL; CONNECT to odbc as DB2 (dsn='db2ecp'); 
EXECUTE (Truncate db2admin.Sofon_Paints ignore delete triggers drop storage immediate ) by DB2;
EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.Sofon_Paints TO USER INFODBC )  by DB2;
EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.Sofon_Paints TO USER FINODBC )  by DB2;
QUIT;
PROC APPEND BASE=db2data.Sofon_Paints DATA=work.paints FORCE; RUN;

DATA work.paints; SET work.paints;
IF Company IN ('Roe','ECP') THEN DELETE;
IF Company='EAP' 			THEN Company='Roe';
RUN;

DATA work.Paints (DROP=PaintStat); SET work.paints; RUN;
PROC APPEND BASE=work.Paints DATA=sofona_l.ECP_Paints FORCE; WHERE PaintCode="-"; RUN;
/**/
/*PROC sql;*/
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Paints ) by SOFON_t;*/
/*CONNECT to odbc as SOFON_p (dsn='Sofon_Art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Paints ) by SOFON_p; */
/*QUIT;   */
/**/
/*PROC APPEND BASE=sofona_t.ECP_Paints DATA=work.paints; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Paints DATA=work.paints; RUN;  */


/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE a.Company=b.Company AND a.PaintCode=b.PaintCode ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																							/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_Paints';
UpdateTable='work.paints';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

DATA _null_; 
SourceTable='sofona_d.ECP_Paints';
UpdateTable='work.paints';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  







/************************************************************************/
/***** Update Artikel Tabel  SOFON									*****/
/************************************************************************/
DATA work.artikel; SET sofona_d.article; DELETE; RUN;

PROC SQL;
CREATE TABLE work.art_new AS
SELECT 	"-         	"													AS ArticleNumber FORMAT $11.,
		a.finish_nr,
		a.side,
		TRIM(b.FinishcodeFS)											AS Description FORMAT $25.,
		b.ProdBrand,
		TRIM(b.ProdBrand)||"/"||TRIM(b.ProdColourBrandFS)				AS TextA,
		CASE	WHEN a.Prod_Line='SPL' THEN TRIM(a.Substrate)||"/"||TRIM(a.Prod_Line)||"/"||TRIM(a.Surf_qual)||"/"||TRIM(a.Surf_treat)||"/"||TRIM(a.Pre_treat_SPL)||"/"||PUT(a.Runs,1.)||" Runs."
				WHEN a.Prod_Line='WPL' THEN TRIM(a.Substrate)||"/"||TRIM(a.Prod_Line)||"/"||TRIM(a.Surf_qual)||"/"||TRIM(a.Surf_treat)||"/"||TRIM(a.Pre_treat_WPL)||"/"||PUT(a.Runs,1.)||" Runs."  END  AS TextB,
		"Primer: "||TRIM(a.PR_code)||" -"||PUT(a.PR_thickn,2.)||"mu." 	AS TextC,
		"Topc.1: "||TRIM(a.L1_Paint)||" -"||PUT(a.L1_Thickn,2.)||"mu." 	AS TextD,
		"Topc.2: "||TRIM(a.L2_Paint)||" -"||PUT(a.L2_Thickn,2.)||"mu" 	AS TextE,
		"Topc.3: "||TRIM(a.L3_Paint)||" -"||PUT(a.L3_Thickn,2.)||"mu." 	AS TextF,
		"RAL: "||TRIM(a.Ral)||"-    NCS: "||TRIM(NCS) 					AS TextG
FROM   db2data.Finishes a,
	   db2data.Finish_rel b
WHERE  a.Finish_code=b.FinishCodeFS AND a.Company='Roe'
ORDER BY a.finish_nr;
QUIT;

PROC SQL;
CREATE TABLE work.design_new AS
SELECT 	a.design_nr						AS ArticleNumber,
		'FS'							AS side,
		TRIM(a.design_code)				AS Description,
		" "								AS ProdBrand,
		TRIM(a.Design_desc)				AS TextA,
		" "								AS TextB,
		" "								AS TextC,
		" "								AS TextD,
		" "								AS TextE,
		" "								AS TextF,
		" "								AS TextG
FROM   db2data.Designs a 
WHERE  Design_blocked eq "No" AND a.Company='Roe'
ORDER BY a.design_nr;
QUIT;

PROC APPEND BASE=work.art_new DATA=work.design_new FORCE; RUN;

PROC SORT DATA=work.art_new;
BY side finish_nr;
RUN;

DATA work.art_new; SET work.art_new;
BY side finish_nr;
IF NOT first.finish_nr THEN DELETE;
RUN;


DATA work.art_new (DROP=finish_nr ProdBrand TextA TextB TextC TextD TextE TextF TextG side) ; SET work.art_new;
IF ArticleNumber="-" 	THEN ArticleNumber=LEFT(finish_nr);
IF side='RS' 			THEN ArticleNumber=LEFT(finish_nr+9000000);
FORMAT DescChangeDate DateTime22.3; DescChangeDate=0;
FORMAT Text1ChangeDate DateTime22.3; Text1ChangeDate=0;
FORMAT Text2ChangeDate DateTime22.3; Text2ChangeDate=0;
FORMAT Text3ChangeDate DateTime22.3; Text3ChangeDate=0;
FORMAT Text4ChangeDate DateTime22.3; Text4ChangeDate=0;
FORMAT ReleaseForSales DateTime22.3; ReleaseForSales=0;
FORMAT EndOfSales DateTime22.3; EndOfSales=0;
FORMAT ReplacedByDate DateTime22.3; ReplacedByDate=0;
OrderAsExtraItem=0;
Icon=-1;
UnitCode="PC";
Type="Import";

Text1="{\rtf1\ansi\deff0 {\fonttbl {\f0 Courier;}}
 {\colortbl;\red0\green0\blue0;\red255\green0\blue0;}
 \landscape
 \paperw15840\paperh12240\margl720\margr720\margt720\margb720
 \tx720\tx1440\tx2880\tx5760 \line
 \b "||TextA||"\b0 \line \line \fs20
 "||TextB||" \line
 "||TextC||" \line
 "||TextD||" \line
 "||TextE||" \line
 "||TextF||" \line
 "||TextG||" \line  
 }";

WHERE ProdBrand NE "EuraDecor" /* AND finish_nr=2*/;
RUN;

DATA work.artikel;
MERGE work.artikel work.art_new;
RUN;

PROC SORT DATA= work.artikel nodups;
BY ArticleNumber;
RUN;


/***** Update to Development env.    	*****/
/*
PROC sql;
CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM article ) by SOFON_d; 
CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM article ) by SOFON_t;
CONNECT to odbc as SOFON_p (dsn='Sofon_Art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM article ) by SOFON_p; 
QUIT;   */

/* PROC APPEND BASE=sofona_d.article DATA=work.artikel; RUN; 
PROC APPEND BASE=sofona_t.article DATA=work.artikel; RUN;
PROC APPEND BASE=sofona_p.article DATA=work.artikel; RUN;  */

/*
DATA work.article; SET sofona_p.article; RUN;
PROC SQL; CREATE TABLE work.different AS SELECT * FROM work.article EXCEPT SELECT * FROM work.artikel; QUIT;
PROC SQL; DELETE FROM sofona_p.ECP_Paints a WHERE EXISTS (SELECT * FROM work.different b WHERE a.ArticleNumber=b.ArticleNumber ); QUIT;
PROC APPEND BASE=sofona_p.ECP_Paints DATA=work.different; RUN;  */


/************************************************************************/
/***** Update ECP_ProdLine_Rates Tabel  SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_ProdLine_Rates
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="ProdLineRates$A2:O250"; 
     GETNAMES=YES;
RUN;

DATA work.ECP_ProdLine_Rates; SET work.ECP_ProdLine_Rates;
IF Rate = '' THEN DELETE;
RUN; 


PROC IMPORT OUT= work.surcharge
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
    		RANGE="Surcharge$M2:Q50"; GETNAMES=YES;
RUN;


PROC SQL;
CREATE TABLE work.ECP_ProdLine_Rates AS
SELECT  a.*,
		b.ExtraValue_per,
		b.Extra_value_eur
FROM work.ECP_ProdLine_Rates a LEFT OUTER JOIN work.surcharge b ON a.rate=b.rate AND date()>Start_Date AND date()<End_Date;
QUIT;

DATA work.ECP_ProdLine_Rates;
SET work.ECP_ProdLine_Rates;
IF ExtraValue_per NE . THEN SPL=SPL*ExtraValue_per;
IF ExtraValue_per NE . THEN WPL=WPL*ExtraValue_per; 
RUN;


/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Rate=b.Rate); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_ProdLine_Rates';
UpdateTable='work.ECP_ProdLine_Rates';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

DATA _null_; 
SourceTable='sofona_d.ECP_ProdLine_Rates';
UpdateTable='work.ECP_ProdLine_Rates';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  


/************************************************************************/
/***** Update LineSpeeds Tabel  SOFON								*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_LineSpeeds
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="LineSpeeds$A2:J1000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeeds  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeeds  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeeds  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_LineSpeeds DATA=work.ECP_LineSpeeds FORCE; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_LineSpeeds DATA=work.ECP_LineSpeeds FORCE; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_LineSpeeds DATA=work.ECP_LineSpeeds FORCE; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Company=b.Company AND a.ProdLine=b.ProdLine AND a.Substrate=b.Substrate AND a.Code=b.Code AND a.ThickMin=b.ThickMin AND a.ThickMax=b.ThickMax AND a.WidthMin=b.WidthMin AND a.WidthMax=b.WidthMax AND 
a.LineSpeed=b.LineSpeed AND a.MinPlt=b.MinPlt); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_LineSpeeds';
UpdateTable='work.ECP_LineSpeeds';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

DATA _null_; 
SourceTable='sofona_d.ECP_LineSpeeds';
UpdateTable='work.ECP_LineSpeeds';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  



/************************************************************************/
/***** Update ECP_Auth_level Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Auth_level
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="AuthLevels$A2:H1000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Auth_level  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Auth_level  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Auth_level  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Auth_level DATA=work.ECP_Auth_level; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Auth_level DATA=work.ECP_Auth_level; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Auth_level DATA=work.ECP_Auth_level; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.AuthLevel=b.AuthLevel AND a.AuthPercMin=b.AuthPercMin AND a.AuthDescr=b.AuthDescr AND a.AuthPercMax=b.AuthPercMax AND a.Market=b.Market AND a.WidthGroup=b.WidthGroup AND 
a.Tolling=b.Tolling AND a.Substrate=b.Substrate  ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Auth_level';
UpdateTable='work.ECP_Auth_level';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

DATA _null_; 
SourceTable='sofona_d.ECP_Auth_level';
UpdateTable='work.ECP_Auth_level';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  



/************************************************************************/
/***** Update ECP_Auth_sofon Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Auth_Sofon
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="ECP_Auth_Sofon$A2:D1000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Auth_Sofon  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Auth_Sofon  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Auth_Sofon  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Auth_Sofon DATA=work.ECP_Auth_Sofon; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Auth_Sofon DATA=work.ECP_Auth_Sofon; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Auth_Sofon DATA=work.ECP_Auth_Sofon; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Auth_Level=b.Auth_Level AND a.Sales_Area=b.Sales_Area AND a.Auth_UserID=b.Auth_UserID AND a.Auth_UserID_CC=b.Auth_UserID_CC  ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Auth_Sofon';
UpdateTable='work.ECP_Auth_Sofon';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  

DATA _null_; 
SourceTable='sofona_d.ECP_Auth_sofon';
UpdateTable='work.ECP_Auth_Sofon';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;  






/************************************************************************/
/***** Update ECP_CM_Dev_perc Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_CM_Dev_perc
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="CM_Dev_perc$A2:D1000"; 
     GETNAMES=YES;
RUN;

/*DATA WORK.ECP_CM_Dev_perc (KEEP=VolMinPerc VolMaxPerc ImpCMPerc Descr); SET WORK.ECP_CM_Dev_perc;*/
/*VolMinPerc=Dev_perc_min; VolMaxPerc=Dev_perc_max; ImpCMPerc=Auth_level; */
/*RUN;*/
PROC SORT DATA=WORK.ECP_CM_Dev_perc;
BY Auth_level;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_CM_Dev_perc  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_CM_Dev_perc  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_CM_Dev_perc  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_CM_Dev_perc DATA=work.ECP_CM_Dev_perc FORCE; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_CM_Dev_perc DATA=work.ECP_CM_Dev_perc FORCE; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_CM_Dev_perc DATA=work.ECP_CM_Dev_perc FORCE; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Auth_level=b.Auth_level   ); QUIT;    									/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_CM_Dev_perc';
UpdateTable='work.ECP_CM_Dev_perc';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_CM_Dev_perc';
UpdateTable='work.ECP_CM_Dev_perc';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_CM_Targets Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_CM_Targets
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="CM_Targets$A2:F1000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_CM_Targets  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_CM_Targets  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_CM_Targets  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_CM_Targets DATA=work.ECP_CM_Targets; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_CM_Targets DATA=work.ECP_CM_Targets; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_CM_Targets DATA=work.ECP_CM_Targets; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.ApplBrand=b.ApplBrand AND a.Brand=b.Brand AND a.Region=b.Region AND a.VolMin=b.VolMin AND a.VolMax=b.VolMax AND a.TargCM=b.TargCM  ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_CM_Targets';
UpdateTable='work.ECP_CM_Targets';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN; 
DATA _null_; 
SourceTable='sofona_d.ECP_CM_Targets';
UpdateTable='work.ECP_CM_Targets';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN; 

/************************************************************************/
/***** Update ECP_Currencies Tabel  SOFON							*****/
/************************************************************************/
PROC SQL;
CREATE TABLE work.ECP_Currencies AS
SELECT 	Currency, Curr_rate AS Factor
FROM  db2fin.Curr_Rates
WHERE Company="EAP" AND Actual="Y" AND Currency IN ("AED","AUD","BRL","CHF","DKK","GBP","HKD","INR","JPY","NOK","SEK","USD");
QUIT;


/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Currencies  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Currencies  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Currencies  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Currencies DATA=work.ECP_Currencies; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Currencies DATA=work.ECP_Currencies; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Currencies DATA=work.ECP_Currencies; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.CURRENCY=b.CURRENCY  ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_Currencies';
UpdateTable='work.ECP_Currencies';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;
DATA _null_; 
SourceTable='sofona_d.ECP_Currencies';
UpdateTable='work.ECP_Currencies';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_Designs Tabel  SOFON								*****/
/************************************************************************/
PROC SQL;
CREATE TABLE work.ECP_Designs AS
SELECT 	Design_nr					AS DesignNr,
		Design_code					AS DesignCode,
		Design_desc					AS DesignDesc,
		Design_Finish_code_FS		AS FinishFS,
		Design_Report_Print			AS Report,
		Design_DEC1_code			AS D1Code,
		Design_DEC1_Cov_mm			AS D1mm,
		Design_DEC1_Cov_Perc		AS D1Perc,
		Design_DEC1_Screen			AS D1Screen,
		Design_DEC2_code			AS D2Code,
		Design_DEC2_Cov_mm			AS D2mm,
		Design_DEC2_Cov_Perc		AS D2Perc,
		Design_DEC2_Screen			AS D2Screen,
		Design_DEC3_code			AS D3Code,
		Design_DEC3_Cov_mm			AS D3mm,
		Design_DEC3_Cov_Perc		AS D3Perc,
		Design_DEC3_Screen			AS D3Screen,
		Design_DEC4_code			AS D4Code,
		Design_DEC4_Cov_mm			AS D4mm,
		Design_DEC4_Cov_Perc		AS D4Perc,
		Design_DEC4_Screen			AS D4Screen,
		Design_DEC5_code			AS D5Code,
		Design_DEC5_Cov_mm			AS D5mm,
		Design_DEC5_Cov_Perc		AS D5Perc,
		Design_DEC5_Screen			AS D5Screen,
		Design_DEC6_code			AS D6Code,
		Design_DEC6_Cov_mm			AS D6mm,
		Design_DEC6_Cov_Perc		AS D6Perc,
		Design_DEC6_Screen			AS D6Screen,
		Design_Prod_Runs			AS Runs
FROM  db2data.Designs
WHERE Design_Blocked IN ("No","-");
QUIT;

DATA work.ECP_Designs; SET work.ECP_Designs;
IF D1mm=. THEN D1mm=0; IF D1Perc=. THEN D1Perc=0; 
IF D2mm=. THEN D2mm=0; IF D2Perc=. THEN D2Perc=0; 
IF D3mm=. THEN D3mm=0; IF D3Perc=. THEN D3Perc=0; 
IF D4mm=. THEN D4mm=0; IF D4Perc=. THEN D4Perc=0; 
IF D5mm=. THEN D5mm=0; IF D5Perc=. THEN D5Perc=0; 
IF D6mm=. THEN D6mm=0; IF D6Perc=. THEN D6Perc=0; 
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Designs  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Designs  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Designs  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Designs DATA=work.ECP_Designs FORCE; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Designs DATA=work.ECP_Designs FORCE; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Designs DATA=work.ECP_Designs FORCE; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.DesignNr=b.DesignNr  ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Designs';
UpdateTable='work.ECP_Designs';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Designs';
UpdateTable='work.ECP_Designs';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_Exceptions Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Exceptions
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx"  
            DBMS=XLSX REPLACE;
     RANGE="Exceptions$A2:F1000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Exceptions  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Exceptions  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Exceptions  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Exceptions DATA=work.ECP_Exceptions; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Exceptions DATA=work.ECP_Exceptions; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Exceptions DATA=work.ECP_Exceptions; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.ExcRef=b.ExcRef  ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Exceptions';
UpdateTable='work.ECP_Exceptions';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Exceptions';
UpdateTable='work.ECP_Exceptions';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_Finish_rel Tabel  SOFON								*****/
/************************************************************************/
PROC SQL;
CREATE TABLE work.ECP_Fin_Rel AS
SELECT 	ProdCode, ProdCustDep, FinishCodeFS, FinishCodeRS, ProdProdBrand AS ProdBrand, ProdRemark, ProdStatus, 
		PRODCOLOURBRANDFS AS ProdColorBrandFS, PRODCOLOURBRANDRS AS ProdColorBrandRS, Company, ARCHITECT__CODE, ARCHITECT__BRAND, PROD_LINE
FROM  db2data.Finish_rel WHERE ProdCode <> "Unreleted";
QUIT;

DATA work.ECP_Fin_Rel; SET work.ECP_Fin_Rel;
FinishNrFS=INPUT(substr(FinishCodeFS,11,6),6.);
FinishNrRS=INPUT(substr(FinishCodeRS,11,6),6.);
RUN;

PROC SORT data=work.ECP_Fin_Rel nodups;
BY Company FinishNrFS FinishNrRS;
RUN;

DATA work.ECP_Fin_Rel;
SET work.ECP_Fin_Rel;
BY Company FinishNrFS FinishNrRS;
IF ProdColorBrandFS IN ("","?") THEN ProdColorBrandFS ="*";
IF NOT first.FinishNrRS 		THEN DELETE;
IF ProdCode="-" 				THEN DELETE;
IF finishnrfs=. 				THEN DELETE;
WHERE Company IN ('Roe','Cor');
RUN;

PROC sql;
CONNECT to odbc as SOFON_L (dsn='SofonA_Live' user=Sofon password=Sofon); EXECUTE (Delete from ECP_Fin_Rel  ) by SOFON_L;
CONNECT to odbc as SOFON_D (dsn='SofonA_Dev' user=Sofon password=Sofon);  EXECUTE (Delete from ECP_Fin_Rel  ) by SOFON_D;
QUIT;

PROC APPEND BASE=sofona_l.ECP_Fin_Rel DATA=work.ECP_Fin_Rel FORCE; RUN;
PROC APPEND BASE=sofona_d.ECP_Fin_Rel DATA=work.ECP_Fin_Rel FORCE; RUN;

/* Call on Update table macro See begining of script  */
/*%MACRO UpdateRecs(Source_Table);*/
/*PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE */
/*a.COMPANY=b.COMPANY AND a.PRODCODE=b.PRODCODE ); QUIT;    	*/
/*PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								*/
/*%MEND;*/
/*DATA _null_; */
/*SourceTable='sofona_l.ECP_Fin_Rel';*/
/*UpdateTable='work.ECP_Fin_Rel';*/
/*CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');*/
/*RUN;*/
/**/
/*DATA _null_; */
/*SourceTable='sofona_d.ECP_Fin_Rel';*/
/*UpdateTable='work.ECP_Fin_Rel';*/
/*CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');*/
/*RUN;*/


/************************************************************************/
/***** Update ECP_Finishes Tabel SOFON								*****/
/************************************************************************/
/*  Create base table from Sofon  	*/
DATA work.ECP_Finishes; SET sofona_d.ECP_Finishes; DELETE ; RUN;

PROC SQL;
CREATE TABLE work.ECP_Finishes1 AS
SELECT  	a.Company,
			a.Side,
			a.Finish_code				AS FinishCode,
			a.Finish_nr					AS FinishNr,
			a.NCS,
			a.Substrate,
			a.Prod_line					AS ProdLine,
			a.Surf_qual					AS SurfQual,
			a.Surf_Treat				AS SurfTreat,
			a.Pre_treat_SPL				AS PreTreatSPL,
			a.Pre_treat_WPL				AS PreTreatWPL,
			a.Pr_code					AS PrCode,
			a.Pr_Thickn					AS PrThickn, 
			a.L1_Paint					AS L1Paint,
			a.L1_Thickn					AS L1Thickn,
			a.L2_Paint					AS L2Paint,
			a.L2_Thickn					AS L2Thickn,
			a.L3_Paint					AS L3Paint,
			a.L3_Thickn					AS L3Thickn,
			Substr(a.Embos,1,5) 		AS Embos FORMAT $5.,
			a.Gloss_Min					AS GlossMin,
			a.Gloss_Max					AS GlossMax,
			a.Finish_Cust_Dep			AS FinishCustDep,
			Substr(a.Finish_Appl,1,4)	AS FinishAppl FORMAT $4.,
			a.Runs,
			a.Ral,
			a.Fin_Paint_Syst			AS PaintSyst,
			a.Fin_Paint_Type			AS PaintType
	FROM db2data.finishes a
	WHERE Finish_Status="Released";
	QUIT;

DATA work.ECP_Finishes1; SET work.ECP_Finishes1; 
IF NCS="" 		THEN NCS="-";
IF GlossMin=. 	THEN GlossMin=0;
IF GlossMax=. 	THEN GlossMax=0;
IF PrThickn=. 	THEN PrThickn=0;
WHERE Company IN ('Roe','Cor');
RUN;

PROC APPEND base=work.ECP_Finishes data=work.ECP_Finishes1 FORCE; RUN;

PROC sql;
CONNECT to odbc as SOFON_L (dsn='SofonA_Live' user=Sofon password=Sofon); EXECUTE (Delete from ECP_Finishes  ) by SOFON_L;
CONNECT to odbc as SOFON_D (dsn='SofonA_Dev' user=Sofon password=Sofon);  EXECUTE (Delete from ECP_Finishes  ) by SOFON_D;
QUIT;

PROC APPEND BASE=sofona_l.ECP_Finishes DATA=work.ECP_Finishes FORCE; RUN;
PROC APPEND BASE=sofona_d.ECP_Finishes DATA=work.ECP_Finishes FORCE; RUN;


/* Call on Update table macro See begining of script  */
/*%MACRO UpdateRecs(Source_Table);*/
/*PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE */
/*a.COMPANY=b.COMPANY AND a.FinishCode=b.FinishCode AND a.side=b.side); QUIT;    	*/
/*PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								*/
/*%MEND;*/
/*DATA _null_; */
/*SourceTable='sofona_l.ECP_Finishes';*/
/*UpdateTable='work.ECP_Finishes';*/
/*CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');*/
/*RUN;*/
/**/
/*DATA _null_; */
/*SourceTable='sofona_d.ECP_Finishes';*/
/*UpdateTable='work.ECP_Finishes';*/
/*CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');*/
/*RUN;*/


/************************************************************************/
/***** Update ECP_Foils Tabel  SOFON								*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Foils
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Foils$A2:F1000"; 
     GETNAMES=YES;
RUN;

DATA WORK.ECP_Foils;
SET WORK.ECP_Foils;
WHERE FoilType ne "";
RUN;
/**/
/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Foils  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Foils  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Foils  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Foils DATA=work.ECP_Foils; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Foils DATA=work.ECP_Foils; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Foils DATA=work.ECP_Foils; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.FoilType=b.FoilType); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_L.ECP_Foils';
UpdateTable='work.ECP_Foils';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Foils';
UpdateTable='work.ECP_Foils';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_Foil_Select Tabel  SOFON							*****/
/************************************************************************/
/*  Create base table from Sofon  	*/
DATA work.ECP_Foil_Select; SET sofona_d.ECP_Foil_Select; DELETE ; RUN;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ECP_Foil_Select as select * from connection to baan
   (SELECT  'Roe'					AS Company,
			a.t_pnts   				AS PaintSystem,
			b.t_ctnm				AS PaintType,
			a.t_embo				AS Embossing,
			a.t_glsf				AS GlossMin,
			a.t_glst				AS GlossMax,
			a.t_cuno				AS CustomerSpecific,
			a.t_pntc				AS PaintSpecific,
			a.t_ftyp				AS FoilType,
			c.t_shlf				AS Outdoor,
			c.t_thck				AS Foil_Thickness,
			CASE
			WHEN c.t_perf=2 THEN 'No'
			WHEN c.t_perf=1 THEN 'Yes' END
									AS Perforated,
			c.t_prnt				AS Foil_Print,
			CASE
			WHEN c.t_clor=1	THEN 'Transparant'
			WHEN c.t_clor=2	THEN 'Blue Transparant'
			WHEN c.t_clor=3	THEN 'Black' 
			WHEN c.t_clor=4	THEN 'Black / White' END
									AS Foil_Color,
			''						AS AccountID_CRM
   FROM         ttdqua160120 a,
   				tttadv401000 b,
				ttdqua150120 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511'  AND
   			a.t_ftyp=c.t_ftyp
   ORDER  by  a.t_pnts   );
 DISCONNECT from baan;
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ECP_Foil_Select_Cor as select * from connection to baan
   (SELECT  'Cor'					AS Company,
			a.t_pnts   				AS PaintSystem,
			b.t_ctnm				AS PaintType,
			a.t_embo				AS Embossing,
			a.t_glsf				AS GlossMin,
			a.t_glst				AS GlossMax,
			a.t_cuno				AS CustomerSpecific,
			a.t_pntc				AS PaintSpecific,
			a.t_ftyp				AS FoilType,
			c.t_shlf				AS Outdoor,
			c.t_thck				AS Foil_Thickness,
			CASE
			WHEN c.t_perf=2 THEN 'No'
			WHEN c.t_perf=1 THEN 'Yes' END
									AS Perforated,
			c.t_prnt				AS Foil_Print,
			CASE
			WHEN c.t_clor=1	THEN 'Transparant'
			WHEN c.t_clor=2	THEN 'Blue Transparant'
			WHEN c.t_clor=3	THEN 'Black' 
			WHEN c.t_clor=4	THEN 'Black / White' END
									AS Foil_Color,
			''						AS AccountID_CRM
   FROM         ttdqua160200 a,
   				tttadv401000 b,
				ttdqua150200 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511'  AND
   			a.t_ftyp=c.t_ftyp
   ORDER  by  a.t_pnts   );
 DISCONNECT from baan;
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ECP_Foil_Select_ECP as select * from connection to baan
   (SELECT  'ECP'					AS Company,
			a.t_pnts   				AS PaintSystem,
			b.t_ctnm				AS PaintType,
			a.t_embo				AS Embossing,
			a.t_glsf				AS GlossMin,
			a.t_glst				AS GlossMax,
			a.t_cuno				AS CustomerSpecific,
			a.t_pntc				AS PaintSpecific,
			a.t_ftyp				AS FoilType,
			c.t_shlf				AS Outdoor,
			c.t_thck				AS Foil_Thickness,
			CASE
			WHEN c.t_perf=2 THEN 'No'
			WHEN c.t_perf=1 THEN 'Yes' END
									AS Perforated,
			c.t_prnt				AS Foil_Print,
			CASE
			WHEN c.t_clor=1	THEN 'Transparant'
			WHEN c.t_clor=2	THEN 'Blue Transparant'
			WHEN c.t_clor=3	THEN 'Black' 
			WHEN c.t_clor=4	THEN 'Black / White' END
									AS Foil_Color,
			''						AS AccountID_CRM
   FROM         ttdqua160130 a,
   				tttadv401000 b,
				ttdqua150130 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511'  AND
   			a.t_ftyp=c.t_ftyp
   ORDER  by  a.t_pnts   );
 DISCONNECT from baan;
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ECP_Foil_Select_EAP as select * from connection to baan
   (SELECT  'EAP'					AS Company,
			a.t_pnts   				AS PaintSystem,
			b.t_ctnm				AS PaintType,
			a.t_embo				AS Embossing,
			a.t_glsf				AS GlossMin,
			a.t_glst				AS GlossMax,
			a.t_cuno				AS CustomerSpecific,
			a.t_pntc				AS PaintSpecific,
			a.t_ftyp				AS FoilType,
			c.t_shlf				AS Outdoor,
			c.t_thck				AS Foil_Thickness,
			CASE
			WHEN c.t_perf=2 THEN 'No'
			WHEN c.t_perf=1 THEN 'Yes' END
									AS Perforated,
			c.t_prnt				AS Foil_Print,
			CASE
			WHEN c.t_clor=1	THEN 'Transparant'
			WHEN c.t_clor=2	THEN 'Blue Transparant'
			WHEN c.t_clor=3	THEN 'Black' 
			WHEN c.t_clor=4	THEN 'Black / White' END
									AS Foil_Color,
			''						AS AccountID_CRM
   FROM         ttdqua160300 a,
   				tttadv401000 b,
				ttdqua150300 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511'  AND
   			a.t_ftyp=c.t_ftyp
   ORDER  by  a.t_pnts   );
 DISCONNECT from baan;
QUIT;

PROC APPEND base=work.ECP_Foil_Select data=work.ECP_Foil_Select_Cor; RUN;
PROC APPEND base=work.ECP_Foil_Select data=work.ECP_Foil_Select_ECP; RUN;
PROC APPEND base=work.ECP_Foil_Select data=work.ECP_Foil_Select_EAP; RUN;


DATA work.ECP_Foil_Select; 
SET work.ECP_Foil_Select;
IF CustomerSpecific="" 				THEN CustomerSpecific="All";
IF PaintSpecific=""					THEN PaintSpecific="All";
IF find(Foil_Print,'arrow','i')>0 	THEN Arrow="Yes"; ELSE Arrow="No";
IF find(Foil_Print,'arrow','i')>0 	THEN Arrow="Yes"; ELSE Arrow="No";
IF Company='EAP' 					THEN Company='Roe';
IF PaintSystem="ALU CHROVRIJ"  		THEN DO; PaintSystem="-"; PaintType="-"; END;
WHERE Company in ('Cor','EAP');
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='SofonA_Dev' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Foil_Select  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Foil_Select  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='SofonA_Live' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Foil_Select  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Foil_Select DATA=work.ECP_Foil_Select FORCE; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Foil_Select DATA=work.ECP_Foil_Select FORCE; RUN;*/
/*PROC APPEND BASE=sofona_l.ECP_Foil_Select DATA=work.ECP_Foil_Select FORCE; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Company=b.Company AND a.PaintSystem=b.PaintSystem AND a.PaintType=b.PaintType AND a.Embossing=b.Embossing AND a.GlossMin=b.GlossMin AND a.GlossMax=b.GlossMax AND a.CustomerSpecific=b.CustomerSpecific 
AND a.PaintSpecific=b.PaintSpecific AND a.Outdoor=b.Outdoor AND a.Foil_Thickness=b.Foil_Thickness AND a.Perforated=b.Perforated AND a.Foil_print=b.Foil_print AND a.Foil_print=b.Foil_print 
AND a.Foil_color=b.Foil_color AND a.AccountID_CRM=b.AccountID_CRM AND a.Foiltype=b.Foiltype ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;												/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofonA_L.ECP_Foil_Select';
UpdateTable='work.ECP_Foil_Select';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofonA_d.ECP_Foil_Select';
UpdateTable='work.ECP_Foil_Select';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_Freight costs Table  SOFON						*****/
/************************************************************************/
/*  Create base table from Sofon  	*/
DATA work.ECP_Freight; SET sofona_d.ECP_Freight; DELETE ; RUN;

PROC SQL;
CREATE TABLE work.ecp_freight1 AS
SELECT  a.Company,
		a.Cust_nr AS CustNr,
		CASE WHEN b.Carg_type='Coil'  THEN SUM(a.Shipm_costs)/SUM(a.Del_Quan) END  AS CostsCoil  FORMAT 5.2,
		CASE WHEN b.Carg_type='Sheet' THEN SUM(a.Shipm_costs)/SUM(a.Del_Quan) END  AS CostsSheet FORMAT 5.2
FROM  db2data.Shipm_Shipments a, db2data.shipm_trips b
WHERE a.Company=b.Company AND a.Trip_nr=b.Trip_nr AND b.Carg_Type IN ('Coil','Sheet') AND Year(a.SAB_date) eq Year(date())-2
GROUP BY a.Company, a.Cust_nr, b.Carg_Type;
QUIT;

PROC SQL;
CREATE TABLE work.ecp_freight1 AS
SELECT  a.Company, a.Custnr, MAX(CostsCoil) AS CostCoil, MAX(CostsSheet) AS CostSheet FROM work.ecp_freight1 a GROUP BY a.Company, a.Custnr;
QUIT;





PROC IMPORT OUT= work.surcharge
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
    		RANGE="Surcharge$G2:K50"; GETNAMES=YES;
RUN;


DATA work.ecp_freight1; SET work.ecp_freight1;
FORMAT Surcharge $11.;
Surcharge='Transport';
RUN;

PROC SQL;
CREATE TABLE work.ecp_freight1 AS
SELECT  a.*,
		b.ExtraValue_per,
		b.Extra_value_eur
FROM work.ecp_freight1 a LEFT OUTER JOIN work.surcharge b ON a.surcharge=b.surcharge AND date()>Start_Date AND date()<End_Date;
QUIT;


DATA work.ecp_freight1; SET work.ecp_freight1;
IF CostSheet=. THEN CostSheet=0; IF CostCoil=. THEN CostCoil=0;
/* Price calculation */
/*IF CostCoil=CostCoil+Extra_value_eur; */
CostCoil=CostCoil*ExtraValue_per; 
CostSheet=CostSheet*ExtraValue_per;
RUN;

PROC APPEND BASE=work.ECP_Freight DATA=work.ecp_freight1 FORCE; RUN;


/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Freight  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Freight  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Freight  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Freight DATA=work.ECP_Freight FORCE; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Freight DATA=work.ECP_Freight FORCE; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Freight DATA=work.ECP_Freight FORCE; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.CustNr=b.CustNr ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Freight';
UpdateTable='work.ECP_Freight';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Freight';
UpdateTable='work.ECP_Freight';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_Inflations Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Inflations
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Inflations$A2:P12"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Inflations  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Inflations  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Inflations  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Inflations DATA=work.ECP_Inflations; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Inflations DATA=work.ECP_Inflations; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Inflations DATA=work.ECP_Inflations; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Inflation=b.Inflation ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Inflations';
UpdateTable='work.ECP_Inflations';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Inflations';
UpdateTable='work.ECP_Inflations';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;



/************************************************************************/
/***** Update ECP_Line_Speed_Ref Tabel  SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Line_Speed_Ref
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="LineSpeedRefs$A2:E10000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Line_Speed_Ref  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Line_Speed_Ref  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Line_Speed_Ref  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Line_Speed_Ref DATA=work.ECP_Line_Speed_Ref; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Line_Speed_Ref DATA=work.ECP_Line_Speed_Ref; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Line_Speed_Ref DATA=work.ECP_Line_Speed_Ref; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Company=b.Company AND a.PaintSystem=b.PaintSystem ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;																								/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Line_Speed_Ref';
UpdateTable='work.ECP_Line_Speed_Ref';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Line_Speed_Ref';
UpdateTable='work.ECP_Line_Speed_Ref';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_Line_Speed_Ref Tabel  SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_LineSpeeds
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="LineSpeeds$A2:J10000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeeds  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeeds  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeeds  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_LineSpeeds DATA=work.ECP_LineSpeeds; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_LineSpeeds DATA=work.ECP_LineSpeeds; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_LineSpeeds DATA=work.ECP_LineSpeeds; RUN;*/

/* Call on Update table macro See begining of script  */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Company=b.Company AND a.ProdLine=b.ProdLine AND a.Substrate=b.Substrate AND a.Code=b.Code AND a.ThickMin=b.ThickMin AND a.ThickMax=b.ThickMax AND a.WidthMin=b.WidthMin 
AND a.WidthMax=b.WidthMax AND a.LineSpeed=b.LineSpeed AND a.MinPlt=b.MinPlt ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different; RUN;																					/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_LineSpeeds';
UpdateTable='work.ECP_LineSpeeds';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_LineSpeeds';
UpdateTable='work.ECP_LineSpeeds';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_MechLine_Setup Tabel  SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_MechLine_Setup
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="MechLine_Setup$A2:J10000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_MechLine_Setup  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_MechLine_Setup  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_MechLine_Setup  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_MechLine_Setup DATA=work.ECP_MechLine_Setup; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_MechLine_Setup DATA=work.ECP_MechLine_Setup; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_MechLine_Setup DATA=work.ECP_MechLine_Setup; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Company=b.Company AND a.ProdLine=b.ProdLine ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_MechLine_Setup';
UpdateTable='work.ECP_MechLine_Setup';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_MechLine_Setup';
UpdateTable='work.ECP_MechLine_Setup';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_Metal_Prices Tabel  SOFON							*****/
/************************************************************************/

PROC IMPORT OUT= WORK.ECP_Metal_Prices
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Metal_Prices$A2:E10000"; 
     GETNAMES=YES;
RUN;

DATA work.ECP_Metal_Prices; SET work.ECP_Metal_Prices;
			SURCHARGE = 'MetPrice';
RUN;

PROC IMPORT OUT= work.Surcharge
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
    		RANGE="Surcharge$Y2:AC50"; GETNAMES=YES;
RUN;

PROC SQL;
CREATE TABLE work.ECP_Metal_Prices AS
SELECT  a.*,
		b.ExtraValue_per,
		b.Extra_value_eur
FROM work.ECP_Metal_Prices a LEFT OUTER JOIN work.surcharge b ON a.SURCHARGE=b.metprice AND date()>Start_Date AND date()<End_Date;
QUIT;


DATA work.ECP_Metal_Prices (DROP=ExtraValue_per Extra_value_eur) ; SET work.ECP_Metal_Prices;
IF Extra_value_eur=. THEN Extra_value_eur=0;
IF Extra_value_eur>0 THEN MetPrice=MetPrice+Extra_Value_eur; 
RUN;


DATA WORK.ECP_Metal_Prices; SET WORK.ECP_Metal_Prices; WHERE ThickMin NE .; RUN;


/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.ThickMin=b.ThickMin AND a.ThickMax=b.ThickMax AND a.WidthMin=b.WidthMin AND a.WidthMax=b.WidthMax  ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_Metal_Prices';
UpdateTable='work.ECP_Metal_Prices';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Metal_Prices';
UpdateTable='work.ECP_Metal_Prices';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/***** Update ECP_Metal_Upcharge Tabel  SOFON						*****/
/************************************************************************/
/*  Create base table from Sofon  	*/

DATA work.ECP_Metal_Upcharges; SET sofona_d.ECP_Metal_Upcharges; DELETE ; RUN;

PROC IMPORT OUT= WORK.ECP_Metal_Upcharges
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Metal_Upcharges$A2:K10000"; 
     GETNAMES=YES;
RUN;

PROC IMPORT OUT= work.Surcharge
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" 
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\Sofon_Table_upload.xlsx" */
			FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
			DBMS=XLSX REPLACE;
    		RANGE="Surcharge$S2:W50"; GETNAMES=YES;
RUN;

PROC SQL;
CREATE TABLE work.ECP_Metal_Upcharges AS
SELECT  a.*,
		b.ExtraValue_per,
		b.Extra_value_eur
FROM work.ECP_Metal_Upcharges a LEFT OUTER JOIN work.surcharge b ON a.alloy=b.alloy AND date()>Start_Date AND date()<End_Date;
QUIT;

DATA work.ECP_Metal_Upcharges (DROP=ExtraValue_per Extra_value_eur) ; SET work.ECP_Metal_Upcharges;
IF Extra_value_eur=. THEN Extra_value_eur=0;
IF Extra_value_eur>0 THEN MetUpcharge=MetUpcharge+Extra_Value_eur; 
RUN;

PROC APPEND BASE=work.ECP_Metal_Upcharges DATA=work.ECP_Metal_Upcharges FORCE; RUN;

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.ThickMin=b.ThickMin AND a.ThickMax=b.ThickMax AND a.WidthMin=b.WidthMin AND a.WidthMax=b.WidthMax AND a.Alloy=b.Alloy AND a.Temper=b.Temper AND a.SurfQuality=b.SurfQuality
AND a.SurfTreatment=b.SurfTreatment AND a.Treatment=b.Treatment AND a.CustNr=b.CustNr); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_Metal_Upcharges';
UpdateTable='work.ECP_Metal_Upcharges';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Metal_Upcharges';
UpdateTable='work.ECP_Metal_Upcharges';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_PaintLine_Setup Tabel  SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_PaintLine_Setup
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="PaintLine_Setup$A2:N10000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_PaintLine_Setup  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_PaintLine_Setup  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_PaintLine_Setup  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_PaintLine_Setup DATA=work.ECP_PaintLine_Setup FORCE; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_PaintLine_Setup DATA=work.ECP_PaintLine_Setup FORCE; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_PaintLine_Setup DATA=work.ECP_PaintLine_Setup FORCE; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Company=b.Company AND a.ProdBrand=b.ProdBrand  ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_PaintLine_Setup';
UpdateTable='work.ECP_PaintLine_Setup';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_PaintLine_Setup';
UpdateTable='work.ECP_PaintLine_Setup';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_ScreenCosts Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_ScreenCosts
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx"  
            DBMS=XLSX REPLACE;
     RANGE="ScreenCosts$A2:E10000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_ScreenCosts  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_ScreenCosts  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_ScreenCosts  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_ScreenCosts DATA=work.ECP_ScreenCosts; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_ScreenCosts DATA=work.ECP_ScreenCosts; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_ScreenCosts DATA=work.ECP_ScreenCosts; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Company=b.Company ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_ScreenCosts';
UpdateTable='work.ECP_ScreenCosts';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_ScreenCosts';
UpdateTable='work.ECP_ScreenCosts';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_LinespeedAtkin Tabel  SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_LineSpeedAtkin
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx"  
            DBMS=XLSX REPLACE;
     RANGE="LineSpeedAtkin$A2:G10000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeedAtkin  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeedAtkin  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_LineSpeedAtkin  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_LineSpeedAtkin DATA=work.ECP_LineSpeedAtkin; WHERE Company <> ""; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_LineSpeedAtkin DATA=work.ECP_LineSpeedAtkin; WHERE Company <> ""; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_LineSpeedAtkin DATA=work.ECP_LineSpeedAtkin; WHERE Company <> ""; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Company=b.Company AND a.Dept=b.Dept AND a.Dept=b.Dept AND a.ProdLine=b.ProdLine AND a.SheetlengthMin=b.SheetlengthMin AND a.SheetlengthMax=b.SheetlengthMax 
AND a.InLineProcess=b.InLineProcess AND a.LineSpeed=b.LineSpeed); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_LineSpeedAtkin';
UpdateTable='work.ECP_LineSpeedAtkin';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_LineSpeedAtkin';
UpdateTable='work.ECP_LineSpeedAtkin';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;



/************************************************************************/
/***** Update ECP_Steel_Upcharges Tabel  SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Steel_Upcharges
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx"  
            DBMS=XLSX REPLACE;
     RANGE="Steel_Upcharges$A2:H10000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Steel_Upcharges  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Steel_Upcharges  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Steel_Upcharges  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Steel_Upcharges DATA=work.ECP_Steel_Upcharges; WHERE Surface <> ""; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Steel_Upcharges DATA=work.ECP_Steel_Upcharges; WHERE Surface <> ""; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Steel_Upcharges DATA=work.ECP_Steel_Upcharges; WHERE Surface <> ""; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.ThickMin=b.ThickMin AND a.ThickMax=b.ThickMax AND a.WidthMin=b.WidthMin AND a.WidthMax=b.WidthMax AND a.Quality=b.Quality AND a.Zinc=b.Zinc 
AND a.Surface=b.Surface AND a.Upcharge=b.Upcharge); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Steel_Upcharges';
UpdateTable='work.ECP_Steel_Upcharges';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Steel_Upcharges';
UpdateTable='work.ECP_Steel_Upcharges';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_Steelprices Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_SteelPrices
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx"  
            DBMS=XLSX REPLACE;
     RANGE="Steel_BasePrice$A2:F100"; 
     GETNAMES=YES;
RUN;

DATA WORK.ECP_SteelPrices; SET WORK.ECP_SteelPrices;
WHERE Year >1999;
RUN; 
/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_SteelPrices  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_SteelPrices  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_SteelPrices  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_SteelPrices DATA=work.ECP_SteelPrices; WHERE year > 0; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_SteelPrices DATA=work.ECP_SteelPrices; WHERE year > 0; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_SteelPrices DATA=work.ECP_SteelPrices; WHERE year > 0; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Year=b.Year AND a.Period=b.Period); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_SteelPrices';
UpdateTable='work.ECP_SteelPrices';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_SteelPrices';
UpdateTable='work.ECP_SteelPrices';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_Steelprices Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Discounts
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Discounts$A2:C5000"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Discounts  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Discounts  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Discounts  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Discounts DATA=work.ECP_Discounts; WHERE Discount ne 0; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Discounts DATA=work.ECP_Discounts; WHERE Discount ne 0; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Discounts DATA=work.ECP_Discounts; WHERE Discount ne 0; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.CustNr=b.CustNr ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Discounts';
UpdateTable='work.ECP_Discounts';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Discounts';
UpdateTable='work.ECP_Discounts';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;



/************************************************************************/
/***** Update ECP_Alufiber Tabel  SOFON								*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Alufiber
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx"  
            DBMS=XLSX REPLACE;
     RANGE="Alufiber$A2:B10"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Alufiber  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Alufiber  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Alufiber  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Alufiber DATA=work.ECP_Alufiber;  RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Alufiber DATA=work.ECP_Alufiber;  RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Alufiber DATA=work.ECP_Alufiber;  RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.ThicknissFiber=b.ThicknissFiber ); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Alufiber';
UpdateTable='work.ECP_Alufiber';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Alufiber';
UpdateTable='work.ECP_Alufiber';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_Wrapping Tabel  SOFON								*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Wrapping
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Wrapping$A2:J50"; 
     GETNAMES=YES;
RUN;

/*DATA WORK.ECP_Wrapping; SET WORK.ECP_Wrapping;
Price=Price*1.5;      /* weet ik niet waar ik dit moet neerzetten added 03-04-2022 DM   
RUN;*/

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Wrapping  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Wrapping  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Wrapping  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Wrapping DATA=work.ECP_Wrapping;  RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Wrapping DATA=work.ECP_Wrapping;  RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Wrapping DATA=work.ECP_Wrapping;  RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Market=b.Market AND a.SheetM2Min=b.SheetM2Min AND a.SheetM2Max=b.SheetM2Max AND a.WeightMin=b.WeightMin AND a.WeightMax=b.WeightMax AND a.LengthMin=b.LengthMin AND
a.LengthMax=b.LengthMax AND a.PalletCostsM2=b.PalletCostsM2 AND a.ProdPallet=b.ProdPallet AND a.PackPallet=b.PackPallet); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;

DATA _null_; 
SourceTable='sofona_l.ECP_Wrapping';
UpdateTable='work.ECP_Wrapping';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Wrapping';
UpdateTable='work.ECP_Wrapping';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_Contracts Tabel  SOFON							*****/
/************************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalContr120 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_cono  	Contr_nr1,
   			b.t_pono	Contr_pos,
			a.t_cuno   	Cust_nr,
			a.t_ccrs	LME_Home1
   FROM         ttdsls300120 a,
				ttdsls301120 b
   WHERE	a.t_cono = b.t_cono AND a.t_icap=2 ORDER BY a.t_cono   );
CREATE table work.SalContr130 as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_cono  	Contr_nr1,
   			b.t_pono	Contr_pos,
			a.t_cuno   	Cust_nr,
			a.t_ccrs	LME_Home1
   FROM         ttdsls300130 a,
				ttdsls301130 b
   WHERE	a.t_cono = b.t_cono AND a.t_icap=2 ORDER BY a.t_cono   );
CREATE table work.SalContr300 as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_cono  	Contr_nr1,
   			b.t_pono	Contr_pos,
			a.t_cuno   	Cust_nr,
			a.t_ccrs	LME_Home1
   FROM         ttdsls300300 a,
				ttdsls301300 b
   WHERE	a.t_cono = b.t_cono AND a.t_icap=2 ORDER BY a.t_cono   );
CREATE table work.SalContr200 as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_cono   	Contr_nr1,
   			b.t_pono	Contr_pos,
			a.t_cuno   	Cust_nr,
			a.t_ccrs	LME_Home1
   FROM         ttdsls300200 a,
				ttdsls301200 b
   WHERE	a.t_cono = b.t_cono AND a.t_icap=2   ORDER BY a.t_cono   );
QUIT;

PROC APPEND BASE=work.SalContr120 DATA=work.SalContr200; RUN;
PROC APPEND BASE=work.SalContr120 DATA=work.SalContr300; RUN;
PROC APPEND BASE=work.SalContr120 DATA=work.SalContr130; RUN;

DATA work.SalContr120 (DROP=LME_Home1 Contr_nr1); SET work.SalContr120;
LME_Home=INPUT(LME_Home1,6.0)/100;
FORMAT Contr_nr 6.0;
Contr_nr=INT(Contr_nr1);
IF Company IN ('ECP','EAP') THEN Company='Roe';
WHERE Company IN ('Cor','EAP','ECP');
RUN;

PROC SORT DATA=work.SalContr120 nodups;
BY Company Contr_nr Contr_pos Cust_nr;
RUN;


/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Contracts  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Contracts  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Contracts  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Contracts DATA=work.SalContr120; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Contracts DATA=work.SalContr120; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Contracts DATA=work.SalContr120; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.cust_nr=b.cust_nr); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Contracts';
UpdateTable='work.SalContr120';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Contracts';
UpdateTable='work.SalContr120';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;


/************************************************************************/
/***** Update ECP_Transport Tabel  SOFON							*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_Transport
/*          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" */
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Transport$A2:B50"; 
     GETNAMES=YES;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Transport  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Transport  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Transport  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Transport DATA=work.ECP_Transport;  RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Transport DATA=work.ECP_Transport;  RUN; */
/*PROC APPEND BASE=sofona_p.ECP_Transport DATA=work.ECP_Transport;  RUN;  */

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Code=b.Code); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Transport';
UpdateTable='work.ECP_Transport';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Transport';
UpdateTable='work.ECP_Transport';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

/************************************************************************/
/***** Update ECP_QuanTolerances Tabel  SOFON						*****/
/************************************************************************/
PROC IMPORT OUT= WORK.ECP_QuanTolerances
 			DATAFILE= "\\spinyspider\Projects\Productconfigurator\SAS_Upload_Files\CustomerTolerances.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="ECP_QuanTolerances$A2:I500"; 
     GETNAMES=YES;
RUN;

DATA WORK.ECP_QuanTolerances; SET WORK.ECP_QuanTolerances;
FORMAT minQuanKG 6.0;
FORMAT maxQuanKG 6.0;
FORMAT minThickn 6.0;
FORMAT maxThickn 6.0;
FORMAT minTol 6.0;
FORMAT maxTol 6.0;
RUN;

/*
PROC sql;
CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_QuanTolerances  ) by SOFON_d; 
CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_QuanTolerances  ) by SOFON_t; 
CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_QuanTolerances  ) by SOFON_p;
QUIT;

PROC APPEND BASE=sofona_d.ECP_QuanTolerances DATA=work.ECP_QuanTolerances;  RUN;
PROC APPEND BASE=sofona_t.ECP_QuanTolerances DATA=work.ECP_QuanTolerances;  RUN; 
PROC APPEND BASE=sofona_p.ECP_QuanTolerances DATA=work.ECP_QuanTolerances;  RUN;  
*/



/************************************************************************/
/***** Update LanguageCode Tabel  SOFON								*****/
/************************************************************************/
/*
PROC IMPORT OUT= WORK.ECP_Languagecode
          FILE= "\\euramax.rmd\departments\Finance\010 Roermond\040 Costing\100 Sofon Productconfigurator\Sofon_Table_upload.xlsx" 
            FILE= "\\spinyspider\projects\Productconfigurator\Sofon tables\SAS_Upload_Folder\Sofon_Table_upload.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="LanguageCode$A2:d9"; 
     GETNAMES=YES;
RUN;
*/

/*PROC sql;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM LanguageCode  ) by SOFON_d; */
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM LanguageCode  ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM LanguageCode  ) by SOFON_p;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=sofona_d.LanguageCode DATA=work.ECP_Languagecode; RUN;*/
/*PROC APPEND BASE=sofona_t.LanguageCode DATA=work.ECP_Languagecode; RUN;*/
/*PROC APPEND BASE=sofona_p.LanguageCode DATA=work.ECP_Languagecode; RUN;*/

/* Call on Update table macro See begining of script */
/*
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Language=b.Language); QUIT;    	
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;														
%MEND;
 
DATA _null_; 
SourceTable='sofona_l.LanguageCode';
UpdateTable='work.ECP_Languagecode';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.LanguageCode';
UpdateTable='work.ECP_Languagecode';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;
*/

/******************************************************************************************/
/*************************** Update Sofon Light Tabels ************************************/
/******************************************************************************************/
PROC IMPORT OUT= WORK.ECP_Sofon_light
			DATAFILE= "\\spinyspider\Projects\Productconfigurator\SAS_Upload_Files\pricelist 2017.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="ECP_Sofon_light$A2:F2000"; 
     GETNAMES=YES;
RUN;

DATA WORK.ECP_Sofon_light (DROP = Min_Thickness Max_Thickness price); SET WORK.ECP_Sofon_light;
FORMAT Min_thick 7.2;
FORMAT Max_thick 7.2;
FORMAT price2 7.2;
Min_thick=Min_Thickness;
Max_thick=Max_Thickness;
price2=Price;
RUN;

DATA WORK.ECP_Sofon_light (DROP = Min_Thick Max_Thick price2); SET WORK.ECP_Sofon_light;
FORMAT Min_thickness 7.2;
FORMAT Max_thickness 7.2;
FORMAT Price 7.2;
Min_Thickness=Min_Thick;
Max_Thickness=Max_Thick;
Price=price2;
RUN;

/*PROC sql;*/
/*CONNECT to odbc as SOFON_t (dsn='Sofon_art_TST' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Sofon_light ) by SOFON_t; */
/*CONNECT to odbc as SOFON_p (dsn='Sofon_art_PRD' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Sofon_light ) by SOFON_p;*/
/*CONNECT to odbc as SOFON_d (dsn='Sofon_art_DEV' user=Sofon password=Sofon); EXECUTE (DELETE FROM ECP_Sofon_light ) by SOFON_d;*/
/*QUIT;*/
/**/
/**/
/*PROC APPEND BASE=sofona_d.ECP_Sofon_light DATA=WORK.ECP_Sofon_light; RUN;*/
/*PROC APPEND BASE=sofona_t.ECP_Sofon_light DATA=WORK.ECP_Sofon_light; RUN;*/
/*PROC APPEND BASE=sofona_p.ECP_Sofon_light DATA=WORK.ECP_Sofon_light; RUN;*/

/* Call on Update table macro See begining of script */
%MACRO UpdateRecs(Source_Table);
PROC SQL; DELETE FROM &Source_Table a WHERE EXISTS (SELECT * FROM work.differentC b WHERE 
a.Min_Meters=b.Min_Meters AND a.Max_Meters=b.Max_Meters AND a.Prod_Brand=b.Prod_Brand AND a.Min_thickness=b.Min_thickness AND a.Max_thickness=b.Max_thickness); QUIT;    	/* Remove updated/removed records 	*/
PROC APPEND BASE=&Source_Table DATA=work.different FORCE; RUN;															/* Append new/updated records		*/
%MEND;
DATA _null_; 
SourceTable='sofona_l.ECP_Sofon_light';
UpdateTable='work.ECP_Sofon_light';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

DATA _null_; 
SourceTable='sofona_d.ECP_Sofon_light';
UpdateTable='work.ECP_Sofon_light';
CALL EXECUTE('%UpdateCheck('||SourceTable||','||UpdateTable||')');
RUN;

