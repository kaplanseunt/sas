

OPTION NOSYNTAXCHECK;
libname DB2SCADA 	ODBC 	schema=DB2SCADA  	noprompt="dsn=db2ecp";
libname CDD 		base 	'\\ecp1ssasdi1\opt-sas\data\Lev3\data\CDD';
libname WHS 		base 	'\\ecp1ssasdi1\opt-sas\data\Lev3\data\WHS';
libname Proficy 	ODBC  	dsn='Proficy' 	schema=dbo 			user=proficydbo password=proficydbo;

/* RM 30-9-2020 Urgent Fix (Mail teun regarding Thickness and In_Thickness) */

DATA work.customers ; 	SET cdd.customers (ENCODING='WLATIN1')	; RUN;
DATA work.lra230  (KEEP=Company Idno Spec value); SET cdd.lra230 (ENCODING='WLATIN1'); WHERE spec IN ('001000','001010') AND Company IN ('ECP','EAP'); RUN;

/**********************************************************************/
/****    ScadaDbLib                          ****/
/**********************************************************************/
/*
PROC SQL;
CREATE TABLE work.ScadaDbLib
(SQLNAME	char(8),
SQLCMD		char(2000)
);
QUIT;


PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (Drop table DB2SCADA.ScadaDbLib) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.ScadaDbLib DATA=work.ScadaDbLib; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.ScadaDbLib TO USER INFODBC )  by baan;
QUIT;
*/
/**********************************************************************/
/****    ScadaDbError                          ****/
/**********************************************************************/
/*PROC SQL;
CREATE TABLE work.ScadaDbError
(TD num informat=Datetime25.6 format=Datetime25.6,
NODE char(8),
TAG char(30),
SQLNAME char(8),
FIX_ERR  char(100),
SQL_ERR char(250),
PROG_ERR char(100));
QUIT;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (Drop table DB2SCADA.ScadaDbError) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.ScadaDbError DATA=work.ScadaDbError; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.ScadaDbError TO USER INFODBC )  by baan;
QUIT;
*/

/**********************************************************************/
/****    EL_Scada_Settings                          ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.EL_Settings as select * from connection to baan
   (SELECT  a.t_conf	AS Conf_nr,
			a.t_cwoc	AS Prod_line,
			a.t_ttro	AS TRO_Type,
			a.t_subs	AS Inp_Dimset,
			a.t_epro	AS End_Dimset,
			a.t_mdat	AS Mut_Date
   FROM      ttdqua140130 a
   WHERE a.t_cwoc = ' EL'
   ORDER BY t_conf);
CREATE table work.EL_Set_spec as select * from connection to baan
   (SELECT  a.*
   FROM      ttdqua141130 a
   ORDER BY t_conf, t_cspe, t_core);
 DISCONNECT from baan;
QUIT;


PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.EL_Settings_EAP as select * from connection to baan
   (SELECT  a.t_conf	AS Conf_nr,
			a.t_cwoc	AS Prod_line,
			a.t_ttro	AS TRO_Type,
			a.t_subs	AS Inp_Dimset,
			a.t_epro	AS End_Dimset,
			a.t_mdat	AS Mut_Date
   FROM      ttdqua140300 a
   WHERE a.t_cwoc IN (' EL','ELE') AND a.t_conf>5000000
   ORDER BY t_conf);
CREATE table work.EL_Set_spec_EAP as select * from connection to baan
   (SELECT  a.*
   FROM      ttdqua141300 a
   WHERE a.t_conf>5000000
   ORDER BY t_conf, t_cspe, t_core);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.EL_Settings DATA=work.EL_Settings_EAP; RUN;
PROC APPEND BASE=work.EL_Set_spec DATA=work.EL_Set_spec_EAP; RUN;

PROC SQL;
CREATE TABLE work.EL_Set_spec AS
SELECT a.*,
	   b.prod_line
FROM work.EL_Set_spec a LEFT OUTER JOIN work.EL_Settings b ON a.t_conf=b.conf_nr;
QUIT;

DATA work.EL_Set_spec(DROP=prod_line); SET work.EL_Set_spec;
IF prod_line = "" THEN DELETE;
RUN;

PROC SORT data=work.EL_Set_spec; BY t_conf t_cspe t_core; RUN;

DATA work.EL_Set_spec1; SET work.EL_Set_spec;
BY t_conf t_cspe t_core;
IF NOT LAST.t_cspe THEN DELETE;
RUN;

DATA work.EL_Set_spec2(KEEP= Conf_nr Spec Value); SET work.EL_Set_spec1;
Conf_nr=t_conf;
Spec=t_cspe;
Value=t_valu;
RUN;

/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.SCADA_SETTINGS_EL_VERTICAL) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.SCADA_SETTINGS_EL_VERTICAL DATA=work.EL_Set_spec2; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_EL_VERTICAL TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='EL_Set_spec2'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;


/***** Horizontal ***/

PROC TRANSPOSE DATA=work.EL_Set_spec1 OUT=work.EL_Set_spec_trans (DROP=_NAME_ _LABEL_);
BY t_conf;
   VAR t_valu;
   ID t_cspe;
RUN;

DATA work.SCADA_SETTINGS_EL(DROP=t_conf); SET work.EL_Set_spec_trans;
Conf_nr=t_conf; 
FORMAT EMB_SEL $1.;		EMB_SEL=substr(emb_sel,1,1);
FORMAT LEV_SEL $1.;		LEV_SEL=substr(LEV_SEL,1,1);
FORMAT FRAC_SEL $1.;	FRAC_SEL=substr(FRAC_SEL,1,1);
FORMAT SIGU_TF $1.;		SIGU_TF=substr(SIGU_TF,1,1);
FORMAT SLIT_SEL $1.;	SLIT_SEL=substr(SLIT_SEL,1,1);
FORMAT SEP_SEL $1.;		SEP_SEL=substr(SEP_SEL,1,1);
FORMAT OSC_SEL $1.;		OSC_SEL=substr(OSC_SEL,1,1);
FORMAT UCEG_TF $1.;		UCEG_TF=substr(UCEG_TF,1,1);
FORMAT UNC_OVW $1.;		UNC_OVW=substr(UNC_OVW,1,1);
FORMAT RCEG_TF $1.;		RCEG_TF=substr(RCEG_TF,1,1);
FORMAT LEV_CR_T $1.;	LEV_CR_T=substr(LEV_CR_T,1,1);
FORMAT LEV_CTTF $1.;	LEV_CTTF=substr(LEV_CTTF,1,1);
FORMAT REC_OVW $1.;		REC_OVW=substr(REC_OVW,1,1);
FORMAT PR2_SEL $1.;		PR2_SEL=substr(PR2_SEL,1,1);
IF EMB_SEL="" 	THEN EMB_SEL="0";
IF LEV_CUR="" 	THEN LEV_CUR="0";
IF LEV_HGHT="" 	THEN LEV_HGHT="0";
IF LEV_SEL="" 	THEN LEV_SEL="0";
IF LEV_TILT="" 	THEN LEV_TILT="0";
IF REC_TEN="" 	THEN REC_TEN="0";
IF UNC_TEN="" 	THEN UNC_TEN="0";
IF FRAC_SEL="" 	THEN FRAC_SEL="0";
IF PR2_SEL="" 	THEN PR2_SEL="0";
IF SIGU_OFS="" 	THEN SIGU_OFS="0";
IF SIGU_TF="" 	THEN SIGU_TF="0";
IF SLIT_SEL="" 	THEN SLIT_SEL="0";
IF PR2_CUR="" 	THEN PR2_CUR="0";
IF SEP_SEL="" 	THEN SEP_SEL="0";
IF OSC_AMPL="" 	THEN OSC_AMPL="0";
IF OSC_FREQ="" 	THEN OSC_FREQ="0";
IF OSC_SEL="" 	THEN OSC_SEL="0";
IF REC_WDTH="" 	THEN REC_WDTH="0";
IF UCEG_OFS="" 	THEN UCEG_OFS="0";
IF UCEG_TF="" 	THEN UCEG_TF="0";
IF SLT_SYST="" 	THEN SLT_SYST="0";
IF LEV_POS1="" 	THEN LEV_POS1="0";
IF LEV_POS2="" 	THEN LEV_POS2="0";
IF LEV_POS3="" 	THEN LEV_POS3="0";
IF LEV_POS4="" 	THEN LEV_POS4="0";
IF LEV_POS5=""	THEN LEV_POS5="0";
IF LEV_POS6="" 	THEN LEV_POS6="0";
IF LEV_POS7="" 	THEN LEV_POS7="0";
IF LEV_POS8="" 	THEN LEV_POS8="0";
IF LEV_POS9="" 	THEN LEV_POS9="0";
IF UNC_OVW="" 	THEN UNC_OVW="0";
IF FRAC_LEN="" 	THEN FRAC_LEN="0";
IF RCEG_OFS="" 	THEN RCEG_OFS="0";
IF RCEG_TF="" 	THEN RCEG_TF="0";
IF LEV_CR_T="" 	THEN LEV_CR_T="0";
IF LEV_CTTF="" 	THEN LEV_CTTF="0";
IF REC_OVW="" 	THEN REC_OVW="0";
IF SYNW_L="" 	THEN SYNW_L="0";
IF SYNW_R="" 	THEN SYNW_R="0";
IF FOIL_TEN="" 	THEN FOIL_TEN="0";
IF LINESPEE="" 	THEN LINESPEE="0";
RUN;


DATA work.SCADA_SETTINGS_EL1	(KEEP=Conf_nr EMB_GDS1 EMB_GOS1 EMB_SEL1 LEV_CUR1 LEV_HGHT1 LEV_SEL1 LEV_TILT1 REC_TEN1 UNC_TEN1 FRAC_
									  SEL1 PR2_SEL1 SIGU_OFS1 SIGU_TF1 SLIT_SEL1 PR2_CUR1 SEP_SEL1 OSC_AMPL1 OSC_FREQ1 OSC_SEL1
									  REC_WDTH1 UCEG_OFS1 UCEG_TF1 SLT_SYST1 LEV_POS1_1 LEV_POS2_1 LEV_POS3_1 LEV_POS4_1 LEV_POS5_1
									  LEV_POS6_1 LEV_POS7_1 LEV_POS8_1 LEV_POS9_1 UNC_OVW1 FRAC_LEN1 RCEG_OFS1 RCEG_TF1 LEV_CR_T1
									  LEV_CTTF1 REC_OVW1 SYNW_L1 SYNW_R1 FOIL_TEN1 LINESPEE1 FRAC_SEL1); 
SET work.SCADA_SETTINGS_EL;
FORMAT EMB_GDS1 10.3;		EMB_GDS1=EMB_GDS;
FORMAT EMB_GOS1 10.3;		EMB_GOS1=EMB_GOS;
FORMAT EMB_SEL1 10.;		EMB_SEL1=EMB_SEL;
FORMAT LEV_CUR1 10.;		LEV_CUR1=LEV_CUR;
FORMAT LEV_HGHT1 10.6;		LEV_HGHT1=LEV_HGHT;
FORMAT LEV_SEL1 10.6;		LEV_SEL1=LEV_SEL;
FORMAT LEV_TILT1 10.2;		LEV_TILT1=LEV_TILT;
FORMAT REC_TEN1 10.;		REC_TEN1=REC_TEN;
FORMAT UNC_TEN1 10.;		UNC_TEN1=UNC_TEN;
FORMAT FRAC_SEL1 10.;		FRAC_SEL1=FRAC_SEL;
FORMAT PR2_SEL1 10.;		PR2_SEL1=PR2_SEL;
FORMAT SIGU_OFS1 10.;		SIGU_OFS1=SIGU_OFS;
FORMAT SIGU_TF1 10.;		SIGU_TF1=SIGU_TF;
FORMAT SLIT_SEL1 10.;		SLIT_SEL1=SLIT_SEL;
FORMAT PR2_CUR1 10.;		PR2_CUR1=PR2_CUR;
FORMAT SEP_SEL1 10.;		SEP_SEL1=SEP_SEL;
FORMAT OSC_AMPL1 10.;		OSC_AMPL1=OSC_AMPL;
FORMAT OSC_FREQ1 10.;		OSC_FREQ1=OSC_FREQ;
FORMAT OSC_SEL1 10.;		OSC_SEL1=OSC_SEL;
FORMAT REC_WDTH1 10.;		REC_WDTH1=REC_WDTH;
FORMAT UCEG_OFS1 10.;		UCEG_OFS1=UCEG_OFS;
FORMAT UCEG_TF1 10.;		UCEG_TF1=UCEG_TF;
FORMAT SLT_SYST1 10.;		SLT_SYST1=SLT_SYST;
FORMAT LEV_POS1_1 10.2;		LEV_POS1_1=LEV_POS1;
FORMAT LEV_POS2_1 10.2;		LEV_POS2_1=LEV_POS2;
FORMAT LEV_POS3_1 10.2;		LEV_POS3_1=LEV_POS3;
FORMAT LEV_POS4_1 10.2;		LEV_POS4_1=LEV_POS4;
FORMAT LEV_POS5_1 10.2;		LEV_POS5_1=LEV_POS5;
FORMAT LEV_POS6_1 10.2;		LEV_POS6_1=LEV_POS6;
FORMAT LEV_POS7_1 10.2;		LEV_POS7_1=LEV_POS7;
FORMAT LEV_POS8_1 10.2;		LEV_POS8_1=LEV_POS8;
FORMAT LEV_POS9_1 10.2;		LEV_POS9_1=LEV_POS9;
FORMAT UNC_OVW1 10.;		UNC_OVW1=UNC_OVW;
FORMAT FRAC_LEN1 10.;		FRAC_LEN1=FRAC_LEN;
FORMAT RCEG_OFS1 10.;		RCEG_OFS1=RCEG_OFS;
FORMAT RCEG_TF1 10.;		RCEG_TF1=RCEG_TF;
FORMAT LEV_CR_T1 10.;		LEV_CR_T1=LEV_CR_T;
FORMAT LEV_CTTF1 10.;		LEV_CTTF1=LEV_CTTF;
FORMAT REC_OVW1 10.;		REC_OVW1=REC_OVW;
FORMAT SYNW_L1 10.;			SYNW_L1=SYNW_L;
FORMAT SYNW_R1 10.;			SYNW_R1=SYNW_R;
FORMAT FOIL_TEN1 10.;		FOIL_TEN1=FOIL_TEN;
FORMAT LINESPEE1 10.;		LINESPEE1=LINESPEE;
RUN;


DATA work.SCADA_SETTINGS_EL1(KEEP=Conf_nr EMB_GDS EMB_GOS EMB_SEL LEV_CUR LEV_HGHT LEV_SEL LEV_TILT REC_TEN UNC_TEN FRAC_SEL PR2_SEL SIGU_OFS SIGU_TF SLIT_SEL PR2_CUR SEP_SEL OSC_AMPL OSC_FREQ OSC_SEL
REC_WDTH UCEG_OFS UCEG_TF SLT_SYST LEV_POS1 LEV_POS2 LEV_POS3 LEV_POS4 LEV_POS5 LEV_POS6 LEV_POS7 LEV_POS8 LEV_POS9 UNC_OVW FRAC_LEN RCEG_OFS RCEG_TF LEV_CR_T LEV_CTTF REC_OVW SYNW_L SYNW_R FOIL_TEN LINESPEE FRAC_SEL); 
SET work.SCADA_SETTINGS_EL1;
RENAME EMB_GDS1 = EMB_GDS;
RENAME EMB_GOS1 = EMB_GOS;
RENAME EMB_SEL1 = EMB_SEL;
RENAME LEV_CUR1 = LEV_CUR;
RENAME LEV_HGHT1 = LEV_HGHT;
RENAME LEV_SEL1 = LEV_SEL;
RENAME LEV_TILT1 = LEV_TILT;
RENAME REC_TEN1 = REC_TEN;
RENAME UNC_TEN1 = UNC_TEN;
RENAME FRAC_SEL1 = FRAC_SEL;
RENAME PR2_SEL1 = PR2_SEL;
RENAME SIGU_OFS1 = SIGU_OFS;
RENAME SIGU_TF1 = SIGU_TF;
RENAME SLIT_SEL1 = SLIT_SEL;
RENAME PR2_CUR1 = PR2_CUR;
RENAME SEP_SEL1 = SEP_SEL;
RENAME OSC_AMPL1 = OSC_AMPL;
RENAME OSC_FREQ1 = OSC_FREQ;
RENAME OSC_SEL1 = OSC_SEL;
RENAME REC_WDTH1 = REC_WDTH;
RENAME UCEG_OFS1 = UCEG_OFS;
RENAME UCEG_TF1 = UCEG_TF;
RENAME SLT_SYST1 = SLT_SYST;
RENAME LEV_POS1_1 = LEV_POS1;
RENAME LEV_POS2_1 = LEV_POS2;
RENAME LEV_POS3_1 = LEV_POS3;
RENAME LEV_POS4_1 = LEV_POS4;
RENAME LEV_POS5_1 = LEV_POS5;
RENAME LEV_POS6_1 = LEV_POS6;
RENAME LEV_POS7_1 = LEV_POS7;
RENAME LEV_POS8_1 = LEV_POS8;
RENAME LEV_POS9_1 = LEV_POS9;
RENAME UNC_OVW1 = UNC_OVW;
RENAME FRAC_LEN1 = FRAC_LEN;
RENAME RCEG_OFS1 = RCEG_OFS;
RENAME RCEG_TF1 = RCEG_TF;
RENAME LEV_CR_T1 = LEV_CR_T;
RENAME LEV_CTTF1 = LEV_CTTF;
RENAME REC_OVW1 = REC_OVW;
RENAME SYNW_L1 = SYNW_L;
RENAME SYNW_R1 = SYNW_R;
RENAME FOIL_TEN1 = FOIL_TEN;
RENAME LINESPEE1 = LINESPEE;
RUN;


/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE FROM DB2SCADA.SCADA_SETTINGS_EL) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.SCADA_SETTINGS_EL DATA=work.SCADA_SETTINGS_EL1 FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_EL TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='SCADA_SETTINGS_EL1'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;


/**********************************************************************/
/****   SCADA_SETTINGS_EL                         ****/
/**********************************************************************/
/*DATA work.Scada_settings_el_vertical; SET _null_;
FORMAT CONF_NR 8.;
FORMAT SPEC $8.;
FORMAT VALUE $8.;
FORMAT Date  $10.;
RUN;


PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_EL_VERTICAL_CHANGES TO USER INFODBC )  by baan;
QUIT;
*/


/**********************************************************************/
/****    SCADA_SETTINGS_ATK                          ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ATK_Settings as select * from connection to baan
   (SELECT  a.t_conf	AS Conf_nr,
			a.t_cwoc	AS Prod_line,
			a.t_ttro	AS SHT_Type,
			a.t_subs	AS Inp_Dimset,
			a.t_epro	AS End_Dimset,
			a.t_mdat	AS Mut_Date
   FROM      ttdqua140130 a
   WHERE a.t_cwoc IN ('SDA','SD5')
   ORDER BY t_conf);
CREATE table work.ATK_Set_spec as select * from connection to baan
   (SELECT  a.*
   FROM      ttdqua141130 a
   ORDER BY t_conf, t_cspe, t_core);
 DISCONNECT from baan;
QUIT;

PROC SQL;
CREATE TABLE work.ATK_Set_spec AS
SELECT a.*,
		b.prod_line
FROM work.ATK_Set_spec a LEFT OUTER JOIN work.ATK_Settings b ON a.t_conf=b.conf_nr;
QUIT;

DATA work.ATK_Set_spec(DROP=prod_line); SET work.ATK_Set_spec;
IF prod_line = '' 	THEN DELETE;
RUN;


PROC SORT data=work.ATK_Set_spec; by t_conf t_cspe t_core; RUN;

DATA work.ATK_Set_spec1; SET work.ATK_Set_spec;
BY t_conf t_cspe t_core;
IF NOT LAST.t_cspe 	THEN DELETE;
RUN;

DATA work.ATK_Set_spec2(KEEP= Conf_nr Spec Value); SET work.ATK_Set_spec1;
Conf_nr=t_conf;
Spec=t_cspe;
Value=t_valu;
RUN;

/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.SCADA_SETTINGS_ATK_VERTICAL) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.SCADA_SETTINGS_ATK_VERTICAL DATA=work.ATK_Set_spec2 FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_ATK_VERTICAL TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='ATK_Set_spec2'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;



/***** Horizontal ***/

PROC TRANSPOSE data=work.ATK_Set_spec1 out=work.ATK_Set_spec_trans (DROP=_NAME_ _LABEL_);
BY t_conf;
   VAR t_valu;
   ID t_cspe;
RUN;

DATA work.SCADA_SETTINGS_ATK(KEEP=Conf_nr EMB_SEL FOIL_TEN LEV_CR_T LEV_CTTF LEV_CUR LEV_HGHT LEV_POS1 LEV_POS2 LEV_POS3 LEV_POS4 LEV_POS5 LEV_POS6 LEV_POS7 LEV_POS8 LEV_POS9
LEV_SEL LEV_TILT LINESPEE UNC_OVW); SET work.ATK_Set_spec_trans;
Conf_nr=t_conf; 
FORMAT EMB_SEL $1.;		EMB_SEL=substr(emb_sel,1,1);
FORMAT LEV_SEL $1.;		LEV_SEL=substr(LEV_SEL,1,1);
FORMAT FRAC_SEL $1.;	FRAC_SEL=substr(FRAC_SEL,1,1);
FORMAT SIGU_TF $1.;		SIGU_TF=substr(SIGU_TF,1,1);
FORMAT SLIT_SEL $1.;	SLIT_SEL=substr(SLIT_SEL,1,1);
FORMAT SEP_SEL $1.;		SEP_SEL=substr(SEP_SEL,1,1);
FORMAT OSC_SEL $1.;		OSC_SEL=substr(OSC_SEL,1,1);
FORMAT UCEG_TF $1.;		UCEG_TF=substr(UCEG_TF,1,1);
FORMAT UNC_OVW $1.;		UNC_OVW=substr(UNC_OVW,1,1);
FORMAT RCEG_TF $1.;		RCEG_TF=substr(RCEG_TF,1,1);
FORMAT LEV_CR_T $1.;	LEV_CR_T=substr(LEV_CR_T,1,1);
FORMAT LEV_CTTF $1.;	LEV_CTTF=substr(LEV_CTTF,1,1);
FORMAT REC_OVW $1.;		REC_OVW=substr(REC_OVW,1,1);
FORMAT PR2_SEL $1.;		PR2_SEL=substr(PR2_SEL,1,1);
IF EMB_SEL="" 	THEN EMB_SEL="0";
IF LEV_CUR="" 	THEN LEV_CUR="0";
IF LEV_HGHT="" 	THEN LEV_HGHT="0";
IF LEV_SEL="" 	THEN LEV_SEL="0";
IF LEV_TILT="" 	THEN LEV_TILT="0";
IF REC_TEN="" 	THEN REC_TEN="0";
IF UNC_TEN="" 	THEN UNC_TEN="0";
IF FRAC_SEL="" 	THEN FRAC_SEL="0";
IF PR2_SEL="" 	THEN PR2_SEL="0";
IF SIGU_OFS="" 	THEN SIGU_OFS="0";
IF SIGU_TF="" 	THEN SIGU_TF="0";
IF SLIT_SEL="" 	THEN SLIT_SEL="0";
IF PR2_CUR="" 	THEN PR2_CUR="0";
IF SEP_SEL="" 	THEN SEP_SEL="0";
IF OSC_AMPL="" 	THEN OSC_AMPL="0";
IF OSC_FREQ="" 	THEN OSC_FREQ="0";
IF OSC_SEL="" 	THEN OSC_SEL="0";
IF REC_WDTH="" 	THEN REC_WDTH="0";
IF UCEG_OFS="" 	THEN UCEG_OFS="0";
IF UCEG_TF="" 	THEN UCEG_TF="0";
IF SLT_SYST="" 	THEN SLT_SYST="0";
IF LEV_POS1="" 	THEN LEV_POS1="0";
IF LEV_POS2="" 	THEN LEV_POS2="0";
IF LEV_POS3="" 	THEN LEV_POS3="0";
IF LEV_POS4="" 	THEN LEV_POS4="0";
IF LEV_POS5="" 	THEN LEV_POS5="0";
IF LEV_POS6="" 	THEN LEV_POS6="0";
IF LEV_POS7="" 	THEN LEV_POS7="0";
IF LEV_POS8="" 	THEN LEV_POS8="0";
IF LEV_POS9="" 	THEN LEV_POS9="0";
IF UNC_OVW="" 	THEN UNC_OVW="0";
IF FRAC_LEN="" 	THEN FRAC_LEN="0";
IF RCEG_OFS="" 	THEN RCEG_OFS="0";
IF RCEG_TF="" 	THEN RCEG_TF="0";
IF LEV_CR_T="" 	THEN LEV_CR_T="0";
IF LEV_CTTF="" 	THEN LEV_CTTF="0";
IF REC_OVW="" 	THEN REC_OVW="0";
IF SYNW_L="" 	THEN SYNW_L="0";
IF SYNW_R="" 	THEN SYNW_R="0";
IF FOIL_TEN="" 	THEN FOIL_TEN="0";
IF LINESPEE="" 	THEN LINESPEE="0";
RUN;


DATA work.SCADA_SETTINGS_ATK1(KEEP=Conf_nr EMB_SEL1 FOIL_TEN1 LEV_CR_T1 LEV_CTTF1 LEV_CUR1 LEV_HGHT1 LEV_POS1_1 LEV_POS2_1 LEV_POS3_1 LEV_POS4_1 LEV_POS5_1 LEV_POS6_1 LEV_POS7_1 LEV_POS8_1 LEV_POS9_1
LEV_SEL1 LEV_TILT1 LINESPEE1 UNC_OVW1); SET work.SCADA_SETTINGS_ATK;
FORMAT EMB_SEL1 10.;	EMB_SEL1=EMB_SEL;
FORMAT FOIL_TEN1 10.;	FOIL_TEN1=FOIL_TEN;
FORMAT LEV_CR_T1 10.;	LEV_CR_T1=LEV_CR_T;
FORMAT LEV_CTTF1 10.;	LEV_CTTF1=LEV_CTTF;
FORMAT LEV_CUR1 10.;	LEV_CUR1=LEV_CUR;
FORMAT LEV_HGHT1 10.6;	LEV_HGHT1=LEV_HGHT;
FORMAT LEV_POS1_1 10.2;	LEV_POS1_1=LEV_POS1;
FORMAT LEV_POS2_1 10.2;	LEV_POS2_1=LEV_POS2;
FORMAT LEV_POS3_1 10.2;	LEV_POS3_1=LEV_POS3;
FORMAT LEV_POS4_1 10.2;	LEV_POS4_1=LEV_POS4;
FORMAT LEV_POS5_1 10.2;	LEV_POS5_1=LEV_POS5;
FORMAT LEV_POS6_1 10.2;	LEV_POS6_1=LEV_POS6;
FORMAT LEV_POS7_1 10.2;	LEV_POS7_1=LEV_POS7;
FORMAT LEV_POS8_1 10.2;	LEV_POS8_1=LEV_POS8;
FORMAT LEV_POS9_1 10.2;	LEV_POS9_1=LEV_POS9;
FORMAT LEV_SEL1 10.;	LEV_SEL1=LEV_SEL;
FORMAT LEV_TILT1 10.2;	LEV_TILT1=LEV_TILT;
FORMAT LINESPEE1 10.;	LINESPEE1=LINESPEE;
FORMAT UNC_OVW1 10.;	UNC_OVW1=UNC_OVW;
RUN;	

DATA work.SCADA_SETTINGS_ATK1(KEEP=Conf_nr EMB_SEL FOIL_TEN LEV_CR_T LEV_CTTF LEV_CUR LEV_HGHT LEV_POS1 LEV_POS2 LEV_POS3 LEV_POS4 LEV_POS5 LEV_POS6 LEV_POS7 LEV_POS8 LEV_POS9
LEV_SEL LEV_TILT LINESPEE UNC_OVW); SET work.SCADA_SETTINGS_ATK1;
RENAME EMB_SEL1 = EMB_SEL;
RENAME FOIL_TEN1 = FOIL_TEN;
RENAME LEV_CR_T1 = LEV_CR_T;
RENAME LEV_CTTF1 = LEV_CTTF;
RENAME LEV_CUR1 = LEV_CUR;
RENAME LEV_HGHT1 = LEV_HGHT;
RENAME LEV_POS1_1 = LEV_POS1;
RENAME LEV_POS2_1 = LEV_POS2;
RENAME LEV_POS3_1 = LEV_POS3;
RENAME LEV_POS4_1 = LEV_POS4;
RENAME LEV_POS5_1 = LEV_POS5;
RENAME LEV_POS6_1 = LEV_POS6;
RENAME LEV_POS7_1 = LEV_POS7;
RENAME LEV_POS8_1 = LEV_POS8;
RENAME LEV_POS9_1 = LEV_POS9;
RENAME LEV_SEL1 = LEV_SEL;
RENAME LEV_TILT1 = LEV_TILT;
RENAME LINESPEE1 = LINESPEE;
RENAME UNC_OVW1 = UNC_OVW;
RUN;

/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE FROM DB2SCADA.SCADA_SETTINGS_ATK) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.SCADA_SETTINGS_ATK DATA=work.SCADA_SETTINGS_ATK1 FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_ATK TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='SCADA_SETTINGS_ATK1'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;



/*
PROC SQL;
CONNECT to odbc as db2 (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_ATK_CHANGES TO USER INFODBC )  by db2;
QUIT;
*/
/**********************************************************************/
/****    Scada_Settings_SPL                          ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Gen_Prod as select * from connection to baan
   (SELECT  a.t_epro  	Dimset,
			a.t_gpro	Gen_Prod,
			b.t_prod	Int_Prod,
			c.t_stro	TRO_Stand,
			d.t_layr	Layer,
			e.t_spec	Spec,
			e.t_cwoc	Prod_Line
   FROM      ttdqua050300 a,
   			 ttdqua041300 b,
			 ttdqua030300 c,
			 ttdqua031300 d,
			 ttdqua020300 e
   WHERE a.t_gpro=b.t_gpro AND b.t_prod=c.t_prod AND b.t_prod=d.t_prod AND d.t_layr=e.t_layr AND e.t_cwoc IN ('SPL','WPL')
   ORDER BY  a.t_epro   );
 DISCONNECT from baan;
QUIT;

/*** Collect TRO-orders RUN 1 Primer FS ***/

DATA work.rou102 ; 			SET cdd.rou102 			(ENCODING='WLATIN1'); 									RUN;
DATA work.sfc001 ; 			SET cdd.sfc001 			(ENCODING='WLATIN1'); 									RUN;
DATA work.TRO_Act; 			SET cdd.TRO_Act 		(ENCODING='WLATIN1'); 									RUN;
DATA work.Dimsets; 			SET cdd.Dimsets 		(ENCODING='WLATIN1'); WHERE Company IN ('ECP','EAP'); 	RUN;
DATA work.qua002; 			SET cdd.qua002 			(ENCODING='WLATIN1'); 									RUN;
DATA work.mdm310; 			SET cdd.mdm310 			(ENCODING='WLATIN1'); 									RUN;
DATA work.mdm315; 			SET cdd.mdm315 			(ENCODING='WLATIN1'); WHERE Company IN ('ECP','EAP'); 	RUN;
DATA work.Default_Specs; 	SET whs.Default_Specs 	(ENCODING='WLATIN1'); 									RUN;

PROC SQL;
CREATE TABLE work.TRO_Order_F_1_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011010'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 				AND 
	  b.Company=c.Company 	AND b.Primer=c.Dimset 				AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL','WPL') 	AND d.TRO_Type_stand IN ('SPL 1','WPL 1','S-SPL 1') AND
	  a.Company=d.Company 	AND a.Database=d.Database 			AND a.TRO_Type=d.TRO_Type 							AND
	  a.company=e.company 	AND a.database=e.database 			AND a.tro_ord_nr=e.tro_ord_nr 						AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;

/*
PROC SQL;
CREATE TABLE work.TRO_Order_F_1_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	As TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011010'			AS Spec
FROM cdd.TRO_Act a		INNER JOIN cdd.Dimsets b ON a.Company=b.Company AND a.Dimset=b.Dimset
						INNER JOIN cdd.Dimsets c ON a.Company=c.Company AND b.Primer=c.Dimset
						INNER JOIN cdd.qua002  d ON a.Company=d.Company AND a.TRO_Type=d.TRO_Type
	 					INNER JOIN cdd.sfc001  e ON a.Company=e.Company AND a.tro_ord_nr=e.tro_ord_nr
						INNER JOIN cdd.rou102  f ON a.Company=f.Company AND e.item_nr=f.item_nr AND e.Routing=f.Routing
WHERE d.TRO_Type_stand IN ('SPL 1','WPL 1','S-SPL 1')
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;  */


/*** Collect TRO-orders RUN 1 Topcoat FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_1_2 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011020'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 				AND 
	  b.Company=c.Company 	AND b.Topcoat1=c.Dimset 			AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL','WPL') 	AND d.TRO_Type_stand IN ('SPL 1','WPL 1','S-SPL 1') AND
	  a.Company=d.Company 	AND a.Database=d.Database 			AND a.TRO_Type=d.TRO_Type 							AND
	  a.company=e.company 	AND a.database=e.database 			AND a.tro_ord_nr=e.tro_ord_nr  						AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 1 Primer RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_1_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012010'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 				AND 
	  b.Company=c.Company 	AND b.Backcoat=c.Dimset 			AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL','WPL') 	AND d.TRO_Type_stand IN ('SPL 1','WPL 1','S-SPL 1') AND
	  a.Company=d.Company 	AND a.Database=d.Database 			AND a.TRO_Type=d.TRO_Type 							AND
	  a.company=e.company 	AND a.database=e.database 			AND a.tro_ord_nr=e.tro_ord_nr  						AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 1 Topcoat RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_1_2 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012020'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 				AND 
	  b.Company=c.Company 	AND b.Backcoat1=c.Dimset 			AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL','WPL') 	AND d.TRO_Type_stand IN ('SPL 1','WPL 1','S-SPL 1') AND
	  a.Company=d.Company 	AND a.Database=d.Database 			AND a.TRO_Type=d.TRO_Type 							AND
	  a.company=e.company 	AND a.database=e.database 			AND a.tro_ord_nr=e.tro_ord_nr  						AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 2 Topcoat 2 FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_2_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011030'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 				AND 
	  b.Company=c.Company 	AND b.Topcoat2=c.Dimset 			AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL','WPL') 	AND d.TRO_Type_stand IN ('SPL 2','WPL 2','S-SPL 2') AND
	  a.Company=d.Company 	AND a.Database=d.Database 			AND a.TRO_Type=d.TRO_Type 							AND
	  a.company=e.company 	AND a.database=e.database 			AND a.tro_ord_nr=e.tro_ord_nr  						AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 2 Topcoat 3 FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_2_2 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011040'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 				AND 
	  b.Company=c.Company 	AND b.Topcoat3=c.Dimset 			AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL','WPL') 	AND d.TRO_Type_stand IN ('SPL 2','WPL 2','S-SPL 2') AND
	  a.Company=d.Company 	AND a.Database=d.Database 			AND a.TRO_Type=d.TRO_Type 							AND
	  a.company=e.company 	AND a.database=e.database 			AND a.tro_ord_nr=e.tro_ord_nr  						AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;

/*** Collect TRO-orders RUN 2 Backcoat 2 RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_2_2b AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012020'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Backcoat1=c.Dimset 	AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL') 	AND d.TRO_Type_stand IN ('SPL 2','S-SPL 2') AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 					AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr  				AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;

/*** Collect TRO-orders RUN 2 Topcoat 2 RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_2_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012030'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 				AND 
	  b.Company=c.Company 	AND b.Backcoat2=c.Dimset 			AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL','WPL') 	AND d.TRO_Type_stand IN ('SPL 2','WPL 2','S-SPL 2') AND
	  a.Company=d.Company 	AND a.Database=d.Database 			AND a.TRO_Type=d.TRO_Type 							AND
	  a.company=e.company 	AND a.database=e.database 			AND a.tro_ord_nr=e.tro_ord_nr  						AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 2 Topcoat 3 RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_2_2 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012040'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 				AND 
	  b.Company=c.Company 	AND b.Backcoat3=c.Dimset 			AND
	  a.Company='EAP' 		AND f.Prod_line IN ('SPL','WPL') 	AND d.TRO_Type_stand IN ('SPL 2','WPL 2','S-SPL 2') AND
	  a.Company=d.Company 	AND a.Database=d.Database 			AND a.TRO_Type=d.TRO_Type 							AND
	  a.company=e.company 	AND a.database=e.database 			AND a.tro_ord_nr=e.tro_ord_nr  						AND e.company='EAP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


PROC SORT DATA=TRO_Order_F_1_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_F_1_2 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_1_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_1_2 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_F_2_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_F_2_2 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_2_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_2_2 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_2_2b nodups; BY Company TRO_Ord_nr; RUN;


DATA work.TRO_Order; SET TRO_Order_F_1_1; RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_F_1_2;  RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_1_1;  RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_1_2;  RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_F_2_1;  RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_F_2_2;  RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_2_1;  RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_2_2;  RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_2_2b; RUN;


PROC SQL;
CREATE TABLE work.TRO_Order1 AS
SELECT a.*, b.layer
FROM work.TRO_Order a LEFT OUTER JOIN work.gen_prod b ON a.Dimset=b.Dimset AND a.Spec=b.Spec AND a.Prod_line=b.Prod_line AND a.TRO_Stand=b.TRO_Stand ;
QUIT;
PROC SQL;
CREATE TABLE work.TRO_Order2 AS
SELECT a.*, b.PMT		AS PMT_Dims Label 'PMT_Dims',
		    b.PMT_Min	AS PMT_Min	Label 'PMT_Min',
		    b.PMT_Max	AS PMT_Max	Label 'PMT_Max'
FROM work.TRO_Order1 a LEFT OUTER JOIN CDD.qua037 b ON 
					a.company=b.company AND a.Prod_line=b.Prod_line AND a.Layer=b.Layer AND a.Paint_Code=b.Paint_code AND a.Suppl_nr=b.Suppl_nr;
QUIT;
PROC SQL;
CREATE TABLE work.TRO_Order3 AS
SELECT a.*, b.PMT	AS PMT_Syst Label 'PMT_Syst'
FROM work.TRO_Order2 a LEFT OUTER JOIN CDD.qua037 b ON 
					a.company=b.company AND a.Prod_line=b.Prod_line AND a.Layer=b.Layer AND a.Paint_Syst=b.Paint_Syst AND a.Suppl_nr=b.Suppl_nr AND b.Paint_code="";
QUIT;
PROC SQL;
CREATE TABLE work.TRO_Order4 AS
SELECT a.*, b.PMT	AS PMT_Syst_gen Label 'PMT_Syst_gen'
FROM work.TRO_Order3 a LEFT OUTER JOIN CDD.qua037 b ON 
					a.company=b.company AND a.Prod_line=b.Prod_line AND a.Layer=b.Layer AND a.Paint_Syst=b.Paint_Syst AND b.Suppl_nr="" AND b.Paint_code="";
QUIT;


DATA work.TRO_Order (DROP=PMT_Syst PMT_Dims PMT_Syst_gen);
SET work.TRO_order4;
PMT=PMT_Dims;
IF PMT_Dims EQ "" AND PMT_Syst NE "" 		THEN PMT=PMT_Syst;
IF PMT_Dims EQ "" AND PMT_Syst_gen NE "" 	THEN PMT=PMT_Syst_gen;
IF PMT="" 									THEN PMT='000';
IF Spec='011030' 							THEN Spec='011010';
IF Spec='011040' 							THEN Spec='011020';
IF Spec='012030' 							THEN Spec='012010';
IF Spec='012040' 							THEN Spec='012020';
IF TRO_Stand='SPL 2' AND Spec='012020' 		THEN Spec='012010';
WHERE Paint_code NE "-" AND Layer ne "";
RUN;

PROC SORT DATA=work.TRO_Order nodups; BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand; RUN;

PROC TRANSPOSE DATA= work.TRO_Order OUT=work.TRO_Order_Trans  (drop=_NAME_ _LABEL_);
BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand;   VAR PMT;     ID Spec;
RUN;

DATA work.TRO_Order_Trans; SET work.TRO_Order_Trans;
RENAME _011010 = PMT_TL1_TVL;
RENAME _011020 = PMT_TL2_TVL;
RENAME _012010 = PMT_BL1_TVL;
RENAME _012020 = PMT_BL2_TVL;
RUN;
PROC TRANSPOSE DATA= work.TRO_Order OUT=work.TRO_Order_Trans_Min  (drop=_NAME_ _LABEL_);
BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand;   VAR PMT_Min;     ID Spec;
RUN;
DATA work.TRO_Order_Trans_Min; SET work.TRO_Order_Trans_Min;
RENAME _011010 = PMT_TL1_MIN;
RENAME _011020 = PMT_TL2_MIN;
RENAME _012010 = PMT_BL1_MIN;
RENAME _012020 = PMT_BL2_MIN;
RUN;
PROC TRANSPOSE DATA= work.TRO_Order OUT=work.TRO_Order_Trans_Max  (drop=_NAME_ _LABEL_);
BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand;   VAR PMT_Max;     ID Spec;
RUN;
DATA work.TRO_Order_Trans_Max; SET work.TRO_Order_Trans_Max;
RENAME _011010 = PMT_TL1_MAX;
RENAME _011020 = PMT_TL2_MAX;
RENAME _012010 = PMT_BL1_MAX;
RENAME _012020 = PMT_BL2_MAX;
RUN;

DATA work.TRO_Order_Trans;
MERGE work.TRO_Order_Trans work.TRO_Order_Trans_Min work.TRO_Order_Trans_Max;
BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand;
RUN;


PROC SQL; CREATE TABLE work.TRO_Order_Trans AS
SELECT 	a.*,
		b.Item_nr,
		b.S_001030  AS AlloyT       Label='AlloyT',
		b.S_010010	AS ChemCoatVZ 	Label='ChemCoatVZ',
		b.S_010020	AS ChemCoatKZ 	Label='ChemCoatKZ',
		b.S_020010	AS ChemCoatWPL 	Label='ChemCoatWPL',
		b.S_010050	AS InkjetText 	Label='InkjetText',
		b.S_060010	AS Fol 			Label='Fol',
		b.S_011010	AS PMT_TL1	 	Label='PMT_TL1',
		b.S_011014	AS LTH_TL1_TVL	Label='LTH_TL1_TVL',
		b.S_011020	AS PMT_TL2	 	Label='PMT_TL2',
		b.S_011024	AS LTH_TL2_TVL	Label='LTH_TL2_TVL',
		b.S_011030	AS PMT_TL3 		Label='PMT_TL3',
		b.S_011034	AS LTH_TL3_TVL	Label='LTH_TL3_TVL',
		b.S_011040	AS PMT_TL4 		Label='PMT_TL4',
		b.S_011044	AS LTH_TL4_TVL	Label='LTH_TL4_TVL',
		b.S_012010	AS PMT_BL1	 	Label='PMT_BL1',
		b.S_012014	AS LTH_BL1_TVL	Label='LTH_BL1_TVL',
		b.S_012020	AS PMT_BL2 		Label='PMT_BL2',
		b.S_012024	AS LTH_BL2_TVL	Label='LTH_BL2_TVL',
		b.S_012030	AS PMT_BL3	 	Label='PMT_BL3',
		b.S_012034	AS LTH_BL3_TVL	Label='LTH_BL3_TVL',
		b.S_012040	AS PMT_BL4	 	Label='PMT_BL4',
		b.S_012044	AS LTH_BL4_TVL	Label='LTH_BL4_TVL',
		b.S_020012	AS WPL_Design	Label='WPL_Design',
		b.S_050100	AS Aluf_Text  	Label='Aluf_Text'
FROM work.TRO_Order_Trans a LEFT OUTER JOIN Work.Default_Specs b ON a.Company=b.Company AND a.Dimset=b.Dimset;
QUIT;


DATA work.TRO_Order_Trans1 (DROP=PMT_TL3 PMT_TL4 PMT_BL3 PMT_BL4 LTH_TL3_TVL LTH_TL4_TVL LTH_BL3_TVL InkjetText Aluf_Text AlloyT);
SET work.TRO_Order_Trans;

IF INDEX(TRO_Stand,'2') AND SUBSTR(PMT_BL2,3,1)='A' 			THEN DO; 	PMT_BL3=PMT_BL2; PMT_BL2=""; LTH_BL3_TVL=LTH_BL2_TVL; LTH_BL2_TVL="";      								END;
IF INDEX(TRO_Stand,'2')  										THEN DO; 	PMT_TL1=PMT_TL3; PMT_TL2=PMT_TL4; PMT_BL1=PMT_BL3; PMT_BL2=PMT_BL4; 
								                             				LTH_TL1_TVL=LTH_TL3_TVL;  LTH_TL2_TVL=LTH_TL4_TVL; LTH_BL1_TVL=LTH_BL3_TVL; LTH_BL2_TVL=LTH_BL4_TVL; 	END;
Inkjet="0";
IF InkjetText='GEEN' 											THEN Inkjet="0";
IF InkjetText='ECP CODE' 										THEN Inkjet="1";
IF InkjetText='SPECIFIEK' 										THEN Inkjet="2";
IF Aluf_Text NE "" 												THEN Alufiber="1"; ELSE Alufiber="0";
IF INDEX(TRO_Stand,'1')>0   									THEN Degrease='1'; ELSE Degrease='0';
TRO_Run_nr=INPUT(Substr(TRO_Stand,5,1),1.0); 
IF TRO_Run_nr=1 												THEN TRO_Run_nr=0; ELSE TRO_Run_nr=1;
IF TRO_Stand IN ('S-SPL 1') 									THEN TRO_Run_nr=0;
IF TRO_Stand IN ('S-SPL 2') 									THEN TRO_Run_nr=1;
IF INDEX(AlloyT,'HSA')>0 										THEN AlloyT='5083';
Alloy=INPUT(Substr(AlloyT,1,4),4.0);
RUN;



DATA work.SCADA_SETTINGS_SPL(KEEP=Company TRO_Ord_nr TRO_Run_nr Alloy ChemcoatKZ ChemcoatVZ Fol Inkjet Substrate Topcoat_VZ 
								  LTH_TL1_TVL LTH_TL2_TVL LTH_BL1_TVL LTH_BL2_TVL
								  PMT_BL1 PMT_BL1_MAX PMT_BL1_MIN PMT_BL1_TVL
								  PMT_BL2 PMT_BL2_MAX PMT_BL2_MIN PMT_BL2_TVL
								  PMT_TL1 PMT_TL1_MAX PMT_TL1_MIN PMT_TL1_TVL
								  PMT_TL2 PMT_TL2_MAX PMT_TL2_MIN PMT_TL2_TVL);
SET work.TRO_Order_Trans1;
IF Fol ne "-" 					THEN Fol='1'; 				ELSE Fol='0';
IF Item_Nr='ALU' 				THEN Substrate='1'; 		ELSE Substrate='0'; 
IF ChemcoatVZ='' 				THEN ChemcoatVZ='0';
IF ChemcoatVZ='ANORCOAT' 		THEN ChemcoatVZ='1';
IF ChemcoatVZ='ZIRKOON' 		THEN ChemcoatVZ='2';
IF ChemcoatVZ='CHROOMVRIJ' 		THEN ChemcoatVZ='2';
IF ChemcoatVZ='CR VRIJ STA' 	THEN ChemcoatVZ='2'; /* RM Added 11-6-2020 */
IF ChemcoatVZ='CHROM GROEN' 	THEN ChemcoatVZ='3';
IF ChemcoatVZ='CHROM GEEL' 		THEN ChemcoatVZ='4';
IF ChemcoatVZ='SIZINK'	 		THEN ChemcoatVZ='5';
IF ChemcoatVZ='ONTVET' 			THEN ChemcoatVZ='0';
IF ChemcoatKZ='' 				THEN ChemcoatKZ='0';
IF ChemcoatKZ='ANORCOAT' 		THEN ChemcoatKZ='1';
IF ChemcoatKZ='ZIRKOON' 		THEN ChemcoatKZ='2';
IF ChemcoatKZ='CHROOMVRIJ' 		THEN ChemcoatKZ='2';
IF ChemcoatKZ='CR VRIJ STA' 	THEN ChemcoatKZ='2'; /* RM Added 11-6-2020 */
IF ChemcoatKZ='CHROM GROEN' 	THEN ChemcoatKZ='3';
IF ChemcoatKZ='CHROM GEEL' 		THEN ChemcoatKZ='4';
IF ChemcoatKZ='SIZINK'  		THEN ChemcoatKZ='5';
IF ChemcoatKZ='ONTVET' 			THEN ChemcoatKZ='0';
IF PMT_TL2 ne '-' 				THEN Topcoat_VZ=PMT_TL2; 	ELSE Topcoat_VZ=PMT_TL1;
IF TRO_Stand='SPL 2' 			THEN DO; ChemcoatVZ='0'; ChemcoatKZ='0'; END;
WHERE prod_line='SPL';
RUN;

DATA work.SCADA_SETTINGS_SPL1(KEEP=Company TRO_Ord_nr TRO_Run_nr Alloy ChemcoatKZ1 ChemcoatVZ1 Fol1 Inkjet1 Substrate1 Topcoat_VZ 
LTH_TL1_TVL1 LTH_TL2_TVL1 LTH_BL1_TVL1 LTH_BL2_TVL1
PMT_BL1 PMT_BL1_MAX1 PMT_BL1_MIN1 PMT_BL1_TVL1
PMT_BL2 PMT_BL2_MAX1 PMT_BL2_MIN1 PMT_BL2_TVL1
PMT_TL1 PMT_TL1_MAX1 PMT_TL1_MIN1 PMT_TL1_TVL1
PMT_TL2 PMT_TL2_MAX1 PMT_TL2_MIN1 PMT_TL2_TVL1); 	SET work.SCADA_SETTINGS_SPL;
FORMAT ChemcoatKZ1 10.;		ChemcoatKZ1=ChemcoatKZ;
FORMAT ChemcoatVZ1 10.;		ChemcoatVZ1=ChemcoatVZ;
FORMAT Fol1 10.;			Fol1=Fol;
FORMAT Inkjet1 10.;			Inkjet1=Inkjet;
FORMAT Substrate1 10.;		Substrate1=Substrate;
FORMAT PMT_BL1_MAX1 10.;	PMT_BL1_MAX1=PMT_BL1_MAX;
FORMAT PMT_BL1_MIN1 10.;	PMT_BL1_MIN1=PMT_BL1_MIN;
FORMAT PMT_BL1_TVL1 10.;	PMT_BL1_TVL1=PMT_BL1_TVL;
FORMAT PMT_BL2_MAX1 10.;	PMT_BL2_MAX1=PMT_BL2_MAX;
FORMAT PMT_BL2_MIN1 10.;	PMT_BL2_MIN1=PMT_BL2_MIN;
FORMAT PMT_BL2_TVL1 10.;	PMT_BL2_TVL1=PMT_BL2_TVL;
FORMAT PMT_TL1_MAX1 10.;	PMT_TL1_MAX1=PMT_TL1_MAX;
FORMAT PMT_TL1_MIN1 10.;	PMT_TL1_MIN1=PMT_TL1_MIN;
FORMAT PMT_TL1_TVL1 10.;	PMT_TL1_TVL1=PMT_TL1_TVL;
FORMAT PMT_TL2_MAX1 10.;	PMT_TL2_MAX1=PMT_TL2_MAX;
FORMAT PMT_TL2_MIN1 10.;	PMT_TL2_MIN1=PMT_TL2_MIN;
FORMAT PMT_TL2_TVL1 10.;	PMT_TL2_TVL1=PMT_TL2_TVL;
FORMAT LTH_TL1_TVL1 10.;	LTH_TL1_TVL1=LTH_TL1_TVL;
FORMAT LTH_TL2_TVL1 10.;	LTH_TL2_TVL1=LTH_TL2_TVL;
FORMAT LTH_BL1_TVL1 10.;	LTH_BL1_TVL1=LTH_BL1_TVL;
FORMAT LTH_BL2_TVL1 10.;	LTH_BL2_TVL1=LTH_BL2_TVL;
RUN;

DATA work.SCADA_SETTINGS_SPL1 (KEEP=Company TRO_Ord_nr TRO_Run_nr Alloy ChemcoatKZ ChemcoatVZ Fol Inkjet Substrate Topcoat_VZ 
LTH_TL1_TVL LTH_TL2_TVL LTH_BL1_TVL LTH_BL2_TVL
PMT_BL1 PMT_BL1_MAX PMT_BL1_MIN PMT_BL1_TVL
PMT_BL2 PMT_BL2_MAX PMT_BL2_MIN PMT_BL2_TVL
PMT_TL1 PMT_TL1_MAX PMT_TL1_MIN PMT_TL1_TVL
PMT_TL2 PMT_TL2_MAX PMT_TL2_MIN PMT_TL2_TVL); 		SET work.SCADA_SETTINGS_SPL1;
RENAME ChemcoatKZ1 = ChemcoatKZ;
RENAME ChemcoatVZ1 = ChemcoatVZ;
RENAME Fol1 = Fol;
RENAME Inkjet1 = Inkjet;
RENAME Substrate1 = Substrate;
RENAME PMT_BL1_MAX1 = PMT_BL1_MAX;
RENAME PMT_BL1_MIN1 = PMT_BL1_MIN;
RENAME PMT_BL1_TVL1 = PMT_BL1_TVL;
RENAME PMT_BL2_MAX1 = PMT_BL2_MAX;
RENAME PMT_BL2_MIN1 = PMT_BL2_MIN;
RENAME PMT_BL2_TVL1 = PMT_BL2_TVL;
RENAME PMT_TL1_MAX1 = PMT_TL1_MAX;
RENAME PMT_TL1_MIN1 = PMT_TL1_MIN;
RENAME PMT_TL1_TVL1 = PMT_TL1_TVL;
RENAME PMT_TL2_MAX1 = PMT_TL2_MAX;
RENAME PMT_TL2_MIN1 = PMT_TL2_MIN;
RENAME PMT_TL2_TVL1 = PMT_TL2_TVL;
RENAME LTH_TL1_TVL1 = LTH_TL1_TVL;
RENAME LTH_TL2_TVL1 = LTH_TL2_TVL;
RENAME LTH_BL1_TVL1 = LTH_BL1_TVL;
RENAME LTH_BL2_TVL1 = LTH_BL2_TVL;
RUN;

DATA work.SCADA_SETTINGS_SPL1; SET work.SCADA_SETTINGS_SPL1;
IF PMT_TL1="" 		THEN PMT_TL1="-";
IF PMT_TL2="" 		THEN PMT_TL2="-";
IF PMT_BL1=""	 	THEN PMT_BL1="-";
IF PMT_BL2="" 		THEN PMT_BL2="-";
IF Inkjet=. 		THEN Inkjet=0;
IF Substrate=. 		THEN Substrate=0;
IF PMT_BL1_MAX=. 	THEN PMT_BL1_MAX=0;
IF PMT_BL1_MIN=. 	THEN PMT_BL1_MIN=0;
IF PMT_BL1_TVL=. 	THEN PMT_BL1_TVL=0;
IF PMT_BL2_MAX=. 	THEN PMT_BL2_MAX=0;
IF PMT_BL2_MIN=. 	THEN PMT_BL2_MIN=0;
IF PMT_BL2_TVL=. 	THEN PMT_BL2_TVL=0;
IF PMT_TL1_MAX=. 	THEN PMT_TL1_MAX=0;
IF PMT_TL1_MIN=. 	THEN PMT_TL1_MIN=0;
IF PMT_TL1_TVL=. 	THEN PMT_TL1_TVL=0;
IF PMT_TL2_MAX=. 	THEN PMT_TL2_MAX=0;
IF PMT_TL2_MIN=. 	THEN PMT_TL2_MIN=0;
IF PMT_TL2_TVL=. 	THEN PMT_TL2_TVL=0;
IF LTH_TL1_TVL=. 	THEN LTH_TL1_TVL=0;
IF LTH_TL2_TVL=. 	THEN LTH_TL2_TVL=0;
IF LTH_BL1_TVL=. 	THEN LTH_BL1_TVL=0;
IF LTH_BL2_TVL=. 	THEN LTH_BL2_TVL=0;
RUN;

/* GET Planned Linespeed  */
PROC SQL;
CREATE TABLE work.Linespeed AS
SELECT  a.Company, a.TRO_ord_nr, AVG(Linespeed) AS Linespeed_plan
FROM WHS.rol_reforcast_new_cap a
WHERE a.Prod_line IN ('SPL','WPL') AND SUBSTR(a.Rep_Group,1,1) IN ('4','5')
GROUP BY a.Company, a.TRO_ord_nr
ORDER BY a.Company, a.TRO_ord_nr;
QUIT;

PROC SQL;
CREATE TABLE work.SCADA_SETTINGS_SPL1 AS
SELECT a.*, b.Linespeed_plan
FROM work.SCADA_SETTINGS_SPL1 a LEFT OUTER JOIN work.Linespeed b ON a.Company=b.Company AND a.TRO_Ord_nr=b.TRO_Ord_nr;
QUIT;
DATA work.SCADA_SETTINGS_SPL1; SET work.SCADA_SETTINGS_SPL1; IF Linespeed_plan=. THEN Linespeed_plan=1; RUN;


DATA work.SCADA_SETTINGS_SPL_VERTICAL(KEEP= Company Tro_Ord_NR Spec Value); SET work.SCADA_SETTINGS_SPL1;
FORMAT Spec $50.;
FORMAT Value $50.;
IF PMT_TL1 NE ""  		THEN DO; Spec='PMT_TL1'			; Value=compress(PMT_TL1); 			OUTPUT; END;
IF PMT_TL2 NE ""  		THEN DO; Spec='PMT_TL2' 		; Value=compress(PMT_TL2); 			OUTPUT; END;
IF PMT_BL1 NE ""  		THEN DO; Spec='PMT_BL1' 		; Value=compress(PMT_BL1); 			OUTPUT; END;
IF PMT_BL2 NE ""  		THEN DO; Spec='PMT_BL2' 		; Value=compress(PMT_BL2); 			OUTPUT; END;
IF TRO_RUN_NR NE .  	THEN DO; Spec='TRO_RUN_NR' 		; Value=compress(TRO_RUN_NR); 		OUTPUT; END;
IF ALLOY NE .  			THEN DO; Spec='ALLOY' 			; Value=compress(ALLOY); 			OUTPUT; END;
IF TOPCOAT_VZ NE .  	THEN DO; Spec='TOPCOAT_VZ' 		; Value=compress(TOPCOAT_VZ); 		OUTPUT; END;
IF CHEMCOATKZ NE .  	THEN DO; Spec='CHEMCOATKZ' 		; Value=compress(CHEMCOATKZ); 		OUTPUT; END;
IF CHEMCOATVZ NE .  	THEN DO; Spec='CHEMCOATVZ' 		; Value=compress(CHEMCOATVZ); 		OUTPUT; END;
IF FOL NE .  			THEN DO; Spec='FOL' 			; Value=compress(FOL); 				OUTPUT; END;
IF INKJET NE .  		THEN DO; Spec='INKJET' 			; Value=compress(INKJET); 			OUTPUT; END;
IF SUBSTRATE NE .  		THEN DO; Spec='SUBSTRATE' 		; Value=compress(SUBSTRATE); 		OUTPUT; END;
IF PMT_BL1_MAX NE .  	THEN DO; Spec='PMT_BL1_MAX' 	; Value=compress(PMT_BL1_MAX); 		OUTPUT; END;
IF PMT_BL1_MIN NE .  	THEN DO; Spec='PMT_BL1_MIN' 	; Value=compress(PMT_BL1_MIN); 		OUTPUT; END;
IF PMT_BL1_TVL NE .  	THEN DO; Spec='PMT_BL1_TVL' 	; Value=compress(PMT_BL1_TVL); 		OUTPUT; END;
IF PMT_BL2_MAX NE .  	THEN DO; Spec='PMT_BL2_MAX' 	; Value=compress(PMT_BL2_MAX); 		OUTPUT; END;
IF PMT_BL2_MIN NE .  	THEN DO; Spec='PMT_BL2_MIN' 	; Value=compress(PMT_BL2_MIN); 		OUTPUT; END;
IF PMT_BL2_TVL NE .  	THEN DO; Spec='PMT_BL2_TVL' 	; Value=compress(PMT_BL2_TVL); 		OUTPUT; END;
IF PMT_TL1_MAX NE .  	THEN DO; Spec='PMT_TL1_MAX' 	; Value=compress(PMT_TL1_MAX); 		OUTPUT; END;
IF PMT_TL1_MIN NE .  	THEN DO; Spec='PMT_TL1_MIN' 	; Value=compress(PMT_TL1_MIN); 		OUTPUT; END;
IF PMT_TL1_TVL NE .  	THEN DO; Spec='PMT_TL1_TVL' 	; Value=compress(PMT_TL1_TVL); 		OUTPUT; END;
IF PMT_TL2_MAX NE .  	THEN DO; Spec='PMT_TL2_MAX' 	; Value=compress(PMT_TL2_MAX); 		OUTPUT; END;
IF PMT_TL2_MIN NE .  	THEN DO; Spec='PMT_TL2_MIN' 	; Value=compress(PMT_TL2_MIN); 		OUTPUT; END;
IF PMT_TL2_TVL NE .  	THEN DO; Spec='PMT_TL2_TVL' 	; Value=compress(PMT_TL2_TVL); 		OUTPUT; END;
IF LTH_TL1_TVL NE .  	THEN DO; Spec='LTH_TL1_TVL' 	; Value=compress(LTH_TL1_TVL); 		OUTPUT; END;
IF LTH_TL2_TVL NE .  	THEN DO; Spec='LTH_TL2_TVL' 	; Value=compress(LTH_TL2_TVL); 		OUTPUT; END;
IF LTH_BL1_TVL NE .  	THEN DO; Spec='LTH_BL1_TVL' 	; Value=compress(LTH_BL1_TVL); 		OUTPUT; END;
IF LTH_BL2_TVL NE .  	THEN DO; Spec='LTH_BL2_TVL' 	; Value=compress(LTH_BL2_TVL); 		OUTPUT; END;
IF LINESPEED_PLAN NE .  THEN DO; Spec='LINESPEED_PLAN' 	; Value=compress(LINESPEED_PLAN); 	OUTPUT; END;
RUN; 


/* Update Table Macro */
%MACRO UpdateTable();

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.SCADA_SETTINGS_SPL) by baan;
EXECUTE (DELETE from DB2SCADA.SCADA_SETTINGS_SPL_VERTICAL) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.SCADA_SETTINGS_SPL DATA=work.SCADA_SETTINGS_SPL1 FORCE; RUN;
PROC APPEND BASE=DB2SCADA.SCADA_SETTINGS_SPL_VERTICAL DATA=work.SCADA_SETTINGS_SPL_VERTICAL FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_SPL TO USER INFODBC )  by baan;
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_SPL_VERTICAL TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='SCADA_SETTINGS_SPL1'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;


/**********************************************************************/
/****    SCADA_SETTINGS_WPL                          ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Gen_Prod as select * from connection to baan
   (SELECT  a.t_epro  	Dimset,
			a.t_gpro	Gen_Prod,
			b.t_prod	Int_Prod,
			c.t_stro	TRO_Stand,
			d.t_layr	Layer,
			e.t_spec	Spec,
			e.t_cwoc	Prod_Line
   FROM      ttdqua050130 a,
   			 ttdqua041130 b,
			 ttdqua030130 c,
			 ttdqua031130 d,
			 ttdqua020130 e
   WHERE a.t_gpro=b.t_gpro AND b.t_prod=c.t_prod AND b.t_prod=d.t_prod AND d.t_layr=e.t_layr AND e.t_cwoc IN ('WPL')
   ORDER BY  a.t_epro   );
 DISCONNECT from baan;
QUIT;

/*** Collect TRO-orders RUN 1 Primer FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_1_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011010'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Primer=c.Dimset 		AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 1') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND  e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 1 Topcoat FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_1_2 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011020'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Topcoat1=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 1') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 1 Primer RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_1_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012010'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Backcoat=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 1') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 1 Topcoat RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_1_2 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012020'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Backcoat1=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 1') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 2 Topcoat 1 FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_2_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011020'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Topcoat1=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 2') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;

/*** Collect TRO-orders RUN 2 Topcoat 2 FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_2_2 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011030'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Topcoat2=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 2') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 2 Backcoat 2 RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_2_2b AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012020'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Backcoat1=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 2') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;


/*** Collect TRO-orders RUN 3 Topcoat 2 FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_3_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011030'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Topcoat2=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 3') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;

/*** Collect TRO-orders RUN 3 Backcoat 1 RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_3_1b AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012030'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Backcoat1=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 3') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;

/*** Collect TRO-orders RUN 4 Topcoat 2 FS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_F_4_1 AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'011040'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Topcoat2=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 4') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;

/*** Collect TRO-orders RUN 4 Backcoat 1 RS ***/
PROC SQL;
CREATE TABLE work.TRO_Order_R_4_1b AS
SELECT 	a.Company,
		a.TRO_ord_nr,
		a.Dimset,
		c.Dimset			AS Paint_code 	Label='Paint_code',
		c.Dim_Suppl_nr		AS Suppl_nr     Label='Suppl_nr',
		f.Prod_Line,
		a.TRO_Type,
		d.TRO_Type_stand	AS TRO_Stand	Label='TRO_Stand',
		b.Thickness,
		c.Paint_Syst,
		'012040'			AS Spec
FROM work.TRO_Act a,
	 work.Dimsets b,
	 work.Dimsets c,
	 work.qua002  d, 
	 work.sfc001  e,
	 work.rou102  f
WHERE a.Company=b.Company 	AND a.Dimset=b.Dimset 		AND 
	  b.Company=c.Company 	AND b.Backcoat1=c.Dimset 	AND
	  a.Company='ECP' 		AND f.Prod_line IN ('WPL') 	AND d.TRO_Type_stand IN ('WPL 4') 	AND
	  a.Company=d.Company 	AND a.Database=d.Database 	AND a.TRO_Type=d.TRO_Type 			AND
	  a.company=e.company 	AND a.database=e.database 	AND a.tro_ord_nr=e.tro_ord_nr 		AND e.company='ECP' AND e.company=f.company AND e.database=f.database AND e.item_nr=f.item_nr AND e.Routing=f.Routing
ORDER BY a.Company, a.TRO_Ord_nr;
QUIT;






PROC SORT DATA=TRO_Order_F_1_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_F_1_2 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_1_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_1_2 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_F_2_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_F_2_2 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_2_2b nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_F_3_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_3_1b nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_F_4_1 	nodups; BY Company TRO_Ord_nr; RUN;
PROC SORT DATA=TRO_Order_R_4_1b nodups; BY Company TRO_Ord_nr; RUN;


DATA work.TRO_Order; SET TRO_Order_F_1_1; RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_F_1_2; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_1_1; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_1_2; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_F_2_1; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_F_2_2; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_2_2b; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_F_3_1; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_3_1b; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_F_4_1; 	RUN;
PROC APPEND BASE=work.TRO_Order DATA=TRO_Order_R_4_1b; 	RUN;


PROC SQL;
CREATE TABLE work.TRO_order AS
SELECT a.*, b.TRO_ord_pos
FROM work.TRO_Order a LEFT OUTER JOIN work.mdm310 b ON a.Company=b.Company AND a.TRO_ord_nr=b.TRO_ord_nr;
QUIT;

DATA work.TRO_Order; SET work.TRO_order; IF INDEX(TRO_Type,'OMW')>0 AND TRO_ord_pos>10 THEN TRO_Stand='WPL 2'; RUN;

PROC SQL;
CREATE TABLE work.TRO_Order1 AS
SELECT a.*, b.layer
FROM work.TRO_Order a LEFT OUTER JOIN work.gen_prod b ON a.Dimset=b.Dimset AND a.Spec=b.Spec AND a.Prod_line=b.Prod_line AND a.TRO_Stand=b.TRO_Stand ;
QUIT;
PROC SQL;
CREATE TABLE work.TRO_Order2 AS
SELECT a.*, b.PMT		AS PMT_Dims Label 'PMT_Dims',
		    b.PMT_Min	AS PMT_Min	Label 'PMT_Min',
		    b.PMT_Max	AS PMT_Max	Label 'PMT_Max'
FROM work.TRO_Order1 a LEFT OUTER JOIN CDD.qua037 b ON 
					a.company=b.company AND a.Prod_line=b.Prod_line AND a.Layer=b.Layer AND a.Paint_Code=b.Paint_code AND a.Suppl_nr=b.Suppl_nr;
QUIT;
PROC SQL;
CREATE TABLE work.TRO_Order3 AS
SELECT a.*, b.PMT	AS PMT_Syst Label 'PMT_Syst'
FROM work.TRO_Order2 a LEFT OUTER JOIN CDD.qua037 b ON 
					a.company=b.company AND a.Prod_line=b.Prod_line AND a.Layer=b.Layer AND a.Paint_Syst=b.Paint_Syst AND a.Suppl_nr=b.Suppl_nr AND b.Paint_code="";
QUIT;
PROC SQL;
CREATE TABLE work.TRO_Order4 AS
SELECT a.*, b.PMT	AS PMT_Syst_gen Label 'PMT_Syst_gen'
FROM work.TRO_Order3 a LEFT OUTER JOIN CDD.qua037 b ON 
					a.company=b.company AND a.Prod_line=b.Prod_line AND a.Layer=b.Layer AND a.Paint_Syst=b.Paint_Syst AND b.Suppl_nr="" AND b.Paint_code="";
QUIT;


DATA work.TRO_Order (DROP=PMT_Syst PMT_Dims PMT_Syst_gen);
SET work.TRO_order4;
PMT=PMT_Dims;
IF PMT_Dims EQ "" AND PMT_Syst NE "" 		THEN PMT=PMT_Syst;
IF PMT_Dims EQ "" AND PMT_Syst_gen NE "" 	THEN PMT=PMT_Syst_gen;
IF PMT="" 									THEN PMT='000';
IF Spec='011030' 							THEN Spec='011010';
IF Spec='011040' 							THEN Spec='011020';
IF Spec='012030' 							THEN Spec='012010';
IF Spec='012040' 							THEN Spec='012020';
WHERE Paint_code NE "-" ;
RUN;

PROC SORT DATA=work.TRO_Order ; BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand; RUN;

PROC TRANSPOSE DATA= work.TRO_Order OUT=work.TRO_Order_Trans  (drop=_NAME_ _LABEL_);
BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand;   VAR PMT;     ID Spec;
RUN;
DATA work.TRO_Order_Trans; SET work.TRO_Order_Trans;
RENAME _011010 = PMT_TL1_TVL;
RENAME _011020 = PMT_TL2_TVL;
RENAME _012010 = PMT_BL1_TVL;
RENAME _012020 = PMT_BL2_TVL;
RUN;
PROC TRANSPOSE DATA= work.TRO_Order OUT=work.TRO_Order_Trans_Min  (drop=_NAME_ _LABEL_);
BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand;   VAR PMT_Min;     ID Spec;
RUN;
DATA work.TRO_Order_Trans_Min; SET work.TRO_Order_Trans_Min;
RENAME _011010 = PMT_TL1_MIN;
RENAME _011020 = PMT_TL2_MIN;
RENAME _012010 = PMT_BL1_MIN;
RENAME _012020 = PMT_BL2_MIN;
RUN;
PROC TRANSPOSE DATA= work.TRO_Order OUT=work.TRO_Order_Trans_Max  (drop=_NAME_ _LABEL_);
BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand;   VAR PMT_Max;     ID Spec;
RUN;
DATA work.TRO_Order_Trans_Max; SET work.TRO_Order_Trans_Max;
RENAME _011010 = PMT_TL1_MAX;
RENAME _011020 = PMT_TL2_MAX;
RENAME _012010 = PMT_BL1_MAX;
RENAME _012020 = PMT_BL2_MAX;
RUN;

DATA work.TRO_Order_Trans;
MERGE work.TRO_Order_Trans work.TRO_Order_Trans_Min work.TRO_Order_Trans_Max;
BY Company Prod_line TRO_Ord_nr Dimset TRO_Stand;
RUN;


PROC SQL; CREATE TABLE work.TRO_Order_Trans AS
SELECT 	a.*,
		b.Item_nr,
		b.S_001030  AS AlloyT       Label='AlloyT',
		b.S_010010	AS ChemCoatVZ 	Label='ChemCoatVZ',
		b.S_010020	AS ChemCoatKZ 	Label='ChemCoatKZ',
		b.S_020010	AS ChemCoatWPL 	Label='ChemCoatWPL',
		b.S_010050	AS InkjetText 	Label='InkjetText',
		b.S_060010	AS Fol 			Label='Fol',
		b.S_011010	AS PMT_TL1	 	Label='PMT_TL1',
		b.S_011014	AS LTH_TL1_TVL	Label='LTH_TL1_TVL',
		b.S_011020	AS PMT_TL2	 	Label='PMT_TL2',
		b.S_011024	AS LTH_TL2_TVL	Label='LTH_TL2_TVL',
		b.S_011030	AS PMT_TL3 		Label='PMT_TL3',
		b.S_011034	AS LTH_TL3_TVL	Label='LTH_TL3_TVL',
		b.S_011040	AS PMT_TL4 		Label='PMT_TL4',
		b.S_011044	AS LTH_TL4_TVL	Label='LTH_TL4_TVL',
		b.S_012010	AS PMT_BL1	 	Label='PMT_BL1',
		b.S_012014	AS LTH_BL1_TVL	Label='LTH_BL1_TVL',
		b.S_012020	AS PMT_BL2 		Label='PMT_BL2',
		b.S_012024	AS LTH_BL2_TVL	Label='LTH_BL2_TVL',
		b.S_012030	AS PMT_BL3	 	Label='PMT_BL3',
		b.S_012034	AS LTH_BL3_TVL	Label='LTH_BL3_TVL',
		b.S_012040	AS PMT_BL4	 	Label='PMT_BL4',
		b.S_012044	AS LTH_BL4_TVL	Label='LTH_BL4_TVL',
		b.S_020012	AS WPL_Design	Label='WPL_Design',
		b.S_050100	AS Aluf_Text  	Label='Aluf_Text'
FROM work.TRO_Order_Trans a LEFT OUTER JOIN work.Default_Specs b ON a.Company=b.Company AND a.Dimset=b.Dimset;
QUIT;


DATA work.TRO_Order_Trans1 (DROP=PMT_TL3 PMT_TL4 PMT_BL3 PMT_BL4 LTH_TL3_TVL LTH_TL4_TVL LTH_BL3_TVL InkjetText Aluf_Text AlloyT);
SET work.TRO_Order_Trans;

IF INDEX(TRO_Stand,'2') AND SUBSTR(PMT_BL2,3,1)='A' THEN DO; 	PMT_BL3=PMT_BL2; PMT_BL2=""; LTH_BL3_TVL=LTH_BL2_TVL; LTH_BL2_TVL="";  									END;
IF INDEX(TRO_Stand,'2')  							THEN DO; 	PMT_TL1=PMT_TL3; PMT_TL2=PMT_TL4; PMT_BL1=PMT_BL3; PMT_BL2=PMT_BL4; 
								 								LTH_TL1_TVL=LTH_TL3_TVL;  LTH_TL2_TVL=LTH_TL4_TVL; LTH_BL1_TVL=LTH_BL3_TVL;  LTH_BL2_TVL=LTH_BL4_TVL; 	END;
Inkjet="0";
IF InkjetText='GEEN' 								THEN Inkjet="0";
IF InkjetText='ECP CODE' 							THEN Inkjet="1";
IF InkjetText='SPECIFIEK' 							THEN Inkjet="2";
IF Aluf_Text NE "" 									THEN Alufiber="1"; ELSE Alufiber="0";
IF INDEX(TRO_Stand,'1')>0   						THEN Degrease='1'; ELSE Degrease='0';
TRO_Run_nr=INPUT(Substr(TRO_Stand,5,1),1.0); 
IF TRO_Run_nr=1 									THEN TRO_Run_nr=0; ELSE TRO_Run_nr=1;
IF INDEX(AlloyT,'HSA')>0 							THEN AlloyT='5083';
Alloy=INPUT(Substr(AlloyT,1,4),4.0);
RUN;


DATA work.SCADA_SETTINGS_WPL(KEEP=Company TRO_Ord_nr TRO_Run_nr Alloy Alufiber Chemcoating Decor Inkjet Degrease Substrate
PMT_BL1 PMT_BL1_MAX PMT_BL1_MIN PMT_BL1_TVL
PMT_BL2 PMT_BL2_MAX PMT_BL2_MIN PMT_BL2_TVL
PMT_TL1 PMT_TL1_MAX PMT_TL1_MIN PMT_TL1_TVL
PMT_TL2 PMT_TL2_MAX PMT_TL2_MIN PMT_TL2_TVL); SET work.TRO_Order_Trans1;
IF Fol ne "-" 					THEN  Fol='Y'; 			ELSE Fol='N';
IF Item_Nr='ALU' 				THEN  Substrate='1'; 	ELSE Substrate='0';
Chemcoating=ChemCoatWPL;
IF Chemcoating='' 				THEN Chemcoating='0';
IF Chemcoating='CHROOMVRIJ' 	THEN Chemcoating='1';
IF Chemcoating='ANORCOAT' 		THEN Chemcoating='1';
IF Chemcoating='ZIRKOON' 		THEN Chemcoating='1';
IF Chemcoating='CHROM GROEN' 	THEN Chemcoating='1';
IF Chemcoating='CHROM GEEL' 	THEN Chemcoating='1';
IF WPL_Design='' 				THEN Decor='0'; 		ELSE Decor='1';
WHERE prod_line='WPL';
RUN;

/* Translate to Numeric*/
DATA work.SCADA_SETTINGS_WPL1(KEEP=Company TRO_Ord_nr TRO_Run_nr1 Alloy Alufiber1 Chemcoating1 Decor1 Inkjet1 Degrease1 Substrate1 PMT_BL1 PMT_BL2 PMT_TL1 PMT_TL2
PMT_BL1_MAX1 PMT_BL1_MIN1 PMT_BL1_TVL1
PMT_BL2_MAX1 PMT_BL2_MIN1 PMT_BL2_TVL1
PMT_TL1_MAX1 PMT_TL1_MIN1 PMT_TL1_TVL1
PMT_TL2_MAX1 PMT_TL2_MIN1 PMT_TL2_TVL1)
; SET work.SCADA_SETTINGS_WPL;
FORMAT Alufiber1 10.;		Alufiber1=Alufiber;
FORMAT Chemcoating1 10.;	Chemcoating1=Chemcoating;
FORMAT Decor1 10.;			Decor1=Decor;
FORMAT Inkjet1 10.;			Inkjet1=Inkjet;
FORMAT Degrease1 10.;		Degrease1=Degrease;
FORMAT Substrate1 10.;		Substrate1=Substrate;
FORMAT PMT_BL1_MAX1 10.;	PMT_BL1_MAX1=PMT_BL1_MAX;
FORMAT PMT_BL1_MIN1 10.;	PMT_BL1_MIN1=PMT_BL1_MIN;
FORMAT PMT_BL1_TVL1 10.;	PMT_BL1_TVL1=PMT_BL1_TVL;
FORMAT PMT_BL2_MAX1 10.;	PMT_BL2_MAX1=PMT_BL2_MAX;
FORMAT PMT_BL2_MIN1 10.;	PMT_BL2_MIN1=PMT_BL2_MIN;
FORMAT PMT_BL2_TVL1 10.;	PMT_BL2_TVL1=PMT_BL2_TVL;
FORMAT PMT_TL1_MAX1 10.;	PMT_TL1_MAX1=PMT_TL1_MAX;
FORMAT PMT_TL1_MIN1 10.;	PMT_TL1_MIN1=PMT_TL1_MIN;
FORMAT PMT_TL1_TVL1 10.;	PMT_TL1_TVL1=PMT_TL1_TVL;
FORMAT PMT_TL2_MAX1 10.;	PMT_TL2_MAX1=PMT_TL2_MAX;
FORMAT PMT_TL2_MIN1 10.;	PMT_TL2_MIN1=PMT_TL2_MIN;
FORMAT PMT_TL2_TVL1 10.;	PMT_TL2_TVL1=PMT_TL2_TVL;
FORMAT TRO_Run_nr1 10.;		TRO_Run_nr1=TRO_Run_nr;
RUN;

DATA work.SCADA_SETTINGS_WPL1; SET work.SCADA_SETTINGS_WPL1;
RENAME Alufiber1 = Alufiber;
RENAME Decor1 = Decor;
RENAME Chemcoating1 = Chemcoating;
RENAME Inkjet1 = Inkjet;
RENAME Degrease1 = Degrease;
RENAME Substrate1 = Substrate;
RENAME PMT_BL1_MAX1 = PMT_BL1_MAX;
RENAME PMT_BL1_MIN1 = PMT_BL1_MIN;
RENAME PMT_BL1_TVL1 = PMT_BL1_TVL;
RENAME PMT_BL2_MAX1 = PMT_BL2_MAX;
RENAME PMT_BL2_MIN1 = PMT_BL2_MIN;
RENAME PMT_BL2_TVL1 = PMT_BL2_TVL;
RENAME PMT_TL1_MAX1 = PMT_TL1_MAX;
RENAME PMT_TL1_MIN1 = PMT_TL1_MIN;
RENAME PMT_TL1_TVL1 = PMT_TL1_TVL;
RENAME PMT_TL2_MAX1 = PMT_TL2_MAX;
RENAME PMT_TL2_MIN1 = PMT_TL2_MIN;
RENAME PMT_TL2_TVL1 = PMT_TL2_TVL;
RENAME TRO_Run_nr1 = TRO_Run_nr;
RUN;


DATA work.SCADA_SETTINGS_WPL1; SET work.SCADA_SETTINGS_WPL1;
IF PMT_TL1="" 		THEN PMT_TL1="-";
IF PMT_TL2="" 		THEN PMT_TL2="-";
IF PMT_BL1="" 		THEN PMT_BL1="-";
IF PMT_BL2="" 		THEN PMT_BL2="-";
IF ALUFIBER=. 		THEN ALUFIBER=0;
IF Chemcoating=. 	THEN Chemcoating=0;
IF Decor=. 			THEN Decor=0;
IF Inkjet=. 		THEN Inkjet=0;
IF Degrease=. 		THEN Degrease=0;
IF Substrate=. 		THEN Substrate=0;
IF PMT_BL1_MAX=. 	THEN PMT_BL1_MAX=0;
IF PMT_BL1_MIN=. 	THEN PMT_BL1_MIN=0;
IF PMT_BL1_TVL=. 	THEN PMT_BL1_TVL=0;
IF PMT_BL2_MAX=. 	THEN PMT_BL2_MAX=0;
IF PMT_BL2_MIN=. 	THEN PMT_BL2_MIN=0;
IF PMT_BL2_TVL=. 	THEN PMT_BL2_TVL=0;
IF PMT_TL1_MAX=. 	THEN PMT_TL1_MAX=0;
IF PMT_TL1_MIN=. 	THEN PMT_TL1_MIN=0;
IF PMT_TL1_TVL=. 	THEN PMT_TL1_TVL=0;
IF PMT_TL2_MAX=. 	THEN PMT_TL2_MAX=0;
IF PMT_TL2_MIN=. 	THEN PMT_TL2_MIN=0;
IF PMT_TL2_TVL=. 	THEN PMT_TL2_TVL=0;
IF TRO_Run_nr=. 	THEN TRO_Run_nr=0;
RUN;


PROC SQL;
CREATE TABLE work.SCADA_SETTINGS_WPL1 AS
SELECT a.*, b.Linespeed_plan
FROM work.SCADA_SETTINGS_WPL1 a LEFT OUTER JOIN work.Linespeed b ON a.Company=b.Company AND a.TRO_Ord_nr=b.TRO_Ord_nr;
QUIT;
DATA work.SCADA_SETTINGS_WPL1; SET work.SCADA_SETTINGS_WPL1; IF Linespeed_plan=. THEN Linespeed_plan=1; RUN;


DATA work.SCADA_SETTINGS_WPL_VERTICAL(KEEP= Company Tro_Ord_NR Spec Value); SET work.SCADA_SETTINGS_WPL1;
FORMAT Spec $50.;
FORMAT Value $50.;
IF PMT_TL1 NE ""  		THEN DO; Spec='PMT_TL1'			; Value=compress(PMT_TL1); 			OUTPUT; END;
IF PMT_TL2 NE ""  		THEN DO; Spec='PMT_TL2' 		; Value=compress(PMT_TL2); 			OUTPUT; END;
IF PMT_BL1 NE ""  		THEN DO; Spec='PMT_BL1' 		; Value=compress(PMT_BL1); 			OUTPUT; END;
IF PMT_BL2 NE .  		THEN DO; Spec='PMT_BL2' 		; Value=compress(PMT_BL2); 			OUTPUT; END;
IF TRO_RUN_NR NE .  	THEN DO; Spec='TRO_RUN_NR' 		; Value=compress(TRO_RUN_NR); 		OUTPUT; END;
IF ALLOY NE .  			THEN DO; Spec='ALLOY' 			; Value=compress(ALLOY); 			OUTPUT; END;
IF ALUFIBER NE .  		THEN DO; Spec='ALUFIBER' 		; Value=compress(ALUFIBER); 		OUTPUT; END;
IF CHEMCOATING NE .  	THEN DO; Spec='CHEMCOATING' 	; Value=compress(CHEMCOATING); 		OUTPUT; END;
IF DECOR NE .  			THEN DO; Spec='DECOR' 			; Value=compress(DECOR); 			OUTPUT; END;
IF INKJET NE .  		THEN DO; Spec='INKJET' 			; Value=compress(INKJET); 			OUTPUT; END;
IF DEGREASE NE .  		THEN DO; Spec='DEGREASE' 		; Value=compress(DEGREASE); 		OUTPUT; END;
IF SUBSTRATE NE .  		THEN DO; Spec='SUBSTRATE' 		; Value=compress(SUBSTRATE); 		OUTPUT; END;
IF PMT_BL1_MAX NE .  	THEN DO; Spec='PMT_BL1_MAX' 	; Value=compress(PMT_BL1_MAX); 		OUTPUT; END;
IF PMT_BL1_MIN NE .  	THEN DO; Spec='PMT_BL1_MIN' 	; Value=compress(PMT_BL1_MIN); 		OUTPUT; END;
IF PMT_BL1_TVL NE .  	THEN DO; Spec='PMT_BL1_TVL' 	; Value=compress(PMT_BL1_TVL); 		OUTPUT; END;
IF PMT_BL2_MAX NE .  	THEN DO; Spec='PMT_BL2_MAX' 	; Value=compress(PMT_BL2_MAX); 		OUTPUT; END;
IF PMT_BL2_MIN NE .  	THEN DO; Spec='PMT_BL2_MIN' 	; Value=compress(PMT_BL2_MIN); 		OUTPUT; END;
IF PMT_BL2_TVL NE .  	THEN DO; Spec='PMT_BL2_TVL' 	; Value=compress(PMT_BL2_TVL); 		OUTPUT; END;
IF PMT_TL1_MAX NE .  	THEN DO; Spec='PMT_TL1_MAX' 	; Value=compress(PMT_TL1_MAX); 		OUTPUT; END;
IF PMT_TL1_MIN NE .  	THEN DO; Spec='PMT_TL1_MIN' 	; Value=compress(PMT_TL1_MIN); 		OUTPUT; END;
IF PMT_TL1_TVL NE .  	THEN DO; Spec='PMT_TL1_TVL' 	; Value=compress(PMT_TL1_TVL); 		OUTPUT; END;
IF PMT_TL2_MAX NE .  	THEN DO; Spec='PMT_TL2_MAX' 	; Value=compress(PMT_TL2_MAX); 		OUTPUT; END;
IF PMT_TL2_MIN NE .  	THEN DO; Spec='PMT_TL2_MIN' 	; Value=compress(PMT_TL2_MIN); 		OUTPUT; END;
IF PMT_TL2_TVL NE .  	THEN DO; Spec='PMT_TL2_TVL' 	; Value=compress(PMT_TL2_TVL); 		OUTPUT; END;
IF LINESPEED_PLAN NE .  THEN DO; Spec='LINESPEED_PLAN' 	; Value=compress(LINESPEED_PLAN); 	OUTPUT; END;
RUN; 

/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.SCADA_SETTINGS_WPL) by baan;
EXECUTE (DELETE from DB2SCADA.SCADA_SETTINGS_WPL_VERTICAL) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.SCADA_SETTINGS_WPL DATA=work.SCADA_SETTINGS_WPL1 FORCE; RUN;
PROC APPEND BASE=DB2SCADA.SCADA_SETTINGS_WPL_VERTICAL DATA=work.SCADA_SETTINGS_WPL_VERTICAL FORCE; RUN;


PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_WPL TO USER INFODBC )  by baan;
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.SCADA_SETTINGS_WPL_VERTICAL TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='SCADA_SETTINGS_WPL1'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;







/**********************************************************************/
/****    					Scada_Rolls (WalsDiameter)                        ****/
/**********************************************************************/
DATA work.Scada_Rolls; SET whs.grindings;
WHERE AX_GRIND_STATUS IN ('In Production') AND Company IN ('EAP','ECP');
RUN;

/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.Scada_Rolls) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.Scada_Rolls DATA=work.Scada_Rolls FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.Scada_Rolls TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 1 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Scada_Rolls'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;





/**********************************************************************/
/****    					Scada_Orders                        ****/
/**********************************************************************/
PROC SQL;
CREATE TABLE Work.Scada_Orders AS
SELECT 	a.Company,
		a.TRO_Campain_nr,
		a.TRO_CAMPAIN_SEQ_NR,
		a.Campain_Date,
		a.TRO_ord_nr,
		a.TRO_Type,
		a.Cust_nr,
		b.Cust_name,
		a.Sal_ord_nr,
		a.Sal_ord_pos,
		a.Dimset				AS Dimset_out,
		c.Dim_descr,
		c.Dim_inp_dims_nr		AS Dimset_in
FROM  db2data.rol_reforcast_new_cap a, db2data.customers b, db2data.Dimsets c 
WHERE a.Company=b.Company 			AND a.Cust_nr=b.Cust_nr AND a.Company=c.Company 					AND a.Dimset=c.Dimset AND
	  a.Company IN ('ECP','EAP') 	AND TRO_Ord_nr>0 		AND TRO_Ord_pos>0 /*AND TRO_Ord_Stat<6*/ 	AND YEAR(a.date)>=2024;
QUIT;

PROC SORT DATA=work.Scada_Orders nodupkey; BY company tro_campain_nr tro_campain_seq_nr campain_date tro_ord_nr tro_type cust_nr sal_ord_nr sal_ord_pos; RUN;

PROC SQL;
CREATE TABLE work.Scada_Orders1 AS
SELECT  a.*,
		b.alloy,
		b.thickness,
		b.substrate AS substrate1,
		b.hardness
FROM work.Scada_Orders a LEFT OUTER JOIN work.Dimsets b ON a.Dimset_out=b.dimset and a.company=b.company;
QUIT;

PROC SQL;
CREATE TABLE work.TRO_Ord_Inp AS
SELECT 	a.Company,
		a.Database,
		a.TRO_ord_nr,
		AVG(INPUT(d.Value,12.1))	AS TRO_Inp_Width   FORMAT 6.1
FROM work.mdm315 	a,
	 work.mdm310 	c,
	 work.lra230 	d
WHERE 	a.Company=c.Company AND a.TRO_Ord_nr=c.TRO_ord_nr 	AND a.TRO_Inp_Idno>0 AND
		a.Company=d.Company AND a.TRO_Inp_Idno=d.Idno 		AND d.Spec='001000'
GROUP BY a.Company,a.Database,a.TRO_ord_nr
ORDER BY a.Company,a.Database,a.TRO_ord_nr ;

CREATE TABLE work.TRO_Ord_Inp_thickness AS
SELECT 	a.Company,
		a.Database,
		a.TRO_ord_nr,
		AVG(INPUT(d.Value,12.2))	AS Thickn_In   FORMAT 6.2
FROM work.mdm315 	a,
	 work.mdm310 	c,
	 work.lra230 	d
WHERE 	a.Company=c.Company AND a.TRO_Ord_nr=c.TRO_ord_nr 	AND a.TRO_Inp_Idno>0 AND
		a.Company=d.Company AND a.TRO_Inp_Idno=d.Idno 		AND d.Spec='001010'
GROUP BY a.Company,a.Database,a.TRO_ord_nr
ORDER BY a.Company,a.Database,a.TRO_ord_nr ;


CREATE TABLE work.TRO_Ord_Outp AS
SELECT 	a.Company,
		a.Database,
		a.TRO_ord_nr,
		AVG(INPUT(d.Value,12.1))	AS TRO_Outp_Width  FORMAT 6.1
FROM work.mdm315 	a,
	 work.mdm310 	c,
	 work.lra230 	d
WHERE 	a.Company=c.Company AND a.TRO_Ord_nr=c.TRO_ord_nr 	AND a.TRO_Outp_Idno>0 AND
		a.Company=d.Company AND a.TRO_Outp_Idno=d.Idno 		AND d.Spec='001000'
GROUP BY a.Company,a.Database,a.TRO_ord_nr
ORDER BY a.Company,a.Database,a.TRO_ord_nr ;

CREATE TABLE work.TRO_Ord_Outp_thickness AS
SELECT 	a.Company,
		a.Database,
		a.TRO_ord_nr,
		AVG(INPUT(d.Value,12.2))	AS Thickn_Out  FORMAT 6.2
FROM work.mdm315 	a,
	 work.mdm310 	c,
	 work.lra230 	d
WHERE 	a.Company=c.Company AND a.TRO_Ord_nr=c.TRO_ord_nr 	AND a.TRO_Outp_Idno>0 AND
		a.Company=d.Company AND a.TRO_Outp_Idno=d.Idno 		AND d.Spec='001010'
GROUP BY a.Company,a.Database,a.TRO_ord_nr
ORDER BY a.Company,a.Database,a.TRO_ord_nr ;

QUIT;

PROC SQL;
CREATE TABLE work.Scada_Orders2 AS
SELECT  a.*,
		b.TRO_Inp_Width AS In_Width,
		c.Thickn_In 	AS In_Thickn
FROM work.Scada_Orders1 a 	LEFT OUTER JOIN work.TRO_Ord_Inp b ON a.Company=b.Company  AND a.TRO_ord_nr=b.TRO_ord_nr
							LEFT OUTER JOIN work.TRO_Ord_Inp_Thickness c ON a.Company=c.Company  AND a.TRO_ord_nr=c.TRO_ord_nr;
QUIT;

PROC SQL;
CREATE TABLE work.Scada_Orders2 AS
SELECT  a.*,
		b.TRO_Outp_Width 	AS Out_Width,
		c.Thickn_Out 		AS Out_Thickn
FROM work.Scada_Orders2 a 	LEFT OUTER JOIN work.TRO_Ord_Outp b ON a.Company=b.Company AND a.TRO_ord_nr=b.TRO_ord_nr
							LEFT OUTER JOIN work.TRO_Ord_Outp_Thickness c ON a.Company=c.Company AND a.TRO_ord_nr=c.TRO_ord_nr;
QUIT;

PROC SQL;
CREATE TABLE work.Scada_Orders2 AS
SELECT  a.*,
		b.TRO_TOT_kg AS tro_kg
FROM work.Scada_Orders2 a LEFT OUTER JOIN work.mdm310 b ON a.tro_ord_nr=b.tro_ord_nr and a.company=b.company;
QUIT;

PROC SQL;
CREATE TABLE Work.Scada_Orders3 AS
SELECT 	a.*,
		b.Conf_nr
FROM Work.Scada_Orders2 a LEFT OUTER JOIN work.EL_Settings b ON a.Dimset_in=b.Inp_dimset AND a.TRO_type=b.TRO_Type AND a.Dimset_out=b.End_Dimset;
QUIT;

DATA Work.Scada_Orders3(DROP=substrate1); SET Work.Scada_Orders3;
FORMAT Substrate 10.;
IF in_width=. 		THEN in_width=0;
IF out_width=. 		THEN out_width=0;
IF in_thickn=. 		THEN in_thickn=Out_Thickn; 
IF in_thickn=. 		THEN in_thickn=Thickness;
IF out_thickn=. 	THEN out_thickn=Thickness;
IF tro_kg=. 		THEN tro_kg=0;
IF conf_nr=. 		THEN conf_nr=0;
IF hardness="" 		THEN hardness="-";
Substrate=0;
IF substrate1="Alu" THEN SUBSTRATE=1;
RUN;

PROC SORT DATA=work.Scada_Orders3 nodupkey; BY Tro_Campain_Nr Tro_Ord_Nr Sal_ord_nr Sal_Ord_Pos; RUN;

DATA work.Scada_Orders3; SET work.Scada_Orders3;
by Tro_Campain_Nr Tro_Ord_Nr Sal_ord_nr Sal_Ord_Pos;
IF not first.Tro_Ord_Nr THEN DELETE;
RUN;

PROC SORT DATA=Scada_Orders3 nodupkey; 
by COMPANY TRO_CAMPAIN_NR TRO_CAMPAIN_SEQ_NR; RUN;

/* Scada Orders Table Format */
/*
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (Drop table db2scada.scada_orders) by baan;
EXECUTE 
(Create table db2scada.scada_orders 		 ( 	Company		Char(3),
									Tro_Campain_Nr			Integer,
									Tro_Campain_Seq_Nr		Integer,
									Campain_date			Date,
									Tro_Ord_Nr				Integer,
									Tro_Type				Char(25),
									Cust_Nr					Char(15),
									Cust_Name				Char(100),
									Sal_ord_nr				Integer,
									Sal_ord_pos				Integer,
									Dimset_out				Char(25),
									Dim_Descr				Char(100),
									Dimset_In				Char(25),
									Alloy					Char(25),
									Thickness				Dec(10,2),
									Hardness				Char(25),
									In_width				Integer,
									In_Thickn				Dec(10,2),
									Out_Width				Integer,
									Out_Thickn				Dec(10,2),
									tro_kg					Integer,
									Conf_nr					Integer,
									Substrate				Integer	)
 ) by baan;
EXECUTE ( GRANT  SELECT ON TABLE db2scada.scada_orders TO USER INFODBC )  by baan;
EXECUTE ( GRANT  SELECT ON TABLE db2scada.scada_orders TO USER FINODBC )  by baan;
EXECUTE ( COMMENT ON TABLE db2scada.scada_orders IS 'Act. Files' )  by baan;   
QUIT;
*/
/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.Scada_Orders) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.Scada_Orders DATA=work.Scada_Orders3 FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.Scada_Orders TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Scada_Orders3'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;



/*** PROFICY ***/
/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (DROP TABLE  Local_Scada_Orders) by Prof;
QUIT; 

PROC APPEND base=Proficy.Local_Scada_Orders  data=work.Scada_Orders3 FORCE; RUN;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Scada_Orders3'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;



/**********************************************************************/
/****    					Scada_Orders_IDNO                        ****/
/**********************************************************************/

PROC SQL;
CREATE TABLE work.Scada_Orders_IDNO AS
SELECT 	a.*,
		b.TRO_Inp_Idno
FROM work.Scada_Orders3 a LEFT OUTER JOIN work.mdm315 b ON a.Company=b.company AND a.TRO_Ord_nr=b.TRO_Ord_nr AND b.TRO_Inp_Idno>0;
QUIT;

/* Scada Orders Idno Table Format */
/*
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (Drop table db2scada.Scada_Orders_IDNO) by baan;
EXECUTE 
(Create table db2scada.Scada_Orders_IDNO 		 ( 	Company		Char(3),
									Tro_Campain_Nr			Integer,
									Tro_Campain_Seq_Nr		Integer,
									Campain_date			Date,
									Tro_Ord_Nr				Integer,
									Tro_Type				Char(25),
									Cust_Nr					Char(15),
									Cust_Name				Char(100),
									Sal_ord_nr				Integer,
									Sal_ord_pos				Integer,
									Dimset_out				Char(25),
									Dim_Descr				Char(100),
									Dimset_In				Char(25),
									Alloy					Char(25),
									Thickness				Dec(10,2),
									Hardness				Char(25),
									In_width				Integer,
									In_Thickn				Dec(10,2),
									Out_Width				Integer,
									Out_Thickn				Dec(10,2),
									tro_kg					Integer,
									Conf_nr					Integer,
									Substrate				Integer,
									TRO_Inp_Idno			Integer)
 ) by baan;
EXECUTE ( GRANT  SELECT ON TABLE db2scada.Scada_Orders_IDNO TO USER INFODBC )  by baan;
EXECUTE ( GRANT  SELECT ON TABLE db2scada.Scada_Orders_IDNO TO USER FINODBC )  by baan;
EXECUTE ( COMMENT ON TABLE db2scada.Scada_Orders_IDNO IS 'Act. Files' )  by baan;   
QUIT;
*/


/* Update Table Macro */
%MACRO UpdateTable();

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.Scada_Orders_IDNO) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.Scada_Orders_IDNO DATA=work.Scada_Orders_Idno FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.Scada_Orders_IDNO TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Scada_Orders_Idno'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;

/*** PROFICY ***/
/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (DROP TABLE  Local_Scada_Orders_Idno) by Prof;
QUIT; 

PROC APPEND base=Proficy.Local_Scada_Orders_Idno  data=work.Scada_Orders_Idno FORCE; RUN;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Scada_Orders_Idno'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;







/**********************************************************************/
/****    					Scada_Orders_SHT                       ****/
/**********************************************************************/
PROC sql;/* RM changed data collection from WHS to BAAN */
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Scada_Orders_SHT as select * from connection to baan
   (SELECT  "ECP" 					AS Company,
			a.t_cano  				AS SHT_Campain_nr,
			a.t_seno				AS SHT_Campain_Seq_nr,
			a.t_psdt 				AS Campain_Date,
			a.t_shto				AS SHT_ord_nr,
			a.t_ttro				AS SHT_Type,
			a.t_cuno				AS Cust_nr,
			c.t_dset_c				AS Dimset_out,
			b.t_orno				AS Sal_ord_nr,
			b.t_pono				AS Sal_ord_pos,
			ROUND(AVG(b.t_oqua_2))	AS Ord_Quan,
			AVG(b.t_lgth) 			AS Plate_Length /*RM added plate_length 18-6-2019*/ 
   FROM      	ttdsht300130 a,
   				ttdsht315130 b,
				ttdsls041130 c
   	WHERE 	a.t_shto=b.t_shto AND a.t_shto>0 AND a.t_osta<6 AND b.t_ttyp = 6 AND b.t_trst < 5 AND
			b.t_orno=c.t_orno AND b.t_pono=c.t_pono
	GROUP BY a.t_cano, a.t_seno, a.t_psdt, a.t_shto, a.t_ttro, a.t_cuno, c.t_dset_c, b.t_orno, b.t_pono, b.t_oqua_1, b.t_oqua_2);
 DISCONNECT from baan;
QUIT;

PROC SQL;
CREATE TABLE Work.Scada_Orders_SHT AS
SELECT 	a.*,
		b.Cust_name 						FORMAT $20. LENGTH=20,
		c.Dim_descr 						FORMAT $25. LENGTH=25,
		c.Dim_inp_dims_nr	AS Dimset_in
FROM  work.Scada_Orders_SHT a, work.customers b, work.Dimsets c 
WHERE a.Company=b.Company AND a.Cust_nr=b.Cust_nr AND a.Company=c.Company AND a.Dimset_out=c.Dimset;
QUIT;

PROC SQL;
CREATE TABLE work.Scada_Orders_SHT1 AS
SELECT  a.*,
		b.alloy,
		b.thickness,
		b.substrate 		AS substrate1,
		b.hardness
FROM work.Scada_Orders_SHT a LEFT OUTER JOIN work.Dimsets b ON a.Dimset_out=b.dimset and a.company=b.company;
QUIT;

PROC SQL;
CREATE TABLE work.Scada_Orders_SHT2 AS
SELECT  a.*,
		b.In_Width,
		b.Out_Width,
		b.In_Thickn,
		b.sht_kg
FROM work.Scada_Orders_SHT1 a LEFT OUTER JOIN db2data.sht_ord b ON a.sht_ord_nr=b.sht_ord_nr 	AND a.company=b.company 	  AND a.sht_campain_nr=b.campain_nr AND a.campain_date=b.campain_date
																								AND a.sal_ord_nr=b.sal_ord_nr AND a.sal_ord_pos=b.sal_ord_pos 	AND a.cust_nr=b.cust_nr;
QUIT;

PROC SQL;
CREATE TABLE Work.Scada_Orders_SHT3 AS
SELECT 	a.*,
		b.Conf_nr
FROM Work.Scada_Orders_SHT2 a LEFT OUTER JOIN work.ATK_Settings b ON a.Dimset_in=b.Inp_dimset AND a.SHT_TYPE=b.SHT_TYPE AND a.Dimset_out=b.End_Dimset;
QUIT;

DATA Work.Scada_Orders_SHT3(DROP=substrate1); SET Work.Scada_Orders_SHT3;
FORMAT Substrate 10.;
IF in_width=. 		THEN in_width=0;
IF out_width=. 		THEN out_width=0;
IF in_thickn=. 		THEN in_thickn=0;
IF tro_kg=. 		THEN tro_kg=0;
IF conf_nr=. 		THEN conf_nr=0;
IF hardness="" 		THEN hardness="-";
Substrate=0;
IF substrate1="Alu" THEN SUBSTRATE=1;
RUN;

PROC SORT DATA=work.Scada_Orders_SHT3 nodupkey; BY SHT_Campain_Nr SHT_Ord_Nr Sal_ord_nr Sal_Ord_Pos; RUN;

DATA work.Scada_Orders_SHT3; SET work.Scada_Orders_SHT3;
BY SHT_Campain_Nr SHT_Ord_Nr Sal_ord_nr Sal_Ord_Pos;
IF SHT_kg=. 			THEN SHT_kg=0;

IF not first.SHT_Ord_Nr THEN DELETE;
Cust_name=translate(Cust_name,"u","�");    /* Quick Fix Upload problem Burstner CustName  PW  13-03-2024 */
RUN;


/* Update Table Macro */
%MACRO UpdateTable();

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.Scada_Orders_SHT) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.Scada_Orders_SHT DATA=work.Scada_Orders_SHT3 FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.Scada_Orders_SHT TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Scada_Orders_SHT3'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;



/**********************************************************************/
/****    			Camp_Nr & Paints & PMT Values   (SPL)       	****/
/**********************************************************************/
/* TL1 */
PROC SQL;
CREATE TABLE work.Camp_Paints_TL1 AS
SELECT  a.TRO_CAMPAIN_NR ,
		"SPL" 			AS Prod_line,
		b.PMT_TL1 		AS Paint_Code 	Label='Paint_Code',
		a.tro_ord_nr,
		b.PMT_TL1_TVL 	AS PMT 			Label='PMT',
		b.PMT_TL1_MAX 	AS PMT_MAX 		Label='PMT_MAX',
		b.PMT_TL1_MIN 	AS PMT_MIN 		Label='PMT_MIN'
FROM db2scada.Scada_Orders a LEFT OUTER JOIN db2scada.scada_settings_spl b ON a.tro_ord_nr=b.tro_ord_nr
ORDER BY a.TRO_CAMPAIN_NR, b.PMT_TL1;
QUIT;


DATA work.Camp_Paints_TL1; SET work.Camp_Paints_TL1;
IF TRO_CAMPAIN_NR=0 		THEN DELETE;
IF PAINT_CODE IN ('-',"") 	THEN DELETE;
RUN;

PROC SORT DATA=work.Camp_Paints_TL1 nodupkey; BY TRO_CAMPAIN_NR Prod_line Paint_Code tro_ord_nr PMT PMT_MAX PMT_MIN; RUN;

/* TL2 */
PROC SQL;
CREATE TABLE work.Camp_Paints_TL2 AS
SELECT  a.TRO_CAMPAIN_NR ,
		"SPL" 			AS Prod_line,
		b.PMT_TL2 		AS Paint_Code 	Label='Paint_Code',
		a.tro_ord_nr,
		b.PMT_TL2_TVL 	AS PMT 			Label='PMT',
		b.PMT_TL2_MAX 	AS PMT_MAX 		Label='PMT_MAX',
		b.PMT_TL2_MIN 	AS PMT_MIN 		Label='PMT_MIN'
FROM db2scada.Scada_Orders a LEFT OUTER JOIN db2scada.scada_settings_spl b ON a.tro_ord_nr=b.tro_ord_nr
ORDER BY a.TRO_CAMPAIN_NR, b.PMT_TL1;
QUIT;


DATA work.Camp_Paints_TL2; SET work.Camp_Paints_TL2;
IF TRO_CAMPAIN_NR=0 		THEN DELETE;
IF PAINT_CODE IN ('-',"") 	THEN DELETE;
RUN;

PROC SORT DATA=work.Camp_Paints_TL2 nodupkey; BY TRO_CAMPAIN_NR Prod_line Paint_Code tro_ord_nr PMT PMT_MAX PMT_MIN; RUN;

/* BL1 */
PROC SQL;
CREATE TABLE work.Camp_Paints_BL1 AS
SELECT  a.TRO_CAMPAIN_NR ,
		"SPL" 			AS Prod_line,
		b.PMT_BL1 		AS Paint_Code 	Label='Paint_Code',
		a.tro_ord_nr,
		b.PMT_BL1_TVL 	AS PMT 			Label='PMT',
		b.PMT_BL1_MAX 	AS PMT_MAX 		Label='PMT_MAX',
		b.PMT_BL1_MIN 	AS PMT_MIN 		Label='PMT_MIN'
FROM db2scada.Scada_Orders a LEFT OUTER JOIN db2scada.scada_settings_spl b ON a.tro_ord_nr=b.tro_ord_nr
ORDER BY a.TRO_CAMPAIN_NR, b.PMT_TL1;
QUIT;


DATA work.Camp_Paints_BL1; SET work.Camp_Paints_BL1;
IF TRO_CAMPAIN_NR=0 		THEN DELETE;
IF PAINT_CODE IN ('-',"") 	THEN DELETE;
RUN;

PROC SORT data=work.Camp_Paints_BL1 nodupkey; by TRO_CAMPAIN_NR Prod_line Paint_Code tro_ord_nr PMT PMT_MAX PMT_MIN; RUN;

/* BL2 */
PROC SQL;
CREATE TABLE work.Camp_Paints_BL2 AS
SELECT  a.TRO_CAMPAIN_NR ,
		"SPL" 			AS Prod_line,
		b.PMT_BL1 		AS Paint_Code 	Label='Paint_Code',
		a.tro_ord_nr,
		b.PMT_BL1_TVL 	AS PMT 			Label='PMT',
		b.PMT_BL1_MAX 	AS PMT_MAX 		Label='PMT_MAX',
		b.PMT_BL1_MIN 	AS PMT_MIN 		Label='PMT_MIN'
FROM db2scada.Scada_Orders a LEFT OUTER JOIN db2scada.scada_settings_spl b ON a.tro_ord_nr=b.tro_ord_nr
ORDER BY a.TRO_CAMPAIN_NR, b.PMT_TL1;
QUIT;


DATA work.Camp_Paints_BL2; SET work.Camp_Paints_BL2;
IF TRO_CAMPAIN_NR=0 		THEN DELETE;
IF PAINT_CODE IN ('-',"") 	THEN DELETE;
RUN;

PROC SORT DATA=work.Camp_Paints_BL2 nodupkey; BY TRO_CAMPAIN_NR Prod_line Paint_Code tro_ord_nr  PMT PMT_MAX PMT_MIN; RUN;

DATA work.Camp_Paints_SPL;
Merge work.Camp_Paints_TL1 work.Camp_Paints_TL2 work.Camp_Paints_BL1 work.Camp_Paints_BL2;
BY TRO_CAMPAIN_NR Prod_line Paint_Code Tro_ord_nr PMT PMT_MAX PMT_MIN;
RUN;

/**********************************************************************/
/****    			Camp_Nr & Paints & PMT Values   (WPL)       	****/
/**********************************************************************/
/* TL1 */
PROC SQL;
CREATE TABLE work.Camp_Paints_TL1 AS
SELECT  a.TRO_CAMPAIN_NR ,
		"WPL" 			AS Prod_line,
		b.PMT_TL1 		AS Paint_Code 	Label='Paint_Code',
		a.tro_ord_nr,
		b.PMT_TL1_TVL 	AS PMT 			Label='PMT',
		b.PMT_TL1_MAX 	AS PMT_MAX 		Label='PMT_MAX',
		b.PMT_TL1_MIN 	AS PMT_MIN 		Label='PMT_MIN'
FROM db2scada.Scada_Orders a LEFT OUTER JOIN db2scada.scada_settings_wpl b ON a.tro_ord_nr=b.tro_ord_nr
ORDER BY a.TRO_CAMPAIN_NR, b.PMT_TL1;
QUIT;


DATA work.Camp_Paints_TL1; SET work.Camp_Paints_TL1;
IF TRO_CAMPAIN_NR=0 		THEN DELETE;
IF PAINT_CODE IN ('-',"") 	THEN DELETE;
RUN;

PROC SORT DATA=work.Camp_Paints_TL1 nodupkey; BY TRO_CAMPAIN_NR Prod_line Paint_Code tro_ord_nr PMT PMT_MAX PMT_MIN; RUN;

/* TL2 */
PROC SQL;
CREATE TABLE work.Camp_Paints_TL2 AS
SELECT  a.TRO_CAMPAIN_NR ,
		"WPL" 			AS Prod_line,
		b.PMT_TL2 		AS Paint_Code 	Label='Paint_Code',
		a.tro_ord_nr,
		b.PMT_TL2_TVL 	AS PMT 			Label='PMT',
		b.PMT_TL2_MAX 	AS PMT_MAX 		Label='PMT_MAX',
		b.PMT_TL2_MIN 	AS PMT_MIN 		Label='PMT_MIN'
FROM db2scada.Scada_Orders a LEFT OUTER JOIN db2scada.scada_settings_wpl b ON a.tro_ord_nr=b.tro_ord_nr
ORDER BY a.TRO_CAMPAIN_NR, b.PMT_TL1;
QUIT;


DATA work.Camp_Paints_TL2; SET work.Camp_Paints_TL2;
IF TRO_CAMPAIN_NR=0 		THEN DELETE;
IF PAINT_CODE IN ('-',"") 	THEN DELETE;
RUN;

PROC SORT DATA=work.Camp_Paints_TL2 nodupkey; BY TRO_CAMPAIN_NR Prod_line Paint_Code tro_ord_nr PMT PMT_MAX PMT_MIN; RUN;

/* BL1 */
PROC SQL;
CREATE TABLE work.Camp_Paints_BL1 AS
SELECT  a.TRO_CAMPAIN_NR ,
		"WPL" 			AS Prod_line,
		b.PMT_BL1 		AS Paint_Code 	Label='Paint_Code',
		a.tro_ord_nr,
		b.PMT_BL1_TVL 	AS PMT 			Label='PMT',
		b.PMT_BL1_MAX 	AS PMT_MAX 		Label='PMT_MAX',
		b.PMT_BL1_MIN 	AS PMT_MIN 		Label='PMT_MIN'
FROM db2scada.Scada_Orders a LEFT OUTER JOIN db2scada.scada_settings_wpl b ON a.tro_ord_nr=b.tro_ord_nr
ORDER BY a.TRO_CAMPAIN_NR, b.PMT_TL1;
QUIT;


DATA work.Camp_Paints_BL1; SET work.Camp_Paints_BL1;
IF TRO_CAMPAIN_NR=0 		THEN DELETE;
IF PAINT_CODE IN ('-',"") 	THEN DELETE;
RUN;

PROC SORT DATA=work.Camp_Paints_BL1 nodupkey; BY TRO_CAMPAIN_NR Prod_line Paint_Code tro_ord_nr PMT PMT_MAX PMT_MIN; RUN;

/* BL2 */
PROC SQL;
CREATE TABLE work.Camp_Paints_BL2 AS
SELECT  a.TRO_CAMPAIN_NR ,
		"WPL" 			AS Prod_line,
		b.PMT_BL1 		AS Paint_Code 	Label='Paint_Code',
		a.tro_ord_nr,
		b.PMT_BL1_TVL 	AS PMT 			Label='PMT',
		b.PMT_BL1_MAX 	AS PMT_MAX 		Label='PMT_MAX',
		b.PMT_BL1_MIN 	AS PMT_MIN 		Label='PMT_MIN'
FROM db2scada.Scada_Orders a LEFT OUTER JOIN db2scada.scada_settings_wpl b ON a.tro_ord_nr=b.tro_ord_nr
ORDER BY a.TRO_CAMPAIN_NR, b.PMT_TL1;
QUIT;


DATA work.Camp_Paints_BL2; SET work.Camp_Paints_BL2;
IF TRO_CAMPAIN_NR=0 		THEN DELETE;
IF PAINT_CODE IN ('-',"") 	THEN DELETE;
RUN;

PROC SORT DATA=work.Camp_Paints_BL2 nodupkey; BY TRO_CAMPAIN_NR Prod_line Paint_Code tro_ord_nr  PMT PMT_MAX PMT_MIN; RUN;

DATA work.Camp_Paints_WPL;
Merge work.Camp_Paints_TL1 work.Camp_Paints_TL2 work.Camp_Paints_BL1 work.Camp_Paints_BL2;
BY TRO_CAMPAIN_NR Prod_line Paint_Code Tro_ord_nr PMT PMT_MAX PMT_MIN;
RUN;

/** Merge WPL & SPL Data **/
DATA work.Camp_Paints;
Merge work.Camp_Paints_SPL work.Camp_Paints_WPL;
BY TRO_CAMPAIN_NR Prod_line Paint_Code Tro_ord_nr PMT PMT_MAX PMT_MIN;
RUN;

DATA work.Camp_Paints; SET work.Camp_Paints;
IF PMT=. 		THEN PMT=0;
IF PMT_MAX=. 	THEN PMT_MAX=0;
IF PMT_MIN=. 	THEN PMT_MIN=0;
RUN;

PROC SQL;
CREATE TABLE work.Camp_Paints AS
SELECT  a.*,
		b.Paint_type
FROM work.camp_paints a LEFT OUTER JOIN db2data.paints b ON a.Paint_Code=b.Paint_Code AND b.company='EAP';
QUIT;


/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DELETE from DB2SCADA.Scada_Camp_Paints) by baan;
QUIT;

PROC APPEND BASE=DB2SCADA.Scada_Camp_Paints DATA=work.Camp_Paints; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  ALL ON TABLE DB2SCADA.Scada_Camp_Paints TO USER INFODBC )  by baan;
QUIT;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Camp_Paints'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;







/* UPDATE Proficy Scada Settings SPL Vertical*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo' insertbuff = 10000);
EXECUTE (truncate table Local_Scada_Set_SPL_vert) by Prof;
QUIT; 
PROC APPEND BASE=Proficy.Local_Scada_Set_SPL_vert  DATA=DB2SCADA.Scada_Settings_SPL_vertical FORCE; RUN;


/* UPDATE Proficy Scada Settings SPL*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Set_SPL) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Set_SPL  DATA=DB2SCADA.Scada_Settings_SPL FORCE; RUN;

/* UPDATE Proficy Scada Settings WPL Vertical*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Set_WPL_vert) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Set_WPL_vert  DATA=DB2SCADA.Scada_Settings_WPL_vertical FORCE; RUN;

/* UPDATE Proficy Scada Settings WPL*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Set_WPL) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Set_WPL  DATA=DB2SCADA.Scada_Settings_WPL FORCE; RUN;

/* UPDATE Proficy Scada Settings EL Vertical*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Set_EL_vert) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Set_EL_vert  DATA=DB2SCADA.Scada_Settings_EL_vertical FORCE; RUN;

/* UPDATE Proficy Scada Settings EL*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Set_EL) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Set_EL  DATA=DB2SCADA.Scada_Settings_EL FORCE; RUN;


/* UPDATE Proficy Scada Settings ATK Vertical*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Set_ATK_vert) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Set_ATK_vert  DATA=DB2SCADA.Scada_Settings_ATK_vertical FORCE; RUN;

/* UPDATE Proficy Scada Settings ATK */
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Set_ATK) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Set_ATK  DATA=DB2SCADA.Scada_Settings_ATK FORCE; RUN;


/* UPDATE Proficy Scada Orders SHT*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Orders_SHT) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Orders_SHT  DATA=DB2SCADA.Scada_Orders_SHT FORCE; RUN;

/* UPDATE Proficy Scada Rolls*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Rolls) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Rolls  DATA=DB2SCADA.Scada_Rolls FORCE; RUN;


/* UPDATE Proficy Scada Appl Rolls*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Appl_Rolls) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Appl_Rolls  DATA=DB2SCADA.Scada_Appl_Rolls FORCE; RUN;

/* UPDATE Proficy Scada Camp Paints*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Truncate table Local_Scada_Camp_Paints) by Prof;
QUIT; 

PROC APPEND BASE=Proficy.Local_Scada_Camp_Paints  DATA=DB2SCADA.Scada_Camp_Paints FORCE; RUN;

/* UPDATE Proficy Scada Parameter Change*/
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (Drop table Local_Scada_Parameter_Change) by Prof;
QUIT; 
PROC APPEND BASE=Proficy.Local_Scada_Parameter_Change  DATA=DB2SCADA.Scada_Parameter_Change FORCE; RUN;



/*********************************************/
/*************Local_TRO_PLAN_ORDERS***********/
/*********************************************/
PROC SQL;
CREATE TABLE work.rol_reforcast AS
SELECT  a.*
FROM db2data.rol_reforcast_new_cap a
WHERE REP_GROUP IN ('3.Prod.Res.Pr.','4.Orderbook','5.Orderb.Late') AND COMPANY IN ('EAP','ECP') AND TRO_Type NE '';
QUIT;

DATA work.rol_reforcast(DROP= Campain_key); SET work.rol_reforcast;
FORMAT Campain_key 10.;
Campain_key=substr(put(TRO_CAMPAIN_NR,6.),3,4);
FORMAT TRO_ID 15.;
TRO_ID=compress(Tro_Ord_NR||Campain_key||TRO_CAMPAIN_SEQ_NR);
RUN;

PROC SORT DATA=work.rol_reforcast; BY COMPANY TRO_CAMPAIN_NR TRO_CAMPAIN_SEQ_NR; RUN;

PROC SQL;
CREATE TABLE work.rol_reforcast_only_LS AS
SELECT  a.*
FROM db2data.rol_reforcast_new_cap a
WHERE LS_REASON ne "" AND REP_GROUP IN  ('4.Orderbook','5.Orderb.Late') AND COMPANY IN ('EAP','ECP');
QUIT;

DATA work.rol_reforcast_only_LS; SET work.rol_reforcast_only_LS;
TRO_CAMPAIN_SEQ_NR=(TRO_CAMPAIN_SEQ_NR-1);
FORMAT TRO_ID 15.;
TRO_ID=compress('999999'||TRO_CAMPAIN_NR||TRO_CAMPAIN_SEQ_NR);
TRO_Ord_Nr=999999; TRO_Type='LS'; TRO_Main=888888; TRO_Outp_Width=1265; Idno_Outp_Stat='Open'; Rep_Group='9.Leadingstrip'; Dimset="-";
TRO_Ord_Pos=0; TRO_Outp_Idno=0; TRO_Outp_Pcs=0; TRO_Outp_kg=0; TRO_Outp_m=0; TRO_RunTime_new=0 ;
RUN;

PROC SORT DATA=work.rol_reforcast_only_LS; BY COMPANY TRO_CAMPAIN_NR TRO_CAMPAIN_SEQ_NR; RUN;

DATA work.rol_reforcast_only_LS; SET work.rol_reforcast_only_LS; 
BY COMPANY TRO_CAMPAIN_NR TRO_CAMPAIN_SEQ_NR;
IF NOT FIRST.TRO_CAMPAIN_SEQ_NR THEN DELETE;
RUN;

/*  Extra LS when painttrail  RFBS 11061   dd 19-02-2021  PW  */
DATA work.rol_reforcast_only_LS_extra; SET work.rol_reforcast_only_LS; 
IF PT_Reason="" THEN DELETE;
TRO_CAMPAIN_SEQ_NR=(TRO_CAMPAIN_SEQ_NR-1);
PT_Reason="/TO";
TRO_Setup_New=21/100;
RUN;

/* MERGE BUG? */
/*
DATA work.rol_reforcast_LS;
MERGE work.rol_reforcast work.rol_reforcast_only_LS work.rol_reforcast_only_LS_extra;
by COMPANY TRO_CAMPAIN_NR TRO_CAMPAIN_SEQ_NR;
RUN;
*/
PROC APPEND BASE=work.rol_reforcast_LS DATA=work.rol_reforcast;               RUN;
PROC APPEND BASE=work.rol_reforcast_LS DATA=work.rol_reforcast_only_LS;       RUN;
PROC APPEND BASE=work.rol_reforcast_LS DATA=work.rol_reforcast_only_LS_extra; RUN;

PROC SORT DATA=rol_reforcast_LS; 
BY COMPANY TRO_CAMPAIN_NR TRO_CAMPAIN_SEQ_NR; RUN;


/* Add detailed information */
PROC SQL;
CREATE TABLE work.rol_reforcast_LS AS
SELECT  a.*,
		b.Cust_name
FROM work.rol_reforcast_LS a LEFT OUTER JOIN work.customers b ON a.company=b.company AND a.cust_nr=b.cust_nr;
QUIT;

PROC SQL;
CREATE TABLE work.rol_reforcast_LS AS
SELECT  a.*,
		b.DIM_DESCR
FROM work.rol_reforcast_LS a LEFT OUTER JOIN work.dimsets b ON a.company=b.company AND a.DIMSET=b.DIMSET;
QUIT;

DATA work.rol_reforcast_LS; SET work.rol_reforcast_LS;
IF TRO_Ord_Nr=999999 THEN DO; Cust_Name='LS'; Dim_Descr='LS'; END;
RUN;

PROC SQL;
CREATE TABLE work.rol_reforcast_LS AS
SELECT  a.*,
		b.alloy,
		b.substrate
FROM work.rol_reforcast_LS a LEFT OUTER JOIN db2scada.scada_settings_spl b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr AND a.PROD_LINE='SPL';
QUIT;

PROC SQL;
CREATE TABLE work.rol_reforcast_LS AS
SELECT  a.*,
		b.thickness,
		b.hardness,
		b.alloy			AS Alloy_1	LABEL='Alloy_1',	/*DV 2024-06-04*/
		c.S_001040
FROM work.rol_reforcast_LS a LEFT OUTER JOIN work.Dimsets       b ON a.dimset=b.dimset AND a.company=b.company
							 LEFT OUTER JOIN work.Default_Specs c ON a.dimset=c.dimset AND a.company=c.company;
QUIT;

DATA work.rol_reforcast_LS (DROP=Alloy_1);              /*DV 2024-06-04*/
SET work.rol_reforcast_LS;
IF Alloy=.	THEN Alloy=INPUT(Substr(Alloy_1,1,4),4.0);
RUN;

PROC SQL;
CREATE TABLE work.rol_reforcast_LS AS
SELECT  a.*,
		b.IN_THICKN
FROM work.rol_reforcast_LS a LEFT OUTER JOIN db2scada.scada_orders b ON a.tro_ord_nr=b.tro_ord_nr AND a.TRO_CAMPAIN_SEQ_NR=b.TRO_CAMPAIN_SEQ_NR and a.company=b.company;
QUIT;

/* RM 30-9-2020 Urgent Fix (Mail teun regarding Thickness and In_Thickness */
DATA work.rol_reforcast_LS; SET work.rol_reforcast_LS;
IF IN_THICKN NE . THEN thickness=IN_THICKN;
RUN;

PROC SORT DATA=rol_reforcast_LS; 
BY COMPANY TRO_CAMPAIN_NR TRO_CAMPAIN_SEQ_NR; RUN;

/* RM added 8-7-2021 Settings Validation */
PROC SQL;
CREATE TABLE work.rol_reforcast_LS AS
SELECT  a.*,
		b.Valid
FROM work.rol_reforcast_LS a LEFT OUTER JOIN proficy.local_scada_spl_oventable b ON a.in_thickn=b.thickness AND a.substrate=b.substrate AND a.linespeed=b.linespeed;
QUIT;

/* ADDED FOR FORMAT TEUN QUICK REQUEST */
DATA work.rol_reforcast_LS; SET work.rol_reforcast_LS;
UNC_OVW=0;
REC_OVW=0;
REWIND=0;
DOUBLE_J=0;
IF index(TRO_TYPE,'UND')>0 							THEN REC_OVW=1;
IF index(Cust_name,'Prefa')>0 AND Prod_line='SPL' 	THEN REC_OVW=1;    /* Noodactie Altijd underwind voor Prefa ivm aanloop kras   PW 20-02-2024  */
IF index(tro_ord_nr,'999999')>0 					THEN REC_OVW=0;
IF index(TRO_TYPE,'OMW')>0 							THEN REWIND=1;
IF Alloy IN ('1050','5005') 						THEN DOUBLE_J=1;
IF S_001040 IN ('COPPER','ZINK') 					THEN DOUBLE_J=1; 
IF IN_THICKN<=0.3 AND IN_THICKN>. 					THEN DOUBLE_J=1;  
RUN;


/* UPDATE DB2 */
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE( DROP  TABLE DB2ADMIN.rol_reforcast_LS  ) by Baan;
QUIT;


PROC APPEND BASE=DB2DATA.rol_reforcast_LS  DATA=work.rol_reforcast_LS FORCE; RUN;
PROC SQL;
CONNECT to odbc as DB2 (dsn='db2ecp');
EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.rol_reforcast_LS TO USER INFODBC )  by DB2;
QUIT;



/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (DROP TABLE  Local_TRO_PLAN_ORDERS) by Prof;
QUIT; 

PROC APPEND base=Proficy.Local_TRO_PLAN_ORDERS  data=work.rol_reforcast_LS FORCE; RUN;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='rol_reforcast_LS'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;










/*********************************************/
/*************Local_TRO_PLAN_SPECS************/
/*********************************************/
PROC SQL;
CREATE TABLE work.Local_TRO_PLAN_SPECS AS
SELECT  a.*,
		b.TOPCOAT_VZ,
		b.CHEMCOATVZ,
		b.CHEMCOATKZ,
		b.INKJET,
		b.TRO_RUN_NR AS TRO_RUN_NR_SPL,
		c.TRO_RUN_NR AS TRO_RUN_NR_WPL
FROM work.rol_reforcast_LS a 
LEFT OUTER JOIN db2scada.scada_settings_spl b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr AND a.PROD_LINE='SPL'
LEFT OUTER JOIN db2scada.scada_settings_wpl c ON a.company=c.company AND a.tro_ord_nr=c.tro_ord_nr AND a.PROD_LINE='WPL';
QUIT;
DATA work.Local_TRO_PLAN_SPECS; SET work.Local_TRO_PLAN_SPECS;
IF Prod_line='SPL' THEN TRO_RUN_NR=TRO_RUN_NR_SPL;
IF Prod_line='WPL' THEN TRO_RUN_NR=TRO_RUN_NR_WPL;
RUN;

PROC SQL;
CREATE TABLE work.Local_TRO_PLAN_SPECS AS
SELECT	a.TRO_ID,
		a.TOPCOAT_VZ,
		a.CHEMCOATVZ,
		a.CHEMCOATKZ,
		a.INKJET,
		a.TRO_RUN_NR,
		a.Tro_ord_Nr,
		a.Rewind,
		b.*
FROM work.Local_TRO_PLAN_SPECS a LEFT OUTER JOIN db2data.dimset_speeds b ON a.company=b.company AND a.dimset=b.dimset AND a.TRO_TYPE_STAND=b.tro_stand
WHERE a.company IN('EAP','ECP');
QUIT;


PROC SQL;
CREATE TABLE work.Local_TRO_PLAN_SPECS AS
SELECT  a.*,
		b.TRO_MAIN
FROM work.Local_TRO_PLAN_SPECS a
LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr;
QUIT;

PROC SORT data=work.Local_TRO_PLAN_SPECS nodupkey; by TRO_ID; RUN;


/* SUM_DLT_RUN1 > Dusty tro_local_specs */
PROC SQL;
CREATE TABLE work.spl_DLT AS
SELECT  a.Company,
		a.tro_ord_nr,
		b.tro_main,
		a.Dimset,
		SUM(a.Lay_Thickn_Dry_Target) AS SUM_DLT_TARG_RUN1
FROM db2data.iHistorian_SPL_AVG_Matrix a
LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr
WHERE a.TRO_TYPE CONTAINS 'L 1E'
GROUP BY a.company, a.tro_ord_nr, b.tro_main, a.dimset;
QUIT;

PROC SQL;
CREATE TABLE work.Local_TRO_PLAN_SPECS AS
SELECT  a.*,
		b.SUM_DLT_TARG_RUN1
FROM work.Local_TRO_PLAN_SPECS a
LEFT OUTER JOIN work.spl_DLT b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr AND a.dimset=b.dimset;
QUIT;

/* Dry meas_Bs + Fs > Dusty tro_local_specs */
/* BS */
PROC SQL;
CREATE TABLE work.spl_DLT_BS AS
SELECT  a.Company,
		a.tro_ord_nr,
		b.tro_main,
		a.Dimset,
		SUM(a.Lay_Thickn_Dry_Meas) AS SUM_DLT_RUN1_AVG_BS
FROM db2data.iHistorian_SPL_AVG_Matrix a
LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr
WHERE a.TRO_TYPE CONTAINS 'L 1E' AND a.Coater_Type IN ('S2','B2')
GROUP BY a.company, a.tro_ord_nr, b.tro_main, a.dimset;
QUIT;

PROC SQL;
CREATE TABLE work.wpl_DLT_BS AS
SELECT  a.Company,
		a.tro_ord_nr,
		b.tro_main,
		a.Dimset,
		SUM(a.Lay_Thickn_Dry_Meas) AS SUM_DLT_RUN1_AVG_BS
FROM db2data.iHistorian_WPL_AVG_Matrix a
LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr
WHERE a.TRO_TYPE CONTAINS 'L 1E' AND a.Coater_Type IN ('KZ')
GROUP BY a.company, a.tro_ord_nr, b.tro_main, a.dimset;
QUIT;

PROC APPEND BASE=work.spl_DLT_BS data=work.wpl_DLT_BS; RUN;

PROC SQL;
CREATE TABLE work.Local_TRO_PLAN_SPECS AS
SELECT  a.*,
		b.SUM_DLT_RUN1_AVG_BS
FROM work.Local_TRO_PLAN_SPECS a
LEFT OUTER JOIN work.spl_DLT_BS b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr AND a.dimset=b.dimset;
QUIT;


/* FS */
PROC SQL;
CREATE TABLE work.spl_DLT_FS AS
SELECT  a.Company,
		a.tro_ord_nr,
		b.tro_main,
		a.Dimset,
		SUM(a.DRY_LAYER_THICKN_AVG) AS SUM_DLT_RUN1_AVG_FS
FROM db2data.iHistorian_SPL_AVG_Matrix a
LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr
WHERE a.TRO_TYPE CONTAINS 'L 1E' AND a.Coater_Type IN ('S1','AL','AR')
GROUP BY a.company, a.tro_ord_nr, b.tro_main, a.dimset;
QUIT;

PROC SQL;
CREATE TABLE work.wpl_DLT_FS AS
SELECT  a.Company,
		a.tro_ord_nr,
		b.tro_main,
		a.Dimset,
		SUM(a.DRY_LAYER_THICKN_AVG) AS SUM_DLT_RUN1_AVG_FS
FROM db2data.iHistorian_WPL_AVG_Matrix a
LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr
WHERE a.TRO_TYPE CONTAINS 'L 1E' AND a.Coater_Type IN ('VZ')
GROUP BY a.company, a.tro_ord_nr, b.tro_main, a.dimset;
QUIT;

PROC APPEND BASE=work.spl_DLT_FS data=work.wpl_DLT_FS; RUN;

PROC SQL;
CREATE TABLE work.Local_TRO_PLAN_SPECS AS
SELECT  a.*,
		b.SUM_DLT_RUN1_AVG_FS
FROM work.Local_TRO_PLAN_SPECS a
LEFT OUTER JOIN work.spl_DLT_FS b ON a.company=b.company AND a.tro_main=b.tro_main AND a.dimset=b.dimset;
QUIT;


PROC SORT data=work.Local_TRO_PLAN_SPECS nodupkey; by TRO_ID; RUN;

/* add beltwrapper */
PROC SQL;
CREATE TABLE work.Local_TRO_PLAN_SPECS AS
SELECT  a.*,
		b.value AS Beltwrapper label='Beltwrapper'
FROM work.Local_TRO_PLAN_SPECS a
LEFT OUTER JOIN cdd.lra220 b ON a.company=b.company AND a.dimset=b.dimset AND b.spec='100020';
QUIT;

DATA work.Local_TRO_PLAN_SPECS(DROP=Beltwrapper); SET work.Local_TRO_PLAN_SPECS;
Sleeve=0;
IF Beltwrapper='610' THEN Sleeve=1;
RUN;

/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (DROP TABLE  Local_TRO_PLAN_SPECS) by Prof;
QUIT; 

PROC APPEND base=Proficy.Local_TRO_PLAN_SPECS  data=work.Local_TRO_PLAN_SPECS FORCE; RUN;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 100 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Local_TRO_PLAN_SPECS'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;

/* UPDATE DB2  */
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE( DROP TABLE db2admin.Scada_Settings_Check  ) by Baan;
QUIT;


PROC APPEND base=db2data.Scada_Settings_Check  data=Proficy.Local_TRO_PLAN_SPECS FORCE; RUN;

PROC SQL;
CONNECT to odbc as DB2 (dsn='db2ecp');
EXECUTE ( GRANT  SELECT ON TABLE db2admin.Scada_Settings_Check TO USER INFODBC )  by DB2;
EXECUTE ( GRANT  SELECT ON TABLE db2admin.Scada_Settings_Check TO USER FINODBC )  by DB2;
QUIT;




/* UPDATE DB2  */
PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE( DELETE FROM DB2ADMIN.Scada_ClimateControl  ) by Baan;
QUIT;


PROC APPEND base=DB2DATA.Scada_ClimateControl  data=Proficy.Local_Scada_ClimateControl FORCE; RUN;

PROC SQL;
CONNECT to odbc as DB2 (dsn='db2ecp');
EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.Scada_ClimateControl TO USER INFODBC )  by DB2;
EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.Scada_ClimateControl TO USER FINODBC )  by DB2;
QUIT;










/********** SM-LABDLT RECIPE DATA **********/
libname smlabdlt  odbc dsn='sm-labdlt' user=sa password=sensory;
libname Proficy ODBC  dsn='Proficy' schema=dbo user=proficydbo password=proficydbo;

PROC SQL;
CREATE TABLE work.SMLABDLT_Recipe AS
SELECT a.Name,
		-1 					AS TARGET_ECP_MIN,
		1 					AS TARGET_ECP_MAX,
		-2 					AS TARGET_CUST_MIN,
		2 					AS TARGET_CUST_MAX,
		b.TARGET_ECP_MAX 	AS NEW_Trigger
FROM smlabdlt.recipes a
LEFT OUTER JOIN proficy.Local_Scada_SpecmetrixRCP b ON a.Name=b.Recipe_ID
WHERE Is_Active=1;
QUIT;
DATA work.SMLABDLT_Recipe(DROP=NEW_Trigger); SET work.SMLABDLT_Recipe;
IF NEW_Trigger=. THEN New_Record='Yes';
FORMAT Recipe_ID $50.;
Recipe_ID=Name;
RUN;

PROC SQL;
CREATE TABLE work.Local_Scada_SpecmetrixRCP_NEW AS
SELECT  a.*
FROM proficy.Local_Scada_SpecmetrixRCP a
INNER JOIN work.SMLABDLT_Recipe b ON a.Recipe_ID=b.Name;
QUIT;

PROC APPEND BASE=work.Local_Scada_SpecmetrixRCP_NEW data=work.SMLABDLT_Recipe FORCE; WHERE New_Record='Yes'; RUN;

PROC SORT DATA=work.Local_Scada_SpecmetrixRCP_NEW; by Recipe_ID; RUN;

/* Update Table Macro */
%MACRO UpdateTable();
PROC SQL;
CONNECT to odbc as Prof (dsn='Proficy' user='proficydbo' password='proficydbo');
EXECUTE (DELETE FROM Local_Scada_SpecmetrixRCP ) by Prof;
QUIT; 

PROC APPEND base=Proficy.Local_Scada_SpecmetrixRCP  data=work.Local_Scada_SpecmetrixRCP_NEW FORCE; RUN;
%MEND;

/* Rec Check Macro */
%MACRO Rec_Check(Table_Name);
DATA work.Rec_Check (KEEP=Rec_Check Table_Name); SET work.&Table_name; Rec_Check=1; Table_Name="&Table_Name"; RUN;
PROC SQL; CREATE TABLE work.rec_count AS SELECT a.Table_Name, Count(a.Rec_Check) AS rec_Count FROM work.Rec_Check a GROUP BY a.Table_Name ORDER BY a.Table_Name; QUIT;
DATA work.rec_count; SET work.rec_count;
IF rec_Count > 10 THEN CALL EXECUTE('%UpdateTable');
RUN;
%MEND;

/* Call in Rec_Check macro */
DATA work.Table_name; Table_name='Local_Scada_SpecmetrixRCP_NEW'; RUN;
DATA work.Table_name;; SET work.Table_name;
CALL EXECUTE('%Rec_Check('||Table_Name||')');
RUN;
