
Libname DB2eura  odbc schema=EURAVIB  noprompt="dsn=db2ecp";
Libname DB2ITASK odbc schema=DB2ITASK noprompt="dsn=db2ecp";
Libname db2data  odbc dsn='db2ecp'    schema=DB2ADMIN user=db2admin password=aachen;
Libname db2fin   odbc dsn='db2ecp'    schema=DB2FIN   user=db2admin password=aachen;


/**************************/
/***** EURAVIB IMPORT *****/
/**************************/

/*****************************  Kaartenbak HSE Mixture Substance *****************************/ 
libname iTask    ODBC  dsn='iProvaPRD' schema=iTask user=odbc password=ODBC;
libname iDataprd ODBC  dsn='iProvaPRD' schema=iData user=odbc password=ODBC;  
libname iCoreprd ODBC  dsn='iProvaPRD' schema=core user=odbc password=ODBC;

/****************************************************************************/
/*****  Collection iData data and convert to db2 tables					*****/
/****************************************************************************/
/* PROC SQL;
CREATE TABLE work.iDataPRD AS
SELECT  a.fldFieldValueID					AS Field_Value_ID 	Label='Field_Value_ID',
		e.fldSingularName					AS Table_name1		Label='Table_name1',
		a.fldFieldID						AS Field_ID			Label='Field_ID',
		c.fldFieldType						AS Field_type		Label='Field_type',
		c.fldCustomOptions					AS Field_options	Label='Field_Options',
		PUT(a.fldObjectIdentifier,$6.)		AS RecordNr			Label='RecordNr',
		b.fldName							AS Field_name1		Label='Field_name1',
		a.fldNumericValue					AS Value_num		Label='Value_num',
		a.fldValue							AS Value_txt1		Label='Value_txt1',
		a.fldSelectedUserIDs				AS User_ID			Label='User_ID',
		a.fldSelectedObjectIDs				AS SelectedObjectID Label='SelectedObjectID',
		a.fldFieldValueID					AS Field_Value_ID   Label='Field_Value_ID',
		DATEPART(a.fldDateValue) 			AS Value_date		Label='Value_date' FORMAT DATE9.
FROM  	iCoreprd.tbdFieldValue a,
		iCoreprd.tbdFieldName b,
		iCoreprd.tbdField c,
		iDataprd.tbdDataTypeField d,
		iDataprd.tbdDataTypeName e
WHERE   a.fldFieldID = b.fldFieldID AND a.fldFieldID = c.fldFieldID AND  a.fldFieldID=d.fldFieldID AND d.fldDataTypeID=e.fldDataTypeID 
AND e.fldSingularName IN ('HSE Mixture Substance','HSE ADR-IMDG',
'HSE Stock Hazardous Substance Cabinets') AND fldObjectDeleted=0;

CREATE TABLE work.iDataPRD AS
SELECT  a.*,
		b.fldFieldListOptionID				AS  Option_ID
FROM  	work.iDataPRD a  LEFT OUTER JOIN iCoreprd.tbdFieldValueListValue b ON a.Field_Value_ID=b.fldFieldValueID;

CREATE TABLE work.iDataPRD AS
SELECT  a.*,
		b.fldName			AS  Option_Name	Label='Option_Name'
FROM  	work.iDataPRD a  LEFT OUTER JOIN iCoreprd.tbdFieldListOptionName b ON a.Option_ID=b.fldFieldListOptionID;

CREATE TABLE work.iDataPRD AS
SELECT  a.*,
		b.fldName			AS  User_name	Label='User_name'
FROM  	work.iDataPRD a  LEFT OUTER JOIN iCoreprd.tbduser b ON a.User_ID=b.flduserid;

QUIT;

PROC SQL;
CREATE TABLE work.iDataPRD AS
SELECT  a.*,
		b.fldSearchValue
FROM  	work.iDataPRD a  LEFT OUTER JOIN iCoreprd.tbdFieldValueSearchValue b ON a.Field_Value_ID=b.fldFieldValueID
WHERE  b.fldLanguage="nl-NL" ;
QUIT; */

/***** above in one go 1st November 2025	*****/
libname iDataprd ODBC  dsn='iProvaPrd' schema=iData user=odbc password=ODBC;  
libname iCoreprd ODBC  dsn='iProvaPrd' schema=core user=odbc password=ODBC;

proc sql;
   create table work.iDataPRD as
   select
      a.fldFieldValueID                 as Field_Value_ID    label='Field_Value_ID',
      e.fldSingularName                 as Table_name1       label='Table_name1',
      a.fldFieldID                      as Field_ID          label='Field_ID',
      c.fldFieldType                    as Field_type        label='Field_type',
      c.fldCustomOptions                as Field_options     label='Field_Options',
      put(a.fldObjectIdentifier,$6.)    as RecordNr          label='RecordNr',
      b.fldName                         as Field_name1       label='Field_name1',
      a.fldNumericValue                 as Value_num         label='Value_num',
      a.fldValue                        as Value_txt1        label='Value_txt1',
      a.fldSelectedUserIDs              as User_ID           label='User_ID',
      a.fldSelectedObjectIDs            as SelectedObjectID  label='SelectedObjectID',
      datepart(a.fldDateValue)          as Value_date        label='Value_date' format=date9.,
      f.fldFieldListOptionID            as Option_ID         label='Option_ID',
      g.fldName                         as Option_Name       label='Option_Name',
      h.fldName                         as User_Name         label='User_Name',
      i.fldSearchValue                  as fldSearchValue    label='SearchValue'
   from 
      iCoreprd.tbdFieldValue a
      inner join iCoreprd.tbdFieldName b on a.fldFieldID = b.fldFieldID
      inner join iCoreprd.tbdField c on a.fldFieldID = c.fldFieldID
      inner join iDataprd.tbdDataTypeField d on a.fldFieldID = d.fldFieldID
      inner join iDataprd.tbdDataTypeName e on d.fldDataTypeID = e.fldDataTypeID
      left join iCoreprd.tbdFieldValueListValue f on a.fldFieldValueID = f.fldFieldValueID
      left join iCoreprd.tbdFieldListOptionName g on f.fldFieldListOptionID = g.fldFieldListOptionID
      left join iCoreprd.tbdUser h on a.fldSelectedUserIDs = h.fldUserID
      left join iCoreprd.tbdFieldValueSearchValue i 
         on a.fldFieldValueID = i.fldFieldValueID
        and i.fldLanguage = "nl-NL"
   where 
      e.fldSingularName in (
         'HSE Mixture Substance',
         'HSE ADR-IMDG',
         'HSE Stock Hazardous Substance Cabinets'
      )
      and a.fldObjectDeleted = 0;
quit;
/***** above in one go 1st November 2025	*****/


DATA work.iDataPRD1 (DROP=Field_Value_ID Field_Options Option_ID Option_Name Table_name1 Field_name1 User_ID User_Name Value_Date)         ;
SET work.iDataPRD;
IF Option_ID ne . 																		THEN Value_txt1=Option_Name;
IF User_ID ne "" 																		THEN Value_txt1=User_name;
IF value_date ne . 																		THEN Value_num=value_date;
if Field_Name1="ADR Data" 																THEN Value_txt1=fldSearchValue;
FORMAT Value_txt $500.; Value_txt=TRIM(Substr(Value_txt1,1,500));
FORMAT Table_name $50.; Table_name=TRIM(Substr(Table_name1,1,50));
FORMAT Field_name $50.; Field_name=TRIM(Substr(Field_name1,1,50));
IF INDEX(Field_Options,'multiselect')>0 												THEN Value_txt1=fldSearchValue;
IF INDEX(Field_Options,'textareaheight')>0 OR INDEX(Field_Options,'customoptions')>0 	THEN Txt='Y';
IF INDEX(Field_Options,'multiselect')>0 												THEN Txt='Y';
IF INDEX(Field_Options,'<onlyintegersallowed>1')>0                                      THEN DO; Int='Y'; Txt='N'; END;
IF INDEX(Field_Options,'<onlyintegersallowed>0')>0                                      THEN DO; Int='';  Txt='N'; END;
IF INDEX(Field_Options,'allowpastdate')>0 												THEN DO; Int='Y'; Txt='N'; END;
Field_Txt_Width=LENGTH(TRIM(Value_txt));
Field_num_Width=LENGTH(TRIM(INPUT(Value_num,$20.)));
IF INDEX(Value_num,'.')>0 AND Value_num ne . 											THEN Field_Decimals=LENGTH((scan(Value_num,2,"."))); ELSE Field_Decimals=0;
Table_name=Translate (Trim(Table_name),"_",' ');
Field_name=Translate (Trim(Field_Name),"______",'.?/'' ');Field_Name=Trim(Field_Name);
/*Field_name=tranwrd(Field_name,"Flashpoint_'C",'Flashpoint');*/
Field_name=tranwrd(Field_name,"ADR-IMDG",'ADR_IMDG');
Field_name=tranwrd(Field_name,'Department_Responsible_for_Collecting_Handling_Was','Dep_Resp_Coll_Handl_Was');
Field_name=tranwrd(Field_name,"Naam-dimset_mengsel_stof_BAAN",'Dimset_BAAN');
Field_name=tranwrd(Field_name,"Naam-artikelnummer_mengsel_stof_BAAN",'Artikel_BAAN');
IF Table_name='HSE_ADR-IMDG' 															THEN Table_name="HSE_ADR_IMDG";
IF Table_name='HSE_Stock_Hazardous_Substance_Cabinets' 									THEN Table_name="HSE_Stock_Cabinets";
RUN;

PROC SORT data=work.iDataPRD1;
BY Recordnr Field_name;
RUN;

/***** Detect number of tables			*****/
PROC SQL;
CREATE TABLE work.tables AS
SELECT   a.Table_name, count(a.Table_name) AS recordnr
FROM   work.iDataPRD1 a
GROUP BY a.Table_name;
QUIT;

/***** Detect tables fields				*****/
PROC SQL;
CREATE TABLE work.var_fields AS
SELECT  a.Table_name				AS TableName,
		a.Field_name				AS FieldName,
		a.Int						AS Field_int,
		a.Txt						AS Field_txt,
		MAX(Field_Txt_Width)		AS Field_width,
		MAX(Value_num)				AS Field_val_max,
		MIN(Value_num)				AS Field_val_min,
		MAX(Field_Decimals)			AS Field_val_dec,
		MAX(Field_num_Width)		AS Field_num_width
FROM work.iDataPRD1 a
GROUP BY a.Table_name, a.Field_name, a.Int, a.Txt ;
RUN;

DATA work.var_fields; SET work.var_fields;
IF Field_int='' AND Field_txt='N' THEN Field_num_Width=Field_num_Width; ELSE Field_num_Width=LENGTH(TRIM(INPUT(Field_val_max,$12.)));
FORMAT SAS_Format $10.;
IF Field_int='Y' 						THEN DO; Field_Format=' Integer not null';  SAS_Format="8.0"; END;
IF Field_int='' AND Field_txt='N' 		THEN DO; Field_Format=' Dec('||PUT(Field_num_width,$2.)||','||PUT(Field_val_dec,$1.)||')'; SAS_Format=COMPRESS(PUT(Field_num_width,$2.)||'.'||PUT(Field_val_dec,$1.)); END;
IF Field_txt='Y'						THEN DO; Field_format=' Char('||PUT(Field_width,$3.)||')'; SAS_Format=COMPRESS(' $'||PUT(Field_width,$3.)||'.'); END;
FieldName=tranwrd(FieldName,"Flashpoint_'C",'Flashpoint');
FieldName=tranwrd(FieldName,"ADR-IMDG",'ADR_IMDG');
FieldName=tranwrd(FieldName,'Department_Responsible_for_Collecting_Handling_Was','Dep_Resp_Coll_Handl_Was');
FieldName=tranwrd(FieldName,"Naam-dimset_mengsel_stof_BAAN",'Dimset_BAAN');
FieldName=tranwrd(FieldName,"Naam-artikelnummer_mengsel_stof_BAAN",'Artikel_BAAN');
RUN;

/*****************************  Corrective var_field formats *****************************/ 
Data work.Var_fields; set work.Var_fields;
if FieldName="Hazard_Sentences_Label" 		THEN SAS_Format="$50.";
if FieldName="Msds" 						THEN SAS_Format="$2000.";
if FieldName="Precaution_Sentences_Label" 	THEN SAS_Format="$50.";
run;


/***********************Concatenate multiple rows into a single value***********************************************/

data work.test1;
set work.idataprd1;
WHERE Field_name ="ADR_Labels";
RUN;

data work.test;
length cat $200.;
   do until (last.Recordnr);
      set work.test1;
        by Recordnr notsorted;
      cat=catx('|',cat,Value_txt);
   end;
   drop Value_txt;
run;
data work.test2;
set work.test;
format Value_txt $200.;
rename cat =Value_txt;
RUN;


DATA work.iDataPRD2;
Set work.iDataPRD1;
If Field_name ="ADR_Labels" then delete;
Run;

PROC SORT data=work.test2; BY Recordnr Field_name;
RUN;
PROC SORT data=work.iDataPRD2; BY Recordnr Field_name;
RUN;
DATA work.iDataPRD1 ;
MERGE work.iDataPRD2 work.test2;
BY Recordnr Field_name ;
RUN;

/***********************Concatenate multiple rows into a single value***********************************************/

data work.test1;
set work.idataprd1;
WHERE Field_name ="Hazard_Sentences_Label";
RUN;

data work.test;
length cat $200.;
   do until (last.Recordnr);
      set work.test1;
        by Recordnr notsorted;
      cat=catx('|',cat,Value_txt);
   end;
   drop Value_txt;
run;
data work.test2;
set work.test;
format Value_txt $200.;
rename cat =Value_txt;
RUN;


DATA work.iDataPRD2;
Set work.iDataPRD1;
If Field_name ="Hazard_Sentences_Label" then delete;
Run;

PROC SORT data=work.test2; 		BY Recordnr Field_name; RUN;
PROC SORT data=work.iDataPRD2; 	BY Recordnr Field_name;	RUN;
DATA work.iDataPRD1 ;
MERGE work.iDataPRD2 work.test2;
BY Recordnr Field_name ;
RUN;


/***********************Concatenate multiple rows into a single value***********************************************/

data work.test1;
set work.idataprd1;
WHERE Field_name ="Msds";
RUN;

data work.test;
length cat $200.;
   do until (last.Recordnr);
      set work.test1;
        by Recordnr notsorted;
      cat=catx('|',cat,fldSearchValue);
   end;
   drop Value_txt;
run;
data work.test2;
set work.test;
format Value_txt $200.;
rename cat =Value_txt;
RUN;


DATA work.iDataPRD2;
Set work.iDataPRD1;
If Field_name ="Msds" then delete;
Run;

PROC SORT data=work.test2; 		BY Recordnr Field_name;
RUN;
PROC SORT data=work.iDataPRD2; 	BY Recordnr Field_name;
RUN;
DATA work.iDataPRD1 ;
MERGE work.iDataPRD2 work.test2;
BY Recordnr Field_name ;
RUN;

/***********************Concatenate multiple rows into a single value***********************************************/

data work.test1;
set work.idataprd1;
WHERE Field_name ="Precaution_Sentences_Label";
RUN;

data work.test;
length cat $200.;
   do until (last.Recordnr);
      set work.test1;
        by Recordnr notsorted;
      cat=catx('|',cat,Value_txt);
   end;
   drop Value_txt;
run;
data work.test2;
set work.test;
format Value_txt $200.;
rename cat =Value_txt;
RUN;


DATA work.iDataPRD2;
Set work.iDataPRD1;
If Field_name ="Precaution_Sentences_Label" then delete;
Run;

PROC SORT data=work.test2; 		BY Recordnr Field_name; RUN;
PROC SORT data=work.iDataPRD2; 	BY Recordnr Field_name; RUN;
DATA work.iDataPRD1 ;
MERGE work.iDataPRD2 work.test2;
BY Recordnr Field_name ;
RUN;



%macro CreateTableNum(tableName, varname, formatnum);
DATA work.table_num (keep=RecordNr &varname) ; SET work.iDataPRD1;
FORMAT &varname &formatnum; &varname=Value_num;
WHERE Table_name="&TableName" AND Field_name="&varname";
RUN;

PROC SORT data=work.table_num; BY RecordNr; RUN;
DATA work.&TableName;
MERGE work.&TableName work.table_num;
BY RecordNr;
RUN;
%mend;

%macro CreateTabletxt(tableName, varname, formattxt);
DATA work.table_txt (keep=RecordNr &varname) ; SET work.iDataPRD1;
FORMAT &varname &formattxt; &varname=Value_txt;
WHERE Table_name="&TableName" AND Field_name="&varname";
RUN;

PROC SORT data=work.table_txt; BY RecordNr; RUN;
DATA work.&TableName;
MERGE work.&TableName work.table_txt;
BY RecordNr;
RUN;
%mend;

%macro CreateTable(tableName);
PROC SQL;
CREATE TABLE work.&TableName AS
SELECT 	RecordNr, COUNT(RecordNr) AS Count
FROM work.iDataPRD1 
WHERE Table_name="&tableName"
GROUP BY RecordNr;
QUIT;

DATA work.var_fields1; SET work.var_fields;
IF Field_txt='Y' THEN CALL EXECUTE('%CreateTabletxt('||TableName||','||FieldName||','||SAS_Format||')'); 
				 ELSE CALL EXECUTE('%CreateTablenum('||TableName||','||FieldName||','||SAS_Format||')'); 
where TableName="&TableName";
RUN;

%mend;

DATA work.tables1; SET work.tables;
CALL EXECUTE('%CreateTable('||Table_name||')');
RUN;

/* HSE ADR-IMDG kaartenbak */
PROC SORT data=work.Hse_adr_imdg ; by RecordNr; RUN;
DATA work.Hse_adr_imdg ; Set work.Hse_adr_imdg;
by RecordNr;
if not first.RecordNr then delete;
RUN;



DATA work.tbdObjectDisplayName; SET idataprd.tbdObjectDisplayName;
Format recordNr $6.;
recordNr=compress(put(fldObjectID,$6.));
RUN;


PROC SQL;
CREATE TABLE work.Hse_adr_imdg AS
SELECT  a.*,
		b.fldDisplayName AS Display_Name
FROM  	work.Hse_adr_imdg a,
		work.tbdObjectDisplayName b
WHERE  b.fldLanguage="nl-NL" AND a.RecordNr=b.recordNr;
QUIT;


/* HSE MIXTURE kaartenbak */

DATA work.Hse_mixture_substance;
SET work.Hse_mixture_substance;
WHERE Euravib_import="Ja";
RUN;


PROC SQL;
CREATE TABLE work.tijdelijke_tabel AS
SELECT  a.RecordNr,
		PUT(a.H_Cat,$200.)			AS H_Cat1					 LABEL='H_Cat1',
		a.Hazard_Sentences_Label	AS Hazard_Sentences_Label1   LABEL='Hazard_Sentences_Label1',
		COUNT(a.RecordNr)           AS Check					 LABEL='Check'
FROM  	work.Hse_mixture_substance a
GROUP BY a.RecordNr;
QUIT;

%macro repeat(n);
   %do i=1 %to &n.;
DATA work.tijdelijke_tabel;
SET work.tijdelijke_tabel;
Index=Index(Hazard_Sentences_Label1, "|");
H_Nr1=substr(Hazard_Sentences_Label1,1, Index-1);
IF Index>0 THEN Hazard_Sentences_Label1=Substr(Hazard_Sentences_Label1, Index+1); ELSE Hazard_Sentences_Label1=Hazard_Sentences_Label1;
RUN;
PROC SORT DATA=work.tijdelijke_tabel; BY RecordNr H_Cat1 Hazard_Sentences_Label1 Check; RUN;
PROC TRANSPOSE DATA=tijdelijke_tabel OUT=tijdelijke_tabel;
BY RecordNr H_Cat1 Hazard_Sentences_Label1 Check;
VAR Hazard_Sentences_Label1 H_Nr1;
RUN;
DATA work.tijdelijke_tabel (DROP= _NAME_ _LABEL_ COL1) ;
SET work.tijdelijke_tabel;
Hazard_Sentences_Label1=COL1;
RUN;
PROC SORT DATA=work.tijdelijke_tabel nodupkey; BY RecordNr H_Cat1 Hazard_Sentences_Label1 Check; RUN;
%END;
%mend repeat;

%repeat(6);


DATA work.waarschuwingsmail_Mixt_Subst;
SET work.tijdelijke_tabel;
IF Index(Hazard_Sentences_Label1, '|') > 0 THEN COUNT=1;
RUN;

%macro Count_reference_H_Nr;
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="dverbert@euramax.eu"			
SUBJECT="**** Hoger aantal H_Nr's per kaart kaartenbak Mixture Substance toegevoegd ****" CONTENT_TYPE="text/html";
Title "Script Euravib_new aanpassen (repeat ophogen)";
ODS LISTING CLOSE; ODS HTML BODY=mail;
PROC PRINT DATA=work.waarschuwingsmail_Mixt_Subst  noobs; RUN;
ODS HTML CLOSE; ODS LISTING; 
%mend;

DATA work.waarschuwingsmail_Mixt_Subst1; SET work.waarschuwingsmail_Mixt_Subst;
CALL EXECUTE('%Count_reference_H_Nr');
WHERE COUNT  > 0;
RUN;

PROC SQL;
CREATE TABLE work.tijdelijke_tabel AS
SELECT  a.*,
        b.H_Category_Short,
		Count(a.Hazard_Sentences_Label1) AS COUNT LABEL='COUNT'
FROM  	work.tijdelijke_tabel a             LEFT OUTER JOIN Db2eura.Euravib_h_info b ON a.Hazard_Sentences_Label1=b.H_Nr
GROUP BY RecordNr, Hazard_Sentences_Label1 
ORDER BY a.RecordNr, a.Hazard_Sentences_Label1;
QUIT;
PROC SORT DATA=tijdelijke_tabel; BY RecordNr Hazard_Sentences_Label1 H_Category_Short; RUN;


DATA work.tijdelijke_tabel (DROP=Check Count Check1 H_Category_Short); 
SET work.tijdelijke_tabel;
IF CHECK>1 AND H_Cat1 = H_Category_Short 	THEN Check1=1;
IF CHECK>1 AND COUNT=2						THEN Check1=1;
IF CHECK>1 AND Check1 NE 1					THEN DELETE;
IF CHECK>1 AND H_Cat1 NE H_Category_Short	THEN H_Cat1=H_Category_Short;
IF H_Cat1='' 								THEN H_Cat1=H_Category_Short;
IF H_Cat1 NE H_Category_Short AND COUNT=1 	THEN H_Cat1=H_Category_Short;
IF H_Cat1 NE H_Category_Short AND COUNT>1	THEN DELETE;
RUN;
PROC SORT DATA=tijdelijke_tabel NODUP; BY RecordNr Hazard_Sentences_Label1; RUN; 

PROC TRANSPOSE DATA=work.tijdelijke_tabel OUT=work.tijdelijke_tabel;
BY RecordNr;
VAR H_Cat1 Hazard_Sentences_Label1;
RUN;

DATA work.tijdelijke_tabel (KEEP=RecordNr CONCAT);
SET work.tijdelijke_tabel;
FORMAT CONCAT $200.;
CONCAT=CATX("|",COL1,COL2,COL3,COL4,COL5,COL6,COL7);
RUN;

PROC TRANSPOSE DATA=work.tijdelijke_tabel OUT=work.tijdelijke_tabel;
BY RecordNr;
VAR CONCAT;
RUN;

DATA work.tijdelijke_tabel (KEEP=RecordNr H_CAT1 Hazard_Sentences_Label1);
SET work.tijdelijke_tabel;
RENAME COL1=H_CAT1;
RENAME COL2=Hazard_Sentences_Label1;
RUN;

PROC SORT data=work.Hse_mixture_substance ; by RecordNr; RUN;
DATA work.Hse_mixture_substance (drop=Length_Data UN_Number ADR_Classes ADR_Packaging_Group ADR_Labels) ; Set work.Hse_mixture_substance;
by RecordNr;
if not first.RecordNr then delete;
/*Length_Data=LENGTH(ADR_DATA)-4;*/
/*ADR_DATA=substr(ADR_DATA,1,Length_Data);*/
RUN;

PROC SQL;
CREATE TABLE work.Hse_mixture_substance AS
SELECT  a.*,
        b.H_Cat1,
		b.Hazard_Sentences_Label1
FROM  	work.Hse_mixture_substance a             LEFT OUTER JOIN work.tijdelijke_tabel b ON a.RecordNr=b.RecordNr
ORDER BY a.RecordNr;
QUIT;

DATA work.Hse_mixture_substance (DROP=H_Cat Hazard_Sentences_Label);
SET work.Hse_mixture_substance;
RUN;

DATA work.Hse_mixture_substance;
SET work.Hse_mixture_substance;
RENAME H_CAT1=H_CAT;
RENAME Hazard_Sentences_Label1=Hazard_Sentences_Label;
RUN;

/* ADR Data: UN Number ADR Classes: ADR Packaging Group: ADR Labels:
 weergavenaam UN_NR		ADR_Klasse 	ADR_PACKAGING_GROUP  ADR_Etiketten
*/
Proc SQL;;
Create Table work.Hse_mixture_substance AS
select 
	a.*,
	b.UN_NR 		AS UN_Number ,
	b.CARGO_NAME    AS CARGO_Name,
	b.ADR_Klasse 	AS ADR_Classes,	
	b.ADR_PACKAGING_GROUP,  
	b.ADR_Etiketten AS ADR_Labels,
	b.Tunnelcode
from Hse_mixture_substance a Left JOIN Hse_adr_imdg b on  a.ADR_Data=b.Display_Name;
quit;


DATA work.tbdObjectDisplayName; SET idataprd.tbdObjectDisplayName;
Format recordNr $6.;
recordNr=compress(put(fldObjectID,$6.));
RUN;


PROC SQL;
CREATE TABLE work.Hse_mixture_substance AS
SELECT  a.*,
		b.fldDisplayName AS Display_Name
FROM  	work.Hse_mixture_substance a,
		work.tbdObjectDisplayName b
WHERE  b.fldLanguage="nl-NL" AND a.RecordNr=b.recordNr;
QUIT;
/*****************************  Cas_Nr maker *****************************/ 
data work.Hse_mixture_substance
(Drop=indexc_result rev_indexc_result);
set work.Hse_mixture_substance;                                                                                                                             
/* Substance1  */
indexc_result= indexc(substance1,'1234567890'); 
if indexc_result=1 THEN  rev_indexc_result= (indexc(substance1,'qwertyuiopasdfghjklzxcvbnm'))-2;
ELSE rev_indexc_result= indexc(reverse(substance1),'qwertyuiopasdfghjklzxcvbnm'); 
substance1=substr(substance1,indexc_result,rev_indexc_result);
/* Substance2  */
indexc_result= indexc(substance2,'1234567890'); 
if indexc_result=1 THEN  rev_indexc_result= (indexc(substance2,'qwertyuiopasdfghjklzxcvbnm'))-2;
ELSE rev_indexc_result= indexc(reverse(substance2),'qwertyuiopasdfghjklzxcvbnm'); 
substance2=substr(substance2,indexc_result,rev_indexc_result);
/* Substance3  */
indexc_result= indexc(substance3,'1234567890'); 
if indexc_result=1 THEN  rev_indexc_result= (indexc(substance3,'qwertyuiopasdfghjklzxcvbnm'))-2;
ELSE rev_indexc_result= indexc(reverse(substance3),'qwertyuiopasdfghjklzxcvbnm'); 
substance3=substr(substance3,indexc_result,rev_indexc_result);
run;

/*****************************  Corrective Format table *****************************/ 
Data work.Hse_mixture_substance1 
(Drop=Substance1 Substance2 Substance3 Percentage1 Percentage2 Percentage3 recordnr count Msds Name
Precaution_Sentences_Label Signal_Word Supplier_Name_Address_Phone Revision_Date Display_Name ph Content_Packaging);
set work.Hse_mixture_substance;
FORMAT Name2 $50.;
FORMAT REV_DATE DATE9.;
Format ENTRY_DATE Date9.;
Format CAS_NR $2000.;
Format CAS_PERC $100.;
entry_date=Date();
CAS_NR=CATX("|", Substance1 , Substance2,Substance3);
CAS_PERC=CATX("|", Percentage1, Percentage2,Percentage3);
REV_DATE=Revision_Date;
IF Substr(Msds,1,24)="Verwijzing naar document" THEN Suppl_Nr=Substr(Msds,27,6); ELSE Suppl_Nr=Substr(Msds,1,5);
IF Substr(Msds,1,24)="Verwijzing naar document" THEN Name2=Substr(Msds,33,index(Msds,"'.")-33);	ELSE Name2=Substr(Msds,7);
/*Suppl_Nr=Substr(Msds,27,6);*/
Run;



/*alle kolommen hernoemen*/
DATA Hse_mixture_substance1
(DROP=ADR_Classes ADR_LABELS ADR_Packaging_Group Flashpoint__C Hazard_sentences_label H_Cat
Name UN_NumbeR REV_DATE ENTRY_DATE CAS_NR CAS_PERC suppl_nr CARGO_Name);
set Hse_mixture_substance1;
ADR_Classes1=ADR_Classes;
ADR_LABELS1=ADR_LABELS;
ADR_Packaging_Group1=ADR_Packaging_Group;
Flashpoint1=Flashpoint__C;
Hazard_sentences_label1=Hazard_sentences_label;
H_Cat1=H_Cat;
Name1=Name2;
FORMAT UN_NumbeR1 $10.;
UN_NumbeR1=UN_NumbeR;
CARGO_Name1=CARGO_Name;
REV_DATE1=REV_DATE;
ENTRY_DATE1=ENTRY_DATE;
CAS_NR1=CAS_NR;   
CAS_PERC1=CAS_PERC;
suppl_nr1=suppl_nr;
Run;

/*nieuwe tabel*/
DATA work.refTable
(DROP=ADR_Classes1 ADR_LABELS1 ADR_Packaging_Group1 Flashpoint1 Hazard_sentences_label1 H_Cat1
Name1 UN_NumbeR1 REV_DATE1 ENTRY_DATE1 CAS_NR1 CAS_PERC1 suppl_nr1 ADR_DATA Tunnelcode CARGO_Name1);
set Hse_mixture_substance1;
SUPPL_NR=Suppl_nr1;
DIMSET=Name1;
ENTRY_DATE=ENTRY_DATE1;
REV_DATE=REV_DATE1;
CAS_NR=CAS_NR1;
CAS_PERC=CAS_PERC1;
H_NR = Hazard_sentences_label1;
H_CAT=H_Cat1;
ADR_UN_NR=UN_NumbeR1;
ADR_CARGO_NAME=CARGO_Name1;
/*ADR_CARGO_NAME="";*/
ADR_TRANSPORTHAZARD_CLASS=ADR_Classes1;
ADR_PACKING_GROUP=ADR_Packaging_Group1;
ADR_ENVIRONMENT_HAZARDS="";
ADR_EXTRAINFO=ADR_LABELS1;
IMDG_UN_NR="";
IMDG_CARGO_NAME="";
IMDG_TRANSPORTHAZARD_CLASS="";
IMDG_PACKING_GROUP="";
IMDG_ENVIRONMENT_HAZARDS="";
IMDG_EXTRAINFO="";
EXTRAINFO_TUNNELCODE=Tunnelcode;
FLASHPOINT=Flashpoint1;
EMS_FIRE="";
EMS_SPILLAGE="";
USER="SAS";
EG_NR="-";
FORMAT REV_DATE DATE9.;
Format ENTRY_DATE Date9.;
Format CAS_NR $2000.;
Format CAS_PERC $100.;
Run;



/* MERGE */
Proc SQL;
Create Table work.Euravib_import AS
select 
a.Suppl_nr,
a.Dimset,
a.Entry_Date,
a.Rev_Date,
a.Cas_nr,
a.Cas_Perc,
a.H_Nr,
a.H_Cat,
a.ADR_UN_NR,
a.ADR_CARGO_Name,
a.ADR_TransportHazard_Class,
a.ADR_Packing_Group,
a.ADR_Environment_Hazards,
a.ADR_EXTRAINFO,
a.IMDG_UN_NR,
a.IMDG_CARGO_NAME,
a.IMDG_TRANSPORTHAZARD_CLASS,
a.IMDG_PACKING_GROUP,
a.IMDG_ENVIRONMENT_HAZARDS,
a.IMDG_PACKING_GROUP,
a.IMDG_ENVIRONMENT_HAZARDS,
a.IMDG_EXTRAINFO,
a.EXTRAINFO_TUNNELCODE,
a.FLASHPOINT,
a.EMS_FIRE,
a.EMS_SPILLAGE,
a.USER,
a.EG_NR from db2eura.Euravib_dovetail_import a
UNION ALL
select 
b.Suppl_nr,
b.Dimset,
b.Entry_Date,
b.Rev_Date,
b.Cas_nr,
b.Cas_Perc,
b.H_Nr,
b.H_Cat,
b.ADR_UN_NR,
b.ADR_CARGO_Name,
b.ADR_TransportHazard_Class,
b.ADR_Packing_Group,
b.ADR_Environment_Hazards,
b.ADR_EXTRAINFO,
b.IMDG_UN_NR,
b.IMDG_CARGO_NAME,
b.IMDG_TRANSPORTHAZARD_CLASS,
b.IMDG_PACKING_GROUP,
b.IMDG_ENVIRONMENT_HAZARDS,
b.IMDG_PACKING_GROUP,
b.IMDG_ENVIRONMENT_HAZARDS,
b.IMDG_EXTRAINFO,
b.EXTRAINFO_TUNNELCODE,
b.FLASHPOINT,
b.EMS_FIRE,
b.EMS_SPILLAGE,
b.USER,
b.EG_NR
from work.refTable b;
quit;

Data work.Euravib_import1
(Drop=indexc_result rev_indexc_result Flashpoint_Tus);
Set work.Euravib_import;
/* Cas_Perc */
CAS_PERC=tranwrd(CAS_PERC,'.',',');/* alle commas in Cas_Perc worden punten door tranwrd */
CAS_PERC=Translate (Trim(CAS_PERC)," ",'%');
CAS_PERC=compress(CAS_PERC);/* Geeft geen spaties weer of andere witruimte */


/* ADR_UN_NR */
if ADR_UN_NR="Niet van toepassing" 		THEN ADR_UN_NR="ADR Vrij" ;
if ADR_UN_NR="Niet" 					THEN ADR_UN_NR="ADR Vrij" ;
if ADR_UN_NR="Niet gereglementeerd." 	THEN ADR_UN_NR="ADR Vrij" ;
if ADR_UN_NR="Not regulated." 			THEN ADR_UN_NR="ADR Vrij" ;
if ADR_UN_NR="niet van toepassing" 		THEN ADR_UN_NR="ADR Vrij" ;
if ADR_UN_NR="UN" 						THEN ADR_UN_NR="ADR Vrij" ;
if ADR_UN_NR="Void" 					THEN ADR_UN_NR="ADR Vrij" ;
if ADR_UN_NR="vervalt" 					THEN ADR_UN_NR="ADR Vrij" ;

/* De velden die ook ADR Vrij moeten worden als de UN_NR ADR Vrij is */
if ADR_UN_NR="ADR Vrij" THEN ADR_CARGO_NAME="ADR Vrij";
if ADR_UN_NR="ADR Vrij" THEN ADR_TRANSPORTHAZARD_CLASS="ADR Vrij";
if ADR_UN_NR="ADR Vrij" THEN ADR_PACKING_GROUP="ADR Vrij";
if ADR_UN_NR="ADR Vrij" THEN EXTRAINFO_TUNNELCODE="(-)";

/* VN OF UN ERAf halen */
indexc_result= indexc(ADR_UN_NR,'1234567890'); 
if indexc_result=1 																														THEN  rev_indexc_result= (indexc(ADR_UN_NR,'123456790'))-2;
ELSE rev_indexc_result= indexc(reverse(ADR_UN_NR),'1234567890'); 
ADR_UN_NR=substr(ADR_UN_NR,indexc_result,rev_indexc_result);
if ADR_CARGO_NAME="ADR Vrij" AND ADR_TRANSPORTHAZARD_CLASS="ADR Vrij" AND ADR_PACKING_GROUP="ADR Vrij" AND  EXTRAINFO_TUNNELCODE="(-)" 	THEN ADR_UN_NR="ADR Vrij" ;

/*Cas_NR*/
CAS_NR=compress(CAS_NR);/* Geeft geen spaties weer of andere witruimte */

/* H_NR */
H_NR=UPCASE(H_NR);/*Zorgt ervoor dat alle h's HGoofdletters zijn. */
H_NR=compress(H_NR);/* Geeft geen spaties weer of andere witruimte */

/* ADR_TRansportHazard_Class & ADR_Packing_Group*/
IF ADR_UN_NR="1263" AND ADR_Packing_Group='vervalt' THEN ADR_TRANSPORTHAZARD_CLASS="ADR Vrij";
IF ADR_UN_NR="1263" AND ADR_Packing_Group='vervalt' THEN ADR_Packing_Group="ADR Vrij";
IF Dimset IN ('00N3477.70','00N3511.70') 			THEN ADR_Packing_Group='III'; 


/* Flashpoint alleen - > of getal in kolom */
indexc_result= indexc(FLASHPOINT,'->1234567890'); /* zoekt in de tekst naar de eerst betreffende teken en onthoudt de positie */
if indexc_result=1 THEN  rev_indexc_result= (indexc(FLASHPOINT,'123456790'))-2;
ELSE rev_indexc_result= indexc(reverse(FLASHPOINT),'1234567890'); 
Flashpoint_Tus=substr(FLASHPOINT,indexc_result,rev_indexc_result);

indexc_result= indexc(Flashpoint_Tus,'->1234567890'); /* zoekt in de tekst naar de eerst betreffende teken en onthoudt de positie */
if indexc_result=1 THEN  rev_indexc_result= (indexc(Flashpoint_Tus,'C'));
ELSE rev_indexc_result= indexc(reverse(Flashpoint_Tus),'C'); 
FLASHPOINT=substr(Flashpoint_Tus,indexc_result,rev_indexc_result);

FLASHPOINT=tranwrd(FLASHPOINT,',','.');/* alle commas in Flashpoint worden punten door tranwrd */
RUN;

PROC SQL;
CREATE TABLE work.Euravib_Import_00110 AS
SELECT a.*
FROM work.Euravib_import1 a
WHERE compress(a.suppl_nr)='00110';
RUN;

DATA work.Euravib_Import_00110; SET work.Euravib_Import_00110;
Suppl_Nr='00111';
RUN;

PROC SQL;
CREATE TABLE work.Euravib_Import_00111 AS
SELECT a.*
FROM work.Euravib_import1 a
WHERE compress(a.suppl_nr)='00111';
RUN;

DATA work.Euravib_Import_00111; SET work.Euravib_Import_00111;
Suppl_Nr='00110';
RUN;

PROC APPEND base=Euravib_import1 data=work.Euravib_Import_00111; RUN;
PROC APPEND base=Euravib_import1 data=work.Euravib_Import_00110; RUN;

PROC SORT data=Euravib_import1 nodupkey; BY SUPPL_NR dimset entry_date rev_Date; RUN;

DATA work.Euravib_import1; SET work.Euravib_import1;
IF INDEX(CAS_NR,'| ')>0 AND COUNTC(CAS_NR,'|')=COUNTC(EG_NR,'|') THEN CAS_NR=compress(CAS_NR||'NoCasNr');
RUN;

/*Aanvulling H_nr - H_Cat kankerverwekkende stoffen*/

DATA work.CASnummers;
INPUT CAS_Nr $9. +1 H_Nr $6. +1 H_Cat $8. +1 caspercentage_max $3. ;
CARDS;
98-82-8   H350c  Carc. 1B 0.1
64-17-5   H350e  Carc. 1A 0.1 
1330-20-7 H361Dx Repr. 2  3.0
108-88-3  H361Dx Repr. 2  3.0
; 
RUN;

%macro Update(CAS_nr,H_Nr,H_Cat, caspercentage_max); 

DATA work.Euravib_import1;
SET work.Euravib_import1;
test=index(Cas_nr, CAT("|","&CAS_nr"));
IF test>0 THEN test_1=COUNTC(Substr(Cas_nr, 1, test),'|'); ELSE test_1=0;
IF test>0 THEN Check=1; ELSE Check=0;
RUN;

DATA work.Euravib_import1 (DROP=test test_1 i);
SET work.Euravib_import1;
p = 0;
   do i=1 to test_1 until(p=0); 
      p = find(Cas_perc, '|', p+1);
   end;
RUN;

DATA work.Euravib_import1 (DROP= p test_1_1);
SET work.Euravib_import1;
IF Check>0 THEN test_1_1=index(Substr(Cas_perc,p+1),'|');
IF Check>0 THEN Cas_percentage=Substr(Cas_perc,P+1,test_1_1-1);
RUN;

DATA work.Euravib_import1 ; SET work.Euravib_import1;
caspercentage=Translate(trim(Cas_percentage),'    ','_=><');
RUN;

DATA work.Euravib_import1 ; SET work.Euravib_import1;
caspercentage_min=scan(caspercentage,+1,'-','m');
RUN;

DATA work.Euravib_import1 ; SET work.Euravib_import1;
caspercentage_max=scan(caspercentage,-1,'-','m');
RUN;

DATA work.Euravib_import1 ; SET work.Euravib_import1;
caspercentage_min=compress(caspercentage_min);
caspercentage_max=compress(caspercentage_max);
RUN;

DATA work.Euravib_import1; SET work.Euravib_import1;
caspercentage_min=Translate(trim(caspercentage_min),'.',",");
caspercentage_max=Translate(trim(caspercentage_max),'.',",");
RUN;

DATA work.Euravib_import1; SET work.Euravib_import1;
IF caspercentage_max >= &caspercentage_max THEN H_Nr_1="&H_Nr";
IF caspercentage_max >= &caspercentage_max THEN H_Cat_1="&H_Cat";
RUN;


DATA work.Euravib_import1 (DROP=Check Cas_percentage caspercentage caspercentage_min caspercentage_max H_Nr_1 H_Cat_1) ;
SET work.Euravib_import1;
H_Nr=CATX('|',H_Nr,H_Nr_1);
H_CAT=CATX('|',H_Cat,H_Cat_1);
RUN;

%mend Update;

DATA WORK.Update1; SET WORK.CASnummers; CALL EXECUTE('%Update('||CAS_Nr||','||H_Nr||','||H_CAT||','||caspercentage_max||')');  RUN; 

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DROP TABLE euravib.Euravib_Import ) by baan;
QUIT;  

PROC APPEND base=db2eura.Euravib_import  (BULKLOAD=YES)  data=work.Euravib_import1 FORCE;	RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Import TO USER INFODBC )  by baan;
EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Import TO USER FINODBC )  by baan;
QUIT;  




/**********************************************************************/
/****    Update Euravib Key Data							       ****/
/**********************************************************************/
PROC IMPORT OUT= work.Euravib_H_Info 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="H.Info$B1:R1000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_P_Sentence 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="P.Sentence$A1:C10000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_H_Sentence 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="H.Sentence$A1:D10000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_SignalWord 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="SignalWord$A1:B100"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_H_P_Rel 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="H_P.Rel$A1:D1000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_Cas_H_Rel 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Cas_H_Ref$A1:E1000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_Cas_Ref 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Cas_Info$A1:AV5000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_Specials 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Specials$A1:AB5000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= Work.Euravib_candidate
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Candidate List.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Sheet1$A1:G500"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_CMR_prop
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSx REPLACE;
     RANGE="susp_CMR_prop$A1:D5000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_Add_Assessm
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSx REPLACE;
     RANGE="Add_assessm$A1:X5000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_Follow_Up
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Follow_up_production$A1:B1000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= work.Euravib_Lab_codes
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\SAS IMPORTS\Euravib_data.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Lab_codes$A1:C1000"; 
     GETNAMES=YES;
RUN;

DATA work.Euravib_Cas_H_Rel; SET work.Euravib_Cas_H_Rel;
Cas_nr=scan(cas_nr,1,'.');
RUN; 

DATA work.Euravib_Follow_Up; SET work.Euravib_Follow_Up;
Follow_up='Y';
Suppl_nr1=""||Suppl_nr;
RUN;

DATA work.Euravib_Cas_Ref(Drop=Val_Date); SET work.Euravib_Cas_Ref;
FORMAT Val_Date1 Date9.;
Val_Date1=Val_date;
/*Cas_nr=scan(cas_nr,1,'.');*/
RUN; 

DATA work.Euravib_Cas_Ref(Drop=Val_Date1); SET work.Euravib_Cas_Ref;
FORMAT Val_Date Date9.;
Val_Date=Val_date1;
RUN; 

PROC SORT data=work.Euravib_Cas_Ref; by cas_nr; RUN;
DATA work.Euravib_Cas_Ref; SET work.Euravib_Cas_Ref;
by cas_nr;
IF not first.cas_nr THEN DELETE;
RUN;

DATA work.Euravib_Specials; 	LENGTH Dimset $50.; SET work.Euravib_Specials; 									FORMAT Dimset $50.; INFORMAT Dimset $50.;  RUN;
DATA work.Euravib_CMR_prop1; 						SET work.Euravib_CMR_prop; Suppl_nr1=" "||Suppl_nr; RUN;
DATA work.Euravib_Specials1; 	LENGTH Dimset $50.; SET work.Euravib_Specials; Suppl_nr1=" "||Supplier_Number; 	FORMAT Dimset $50.; INFORMAT Dimset $50.; WHERE LENGTH(Code)>5; RUN;

DATA work.Euravib_Specials1(DROP= Aanvullende_maatregelen_bij_grot); SET work.Euravib_Specials1;
Aanvullende_Maatregelen=Aanvullende_maatregelen_bij_grot;
RUN;


/* SPECIALS STOCK */

libname iDocP ODBC  dsn='iProvaPrd' schema=iDocument user=odbc password=ODBC;

/* wachten tot stock velden beschikbaar zijn */
/* name > tbdDocumentVersion;(fldtitle), fldDocumentVersionID > tbdMetaFieldValue; (fldDocumentVersionID), fldValue.. fldMetaFieldID > tbdMetaFieldName; fldName */ 

PROC SQL;
CREATE TABLE work.Euravib_Specials1 AS
SELECT  a.*,
		b.Hoeveelheid_in_kg
FROM work.Euravib_Specials1 a
LEFT OUTER JOIN work.hse_stock_cabinets b ON a.name=b.Naam_indien_niet_in_BAAN;
QUIT;

DATA work.Euravib_Specials1; SET work.Euravib_Specials1;
IF Hoeveelheid_in_kg>0 AND Stock_kg <=0 THEN Stock_kg=Hoeveelheid_in_kg;
RUN;

/* SPECIALS STOCK */


DATA work.Euravib_H_P_Rel ; SET work.Euravib_H_P_Rel;
FORMAT H_Ref $25.; H_Ref=TRIM(H_nr)||'-';
IF INDEX(Category_short,'1')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(Category_short,INDEX(Category_short,'1'),2));
IF INDEX(Category_short,'2')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(Category_short,INDEX(Category_short,'2'),2));
IF INDEX(Category_short,'3')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(Category_short,INDEX(Category_short,'3'),2));
IF INDEX(Category_short,'4')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(Category_short,INDEX(Category_short,'4'),2));
IF H_Nr="H280"		  		   THEN H_Ref=TRIM(H_nr)||'-'||TRIM(Category_short);
RUN;

DATA work.Euravib_Cas_H_Rel; SET work.Euravib_Cas_H_Rel;
FORMAT H_Ref $25.; H_Ref=TRIM(H_nr)||'-';
IF INDEX(H_Category_short,'1')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Category_short,INDEX(H_Category_short,'1'),2));
IF INDEX(H_Category_short,'2')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Category_short,INDEX(H_Category_short,'2'),2));
IF INDEX(H_Category_short,'3')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Category_short,INDEX(H_Category_short,'3'),2));
IF INDEX(H_Category_short,'4')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Category_short,INDEX(H_Category_short,'4'),2));
IF H_Nr="H280"		  			 THEN H_Ref=TRIM(H_nr)||'-'||TRIM(H_Category_short);
RUN;

DATA work.Euravib_H_Info; SET work.Euravib_H_Info;
FORMAT H_Ref $25.; H_Ref=TRIM(H_nr)||'-';
IF INDEX(H_Category_short,'1')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Category_short,INDEX(H_Category_short,'1'),2));
IF INDEX(H_Category_short,'2')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Category_short,INDEX(H_Category_short,'2'),2));
IF INDEX(H_Category_short,'3')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Category_short,INDEX(H_Category_short,'3'),2));
IF INDEX(H_Category_short,'4')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Category_short,INDEX(H_Category_short,'4'),2));
IF H_Nr="H280"		  			 THEN H_Ref=TRIM(H_nr)||'-'||TRIM(H_Category_short);
RUN;

PROC SQL;
CREATE TABLE work.Euravib_H_Info AS
SELECT 	a.*, 
		CASE 
		WHEN a.Class_Code='C'  THEN 	'C'
		WHEN a.Class_Code='c'  THEN 	'c'  END   	AS CMR_C,
		CASE 
		WHEN a.Class_Code='M'  THEN 	'M'
		WHEN a.Class_Code='m'  THEN 	'm'  END   	AS CMR_M,
		CASE 
		WHEN a.Class_Code='R'  THEN 	'R'
		WHEN a.Class_Code='r'  THEN 	'r'  END   	AS CMR_R
FROM work.Euravib_H_Info a;
QUIT;

DATA work.Euravib_Cas_H_Rel; SET work.Euravib_Cas_H_Rel;
IF H_Nr IN ('H340','H350','H350i','H360D','H360F','H341','H351') 	THEN DO LEG_IED_UKperm='Y'; END;
IF LEG_IED_UKperm="" 												THEN DO LEG_IED_UKperm='N'; END;
RUN;

PROC SQL;
CREATE TABLE work.Cas_Leg_IED AS
SELECT  a.Cas_nr,
		CASE WHEN COUNT(a.H_ref)>0 THEN 'Y' ELSE 'N' END  AS CAS_LEG_IED_UKperm
FROM work.Euravib_Cas_H_Rel a
WHERE a.LEG_IED_UKperm='Y'
GROUP BY a.Cas_nr;
QUIT;  

PROC SQL;
CREATE TABLE work.Euravib_Cas_Ref AS 
SELECT a.*, b.CAS_LEG_IED_UKperm
FROM work.Euravib_Cas_Ref a LEFT OUTER JOIN work.Cas_Leg_IED b ON a.Cas_nr=b.Cas_nr;
QUIT;

DATA work.Euravib_Cas_Ref; SET work.Euravib_Cas_Ref;
IF CAS_LEG_IED_UKperm="" 	THEN DO CAS_LEG_IED_UKperm='N'; END;
IF Cas_nr="" 				THEN DELETE;
RUN;

DATA work.Euravib_Cas_Ref(DROP=molecuulgewicht); SET work.Euravib_Cas_Ref;
FORMAT molecuulgewicht_num 7.2;
Molecuulgewicht_num=input(molecuulgewicht, 7.2);
RUN;

PROC SQL;
CREATE TABLE work.Euravib_Cas_Ref AS
SELECT a.*, b.Date_of_inclusion, b.Reason_for_inclusion
FROM work.Euravib_Cas_Ref a LEFT OUTER JOIN Work.Euravib_candidate b ON a.Cas_nr=b.Cas_number;
QUIT;

DATA work.euravib_cas_ref ; SET work.euravib_cas_ref;
If CAS_nr="" THEN DELETE;
Molecuulgewicht_num=round(Molecuulgewicht_num);
Cmax_mg_m3=round(Cmax_mg_m3);
RIR_25=round(RIR_25);
RUN;

/********* Count CAS Measures *******/
PROC SQL;
CREATE TABLE work.werkplekmeting_count AS
SELECT  CasNR, COUNT(CasNR) AS Count  FROM db2itask.itask_werkplekmeting_stoffen GROUP BY CasNR;
QUIT;

PROC SQL; 
CREATE TABLE work.euravib_cas_Ref AS
SELECT  a.*, b.Count
FROM work.euravib_cas_ref a LEFT OUTER JOIN work.werkplekmeting_count  b ON a.Cas_nr=b.CASNR;
QUIT;

DATA work.euravib_cas_Ref; SET work.euravib_cas_Ref;
IF COUNT="" THEN COUNT=0;
RUN;

/**********************************************************************/
/****    Update Euravib_substance_cas						       ****/
/**********************************************************************/
DATA work.euravib_substance_cas (KEEP= SUPPL_NR DIMSET REV_DATE ENTRY_DATE CAS_NR CAS_PERC); SET db2eura.euravib_import;
RUN;

data work.euravib_substance_cas;
   set work.euravib_substance_cas;
   length casnr1-casnr20 $30.;
   array casnr(20) $;
   do i = 1 to dim(casnr);
      casnr[i]=scan(CAS_NR,i,'|','M');
   end;

   length casperc1-casperc20 $30.;
   array casperc(20) $;
   do i = 1 to dim(casperc);
      casperc[i]=scan(CAS_PERC,i,'|','M');
   end;
run;


DATA work.euravib_substance_cas(KEEP= SUPPL_NR DIMSET REV_DATE ENTRY_DATE CASNR CASPERC); SET work.euravib_substance_cas;
IF casnr1  ne "" 	THEN DO; CasNr=casnr1;  CasPerc=casperc1; 		OUTPUT; END;
IF casnr2  ne "" 	THEN DO; CasNr=casnr2;  CasPerc=casperc2; 		OUTPUT; END;
IF casnr3  ne "" 	THEN DO; CasNr=casnr3;  CasPerc=casperc3; 		OUTPUT; END;
IF casnr4  ne "" 	THEN DO; CasNr=casnr4;  CasPerc=casperc4; 		OUTPUT; END;
IF casnr5  ne "" 	THEN DO; CasNr=casnr5;  CasPerc=casperc5; 		OUTPUT; END;
IF casnr6  ne "" 	THEN DO; CasNr=casnr6;  CasPerc=casperc6; 		OUTPUT; END;
IF casnr7  ne "" 	THEN DO; CasNr=casnr7;  CasPerc=casperc7; 		OUTPUT; END;
IF casnr8  ne "" 	THEN DO; CasNr=casnr8;  CasPerc=casperc8; 		OUTPUT; END;
IF casnr9  ne "" 	THEN DO; CasNr=casnr9;  CasPerc=casperc9; 		OUTPUT; END;
IF casnr10  ne "" 	THEN DO; CasNr=casnr10;  CasPerc=casperc10;  	OUTPUT; END;
IF casnr11  ne "" 	THEN DO; CasNr=casnr11;  CasPerc=casperc11;  	OUTPUT; END;
IF casnr12  ne "" 	THEN DO; CasNr=casnr12;  CasPerc=casperc12;  	OUTPUT; END;
IF casnr13  ne "" 	THEN DO; CasNr=casnr13;  CasPerc=casperc13;  	OUTPUT; END;
IF casnr14  ne "" 	THEN DO; CasNr=casnr14;  CasPerc=casperc14;  	OUTPUT; END;
IF casnr15  ne "" 	THEN DO; CasNr=casnr15;  CasPerc=casperc15; 	OUTPUT; END;
IF casnr16  ne "" 	THEN DO; CasNr=casnr16;  CasPerc=casperc16;  	OUTPUT; END;
IF casnr17  ne "" 	THEN DO; CasNr=casnr17;  CasPerc=casperc17;  	OUTPUT; END;
IF casnr18  ne "" 	THEN DO; CasNr=casnr18;  CasPerc=casperc18;  	OUTPUT; END;
IF casnr19  ne "" 	THEN DO; CasNr=casnr19;  CasPerc=casperc19;  	OUTPUT; END;
IF casnr20  ne "" 	THEN DO; CasNr=casnr20;  CasPerc=casperc20;  	OUTPUT; END;
RUN;


DATA work.Euravib_Substance_Cas (KEEP=Dimset Suppl_nr Rev_Date Cas_Perc Cas_Nr Entry_date);
SET work.euravib_substance_cas;
IF substr(dimset,1,3)='00A' 								THEN Dimset=Substr(Dimset,1,7);
IF substr(dimset,1,3)='09A' AND substr(dimset,8,10)='.00'  	THEN Dimset=Substr(Dimset,1,7);
Cas_nr=compress(CasNr) ; Cas_Perc=CasPerc;
Suppl_nr=" "||Suppl_nr;
RUN;


PROC SQL;
CREATE TABLE work.euravib_substance_cas AS
SELECT	a.*,
		ROUND(b.VAP_PRESS_25_MBAR) 	AS Vap_Press_25_mbar,
		ROUND(b.RIR_25)				AS Rir_25,
		b.boiling_range_c,
		b.boiling_point_c
FROM work.euravib_substance_cas a LEFT OUTER JOIN work.euravib_cas_ref b ON a.CAS_NR=b.CAS_NR
GROUP BY a.suppl_nr, a.dimset, a.rev_date, a.entry_date, a.cas_nr;
QUIT;

/**** Check on reach inclusion				*****/
PROC SQL;
CREATE TABLE work.euravib_substance_cas AS
SELECT a.*, b.Date_of_inclusion, b.Reason_for_inclusion
FROM work.euravib_substance_cas a LEFT OUTER JOIN Work.Euravib_candidate b ON a.Cas_nr=b.Cas_number;
QUIT;

PROC Sort data=work.euravib_substance_cas nodups; by suppl_nr dimset rev_date entry_date cas_nr cas_perc; RUN;

/**************************** P Vap Pressure ****************************/
PROC SQL;
CREATE TABLE work.p_vap_press AS
SELECT  a.*
FROM work.euravib_substance_cas a;
QUIT;

DATA work.p_vap_press ; SET work.p_vap_press;
caspercentage=Translate(trim(cas_perc),"   ","_=>");
RUN;

DATA work.p_vap_press ; SET work.p_vap_press;
caspercentage=scan(caspercentage,-1,'-','m');
RUN;

DATA work.p_vap_press ; SET work.p_vap_press;
caspercentage=scan(caspercentage,-1,'<','m');
RUN;

DATA work.p_vap_press ; SET work.p_vap_press;
caspercentage=compress(caspercentage);
RUN;

DATA work.p_vap_press ; SET work.p_vap_press;
caspercentage=Translate(trim(caspercentage),".",",");
RUN;

DATA work.p_vap_press (Drop=caspercentage); SET work.p_vap_press;
FORMAT casperc_num 10.2;
casperc_num=caspercentage;
RUN;

DATA work.p_vap_press ; SET work.p_vap_press;
Pvappress25mbar=((casperc_num/100)*VAP_PRESS_25_MBAR);
RUN;

PROC SQL;
CREATE TABLE work.euravib_substance_cas1 AS
SELECT  a.*,
		b.Pvappress25mbar
FROM work.euravib_substance_cas a LEFT OUTER JOIN work.p_vap_press b on a.dimset=b.dimset and a.suppl_nr=b.suppl_nr and a.rev_date=b.rev_date and a.entry_date=b.entry_date 
and a.cas_nr=b.cas_nr and a.cas_perc=b.cas_perc;
QUIT;

/******************************** P Cmax ****************************/
PROC SQL;
CREATE TABLE work.p_cmax AS
SELECT  a.*,
		b.Cmax_mg_m3,
		b.molecuulgewicht_num
FROM work.euravib_substance_cas1 a LEFT OUTER JOIN work.euravib_cas_ref b on a.cas_nr=b.cas_nr;
QUIT;

DATA work.p_cmax ; SET work.p_cmax;
Pcmax=((((pvappress25mbar*100)/1000)*MOLECUULGEWICHT_NUM)*404.4);
RUN;

PROC SQL;
CREATE TABLE work.euravib_substance_cas2 AS
SELECT  a.*,
		b.Pcmax
FROM work.euravib_substance_cas1 a LEFT OUTER JOIN work.p_cmax b on a.dimset=b.dimset and a.suppl_nr=b.suppl_nr and a.rev_date=b.rev_date and a.entry_date=b.entry_date 
and a.cas_nr=b.cas_nr and a.cas_perc=b.cas_perc;
QUIT;


/******************************** Max_P_HR ****************************/
PROC SQL;
CREATE TABLE work.max_p_hr AS
SELECT  a.*,
		b.GW_ECP_NL_8h_TGG_mg,
		b.GW_ECP_NL_15m_TGG_mg,
		b.FLASH_POINT_C
FROM work.euravib_substance_cas2 a LEFT OUTER JOIN work.euravib_cas_ref b on a.cas_nr=b.cas_nr;
QUIT;

DATA work.max_p_hr ; SET work.max_p_hr;
p_hr_8h=pcmax/GW_ECP_NL_8h_TGG_mg;
p_hr_15m=pcmax/GW_ECP_NL_15m_TGG_mg;
RUN;

PROC SQL;
CREATE TABLE work.euravib_substance_cas3 AS
SELECT  a.*,
		b.p_hr_8h,
		b.p_hr_15m,
		b.FLASH_POINT_C
FROM work.euravib_substance_cas2 a LEFT OUTER JOIN work.max_p_hr b on a.dimset=b.dimset and a.suppl_nr=b.suppl_nr and a.rev_date=b.rev_date and a.entry_date=b.entry_date 
and a.cas_nr=b.cas_nr and a.cas_perc=b.cas_perc;
QUIT;

DATA work.euravib_substance_cas3; SET work.euravib_substance_cas3;
FORMAT Boiling_range_c_1 11.;
Boiling_Range_C_1=scan(Boiling_Range_C,-1,'-','m');
RUN;

DATA work.euravib_substance_cas3(DROP=Boiling_Point_C Boiling_Range_C Boiling_range_c_1); SET work.euravib_substance_cas3;
FORMAT Boiling_MAX 11.2;
IF Boiling_Range_C_1=. 	THEN Boiling_MAX=Boiling_point_c; ELSE Boiling_MAX=Boiling_Range_C_1;
IF Boiling_MAX=. 		THEN Boiling_MAX=0;
RUN;


PROC SQL;
CREATE TABLE work.Main_inclusion AS
SELECT a.Suppl_nr, a.Dimset, a.Rev_date, COUNT(a.Dimset) AS Main_reason_for_inclusion
FROM work.euravib_substance_cas a
WHERE a.Reason_for_inclusion NE ""
GROUP BY a.Suppl_nr, a.Dimset, a.Rev_date;
QUIT;                                                                 /* Date will be appended at Euravib_main script */

/**** Check on RIR max						*****/	
PROC SQL;
CREATE TABLE work.euravib_Mixture_Max AS
SELECT  a.Suppl_nr,
		a.Dimset,
		a.REV_Date,
		max(a.RIR_25) 			AS MAXRIR,
		max(a.Vap_press_25_mbar)AS MAXVapour
FROM work.euravib_substance_cas a
GROUP BY DIMSET, Suppl_nr, Rev_date;
QUIT;

/**********************************************************************/
/****    Update Euravib_Mixture_H						           ****/
/**********************************************************************/
DATA work.Euravib_Mixture_H (KEEP= SUPPL_NR DIMSET REV_DATE ENTRY_DATE H_NR H_CAT); SET db2eura.euravib_import;
RUN;

data work.Euravib_Mixture_H;
   set work.Euravib_Mixture_H;
   length hnr1-hnr20 $30.;
   array hnr(20) $;
   do i = 1 to dim(hnr);
      hnr[i]=scan(H_NR,i,'|','M');
   end;

   length hcat1-hcat20 $50.;
   array hcat(20) $;
   do i = 1 to dim(hcat);
      hcat[i]=scan(H_CAT,i,'|','M');
   end;
run;


DATA work.Euravib_Mixture_H(KEEP= SUPPL_NR DIMSET REV_DATE ENTRY_DATE H_NR H_CAT); SET work.Euravib_Mixture_H;
IF hnr1  ne "" 	THEN DO; H_NR=hnr1;  H_CAT=hcat1; 	OUTPUT; END;
IF hnr2  ne "" 	THEN DO; H_NR=hnr2;  H_CAT=hcat2; 	OUTPUT; END;
IF hnr3  ne "" 	THEN DO; H_NR=hnr3;  H_CAT=hcat3; 	OUTPUT; END;
IF hnr4  ne "" 	THEN DO; H_NR=hnr4;  H_CAT=hcat4; 	OUTPUT; END;
IF hnr5  ne "" 	THEN DO; H_NR=hnr5;  H_CAT=hcat5; 	OUTPUT; END;
IF hnr6  ne "" 	THEN DO; H_NR=hnr6;  H_CAT=hcat6; 	OUTPUT; END;
IF hnr7  ne "" 	THEN DO; H_NR=hnr7;  H_CAT=hcat7; 	OUTPUT; END;
IF hnr8  ne "" 	THEN DO; H_NR=hnr8;  H_CAT=hcat8; 	OUTPUT; END;
IF hnr9  ne "" 	THEN DO; H_NR=hnr9;  H_CAT=hcat9; 	OUTPUT; END;
IF hnr10  ne "" THEN DO; H_NR=hnr10;  H_CAT=hcat10; OUTPUT; END;
IF hnr11  ne "" THEN DO; H_NR=hnr11;  H_CAT=hcat11; OUTPUT; END;
IF hnr12  ne "" THEN DO; H_NR=hnr12;  H_CAT=hcat12; OUTPUT; END;
IF hnr13  ne "" THEN DO; H_NR=hnr13;  H_CAT=hcat13; OUTPUT; END;
IF hnr14  ne "" THEN DO; H_NR=hnr14;  H_CAT=hcat14; OUTPUT; END;
IF hnr15  ne "" THEN DO; H_NR=hnr15;  H_CAT=hcat15; OUTPUT; END;
IF hnr16  ne "" THEN DO; H_NR=hnr16;  H_CAT=hcat16; OUTPUT; END;
IF hnr17  ne "" THEN DO; H_NR=hnr17;  H_CAT=hcat17; OUTPUT; END;
IF hnr18  ne "" THEN DO; H_NR=hnr18;  H_CAT=hcat18; OUTPUT; END;
IF hnr19  ne "" THEN DO; H_NR=hnr19;  H_CAT=hcat19; OUTPUT; END;
IF hnr20  ne "" THEN DO; H_NR=hnr20;  H_CAT=hcat20; OUTPUT; END;
RUN;

DATA work.Euravib_Mixture_H; SET work.Euravib_Mixture_H;
FORMAT H_Ref $30.;
LENGTH H_Ref $30.;
IF substr(dimset,1,3)='00A' 										THEN Dimset=Substr(Dimset,1,7);
IF substr(dimset,1,3)='09A' AND substr(dimset,8,10)='.00'  			THEN Dimset=Substr(Dimset,1,7);
IF LENGTH(Suppl_nr)=5 												THEN Suppl_nr=" "||Suppl_nr;
IF Suppl_nr=' 01270' AND Dimset IN('Gardobond X 4650_3','Gardobond X 4744_3') AND H_nr='H314' AND substr(strip(reverse(H_Cat)), 1, 1) NE 'B'	THEN H_Cat=CATS(H_Cat,'B');

H_Ref=TRIM(H_nr)||'-';
IF INDEX(H_Cat,'1')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Cat,INDEX(H_Cat,'1'),2));
IF INDEX(H_Cat,'2')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Cat,INDEX(H_Cat,'2'),2));
IF INDEX(H_Cat,'3')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Cat,INDEX(H_Cat,'3'),2));
IF INDEX(H_Cat,'4')>0 THEN H_Ref=TRIM(H_nr)||'-'||UPCASE(SUBSTR(H_Cat,INDEX(H_Cat,'4'),2));
IF H_Nr="H280"		  THEN H_Ref=TRIM(H_nr)||'-'||TRIM(H_Cat);
/**/
/*IF H_Nr="H220"		  THEN H_Ref=TRIM(H_nr)||'-'||"1A";*/
/**/ 
WHERE H_nr <> "";
RUN;


/* Get availeble dimsets for Main Table */
DATA work.euravib_main1 (KEEP=Suppl_nr Dimset Entry_date Rev_Date); SET work.Euravib_Substance_Cas; RUN;
DATA work.euravib_main2 (KEEP=Suppl_nr Dimset Entry_date Rev_Date); SET work.Euravib_Mixture_H; RUN;
DATA work.euravib_main1; SET work.euravib_main1; 
IF substr(dimset,1,3)='00A' 									THEN Dimset=Substr(Dimset,1,7); 
IF substr(dimset,1,3)='09A' AND substr(dimset,8,3)='.00'  		THEN Dimset=Substr(Dimset,1,7); 
Dimset_descr=dimset;
IF substr(dimset,1,3)='00A' AND substr(dimset,8,3) NE '.RD' 	THEN Dimset_descr=TRIM(Dimset_descr)||".00"; 
RUN;
DATA work.euravib_main2; SET work.euravib_main2; 
IF substr(dimset,1,3)='00A' 									THEN Dimset=Substr(Dimset,1,7); 
IF substr(dimset,1,3)='09A' AND substr(dimset,8,3)='.00'  		THEN Dimset=Substr(Dimset,1,7);
Dimset_descr=dimset;
IF substr(dimset,1,3)='00A' AND substr(dimset,8,3) NE '.RD' 	THEN Dimset_descr=TRIM(dimset)||".00"; 
RUN;



PROC sql;
CREATE table work.Dimset_tro AS
  	SELECT 	a.Company,
			a.suppl_nr,
			a.Dimset,
			b.Dim_Suppl_nr,
			sum(a.ord_quan) AS TRO_hist_ly
	FROM  db2data.lra011 a,
		  db2data.dimsets b
	WHERE del_quan ne 0 AND Ord_type=1 AND date>=(date()-365) AND a.Item IN ('LAK','PRI') AND a.Company=b.Company AND a.Dimset=b.Dimset
	GROUP by a.Company, a.suppl_nr, a.Dimset, b.Dim_Suppl_nr 
	Order by a.company, a.suppl_nr, a.dimset, b.Dim_Suppl_nr;
QUIT;
DATA work.Dimset_tro (DROP=Dim_Suppl_nr); SET work.Dimset_tro;
IF Suppl_nr=' Z0200' THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr=' 20320' THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr='013320' THEN Suppl_nr=Dim_Suppl_nr;
RUN;
PROC sql;
CREATE table work.Dimset_tro_3yr AS
  	SELECT 	a.Company,
			a.suppl_nr,
			a.Dimset,
			b.Dim_Suppl_nr,
			sum(a.ord_quan) AS TRO_hist_l3y
	FROM  db2data.lra011 a,
		  db2data.dimsets b
	WHERE del_quan ne 0 AND Ord_type=1 AND date>=(date()-3*365) AND a.Item IN ('LAK','PRI') AND a.Company=b.Company AND a.Dimset=b.Dimset
	GROUP by a.Company, a.suppl_nr, a.Dimset, b.Dim_Suppl_nr 
	Order by a.company, a.suppl_nr, a.dimset, b.Dim_Suppl_nr;
QUIT;
DATA work.Dimset_tro_3yr (DROP=Dim_Suppl_nr); SET work.Dimset_tro_3yr;
IF Suppl_nr=' Z0200' THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr=' 20320' THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr='013320' THEN Suppl_nr=Dim_Suppl_nr;
RUN;
PROC sql;
CREATE table work.Dimset_tro_pln AS
  	SELECT 	a.Company,
			a.Dimset,
			min(a.date) AS TRO_date
	FROM  db2data.lra011 a 
	WHERE del_quan eq 0 AND Ord_type=1 AND a.Item IN ('LAK','PRI','CHEM')
	GROUP by a.Company, a.Dimset 
	Order by a.company, a.dimset;
QUIT;
PROC sql;
CREATE table work.Dimset_pur AS
  	SELECT 	a.Company,
			a.suppl_nr,
			a.Dimset,
			b.Dim_Suppl_nr,
			sum(a.ord_quan) AS Pur_ord
	FROM  db2data.lra011 a,
		  db2data.dimsets b
	WHERE del_quan eq 0 AND Ord_type=2 AND a.Item IN ('LAK','PRI') AND a.Item IN ('LAK','PRI') AND a.Company=b.Company AND a.Dimset=b.Dimset
	GROUP by a.Company, a.suppl_nr, a.Dimset, b.Dim_Suppl_nr 
	Order by a.company, a.suppl_nr, a.dimset, b.Dim_Suppl_nr;
QUIT;
DATA work.Dimset_pur (DROP=Dim_Suppl_nr); SET work.Dimset_pur;
IF Suppl_nr=' Z0200' THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr=' 20320' THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr='013320' THEN Suppl_nr=Dim_Suppl_nr;
RUN;
PROC sql;
CREATE table work.Dimset_stc AS
  	SELECT 	a.Company,
			a.suppl_nr,
			a.Dimset,
			b.Dim_Suppl_nr,
			sum(a.Stock_quan) AS Idno_stock
	FROM  db2data.idno_stock a,
		  db2data.dimsets b 
	WHERE  a.Item_nr IN ('LAK','PRI','CHEM') AND a.Item_nr IN ('LAK','PRI','CHEM') AND a.Company=b.Company AND a.Dimset=b.Dimset
	GROUP by a.Company, a.suppl_nr, a.Dimset, b.Dim_Suppl_nr
	Order by a.company, a.suppl_nr, a.dimset, b.Dim_Suppl_nr;
QUIT;
DATA work.Dimset_stc (DROP=Dim_Suppl_nr); SET work.Dimset_stc;
IF Suppl_nr=' Z0200' THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr=' 20320' THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr='013320' THEN Suppl_nr=Dim_Suppl_nr;
RUN;


PROC SORT data=work.Dimset_tro; 	BY Company Suppl_nr Dimset; RUN;
PROC SORT data=work.Dimset_pur; 	BY Company Suppl_nr Dimset; RUN;
PROC SORT data=work.Dimset_stc; 	BY Company Suppl_nr Dimset; RUN;
PROC SORT data=work.Dimset_tro_3yr; BY Company Suppl_nr Dimset; RUN;

DATA work.dimsets (DROP=TRO_hist_l3y);
MERGE work.Dimset_tro work.Dimset_pur work.Dimset_stc work.Dimset_tro_3yr;
BY Company Suppl_nr Dimset;
RUN;

DATA work.dimsets; Length Dimset $50.; SET work.dimsets;
FORMAT Dimset $50.; INFORMAT Dimset $50.;
IF Idno_stock=. 			THEN Idno_stock=0;
IF Pur_ord=. 				THEN Pur_ord=0;
IF TRO_hist_ly=. 			THEN TRO_hist_ly=0;
IF substr(Dimset,3,1)=" " 	THEN DELETE;
IF Suppl_nr="-" 			THEN DELETE;

RUN;

/* Collect Specials */
DATA work.euravib_main3 (KEEP=Dimset1 Suppl_nr Review_Date); 
Length Dimset1 $50.;
SET work.Euravib_Specials1;
FORMAT Dimset1 $50.; INFORMAT Dimset1 $50.;
Dimset1=TRIM(STRIP(Code)); Suppl_nr=compress(Suppl_nr1); 
WHERE Code NE "";
RUN;

PROC SQL;
CREATE TABLE work.euravib_main3 AS
SELECT  a.*,
		b.rev_date,
		b.entry_date
FROM work.euravib_main3 a LEFT OUTER JOIN db2eura.euravib_import b ON a.suppl_nr=b.suppl_nr and a.dimset1=b.dimset;
QUIT;

DATA work.euravib_main3 (DROP=dimset1 Review_Date); SET work.euravib_main3;
Dimset=Dimset1;
IF rev_date="" THEN rev_date=Review_Date;
RUN;

PROC SORT data=work.euravib_main3 nodups; BY Suppl_nr Dimset Entry_date Rev_Date; RUN;

DATA work.euravib_main3; SET work.euravib_main3;
by Suppl_nr Dimset Entry_date Rev_Date;
IF NOT last.dimset THEN DELETE;
RUN;

DATA work.euravib_main3; SET work.euravib_main3;
Suppl_nr=" "||Suppl_nr;
RUN;

/* Bullit change */
/* Main1 */
DATA work.euravib_main1; SET work.euravib_main1;
IF SUBSTR(Suppl_nr,2,1) IN ('1','2','3','4','5','6','7','8','9','0') THEN Company='Roe'; ELSE Company='Cor';
RUN;

DATA work.euravib_main1_ECP; SET work.euravib_main1;
Company='ECP';
WHERE Company='Roe';
RUN;

DATA work.euravib_main1_EAP; SET work.euravib_main1;
Company='EAP';
WHERE Company='Roe';
RUN;

PROC APPEND BASE=work.euravib_main1 data=work.euravib_main1_ECP; RUN;
PROC APPEND BASE=work.euravib_main1 data=work.euravib_main1_EAP; RUN;
/* Main1 */
/* Main2 */
DATA work.euravib_main2; SET work.euravib_main2;
IF SUBSTR(Suppl_nr,2,1) IN ('1','2','3','4','5','6','7','8','9','0') THEN Company='Roe'; ELSE Company='Cor';
RUN;

DATA work.euravib_main2_ECP; SET work.euravib_main2;
Company='ECP';
WHERE Company='Roe';
RUN;

DATA work.euravib_main2_EAP; SET work.euravib_main2;
Company='EAP';
WHERE Company='Roe';
RUN;

PROC APPEND BASE=work.euravib_main2 data=work.euravib_main2_ECP; RUN;
PROC APPEND BASE=work.euravib_main2 data=work.euravib_main2_EAP; RUN;
/* Main2 */
/* Main3 */
DATA work.euravib_main3; SET work.euravib_main3;
IF SUBSTR(Suppl_nr,2,1) IN ('1','2','3','4','5','6','7','8','9','0') THEN Company='Roe'; ELSE Company='Cor';
RUN;

DATA work.euravib_main3_ECP; SET work.euravib_main3;
Company='ECP';
WHERE Company='Roe';
RUN;

DATA work.euravib_main3_EAP; SET work.euravib_main3;
Company='EAP';
WHERE Company='Roe';
RUN;

PROC APPEND BASE=work.euravib_main3 data=work.euravib_main3_ECP; RUN;
PROC APPEND BASE=work.euravib_main3 data=work.euravib_main3_EAP; RUN;
/* Main3 */




PROC SORT data=work.euravib_main1 	nodupkey; BY Company Suppl_nr Dimset Entry_date Rev_Date; 	RUN;
PROC SORT data=work.euravib_main2 	nodupkey; BY Company Suppl_nr Dimset Entry_date Rev_Date; 	RUN;
PROC SORT data=work.euravib_main3 	nodupkey; BY Company Suppl_nr Dimset Entry_date Rev_Date; 	RUN;
PROC SORT data=work.Dimsets 		nodupkey; BY Company Suppl_nr Dimset;  						RUN;

DATA work.euravib_main /*(DROP=Idno_stock Pur_ord TRO_hist_lhy)*/;
MERGE work.dimsets work.euravib_main3 work.euravib_main1 work.euravib_main2;
BY Company Suppl_nr Dimset ;
Pur_Quan=Pur_ord;
STC_Quan=Idno_stock;
RUN;

PROC SORT data=work.euravib_main; BY Company suppl_nr dimset rev_date; RUN;
DATA work.euravib_main; SET work.euravib_main;
BY Company suppl_nr dimset rev_date; 
IF NOT First.rev_date THEN DELETE;
RUN;


PROC SQL;   /* Stock via special dimset */
CREATE TABLE work.euravib_stock_dims AS
SELECT  a.Company, a.Suppl_nr, a.Dimset AS Dimset, AVG(c.STC_Quan)  AS STC_Quan_d
FROM work.euravib_main a,
	 work.Euravib_Specials1 b,
	 db2data.Dimset_Transactions c
WHERE a.Company=b.Company AND SUBSTR(a.Dimset,1,7)=SUBSTR(b.code,1,7)  AND b.Company=c.Company AND STRIP(b.Dimset)=STRIP(c.Dimset)
GROUP BY a.Company, a.Suppl_nr, a.Dimset;
QUIT;

PROC SQL;   /* Stock via special item */
CREATE TABLE work.euravib_stock_item AS
SELECT  a.Company, a.Suppl_nr, a.Dimset, AVG(c.ITEM_STOCK_QUAN)  AS STC_Quan_i
FROM work.euravib_main a,
	 work.Euravib_Specials1 b,
	 db2data.Item_Stock c
WHERE a.Company=b.Company AND SUBSTR(a.Dimset,1,7)=SUBSTR(b.code,1,7) AND b.Company=c.Company AND STRIP(b.Item_nr)=c.Item_nr
GROUP BY a.Company, a.Suppl_nr, a.Dimset;
QUIT;

PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT  a.*, b.STC_Quan_d
FROM work.euravib_main a LEFT OUTER JOIN work.euravib_stock_dims b ON a.Suppl_nr=b.Suppl_nr AND a.Dimset=b.Dimset;
QUIT;
PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT  a.*, b.STC_Quan_i
FROM work.euravib_main a LEFT OUTER JOIN work.euravib_stock_item b ON a.Suppl_nr=b.Suppl_nr AND a.Dimset=b.Dimset;
QUIT;

DATA work.euravib_main (DROP=STC_Quan_d STC_Quan_i);
SET work.euravib_main;
IF STC_Quan_d>0 THEN STC_Quan=STC_Quan_d;
IF STC_Quan_i>0 THEN STC_Quan=STC_Quan_i;
RUN;

PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT a.*, b.Replacebility
FROM work.euravib_main a Left OUTER JOIN work.Euravib_CMR_Prop1 b ON a.Company=b.Company AND Substr(a.Dimset,1,7)=Substr(b.Dimset,1,7) AND a.Suppl_nr=b.Suppl_nr1;
QUIT;

PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT a.*, b.Name AS Special_descr, b.Stock_kg, b.State_matter
FROM work.euravib_main a Left OUTER JOIN work.Euravib_Specials1 b ON a.Dimset=b.Code AND a.Suppl_nr=b.Suppl_nr1;
QUIT;

PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT a.*, b.Dim_Suppl_nr, b.DIM_ITEM
FROM work.euravib_main a Left OUTER JOIN db2data.Dimsets b ON a.Company=b.Company AND a.Dimset=b.Dimset;
QUIT;

DATA DATA work.euravib_main (DROP=Dim_Suppl_nr); SET work.euravib_main;
IF Suppl_nr=' Z0200' 	THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr=' 20320' 	THEN Suppl_nr=Dim_Suppl_nr;
IF Suppl_nr='013320' 	THEN Suppl_nr=Dim_Suppl_nr;
IF Dim_item='LAK' 		THEN State_matter='Liquid';
IF Dim_item='PRI' 		THEN State_matter='Liquid';
IF Dim_item="" 			THEN Dim_item="-";
IF State_matter="" 		THEN State_Matter="-";
IF State_matter="Stof" 	THEN State_Matter="Dust";
IF State_matter="Vast" 	THEN State_Matter="Solid";
IF State_matter="Rook" 	THEN State_Matter="Smoke";
/*If dim_item='CHEM' 		THEN DELETE;*/
RUN;

PROC SORT DATA=work.euravib_main;
BY Company Suppl_nr Dimset descending rev_date;
RUN;

DATA work.euravib_main (DROP=Rev_Date_Check Special_descr Stock_kg); SET work.euravib_main;
BY Company Suppl_nr Dimset descending rev_date;
RETAIN Rev_Date_check;
IF STC_Quan=. AND Stock_kg>0 					THEN STC_Quan=Stock_kg;
IF TRO_Hist_LY=. 								THEN TRO_Hist_LY=0;
IF Pur_Quan=. 									THEN Pur_Quan=0;
IF STC_Quan=. 									THEN STC_Quan=0;
IF -TRO_Hist_LY+Pur_Quan+STC_Quan=0 			THEN IN_USE='N'; ELSE IN_USE='Y';
IF FIRST.Dimset 								THEN Active='Y'; ELSE Active='N';
IF FIRST.Dimset 								THEN Rev_Date_check=Rev_Date;
IF NOT FIRST.Dimset AND Rev_Date_check=Rev_Date THEN DELETE;
IF NOT FIRST.Dimset AND Rev_date=. 				THEN DELETE;
IF Suppl_nr="" 									THEN DELETE;
/*IF substr(Dimset,3,1)='A' THEN Dimset=substr(Dimset,1,7);*/
FORMAT Dimset_Descr $50.; Dimset_Descr=Dimset;
IF Special_descr ne "" THEN Dimset_descr=Special_descr;
RUN;

PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT	a.*,
		b.MAXRIR 	FORMAT 11.2,
		b.MAXVapour FORMAT 11.2
FROM work.euravib_main a LEFT OUTER JOIN work.euravib_mixture_max b ON a.Dimset=b.Dimset AND a.Suppl_nr=b.Suppl_Nr AND a.REV_DATE=b.REV_DATE;
QUIT;

PROC SQL; CREATE TABLE work.euravib_main AS
SELECT   a.*, CASE WHEN b.Main_reason_for_inclusion>0 THEN 'Y' ELSE 'N' END AS Main_reason_for_inclusion
FROM   work.euravib_main a LEFT OUTER JOIN work.Main_inclusion b ON a.Suppl_nr=b.Suppl_nr AND a.Dimset=b.Dimset AND a.Rev_date=b.Rev_date;
QUIT;

DATA work.euravib_main; SET work.euravib_main;
IF MAXRIR=. THEN MAXRIR=0; IF MAXVapour=. THEN MAXVapour=0; IF State_Matter="-" THEN State_Matter="Liquid";
RUN; 

PROC SORT data=work.euravib_main nodups; BY Company Suppl_nr Dimset; RUN; 

/********************************/
/***** Create Exposure Base *****/
PROC SQL;
CREATE TABLE work.exposure_base AS
SELECT 	a.Suppl_nr,
		a.ITEM_NR,
		a.Dimset,
		a.Company,
	   	a.TRO_ord_nr,
	   	a.Weight		AS Cons_Weight,
	   	a.Date			AS Cons_Date,
		b.Prod_Line,
		b.TASK_DESCRIPTION,
		b.Shift,
		b.Start_Time,
		b.Stop_Time,
		(b.Stop_Time-b.Start_Time)/60 AS Exposure
FROM db2data.tro_consumptions a INNER JOIN db2data.tro_hours b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr AND b.Task_Code>3400
WHERE ITEM_NR="LAK" OR ITEM_NR="PRI" and a.Date>MDY(01,01,year(date())-1) ;
QUIT;

/********************************************/
/***** Create Exposior CMR by employee  *****/
PROC SQL;
CREATE TABLE work.exposure_cmr AS
SELECT  b.Company,
		a.Suppl_nr,
		a.Dimset,
		a.Rev_date,
		c.CMR_C,
		c.CMR_M,
		c.CMR_R
FROM work.euravib_mixture_h a INNER JOIN work.euravib_main b ON a.Suppl_nr=b.Suppl_nr AND a.Dimset=b.Dimset AND a.Rev_date=b.Rev_date AND b.Active='Y' 
							  LEFT OUTER JOIN work.euravib_h_info c ON a.H_Ref=c.H_Ref 
WHERE NOT (c.CMR_C="" AND c.CMR_M="" AND c.CMR_R="");
QUIT;

PROC SQL;
CREATE TABLE work.exposure_cmr AS
SELECT 	a.*,
	   	b.TRO_ord_nr,
	   	b.Weight		AS Cons_Weight,
	   	b.Date			AS Cons_Date
FROM work.exposure_cmr a LEFT OUTER JOIN db2data.tro_consumptions b ON a.Dimset=b.Dimset AND a.company=b.company;
QUIT;
PROC SQL;
CREATE TABLE work.exposure_cmr AS
SELECT 	a.*,
		b.Prod_Line,
		b.Shift,
		b.Start_Time,
		b.Stop_Time,
		(b.Stop_Time-b.Start_Time)/60 AS Exposior
FROM work.exposure_cmr a LEFT OUTER JOIN db2data.tro_hours b ON a.company=b.company AND  a.TRO_ord_nr=b.TRO_Ord_nr AND b.Task_Code>3400;
QUIT;
PROC SQL;
CREATE TABLE work.exposure_cmr AS
SELECT 	a.*,
		b.Empl_nr,
		b.Empl_name
FROM work.exposure_cmr a LEFT OUTER JOIN DB2DATA.Production_presence b ON a.Company=b.Company AND a.Cons_Date=b.Date AND a.Prod_line=b.Prod_line AND
					   ((b.Shift='OD' AND a.shift='S1') OR (b.Shift='MD' AND a.shift='S2') OR (b.shift='ND' AND a.shift='S3'));
QUIT;




/**********************************************************************/
/****    Import BRZO/ARIE list reference Data					   ****/
/**********************************************************************/

/**/
/*IDno-stock*/
/*Ophalen grenswaarden - op deze plek nog voor alle gevarencategorie�n, niet enkel voor de gevarencategorie met de laagste grenswaarden*/
PROC SQL;
CREATE TABLE work.stock_brzo AS
SELECT	a.Company,
		a.Idno,
		a.Item_nr,
		a.Warehouse,
		a.Dimset				FORMAT $50. LENGTH 50,
		b.Dimset_Descr,
		a.Suppl_nr,
		a.Stock_quan,
		c.H_Nr,
		c.H_Cat,
		c.H_Ref,
		b.Rev_Date,
		d.ARIE_treshold,																			/*Grenswaarde ARIE*/
		d.SEV_III_TRESHOLD_1,           															/*Grenswaarde BRZO*/
		d.SEC_III_HAZ_CAT				AS SEC_III_HAZ_CAT  		Label='SEC_III_HAZ_CAT',		/*Gevarencategorie lang*/
		substr(d.SEC_III_HAZ_CAT,1,1) 	AS SEC_III_HAZ_CAT_Short	Label='SEC_III_HAZ_CAT_Short'   /*Gevarencategorie kort*/
FROM Db2data.Idno_stock a,
	 work.Euravib_main b,
	 work.Euravib_mixture_h c,
	 work.Euravib_H_Info d
WHERE (a.company=b.Company AND a.dimset=b.dimset     AND b.Active="Y"          AND a.suppl_nr=b.Suppl_nr AND a.Warehouse<>'CWM'        AND
      a.Dimset=c.Dimset    AND b.Suppl_nr=c.Suppl_nr AND b.Rev_Date=c.Rev_Date AND c.H_Ref=d.H_Ref)      AND (SEV_III_TRESHOLD_1 <> . OR ARIE_treshold <> .)      
ORDER BY a.Company, a.Idno, a.Item_nr, a.Dimset, d.SEV_III_TRESHOLD_1 ;
QUIT;

/*Aanvulling deel I (ARIE) - Ontvlambare vloeistoffen*/
/*Aanpassing grenswaarden indien voldaan aan de voorwaarden*/
PROC SQL;
CREATE TABLE work.stock_brzo AS
SELECT	a.Company,
        a.IDNO,
		a.Item_nr,
		a.Warehouse,
		a.Dimset,
		a.Dimset_descr,
		a.Suppl_nr,
		a.Stock_quan,
		a.H_nr,
		a.H_cat,
		a.H_ref,
		a.Rev_date,
		a.ARIE_treshold,
		a.Sev_III_treshold_1,
		a.SEC_III_HAZ_CAT,
		a.SEC_III_HAZ_CAT_Short,
        COMPRESS(PUT(b.Flashpoint, $20.),'�C>') AS Flashpoint  LABEL='Flashpoint'
FROM work.stock_brzo a		LEFT OUTER JOIN Db2eura.Euravib_import b 		ON TRIM(a.Dimset)=TRIM(b.Dimset) 				AND Substr(a.Suppl_nr,2,5)=b.Suppl_nr AND a.Rev_date=b.Rev_date;
QUIT;

PROC SQL;
CREATE TABLE work.stock_brzo AS
SELECT	a.*,
		COMPRESS(PUT(b.Flashpoint, $20.),'�C>') AS Flashpoint_C1 LABEL='Flashpoint_C1'
FROM work.stock_brzo a		LEFT OUTER JOIN	Db2eura.Euravib_import b 		ON TRIM(a.Dimset)=TRIM(Substr(b.Dimset,1,7)) AND Substr(a.Suppl_nr,2,5)=b.Suppl_nr AND a.Rev_date=b.Rev_date AND a.Flashpoint IS MISSING
ORDER BY a.Company, a.Dimset, a.Idno, a.H_Ref;
QUIT;

DATA work.stock_brzo (DROP=Flashpoint_C1 Index Boilingpoint_C Ambient_temp_C Flashpoint Flashpoint_C  Rev_date);
SET work.stock_brzo;
FORMAT Boilingpoint_C   $2.;
FORMAT Ambient_temp_C 	$2.;
Boilingpoint_C	=55; /*Vastgelegd in opdracht van HH d.d. 2023-01*/
Ambient_temp_C	=20; /*Vastgelegd in opdracht van HH d.d. 2023-01*/
/*Klaarzetten juiste data*/
IF Flashpoint="" 																											THEN Flashpoint=Flashpoint_C1; ELSE Flashpoint=Flashpoint;
Index=(Index(Flashpoint,'-'));
IF Index=1 																													THEN Flashpoint=Flashpoint;
IF Index>1 																													THEN Flashpoint=Substr(Flashpoint,1,Index-1);
Flashpoint_C=INPUT(Flashpoint, 3.);
/*Bepaling aangepaste grenswaarden*/
IF H_Ref IN('H225-2','H226-3') AND Ambient_temp_C > Boilingpoint_C 															THEN ARIE_treshold=3000;
IF H_Ref IN('H225-2','H226-3') AND Flashpoint_C > 60 AND Ambient_temp_C > Flashpoint_C 										THEN ARIE_treshold=3000;
IF H_Ref IN('H225-2','H226-3') AND Ambient_temp_C > Flashpoint_C AND Ambient_temp_C < Boilingpoint_C 						THEN ARIE_treshold=15000;
IF H_Ref IN('H225-2','H226-3') AND Flashpoint_C <= 60 AND Ambient_temp_C > Flashpoint_C AND Ambient_temp_C < Boilingpoint_C THEN ARIE_treshold=15000;
RUN;
/**/

/**/
/*Kaartenbak HSE STOCK HAZARDOUS SUBSTANCE ON SITE ARIE*/
/*Ophalen stoffen en hoeveelheid uit kaartenbak HSE STOCK HAZARDOUS SUBSTANCE ON SITE ARIE. Deze stoffen staan niet geregistreerd in BaaN.*/
DATA work.iCard_Stock_Haz_Sub_Site_ARIE (keep=Recordnr Companies Company_2 Location Mixture_Substance MSDS Highest_Stock_Level_KG_ PH);
SET DB2iTask.iCard_Stock_Haz_Sub_Site_ARIE;
INDEX=INDEX(Companies,";");
IF index > 0 THEN Company_2=Substr(Companies,7,3);
Companies=Substr(Companies,1,3);
WHERE Source_for_Stock_Levels="Cardfile Stock Haz.Sub.Site.ARIE";
RUN;

PROC TRANSPOSE DATA=work.iCard_Stock_Haz_Sub_Site_ARIE OUT=work.iCard_Stock_Haz_Sub_Site_ARIE;
BY RECORDNR  Location HIGHEST_STOCK_LEVEL_KG_ MIXTURE_SUBSTANCE MSDS PH;
VAR Companies Company_2;
RUN;
DATA work.iCard_Stock_Haz_Sub_Site_ARIE (DROP=_NAME_ _LABEL_);
SET work.iCard_Stock_Haz_Sub_Site_ARIE;
IF COL1="" THEN DELETE;
RUN;
DATA work.iCard_Stock_Haz_Sub_Site_ARIE ;
SET work.iCard_Stock_Haz_Sub_Site_ARIE;
RENAME COL1=Company;
RUN;

DATA iCard_Stock_Haz_Sub_Site_ARIE;
SET iCard_Stock_Haz_Sub_Site_ARIE;
Supplier1=substr(MSDS,1,5);
MSDS=Substr(MSDS,7);
Index=prxmatch("/\d{5}/", MSDS);
MSDS1=Substr(MSDS,1,Index-2);
MSDS=Substr(MSDS,Index);
RUN;
PROC SORT DATA=work.iCard_Stock_Haz_Sub_Site_ARIE; BY RECORDNR COMPANY Location HIGHEST_STOCK_LEVEL_KG_ MIXTURE_SUBSTANCE; RUN;

PROC TRANSPOSE DATA=work.iCard_Stock_Haz_Sub_Site_ARIE OUT=work.test1;
BY RECORDNR COMPANY Location HIGHEST_STOCK_LEVEL_KG_ MIXTURE_SUBSTANCE MSDS PH;
VAR MSDS1;
RUN;

PROC SQL;
CREATE TABLE work.test1 AS
SELECT	a.Recordnr,
        a.Company,
		a.Location,
		a.Highest_Stock_Level_Kg_ 	AS Highest_Stock_Level_Kg 	Label='Highest_Stock_Level_Kg',
		a.COL1                      AS Mixture_Substance        Label='Mixture_Substance',
		a.pH
FROM work.test1 a
WHERE a.COL1 IS NOT MISSING;
QUIT;


PROC TRANSPOSE DATA=work.iCard_Stock_Haz_Sub_Site_ARIE OUT=work.test2;
BY RECORDNR COMPANY Location HIGHEST_STOCK_LEVEL_KG_ MIXTURE_SUBSTANCE MSDS PH;
VAR SUPPLIER1;
RUN;

PROC SQL;
CREATE TABLE work.test2 AS
SELECT	a.Recordnr,
        a.Company,
		a.Location,
		a.Highest_Stock_Level_Kg_ 	AS Highest_Stock_Level_Kg 	Label='Highest_Stock_Level_Kg',
		a.COL1                      AS Suppl_nr        			Label='Suppl_nr',
		a.PH
FROM work.test2 a
WHERE a.COL1 IS NOT MISSING;
QUIT;

DATA work.tussentabel;
MERGE work.test1 work.test2;
BY RECORDNR;
RUN;
DATA work.tussentabel;
SET work.tussentabel;
Suppl_nr=CAT(" ",Suppl_nr);
RUN;

DATA work.eindtabel;
SET work.tussentabel;
RUN;

DATA work.iCard_Stock_Haz_Sub_Site_ARIE;
SET work.iCard_Stock_Haz_Sub_Site_ARIE;
IF MSDS='' THEN DELETE;
RUN;

%macro repeat(n);
   %do i=1 %to &n.;
DATA iCard_Stock_Haz_Sub_Site_ARIE;
SET iCard_Stock_Haz_Sub_Site_ARIE;
Supplier1=substr(MSDS,1,5);
MSDS=Substr(MSDS,7);
Index=prxmatch("/\d{5}/", MSDS);
MSDS1=Substr(MSDS,1,Index-2);
MSDS=Substr(MSDS,Index);
RUN;
PROC SORT DATA=work.iCard_Stock_Haz_Sub_Site_ARIE; BY RECORDNR COMPANY Location HIGHEST_STOCK_LEVEL_KG_ MIXTURE_SUBSTANCE; RUN;

PROC TRANSPOSE DATA=work.iCard_Stock_Haz_Sub_Site_ARIE OUT=work.test1;
BY RECORDNR COMPANY Location HIGHEST_STOCK_LEVEL_KG_ MIXTURE_SUBSTANCE MSDS;
VAR MSDS1;
RUN;

PROC SQL;
CREATE TABLE work.test1 AS
SELECT	a.Recordnr,
        a.Company,
		a.Location,
		a.Highest_Stock_Level_Kg_ 	AS Highest_Stock_Level_Kg 	Label='Highest_Stock_Level_Kg',
		a.COL1                      AS Mixture_Substance        Label='Mixture_Substance'
FROM work.test1 a
WHERE a.COL1 IS NOT MISSING;
QUIT;


PROC TRANSPOSE DATA=work.iCard_Stock_Haz_Sub_Site_ARIE OUT=work.test2;
BY RECORDNR COMPANY Location HIGHEST_STOCK_LEVEL_KG_ MIXTURE_SUBSTANCE MSDS;
VAR SUPPLIER1;
RUN;

PROC SQL;
CREATE TABLE work.test2 AS
SELECT	a.Recordnr,
        a.Company,
		a.Location,
		a.Highest_Stock_Level_Kg_ 	AS Highest_Stock_Level_Kg 	Label='Highest_Stock_Level_Kg',
		a.COL1                      AS Suppl_nr        			Label='Suppl_nr'
FROM work.test2 a
WHERE a.COL1 IS NOT MISSING;
QUIT;

DATA work.tussentabel;
MERGE work.test1 work.test2;
BY RECORDNR;
RUN;
DATA work.tussentabel;
SET work.tussentabel;
Suppl_nr=CAT(" ",Suppl_nr);
RUN;

PROC APPEND BASE=work.eindtabel DATA=work.tussentabel; RUN;

DATA work.iCard_Stock_Haz_Sub_Site_ARIE;
SET work.iCard_Stock_Haz_Sub_Site_ARIE;
IF MSDS='' THEN DELETE;
RUN;
%END;
%mend repeat;

%repeat(0);

PROC SQL;
CREATE TABLE work.waarschuwingsmail AS
SELECT Count(a.Recordnr) AS Obs
FROM work.iCard_Stock_Haz_Sub_Site_ARIE a;
QUIT;

%macro Count_reference_msds;
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="dverbert@euramax.eu"			
SUBJECT="**** Hoger aantal MSDS-verwijzingen per kaart kaartenbak iCard_Stock_Haz_Sub_Site_ARIE toegevoegd ****" CONTENT_TYPE="text/html";
Title "Script Euravib_new aanpassen (repeat ophogen)";
ODS LISTING CLOSE; ODS HTML BODY=mail;
PROC PRINT DATA=work.waarschuwingsmail  noobs; RUN;
ODS HTML CLOSE; ODS LISTING; 
%mend;

DATA work.Waarschuwingsmail1; SET work.waarschuwingsmail;
CALL EXECUTE('%Count_reference_msds');
WHERE obs  > 0;
RUN;

DATA work.iCard_Stock_Haz_Sub_Site_ARIE;
SET work.eindtabel;
Idno=0;
Item_nr='Extra';
RUN;
/**/

/**/
/*Container-idnos (via BaaN)*/
/*Ophalen stoffen uit kaartenbak HSE STOCK HAZARDOUS SUBSTANCE ON SITE ARIE en hoeveelheid uit Idno_stock-tabel.*/
DATA work.iCard_Stock_Haz_Sub_Site_CON (keep=Recordnr Companies Company_2 Location Mixture_Substance Mixture_Substance_Dimset MSDS);
SET DB2iTask.iCard_Stock_Haz_Sub_Site_ARIE;
INDEX=INDEX(Companies,";");
IF index > 0 THEN Company_2=Substr(Companies,7,3);
Companies=Substr(Companies,1,3);
WHERE Source_for_Stock_Levels="BAAN" AND Mixture_Substance_Dimset IS NOT MISSING; 
RUN;

PROC TRANSPOSE DATA=work.iCard_Stock_Haz_Sub_Site_CON OUT=work.iCard_Stock_Haz_Sub_Site_CON;
BY RECORDNR Location MIXTURE_SUBSTANCE Mixture_Substance_Dimset MSDS ;
VAR Companies Company_2;
RUN;
DATA work.iCard_Stock_Haz_Sub_Site_CON (DROP=_NAME_ _LABEL_);
SET work.iCard_Stock_Haz_Sub_Site_CON;
IF COL1="" THEN DELETE;
RUN;
DATA work.iCard_Stock_Haz_Sub_Site_CON;
SET work.iCard_Stock_Haz_Sub_Site_CON;
RENAME COL1=Company;
RUN;

DATA work.iCard_Stock_Haz_Sub_Site_CON (DROP=Length);
SET work.iCard_Stock_Haz_Sub_Site_CON;
Idno_Dimset_Descr=Substr(Mixture_Substance_Dimset,1, INDEX(Mixture_Substance_Dimset,"  ")-1);
Length=length(Mixture_Substance_Dimset) - length(scan(Mixture_Substance_Dimset, -1, "  ") );
Dimset=Substr(Mixture_Substance_Dimset, length+1);
RUN;

PROC SQL;
CREATE TABLE work.stock_brzo_CON AS
SELECT	b.Recordnr,
        a.Company,
		a.Idno,
		a.Item_nr,
		a.Location,
		a.Stock_quan 			AS Highest_stock_Level_Kg	LABEL='Highest_stock_Level_Kg',
        Substr(b.MSDS,7)		AS Mixture_Substance		LABEL='Mixture_Substance',
		.						AS PH 						LABEL='PH',
		a.Suppl_nr
FROM Db2data.Idno_stock a INNER JOIN work.iCard_Stock_Haz_Sub_Site_CON b ON a.Company=b.Company AND a.Dimset=b.Dimset AND a.Idno_Dimset_Descr=b.Idno_Dimset_Descr
WHERE a.Warehouse='CON'
ORDER BY b.Recordnr, a.Company, a.Location;
QUIT;
/**/

/**/
PROC APPEND BASE=work.iCard_Stock_Haz_Sub_Site_ARIE DATA=stock_brzo_CON FORCE; RUN;
/**/

/*Ophalen grenswaarden - op deze plek nog voor alle gevarencategorie�n, niet enkel voor de gevarencategorie met de laagste grenswaarden*/
PROC SQL;
CREATE TABLE work.stock_brzo_new_Card AS
SELECT  a.Recordnr,
        a.Company,
		a.Idno,
		a.Item_nr,
		a.Location                      AS Warehouse 				Label='Warehouse',
		a.Mixture_Substance				AS Dimset    				Label='Dimset',
		b.Dimset_Descr,
		a.Suppl_nr,
		a.Highest_stock_Level_Kg		AS Stock_quan 				Label='Stock_quan',
		a.PH,
		c.H_Nr,
		c.H_Cat,
		c.H_Ref,
		b.Rev_Date,
		d.ARIE_treshold,
	    d.SEV_III_TRESHOLD_1,
        d.SEC_III_HAZ_CAT				AS SEC_III_HAZ_CAT  		Label='SEC_III_HAZ_CAT',
		substr(d.SEC_III_HAZ_CAT,1,1) 	AS SEC_III_HAZ_CAT_Short	Label='SEC_III_HAZ_CAT_Short'
FROM work.iCard_Stock_Haz_Sub_Site_ARIE a,
	 work.Euravib_main b,
	 work.Euravib_mixture_h c,
	 work.Euravib_H_Info d
WHERE (a.company=b.Company 		   AND a.Mixture_Substance=b.Dimset_Descr AND b.Active="Y"          AND a.suppl_nr=b.Suppl_nr AND a.Location<>'CWM'        AND
      a.Mixture_Substance=c.Dimset AND b.Suppl_nr=c.Suppl_nr 			  AND b.Rev_Date=c.Rev_Date AND c.H_Ref=d.H_Ref) AND (SEV_III_TRESHOLD_1 <> . OR ARIE_treshold <> .)     
ORDER BY Recordnr, Company, Sev_III_treshold_1 ;
QUIT;

DATA work.stock_brzo_new_Card;
SET work.stock_brzo_new_Card;
IF H_Nr="H314" AND 2 < PH <11.5 THEN DELETE;
RUN;


/*Aanvulling deel I (ARIE) - ontvlambare vloeistoffen*/
/*Aanpassing grenswaarden indien voldaan aan de voorwaarden*/
PROC SQL;
CREATE TABLE work.stock_brzo_new_Card AS
SELECT	a.Recordnr,
        a.Company,
        a.IDNO,
		a.Item_nr,
		a.Warehouse,
		a.Dimset,
		a.Dimset_descr,
		a.Suppl_nr,
		a.Stock_quan,
		a.H_nr,
		a.H_cat,
		a.H_ref,
		a.Rev_date,
		a.ARIE_treshold,
		a.Sev_III_treshold_1,
		a.SEC_III_HAZ_CAT,
		a.SEC_III_HAZ_CAT_Short,
        COMPRESS(PUT(b.Flashpoint, $20.),'�C>') AS Flashpoint  LABEL='Flashpoint'
FROM work.stock_brzo_new_Card a		LEFT OUTER JOIN Db2eura.Euravib_import b 		ON TRIM(a.Dimset)=TRIM(b.Dimset) 				AND Substr(a.Suppl_nr,2,5)=b.Suppl_nr AND a.Rev_date=b.Rev_date;
QUIT;

PROC SQL;
CREATE TABLE work.stock_brzo_new_Card AS
SELECT	a.*,
		COMPRESS(PUT(b.Flashpoint, $20.),'�C>') AS Flashpoint_C1 LABEL='Flashpoint_C1'
FROM work.stock_brzo_new_Card a		LEFT OUTER JOIN	Db2eura.Euravib_import b 		ON TRIM(a.Dimset)=TRIM(Substr(b.Dimset,1,7)) AND Substr(a.Suppl_nr,2,5)=b.Suppl_nr AND a.Rev_date=b.Rev_date AND a.Flashpoint IS MISSING
ORDER BY a.Company, a.Dimset, a.Idno, a.H_Ref;
QUIT;

DATA work.stock_brzo_new_Card (DROP=Flashpoint_C1 Index Boilingpoint_C Ambient_temp_C Flashpoint Flashpoint_C  Rev_date);
SET work.stock_brzo_new_Card;
FORMAT Boilingpoint_C   $2.;
FORMAT Ambient_temp_C 	$2.;
Boilingpoint_C	=55; /*Vastgelegd in opdracht van HH d.d. 2023-01*/
Ambient_temp_C	=20; /*Vastgelegd in opdracht van HH d.d. 2023-01*/
/*Klaarzetten juiste data*/
IF Flashpoint="" 																											THEN Flashpoint=Flashpoint_C1; ELSE Flashpoint=Flashpoint;
Index=(Index(Flashpoint,'-'));
IF Index=1 																													THEN Flashpoint=Flashpoint;
IF Index>1 																													THEN Flashpoint=Substr(Flashpoint,1,Index-1);
Flashpoint_C=INPUT(Flashpoint, 3.);
/*Bepaling aangepaste grenswaarden*/
IF H_Ref IN('H225-2','H226-3') AND Ambient_temp_C > Boilingpoint_C 															THEN ARIE_treshold=3000;
IF H_Ref IN('H225-2','H226-3') AND Flashpoint_C > 60 AND Ambient_temp_C > Flashpoint_C 										THEN ARIE_treshold=3000;
IF H_Ref IN('H225-2','H226-3') AND Ambient_temp_C > Flashpoint_C AND Ambient_temp_C < Boilingpoint_C 						THEN ARIE_treshold=15000;
IF H_Ref IN('H225-2','H226-3') AND Flashpoint_C <= 60 AND Ambient_temp_C > Flashpoint_C AND Ambient_temp_C < Boilingpoint_C THEN ARIE_treshold=15000;
RUN;

PROC SQL;
CREATE TABLE work.Stock_brzo_new_Card AS
SELECT COUNT(a.Recordnr) AS COUNT,
       a.*
FROM work.Stock_brzo_new_Card a
GROUP BY Recordnr, Dimset;
QUIT; 
/*Indien stof niet duidelijk aan EAP of ECP toegewezen is*/
DATA work.Stock_brzo_new_Card (DROP=Recordnr COUNT);
SET work.Stock_brzo_new_Card;
IF COUNT>1 AND idno=0 THEN Stock_quan=Stock_quan/2;
RUN;

PROC APPEND BASE=work.stock_brzo DATA=work.Stock_brzo_new_Card FORCE; RUN;
PROC SORT DATA=work.stock_brzo;  BY Company Idno Dimset SEC_III_HAZ_CAT SEV_III_TRESHOLD_1; RUN;

DATA work.stock_brzo;
SET work.stock_brzo;
FORMAT Date Date9.; Date=Date();
RUN;

/*Aanvulling deel II (ARIE&BRZO) - Met naam genoemde stoffen*/
/*Indentificeren met naam genoemde stoffen en bijbehorende gevarencategorie�n en grenswaarden*/
PROC SQL;
CREATE TABLE work.stock_brzo_aavulling_II AS
SELECT  a.CAS_nr,
        a.ARIE_treshold,
		a.Sev_III_treshold_1,
		a.Sec_III_Haz_Cat,
        b.Suppl_nr,
		b.Dimset,
		b.Rev_date
FROM work.euravib_cas_ref a                   LEFT OUTER JOIN work.Euravib_import b ON a.CAS_nr=b.CAS_nr
WHERE a.Sec_III_Haz_Cat IS NOT MISSING;   
QUIT;
DATA work.stock_brzo_aavulling_II;
SET work.stock_brzo_aavulling_II;
FORMAT Sec_III_Haz_Cat1 $10.;
IF Dimset = '' 	THEN DELETE;
Index=Index(Sec_III_Haz_Cat, ";");
IF Index>0 		THEN Sec_III_Haz_Cat1=Substr(Sec_III_Haz_Cat, Index+2);
IF Index>0		THEN Sec_III_Haz_Cat =Substr(Sec_III_Haz_Cat, 1, Index-2);
RUN;
PROC SORT DATA=work.stock_brzo_aavulling_II; BY CAS_nr ARIE_treshold Sev_III_treshold_1 Sec_III_Haz_Cat Suppl_nr Dimset Rev_date; RUN;

PROC TRANSPOSE DATA=work.stock_brzo_aavulling_II OUT=work.stock_brzo_aavulling_II;
BY CAS_nr ARIE_treshold Sev_III_treshold_1 Suppl_nr Dimset Rev_date;
VAR Sec_III_Haz_Cat Sec_III_Haz_Cat1;
RUN;

DATA work.stock_brzo_aavulling_II (DROP=_NAME_ _LABEL_);
SET work.stock_brzo_aavulling_II;
FORMAT Sec_III_Haz_Cat $5.;  
RENAME COL1=Sec_III_Haz_Cat;
IF COL1 = '' THEN DELETE;
RUN;

/*Vervangen algemene grenswaarden door grenswaarden behorend bij de met naam genoemde stoffen*/
PROC SQL;
CREATE TABLE work.stock_brzo AS
SELECT  a.*,
        b.ARIE_treshold			AS ARIE_deel2		LABEL='ARIE_deel2',
		b.Sev_III_treshold_1	AS BRZO_deel2		LABEL='BRZO_deel2' 
FROM work.stock_brzo a                   LEFT OUTER JOIN work.stock_brzo_aavulling_II b ON a.Dimset_descr=b.Dimset AND Substr(a.Suppl_nr,2,5)=b.Suppl_nr AND a.SEC_III_HAZ_CAT=b.Sec_III_Haz_Cat;   
QUIT;

DATA work.stock_brzo (DROP=ARIE_deel2 BRZO_deel2) ;
SET work.stock_brzo;
IF ARIE_deel2 NE . 						THEN ARIE_treshold=ARIE_deel2; 
IF BRZO_deel2 NE . 						THEN Sev_III_treshold_1=BRZO_deel2;
IF ARIE_deel2 NE . OR BRZO_deel2 NE . 	THEN Check_losse_stof=1;
RUN;


/**/
/*Losse stoffen gegroepeerd per company en dimset t.b.v. DB2eura.euravib_BRZO_deel_2 - de gevarencategorie buiten beschouwing latend*/
DATA work.Losse_stoffen_ARIE_BRZO;
SET work.stock_brzo;
WHERE Check_losse_stof=1;
RUN;
PROC SORT DATA=work.Losse_stoffen_ARIE_BRZO NODUPKEY; BY Company Warehouse Dimset Suppl_nr; RUN;

PROC SQL;
CREATE TABLE work.Losse_stoffen_ARIE_BRZO AS
SELECT Date()				AS Date			FORMAT DATE9.,
       a.Company,
       a.Dimset,
	   SUM(a.Stock_quan)	AS Stock_quan,
       a.ARIE_treshold,
	   a.Sev_III_treshold_1
FROM work.Losse_stoffen_ARIE_BRZO a
GROUP BY a.Company, a.Dimset;
QUIT;
PROC SORT DATA=work.Losse_stoffen_ARIE_BRZO NODUP; BY Company Dimset; RUN;
/**/

/**/
/*Losse stoffen wegfilteren voor toets tresholdrule. Wel meenemen bij toets sumrule - indelen in gevarencategorie�n*/
PROC SQL;
CREATE TABLE work.Stoffen_totaal AS
SELECT a.*,
	   SUM(a.Check_losse_stof)	AS Check2
FROM  work.stock_brzo a
GROUP BY a.Company, a.Dimset, a.Suppl_nr;
QUIT;

DATA work.stock_brzo_losse_stoffen (DROP=Check_losse_stof Check2);
SET work.Stoffen_totaal;
WHERE Check2 <> .;
RUN;
PROC SORT DATA=work.stock_brzo_losse_stoffen NODUPKEY; BY Company Idno Warehouse Dimset SEC_III_HAZ_CAT_Short; RUN;

DATA work.stock_brzo (DROP=Check_losse_stof Check2);
SET work.Stoffen_totaal;
WHERE Check2=.;
RUN;
/**/

/**************************************************************/

/*Selecteren laagste grenswaarden, apart voor ARIE en BRZO.*/
/*Vervolgens deze tabellen mergen.*/
PROC SORT DATA=work.stock_BRZO OUT=Stock_BRZO_1; BY Company Idno Warehouse Dimset Sev_III_treshold_1 H_ref; RUN;
PROC SORT DATA=work.stock_BRZO OUT=Stock_ARIE_1; BY Company Idno Warehouse Dimset ARIE_treshold H_ref; 		RUN;

PROC SQL;
CREATE TABLE work.stock_BRZO_1 AS
SELECT a.*,
       SUM(a.Sev_III_treshold_1)	AS SUM_Treshold LABEL='SUM_Treshold'
FROM work.stock_BRZO_1 a
GROUP BY a.Company, a.Idno, a.Warehouse, a.Dimset
ORDER BY a.Company, a.Idno, a.Warehouse, a.Dimset, a.Sev_III_treshold_1, a.H_Ref;
QUIT;

DATA work.stock_BRZO_1 (DROP=ARIE_treshold SUM_Treshold);
SET work.stock_BRZO_1;
IF Sev_III_treshold_1=. 					THEN Sev_III_treshold_1=0;
IF SUM_Treshold=. 							THEN SUM_Treshold=0;
IF Sev_III_treshold_1=0 AND SUM_Treshold>0 	THEN DELETE;
RUN;
PROC SORT DATA=work.stock_BRZO_1 NODUPKEY; 	BY Company Idno Warehouse Dimset; RUN;
PROC SORT DATA=work.stock_BRZO_1; 			BY Company Idno Warehouse Dimset H_ref Stock_quan; RUN;

PROC SQL;
CREATE TABLE work.stock_ARIE_1 AS
SELECT a.*,
       SUM(a.ARIE_treshold)	AS SUM_Treshold LABEL='SUM_Treshold'
FROM work.stock_ARIE_1 a
GROUP BY a.Company, a.Idno, a.Warehouse, a.Dimset
ORDER BY a.Company, a.Idno, a.Warehouse, a.Dimset, a.ARIE_treshold, a.H_Ref;;
QUIT;

DATA work.stock_ARIE_1 (DROP=Sev_III_treshold_1 SUM_Treshold);
SET work.stock_ARIE_1;
IF ARIE_treshold=. 							THEN ARIE_treshold=0;
IF SUM_Treshold=. 							THEN SUM_Treshold=0;
IF ARIE_treshold=0 AND SUM_Treshold>0 		THEN DELETE;
RUN;
PROC SORT DATA=work.stock_ARIE_1 NODUPKEY; 	BY Company Idno Warehouse Dimset; 					RUN;
PROC SORT DATA=work.stock_ARIE_1; 			BY Company Idno Warehouse Dimset H_ref Stock_quan; 	RUN;

DATA work.Stock_BRZO;
MERGE work.stock_BRZO_1 work.stock_ARIE_1;
BY Company Idno Warehouse Dimset H_ref Stock_quan;
RUN;
DATA work.Stock_BRZO;
SET work.Stock_BRZO;
IF Sev_III_treshold_1=0 THEN Sev_III_treshold_1=.;
IF ARIE_treshold=0		THEN ARIE_treshold=.;
RUN;

/**/
/**************************************************************/

/*TRESHOLDRULE*/

/*Uitsplitsen EAP-ECP*/

PROC SQL;
CREATE TABLE work.BRZO_Check1_BRZO AS
SELECT  a.Company,
        Date()							AS Date	FORMAT Date9.,
		"Treshold_group_vs_Stock"		AS Check1,
		a.SEC_III_HAZ_CAT               AS SEC_III_HAZ_CAT 			LABEL='SEC_III_HAZ_CAT',
		a.ARIE_Treshold,
		a.SEV_III_TRESHOLD_1			AS Sev_III_Treshold 		LABEL='Sev_III_Treshold',
		"-"								AS SEC_III_HAZ_CAT_Short1 	LABEL='SEC_III_HAZ_CAT_Short1',
		SUM(a.Stock_quan)				AS Stock_quan_BRZO,
		0								AS Factor_ARIE,
		0                               AS Factor_BRZO,
		CASE
		WHEN SUM(a.Stock_quan)<a.SEV_III_TRESHOLD_1 OR a.SEV_III_TRESHOLD_1=.   THEN 'Ok'
													  							ELSE 'Not ok'  END  AS Result_BRZO FORMAT $6.
FROM  work.Stock_BRZO a
GROUP BY a.Company, a.SEC_III_HAZ_CAT, a.SEV_III_TRESHOLD_1;
QUIT;
PROC SORT DATA=work.BRZO_Check1_BRZO nodupkey; 	BY Company SEC_III_HAZ_CAT SEV_III_TRESHOLD; 				RUN;
PROC SORT DATA=work.BRZO_Check1_BRZO; 			BY Company SEC_III_HAZ_CAT ARIE_Treshold SEV_III_TRESHOLD; 	RUN;

PROC SQL;
CREATE TABLE work.BRZO_Check1_ARIE AS
SELECT  a.Company,
        Date()							AS Date	FORMAT Date9.,
		"Treshold_group_vs_Stock"		AS Check1,
		a.SEC_III_HAZ_CAT               AS SEC_III_HAZ_CAT 			LABEL='SEC_III_HAZ_CAT',
		a.ARIE_Treshold,
		a.SEV_III_TRESHOLD_1			AS Sev_III_Treshold 		LABEL='Sev_III_Treshold',
		"-"								AS SEC_III_HAZ_CAT_Short1 	LABEL='SEC_III_HAZ_CAT_Short1',
		SUM(a.Stock_quan)				AS Stock_quan_ARIE,
		0								AS Factor_ARIE,
		0                               AS Factor_BRZO,
		CASE
		WHEN SUM(a.Stock_quan)<a.ARIE_Treshold	OR a.ARIE_Treshold=.			THEN 'Ok'
													  							ELSE 'Not ok'  END  AS Result_ARIE FORMAT $6.
FROM  work.Stock_BRZO a
GROUP BY a.Company, a.SEC_III_HAZ_CAT, a.ARIE_Treshold;
QUIT;
PROC SORT DATA=work.BRZO_Check1_ARIE nodupkey; 	BY Company SEC_III_HAZ_CAT ARIE_Treshold; 					RUN;
PROC SORT DATA=work.BRZO_Check1_ARIE; 		 	BY Company SEC_III_HAZ_CAT ARIE_Treshold SEV_III_TRESHOLD; 	RUN;

DATA work.BRZO_Check1;
MERGE work.BRZO_Check1_BRZO work.BRZO_Check1_ARIE;
BY Company SEC_III_HAZ_CAT ARIE_Treshold SEV_III_TRESHOLD;
RUN;



DATA work.BRZO_check1(Drop= Check1 SEC_III_HAZ_CAT_Short1); SET work.BRZO_check1;
FORMAT SEC_III_HAZ_CAT_Short $1.;
FORMAT Check $50.;
SEC_III_HAZ_CAT_Short=SEC_III_HAZ_CAT_Short1;
Check=Check1;
RUN;


/****************************************/

/*SUMRULE*/

/*Losse stoffen weer toevoegen*/
PROC APPEND BASE=work.Stock_brzo DATA=work.Stock_brzo_losse_stoffen; RUN;

PROC SQL;
CREATE TABLE work.BRZO_Check2 AS
SELECT  a.Company,
        a.SEC_III_HAZ_CAT,
		a.SEC_III_HAZ_CAT_Short, 
		a.ARIE_Treshold,
		a.SEV_III_TRESHOLD_1 				AS SEV_III_TRESHOLD,
		a.Stock_quan,
		a.Stock_quan/a.ARIE_Treshold        AS Factor_ARIE1,
		a.Stock_quan/a.SEV_III_TRESHOLD_1 	AS Factor_BRZO1
FROM  work.Stock_brzo a;
QUIT;

/*Uitsplitsen EAP-ECP*/

PROC SQL;
CREATE TABLE work.BRZO_Check3 AS
SELECT  a.Company,
        Date()							AS Date FORMAT Date9.,
		"Treshold_Category     "		AS Check,
		a.ARIE_Treshold,
		a.Sev_III_Treshold 				AS SEV_III_TRESHOLD         LABEL='SEV_III_TRESHOLD',
        a.SEC_III_HAZ_CAT,
		a.SEC_III_HAZ_CAT_Short			AS SEC_III_HAZ_CAT_Short 	LABEL='SEC_III_HAZ_CAT_Short',
		SUM(a.Stock_quan)               AS Stock_quan_ARIE			LABEL='Stock_quan_ARIE',
		SUM(a.Stock_quan)               AS Stock_quan_BRZO			LABEL='Stock_quan_BRZO',
		SUM(a.Factor_ARIE1)             AS Factor_ARIE,
		SUM(a.Factor_BRZO1)             AS Factor_BRZO,
		CASE
		WHEN SUM(a.Factor_ARIE1) <1        THEN 'Ok  '
										   ELSE 'Not ok'  END  AS Result_ARIE FORMAT $6.,
		CASE
		WHEN SUM(a.Factor_BRZO1) <1 	   THEN 'Ok  '
										   ELSE 'Not ok'  END  AS Result_BRZO FORMAT $6.
FROM  work.BRZO_check2 a
GROUP BY Company, a.SEC_III_HAZ_CAT_Short;
QUIT;
PROC SORT DATA=work.BRZO_Check3 nodupkey; BY Company SEC_III_HAZ_CAT_Short; RUN;

/****************** Exposure Add_Assessm ********************/
PROC SQL;
CREATE TABLE work.Paint_Changes1 AS
SELECT  a.COMPANY 		AS COMPANY,
		b.PROD_LINE 	AS PROD_LINE,
		a.DIMSET 		AS DIMSET,
		a.DATE 			AS DATE,
		COUNT(a.DIMSET) AS COUNT 
FROM db2data.tro_consumptions a LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr 
WHERE a.ITEM_NR="LAK" OR a.ITEM_NR="PRI"
GROUP BY a.Company, b.PROD_LINE, a.DIMSET, a.DATE;
QUIT;

PROC SQL;
CREATE TABLE work.Paint_Changes AS
SELECT  a.COMPANY,
		a.PROD_LINE,
		a.DATE,
		COUNT(a.Dimset) AS COUNT
FROM work.Paint_Changes1 a
GROUP BY a.Company, a.PROD_LINE, a.DATE;
QUIT;


/******  CasCheck Cust *************/
PROC SQL;
CREATE TABLE work.Dimset_CMR AS
SELECT  b.Company,
		a.Suppl_nr,
		a.Dimset,
		a.Rev_date,
		c.CMR_C,
		c.CMR_M,
		c.CMR_R
FROM work.euravib_mixture_h a INNER JOIN work.euravib_main b ON a.Suppl_nr=b.Suppl_nr AND a.Dimset=b.Dimset AND a.Rev_date=b.Rev_date AND b.Active='Y' 
							  LEFT OUTER JOIN work.euravib_h_info c ON a.H_Ref=c.H_Ref 
WHERE (c.CMR_C="C" OR c.CMR_M="M" OR c.CMR_R="R")
ORDER BY b.Company, a.Suppl_nr, a.Dimset ;
QUIT;

DATA work.Dimset_CMR (DROP=C M R); SET work.Dimset_CMR;
BY Company Suppl_nr Dimset;
RETAIN C M R ;
IF First.Dimset 					THEN DO; C=CMR_C; M=CMR_M; R=CMR_R; END;
IF NOT First.Dimset AND CMR_C="" 	THEN CMR_C=C;
IF NOT First.Dimset AND CMR_M="" 	THEN CMR_M=M;
IF NOT First.Dimset AND CMR_R="" 	THEN CMR_R=R;
C=CMR_C; M=CMR_M; R=CMR_R; 
IF NOT Last.dimset 					THEN DELETE;
RUN;

PROC SQL;
CREATE TABLE work.Dimset_CMR AS
SELECT 	a.*,
	   	b.TRO_ord_nr,
		b.Ord_pos,
	   	b.Date			AS Cons_Date 	label='Cons_Date'
FROM work.Dimset_CMR a LEFT OUTER JOIN db2data.tro_consumptions b ON a.Dimset=b.Dimset AND a.company=b.company AND a.suppl_nr=b.suppl_nr;
QUIT;

PROC SQL;
CREATE TABLE work.Dimset_CMR AS
SELECT  a.*,
		b.Dimset AS Tro_Dimset Label='Tro_Dimset',
		b.SAL_ORD_NR,
		b.SAL_ORD_POS
FROM work.Dimset_CMR a LEFT OUTER JOIN db2data.tro_ord b ON a.tro_ord_nr=b.tro_ord_nr AND a.company=b.company;
QUIT;
		
PROC SQL;
CREATE TABLE work.Dimset_CMR AS
SELECT  a.*,
		b.Idno,
		b.Cust_nr,
		b.Weight,
		b.Value_euro	AS Value,
		b.CM_euro		AS CM
FROM work.Dimset_CMR a LEFT OUTER JOIN db2data.cust_cm b ON a.company=b.company AND a.tro_dimset=b.dimset AND a.sal_ord_nr=b.sal_ord_nr AND a.sal_ord_pos=a.sal_ord_pos;
QUIT;

DATA work.Dimset_CMR1; SET work.Dimset_CMR;
FORMAT CMRC $2. ; Length CMRC $2.;
FORMAT CMRM $2. ; Length CMRM $2.;
FORMAT CMRR $2. ; Length CMRR $2.;
IF CMR_C='c' THEN CMRC='c.'; ELSE CMRC=CMR_C;
IF CMR_M='m' THEN CMRC='m.'; ELSE CMRM=CMR_M;
IF CMR_R='r' THEN CMRC='r.'; ELSE CMRR=CMR_R;
RUN;


/* MAX P_HR euravib_main */
PROC SQL;
CREATE TABLE work.max_p_hr AS
SELECT  a.suppl_nr,
		a.dimset,
		a.rev_date,
		a.entry_date,
		MAX(a.p_hr_8h) 			AS Max_P_HR_8h 		FORMAT 11.2,
		MAX(a.p_hr_15m) 		AS Max_P_HR_15m 	FORMAT 11.2,
		MIN(a.FLASH_POINT_C) 	AS MIN_Flash_point 	FORMAT 11.2,
		MAX(a.FLASH_POINT_C) 	AS MAX_Flash_point 	FORMAT 11.2
FROM work.euravib_substance_cas3 a 
GROUP BY a.suppl_nr, a.dimset, a.rev_date, a.entry_date;
QUIT;


PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT  a.*,
		b.MAX_P_HR_8h,
		b.Max_P_HR_15m,
		b.MIN_Flash_point,
		b.MAX_Flash_point
FROM work.euravib_main a LEFT OUTER JOIN work.max_p_hr b on a.dimset=b.dimset and a.suppl_nr=b.suppl_nr and a.rev_date=b.rev_date 
and a.entry_date=b.entry_date;
QUIT;

/* MAX Vappress & pcmax */
PROC SQL;
CREATE TABLE work.euravib_substance_max AS
SELECT  a.suppl_nr,
		a.dimset,
		a.rev_date,
		a.entry_date,
		MAX(a.Pvappress25mbar) 	AS MAX_Pvappress25mbar,
		MAX(a.Pcmax) 			AS MAX_Pcmax
FROM work.euravib_substance_cas2 a
GROUP BY a.dimset, a.suppl_nr, a.rev_date, a.entry_date;
QUIT;

PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT  a.*,
		b.MAX_Pvappress25mbar 	FORMAT 11.2,
		b.MAX_Pcmax 			FORMAT 11.2
FROM work.euravib_main a LEFT OUTER JOIN work.euravib_substance_max b on a.dimset=b.dimset and a.suppl_nr=b.suppl_nr and a.rev_date=b.rev_date and a.entry_date=b.entry_date;
QUIT;
DATA work.euravib_main ; SET work.euravib_main;
IF MAX_Pvappress25mbar=. 	THEN MAX_Pvappress25mbar=0;
IF MAX_Pcmax=. 				THEN MAX_Pcmax=0;
RUN;

/* Boiling Max */
PROC SQL;
CREATE TABLE work.euravib_boiling_max AS
SELECT  a.suppl_nr,
		a.dimset,
		a.rev_date,
		a.entry_date,
		MAX(a.Boiling_MAX) AS Boiling_MAX
FROM work.euravib_substance_cas3 a 
GROUP BY a.suppl_nr, a.dimset, a.rev_date, a.entry_date;
QUIT;

PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT  a.*,
		b.Boiling_MAX FORMAT 11.2
FROM work.euravib_main a LEFT OUTER JOIN work.euravib_boiling_max b on a.dimset=b.dimset and a.suppl_nr=b.suppl_nr and a.rev_date=b.rev_date 
and a.entry_date=b.entry_date;
QUIT;

/***** FOLLOW_UP *****/
PROC SQL;
CREATE TABLE work.euravib_main AS
SELECT  a.*,
		b.Follow_up
FROM work.euravib_main a LEFT OUTER JOIN work.euravib_follow_up b ON a.suppl_nr=b.suppl_nr1 AND a.dimset=b.dimset;
QUIT;


DATA work.euravib_main_1 ; SET work.euravib_main;
FORMAT MAX_Pcmax 11.;
FORMAT Max_P_HR_8h 11.;
FORMAT Max_P_HR_15m 11.;
IF TRO_hist_ly=. 	THEN TRO_hist_ly= 0;
IF Pur_ord=. 		THEN Pur_ord=	  0;
IF Idno_stock=. 	THEN Idno_stock=  0;
IF TRO_hist_lhy=. 	THEN TRO_hist_lhy=0;
IF MAX_Pcmax=. 		THEN MAX_Pcmax=   0;
IF Max_P_HR_8h=. 	THEN Max_P_HR_8h= 0;
IF Max_P_HR_15m=. 	THEN Max_P_HR_15m=0;
IF Boiling_MAX=. 	THEN Boiling_MAX= 0;
IF Follow_Up="" 	THEN Follow_Up="N";
RUN;


/** Control Branding **/
PROC SQL;
CREATE TABLE work.euravib_control_branding_h AS
SELECT  a.*,
CASE	WHEN b.CB_H_Cat=0 			THEN '-'
		WHEN b.CB_H_Cat=1 			THEN 'A.Very Low'
		WHEN b.CB_H_Cat=2 			THEN 'B.Low'
		WHEN b.CB_H_Cat=3 			THEN 'C.Medium'
		WHEN b.CB_H_Cat=4 			THEN 'D.High'
		WHEN b.CB_H_Cat=5 			THEN 'E.Very High' 	END  AS CB_H_Cat FORMAT $15.,
CASE    WHEN a.H_NR contains 'H340' THEN 1 
        WHEN a.H_NR contains 'H350' THEN 1   			END  AS COUNT_H340_H350
FROM work.euravib_mixture_h a LEFT OUTER JOIN work.euravib_h_info b ON a.h_ref=b.h_ref;
QUIT;

PROC SQL;
CREATE TABLE work.euravib_control_branding_h AS
SELECT  a.*,
        COUNT(COUNT_H340_H350) AS CHECK
FROM work.euravib_control_branding_h a
GROUP BY suppl_Nr, dimset, rev_date;
QUIT; 

PROC SORT data=work.euravib_control_branding_h; by suppl_Nr dimset DESCENDING rev_date DESCENDING CB_H_Cat suppl_nr; RUN;

DATA work.euravib_control_branding_h(KEEP= suppl_Nr dimset rev_date entry_date cb_h_cat Check); SET work.euravib_control_branding_h;
by suppl_Nr dimset;
IF not first.dimset THEN DELETE;;
RUN;

PROC SQL;
CREATE TABLE work.euravib_control_branding AS
SELECT  a.*,
		b.CB_H_Cat,
		b.Check
FROM work.euravib_main_1 a LEFT OUTER JOIN work.euravib_control_branding_h b ON a.suppl_Nr=b.suppl_Nr AND a.dimset=b.dimset AND a.rev_date=b.rev_date AND a.entry_date=b.entry_date;
Quit;

PROC SQL;
CREATE TABLE work.euravib_control_branding1 AS
SELECT  a.*,
		b.company,
		b.date,
		b.tro_ord_nr,
		count(b.dimset) AS Count_Dimset
FROM work.euravib_control_branding a LEFT OUTER JOIN db2data.tro_consumptions b ON a.dimset=b.dimset AND a.suppl_nr=b.suppl_nr
WHERE b.date>=date()-730
GROUP BY a.company, a.suppl_nr, a.dimset, a.rev_date, a.entry_date, a.CB_h_CAT, b.date, b.tro_ord_nr;
QUIT;

PROC SQL;
CREATE TABLE work.euravib_control_branding2 AS
SELECT  a.*,
		b.PRD_HOURS
FROM work.euravib_control_branding1 a LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr;
QUIT;

DATA work.euravib_control_branding2; SET work.euravib_control_branding2;
IF Count_Dimset>1 	THEN Count_Dimset=1;
IF PRD_HOURS=. 		THEN PRD_HOURS=0;
RUN;

PROC SQL;
CREATE TABLE work.euravib_control_branding3 AS
SELECT  a.Company,
		a.Suppl_nr,
		a.Dimset,
		a.Rev_date,
		a.Entry_date,
		a.CB_H_CAT,
		a.Check,
		a.Date,
		SUM(a.PRD_HOURS) AS PRD_HOURS
FROM work.euravib_control_branding2 a
GROUP BY  a.Company, a.Suppl_nr, a.Dimset, a.Rev_date, a.Entry_date, a.CB_H_CAT, a.Date;
QUIT;
PROC SORT DATA=work.euravib_control_branding3 nodupkey; BY Company Suppl_nr Dimset Rev_date Entry_date CB_H_CAT Date; RUN;

PROC SQL;
CREATE TABLE work.count_Year AS
SELECT  a.Company,
		a.Suppl_nr,
		a.Dimset,
		a.Rev_date,
		a.Entry_date,
		a.CB_H_CAT,
		a.Check,
		a.Date,
		a.PRD_HOURS,
		COUNT(a.Dimset) AS Count_Year
FROM work.euravib_control_branding3 a
WHERE a.date>=date()-365 AND a.date<=date()
GROUP BY  a.Company, a.Suppl_nr, a.Dimset, a.Rev_date, a.Entry_date, a.CB_H_CAT;
QUIT;

PROC SQL;
CREATE TABLE work.euravib_control_branding4 AS
SELECT  a.Company,
		a.Suppl_nr,
		a.Dimset,
		a.Rev_date,
		a.Entry_date,
		a.CB_H_CAT,
		a.Check,
		a.Date,
		a.PRD_HOURS,
		b.Count_Year
FROM work.euravib_control_branding3 a LEFT OUTER JOIN work.count_year b ON a.Company=b.Company AND a.Suppl_nr=b.Suppl_nr AND a.Dimset=b.Dimset AND a.Rev_date=b.Rev_date 
AND a.Entry_date=b.Entry_date;
QUIT;

DATA work.euravib_control_branding4; SET work.euravib_control_branding4;
FORMAT CB_B_CAT $15.;
IF Count_Year>=104 						THEN CB_B_CAT="5.Very High";
IF Count_Year>=24 AND Count_Year<104  	THEN CB_B_CAT="4.High";
IF Count_Year>12 AND Count_Year<24  	THEN CB_B_CAT="3.Medium";
IF Count_Year>5 AND Count_Year=<12  	THEN CB_B_CAT="2.Low";
IF Count_Year>0 AND Count_Year=<5  		THEN CB_B_CAT="1.Very Low";
IF Count_Year=0 						THEN CB_B_CAT="-";
IF Count_Year=. 						THEN CB_B_CAT="-";
IF Check=.								THEN Check=0;
IF CB_H_CAT="" 							THEN CB_H_CAT="-";
/**/
IF CB_H_CAT="A.Very Low" AND CB_B_CAT='-' 				THEN CB_Value=1;
IF CB_H_CAT="A.Very Low" AND CB_B_CAT='1.Very Low' 		THEN CB_Value=2;
IF CB_H_CAT="A.Very Low" AND CB_B_CAT='2.Low' 			THEN CB_Value=3;
IF CB_H_CAT="A.Very Low" AND CB_B_CAT='3.Medium' 		THEN CB_Value=4;
IF CB_H_CAT="A.Very Low" AND CB_B_CAT='4.High' 			THEN CB_Value=5;
IF CB_H_CAT="A.Very Low" AND CB_B_CAT='5.Very High' 	THEN CB_Value=6;
/**/
IF CB_H_CAT="B.Low" AND CB_B_CAT='-' 					THEN CB_Value=2;
IF CB_H_CAT="B.Low" AND CB_B_CAT='1.Very Low' 			THEN CB_Value=3;
IF CB_H_CAT="B.Low" AND CB_B_CAT='2.Low' 				THEN CB_Value=4;
IF CB_H_CAT="B.Low" AND CB_B_CAT='3.Medium' 			THEN CB_Value=5;
IF CB_H_CAT="B.Low" AND CB_B_CAT='4.High' 				THEN CB_Value=6;
IF CB_H_CAT="B.Low" AND CB_B_CAT='5.Very High' 			THEN CB_Value=7;
/**/
IF CB_H_CAT="C.Medium" AND CB_B_CAT='-' 				THEN CB_Value=3;
IF CB_H_CAT="C.Medium" AND CB_B_CAT='1.Very Low' 		THEN CB_Value=4;
IF CB_H_CAT="C.Medium" AND CB_B_CAT='2.Low' 			THEN CB_Value=5;
IF CB_H_CAT="C.Medium" AND CB_B_CAT='3.Medium' 			THEN CB_Value=6;
IF CB_H_CAT="C.Medium" AND CB_B_CAT='4.High' 			THEN CB_Value=7;
IF CB_H_CAT="C.Medium" AND CB_B_CAT='5.Very High' 		THEN CB_Value=8;
/**/
IF CB_H_CAT="D.High" AND CB_B_CAT='-' 					THEN CB_Value=4;
IF CB_H_CAT="D.High" AND CB_B_CAT='1.Very Low' 			THEN CB_Value=5;
IF CB_H_CAT="D.High" AND CB_B_CAT='2.Low' 				THEN CB_Value=6;
IF CB_H_CAT="D.High" AND CB_B_CAT='3.Medium' 			THEN CB_Value=7;
IF CB_H_CAT="D.High" AND CB_B_CAT='4.High' 				THEN CB_Value=8;
IF CB_H_CAT="D.High" AND CB_B_CAT='5.Very High' 		THEN CB_Value=9;
/**/
IF CB_H_CAT="E.Very High" AND CB_B_CAT='-' 				THEN CB_Value=5;
IF CB_H_CAT="E.Very High" AND CB_B_CAT='1.Very Low' 	THEN CB_Value=6;
IF CB_H_CAT="E.Very High" AND CB_B_CAT='2.Low' 			THEN CB_Value=7;
IF CB_H_CAT="E.Very High" AND CB_B_CAT='3.Medium' 		THEN CB_Value=8;
IF CB_H_CAT="E.Very High" AND CB_B_CAT='4.High' 		THEN CB_Value=9;
IF CB_H_CAT="E.Very High" AND CB_B_CAT='5.Very High' 	THEN CB_Value=10;
/**/
IF CB_H_CAT="-" AND CB_B_CAT='-' 						THEN CB_Value=0;
IF CB_H_CAT="-" AND CB_B_CAT='1.Very Low' 				THEN CB_Value=1;
IF CB_H_CAT="-" AND CB_B_CAT='2.Low' 					THEN CB_Value=2;
IF CB_H_CAT="-" AND CB_B_CAT='3.Medium' 				THEN CB_Value=3;
IF CB_H_CAT="-" AND CB_B_CAT='4.High' 					THEN CB_Value=4;
IF CB_H_CAT="-" AND CB_B_CAT='5.Very High' 				THEN CB_Value=5;
/**/
IF CB_Value=. THEN CB_Value=0;
/**/
IF Check>0 AND CB_Value<7 THEN CB_Value=7;
RUN;

PROC SORT data=work.euravib_control_branding4; by suppl_nr dimset rev_date entry_date; RUN;

PROC SQL;
CREATE TABLE work.euravib_control_branding4 AS
SELECT  a.*,
		b.In_USE,
		b.Active
FROM work.euravib_control_branding4 a LEFT OUTER JOIN work.euravib_main_1 b ON a.suppl_nr=b.suppl_nr AND a.dimset=b.dimset AND a.rev_date=b.rev_date AND a.entry_date=b.entry_date;
QUIt;

DATA work.euravib_control_branding4 (DROP=Check); SET work.euravib_control_branding4;
IF active NE'Y' AND In_USE NE "Y" 	THEN DELETE;
IF active='Y' AND In_USE="N" 		THEN DELETE;
IF active='N' AND In_USE="Y" 		THEN DELETE;
RUN;

/*** Adding Control Branding Labels to Euravib Main ***/
DATA work.euravib_control_branding5; SET work.euravib_control_branding4;
by suppl_nr dimset rev_date entry_date;
IF NOT last.dimset THEN DELETE;
RUN;

PROC SQL;
CREATE TABLE work.euravib_main_2 AS
SELECT  a.*,
		b.CB_H_CAT,
		b.CB_B_CAT,
		b.CB_Value
FROM work.euravib_main_1 a LEFT OUTER JOIN work.euravib_control_branding5 b ON a.suppl_nr=b.suppl_nr AND a.dimset=b.dimset AND a.rev_date=b.rev_date AND a.entry_date=b.entry_date;
QUIT;

DATA work.euravib_main_2; SET work.euravib_main_2;
IF CB_B_CAT="" 	THEN CB_B_CAT="-";
IF CB_H_CAT="" 	THEN CB_H_CAT="-";
IF CB_Value=. 	THEN CB_Value=0;
IF substr(dimset,1,3)='00A' AND length(dimset)=7  	THEN Dimset_descr=TRIM(Dimset_descr)||".00"; 
IF substr(dimset,1,3)='09A' AND length(dimset)=7 	THEN Dimset_descr=TRIM(Dimset_descr)||".00"; 
dimset_descr_dms=compress(lowcase(Dimset_Descr));
RUN;

/*
PROC IMPORT OUT= Work.Euravib_ControlBandingIndex
 			DATAFILE= "\\spinyspider\Projects\Data exchange folder for the HSE department\SAS IMPORTS\BlootstellingsIndex.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Sheet1$A1:C100"; 
     GETNAMES=YES;
RUN;
*/

/*** ADD DOC_ID FOR Zenya ***/
libname iDocP ODBC  dsn='iProvaPrd' schema=iDocument user=odbc password=ODBC;
PROC SQL;
CREATE TABLE work.iDocuments AS
SELECT  
a.fldDocumentVersionID 		AS DOCUMENTVERSIONID 	Label='DocumentVersionID',
c.fldDocumentID 			AS DocumentID 			Label='DocumentID',
a.fldTitle 					AS DocumentTitle 		Label='DocumentTitle',
d.fldPath 					AS DocumentPath 		Label='DocumentPath',
a.fldVersion 				AS Version 				Label='Version',
a.fldPublishedDateTime 		AS PublishedDateTime 	Label='PublishedDateTime',
a.fldState 					AS fldState 			Label='fldState',
a.fldLastModifiedDateTime 	AS LastModifiedDateTime Label='LastModifiedDateTime'
FROM idocp.tbddocumentversion a,
	 idocp.tbdDocumentTypeName b,
     idocp.tbdDocument c,
     idocp.tbdfolder d
WHERE a.fldDocumentTypeID=b.fldDocumentTypeID AND b.fldLanguage='en-US' AND a.fldDocumentID=c.fldDocumentID AND c.fldFolderID=d.fldFolderID AND a.fldState=4 ;
QUIT;

Data work.euravib_main_2; set work.euravib_main_2;
DOC_dimset=dimset;
IF substr(dimset,1,3)='00A' AND length(dimset)=7  THEN DOC_DIMSET=TRIM(dimset)||".00"; 
IF substr(dimset,1,3)='09A' AND length(dimset)=7  THEN DOC_DIMSET=TRIM(dimset)||".00"; 
DOC_suppl_nr=Compress(suppl_nr);
DOC_title=DOC_suppl_nr || DOC_DIMSET;
Run;

Proc SQL;
Create Table work.euravib_main_3 AS
select a.*, b.DocumentID AS DOC_ID
from work.euravib_main_2 a LEFT OUTER JOIN  work.Idocuments b ON a.DOC_title = b.DocumentTitle;
quit;

/* Bullit correction */
DATA work.euravib_main_3; SET work.euravib_main_3;
IF Company='Roe' THEN ACTIVE='N';
IF Company='Roe' THEN IN_USE='N';
RUN;

PROC SORT DATA=work.euravib_main_3 nodupkey; by company suppl_nr dimset entry_date rev_date; RUN;


/* Read out Classification GADSL Automative */
PROC IMPORT OUT= work.GADSL_Automotive 
 			DATAFILE= "\\spinyspider\projects\Data exchange folder for the HSE department\sas imports\GADSL Automotive.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Sheet1$A1:F8000"; 
     GETNAMES=YES;
RUN;

PROC SORT DATA=work.GADSL_Automotive; BY CAS_nr Revision_Date; RUN;

DATA work.GADSL_Automotive(DROP=VAR5); SET work.GADSL_Automotive;
BY CAS_nr Revision_Date; 
IF CAS_Description = "" AND CAS_nr = "" THEN DELETE;
IF NOT LAST.Revision_Date THEN DELETE;
Source=VAR5;
RUN;
		

PROC SQL;
CREATE TABLE work.Euravib_Cas_Ref  AS
SELECT  a.*,
		b.Classification,
		b.Reason_Code,
		b.Source
FROM work.Euravib_Cas_Ref a LEFT OUTER JOIN work.GADSL_Automotive b ON a.CAS_nr=b.CAS_nr;
QUIT;


/* Euravib Cas Rel Add Gevarengroep_GG */
PROC SQL;
CREATE TABLE work.Euravib_Cas_H_Rel AS
SELECT a.*,
		b.Gevarengroep_GG
FROM work.Euravib_Cas_H_Rel a LEFT OUTER JOIN db2itask.icard_hse_substance_skin b ON a.H_NR=b.Hazard_Sentences;
QUIT;


/***********************************************/
/************* Import ZZS Euravib **************/
/***********************************************/
data WORK.zzs_totale_lijst  ;
%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
infile '\\Spinyspider\Projects\Data exchange folder for the HSE department\SAS IMPORTS\ZZS-totale-lijst.txt' delimiter='09'x
MISSOVER DSD lrecl=32767 firstobs=2 ;
		 informat CAS_nummer $11. ;
		 informat EG_nummer $9. ;
		 informat Nederlands_stofnaam $157. ;
		 informat Engelse_stofnaam $159. ;
		 informat ZZS_volgens_EU_gevaarsindeling $3. ;
		 informat ZZS_volgens_REACH $3. ;
		 informat ZZS_volgens_KRW $3. ;
		 informat ZZS_volgens_OSPAR $3. ;
		 informat ZZS_volgens_EU_POP_Verordening $3. ;
		 informat Stofklasse_voor_luchtemissies $5. ;
		 informat Grensmassastroom $10. ;
		 informat Emissiegrenswaarde $11. ;
		 informat Datum_toevoeging DDMMYY9. ;
		 informat Voetnoot1 $210. ;
		 informat Voetnoot2 $196. ;
		 format CAS_nummer $11. ;
		 format EG_nummer $9. ;
		 format Nederlands_stofnaam $157. ;
		 format Engelse_stofnaam $159. ;
		 format ZZS_volgens_EU_gevaarsindeling $3. ;
		 format ZZS_volgens_REACH $3. ;
		 format ZZS_volgens_KRW $3. ;
		 format ZZS_volgens_OSPAR $3. ;
		 format ZZS_volgens_EU_POP_Verordening $3. ;
		 format Stofklasse_voor_luchtemissies $5. ;
		 format Grensmassastroom $10. ;
		 format Emissiegrenswaarde $11. ;
		 format Datum_toevoeging DDMMYY9. ;
		 format Voetnoot1 $210. ;
		 format Voetnoot2 $196. ;
	  input
		CAS_nummer  $
		EG_nummer  $
		Nederlands_stofnaam  $
		Engelse_stofnaam  $
		ZZS_volgens_EU_gevaarsindeling  $
		ZZS_volgens_REACH  $
		ZZS_volgens_KRW  $
		ZZS_volgens_OSPAR  $
		ZZS_volgens_EU_POP_Verordening  $
		Stofklasse_voor_luchtemissies  $
		Grensmassastroom  $
		Emissiegrenswaarde  $
		Datum_toevoeging
		Voetnoot1  $
		Voetnoot2  $
	  ;
if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;


PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp');
EXECUTE (DELETE FROM euravib.Euravib_BRZO_Deel_2) by db2;  

QUIT;

PROC APPEND BASE=DB2Eura.Euravib_BRZO_Deel_2 DATA=work.Losse_stoffen_ARIE_BRZO; RUN;


PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp');
EXECUTE (Drop table euravib.Euravib_ZZS) by db2;
EXECUTE (Create table euravib.Euravib_ZZS	(	CAS_nummer						Char(11) ,
												EG_nummer						Char(9),
												Nederlands_stofnaam				varChar(500),								
												Engelse_stofnaam				varchar(500),								
												ZZS_volgens_EU_gevaarsindeling	Char(3),								
												ZZS_volgens_REACH				char(3),								
												ZZS_volgens_KRW					char(3),								
												ZZS_volgens_OSPAR				char(3),								
												ZZS_volgens_EU_POP_Verordening	char(3),								
												Stofklasse_voor_luchtemissies	char(10),								
												Grensmassastroom				char(20),								
												Datum_toevoeging				Date,							
												Voetnoot1						varchar(500),								
												Voetnoot2						varchar(500))) by db2;
EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_ZZS TO USER INFODBC )  by db2;
QUIT;

PROC APPEND BASE=DB2eura.Euravib_ZZS (BULKLOAD=YES) DATA=work.zzs_totale_lijst FORCE; RUN;


/* Euravib ZZS*/
PROC SQL;
CREATE TABLE work.euravib_main_4 AS
SELECT a.*,
		MIN(c.Datum_toevoeging) AS ZZS_Datum label='ZZS_Datum' FORMAT DATE9.
FROM work.euravib_main_3 a 
LEFT OUTER JOIN DB2eura.euravib_substance_cas b ON a.rev_date=b.rev_date AND a.entry_date=b.entry_date AND a.dimset=b.dimset AND a.suppl_nr=b.suppl_nr
LEFT OUTER JOIN DB2eura.Euravib_ZZS c 			ON b.cas_nr=c.CAS_nummer
GROUP BY a.company, a.suppl_nr, a.dimset, a.rev_date, a.entry_date;
QUIT;

PROC SORT data=work.euravib_main_4 nodupkey; by company suppl_nr dimset rev_date entry_date; RUN;



/************************************************************/
/***** Update Databases									*****/
/************************************************************/
PROC SQL;
	CONNECT to odbc as db2 (dsn='db2ecp');
	EXECUTE (Truncate euravib.Euravib_CMR_Sales ignore delete triggers drop storage immediate ) 			by db2;
	EXECUTE (Truncate euravib.Euravib_Specials ignore delete triggers drop storage immediate ) 				by db2;
	EXECUTE (Truncate euravib.Paint_Changes ignore delete triggers drop storage immediate ) 				by db2;
	EXECUTE (Truncate euravib.Euravib_Add_Assessm ignore delete triggers drop storage immediate ) 			by db2;
	EXECUTE (Truncate euravib.Euravib_H_Info ignore delete triggers drop storage immediate ) 				by db2;
	EXECUTE (Truncate euravib.Euravib_P_Sentence ignore delete triggers drop storage immediate ) 			by db2;
	EXECUTE (Truncate euravib.Euravib_H_Sentence ignore delete triggers drop storage immediate ) 			by db2;
	EXECUTE (Truncate euravib.Euravib_SignalWord ignore delete triggers drop storage immediate ) 			by db2;
	EXECUTE (Truncate euravib.Euravib_H_P_Rel ignore delete triggers drop storage immediate ) 				by db2;
	EXECUTE (Truncate euravib.Euravib_Cas_H_Rel ignore delete triggers drop storage immediate ) 			by db2;
	EXECUTE (Truncate euravib.Euravib_Substance_Cas ignore delete triggers drop storage immediate ) 		by db2;
	EXECUTE (Truncate euravib.Euravib_Main ignore delete triggers drop storage immediate ) 					by db2;
	EXECUTE (Truncate euravib.Euravib_Exposure_cmr ignore delete triggers drop storage immediate )		 	by db2;
	EXECUTE (Truncate euravib.Euravib_Exposure_base ignore delete triggers drop storage immediate ) 		by db2;
	EXECUTE (Truncate euravib.Euravib_BRZO_stock ignore delete triggers drop storage immediate ) 			by db2;
	EXECUTE (Truncate euravib.Euravib_BRZO_kpi ignore delete triggers drop storage immediate ) 				by db2;
	EXECUTE (Truncate euravib.Euravib_Control_Branding ignore delete triggers drop storage immediate ) 		by db2;
	EXECUTE (Truncate euravib.Euravib_Lab_codes ignore delete triggers drop storage immediate ) 			by db2;
QUIT;


PROC APPEND BASE=DB2eura.Euravib_Main 					(BULKLOAD=YES) DATA=work.euravib_main_4 	FORCE; RUN;


PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp');
EXECUTE (DELETE FROM euravib.Euravib_Mixture_H) by db2;  

QUIT;

PROC APPEND BASE=DB2eura.Euravib_Mixture_H (BULKLOAD=YES) DATA=work.Euravib_Mixture_H   FORCE;RUN;


PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp');
EXECUTE (DELETE FROM euravib.Euravib_P_Sentence) by db2;  
QUIT;

PROC APPEND BASE=DB2eura.Euravib_P_Sentence (BULKLOAD=YES) DATA=work.Euravib_P_Sentence FORCE; RUN;


PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp');
EXECUTE (DELETE FROM euravib.Euravib_H_Sentence) by db2; 
QUIT;

PROC APPEND BASE=DB2eura.Euravib_H_Sentence (BULKLOAD=YES) DATA=work.Euravib_H_Sentence FORCE; RUN;

PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp');
EXECUTE (DELETE FROM euravib.Euravib_Cas_Ref) by db2;  

QUIT;

PROC APPEND BASE=DB2eura.Euravib_Cas_Ref 				DATA=work.Euravib_Cas_Ref 				FORCE; RUN;


PROC APPEND BASE=DB2eura.Euravib_Specials 				(BULKLOAD=YES) DATA=work.Euravib_Specials1 				FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_CMR_Sales 				(BULKLOAD=YES) DATA=work.Dimset_CMR1 					FORCE; RUN;
PROC APPEND BASE=DB2eura.Paint_Changes 					(BULKLOAD=YES) DATA=work.Paint_Changes 					FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_Add_Assessm 			(BULKLOAD=YES) DATA=work.Euravib_Add_Assessm 			FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_H_Info 				(BULKLOAD=YES) DATA=work.Euravib_H_Info 				FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_SignalWord 			(BULKLOAD=YES) DATA=work.Euravib_SignalWord 			FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_H_P_Rel 				(BULKLOAD=YES) DATA=work.Euravib_H_P_Rel 				FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_Cas_H_Rel 				(BULKLOAD=YES) DATA=work.Euravib_Cas_H_Rel 				FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_Substance_Cas 			(BULKLOAD=YES) DATA=work.Euravib_Substance_Cas3 		FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_Exposure_cmr 			(BULKLOAD=YES) DATA=work.exposure_cmr 					FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_Exposure_base 			(BULKLOAD=YES) DATA=work.exposure_base 					FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_BRZO_stock 			(BULKLOAD=YES) DATA=work.stock_brzo 					FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_BRZO_kpi 				(BULKLOAD=YES) DATA=work.BRZO_Check1 					FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_BRZO_kpi 				(BULKLOAD=YES) DATA=work.BRZO_Check3 					FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_Control_Branding 		(BULKLOAD=YES) DATA=work.Euravib_Control_Branding4 		FORCE; RUN;
PROC APPEND BASE=DB2eura.Euravib_Lab_codes 				(BULKLOAD=YES) DATA=work.Euravib_Lab_codes 				FORCE; RUN;


PROC SQL;
	CONNECT to odbc as db2 (dsn='db2ecp');
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_CMR_Sales TO USER INFODBC )  				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Specials TO USER INFODBC ) 				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Paint_Changes TO USER INFODBC ) 					by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Add_Assessm TO USER INFODBC ) 				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_H_Info TO USER INFODBC )  					by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_SignalWord TO USER INFODBC ) 				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_H_P_Rel TO USER INFODBC ) 					by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Cas_H_Rel TO USER INFODBC ) 				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Cas_Ref TO USER INFODBC ) 					by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Substance_Cas TO USER INFODBC ) 			by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Mixture_H TO USER INFODBC ) 				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Main TO USER INFODBC ) 					by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Exposure_cmr TO USER INFODBC ) 			by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Exposure_base TO USER INFODBC ) 			by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_BRZO_kpi TO USER INFODBC ) 				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_BRZO_stock TO USER INFODBC ) 				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_BRZO_deel_2 TO USER INFODBC ) 				by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Control_Branding TO USER INFODBC ) 		by db2;
	EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Lab_codes TO USER INFODBC ) 				by db2;
QUIT;


/**********************************************************************/
/****    Import BRZO/ARIE list hist stock Data					   ****/
/**********************************************************************/
 
/*IDno-stock*/

DATA work.idno_stock_week;
SET db2data.idno_stock_week;
FORMAT Dimset1 $50.;
Dimset1=Dimset;
WHERE Storage_date>=TODAY()-360;
RUN;

PROC SQL;
CREATE TABLE work.stock_brzo_hist AS
SELECT	a.Company,
        a.Storage_date 					AS Date LABEL='Date',
		a.Idno,
		a.Item_nr,
		a.Warehouse,
		a.Dimset1						AS Dimset LABEL='Dimset',
		b.Dimset_Descr,
		a.Suppl_nr,
		a.Stock_quan,
		c.H_Nr,
		c.H_Cat,
		c.H_Ref,
		b.Rev_date,
		d.ARIE_Treshold,
		d.SEV_III_TRESHOLD_1,
		d.SEC_III_HAZ_CAT				AS SEC_III_HAZ_CAT  		Label='SEC_III_HAZ_CAT',
		substr(d.SEC_III_HAZ_CAT,1,1) 	AS SEC_III_HAZ_CAT_Short	Label='SEC_III_HAZ_CAT_Short'
FROM work.idno_stock_week a,
	 work.Euravib_main b,
	 work.Euravib_mixture_h c,
	 work.Euravib_H_Info d
WHERE (a.company=b.Company AND a.dimset=b.dimset     AND b.Active="Y"          AND a.suppl_nr=b.Suppl_nr AND a.Warehouse<>'CWM'           AND a.Company IN("ECP","EAP") AND
      a.Dimset=c.Dimset    AND b.Suppl_nr=c.Suppl_nr AND b.Rev_Date=c.Rev_Date AND c.H_Ref=d.H_Ref       AND a.Storage_date>=today()-360) AND (SEV_III_TRESHOLD_1 <> . OR ARIE_treshold <> . )      
ORDER BY a.Company, a.Storage_date, a.Idno, a.Item_nr, a.Dimset;
QUIT;

/*IDno-stock - Warehouse CON*/

PROC SQL;
CREATE TABLE work.stock_brzo_hist_CON AS
SELECT	a.Company,
        a.Storage_date 						AS Date 			LABEL='Date',
		a.Idno,
		a.Item_nr,
		a.Location							AS Warehouse		LABEL='Warehouse',
		a.Dimset,
		Substr(b.MSDS,7)					AS Dimset_Descr		LABEL='Dimset_Descr',
		a.Suppl_nr,
		a.Stock_quan
FROM db2data.idno_stock_week a INNER JOIN work.iCard_Stock_Haz_Sub_Site_CON b ON a.Company=b.Company AND a.Dimset=b.Dimset
WHERE a.Warehouse='CON' AND a.Storage_date>=today()-360  AND a.Storage_date>=MDY(03,13,2023) 
ORDER BY a.Company, a.Storage_date, a.Idno, a.Item_nr, a.Dimset;
QUIT;

PROC SQL;
CREATE TABLE work.stock_brzo_hist_CON AS
SELECT	a.*,
		c.H_Nr,
		c.H_Cat,
		c.H_Ref,
		b.Rev_date,
		d.ARIE_Treshold,
		d.SEV_III_TRESHOLD_1,
		d.SEC_III_HAZ_CAT				AS SEC_III_HAZ_CAT  		Label='SEC_III_HAZ_CAT',
		substr(d.SEC_III_HAZ_CAT,1,1) 	AS SEC_III_HAZ_CAT_Short	Label='SEC_III_HAZ_CAT_Short'
FROM work.stock_brzo_hist_CON a,
	 work.Euravib_main b,
	 work.Euravib_mixture_h c,
	 work.Euravib_H_Info d
WHERE (a.Company=b.Company 		AND a.Dimset_Descr=b.dimset AND b.Active="Y"          AND a.suppl_nr=b.Suppl_nr AND
      a.Dimset_Descr=c.Dimset   AND b.Suppl_nr=c.Suppl_nr   AND b.Rev_Date=c.Rev_Date AND c.H_Ref=d.H_Ref       AND (SEV_III_TRESHOLD_1 <> . OR ARIE_treshold <> . ))     
ORDER BY a.Company, a.Date, a.Idno, a.Item_nr, a.Dimset;
QUIT;

PROC APPEND BASE=stock_brzo_hist DATA=stock_brzo_hist_CON FORCE; RUN;

DATA work.stock_brzo_hist;
SET work.stock_brzo_hist;
IF Date=Date() 										THEN DELETE;
IF Date>='01JAN2022'd AND Company='Roe' 			THEN DELETE;
RUN;

/*Extra items (Kaartenbak)*/

PROC SQL;
CREATE TABLE work.store_dates AS
SELECT   a.Date,
		 count(idno)	AS Counter
FROM  work.stock_brzo_hist a
GROUP BY a.Date;
QUIT;


PROC SQL;
CREATE TABLE work.BRZO_specials AS
SELECT   a.*,
		 b.Date		AS DateNew LABEL='DateNew'
FROM  db2eura.Euravib_BRZO_stock a,
	  work.store_dates b
WHERE  a.ITEM_NR="Extra";
QUIT;

DATA work.BRZO_specials (DROP=DateNew);
SET work.BRZO_specials;
Date=DateNew;
RUN;

PROC APPEND BASE=work.stock_brzo_hist DATA=work.BRZO_specials FORCE; RUN;

PROC SQL;
CREATE TABLE work.stock_brzo_hist AS
SELECT	a.Company,
        a.Date,
        a.IDNO,
		a.Item_nr,
		a.Warehouse,
		a.Dimset,
		a.Dimset_descr,
		a.Suppl_nr,
		a.Stock_quan,
		a.H_nr,
		a.H_cat,
		a.H_ref,
		a.Rev_date,
		a.ARIE_treshold,
		a.Sev_III_treshold_1,
		a.SEC_III_HAZ_CAT,
		a.SEC_III_HAZ_CAT_Short,
        COMPRESS(PUT(b.Flashpoint, $20.),'�C>') AS Flashpoint  LABEL='Flashpoint'
FROM work.stock_brzo_hist a		LEFT OUTER JOIN Db2eura.Euravib_import b 		ON TRIM(a.Dimset)=TRIM(b.Dimset) 				AND Substr(a.Suppl_nr,2,5)=b.Suppl_nr AND a.Rev_date=b.Rev_date;
QUIT;

PROC SQL;
CREATE TABLE work.stock_brzo_hist AS
SELECT	a.*,
		COMPRESS(PUT(b.Flashpoint, $20.),'�C>') AS Flashpoint_C1 LABEL='Flashpoint_C1'
FROM work.stock_brzo_hist a		LEFT OUTER JOIN	Db2eura.Euravib_import b 		ON TRIM(a.Dimset)=TRIM(Substr(b.Dimset,1,7)) AND Substr(a.Suppl_nr,2,5)=b.Suppl_nr AND a.Rev_date=b.Rev_date AND a.Flashpoint IS MISSING
ORDER BY a.Company, a.Dimset, a.Idno, a.H_Ref;
QUIT;

DATA work.stock_brzo_hist (DROP=Flashpoint_C1 Index Boilingpoint_C Ambient_temp_C Flashpoint Flashpoint_C Rev_date);
SET work.stock_brzo_hist;
FORMAT Boilingpoint_C   $2.;
FORMAT Ambient_temp_C 	$2.;
Boilingpoint_C	=55; /*Vastgelegd in opdracht van HH d.d. 2023-01*/
Ambient_temp_C	=20; /*Vastgelegd in opdracht van HH d.d. 2023-01*/
/*Klaarzetten juiste data*/
IF Flashpoint="" 																											THEN Flashpoint=Flashpoint_C1; ELSE Flashpoint=Flashpoint;
Index=(Index(Flashpoint,'-'));
IF Index=1 																													THEN Flashpoint=Flashpoint;
IF Index>1 																													THEN Flashpoint=Substr(Flashpoint,1,Index-1);
Flashpoint_C=INPUT(Flashpoint, 3.);
/*Bepaling aangepaste grenswaarden*/
IF H_Ref IN('H225-2','H226-3') AND Ambient_temp_C > Boilingpoint_C 															THEN ARIE_treshold=3000;
IF H_Ref IN('H225-2','H226-3') AND Flashpoint_C > 60 AND Ambient_temp_C > Flashpoint_C 										THEN ARIE_treshold=3000;
IF H_Ref IN('H225-2','H226-3') AND Ambient_temp_C > Flashpoint_C AND Ambient_temp_C < Boilingpoint_C 						THEN ARIE_treshold=15000;
IF H_Ref IN('H225-2','H226-3') AND Flashpoint_C <= 60 AND Ambient_temp_C > Flashpoint_C AND Ambient_temp_C < Boilingpoint_C THEN ARIE_treshold=15000;
RUN;

/*Aanvulling deel II (ARIE&BRZO*/

PROC SQL;
CREATE TABLE work.stock_brzo_hist AS
SELECT  a.*,
        b.ARIE_treshold			AS ARIE_deel2		LABEL='ARIE_deel2',
		b.Sev_III_treshold_1	AS BRZO_deel2		LABEL='BRZO_deel2' 
FROM work.stock_brzo_hist a                   LEFT OUTER JOIN work.stock_brzo_aavulling_II b ON a.Dimset_descr=b.Dimset AND Substr(a.Suppl_nr,2,5)=b.Suppl_nr AND a.SEC_III_HAZ_CAT=b.Sec_III_Haz_Cat;   
QUIT;

DATA work.stock_brzo_hist (DROP=ARIE_deel2 BRZO_deel2) ;
SET work.stock_brzo_hist;
IF ARIE_deel2 NE . 						THEN ARIE_treshold=ARIE_deel2;
IF BRZO_deel2 NE . 						THEN Sev_III_treshold_1=BRZO_deel2;
IF ARIE_deel2 NE . OR BRZO_deel2 NE . 	THEN Check_losse_stof=1;
RUN;


/*Losse stoffen gegroepeerd per datum, company en dimset t.b.v. DB2eura.euravib_BRZO_deel_2*/
/**/
DATA work.Losse_stoffen_ARIE_BRZO_hist;
SET work.stock_brzo_hist;
WHERE Check_losse_stof=1;
RUN;
PROC SORT DATA=work.Losse_stoffen_ARIE_BRZO_hist NODUPKEY; BY Date Company Warehouse Dimset Suppl_nr; RUN;

PROC SQL;
CREATE TABLE work.Losse_stoffen_ARIE_BRZO_hist AS
SELECT a.Date,
       a.Company,
       a.Dimset,
	   SUM(a.Stock_quan)	AS Stock_quan,
       a.ARIE_treshold,
	   a.Sev_III_treshold_1
FROM work.Losse_stoffen_ARIE_BRZO_hist a
GROUP BY a.Date, a.Company, a.Dimset;
QUIT;
PROC SORT DATA=work.Losse_stoffen_ARIE_BRZO_hist NODUP; BY Date Company Dimset; RUN;
/**/

/*Losse stoffen wegfilteren voor toets tresholdrule. Wel meenemen bij toets sumrule - alle van toepassing zijnde categorie�n short*/

PROC SQL;
CREATE TABLE work.Stoffen_totaal_hist AS
SELECT a.*,
	   SUM(a.Check_losse_stof)	AS Check2
FROM  work.stock_brzo_hist a
GROUP BY a.Date, a.Company, a.Dimset, a.Suppl_nr;
QUIT;

DATA work.stock_brzo_losse_stoffen_hist (DROP=Check_losse_stof Check2);
SET work.Stoffen_totaal_hist;
WHERE Check2 <> .;
RUN;
PROC SORT DATA=work.stock_brzo_losse_stoffen_hist NODUPKEY; BY Date Company Idno Warehouse Dimset SEC_III_HAZ_CAT_Short; RUN;

DATA work.stock_brzo_hist (DROP=Check_losse_stof Check2);
SET work.Stoffen_totaal_hist;
WHERE Check2=.;
RUN;


/**************************************************************/

/*Selecteren laagste grenswaarden, apart voor ARIE en BRZO.*/
/*Vervolgens deze tabellen mergen.*/
PROC SORT DATA=work.stock_BRZO_hist OUT=Stock_BRZO_1_hist; BY Date Company Idno Warehouse Dimset Sev_III_treshold_1 H_ref;  RUN;
PROC SORT DATA=work.stock_BRZO_hist OUT=Stock_ARIE_1_hist; BY Date Company Idno Warehouse Dimset ARIE_treshold H_ref; 		RUN;

PROC SQL;
CREATE TABLE work.stock_BRZO_1_hist AS
SELECT a.*,
       SUM(a.Sev_III_treshold_1)	AS SUM_Treshold LABEL='SUM_Treshold'
FROM work.stock_BRZO_1_hist a
GROUP BY a.Date, a.Company, a.Idno, a.Warehouse, a.Dimset
ORDER BY a.Date, a.Company, a.Idno, a.Warehouse, a.Dimset, a.Sev_III_treshold_1, a.H_Ref;
QUIT;

DATA work.stock_BRZO_1_hist (DROP=ARIE_treshold SUM_Treshold);
SET work.stock_BRZO_1_hist;
IF Sev_III_treshold_1=. 					THEN Sev_III_treshold_1=0;
IF SUM_Treshold=. 							THEN SUM_Treshold=0;
IF Sev_III_treshold_1=0 AND SUM_Treshold>0 	THEN DELETE;
RUN;
PROC SORT DATA=work.stock_BRZO_1_hist NODUPKEY; 	BY Date Company Idno Warehouse Dimset; 					RUN;
PROC SORT DATA=work.stock_BRZO_1_hist; 				BY Date Company Idno Warehouse Dimset H_ref Stock_quan; RUN;

PROC SQL;
CREATE TABLE work.stock_ARIE_1_hist AS
SELECT a.*,
       SUM(a.ARIE_treshold)	AS SUM_Treshold LABEL='SUM_Treshold'
FROM work.stock_ARIE_1_hist a
GROUP BY a.Company, a.Idno, a.Warehouse, a.Dimset
ORDER BY a.Company, a.Idno, a.Warehouse, a.Dimset, a.ARIE_treshold, a.H_Ref;;
QUIT;

DATA work.stock_ARIE_1_hist (DROP=Sev_III_treshold_1 SUM_Treshold);
SET work.stock_ARIE_1_hist;
IF ARIE_treshold=. 							THEN ARIE_treshold=0;
IF SUM_Treshold=. 							THEN SUM_Treshold=0;
IF ARIE_treshold=0 AND SUM_Treshold>0 		THEN DELETE;
RUN;
PROC SORT DATA=work.stock_ARIE_1_hist NODUPKEY; BY Date Company Idno Warehouse Dimset; 					RUN;
PROC SORT DATA=work.stock_ARIE_1_hist; 			BY Date Company Idno Warehouse Dimset H_ref Stock_quan; RUN;

DATA work.Stock_BRZO_hist;
MERGE work.stock_BRZO_1_hist work.stock_ARIE_1_hist;
BY Date Company Idno Warehouse Dimset H_ref Stock_quan;
RUN;
DATA work.Stock_BRZO_hist;
SET work.Stock_BRZO_hist;
IF Sev_III_treshold_1=0 THEN Sev_III_treshold_1=.;
IF ARIE_treshold=0		THEN ARIE_treshold=.;
RUN;


/*TRESHOLDRULE*/

/*Uitsplitsing EAP-ECP*/

PROC SQL;
CREATE TABLE BRZO_Check1_hist_BRZO AS
SELECT  a.Company,
        a.Date							AS Date	FORMAT Date9.,
		"Treshold_group_vs_Stock"		AS Check1,
		a.SEC_III_HAZ_CAT               AS SEC_III_HAZ_CAT 			LABEL='SEC_III_HAZ_CAT',
		a.ARIE_Treshold,
		a.SEV_III_TRESHOLD_1			AS Sev_III_Treshold 		LABEL='Sev_III_Treshold',
		"-"								AS SEC_III_HAZ_CAT_Short1 	LABEL='SEC_III_HAZ_CAT_Short1',
		SUM(a.Stock_quan)				AS Stock_quan_BRZO			LABEL='Stock_quan_BRZO',
		0								AS Factor_ARIE,
		0                               AS Factor_BRZO,
		CASE
		WHEN SUM(a.Stock_quan)<a.SEV_III_TRESHOLD_1 OR a.SEV_III_TRESHOLD_1=.   THEN 'Ok'
													  							ELSE 'Not ok'  END  AS Result_BRZO
FROM  work.Stock_BRZO_hist a
GROUP BY a.Company, a.Date, a.SEC_III_HAZ_CAT, a.SEV_III_TRESHOLD_1;
QUIT;
PROC SORT DATA=work.BRZO_Check1_hist_BRZO nodupkey; BY Company Date SEC_III_HAZ_CAT SEV_III_TRESHOLD; 				RUN;
PROC SORT DATA=work.BRZO_Check1_hist_BRZO; 			BY Company Date SEC_III_HAZ_CAT ARIE_Treshold SEV_III_TRESHOLD; RUN;

PROC SQL;
CREATE TABLE BRZO_Check1_hist_ARIE AS
SELECT  a.Company,
        a.Date							AS Date	FORMAT Date9.,
		"Treshold_group_vs_Stock"		AS Check1,
		a.SEC_III_HAZ_CAT               AS SEC_III_HAZ_CAT 			LABEL='SEC_III_HAZ_CAT',
		a.ARIE_Treshold,
		a.SEV_III_TRESHOLD_1			AS Sev_III_Treshold 		LABEL='Sev_III_Treshold',
		"-"								AS SEC_III_HAZ_CAT_Short1 	LABEL='SEC_III_HAZ_CAT_Short1',
		SUM(a.Stock_quan)				AS Stock_quan_ARIE			LABEL='Stock_quan_ARIE',
		0								AS Factor_ARIE,
		0                               AS Factor_BRZO,
		CASE
		WHEN SUM(a.Stock_quan)<a.ARIE_Treshold OR a.ARIE_Treshold=.   			THEN 'Ok'
													  							ELSE 'Not ok'  END  AS Result_ARIE
FROM  work.Stock_BRZO_hist a
GROUP BY a.Company, a.Date, a.SEC_III_HAZ_CAT, a.ARIE_Treshold;
QUIT;
PROC SORT DATA=work.BRZO_Check1_hist_ARIE nodupkey; BY Company Date SEC_III_HAZ_CAT ARIE_Treshold; 					RUN;
PROC SORT DATA=work.BRZO_Check1_hist_ARIE; 			BY Company Date SEC_III_HAZ_CAT ARIE_Treshold SEV_III_TRESHOLD; RUN;

DATA work.BRZO_Check1_hist;
MERGE work.BRZO_Check1_hist_BRZO work.BRZO_Check1_hist_ARIE;
BY Company Date SEC_III_HAZ_CAT ARIE_Treshold SEV_III_TRESHOLD;
RUN;


DATA work.BRZO_Check1_hist(Drop= Check1 SEC_III_HAZ_CAT_Short1); SET work.BRZO_Check1_hist;
FORMAT SEC_III_HAZ_CAT_Short $1.;
FORMAT Check $50.;
SEC_III_HAZ_CAT_Short=SEC_III_HAZ_CAT_Short1;
Check=Check1;
RUN;


/*SUMRULE*/

/*Losse stoffen weer toevoegen*/
PROC APPEND BASE=work.Stock_brzo_hist DATA=work.Stock_brzo_losse_stoffen_hist; RUN;

PROC SQL;
CREATE TABLE work.BRZO_Check2_hist AS
SELECT  a.Date,
        a.Company,
		a.SEC_III_HAZ_CAT,
		a.SEC_III_HAZ_CAT_Short, 
		a.ARIE_Treshold,
		a.SEV_III_TRESHOLD_1 				AS SEV_III_TRESHOLD,
		a.stock_quan,
		a.stock_quan/a.ARIE_Treshold        AS Factor_ARIE1,
		a.stock_quan/a.SEV_III_TRESHOLD_1 	AS Factor_BRZO1
FROM  work.Stock_brzo_hist a;
QUIT;

/*Uitsplitsing EAP-ECP*/

PROC SQL;
CREATE TABLE BRZO_Check3_hist AS
SELECT  a.Company,
        a.Date							AS Date 					FORMAT Date9.,
		"Treshold_Category     "		AS Check,
		a.ARIE_Treshold,
		a.Sev_III_Treshold 				AS SEV_III_TRESHOLD         LABEL='SEV_III_TRESHOLD',
		a.SEC_III_HAZ_CAT,
		a.SEC_III_HAZ_CAT_Short			AS SEC_III_HAZ_CAT_Short 	LABEL='SEC_III_HAZ_CAT_Short',
		SUM(a.Stock_quan)               AS Stock_quan_ARIE			LABEL='Stock_quan_ARIE',
		SUM(a.Stock_quan)               AS Stock_quan_BRZO			LABEL='Stock_quan_BRZO',
		SUM(a.Factor_ARIE1)             AS Factor_ARIE,
		SUM(a.Factor_BRZO1)             AS Factor_BRZO,
		CASE
		WHEN SUM(a.Factor_ARIE1) <1        THEN 'Ok  '
										   ELSE 'Not ok'  END  AS Result_ARIE FORMAT $6.,
		CASE
		WHEN SUM(a.Factor_BRZO1) <1 	   THEN 'Ok  '
										   ELSE 'Not ok'  END  AS Result_BRZO FORMAT $6.
FROM  work.BRZO_check2_hist a
GROUP BY a.Company, a.Date, a.SEC_III_HAZ_CAT_Short;
QUIT;
PROC SORT DATA=work.BRZO_Check3_hist nodupkey; BY Company Date SEC_III_HAZ_CAT_Short; RUN;


PROC APPEND BASE=db2eura.Euravib_BRZO_stock 	(BULKLOAD=YES) DATA=work.stock_brzo_hist				FORCE;  RUN;
PROC APPEND BASE=db2eura.Euravib_BRZO_kpi 		(BULKLOAD=YES) DATA=work.BRZO_Check1_hist				FORCE;  RUN;
PROC APPEND BASE=db2eura.Euravib_BRZO_kpi 		(BULKLOAD=YES) DATA=work.BRZO_Check3_hist				FORCE;  RUN;

PROC APPEND BASE=db2eura.Euravib_BRZO_deel_2 	(BULKLOAD=YES) DATA=work.Losse_stoffen_ARIE_BRZO_hist 	FORCE;	RUN;



/* Bullit change */

/************** Cas_Nr_Check ****************/
DATA work.euravib_cas_ref; SET db2eura.euravib_cas_ref;
Cas_nr=scan(cas_nr,1,'.');
RUN;

PROC SQL;
CREATE TABLE work.Cas_Nr_Check AS
SELECT  a.suppl_nr,
		a.dimset,
		trim(a.cas_nr) 	AS Cas_Nr,
		b.CAS_DESCR,
		1 				AS COUNT_RECORD,
		d.active,
		d.in_use
FROM db2eura.euravib_substance_cas a 
LEFT OUTER JOIN work.euravib_cas_ref b ON a.cas_nr=b.cas_nr
LEFT OUTER JOIN db2eura.euravib_main d ON a.dimset=d.dimset AND a.suppl_nr=d.suppl_nr AND a.rev_date=d.rev_date;
QUIT;

PROC SORT data=work.Cas_Nr_Check nodupkey; by suppl_nr dimset cas_nr ; RUN;

DATA work.Cas_Nr_Check; SET work.Cas_Nr_Check;
IF DIMSET IN ('99V0003.xx','99O0035.xx') 	THEN DELETE;
IF DIMSET IN ('90R0122.90') 				THEN DELETE;
IF Cas_Nr IN ('UNKNOWN') 					THEN DELETE;
IF Cas_Nr IN ('NoCasNr') 					THEN DELETE;
WHERE CAS_DESCR="" AND Active='Y' AND IN_USE='Y';
RUN;

PROC SQL;
CREATE TABLE work.Cas_Nr_Check_MAIL AS
SELECT  sum(COUNT_RECORD) AS SUM_RECORD
FROM work.Cas_Nr_Check a;
QUIT;

%macro CASCHECK;
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="hhalmans@euramax.eu" CC="team-bi@euramax.eu"			
SUBJECT="**** Check Cas Nr ****" CONTENT_TYPE="text/html";
Title "Check Cas Nr";
ODS LISTING CLOSE; ODS HTML BODY=mail;
PROC PRINT DATA=work.Cas_Nr_Check  noobs; VAR suppl_nr dimset cas_nr CAS_DESCR ; RUN;
ODS HTML CLOSE; ODS LISTING; 
%mend;

DATA work.Cas_Nr_Check_MAIL; SET work.Cas_Nr_Check_MAIL;
CALL EXECUTE('%CASCHECK');
WHERE SUM_RECORD>0;
RUN;

/* Brandweer lijst idno stock */
PROC SQL;
CREATE TABLE work.idno_stock_HSE AS
select  a.Company,
		a.Suppl_nr,
		a.Dimset,
		a.Dimset_Descr,
		a.Rev_date,
		a.Entry_Date,
		b.Idno,
		b.MAINWAREHOUSE,
		b.WAREHOUSE,
		b.LOCATION,
		b.STOCK_DATE,
		b.Stock_Quan,
		c.ADR_UN_NR,
		c.ADR_PACKING_GROUP,
		c.ADR_TRANSPORTHAZARD_CLASS,
		c.FLASHPOINT
FROM db2eura.euravib_main a
INNER JOIN Db2data.idno_stock b 			ON a.company=b.company 							AND a.dimset=b.dimset 							AND a.suppl_nr=b.suppl_nr
LEFT OUTER JOIN db2eura.euravib_import c 	ON compress(a.dimset_descr)=compress(c.dimset) 	AND compress(a.suppl_nr)=compress(c.suppl_nr) 	AND a.rev_date=c.rev_date
WHERE a.active='Y' AND a.in_use='Y'; 
QUIT;

DATA work.idno_stock_HSE; SET work.idno_stock_HSE;
Flashpoint=tranwrd(FLASHPOINT,'.0','');
Flashpoint=tranwrd(FLASHPOINT,'.3','');
Vlampunt=compress(FLASHPOINT,,"kd");

IF flashpoint='>23-60�C' THEN Vlampunt='23';
IF flashpoint='23-60�C'  THEN Vlampunt='23';

RUN;

DATA work.icard_hse_adr_imdg; SET db2itask.icard_hse_adr_imdg;
IF substr(VLAMPUNT,1,2)='<=' 								THEN DO VLAMPUNT_MIN='-999'; VLAMPUNT_MAX=substr(VLAMPUNT,3,2); 	END; 
IF substr(VLAMPUNT,1,1)='<' AND substr(VLAMPUNT,2,1) NE '=' THEN DO VLAMPUNT_MIN='-999'; VLAMPUNT_MAX=substr(VLAMPUNT,2,2)-1; 	END; 
IF substr(VLAMPUNT,1,2)='>=' 								THEN DO VLAMPUNT_MIN=substr(VLAMPUNT,3,2); VLAMPUNT_MAX='999'; 		END; 

IF VLAMPUNT_MIN='' THEN VLAMPUNT_MIN='-999';
IF VLAMPUNT_MAX='' THEN VLAMPUNT_MAX='999';
RUN;

PROC SQL;
CREATE TABLE work.idno_stock_HSE_1 AS
SELECT a.*,
		b.GEVAARSIDENTIFICATIENR
FROM work.idno_stock_HSE a 
LEFT OUTER JOIN work.icard_hse_adr_imdg b ON a.ADR_PACKING_GROUP=b.ADR_PACKAGING_GROUP 	AND a.ADR_TRANSPORTHAZARD_CLASS=b.ADR_KLASSE 	AND a.ADR_UN_NR=b.UN_NR 
																						AND a.vlampunt>=b.VLAMPUNT_MIN 					AND a.vlampunt<=b.VLAMPUNT_MAX;
QUIT;

PROC SORT data=work.idno_stock_HSE_1 nodupkey; by company suppl_nr dimset idno; RUN;

DATA work.idno_stock_HSE_1; SET work.idno_stock_HSE_1;
IF ADR_UN_NR='ADR Vrij' THEN GEVAARSIDENTIFICATIENR='-';
RUN;


PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp'); 
EXECUTE (Drop table euravib.Euravib_Idno_Stock_HSE) by db2;
QUIT;

PROC APPEND BASE=DB2eura.Euravib_Idno_Stock_HSE (BULKLOAD=YES) DATA=work.idno_stock_HSE_1 FORCE; RUN;

PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp'); 
EXECUTE ( GRANT  SELECT ON TABLE euravib.Euravib_Idno_Stock_HSE TO USER INFODBC )  by db2;
QUIT;



/**********************************************************************/
/****    Wateringen to db2                            ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Afval_Watermetingen as select * from connection to baan
   (SELECT  a.t_trdt  	Trans_date,
   			a.t_trtm	Trans_time,
			a.t_dsca	Description,
			a.t_zcrv	Chrome,
			a.t_zznv	Zinc,
			a.t_zpbv	Lead,
			a.t_zphv	pH_value,
			a.t_zmty	Analyse_type,
			a.t_slvl	Sulfaat_mg_l,
			a.t_flur	Fluoride_Riool,
			a.t_flut	Fluoride_T33
   FROM      ttdlra929120 a
   ORDER BY  Trans_date, Trans_time, Analyse_type    );
 DISCONNECT from baan;
QUIT;

DATA work.Afval_Watermetingen; SET work.Afval_Watermetingen;
FORMAT Trans_time TIME8.; FORMAT DateTime DateTime16.;
DateTime=DHMS(Trans_date,Hour(Trans_time),Minute(Trans_time),second(Trans_time));
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DROP TABLE euravib.Afval_Watermetingen) by baan;   
QUIT;

PROC APPEND base=DB2EURA.Afval_Watermetingen (BULKLOAD=YES) data=work.Afval_Watermetingen;  RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  SELECT ON TABLE euravib.Afval_Watermetingen TO USER INFODBC )  by baan;
EXECUTE ( GRANT  SELECT ON TABLE euravib.Afval_Watermetingen TO USER FINODBC )  by baan;
QUIT;





DATA work.Itask_lel_controlemeting; SET Db2itask.Itask_lel_controlemeting; 	RUN;
DATA work.cas_ref; 					SET Db2eura.Euravib_cas_ref; 			RUN;
PROC SORT DATA=work.Itask_lel_controlemeting;
BY TASKID;
RUN;
PROC SQL;
CREATE TABLE work.cas AS
SELECT a.CAS_NR, 
	   a.CAS_DESCR,
	   a.NUMBER_C_ATOMS,
	   a.RESPONSE_FAC_PROPANE,
	   a.LEL_PERC 					AS CAS_LEL_PERC LABEL="CAS_LEL_PERC",
	   a.Volatile
FROM work.Cas_ref a;
QUIT;
PROC SQL;
CREATE TABLE work.lelControl AS
SELECT b.*,
	   a.CAS_NR, 
	   b.SAMPLE_POINT_NUMBER,
	   a.CAS_DESCR,
	   a.NUMBER_C_ATOMS,
	   a.RESPONSE_FAC_PROPANE,
	   CAS_LEL_PERC
FROM work.Cas a, work.Itask_lel_controlemeting b
WHERE a.Cas_Nr=b.Cas_Nr;
QUIT;

PROC SORT DATA=work.lelControl; BY TaskId; Run;
PROC SQL;
CREATE TABLE work.comp AS
SELECT a.TaskiD,
	   a.CAS_NR,
	   a.Sample_POINT_NUMBER,
	   b.*,
	   a.Concentration_per_substance,
	   a.LEL,
	   a.ELM_LEL_Conc
FROM work.lelControl a, work.cas b
WHERE a.CAS_NR=b.CAS_NR;
QUIT;

PROC SQL;
CREATE TABLE work.lel_missing AS
SELECT 	TASKID,
		CAS_NR,
		CAS_LEL_PERC,
		LEL,
		NUMBER_C_ATOMS,
		RESPONSE_FAC_PROPANE,
		ELM_LEL_Conc,
		VOLATILE
FROM	work.comp
WHERE  	CAS_LEL_PERC IS MISSING OR LEL IS MISSING OR NUMBER_C_ATOMS IS MISSING OR
		RESPONSE_FAC_PROPANE IS MISSING OR
		ELM_LEL_Conc IS MISSING;
QUIT;
PROC SORT DATA=work.lel_missing;
BY CAS_NR TASKID;
RUN;
PROC SQL;
CREATE TABLE work.lel_missing AS
SELECT *
FROM work.lel_missing
WHERE VOLATILE="Y";
quit;

%macro Mail();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ;
FILENAME mail EMAIL TO="hhalmans@euramax.eu"
SUBJECT="**** SAS Missing data Emissie & LEL ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

Title "DATA ontbreekt";
PROC PRINT NOOBS DATA=work.lel_missing;
RUN;
ODS HTML CLOSE; ODS LISTING;
%mend;

PROC SQL;
CREATE TABLE work.logcount AS SELECT  count(CAS_NR) AS counter FROM work.lel_missing;
QUIT;

DATA work.logcount; SET work.logcount; IF counter=0 THEN DELETE;
RUN;

DATA work.logcount; SET work.logcount;
CALL EXECUTE('%Mail');
RUN;




DATA work.Itask_lel_controlemeting; SET Db2itask.Itask_lel_controlemeting; RUN;
PROC SORT DATA=work.Itask_lel_controlemeting;
BY TASKID;
RUN;

PROC SQL;
CREATE TABLE work.lel_Controlemeting AS
SELECT 	TASKID,
		DIMSET
FROM	work.Itask_lel_controlemeting
WHERE  	CAS_NR IS MISSING;
QUIT;
PROC SORT DATA=work.lel_Controlemeting;
BY TASKID;
RUN;


%macro Mail();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ;
FILENAME mail EMAIL TO="hhalmans@euramax.eu"  
SUBJECT="**** SAS Missing Cas_Nr; Emissie & LEL Tabblad LEL ****" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

Title "DATA ontbreekt bij TaskID en Dimset ";
PROC PRINT NOOBS DATA=work.lel_Controlemeting;
RUN;
ODS HTML CLOSE; ODS LISTING;
%mend;

PROC SQL;
CREATE TABLE work.logcount AS SELECT  count(TASKID) AS counter FROM work.lel_Controlemeting;
QUIT;

DATA work.logcount; SET work.logcount; IF counter=0 THEN DELETE;
RUN;

DATA work.logcount; SET work.logcount;
CALL EXECUTE('%Mail');
RUN;



/* Wat Moet er in staan:		van Kolom		Tabel
1. Klantnummer					CUST_NR			Euravib_transactions
2. Klantnaam					CUST_NAME		Euravib_transactions
3. Transactie datum				DATE			Euravib_transactions
4. CAS_NR										Euravib_cas_substance_cas
5. CAS_DESCR									Euravib_cas_ref
6. CAS_DESCR_E									Euravib_cas_ref
7. REACH_NR										Euravib_cas_ref
8. EINECS_NR									Euravib_cas_ref
Kolomen naast elkaar:
 
suppl_nr voor dimset

latest Declaration Date RoHS and REACH:, Latest Declaration Date REACH: > datum
*/



DATA work.Euravib_substance_cas; 	SET Db2eura.Euravib_substance_cas; 	RUN;
DATA work.Euravib_cas_ref; 			SET Db2Eura.Euravib_cas_ref; 		RUN;
DATA work.Euravib_transactions; 	SET Db2eura.Euravib_transactions; 	RUN;

proc sql;
CREATE TABLE work.euravibhistory AS
SELECT 
		Company,
		Dimset,
		Date,
		SUPPL_NR,
		CUST_NR,
		CUST_Name,
		1 			AS check		
FROM work.euravib_transactions a
WHERE Company="Roe";
quit;

DATA work.euravibhistory; SET work.euravibhistory;
Cust_code= Compress(CUST_Name||"_"||CUST_NR);
RUN;

/* HSE Customer   */
libname iTask    ODBC  dsn='iProvaPRD' schema=iTask user=odbc password=ODBC;
libname iDataprd ODBC  dsn='iProvaPRD' schema=iData user=odbc password=ODBC;  
libname iCoreprd ODBC  dsn='iProvaPRD' schema=core  user=odbc password=ODBC;

/****************************************************************************/
/*****  Collection iData data and convert to db2 tables					*****/
/****************************************************************************/
PROC SQL;
CREATE TABLE work.iDataPRD AS
SELECT  a.fldFieldValueID					AS Field_Value_ID 	Label='Field_Value_ID',
		e.fldSingularName					AS Table_name1		Label='Table_name1',
		a.fldFieldID						AS Field_ID			Label='Field_ID',
		c.fldFieldType						AS Field_type		Label='Field_type',
		c.fldCustomOptions					AS Field_options	Label='Field_Options',
		PUT(a.fldObjectIdentifier,$6.)		AS RecordNr			Label='RecordNr',
		b.fldName							AS Field_name1		Label='Field_name1',
		a.fldNumericValue					AS Value_num		Label='Value_num',
		a.fldValue							AS Value_txt1		Label='Value_txt1',
		a.fldSelectedUserIDs				AS User_ID			Label='User_ID',
		a.fldSelectedObjectIDs				AS SelectedObjectID Label='SelectedObjectID',
		a.fldFieldValueID					AS Field_Value_ID   Label='Field_Value_ID',
		DATEPART(a.fldDateValue) 			AS Value_date		Label='Value_date' FORMAT DATE9.
FROM  	iCoreprd.tbdFieldValue a,
		iCoreprd.tbdFieldName b,
		iCoreprd.tbdField c,
		iDataprd.tbdDataTypeField d,
		iDataprd.tbdDataTypeName e
WHERE   a.fldFieldID = b.fldFieldID AND a.fldFieldID = c.fldFieldID AND  a.fldFieldID=d.fldFieldID AND d.fldDataTypeID=e.fldDataTypeID AND e.fldSingularName='HSE Customer' AND fldObjectDeleted=0;

CREATE TABLE work.iDataPRD AS
SELECT  a.*,
		b.fldFieldListOptionID				AS  Option_ID
FROM  	work.iDataPRD a  LEFT OUTER JOIN iCoreprd.tbdFieldValueListValue b ON a.Field_Value_ID=b.fldFieldValueID;

CREATE TABLE work.iDataPRD AS
SELECT  a.*,
		b.fldName			AS  Option_Name	Label='Option_Name'
FROM  	work.iDataPRD a  LEFT OUTER JOIN iCoreprd.tbdFieldListOptionName b ON a.Option_ID=b.fldFieldListOptionID;

CREATE TABLE work.iDataPRD AS
SELECT  a.*,
		b.fldName			AS  User_name	Label='User_name'
FROM  	work.iDataPRD a  LEFT OUTER JOIN iCoreprd.tbduser b ON a.User_ID=b.flduserid;

QUIT;

PROC SQL;
CREATE TABLE work.iDataPRD AS
SELECT  a.*,
		b.fldSearchValue
FROM  	work.iDataPRD a  LEFT OUTER JOIN iCoreprd.tbdFieldValueSearchValue b ON a.Field_Value_ID=b.fldFieldValueID
WHERE  b.fldLanguage="nl-NL" ;
QUIT;


DATA work.iDataPRD1 (DROP=Field_Value_ID Field_Options Option_ID Option_Name Table_name1 Field_name1 User_ID User_Name Value_Date)         ;
SET work.iDataPRD;
IF Option_ID ne . 																		THEN Value_txt1=Option_Name;
IF User_ID ne "" 																		THEN Value_txt1=User_name;
IF value_date ne . 																		THEN Value_num=value_date;
FORMAT Value_txt $500.; Value_txt=TRIM(Substr(Value_txt1,1,500));
FORMAT Table_name $50.; Table_name=TRIM(Substr(Table_name1,1,50));
FORMAT Field_name $50.; Field_name=TRIM(Substr(Field_name1,1,50));
IF INDEX(Field_Options,'multiselect')>0 												THEN Value_txt1=fldSearchValue;
IF INDEX(Field_Options,'textareaheight')>0 OR INDEX(Field_Options,'customoptions')>0 	THEN Txt='Y';
IF INDEX(Field_Options,'multiselect')>0 												THEN Txt='Y';
IF INDEX(Field_Options,'onlyintegersallowed')>0 										THEN DO; Int='Y'; Txt='N'; END;
IF INDEX(Field_Options,'allowpastdate')>0 												THEN DO; Int='Y'; Txt='N'; END;
Field_Txt_Width=LENGTH(TRIM(Value_txt));
Field_num_Width=LENGTH(TRIM(INPUT(Value_num,$20.)));
IF INDEX(Value_num,'.')>0 AND Value_num ne . 											THEN Field_Decimals=LENGTH((scan(Value_num,2,"."))); ELSE Field_Decimals=0;
Table_name=Translate (Trim(Table_name),"_",' ');
Field_name=Translate (Trim(Field_Name),"____",'.?/ ');Field_Name=Trim(Field_Name);
Field_name=tranwrd(Field_name,'Latest_Declaration_Date_RoHS_and_REACH','Late_Decl_Date_RoHS_and_REACH');
Field_name=tranwrd(Field_name,'Latest_Declaration_Date_Conflict_Minerals','Late_Decl_Date_Conflict_Mineral');
Field_name=tranwrd(Field_name,'Latest_Declaration_Date_Stockhom_Conv','Late_Decl_Date_Stockhom_Conv');
Field_name=tranwrd(Field_name,'Latest_Declaration_Date_Data_Cross','Late_Decl_Date_Data_Cross');
RUN;

PROC SORT DATA=work.iDataPRD1;
BY Recordnr Field_name;
RUN;

/***** Detect number of tables			*****/
PROC SQL;
CREATE TABLE work.tables AS
SELECT   a.Table_name, count(a.Table_name) AS recordnr
FROM   work.iDataPRD1 a
GROUP BY a.Table_name;
QUIT;

/***** Detect tables fields				*****/
PROC SQL;
CREATE TABLE work.var_fields AS
SELECT  a.Table_name				AS TableName,
		a.Field_name				AS FieldName,
		a.Int						AS Field_int,
		a.Txt						AS Field_txt,
		MAX(Field_Txt_Width)		AS Field_width,
		MAX(Value_num)				AS Field_val_max,
		MIN(Value_num)				AS Field_val_min,
		MAX(Field_Decimals)			AS Field_val_dec,
		MAX(Field_num_Width)		AS Field_num_width
FROM work.iDataPRD1 a
GROUP BY a.Table_name, a.Field_name, a.Int, a.Txt ;
RUN;

DATA work.var_fields; SET work.var_fields;
Field_num_Width=LENGTH(TRIM(INPUT(Field_val_max,$12.)));
FORMAT SAS_Format $10.;
IF Field_int='Y' 						THEN DO; Field_Format=' Integer not null';  SAS_Format="8.0"; END;
IF Field_int='' AND Field_txt='N' 		THEN DO; Field_Format=' Dec('||PUT(Field_num_width,$2.)||','||PUT(Field_val_dec,$1.)||')'; SAS_Format=COMPRESS(PUT(Field_num_width,$2.)||'.'||PUT(Field_val_dec,$1.)); END;
IF Field_txt='Y'						THEN DO; Field_format=' Char('||PUT(Field_width,$3.)||')'; SAS_Format=COMPRESS(' $'||PUT(Field_width,$3.)||'.'); END;
FieldName=tranwrd(FieldName,'Latest_Declaration_Date_RoHS_and_REACH','Late_Decl_Date_RoHS_and_REACH');
FieldName=tranwrd(FieldName,'Latest_Declaration_Date_Conflict_Minerals','Late_Decl_Date_Conflict_Mineral');
FieldName=tranwrd(FieldName,'Latest_Declaration_Date_31__BImSchV','Late_Decl_Date_31__BImSchV');
Fieldname=tranwrd(Fieldname,'Latest_Declaration_Date_Data-Cross','Late_Decl_Date_Data_Cross');
RUN;


%macro CreateTableNum(tableName, varname, formatnum);
DATA work.table_num (keep=RecordNr &varname) ; SET work.iDataPRD1;
FORMAT &varname &formatnum; &varname=Value_num;
WHERE Table_name="&TableName" AND Field_name="&varname";
RUN;

PROC SORT data=work.table_num; BY RecordNr; RUN;
DATA work.&TableName;
MERGE work.&TableName work.table_num;
BY RecordNr;
RUN;
%mend;

%macro CreateTabletxt(tableName, varname, formattxt);
DATA work.table_txt (keep=RecordNr &varname) ; SET work.iDataPRD1;
FORMAT &varname &formattxt; &varname=Value_txt;
WHERE Table_name="&TableName" AND Field_name="&varname";
RUN;

PROC SORT data=work.table_txt; BY RecordNr; RUN;
DATA work.&TableName;
MERGE work.&TableName work.table_txt;
BY RecordNr;
RUN;
%mend;

%macro CreateTable(tableName);
PROC SQL;
CREATE TABLE work.&TableName AS
SELECT 	RecordNr, COUNT(RecordNr) AS Count
FROM work.iDataPRD1 
WHERE Table_name="&tableName"
GROUP BY RecordNr;
QUIT;

DATA work.var_fields1; SET work.var_fields;
IF Field_txt='Y' THEN CALL EXECUTE('%CreateTabletxt('||TableName||','||FieldName||','||SAS_Format||')'); 
				 ELSE CALL EXECUTE('%CreateTablenum('||TableName||','||FieldName||','||SAS_Format||')'); 
where TableName="&TableName";
RUN;

%mend;

DATA work.tables1; SET work.tables;
CALL EXECUTE('%CreateTable('||Table_name||')');
RUN;



PROC SORT DATA=work.Hse_customer ; BY RecordNr; RUN;
DATA work.Hse_customer ; SET work.Hse_customer;
BY RecordNr;
IF not first.RecordNr THEN DELETE;
RUN;



DATA work.tbdObjectDisplayName; SET idataprd.tbdObjectDisplayName;
FORMAT recordNr $6.;
recordNr=compress(put(fldObjectID,$6.));
RUN;


PROC SQL;
CREATE TABLE work.Hse_customer AS
SELECT  a.*,
		b.fldDisplayName AS Display_Name
FROM  	work.Hse_customer a,
		work.tbdObjectDisplayName b
WHERE  b.fldLanguage="nl-NL" AND a.RecordNr=b.recordNr;
QUIT;
DATA work.Hse_customer; SET work.Hse_customer;
FORMAT Late_Decl_Date_Conflict_Mineral 	DATE9.;
FORMAT Latest_Declaration_Date_EVD 		DATE9.;
Format Latest_Declaration_Date_PFAS 	DATE9.;
FORMAT Latest_Declaration_Date_REACH 	DATE9.;
FORMAT Latest_Declaration_Date_RoHs 	DATE9.;
FORMAT Late_Decl_Date_RoHS_and_REACH 	DATE9.;
FORMAT Late_Decl_Date_Stockhom_Conv  	DATE9.;
FORMAT Latest_Date_Cradle_to_Cradle 	DATE9.;
FORMAT Late_Decl_Date_Data_Cross        DATE9.;
FORMAT Mail_Substances_Processed 		DATE9.;
RUN;

DATA work.Hse_customer; SET work.Hse_customer;
Cust_code= Compress(Customer_Code);
RUN;


Proc SQL;
CREATE TABLE work.euravibhistory AS
SELECT a.*,
	   b.Late_Decl_Date_RoHS_and_REACH, 
	   b.Latest_Declaration_Date_REACH,
	   b.Mail_Substances_Processed
FROM work.euravibhistory a ,work.Hse_customer b 
WHERE a.Cust_code=b.Cust_code;
QUIT;

PROC SORT DATA=work.euravibhistory; BY COMPANY DIMSET CUST_NR; RUN;
PROC SQL;
CREATE TABLE work.euravibhistory AS
SELECT a.*,
	   Sum(a.check) AS counter
FROM work.euravibhistory a
GROUP BY COMPANY, DIMSET, CUST_NR;
quit;

PROC SQL;
CREATE TABLE work.euraviblive AS
SELECT a.*
FROM work.euravibhistory a
WHERE Late_Decl_Date_RoHS_and_REACH<=Date() AND counter=1 AND Late_Decl_Date_RoHS_and_REACH NE "."d  OR Latest_Declaration_Date_REACH<=Date() AND counter=1 AND Latest_Declaration_Date_REACH NE "."d;/*Voor test doeleinde  */
quit;

/* Mail_Substances_Processed filter */
DATA work.euraviblive1;
SET work.euraviblive;
FORMAT Last_Mail_send Date9.;
Last_Mail_send = Date();
WHERE Mail_Substances_Processed = .; /* Moet kijken hoe dit het best worden gedaan*/
Run;

PROC SORT DATA=euraviblive;  BY CUST_NR SUPPL_NR DIMSET; RUN;
PROC SORT DATA=euraviblive1; BY CUST_NR SUPPL_NR DIMSET; RUN;

DATA work.merged;
MERGE euraviblive euraviblive1;
BY CUST_NR SUPPL_NR DIMSET;
RUN;


PROC SQL;
CREATE TABLE work.euraviblive2 AS
SELECT *
FROM work.merged
WHERE Last_Mail_send>Mail_Substances_Processed;
quit;

/* einde Mail_Substances_Processed*/

PROC SQL;
CREATE TABLE work.euravibsubstance AS
SELECT a.*,
	   b.SUPPL_NR,
	   b.DIMSET,
	   b.CAS_NR
FROM	work.euraviblive2 a , work.Euravib_substance_cas b
WHERE a.DIMSET=b.DIMSET AND a.SUPPL_NR=b.SUPPL_NR;
quit;

PROC SQL;
CREATE TABLE work.euravibsubCas AS
SELECT a.*,
	   b.CAS_DESCR,								
	   b.CAS_DESCR_E,									
 	   b.REACH_NR,									
	   b.EINECS_NR,
	   b.REASON_FOR_INCLUSION	
FROM	work.euravibsubstance a LEFT JOIN work.Euravib_cas_ref b
ON a.CAS_NR=b.CAS_NR;
QUIT;
PROC SORT DATA=work.euravibsubCas; BY COMPANY DIMSET CUST_NR; Run;

PROC SQL;
CREATE TABLE work.casList AS
SELECT *
FROM work.euravibsubCas;
QUIT;

PROC SQL;
CREATE TABLE work.euravibordering AS
SELECT SUPPL_NR,
	   DIMSET,
	   DATE,
	   CUST_NR,
	   CUST_NAME,
	   CAS_NR,
	   CAS_DESCR,
	   CASE 
	WHEN REASON_FOR_INCLUSION = ""  THEN "N"
	WHEN REASON_FOR_INCLUSION NE "" THEN "Y"
	ELSE "Missing"							end AS Candidate,
	Reach_Nr,
	Einecs_NR
FROM work.casList a;
QUIT;
DATA work.euravibordering; SET work.euravibordering;
RENAME CAS_NR=CAS_NR_MAIL;
RUN;

%macro Mail();
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ;
FILENAME mail EMAIL TO="hhalmans@euramax.eu"  /*CC="rmooren@euramax.eu" */
SUBJECT="**** SAS new data ****" CONTENT_TYPE="text/html";
/*ATTACH= ("P:\Data exchange folder for the HSE department\Stickers\foto.png")*/
ODS LISTING CLOSE; ODS HTML BODY=mail;

Title "De nieuwe data voor Customer Euravib Check is: ";
PROC PRINT NOOBS DATA=work.euravibordering;
RUN;
ODS HTML CLOSE; ODS LISTING;

Data work.euraviblive2;
set work.euraviblive2;
Last_Mail_send = Date();
Run;

Proc sort Data=euravib_transactions; BY CUST_NR SUPPL_NR DIMSET; Run;
Proc sort Data=euraviblive2; BY CUST_NR SUPPL_NR DIMSET; Run;

Data work.euravib_transactions (DROP=Cust_code Late_Decl_Date_RoHS_and_REACH Latest_Declaration_Date_REACH counter);
Merge euravib_transactions euraviblive2;
BY  CUST_NR SUPPL_NR DIMSET;
Run;

%mend;

PROC SQL;
CREATE TABLE work.logcount AS SELECT  count(Date) AS counter FROM work.casList;
QUIT;

DATA work.logcount; SET work.logcount; IF counter=0 THEN DELETE;
RUN;

DATA work.logcount; SET work.logcount;
CALL EXECUTE('%Mail');
RUN;



/*HSE - New Dimset C,M,R */
PROC SQL;
CREATE TABLE work.DimsetCMR_Check AS
SELECT  a.Dimset,
		a.Rev_date,
		a.Entry_date,
		a.Suppl_nr,
	    b.H_ref,
		STRIP(CAT(c.CMR_C,c.CMR_M,c.CMR_R))	AS CMR	LABEL='CMR',
		a.User
FROM DB2eura.Euravib_import a LEFT OUTER JOIN DB2eura.Euravib_mixture_h b ON a.Dimset=b.Dimset AND a.Rev_date=b.Rev_date AND a.Entry_date=b.Entry_date AND a.Suppl_nr=STRIP(b.Suppl_nr)
                              LEFT OUTER JOIN DB2eura.Euravib_h_info    c ON b.H_ref=c.H_ref
WHERE (c.CMR_C IS NOT MISSING OR c.CMR_M IS NOT MISSING OR c.CMR_R IS NOT MISSING) AND a.Entry_date>=DATE()-2 /*AND a.User NE "SAS"*/
ORDER BY a.Dimset, a.Entry_date, a.Rev_date;
QUIT;
DATA work.DimsetCMR_Check;
SET work.DimsetCMR_Check;
WHERE User NE "SAS";
RUN;	

PROC SQL;
CREATE TABLE work.CMRMailTrigger AS
SELECT	COUNT(a.Dimset) AS Count
FROM work.DimsetCMR_Check a;
QUIT;

%macro NewDimsetCMR;
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="hhalmans@euramax.eu" CC="dverbert@euramax.eu"				
SUBJECT="**** New Dimset CMR ****" CONTENT_TYPE="text/html";
Title "New Dimset CMR";
ODS LISTING CLOSE; ODS HTML BODY=mail;
PROC PRINT DATA=work.DimsetCMR_Check  noobs; VAR Suppl_nr Dimset Rev_date Entry_Date H_Ref CMR; RUN;
ODS HTML CLOSE; ODS LISTING; 
%mend;

DATA work.CMRMailTrigger; SET work.CMRMailTrigger;
CALL EXECUTE('%NewDimsetCMR');
WHERE Count > 0;
RUN;


/*HSE - New msds contains CAS-nr 50-00-0 */
%LET End_date   = %sysfunc(today());
%LET Start_date = %sysfunc(intnx(day, &End_date, -1));

DATA VIBcheck;
SET DB2eura.Euravib_dovetail_import(KEEP=Entry_date Dimset Suppl_nr CAS_nr CAS_perc H_nr);
WHERE INDEX(CAS_nr, '50-00-0') > 0 AND Entry_date >= &Start_date AND Entry_date <= &End_date;
RUN;

PROC SQL;
CREATE TABLE work.Sent_MAIL_TRIGGER AS
SELECT COUNT(a.CAS_NR) AS Count
FROM work.VIBcheck a;
QUIT;


%macro MailTrigger;
options emailsys=smtp emailhost="smtp-relay.gmail.com" emailport=25 EMAILID="sas_mail@euramax.eu" ; 
FILENAME mail EMAIL TO="hhalmans@euramax.eu" CC="dverbert@euramax.eu"
SUBJECT="*** Nieuwe msds waarin CAS-nr 50-00-0 voorkomt ***" CONTENT_TYPE="text/html";
ODS LISTING CLOSE; ODS HTML BODY=mail;

TITLE1 "Hoi Hertwig,";
TITLE2 "Er is een nieuwe msds in het systeem gezet waarin CAS-nr 50-00-0 voorkomt.";

PROC PRINT NOOBS DATA=work.VIBcheck; RUN;
ODS HTML CLOSE; ODS LISTING;
%mend;

DATA work.Sent_MAIL_TRIGGER; SET work.Sent_MAIL_TRIGGER;
CALL EXECUTE('%MailTrigger');
WHERE Count>0;
RUN;

