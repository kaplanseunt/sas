libname db2data  odbc dsn='db2ecp' schema=DB2ADMIN user=db2admin password=aachen;
libname db2fin   odbc dsn='db2ecp' schema=DB2FIN   user=db2admin password=aachen;

/* PW 03-07-2020  		For Customer MCCA use Shipm_first_Date and NOT Shpm_Last_date		*/
/* RM 08-07-2020 ADDED CUST 061210 BALANCE ORDER CHECK  & OTIF HITS */
/* RM 09-07-2020 ADDED Cust 061210 Ord Tol Business Rule AND MT_type for each Order */
/* RM 14-07-2020 ADDED InFull Perc calculation */
/* RM 11-9-2020 changed join; Before; Sal_Ord_Pos_org_ord_quan After; sal_ord_pos_quan */

/**********************************************************************/
/****    Collecting SLX121 table comp         			   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.slx121 as select * from connection to baan
   (SELECT  'Roe'									AS Company,
			CASE
			WHEN a.t_koor=3 	THEN "Sales   "
			WHEN a.t_koor=11 	THEN "Forecast" END AS Ord_Type,
			CASE
			WHEN a.t_dstk=1 	THEN "Y"
			WHEN a.t_dstk=2 	THEN "N" 		END AS WO_Prep_Org_Del_From_Stock,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_dset	Dimset,
			a.t_prfl	WO_Prep_Org_Proc_Flow,
			a.t_sbds	WO_Prep_Org_Substr_Dimset,
			a.t_sbdt	WO_Prep_Org_Substr_Date,
			a.t_pndt	WO_Prep_Org_Paint_date,
			a.t_pcdt	WO_Prep_Org_Foil_date,
			a.t_cpdt	WO_Prep_Org_Capac_date,
			a.t_ltdt	WO_Prep_Org_Leadt_date,
			a.t_cfdt	WO_Prep_Org_Confirm_date,
			a.t_ltdt	WO_Prep_Org_Leadt_date,
			a.t_prdt	WO_P_Org_Sal_Plan_Del_date,
			a.t_ddta	WO_P_Org_Sal_Prod_Compl_date,
			a.t_dtrs	WO_Prep_Org_Rel_Sales,
			a.t_dtrl	WO_Prep_Org_Rel_Logistics,
			a.t_dtcs	WO_Prep_Org_Conf_Sales_Date,
			a.t_dtfi	WO_Prep_Org_Finished_Date,
			a.t_dtca	WO_Prep_Org_Canceled_Date,
			a.t_ccbd	WO_Prep_Org_Cred_block_Date,
			a.t_madt	WO_Prep_Org_MAD_Date,
			a.t_psdt	WO_Prep_Org_Requirement_Date,
			a.t_acun_c	WO_Prep_Org_Ord_Quan_Unit,
			a.t_quau_c	WO_Prep_Org_Ord_Quan,
			a.t_date	Date,
			a.t_time	Time,
			a.t_wpst	WO_Prep_Status
FROM 			ttdslx121120 a
WHERE a.t_date>MDY(01,01,2018)
UNION ALL
   SELECT  'Cor'									AS Company,
			CASE
			WHEN a.t_koor=3 	THEN "Sales   "
			WHEN a.t_koor=11 	THEN "Forecast" END AS Ord_Type,
			CASE
			WHEN a.t_dstk=1 	THEN "Y"
			WHEN a.t_dstk=2 	THEN "N" 		END AS WO_Prep_Org_Del_From_Stock,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_dset	Dimset,
			a.t_prfl	WO_Prep_Org_Proc_Flow,
			a.t_sbds	WO_Prep_Org_Substr_Dimset,
			a.t_sbdt	WO_Prep_Org_Substr_Date,
			a.t_pndt	WO_Prep_Org_Paint_date,
			a.t_pcdt	WO_Prep_Org_Foil_date,
			a.t_cpdt	WO_Prep_Org_Capac_date,
			a.t_ltdt	WO_Prep_Org_Leadt_date,
			a.t_cfdt	WO_Prep_Org_Confirm_date,
			a.t_ltdt	WO_Prep_Org_Leadt_date,
			a.t_prdt	WO_P_Org_Sal_Plan_Del_date,
			a.t_ddta	WO_P_Org_Sal_Prod_Compl_date,
			a.t_dtrs	WO_Prep_Org_Rel_Sales,
			a.t_dtrl	WO_Prep_Org_Rel_Logistics,
			a.t_dtcs	WO_Prep_Org_Conf_Sales_Date,
			a.t_dtfi	WO_Prep_Org_Finished_Date,
			a.t_dtca	WO_Prep_Org_Canceled_Date,
			a.t_ccbd	WO_Prep_Org_Cred_block_Date,
			a.t_madt	WO_Prep_Org_MAD_Date,
			a.t_psdt	WO_Prep_Org_Requirement_Date,
			a.t_acun_c	WO_Prep_Org_Ord_Quan_Unit,
			a.t_quau_c	WO_Prep_Org_Ord_Quan,
			a.t_date	Date,
			a.t_time	Time,
			a.t_wpst	WO_Prep_Status
FROM 			ttdslx121200 a
WHERE a.t_date>MDY(01,01,2018)
UNION ALL
   SELECT  'ECP'									AS Company,
			CASE
			WHEN a.t_koor=3 	THEN "Sales   "
			WHEN a.t_koor=11 	THEN "Forecast" END AS Ord_Type,
			CASE
			WHEN a.t_dstk=1 	THEN "Y"
			WHEN a.t_dstk=2 	THEN "N" 		END AS WO_Prep_Org_Del_From_Stock,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_dset	Dimset,
			a.t_prfl	WO_Prep_Org_Proc_Flow,
			a.t_sbds	WO_Prep_Org_Substr_Dimset,
			a.t_sbdt	WO_Prep_Org_Substr_Date,
			a.t_pndt	WO_Prep_Org_Paint_date,
			a.t_pcdt	WO_Prep_Org_Foil_date,
			a.t_cpdt	WO_Prep_Org_Capac_date,
			a.t_ltdt	WO_Prep_Org_Leadt_date,
			a.t_cfdt	WO_Prep_Org_Confirm_date,
			a.t_ltdt	WO_Prep_Org_Leadt_date,
			a.t_prdt	WO_P_Org_Sal_Plan_Del_date,
			a.t_ddta	WO_P_Org_Sal_Prod_Compl_date,
			a.t_dtrs	WO_Prep_Org_Rel_Sales,
			a.t_dtrl	WO_Prep_Org_Rel_Logistics,
			a.t_dtcs	WO_Prep_Org_Conf_Sales_Date,
			a.t_dtfi	WO_Prep_Org_Finished_Date,
			a.t_dtca	WO_Prep_Org_Canceled_Date,
			a.t_ccbd	WO_Prep_Org_Cred_block_Date,
			a.t_madt	WO_Prep_Org_MAD_Date,
			a.t_psdt	WO_Prep_Org_Requirement_Date,
			a.t_acun_c	WO_Prep_Org_Ord_Quan_Unit,
			a.t_quau_c	WO_Prep_Org_Ord_Quan,
			a.t_date	Date,
			a.t_time	Time,
			a.t_wpst	WO_Prep_Status
FROM 			ttdslx121130 a
WHERE a.t_date>MDY(01,01,2018)
UNION ALL
   SELECT  'EAP'									AS Company,
			CASE
			WHEN a.t_koor=3 	THEN "Sales   "
			WHEN a.t_koor=11 	THEN "Forecast" END AS Ord_Type,
			CASE
			WHEN a.t_dstk=1 	THEN "Y"
			WHEN a.t_dstk=2 	THEN "N" 		END AS WO_Prep_Org_Del_From_Stock,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_dset	Dimset,
			a.t_prfl	WO_Prep_Org_Proc_Flow,
			a.t_sbds	WO_Prep_Org_Substr_Dimset,
			a.t_sbdt	WO_Prep_Org_Substr_Date,
			a.t_pndt	WO_Prep_Org_Paint_date,
			a.t_pcdt	WO_Prep_Org_Foil_date,
			a.t_cpdt	WO_Prep_Org_Capac_date,
			a.t_ltdt	WO_Prep_Org_Leadt_date,
			a.t_cfdt	WO_Prep_Org_Confirm_date,
			a.t_ltdt	WO_Prep_Org_Leadt_date,
			a.t_prdt	WO_P_Org_Sal_Plan_Del_date,
			a.t_ddta	WO_P_Org_Sal_Prod_Compl_date,
			a.t_dtrs	WO_Prep_Org_Rel_Sales,
			a.t_dtrl	WO_Prep_Org_Rel_Logistics,
			a.t_dtcs	WO_Prep_Org_Conf_Sales_Date,
			a.t_dtfi	WO_Prep_Org_Finished_Date,
			a.t_dtca	WO_Prep_Org_Canceled_Date,
			a.t_ccbd	WO_Prep_Org_Cred_block_Date,
			a.t_madt	WO_Prep_Org_MAD_Date,
			a.t_psdt	WO_Prep_Org_Requirement_Date,
			a.t_acun_c	WO_Prep_Org_Ord_Quan_Unit,
			a.t_quau_c	WO_Prep_Org_Ord_Quan,
			a.t_date	Date,
			a.t_time	Time,
			a.t_wpst	WO_Prep_Status
FROM 			ttdslx121300 a
WHERE a.t_date>MDY(01,01,2018));
 DISCONNECT from baan;
QUIT;

PROC SORT DATA=work.slx121;
BY Company Sal_Ord_nr Sal_ord_pos Date Time;
RUN;

DATA work.slx121SalConf; SET work.slx121;
BY Company Sal_Ord_nr Sal_ord_pos Date Time;
IF NOT FIRST.Sal_ord_pos THEN DELETE;
WHERE WO_Prep_Status=2;
RUN;

DATA work.slx121 (DROP=WO_Prep_Status); SET work.slx121;
BY Company Sal_Ord_nr Sal_ord_pos Date Time;
IF NOT LAST.Sal_ord_pos THEN DELETE;
RUN;

/**********************************************************************/
/****    Collecting SLX123 table comp        			   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.slx123 as select * from connection to baan
   (SELECT  'Roe'									AS Company,
			CASE
			WHEN a.t_koor=3 	THEN "Sales   "
			WHEN a.t_koor=11 	THEN "Forecast" END AS Ord_Type,
			CASE
			WHEN a.t_dstk=1 	THEN "Y"
			WHEN a.t_dstk=2 	THEN "N" 		END AS WO_Prep_Fin_Del_From_Stock,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_prfl	WO_Prep_Fin_Proc_Flow,
			a.t_sbds	WO_Prep_Fin_Substr_Dimset,
			a.t_sbdt	WO_Prep_Fin_Substr_Date,
			a.t_pndt	WO_Prep_Fin_Paint_date,
			a.t_pcdt	WO_Prep_Fin_Foil_date,
			a.t_cpdt	WO_Prep_Fin_Capac_date,
			a.t_ltdt	WO_Prep_Fin_Leadt_date,
			a.t_cfdt	WO_Prep_Fin_Confirm_date,
			a.t_ltdt	WO_Prep_Fin_Leadt_date,
			a.t_prdt	WO_P_Fin_Sal_Plan_Del_date,
			a.t_ddta	WO_P_Fin_Sal_Prod_Compl_date,
			a.t_dtrs	WO_Prep_Fin_Rel_Sales,
			a.t_dtrl	WO_Prep_Fin_Rel_Logistics,
			a.t_dtcs	WO_Prep_Fin_Conf_Sales_Date,
			a.t_dtfi	WO_Prep_Fin_Finished_Date,
			a.t_dtca	WO_Prep_Fin_Canceled_Date,
			a.t_ccbd	WO_Prep_Fin_Cred_block_Date,
			a.t_madt	WO_Prep_Fin_MAD_Date,
			a.t_psdt	WO_Prep_Fin_Requirement_Date,
			a.t_acun_c	WO_Prep_Fin_Ord_Quan_Unit,
			a.t_quau_c	WO_Prep_Fin_Ord_Quan
FROM 			ttdslx123120 a
UNION ALL
   SELECT  'Cor' 									AS Company,
			CASE
			WHEN a.t_koor=3 	THEN "Sales   "
			WHEN a.t_koor=11 	THEN "Forecast" END AS Ord_Type,
			CASE
			WHEN a.t_dstk=1 	THEN "Y"
			WHEN a.t_dstk=2 	THEN "N" 		END AS WO_Prep_Fin_Del_From_Stock,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_prfl	WO_Prep_Fin_Proc_Flow,
			a.t_sbds	WO_Prep_Fin_Substr_Dimset,
			a.t_sbdt	WO_Prep_Fin_Substr_Date,
			a.t_pndt	WO_Prep_Fin_Paint_date,
			a.t_pcdt	WO_Prep_Fin_Foil_date,
			a.t_cpdt	WO_Prep_Fin_Capac_date,
			a.t_ltdt	WO_Prep_Fin_Leadt_date,
			a.t_cfdt	WO_Prep_Fin_Confirm_date,
			a.t_ltdt	WO_Prep_Fin_Leadt_date,
			a.t_prdt	WO_P_Fin_Sal_Plan_Del_date,
			a.t_ddta	WO_P_Fin_Sal_Prod_Compl_date,
			a.t_dtrs	WO_Prep_Fin_Rel_Sales,
			a.t_dtrl	WO_Prep_Fin_Rel_Logistics,
			a.t_dtcs	WO_Prep_Fin_Conf_Sales_Date,
			a.t_dtfi	WO_Prep_Fin_Finished_Date,
			a.t_dtca	WO_Prep_Fin_Canceled_Date,
			a.t_ccbd	WO_Prep_Fin_Cred_block_Date,
			a.t_madt	WO_Prep_Fin_MAD_Date,
			a.t_psdt	WO_Prep_Fin_Requirement_Date,
			a.t_acun_c	WO_Prep_Fin_Ord_Quan_Unit,
			a.t_quau_c	WO_Prep_Fin_Ord_Quan
FROM 			ttdslx123200 a
UNION ALL
   SELECT  'ECP' 									AS Company,
			CASE
			WHEN a.t_koor=3 	THEN "Sales   "
			WHEN a.t_koor=11 	THEN "Forecast" END AS Ord_Type,
			CASE
			WHEN a.t_dstk=1 	THEN "Y"
			WHEN a.t_dstk=2 	THEN "N" 		END AS WO_Prep_Fin_Del_From_Stock,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_prfl	WO_Prep_Fin_Proc_Flow,
			a.t_sbds	WO_Prep_Fin_Substr_Dimset,
			a.t_sbdt	WO_Prep_Fin_Substr_Date,
			a.t_pndt	WO_Prep_Fin_Paint_date,
			a.t_pcdt	WO_Prep_Fin_Foil_date,
			a.t_cpdt	WO_Prep_Fin_Capac_date,
			a.t_ltdt	WO_Prep_Fin_Leadt_date,
			a.t_cfdt	WO_Prep_Fin_Confirm_date,
			a.t_ltdt	WO_Prep_Fin_Leadt_date,
			a.t_prdt	WO_P_Fin_Sal_Plan_Del_date,
			a.t_ddta	WO_P_Fin_Sal_Prod_Compl_date,
			a.t_dtrs	WO_Prep_Fin_Rel_Sales,
			a.t_dtrl	WO_Prep_Fin_Rel_Logistics,
			a.t_dtcs	WO_Prep_Fin_Conf_Sales_Date,
			a.t_dtfi	WO_Prep_Fin_Finished_Date,
			a.t_dtca	WO_Prep_Fin_Canceled_Date,
			a.t_ccbd	WO_Prep_Fin_Cred_block_Date,
			a.t_madt	WO_Prep_Fin_MAD_Date,
			a.t_psdt	WO_Prep_Fin_Requirement_Date,
			a.t_acun_c	WO_Prep_Fin_Ord_Quan_Unit,
			a.t_quau_c	WO_Prep_Fin_Ord_Quan
FROM 			ttdslx123130 a
UNION ALL
   SELECT  'EAP' 									AS Company,
			CASE
			WHEN a.t_koor=3 	THEN "Sales   "
			WHEN a.t_koor=11 	THEN "Forecast" END AS Ord_Type,
			CASE
			WHEN a.t_dstk=1 	THEN "Y"
			WHEN a.t_dstk=2 	THEN "N" 		END AS WO_Prep_Fin_Del_From_Stock,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_prfl	WO_Prep_Fin_Proc_Flow,
			a.t_sbds	WO_Prep_Fin_Substr_Dimset,
			a.t_sbdt	WO_Prep_Fin_Substr_Date,
			a.t_pndt	WO_Prep_Fin_Paint_date,
			a.t_pcdt	WO_Prep_Fin_Foil_date,
			a.t_cpdt	WO_Prep_Fin_Capac_date,
			a.t_ltdt	WO_Prep_Fin_Leadt_date,
			a.t_cfdt	WO_Prep_Fin_Confirm_date,
			a.t_ltdt	WO_Prep_Fin_Leadt_date,
			a.t_prdt	WO_P_Fin_Sal_Plan_Del_date,
			a.t_ddta	WO_P_Fin_Sal_Prod_Compl_date,
			a.t_dtrs	WO_Prep_Fin_Rel_Sales,
			a.t_dtrl	WO_Prep_Fin_Rel_Logistics,
			a.t_dtcs	WO_Prep_Fin_Conf_Sales_Date,
			a.t_dtfi	WO_Prep_Fin_Finished_Date,
			a.t_dtca	WO_Prep_Fin_Canceled_Date,
			a.t_ccbd	WO_Prep_Fin_Cred_block_Date,
			a.t_madt	WO_Prep_Fin_MAD_Date,
			a.t_psdt	WO_Prep_Fin_Requirement_Date,
			a.t_acun_c	WO_Prep_Fin_Ord_Quan_Unit,
			a.t_quau_c	WO_Prep_Fin_Ord_Quan
FROM 			ttdslx123300 a);
 DISCONNECT from baan;
QUIT;

/**********************************************************************/
/****    Collecting QUA427 table      			   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.qua427 as select * from connection to baan
   (SELECT  'Roe'										AS Company,
			a.t_irre	Irreg_nr,
			a.t_irpo	Irreg_pos,
			a.t_acno	Irreg_act_nr,
			CASE
			WHEN a.t_slxd=1 	THEN "Substrate "
			WHEN a.t_slxd=2 	THEN "Paint     "
			WHEN a.t_slxd=3 	THEN "Polycoat  "
			WHEN a.t_slxd=7 	THEN "MAD       "
			WHEN a.t_slxd=8 	THEN "Plan.Compl"
			WHEN a.t_slxd=9 	THEN "Plan.Del. " 
			WHEN a.t_slxd=10 	THEN "Req.Del.  "
			WHEN a.t_slxd=11  	THEN "Cust.Del. "  END 	AS Ord_Type,
			a.t_dold	Old_date,
			a.t_dnew	New_date,
			a.t_qold	Old_Quan,
			a.t_qnew	New_Quan,
			a.t_prdt	Last_Update_date,
			b.t_sorn	Sal_Ord_nr,
			b.t_spon	Sal_Ord_pos
FROM 			ttdqua427120 a,	ttdqua400120 b
WHERE  a.t_irre=b.t_irre AND a.t_dnew > 0 
UNION ALL
   SELECT  'Cor'										AS 	Company,
			a.t_irre	Irreg_nr,
			a.t_irpo	Irreg_pos,
			a.t_acno	Irreg_act_nr,
			CASE
			WHEN a.t_slxd=1 	THEN "Substrate "
			WHEN a.t_slxd=2 	THEN "Paint     "
			WHEN a.t_slxd=3 	THEN "Polycoat  "
			WHEN a.t_slxd=7 	THEN "MAD       "
			WHEN a.t_slxd=8 	THEN "Plan.Compl"
			WHEN a.t_slxd=9 	THEN "Plan.Del. " 
			WHEN a.t_slxd=10 	THEN "Req.Del.  "
			WHEN a.t_slxd=11  	THEN "Cust.Del. "  END 	AS Ord_Type,
			a.t_dold	Old_date,
			a.t_dnew	New_date,
			a.t_qold	Old_Quan,
			a.t_qnew	New_Quan,
			a.t_prdt	Last_Update_date,
			b.t_sorn	Sal_Ord_nr,
			b.t_spon	Sal_Ord_pos
FROM 			ttdqua427200 a,	ttdqua400200 b
WHERE  a.t_irre=b.t_irre AND a.t_dnew > 0
UNION ALL
   SELECT  'ECP'										AS Company,
			a.t_irre	Irreg_nr,
			a.t_irpo	Irreg_pos,
			a.t_acno	Irreg_act_nr,
			CASE
			WHEN a.t_slxd=1 	THEN "Substrate "
			WHEN a.t_slxd=2 	THEN "Paint     "
			WHEN a.t_slxd=3 	THEN "Polycoat  "
			WHEN a.t_slxd=7 	THEN "MAD       "
			WHEN a.t_slxd=8 	THEN "Plan.Compl"
			WHEN a.t_slxd=9 	THEN "Plan.Del. " 
			WHEN a.t_slxd=10 	THEN "Req.Del.  "
			WHEN a.t_slxd=11  	THEN "Cust.Del. "  END 	AS Ord_Type,
			a.t_dold	Old_date,
			a.t_dnew	New_date,
			a.t_qold	Old_Quan,
			a.t_qnew	New_Quan,
			a.t_prdt	Last_Update_date,
			b.t_sorn	Sal_Ord_nr,
			b.t_spon	Sal_Ord_pos
FROM 			ttdqua427130 a,	ttdqua400130 b
WHERE  a.t_irre=b.t_irre AND a.t_dnew > 0
UNION ALL
   SELECT  'EAP'										AS Company,
			a.t_irre	Irreg_nr,
			a.t_irpo	Irreg_pos,
			a.t_acno	Irreg_act_nr,
			CASE
			WHEN a.t_slxd=1 	THEN "Substrate "
			WHEN a.t_slxd=2 	THEN "Paint     "
			WHEN a.t_slxd=3 	THEN "Polycoat  "
			WHEN a.t_slxd=7 	THEN "MAD       "
			WHEN a.t_slxd=8 	THEN "Plan.Compl"
			WHEN a.t_slxd=9 	THEN "Plan.Del. " 
			WHEN a.t_slxd=10 	THEN "Req.Del.  "
			WHEN a.t_slxd=11  	THEN "Cust.Del. "  END 	AS Ord_Type,
			a.t_dold	Old_date,
			a.t_dnew	New_date,
			a.t_qold	Old_Quan,
			a.t_qnew	New_Quan,
			a.t_prdt	Last_Update_date,
			b.t_sorn	Sal_Ord_nr,
			b.t_spon	Sal_Ord_pos
FROM 			ttdqua427300 a,	ttdqua400300 b
WHERE  a.t_irre=b.t_irre AND a.t_dnew > 0);
 DISCONNECT from baan;
QUIT;

PROC SORT DATA=work.qua427;
BY Company Sal_Ord_nr Sal_Ord_pos Irreg_nr Irreg_pos Irreg_act_nr;
RUN;

DATA work.qua427; SET work.qua427;
BY Company Sal_Ord_nr Sal_Ord_pos Irreg_nr Irreg_pos Irreg_Act_nr;
RETAIN Irreg_nrR Irreg_PosR Irreg_act_nrR;
IF First.Sal_Ord_pos 							THEN DO; Irreg_nrR=Irreg_nr; Irreg_PosR=Irreg_Pos; Irreg_act_nrR=Irreg_act_nr; END;
IF Irreg_nrR=Irreg_nr AND Irreg_PosR=Irreg_Pos 	THEN Irreg_Count=0; 																ELSE Irreg_Count=1;
IF First.Sal_Ord_pos 							THEN Irreg_Count=1;
RUN;

PROC SQL;
CREATE TABLE work.qua427_avg AS
SELECT 	a.Company, Sal_Ord_nr, Sal_Ord_pos,
		SUM(a.Irreg_count)		AS Irreg_Count
FROM work.qua427 a
GROUP BY a.Company, Sal_Ord_nr, Sal_Ord_pos
ORDER BY a.Company, Sal_Ord_nr, Sal_Ord_pos;
QUIT;

/**********************************************************************/
/****    Collecting Irregs by SalesOrder   		   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.qua401 as select * from connection to baan
   (SELECT  'Roe'			AS Company,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos,
			b.t_wrka		AS WorkArea,
			Count(b.t_irre)	AS Irreg_Count
FROM 			ttdqua400120 a,	ttdqua401120 b
WHERE  a.t_irre=b.t_irre 
GROUP BY a.t_sorn, a.t_spon, b.t_wrka
UNION ALL
   SELECT  'Cor'			AS Company,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos,
			b.t_wrka		AS WorkArea,
			Count(b.t_irre)	AS Irreg_Count
FROM 			ttdqua400200 a,	ttdqua401200 b
WHERE  a.t_irre=b.t_irre
GROUP BY a.t_sorn, a.t_spon, b.t_wrka
UNION ALL
   SELECT  'ECP'			AS Company,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos,
			b.t_wrka		AS WorkArea,
			Count(b.t_irre)	AS Irreg_Count
FROM 			ttdqua400130 a,	ttdqua401130 b
WHERE  a.t_irre=b.t_irre
GROUP BY a.t_sorn, a.t_spon, b.t_wrka 
UNION ALL
   SELECT  'EAP'			AS Company,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos,
			b.t_wrka		AS WorkArea,
			Count(b.t_irre)	AS Irreg_Count
FROM 			ttdqua400300 a,	ttdqua401300 b
WHERE  a.t_irre=b.t_irre
GROUP BY a.t_sorn, a.t_spon, b.t_wrka  );
 DISCONNECT from baan;
QUIT;

PROC SORT DATA=work.qua401; BY Company Sal_ord_nr Sal_ord_pos WorkArea; RUN;
PROC TRANSPOSE DATA= work.qua401 OUT=work.qua401_trans  (drop=_NAME_ _LABEL_);
BY  Company Sal_ord_nr Sal_ord_pos ;
   VAR Irreg_Count;
    ID WorkArea;
RUN;

DATA work.qua401_trans (KEEP=Company Sal_ord_nr Sal_ord_pos Irreg_Ref); SET work.qua401_trans ;
FORMAT Irreg_Ref $30.;
IF MUT=. THEN MUT=0; IF MAD=. THEN MAD=0; IF PDD=. THEN PDD=0; IF SUB=. THEN SUB=0;
Irreg_Ref="MUT:"||PUT(MUT,2.0)||"/MAD:"||PUT(MAD,2.0)||"/PDD:"||PUT(PDD,2.0)||"/SUB:"||PUT(SUB,2.0);
WHERE (MUT)>0 OR (MAD)>0 OR (PDD)>0 OR (SUB)>0 ;
RUN;

/*****  Check on PDD after MAD		*****/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.qua401 as select * from connection to baan
   (SELECT  'Roe'			AS Company,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos,
			b.t_irre		AS Irreg_nr,
			b.t_irpo		AS Irreg_pos,
			b.t_wrka		AS WorkArea
FROM 			ttdqua400120 a,	ttdqua401120 b
WHERE  a.t_irre=b.t_irre AND b.t_wrka IN ('MAD','PDD')
UNION ALL
   SELECT  'Cor'			AS Company,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos,
			b.t_irre		AS Irreg_nr,
			b.t_irpo		AS Irreg_pos,
			b.t_wrka		AS WorkArea
FROM 			ttdqua400200 a,	ttdqua401200 b
WHERE  a.t_irre=b.t_irre AND b.t_wrka IN ('MAD','PDD')
UNION ALL
   SELECT  'ECP'			AS Company,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos,
			b.t_irre		AS Irreg_nr,
			b.t_irpo		AS Irreg_pos,
			b.t_wrka		AS WorkArea
FROM 			ttdqua400130 a,	ttdqua401130 b
WHERE  a.t_irre=b.t_irre AND b.t_wrka IN ('MAD','PDD') 
UNION ALL
   SELECT  'EAP'			AS Company,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos,
			b.t_irre		AS Irreg_nr,
			b.t_irpo		AS Irreg_pos,
			b.t_wrka		AS WorkArea
FROM 			ttdqua400300 a,	ttdqua401300 b
WHERE  a.t_irre=b.t_irre AND b.t_wrka IN ('MAD','PDD')  );
 DISCONNECT from baan;
QUIT;
PROC SORT DATA=work.qua401; BY Company Sal_ord_nr Sal_ord_pos Irreg_nr Irreg_pos; RUN;

DATA work.qua401; SET work.qua401; 
BY Company Sal_ord_nr Sal_ord_pos Irreg_nr Irreg_pos;
RETAIN WorkArea_R;
IF FIRST.Irreg_nr 											THEN WorkArea_R=WorkArea;
IF LAST.Irreg_nr AND WorkArea='PDD' AND WorkArea_R='MAD' 	THEN MAD_PDD_Check='Y';
IF MAD_PDD_Check NE 'Y' 									THEN DELETE; 
RUN;

PROC SQL;
CREATE TABLE work.qua401_trans AS
SELECT 	a.*, b.MAD_PDD_Check
FROM work.qua401_trans a LEFT OUTER JOIN work.qua401 b ON a.Company=b.Company AND a.Sal_ord_nr=b.Sal_ord_nr AND a.Sal_ord_pos=b.Sal_ord_pos;
QUIT;

/**********************************************************************/
/****    Collecting Last Delivery Shipment Comp 		   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.shp121 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_leno    Idno,
			a.t_sorn	Sal_Ord_nr,
			a.t_spon	Sal_Ord_pos,
			b.t_shpm	Shipment,
			c.t_rono	Trip_nr,
			d.t_lodt	Load_date,
			c.t_uldt	Unload_date,
			c.t_obdt	Onboard_date,
			c.t_cdec	Shipm_Del_Cond
FROM 			ttdshp121120 a,
				ttdshp120120 b,
				ttdshp130120 c,
				ttdshp100120 d
WHERE 		a.t_part = b.t_part AND
			b.t_shpm = c.t_shpm AND
			c.t_rono = d.t_rono AND  b.t_stat>11  
UNION ALL
    SELECT  'Cor'		AS Company,
			a.t_leno    Idno,
			a.t_sorn	Sal_Ord_nr,
			a.t_spon	Sal_Ord_pos,
			b.t_shpm	Shipment,
			c.t_rono	Trip_nr,
			d.t_lodt	Load_date,
			c.t_uldt	Unload_date,
			c.t_obdt	Onboard_date,
			c.t_cdec	Shipm_Del_Cond
FROM 			ttdshp121200 a,
				ttdshp120200 b,
				ttdshp130200 c,
				ttdshp100200 d
WHERE 		a.t_part = b.t_part AND
			b.t_shpm = c.t_shpm AND
			c.t_rono = d.t_rono AND  b.t_stat>11
UNION ALL
    SELECT  'ECP'		AS Company,
			a.t_leno    Idno,
			a.t_sorn	Sal_Ord_nr,
			a.t_spon	Sal_Ord_pos,
			b.t_shpm	Shipment,
			c.t_rono	Trip_nr,
			d.t_lodt	Load_date,
			c.t_uldt	Unload_date,
			c.t_obdt	Onboard_date,
			c.t_cdec	Shipm_Del_Cond
FROM 			ttdshp121130 a,
				ttdshp120130 b,
				ttdshp130130 c,
				ttdshp100130 d
WHERE 		a.t_part = b.t_part AND
			b.t_shpm = c.t_shpm AND
			c.t_rono = d.t_rono AND  b.t_stat>11
UNION ALL
    SELECT  'EAP'		AS Company,
			a.t_leno    Idno,
			a.t_sorn	Sal_Ord_nr,
			a.t_spon	Sal_Ord_pos,
			b.t_shpm	Shipment,
			c.t_rono	Trip_nr,
			d.t_lodt	Load_date,
			c.t_uldt	Unload_date,
			c.t_obdt	Onboard_date,
			c.t_cdec	Shipm_Del_Cond
FROM 			ttdshp121300 a,
				ttdshp120300 b,
				ttdshp130300 c,
				ttdshp100300 d
WHERE 		a.t_part = b.t_part AND
			b.t_shpm = c.t_shpm AND
			c.t_rono = d.t_rono AND  b.t_stat>11  );
QUIT;

PROC SQL;
CREATE TABLE work.Shipm AS
SELECT 	a.Company,
		a.Sal_ord_nr,
		a.Sal_ord_pos,
		MAX(a.Load_date) 		AS Shipm_Last_Load_Date			FORMAT Date9.,							/* PW 03-07-2020  */
		MIN(a.Load_date) 		AS Shipm_First_Load_Date		FORMAT Date9.,
		MAX(a.Onboard_date)		AS Shipm_Last_OnBoard_Date		FORMAT Date9.,
		MAX(a.Unload_Date)		AS Shipm_Last_UnLoad_Date		FORMAT Date9.
FROM work.shp121 a
GROUP BY a.Company, a.Sal_ord_nr, a.Sal_ord_pos
ORDER BY a.Company, a.Sal_ord_nr, a.Sal_ord_pos;
QUIT;
		
DATA work.Shipm; SET work.Shipm;
IF Shipm_Last_OnBoard_Date=. THEN Shipm_Last_OnBoard_Date=MDY(01,01,2000);
RUN;

/*******************************************************************************/
/****    Collect WO_Prep info from DMS						                ****/
/*******************************************************************************/
/*
PROC SQL; 
connect to odbc(dsn='DMS' user=readonlyuser password=Welkom01 ); 
CREATE table work.WV_Card_DMS as select * from connection to odbc 
(select * from openims_salesorders_document_data
 order by doc_id); 
disconnect from odbc; 
QUIT;

DATA work.DMS (Keep=Company Sal_Ord_nr DMS_Inp_Date DMS_Sales_Ord_Receipt_Date DMS_Sales_Ord_Receipt_Time DMS_Sales_Ord_Creation_Date DMS_Sales_Ord_Creation_Time) ; 
SET work.WV_Card_DMS;
Sal_ord_nr=INPUT(SUBSTR(ordernumber,1,6),6.0);
IF productionplant_vis='Roermond' THEN Company='Roe'; ELSE Company='Cor';
FORMAT DMS_Sales_Ord_Receipt_Date  Date9.; DMS_Sales_Ord_Receipt_Date=MDY(substr(Date_incoming_iso,6,2),substr(Date_incoming_iso,9,2),substr(Date_incoming_iso,1,4));
FORMAT DMS_Sales_Ord_Receipt_Time  Time8.; DMS_Sales_Ord_Receipt_Time=HMS(substr(Date_incoming_iso,12,2),substr(Date_incoming_iso,15,2),substr(Date_incoming_iso,18,2));
FORMAT DMS_Sales_Ord_Creation_Date Date9.; DMS_Sales_Ord_Creation_Date=MDY(substr(Creationdate_iso,6,2),substr(Creationdate_iso,9,2),substr(Creationdate_iso,1,4));
FORMAT DMS_Sales_Ord_Creation_Time Time8.; DMS_Sales_Ord_Creation_Time=HMS(substr(Creationdate_iso,12,2),substr(Creationdate_iso,15,2),substr(Creationdate_iso,18,2));
RUN;

PROC SORT data=work.DMS nodups;
BY Company Sal_Ord_nr;
WHERE Sal_ord_nr>100000;
RUN;

DATA work.DMS; SET work.DMS; BY Company Sal_Ord_nr; IF NOT first.Sal_ord_nr THEN DELETE; RUN;  */

/**********************************************************************/
/****    Collecting SLS041 table       			   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.sls041 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_cuno	Cust_nr,
			b.t_cotp	Sal_Ord_Type,
			b.t_cdec	Sal_Ord_term_del,
			b.t_cdel	Sal_Ord_Del_Addr,
			b.t_crte	Sal_Ord_Route,
			a.t_cdel	Sal_Ord_pos_Del_Addr,
			a.t_ccty	Sal_Ord_Country,
			a.t_item	Item_nr,
			a.t_dset_c	Dimset,
			a.t_acun_c	Sal_ord_pos_ord_Unit,
			a.t_oqua	Sal_Ord_Pos_Quan,
			a.t_dqua	Sal_Ord_Pos_Del_Quan,
			a.t_bqua	Sal_ord_pos_Back_Quan,
			a.t_odat	Sal_Ord_pos_Order_date,
			a.t_prdt	Sal_Ord_Org_Plan_Del_date,
			a.t_ddta	Sal_Ord_Org_Prod_Compl_date,
			a.t_eseq	Sal_Ord_Pos_Org_conf_del_dateT
FROM 			ttdsls041120 a, ttdsls040120 b
WHERE 	a.t_odat>MDY(11,01,2018) AND a.t_orno=b.t_orno );

CREATE table work.sls051 as select * from connection to baan
   (SELECT  'Roe'			AS Company,
			a.t_orno 		AS Sal_Ord_nr,
			a.t_pono		AS Sal_Ord_pos,
			MAX(a.t_trdt)	AS	Sal_ord_Pos_Last_Hist_Mut_Date
FROM 			ttdsls051120 a
GROUP BY a.t_orno, a.t_pono);

CREATE table work.sls041_cust as select * from connection to baan
   (SELECT  'Roe'			AS Company,
			a.t_cuno		Cust_nr,
			count(a.t_pono)	AS Sal_ord_pos_L3Y
FROM 			ttdsls041120 a, ttdsls040120 b
WHERE 	a.t_odat>MDY(Month(current),Day(current),YEAR(current)-3) AND a.t_orno=b.t_orno AND a.t_dqua>0
GROUP BY a.t_cuno);

CREATE TABLE work.com013 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_cuno	Cust_nr,
			a.t_cdel	Cust_Del_Addr,
			a.t_ccty	Cust_Del_Addr_Country
FROM 			ttccom013120 a							);

CREATE table work.lra030 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_orno   	Sal_Ord_nr,
   			a.t_pono   	Sal_Ord_pos,
			sum(a.t_oqua_1) AS	Sal_Ord_pos_pcs,
			sum(a.t_dqua_1) AS	Sal_ord_pos_del_pcs,
			sum(a.t_aqan_1) AS	Sal_Ord_Pos_org_ord_pcs,
			sum(a.t_aqan_2) AS	Sal_Ord_Pos_org_ord_quan
   FROM         ttdlra030120 a
   WHERE 	a.t_koor=3
   GROUP BY a.t_orno, a.t_pono  );

CREATE table work.mdm112 as select * from connection to baan
	(SELECT 'Roe'		AS Company,
			a.t_orno  	Sal_ord_nr,
			a.t_pono	Sal_ord_pos,
			a.t_pval	Sal_Ord_pos_Order_tol
	FROM	ttdmdm112120 a
	WHERE t_spec IN ('001220') AND t_koor=3 );

CREATE table work.mdm112_ol as select * from connection to baan
	(SELECT 'Roe'		AS Company,
			a.t_orno  	Sal_ord_nr,
			a.t_pono	Sal_ord_pos,
			a.t_pval	Sal_Ord_pos_Min_ord_mT
	FROM	ttdmdm112120 a
	WHERE t_spec IN ('090030') AND t_koor=3 );
 DISCONNECT from baan;
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.sls041_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_cuno	Cust_nr,
			b.t_cotp	Sal_Ord_Type,
			b.t_cdec	Sal_Ord_term_del,
			b.t_cdel	Sal_Ord_Del_Addr,
			b.t_crte	Sal_Ord_Route,
			a.t_cdel	Sal_Ord_pos_Del_Addr,
			a.t_ccty	Sal_Ord_Country,
			a.t_item	Item_nr,
			a.t_dset_c	Dimset,
			a.t_acun_c	Sal_ord_pos_ord_Unit,
			a.t_oqua	Sal_Ord_Pos_Quan,
			a.t_dqua	Sal_Ord_Pos_Del_Quan,
			a.t_bqua	Sal_ord_pos_Back_Quan,
			a.t_odat	Sal_Ord_pos_Order_date,
			a.t_prdt	Sal_Ord_Org_Plan_Del_date,
			a.t_ddta	Sal_Ord_Org_Prod_Compl_date,
			a.t_eseq	Sal_Ord_Pos_Org_conf_del_dateT
FROM 			ttdsls041130 a, ttdsls040130 b
WHERE 	a.t_odat>MDY(11,01,2018) AND a.t_orno=b.t_orno );

CREATE table work.sls051_ECP as select * from connection to baan
   (SELECT  'ECP'			AS Company,
			a.t_orno 		AS Sal_Ord_nr,
			a.t_pono		AS Sal_Ord_pos,
			MAX(a.t_trdt)	AS	Sal_ord_Pos_Last_Hist_Mut_Date
FROM 			ttdsls051130 a
GROUP BY a.t_orno, a.t_pono);

CREATE table work.sls041_cust_ECP as select * from connection to baan
   (SELECT  'ECP'				AS Company,
			a.t_cuno	Cust_nr,
			count(a.t_pono)		AS Sal_ord_pos_L3Y
FROM 			ttdsls041130 a, ttdsls040130 b
WHERE 	a.t_odat>MDY(Month(current),Day(current),YEAR(current)-3) AND a.t_orno=b.t_orno AND a.t_dqua>0
GROUP BY a.t_cuno);

CREATE TABLE work.com013_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_cuno	Cust_nr,
			a.t_cdel	Cust_Del_Addr,
			a.t_ccty	Cust_Del_Addr_Country
FROM 			ttccom013130 a							);

CREATE table work.lra030_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_orno   	Sal_Ord_nr,
   			a.t_pono   	Sal_Ord_pos,
			sum(a.t_oqua_1) AS	Sal_Ord_pos_pcs,
			sum(a.t_dqua_1) AS	Sal_ord_pos_del_pcs,
			sum(a.t_aqan_1) AS	Sal_Ord_Pos_org_ord_pcs,
			sum(a.t_aqan_2) AS	Sal_Ord_Pos_org_ord_quan
   FROM         ttdlra030130 a
   WHERE 	a.t_koor=3
   GROUP BY a.t_orno, a.t_pono  );

CREATE table work.mdm112_ECP as select * from connection to baan
	(SELECT 'ECP'		AS Company,
			a.t_orno  	Sal_ord_nr,
			a.t_pono	Sal_ord_pos,
			a.t_pval	Sal_Ord_pos_Order_tol
	FROM	ttdmdm112130 a
	WHERE t_spec IN ('001220') AND t_koor=3 );

CREATE table work.mdm112_ol_ECP as select * from connection to baan
	(SELECT 'ECP'		AS Company,
			a.t_orno  	Sal_ord_nr,
			a.t_pono	Sal_ord_pos,
			a.t_pval	Sal_Ord_pos_Min_ord_mT
	FROM	ttdmdm112130 a
	WHERE t_spec IN ('090030') AND t_koor=3 );
 DISCONNECT from baan;
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.sls041_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_cuno	Cust_nr,
			b.t_cotp	Sal_Ord_Type,
			b.t_cdec	Sal_Ord_term_del,
			b.t_cdel	Sal_Ord_Del_Addr,
			b.t_crte	Sal_Ord_Route,
			a.t_cdel	Sal_Ord_pos_Del_Addr,
			a.t_ccty	Sal_Ord_Country,
			a.t_item	Item_nr,
			a.t_dset_c	Dimset,
			a.t_acun_c	Sal_ord_pos_ord_Unit,
			a.t_oqua	Sal_Ord_Pos_Quan,
			a.t_dqua	Sal_Ord_Pos_Del_Quan,
			a.t_bqua	Sal_ord_pos_Back_Quan,
			a.t_odat	Sal_Ord_pos_Order_date,
			a.t_prdt	Sal_Ord_Org_Plan_Del_date,
			a.t_ddta	Sal_Ord_Org_Prod_Compl_date,
			a.t_eseq	Sal_Ord_Pos_Org_conf_del_dateT
FROM 			ttdsls041300 a, ttdsls040300 b
WHERE 	a.t_odat>MDY(11,01,2018) AND a.t_orno=b.t_orno );

CREATE table work.sls051_EAP as select * from connection to baan
   (SELECT  'EAP'			AS Company,
			a.t_orno 		AS Sal_Ord_nr,
			a.t_pono		AS Sal_Ord_pos,
			MAX(a.t_trdt)	AS	Sal_ord_Pos_Last_Hist_Mut_Date
FROM 			ttdsls051300 a
GROUP BY a.t_orno, a.t_pono);

CREATE table work.sls041_cust_EAP as select * from connection to baan
   (SELECT  'EAP'					AS Company,
			a.t_cuno	Cust_nr,
			count(a.t_pono)			AS Sal_ord_pos_L3Y
FROM 			ttdsls041300 a, ttdsls040300 b
WHERE 	a.t_odat>MDY(Month(current),Day(current),YEAR(current)-3) AND a.t_orno=b.t_orno AND a.t_dqua>0
GROUP BY a.t_cuno);

CREATE TABLE work.com013_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_cuno	Cust_nr,
			a.t_cdel	Cust_Del_Addr,
			a.t_ccty	Cust_Del_Addr_Country
FROM 			ttccom013300 a							);

CREATE table work.lra030_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_orno   	Sal_Ord_nr,
   			a.t_pono   	Sal_Ord_pos,
			sum(a.t_oqua_1) AS	Sal_Ord_pos_pcs,
			sum(a.t_dqua_1) AS	Sal_ord_pos_del_pcs,
			sum(a.t_aqan_1) AS	Sal_Ord_Pos_org_ord_pcs,
			sum(a.t_aqan_2) AS	Sal_Ord_Pos_org_ord_quan
   FROM         ttdlra030300 a
   WHERE 	a.t_koor=3
   GROUP BY a.t_orno, a.t_pono  );

CREATE table work.mdm112_EAP as select * from connection to baan
	(SELECT 'EAP'		AS Company,
			a.t_orno  	Sal_ord_nr,
			a.t_pono	Sal_ord_pos,
			a.t_pval	Sal_Ord_pos_Order_tol
	FROM	ttdmdm112300 a
	WHERE t_spec IN ('001220') AND t_koor=3 );

CREATE table work.mdm112_ol_EAP as select * from connection to baan
	(SELECT 'EAP'		AS Company,
			a.t_orno  	Sal_ord_nr,
			a.t_pono	Sal_ord_pos,
			a.t_pval	Sal_Ord_pos_Min_ord_mT
	FROM	ttdmdm112300 a
	WHERE t_spec IN ('090030') AND t_koor=3 );
 DISCONNECT from baan;
QUIT;


PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.sls041_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_orno 	Sal_Ord_nr,
			a.t_pono	Sal_Ord_pos,
			a.t_cuno	Cust_nr,
			b.t_cotp	Sal_Ord_Type,
			b.t_cdec	Sal_Ord_term_del,
			b.t_cdel	Sal_Ord_Del_Addr,
			b.t_crte	Sal_Ord_Route,
			a.t_cdel	Sal_Ord_pos_Del_Addr,
			a.t_ccty	Sal_Ord_Country,
			a.t_item	Item_nr,
			a.t_dset_c	Dimset,
			a.t_acun_c	Sal_ord_pos_ord_Unit,
			a.t_oqua	Sal_Ord_Pos_Quan,
			a.t_dqua	Sal_Ord_Pos_Del_Quan,
			a.t_bqua	Sal_ord_pos_Back_Quan,
			a.t_odat	Sal_Ord_pos_Order_date,
			a.t_prdt	Sal_Ord_Org_Plan_Del_date,
			a.t_ddta	Sal_Ord_Org_Prod_Compl_date,
			a.t_eseq	Sal_Ord_Pos_Org_conf_del_dateT
FROM 			ttdsls041200 a, ttdsls040200 b
WHERE 	a.t_odat>MDY(11,01,2018) AND a.t_orno=b.t_orno );

CREATE table work.sls051_Cor as select * from connection to baan
   (SELECT  'Cor'			AS Company,
			a.t_orno 		AS Sal_Ord_nr,
			a.t_pono		AS Sal_Ord_pos,
			MAX(a.t_trdt)	AS	Sal_ord_Pos_Last_Hist_Mut_Date
FROM 			ttdsls051200 a
GROUP BY a.t_orno, a.t_pono);

CREATE table work.sls041_cust_Cor as select * from connection to baan
   (SELECT  'Cor'					AS Company,
			a.t_cuno	Cust_nr,
			count(a.t_pono)			AS Sal_ord_pos_L3Y
FROM 			ttdsls041200 a, ttdsls040200 b
WHERE 	a.t_odat>MDY(Month(current),Day(current),YEAR(current)-3) AND a.t_orno=b.t_orno AND a.t_dqua>0
GROUP BY a.t_cuno);

CREATE TABLE work.com013_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_cuno	Cust_nr,
			a.t_cdel	Cust_Del_Addr,
			a.t_ccty	Cust_Del_Addr_Country
FROM 			ttccom013200 a							);

CREATE table work.lra030_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_orno   	Sal_Ord_nr,
   			a.t_pono   	Sal_Ord_pos,
			sum(a.t_oqua_1) AS	Sal_Ord_pos_pcs,
			sum(a.t_dqua_1) AS	Sal_ord_pos_del_pcs,
			sum(a.t_aqan_1) AS	Sal_Ord_Pos_org_ord_pcs,
			sum(a.t_aqan_2) AS	Sal_Ord_Pos_org_ord_quan
   FROM         ttdlra030200 a
   WHERE 	a.t_koor=3
   GROUP BY a.t_orno, a.t_pono  );

CREATE table work.mdm112_Cor as select * from connection to baan
	(SELECT 'Cor'		AS Company,
			a.t_orno  	Sal_ord_nr,
			a.t_pono	Sal_ord_pos,
			a.t_pval	Sal_Ord_pos_Order_tol
	FROM	ttdmdm112200 a
	WHERE t_spec IN ('001220') AND t_koor=3 );

CREATE table work.mdm112_ol_Cor as select * from connection to baan
	(SELECT 'Cor'		AS Company,
			a.t_orno  	Sal_ord_nr,
			a.t_pono	Sal_ord_pos,
			a.t_pval	Sal_Ord_pos_Min_ord_mT
	FROM	ttdmdm112200 a
	WHERE t_spec IN ('090030') AND t_koor=3 );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.sls041 		DATA=work.sls041_ECP; 		RUN;
PROC APPEND BASE=work.sls041 		DATA=work.sls041_EAP; 		RUN;
PROC APPEND BASE=work.sls041 		DATA=work.sls041_Cor; 		RUN;

PROC APPEND BASE=work.sls051 		DATA=work.sls051_ECP; 		RUN;
PROC APPEND BASE=work.sls051 		DATA=work.sls051_EAP; 		RUN;
PROC APPEND BASE=work.sls051 		DATA=work.sls051_Cor; 		RUN;

PROC APPEND BASE=work.sls041_cust 	DATA=work.sls041_cust_ECP; 	RUN;
PROC APPEND BASE=work.sls041_cust 	DATA=work.sls041_cust_EAP; 	RUN;
PROC APPEND BASE=work.sls041_cust 	DATA=work.sls041_cust_Cor; 	RUN;

PROC APPEND BASE=work.com013 		DATA=work.com013_ECP; 		RUN;
PROC APPEND BASE=work.com013 		DATA=work.com013_EAP; 		RUN;
PROC APPEND BASE=work.com013 		DATA=work.com013_Cor; 		RUN;

PROC APPEND BASE=work.lra030 		DATA=work.lra030_ECP; 		RUN;
PROC APPEND BASE=work.lra030 		DATA=work.lra030_EAP; 		RUN;
PROC APPEND BASE=work.lra030 		DATA=work.lra030_Cor; 		RUN;

PROC APPEND BASE=work.mdm112 		DATA=work.mdm112_ECP;	 	RUN;
PROC APPEND BASE=work.mdm112 		DATA=work.mdm112_EAP; 		RUN;
PROC APPEND BASE=work.mdm112 		DATA=work.mdm112_Cor; 		RUN;

PROC APPEND BASE=work.mdm112_ol 	DATA=work.mdm112_ol_ECP; 	RUN;
PROC APPEND BASE=work.mdm112_ol 	DATA=work.mdm112_ol_EAP; 	RUN;
PROC APPEND BASE=work.mdm112_ol 	DATA=work.mdm112_ol_Cor; 	RUN;

PROC SORT DATA=work.mdm112 nodups; BY Company Sal_ord_nr Sal_ord_pos Sal_Ord_pos_Order_tol; 										RUN;
DATA work.mdm112; SET work.mdm112; BY Company Sal_ord_nr Sal_ord_pos Sal_Ord_pos_Order_tol; IF NOT first.Sal_ord_pos THEN DELETE; 	RUN;

PROC SORT DATA=work.mdm112_ol nodups; 		BY Company Sal_ord_nr Sal_ord_pos; 											RUN;
DATA work.mdm112_ol; SET work.mdm112_ol; 	BY Company Sal_ord_nr Sal_ord_pos; IF NOT first.Sal_ord_pos THEN DELETE;	RUN;

DATA work.sls041  (DROP=Sal_ord_pos_Del_addr Sal_Ord_Pos_Org_conf_del_dateT); SET work.sls041;
IF Sal_ord_pos_Del_Addr NE "" THEN Sal_ord_Del_Addr=Sal_ord_pos_Del_Addr;
FORMAT Sal_Ord_Pos_Org_conf_del_date Date9.;
Sal_Ord_Pos_Org_conf_del_date=MDY(substr(Sal_Ord_Pos_Org_conf_del_dateT,6,2),substr(Sal_Ord_Pos_Org_conf_del_dateT,9,2),substr(Sal_Ord_Pos_Org_conf_del_dateT,1,4));
RUN;

PROC SQL;
CREATE TABLE work.sls041 AS
SELECT 	a.*,
		b.Cust_del_addr_Country,
		c.Sal_Ord_pos_Order_tol,
		d.Sal_Ord_Pos_org_ord_pcs,
		d.Sal_Ord_Pos_org_ord_quan,
		e.Sal_Ord_pos_Min_ord_mT,
		f.Irreg_ref,
		f.MAD_PDD_Check,
		g.Sal_ord_pos_L3Y,
		h.Sal_ord_Pos_Last_Hist_Mut_Date
FROM work.sls041 a 	LEFT OUTER JOIN work.com013 b 		ON a.Company=b.Company AND a.Cust_nr=b.Cust_nr 			AND a.Sal_ord_Del_Addr=b.Cust_Del_Addr
					LEFT OUTER JOIN work.mdm112 c 		ON a.Company=c.Company AND a.Sal_ord_nr=c.Sal_ord_nr 	AND a.Sal_ord_pos=c.Sal_ord_pos  
					LEFT OUTER JOIN work.lra030 d 		ON a.Company=d.Company AND a.Sal_ord_nr=d.Sal_ord_nr 	AND a.Sal_ord_pos=d.Sal_ord_pos 
					LEFT OUTER JOIN work.mdm112_ol e 	ON a.Company=e.Company AND a.Sal_ord_nr=e.Sal_ord_nr 	AND a.Sal_ord_pos=e.Sal_ord_pos 
					LEFT OUTER JOIN work.qua401_trans f	ON a.Company=f.Company AND a.Sal_ord_nr=f.Sal_ord_nr 	AND a.Sal_ord_pos=f.Sal_ord_pos 
					LEFT OUTER JOIN work.sls041_cust g 	ON a.Company=g.Company AND a.Cust_nr=g.Cust_nr
					LEFT OUTER JOIN work.sls051 h		ON a.Company=h.Company AND a.Sal_ord_nr=h.Sal_ord_nr 	AND a.Sal_ord_pos=h.Sal_ord_pos  				;
QUIT;
/*	LEFT OUTER JOIN work.DMS i  		ON a.Company=i.Company AND a.Sal_ord_nr=i.Sal_ord_nr   */

PROC SORT DATA=work.sls041; BY Company Sal_ord_nr Sal_ord_pos; RUN;

DATA work.sls041  (DROP=Sal_ord_country Order_tol Sal_Ord_pos_Min_ord_mT check); SET work.sls041;
BY Company Sal_ord_nr Sal_ord_pos;
IF Cust_del_addr_Country EQ "" 				THEN Cust_del_addr_Country=Sal_ord_country;
Sal_Ord_pos_Min_ord_m=INPUT(TRIM(Sal_Ord_pos_Min_ord_mT),11.0);
IF Sal_Ord_pos_Min_ord_m=. 					THEN Sal_Ord_pos_Min_ord_m=0;
IF Sal_Ord_pos_Order_tol="" 				THEN Sal_Ord_pos_Order_tol='-0 /+0';
Order_tol=translate(Sal_Ord_pos_Order_tol,"  ","MTR+%");
check=index(order_tol,"/");
IF Check>0 									THEN Sal_ord_pos_ordtol_min=input(substr(order_tol,1,check-1),6.0);
IF Check>0 									THEN Sal_ord_pos_ordtol_max=input(substr(order_tol,check+1,length(order_tol)-check),6.0);
IF order_tol=' 0/-2' 						THEN DO; Sal_ord_pos_ordtol_min=-2; Sal_ord_pos_ordtol_max=0; END;
Sal_ord_pos_ordtol_Unit='%  ';
IF Sal_ord_pos_ord_Unit IN ('stk','pcs') 	THEN Sal_ord_pos_ordtol_Unit='pcs';
IF index(Sal_Ord_pos_Order_tol,"MTR")>0 	THEN Sal_ord_pos_ordtol_Unit='m';
DMS_Inp_Date=MDY(01,01,2000); DMS_Sales_Ord_Receipt_Date=MDY(01,01,2000); DMS_Sales_Ord_Receipt_Time=MDY(01,01,2000); DMS_Sales_Ord_Creation_Date=MDY(01,01,2000); DMS_Sales_Ord_Creation_Time=MDY(01,01,2000);   /* coreection DB2 table */
RUN;

/*****************************************************************************************/
/*****  SalesOrder Delivery data													******/
/*****************************************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.Sal_Idno as select * from connection to baan
   (SELECT  'Roe'			AS Company,
			a.t_leno		AS Idno,
			a.t_dset		AS Dimset,
			a.t_orno		AS Sal_ord_nr,
			a.t_pono		AS Sal_ord_pos,
			a.t_dqua_1		AS Del_pcs,
			a.t_dqua_2		AS Del_Kg,
			b.t_aval		AS Spec_gravT,
			c.t_aval		AS WidthT,
			d.t_aval		AS ThicknessT,
			e.t_aval		AS CPS,
			f.t_stoc_2		AS Idno_Stock
    FROM        ttdlra011120 a 	LEFT OUTER JOIN ttdlra230120 b ON a.t_leno=b.t_leno AND b.t_spec='000010'
								LEFT OUTER JOIN ttdlra230120 c ON a.t_leno=c.t_leno AND c.t_spec='001000'
								LEFT OUTER JOIN ttdlra230120 d ON a.t_leno=d.t_leno AND d.t_spec='001010'
								LEFT OUTER JOIN ttdlra230120 e ON a.t_leno=e.t_leno AND e.t_spec='100100'
								LEFT OUTER JOIN ttdlra017120 f ON a.t_leno=f.t_leno 
WHERE a.t_koor=3  
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.Sal_Idno_ECP as select * from connection to baan
   (SELECT  'ECP'			AS Company,
			a.t_leno		AS Idno,
			a.t_dset		AS Dimset,
			a.t_orno		AS Sal_ord_nr,
			a.t_pono		AS Sal_ord_pos,
			a.t_dqua_1		AS Del_pcs,
			a.t_dqua_2		AS Del_Kg,
			b.t_aval		AS Spec_gravT,
			c.t_aval		AS WidthT,
			d.t_aval		AS ThicknessT,
			e.t_aval		AS CPS,
			f.t_stoc_2		AS Idno_Stock
    FROM        ttdlra011130 a 	LEFT OUTER JOIN ttdlra230130 b ON a.t_leno=b.t_leno AND b.t_spec='000010'
								LEFT OUTER JOIN ttdlra230130 c ON a.t_leno=c.t_leno AND c.t_spec='001000'
								LEFT OUTER JOIN ttdlra230130 d ON a.t_leno=d.t_leno AND d.t_spec='001010'
								LEFT OUTER JOIN ttdlra230130 e ON a.t_leno=e.t_leno AND e.t_spec='100100'
								LEFT OUTER JOIN ttdlra017130 f ON a.t_leno=f.t_leno 
WHERE a.t_koor=3  
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.Sal_Idno_EAP as select * from connection to baan
   (SELECT  'EAP'			AS Company,
			a.t_leno		AS Idno,
			a.t_dset		AS Dimset,
			a.t_orno		AS Sal_ord_nr,
			a.t_pono		AS Sal_ord_pos,
			a.t_dqua_1		AS Del_pcs,
			a.t_dqua_2		AS Del_Kg,
			b.t_aval		AS Spec_gravT,
			c.t_aval		AS WidthT,
			d.t_aval		AS ThicknessT,
			e.t_aval		AS CPS,
			f.t_stoc_2		AS Idno_Stock
    FROM        ttdlra011300 a 	LEFT OUTER JOIN ttdlra230300 b ON a.t_leno=b.t_leno AND b.t_spec='000010'
								LEFT OUTER JOIN ttdlra230300 c ON a.t_leno=c.t_leno AND c.t_spec='001000'
								LEFT OUTER JOIN ttdlra230300 d ON a.t_leno=d.t_leno AND d.t_spec='001010'
								LEFT OUTER JOIN ttdlra230300 e ON a.t_leno=e.t_leno AND e.t_spec='100100'
								LEFT OUTER JOIN ttdlra017300 f ON a.t_leno=f.t_leno 
WHERE a.t_koor=3  
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.Sal_Idno_Cor as select * from connection to baan
   (SELECT  'Cor'			AS Company,
			a.t_leno		AS Idno,
			a.t_dset		AS Dimset,
			a.t_orno		AS Sal_ord_nr,
			a.t_pono		AS Sal_ord_pos,
			a.t_dqua_1		AS Del_pcs,
			a.t_dqua_2		AS Del_Kg,
			b.t_aval		AS Spec_gravT,
			c.t_aval		AS WidthT,
			d.t_aval		AS ThicknessT,
			e.t_aval		AS CPS,
			f.t_stoc_2		AS Idno_Stock
    FROM        ttdlra011200 a 	LEFT OUTER JOIN ttdlra230200 b ON a.t_leno=b.t_leno AND b.t_spec='000010'
								LEFT OUTER JOIN ttdlra230200 c ON a.t_leno=c.t_leno AND c.t_spec='001000'
								LEFT OUTER JOIN ttdlra230200 d ON a.t_leno=d.t_leno AND d.t_spec='001010'
								LEFT OUTER JOIN ttdlra230200 e ON a.t_leno=e.t_leno AND e.t_spec='100100'
								LEFT OUTER JOIN ttdlra017200 f ON a.t_leno=f.t_leno 
WHERE a.t_koor=3  
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;

PROC APPEND base=work.Sal_Idno data=work.Sal_Idno_ECP; RUN;
PROC APPEND base=work.Sal_Idno data=work.Sal_Idno_EAP; RUN;
PROC APPEND base=work.Sal_Idno data=work.Sal_Idno_Cor; RUN;

DATA work.Sal_Idno (DROP=WidthT Spec_GravT ThicknessT); SET work.Sal_Idno;
Width=Input(WidthT,11.0); Spec_Grav=Input(Spec_GravT,11.0); Thickness=Input(ThicknessT,11.2);
IF Dimset ne '-' 						THEN Del_m=INT(Del_Kg/spec_grav/width/thickness*1000000000) ; ELSE Del_m=0;
Del_m2=ROUND(Del_m*Width/1000,0.01);
IF Idno_stock<1 						THEN Idno_stock=0;
IF CPS="" 								THEN CPS="-";
RUN;

PROC SQL;
CREATE TABLE work.Sal_ord_del AS
SELECT 	a.Company, a.Sal_ord_nr, a.Sal_ord_pos, a.CPS, a.Width, a.Thickness,
		SUM(Del_Kg)		AS Sales_kg  	FORMAT 6.0,
		SUM(Del_m) 		AS Sales_m  	FORMAT 6.0,
		SUM(Del_m2) 	AS Sales_m2  	FORMAT 6.0,
		SUM(Del_pcs) 	AS Sales_pcs  	FORMAT 6.0,
		SUM(Idno_Stock)	AS Sales_Stock  FORMAT 6.0
FROM work.Sal_Idno a
GROUP BY a.Company, a.Sal_ord_nr, a.Sal_ord_pos
ORDER BY a.Company, a.Sal_ord_nr, a.Sal_ord_pos;
QUIT;

PROC SQL;
CREATE TABLE work.sls041 AS
SELECT 	a.*,
		b.Sales_kg, b.Sales_m, b.Sales_m2, Sales_pcs, Sales_Stock, b.CPS, b.Width, b.Thickness
FROM work.sls041 a 	LEFT OUTER JOIN work.Sal_ord_del b 		ON a.Company=b.Company AND a.Sal_ord_nr=b.Sal_ord_nr AND a.Sal_ord_pos=b.Sal_ord_Pos;
QUIT;

PROC SORT DATA=work.sls041 nodupkey; BY Company Sal_ord_nr Sal_ord_pos; RUN;


/*****************************************************************************************/
/*****  Default Order Tolerance data												******/
/*****************************************************************************************/
/*PROC IMPORT OUT= WORK.Sal_tol_base*/
/* 			DATAFILE= "\\spinyspider\euramax\SASBI\Data\Roermond\Sal_Ord_Tolerances_new1.xlsx" */
/*            DBMS=XLSX REPLACE;*/
/*     RANGE="Default$A1:I1000"; */
/*     GETNAMES=YES;*/
/*RUN;*/

/* 27-5-2021 RM added tolerance via REAL instead of Excelsheet */
libname realdb7 odbc dsn='realdb7' schema='realdb7' user="root" password="1Safetyok";

PROC SQL;
CREATE TABLE work.Default_Tolerances AS
SELECT  a.maxquantity,
		a.minquantity,
		a.minthickness,
		a.maxthickness,
		a.toleranceminus,
		a.toleranceplus,
		b.code AS market 		label='market',
		c.code AS quantityuom 	label='quantityuom',
		d.code AS toleranceuom 	label='toleranceuom'
FROM realdb7.trd_req_defaulttolerance 	a 
LEFT OUTER JOIN realdb7.cat_mrk_market 	b ON a.market=b.id
LEFT OUTER JOIN realdb7.com_log_uom 	c ON a.quantityuom=c.id
LEFT OUTER JOIN realdb7.com_log_uom 	d ON a.toleranceuom=d.id;
QUIT;


PROC IMPORT OUT= WORK.Sal_tol_special
 			DATAFILE= "\\spinyspider\euramax\SASBI\Data\Roermond\Sal_Ord_Tolerances_new1.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="Exceptions$A1:N1000"; 
     GETNAMES=YES;
RUN;

PROC SQL;
CREATE TABLE work.Special_tolerances AS
SELECT  a.maxquantity,
		a.minquantity,
		a.minthickness,
		a.maxthickness,
		a.toleranceminus,
		a.toleranceplus,
		c.code 											AS quantityuom 	label='quantityuom',
		d.code 											AS toleranceuom label='toleranceuom',
		e.code 											AS customer 	label='customer',
		CASE 
		WHEN a.itemform='C' THEN 'Coil' ELSE 'Plt' END 	AS Coil_Plate
FROM realdb7.trd_req_partnertolerance 	a 
LEFT OUTER JOIN realdb7.com_log_uom 	c ON a.quantityuom=c.id
LEFT OUTER JOIN realdb7.com_log_uom 	d ON a.toleranceuom=d.id
LEFT OUTER JOIn realdb7.com_par_partner e ON a.partner=e.id;
QUIT;





/*****  Adding Default Order tolerance Data											*****/
PROC SQL;
CREATE TABLE work.sls041 AS
SELECT 	a.*,
		b.Thickness,
		b.Paint_FS_layers 	AS FS_Lay,
		b.Coil_Plate		AS Coil_Plate,
		b.Width_group		AS Width_group,
		c.Market_Code		AS Market,
		c.Cust_Par_Code		AS Cust_Parent
FROM work.sls041 a 	LEFT OUTER JOIN DB2DATA.Dimsets b 		ON a.Company=b.Company AND a.Dimset=b.Dimset AND a.Dimset NE ""
					LEFT OUTER JOIN DB2DATA.Customers c 	ON a.Company=c.Company AND a.Cust_nr=c.Cust_nr;
QUIT;

PROC SQL;
CREATE TABLE work.sls041 AS
SELECT 	a.*, 	b.MTO, b.MTO_Start, b.MTO_Stop,
				b.MTS, b.MTS_Start, b.MTS_Stop,
				b.FTO, b.FTO_Start, b.FTO_Stop
FROM work.sls041 a LEFT OUTER JOIN db2data.Dimset_Supplychain_strategy b ON a.Company=b.Company AND a.Dimset=b.Dimset;
QUIT;

DATA work.sls041 (DROP=MTO_Start MTO_Stop MTS_Start MTS_Stop FTO_Start FTO_Stop) ; SET work.sls041;
IF MTO NE "" AND sal_ord_pos_order_date<MTO_Start OR sal_ord_pos_order_date>MTO_Stop THEN MTO="";
IF MTS NE "" AND sal_ord_pos_order_date<MTS_Start OR sal_ord_pos_order_date>MTS_Stop THEN MTS="";
IF FTO NE "" AND sal_ord_pos_order_date<FTO_Start OR sal_ord_pos_order_date>FTO_Stop THEN FTO="";

/* RM 09-07-2020 ADDED Cust 061210 Ord Tol Business Rule AND MT_type for each Order */
IF CUST_NR='061210' AND FS_Lay='P---' THEN Sal_ord_pos_ordtol_Unit='%';
FORMAT MT_Type $3.;
MT_Type="";
IF MTO='Yes' THEN MT_Type='MTO';
IF FTO='Yes' THEN MT_Type='FTO';
IF MTS='Yes' THEN MT_Type='MTS';
RUN;

/* RM 11-9-2020 changed join; Before; Sal_Ord_Pos_org_ord_quan After; sal_ord_pos_quan */
PROC SQL;
CREATE TABLE work.sls041 AS
SELECT 	a.*, b.toleranceminus AS Tol_Min_Base LABEL='Tol_Min_Base', b.toleranceplus AS Tol_Max_Base LABEL='Tol_Max_Base'
FROM work.sls041 a LEFT OUTER JOIN work.Default_Tolerances b ON 	a.Thickness>=b.minthickness 		AND a.Thickness<=b.maxthickness 				AND a.Sal_ord_pos_ordtol_Unit=b.toleranceuom AND b.Market="" AND
															((a.sal_ord_pos_quan>=b.minquantity 		AND a.sal_ord_pos_quan<=b.maxquantity 			AND a.Sal_ord_pos_ordtol_Unit='%') OR
															 (a.Sal_Ord_Pos_org_ord_pcs>=b.minquantity 	AND a.Sal_Ord_Pos_org_ord_pcs<=b.maxquantity 	AND a.Sal_ord_pos_ordtol_Unit='pcs')OR
															 (a.Sal_Ord_pos_Min_ord_m>=b.minquantity 	AND a.Sal_Ord_pos_Min_ord_m<=b.maxquantity 		AND a.Sal_ord_pos_ordtol_Unit='m')     );
QUIT;
PROC SQL;
CREATE TABLE work.sls041 AS
SELECT 	a.*, b.toleranceminus AS Tol_Min_BaseM LABEL='Tol_Min_BaseM', b.toleranceplus AS Tol_Max_BaseM LABEL='Tol_Max_BaseM'
FROM work.sls041 a LEFT OUTER JOIN work.Default_Tolerances b ON 	a.Thickness>=b.minthickness 		AND a.Thickness<=b.maxthickness 				AND a.Sal_ord_pos_ordtol_Unit=b.toleranceuom AND INDEX(b.Market,TRIM(a.Market))>0 AND
															((a.sal_ord_pos_quan>=b.minquantity 		AND a.sal_ord_pos_quan<=b.maxquantity 			AND a.Sal_ord_pos_ordtol_Unit='%') OR
															 (a.Sal_Ord_Pos_org_ord_pcs>=b.minquantity 	AND a.Sal_Ord_Pos_org_ord_pcs<=b.maxquantity 	AND a.Sal_ord_pos_ordtol_Unit='pcs')    );
QUIT;	
PROC SQL;
CREATE TABLE work.sls041 AS
SELECT 	a.*, b.toleranceminus AS Tol_Min_BaseS LABEL='Tol_Min_BaseS', b.toleranceplus AS Tol_Max_BaseS LABEL='Tol_Max_BaseS'
FROM work.sls041 a LEFT OUTER JOIN work.Special_tolerances b ON 	a.Thickness>=b.minthickness AND a.Thickness<=b.maxthickness AND a.Sal_ord_pos_ordtol_Unit=b.toleranceuom AND a.Coil_Plate=b.Coil_Plate AND
																  a.Cust_nr=b.customer 						AND a.Sal_ord_pos_ord_Unit=b.quantityuom AND 
																((a.sal_ord_pos_quan>=b.minquantity 		AND a.sal_ord_pos_quan<=b.maxquantity 			AND a.Sal_ord_pos_ordtol_Unit='%') OR
																 (a.Sal_Ord_Pos_org_ord_pcs>=b.minquantity 	AND a.Sal_Ord_Pos_org_ord_pcs<=b.maxquantity 	AND a.Sal_ord_pos_ordtol_Unit='pcs')OR
																 (a.Sal_Ord_pos_Min_ord_m>=b.minquantity 	AND a.Sal_Ord_pos_Min_ord_m<=b.maxquantity 		AND a.Sal_ord_pos_ordtol_Unit='m')   );
QUIT;


DATA work.sls041 (Drop=Tol_Min_BaseM Tol_Max_BaseM Tol_Min_BaseS Tol_Max_BaseS Tol_Max_BaseSP); 
SET work.sls041;
Tol_Match_type='Base      ';
IF Tol_Min_BaseM NE . 	THEN DO; Tol_Min_Base=Tol_Min_BaseM; 	Tol_Max_Base=Tol_Max_BaseM; Tol_Match_type='BaseMarket'; 	END;
IF Tol_Min_BaseS NE . 	THEN DO; Tol_Min_Base=Tol_Min_BaseS; 	Tol_Max_Base=Tol_Max_BaseS; Tol_Match_type='Special   '; 	END;
RUN;

/**********************************************************************/
/****    Collecting Dispatch_Slack table 	   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.shp002 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_crte	Shipm_Route,
			a.t_ccty	Country,
			a.t_cdec	Term_del,
			a.t_slck	Del_Slack
   FROM      ttdshp002120 a  
WHERE a.t_ccty <> ''  AND a.t_grpg=2
ORDER BY t_grpg, t_crte, t_ccty, t_cdec);
CREATE table work.shp005 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_crte	Shipm_Route,
			a.t_cuno	Cust_nr,
			a.t_cdel	Cust_del_addr_code,
			a.t_slck	Del_Slack
   FROM      ttdshp005120 a  
WHERE a.t_grpg=2
ORDER BY t_grpg, t_crte, t_cuno, t_cdel);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.shp002_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_crte	Shipm_Route,
			a.t_ccty	Country,
			a.t_cdec	Term_del,
			a.t_slck	Del_Slack
   FROM      ttdshp002130 a  
WHERE a.t_ccty <> ''  AND a.t_grpg=2
ORDER BY t_grpg, t_crte, t_ccty, t_cdec);
CREATE table work.shp005_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_crte	Shipm_Route,
			a.t_cuno	Cust_nr,
			a.t_cdel	Cust_del_addr_code,
			a.t_slck	Del_Slack
   FROM      ttdshp005130 a  
WHERE a.t_grpg=2
ORDER BY t_grpg, t_crte, t_cuno, t_cdel);
 DISCONNECT from baan;
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.shp002_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_crte	Shipm_Route,
			a.t_ccty	Country,
			a.t_cdec	Term_del,
			a.t_slck	Del_Slack
   FROM      ttdshp002300 a  
WHERE a.t_ccty <> ''  AND a.t_grpg=2
ORDER BY t_grpg, t_crte, t_ccty, t_cdec);
CREATE table work.shp005_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_crte	Shipm_Route,
			a.t_cuno	Cust_nr,
			a.t_cdel	Cust_del_addr_code,
			a.t_slck	Del_Slack
   FROM      ttdshp005300 a  
WHERE a.t_grpg=2
ORDER BY t_grpg, t_crte, t_cuno, t_cdel);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.shp002 DATA=work.shp002_ECP; RUN;
PROC APPEND BASE=work.shp002 DATA=work.shp002_EAP; RUN;

PROC APPEND BASE=work.shp005 DATA=work.shp005_ECP; RUN;
PROC APPEND BASE=work.shp005 DATA=work.shp005_EAP; RUN;

/**********************************************************************/
/****    Collecting Default ProcesFlows slack					   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm937 as select * from connection to baan
   (SELECT  'Roe'			AS Company,
   			a.t_item		AS Item_nr,
			a.t_prfl		AS Dims_Def_ProcFlow,
			a.t_iltd		AS ProcFlowSlack
    FROM        ttdmdm937120 a  );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm937_ECP as select * from connection to baan
   (SELECT  'ECP'			AS Company,
   			a.t_item		AS Item_nr,
			a.t_prfl		AS Dims_Def_ProcFlow,
			a.t_iltd		AS ProcFlowSlack
    FROM        ttdmdm937130 a  );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm937_EAP as select * from connection to baan
   (SELECT  'EAP'			AS Company,
   			a.t_item		AS Item_nr,
			a.t_prfl		AS Dims_Def_ProcFlow,
			a.t_iltd		AS ProcFlowSlack
    FROM        ttdmdm937300 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.mdm937 DATA=work.mdm937_ECP; RUN;
PROC APPEND BASE=work.mdm937 DATA=work.mdm937_EAP; RUN;

/**********************************************************************/
/****    Collecting TRO data  					   ****/
/**********************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm310 as select * from connection to baan
   (SELECT  'Roe'			AS Company,
   			a.t_morn		AS TRO_Main_nr,
			a.t_orno		AS TRO_ord_nr,
			a.t_pono		AS TRO_pos_nr,
			a.t_osta		AS TRO_Status,
			a.t_psdt		AS TRO_Start_Date,
			a.t_pcdt		AS TRO_End_Date,
			a.t_cano		AS TRO_Camp_nr,
			a.t_seno		AS TRO_Camp_Seq,
			b.t_date		AS Campaign_Date,
			c.t_efdt		AS TRO_Creation_Date
    FROM        ttdmdm310120 a, ttdprd100120 b, ttisfc001120 c
WHERE a.t_cano=b.t_cano AND a.t_orno=c.t_pdno
ORDER BY TRO_Main_nr, TRO_Pos_nr);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm993 as select * from connection to baan
   (SELECT  'Roe'			AS Company,
			a.t_orno		AS TRO_ord_nr,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos
    FROM        ttdmdm993120 a  );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm310_ECP as select * from connection to baan
   (SELECT  'ECP'			AS Company,
   			a.t_morn		AS TRO_Main_nr,
			a.t_orno		AS TRO_ord_nr,
			a.t_pono		AS TRO_pos_nr,
			a.t_osta		AS TRO_Status,
			a.t_psdt		AS TRO_Start_Date,
			a.t_pcdt		AS TRO_End_Date,
			a.t_cano		AS TRO_Camp_nr,
			a.t_seno		AS TRO_Camp_Seq,
			b.t_date		AS Campaign_Date,
			c.t_efdt		AS TRO_Creation_Date
    FROM        ttdmdm310130 a, ttdprd100130 b, ttisfc001130 c
WHERE a.t_cano=b.t_cano AND a.t_orno=c.t_pdno
ORDER BY TRO_Main_nr, TRO_Pos_nr);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm993_ECP as select * from connection to baan
   (SELECT  'ECP'			AS Company,
			a.t_orno		AS TRO_ord_nr,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos
    FROM        ttdmdm993130 a  );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm310_EAP as select * from connection to baan
   (SELECT  'EAP'			AS Company,
   			a.t_morn		AS TRO_Main_nr,
			a.t_orno		AS TRO_ord_nr,
			a.t_pono		AS TRO_pos_nr,
			a.t_osta		AS TRO_Status,
			a.t_psdt		AS TRO_Start_Date,
			a.t_pcdt		AS TRO_End_Date,
			a.t_cano		AS TRO_Camp_nr,
			a.t_seno		AS TRO_Camp_Seq,
			b.t_date		AS Campaign_Date,
			c.t_efdt		AS TRO_Creation_Date
    FROM        ttdmdm310300 a, ttdprd100300 b, ttisfc001300 c
WHERE a.t_cano=b.t_cano AND a.t_orno=c.t_pdno
ORDER BY TRO_Main_nr, TRO_Pos_nr);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.mdm993_EAP as select * from connection to baan
   (SELECT  'EAP'			AS Company,
			a.t_orno		AS TRO_ord_nr,
			a.t_sorn		AS Sal_Ord_nr,
			a.t_spon		AS Sal_ord_pos
    FROM        ttdmdm993300 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.mdm310 DATA=work.mdm310_ECP; RUN;
PROC APPEND BASE=work.mdm310 DATA=work.mdm310_EAP; RUN;

PROC APPEND BASE=work.mdm993 DATA=work.mdm993_ECP; RUN;
PROC APPEND BASE=work.mdm993 DATA=work.mdm993_EAP; RUN;
 
PROC SORT DATA=work.mdm993; BY Company TRO_Ord_nr; RUN;

PROC SQL;
CREATE TABLE work.mdm310 AS
SELECT 	a.*,
		b.Sal_ord_nr,
		b.Sal_ord_pos
FROM work.mdm310 a LEFT OUTER JOIN work.mdm993 b ON a.Company=b.Company AND a.TRO_ord_nr=b.TRO_ord_nr;
QUIT;

PROC SQL;
CREATE TABLE work.mdm310_1 AS
SELECT 	a.Company,
		a.Sal_ord_nr,
		a.Sal_ord_pos,
		a.TRO_main_nr,
		MIN (TRO_start_date)		AS TRO_Main_Start_date			FORMAT Date9.,
		MAX (TRO_End_Date)			AS TRO_Main_End_Date			FORMAT Date9.,
		MIN (Campaign_date)			AS TRO_Main_Camp_Date_first		FORMAT Date9.,
		MAX (Campaign_date)			AS TRO_Main_Camp_Date_last		FORMAT Date9.,
		MIN (TRO_Creation_Date)		AS TRO_Main_Creation_Date_first	FORMAT Date9.,
		MIN (TRO_Status)			AS TRO_Main_Min_Status,
		COUNT(TRO_ord_nr)			AS TRO_Main_Steps
FROM work.mdm310 a
WHERE Sal_ord_nr ne 0
GROUP BY a.Company, a.Sal_ord_nr, a.Sal_ord_pos, a.TRO_main_nr
ORDER BY a.Company, a.Sal_ord_nr, a.Sal_ord_pos, a.TRO_main_nr ;
QUIT;

DATA work.mdm310_1; SET work.mdm310_1;
BY Company Sal_Ord_nr Sal_ord_pos ;
IF NOT first.Sal_ord_pos THEN DELETE;
RUN;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_TRO as select * from connection to baan
   (SELECT  'Roe'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			MAX(b.t_date)		AS TRO_Main_max_Date
    FROM        ttdlra011120 a, ttdlra011120 b 
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND b.t_koor=80 AND a.t_dqua_2>0
GROUP BY a.t_orno, a.t_pono
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_TRO_ECP as select * from connection to baan
   (SELECT  'ECP'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			MAX(b.t_date)		AS TRO_Main_max_Date
    FROM        ttdlra011130 a, ttdlra011130 b 
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND b.t_koor=80 AND a.t_dqua_2>0
GROUP BY a.t_orno, a.t_pono
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_TRO_EAP as select * from connection to baan
   (SELECT  'EAP'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			MAX(b.t_date)		AS TRO_Main_max_Date
    FROM        ttdlra011300 a, ttdlra011300 b 
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND b.t_koor=80 AND a.t_dqua_2>0
GROUP BY a.t_orno, a.t_pono
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.lra011_Sal_TRO DATA=work.lra011_Sal_TRO_ECP; RUN;
PROC APPEND BASE=work.lra011_Sal_TRO DATA=work.lra011_Sal_TRO_EAP; RUN;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_SHT as select * from connection to baan
   (SELECT  'Roe'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			MAX(b.t_trdt)		AS SHT_Main_max_Date
    FROM        ttdlra011120 a, ttdlra014120 b 
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND a.t_dqua_2>0
GROUP BY a.t_orno, a.t_pono
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_SHT_ECP as select * from connection to baan
   (SELECT  'ECP'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			MAX(b.t_trdt)		AS SHT_Main_max_Date
    FROM        ttdlra011130 a, ttdlra014130 b 
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND a.t_dqua_2>0
GROUP BY a.t_orno, a.t_pono
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_SHT_EAP as select * from connection to baan
   (SELECT  'EAP'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			MAX(b.t_trdt)		AS SHT_Main_max_Date
    FROM        ttdlra011300 a, ttdlra014300 b 
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND a.t_dqua_2>0
GROUP BY a.t_orno, a.t_pono
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_SHT_Cor as select * from connection to baan
   (SELECT  'Cor'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			MAX(b.t_trdt)		AS SHT_Main_max_Date
    FROM        ttdlra011200 a, ttdlra014200 b 
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND a.t_dqua_2>0
GROUP BY a.t_orno, a.t_pono
ORDER BY a.t_orno, a.t_pono);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.lra011_Sal_SHT DATA=work.lra011_Sal_SHT_ECP; RUN;
PROC APPEND BASE=work.lra011_Sal_SHT DATA=work.lra011_Sal_SHT_EAP; RUN;
PROC APPEND BASE=work.lra011_Sal_SHT DATA=work.lra011_Sal_SHT_Cor; RUN;


/***** Calculating TRO_Main Input/output weigths			*****/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_TRO_ord as select * from connection to baan
   (SELECT  'Roe'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			b.t_orno			AS TRO_Ord_nr_Last,
			c.t_morn			AS TRO_Main_nr,
			SUM(b.t_oqua_2)		AS TRO_Ord_Last_kg
    FROM        ttdlra011120 a, ttdlra011120 b, ttdmdm310120 c
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND b.t_koor=80 AND a.t_dqua_2>0 AND b.t_orno=c.t_orno
GROUP BY a.t_orno, a.t_pono, b.t_orno, c.t_morn
ORDER BY a.t_orno, a.t_pono, b.t_orno, c.t_morn);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_TRO_ord_ECP as select * from connection to baan
   (SELECT  'ECP'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			b.t_orno			AS TRO_Ord_nr_Last,
			c.t_morn			AS TRO_Main_nr,
			SUM(b.t_oqua_2)		AS TRO_Ord_Last_kg
    FROM        ttdlra011130 a, ttdlra011130 b, ttdmdm310130 c
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND b.t_koor=80 AND a.t_dqua_2>0 AND b.t_orno=c.t_orno
GROUP BY a.t_orno, a.t_pono, b.t_orno, c.t_morn
ORDER BY a.t_orno, a.t_pono, b.t_orno, c.t_morn);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.lra011_Sal_TRO_ord_EAP as select * from connection to baan
   (SELECT  'EAP'				AS Company,
   			a.t_orno			AS Sal_ord_nr,
			a.t_pono			AS Sal_ord_pos,
			b.t_orno			AS TRO_Ord_nr_Last,
			c.t_morn			AS TRO_Main_nr,
			SUM(b.t_oqua_2)		AS TRO_Ord_Last_kg
    FROM        ttdlra011300 a, ttdlra011300 b, ttdmdm310300 c
WHERE a.t_leno=b.t_leno AND a.t_koor=3 AND b.t_koor=80 AND a.t_dqua_2>0 AND b.t_orno=c.t_orno
GROUP BY a.t_orno, a.t_pono, b.t_orno, c.t_morn
ORDER BY a.t_orno, a.t_pono, b.t_orno, c.t_morn);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.lra011_Sal_TRO_ord DATA=work.lra011_Sal_TRO_ord_ECP; RUN;
PROC APPEND BASE=work.lra011_Sal_TRO_ord DATA=work.lra011_Sal_TRO_ord_EAP; RUN;

PROC SORT DATA=work.lra011_Sal_TRO_ord nodupkey; BY Company Sal_ord_nr Sal_ord_pos; RUN;

DATA work.lra011_Sal_TRO_ord; SET work.lra011_Sal_TRO_ord; BY Company Sal_ord_nr Sal_ord_pos; IF NOT LAST.Sal_ord_pos THEN DELETE; RUN;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.TRO_ord as select * from connection to baan
   (SELECT  'Roe'				AS Company,
			a.t_orno			AS TRO_Ord_nr,
			a.t_pono			AS TRO_Ord_pos,
			a.t_morn			AS TRO_Main_nr,
			a.t_iqan			AS TRO_Inp_Quan,
			a.t_dqan			AS TRO_Outp_Quan
	FROM ttdmdm310120 a
ORDER BY a.t_morn, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.TRO_ord_ECP as select * from connection to baan
   (SELECT  'ECP'				AS Company,
			a.t_orno			AS TRO_Ord_nr,
			a.t_pono			AS TRO_Ord_pos,
			a.t_morn			AS TRO_Main_nr,
			a.t_iqan			AS TRO_Inp_Quan,
			a.t_dqan			AS TRO_Outp_Quan
	FROM ttdmdm310130 a
ORDER BY Company, a.t_morn, a.t_pono);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
CREATE TABLE work.TRO_ord_EAP as select * from connection to baan
   (SELECT  'EAP'				AS Company,
			a.t_orno			AS TRO_Ord_nr,
			a.t_pono			AS TRO_Ord_pos,
			a.t_morn			AS TRO_Main_nr,
			a.t_iqan			AS TRO_Inp_Quan,
			a.t_dqan			AS TRO_Outp_Quan
	FROM ttdmdm310300 a
ORDER BY Company, a.t_morn, a.t_pono);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.TRO_ord DATA=work.TRO_ord_ECP; RUN;
PROC APPEND BASE=work.TRO_ord DATA=work.TRO_ord_EAP; RUN;

PROC SORT DATA=work.TRO_ord; 
BY Company TRO_Main_nr TRO_Ord_pos; RUN; 

DATA work.TRO_ord; SET work.TRO_ord;
BY Company TRO_Main_nr TRO_Ord_pos;
IF NOT (First.TRO_Main_nr OR Last.TRO_Main_nr) 	THEN DELETE;
IF First.TRO_Main_nr AND NOT LAST.TRO_Main_nr 	THEN TRO_Outp_Quan=0;
IF LAST.TRO_Main_nr AND NOT FIRST.TRO_Main_nr 	THEN TRO_Inp_Quan=0;
RUN;

PROC SQL;
CREATE TABLE work.TRO_Main_Ballance AS
SELECT 	a.Company,
		a.TRO_Main_nr,
		SUM(TRO_Inp_Quan)  	AS TRO_Main_Inp_Quan,
		SUM(TRO_Outp_Quan)	AS TRO_Main_Outp_Quan
FROM work.TRO_ord a
GROUP BY a.Company, a.TRO_Main_nr
ORDER BY a.Company, a.TRO_Main_nr;
QUIT;

PROC SQL;
CREATE TABLE work.TRO_Main_Bal AS
SELECT a.*, b.TRO_Main_Inp_Quan, b.TRO_Main_Outp_Quan
FROM work.lra011_Sal_TRO_ord a LEFT OUTER JOIN work.TRO_Main_Ballance b ON a.Company=b.Company AND a.TRO_Main_nr=b.TRO_Main_nr;
QUIT;



/**********************************************************************/
/****    Combining all data						     			   ****/
/**********************************************************************/
PROC SQL;
CREATE TABLE work.WO_Prep_Orders AS
SELECT 	a.*,
		b.WO_Prep_Org_Proc_Flow,
		b.WO_Prep_Org_Requirement_Date,
		b.WO_Prep_Org_MAD_Date,
		b.WO_Prep_Org_Substr_Date,
		b.WO_Prep_Org_Paint_Date,
		b.WO_prep_org_finished_date,
		b.WO_P_Org_Sal_Plan_Del_date,
		b.WO_P_Org_Sal_Prod_Compl_date,
		b.WO_Prep_Org_Ord_Quan_Unit,
		b.WO_Prep_Org_Ord_Quan,
		b.WO_Prep_Org_Del_From_Stock,
		c.WO_P_Fin_Sal_Plan_Del_date,
		c.WO_P_Fin_Sal_Prod_Compl_date,
		c.WO_Prep_Fin_Proc_Flow,
		c.WO_Prep_Fin_Requirement_Date,
		c.WO_Prep_Fin_MAD_Date,
		c.WO_Prep_Fin_Substr_Date,
		c.WO_Prep_Fin_Paint_Date,
		c.WO_Prep_Fin_Foil_Date,
		c.WO_Prep_Fin_Capac_Date,
		c.wo_prep_Fin_finished_date,
		c.WO_Prep_Fin_Ord_Quan_Unit,
		c.WO_Prep_Fin_Ord_Quan,
		c.WO_Prep_Fin_Del_From_Stock,
		d.Irreg_Count,
		e.ProcFlowSlack,
		f.Del_Slack,
		g.Del_Slack							AS Countr_sl,
		h.Del_Slack							AS Countr_termDel_sl,
		i.Del_Slack							AS Countr_gen_sl,
		j.TRO_main_nr,
		j.TRO_Main_Start_Date,
		j.TRO_Main_End_Date,
		j.TRO_Main_Camp_Date_First,
		j.TRO_Main_Camp_Date_Last,
		j.TRO_Main_Creation_Date_first,
		j.TRO_Main_Min_Status,
		j.TRO_Main_Steps,
		k.Shipm_Last_Load_Date,
		k.Shipm_First_Load_Date,
		k.Shipm_Last_OnBoard_Date,										/* PW 03-07-2020  */
		k.Shipm_Last_UnLoad_Date,
		l.TRO_Main_max_Date,
		m.SHT_Main_max_Date,
		n.TRO_Main_Inp_Quan,
		n.TRO_Main_Outp_Quan,
		o.Date								AS WO_Prep_org_rel_Sales_Date	FORMAT Date9.,
		o.Time								AS WO_Prep_org_rel_Sales_Time	FORMAT Time8.
FROM work.sls041 a 	LEFT OUTER JOIN work.slx121 b 			ON a.Company=b.Company AND a.Sal_Ord_nr=b.Sal_Ord_nr 			AND a.Sal_Ord_pos=b.Sal_Ord_pos
					LEFT OUTER JOIN work.slx123 c 			ON a.Company=c.Company AND a.Sal_Ord_nr=c.Sal_Ord_nr 			AND a.Sal_Ord_pos=c.Sal_Ord_pos
					LEFT OUTER JOIN work.qua427_avg d 		ON a.Company=d.Company AND a.Sal_Ord_nr=d.Sal_Ord_nr 			AND a.Sal_Ord_pos=d.Sal_Ord_pos
					LEFT OUTER JOIN work.mdm937 e 			ON a.Company=e.Company AND a.Item_nr=e.Item_nr 					AND c.WO_Prep_Fin_Proc_Flow=e.Dims_Def_ProcFlow
					LEFT OUTER JOIN work.shp005 f 			ON a.Company=f.Company AND a.Sal_Ord_Route=f.Shipm_Route 		AND a.Cust_nr=f.Cust_nr 						AND a.Sal_ord_Del_Addr=f.Cust_del_addr_Code 	
					LEFT OUTER JOIN work.shp002 g 			ON a.Company=g.Company AND a.Sal_Ord_Route=g.Shipm_Route 		AND a.Cust_del_addr_Country=g.Country 			AND g.Term_Del="" 	
					LEFT OUTER JOIN work.shp002 h 			ON a.Company=h.Company AND a.Sal_Ord_Route=h.Shipm_Route 		AND a.Cust_del_addr_Country=h.Country 			AND a.Sal_Ord_term_del=h.Term_Del 
					LEFT OUTER JOIN work.shp002 i 			ON a.Company=i.Company AND a.Cust_del_addr_Country=i.Country 	AND i.Term_Del="" 								AND i.Shipm_route="" 
					LEFT OUTER JOIN work.mdm310_1 j			ON a.Company=j.Company AND a.Sal_Ord_nr=j.Sal_Ord_nr 			AND a.Sal_Ord_pos=j.Sal_Ord_pos
					LEFT OUTER JOIN work.shipm k			ON a.Company=k.Company AND a.Sal_Ord_nr=k.Sal_Ord_nr 			AND a.Sal_Ord_pos=k.Sal_Ord_pos
					LEFT OUTER JOIN work.lra011_Sal_TRO l	ON a.Company=l.Company AND a.Sal_Ord_nr=l.Sal_Ord_nr 			AND a.Sal_Ord_pos=l.Sal_Ord_pos
					LEFT OUTER JOIN work.lra011_Sal_SHT m	ON a.Company=m.Company AND a.Sal_Ord_nr=m.Sal_Ord_nr 			AND a.Sal_Ord_pos=m.Sal_Ord_pos
					LEFT OUTER JOIN work.TRO_Main_Bal n		ON a.Company=n.Company AND a.Sal_Ord_nr=n.Sal_Ord_nr 			AND a.Sal_Ord_pos=n.Sal_Ord_pos
					LEFT OUTER JOIN work.slx121SalConf o	ON a.Company=o.Company AND a.Sal_Ord_nr=o.Sal_Ord_nr 			AND a.Sal_Ord_pos=o.Sal_Ord_pos;
QUIT;

/* RM ADDED 30-3-2022 AGE DATE */
PROC SQL;
CREATE TABLE work.MAX_AGE_DATE AS
SELECT 	a.Company,
		a.Sal_ord_nr,
		a.Sal_ord_pos,
		MAX(c.lra011_Date) 	AS MAX_RECEIPT_DATE,
		MAX(b.Age_Date)  	AS MAX_Age_Date
FROM db2data.lra011 a 
LEFT OUTER JOIN db2data.idno_stock_week b ON a.company=b.company AND a.idno=b.idno
LEFT OUTER JOIN db2data.lra011 			c ON a.company=c.company AND a.idno=c.idno AND c.ord_type=2
WHERE a.Ord_type=3 
GROUP BY a.Company, a.Sal_ord_nr, a.Sal_Ord_pos
ORDER BY a.Company, a.Sal_ord_nr, a.Sal_Ord_pos;
QUIT;

PROC SQL;
CREATE TABLE work.WO_Prep_Orders AS
SELECT  a.*,
		b.MAX_RECEIPT_DATE,
		b.MAX_Age_Date
FROM work.WO_Prep_Orders a LEFT OUTER JOIN work.MAX_AGE_DATE b ON a.company=b.company AND a.sal_ord_nr=b.sal_ord_nr AND a.sal_ord_pos=b.sal_ord_pos;
QUIT;


DATA work.WO_Prep_Orders (DROP=Rev_Salpos Countr_sl Countr_termDel_sl Countr_gen_sl Ord_PCS Ord_Kg Total_Days Week_Days);
SET work.WO_Prep_Orders;

IF wo_prep_fin_finished_date=. 																				THEN wo_prep_fin_finished_date=MDY(01,01,2000);

Req_Date_minus_MAD_Date=WO_Prep_Fin_Requirement_Date-WO_Prep_Fin_MAD_Date;
MAD_Date_minus_Req_Date=WO_Prep_Fin_MAD_Date-WO_Prep_Fin_Requirement_Date;
Req_Date_Minus_Ord_date=WO_Prep_Fin_Requirement_Date-Sal_Ord_pos_Order_date;

IF (WO_Prep_Fin_Substr_Date>WO_Prep_Fin_Requirement_Date AND WO_Prep_Fin_Substr_Date=WO_Prep_Fin_MAD_Date) 	THEN Substr_Check=1; 	ELSE Substr_Check=0;
IF (WO_Prep_Fin_Paint_Date>WO_Prep_Fin_Requirement_Date AND WO_Prep_Fin_Paint_Date=WO_Prep_Fin_MAD_Date) 	THEN Paint_check=1; 	ELSE Paint_check=0;

IF ProcFlowSlack=. 																							THEN ProcFlowSlack=5;
IF Del_Slack=. 																								THEN Del_Slack=Countr_sl;
IF Del_Slack=. 																								THEN Del_Slack=Countr_termDel_sl;
IF Del_Slack=. 																								THEN Del_Slack=Countr_gen_sl;
FORMAT OnTime_Date Date9.;
IF Sal_Ord_term_del IN ('EXW','FCA')			 					AND Shipm_Last_Load_Date>. 														THEN OnTime_Date=MAX(TRO_Main_Max_Date,SHT_Main_max_Date)+1;
IF Sal_Ord_term_del IN ('EXW','FCA')	AND Shipm_Last_Load_Date>. 	AND TRO_Main_Max_Date=. 		AND SHT_Main_max_Date=. AND MAX_Age_Date NE .	THEN OnTime_Date=MAX_Age_Date;     /* RM ADDED 30-3-2022 */
IF Sal_Ord_term_del IN ('EXW','FCA')	AND Shipm_Last_Load_Date>. 	AND TRO_Main_Max_Date=. 		AND SHT_Main_max_Date=. AND MAX_Age_Date=.		THEN OnTime_Date=MAX_RECEIPT_DATE; /* RM ADDED 30-3-2022 */
IF Sal_Ord_term_del IN ('FAS')					 					AND Shipm_Last_Load_Date>. 														THEN OnTime_Date=Shipm_Last_Load_Date;
IF Sal_Ord_term_del IN ('FOB') 										AND Shipm_Last_OnBoard_Date>. 													THEN OnTime_Date=Shipm_Last_OnBoard_Date;
IF Sal_Ord_term_del IN ('DDP','DAP','DPU','CIF','CIP','DAT') 		AND Shipm_Last_UnLoad_Date>. 													THEN OnTime_Date=Shipm_Last_UnLoad_Date;

IF Cust_nr='061204' 																																THEN OnTime_Date=Shipm_First_Load_Date;	/* PW 03-07-2020  */

IF OnTime_Date>. AND OnTime_Date <= Sal_Ord_Pos_Org_conf_del_date 	THEN OnTime_Check='Ok  '; 
IF OnTime_Date>. AND OnTime_Date >  Sal_Ord_Pos_Org_conf_del_date 	THEN OnTime_Check='N.Ok';
IF Sal_ord_Pos_Del_Quan>0 AND Sal_ord_Pos_Back_Quan NE 0 			THEN OnTime_Check='    '; 
OnTime_Dif_Days=OnTime_Date-Sal_Ord_Pos_Org_conf_del_date;

/* Recalc origenal ord quan via tdslx123 */
IF Sales_Kg>0 						THEN DO;
IF WO_Prep_Fin_Ord_Quan_Unit='kg'	THEN WO_Prep_Fin_Ord_kg=ROUND(WO_Prep_Fin_Ord_Quan,1); 
IF WO_Prep_Fin_Ord_Quan_Unit='lb'	THEN WO_Prep_Fin_Ord_kg=ROUND(WO_Prep_Fin_Ord_Quan*0.45359237,1); 
IF WO_Prep_Fin_Ord_Quan_Unit='m'	THEN WO_Prep_Fin_Ord_kg=ROUND(WO_Prep_Fin_Ord_Quan*(Sales_kg/Sales_M),1); 
IF WO_Prep_Fin_Ord_Quan_Unit='m2'	THEN WO_Prep_Fin_Ord_kg=ROUND(WO_Prep_Fin_Ord_Quan*(Sales_kg/Sales_M2),1);
IF WO_Prep_Fin_Ord_Quan_Unit='ton'	THEN WO_Prep_Fin_Ord_kg=ROUND(WO_Prep_Fin_Ord_Quan*1000,1); 
IF WO_Prep_Fin_Ord_Quan_Unit='stk'	THEN WO_Prep_Fin_Ord_pcs=WO_Prep_Fin_Ord_Quan; 								ELSE WO_Prep_Fin_Ord_pcs=1;
END;


Ord_PCS=sal_ord_pos_org_ord_pcs; Ord_Kg=Sal_Ord_Pos_org_ord_quan;
IF OnTime_date>=MDY(05,01,2020) AND Sal_ord_pos_OrdTol_Unit='pcs' 	THEN Ord_PCS=WO_Prep_Fin_Ord_pcs;    /* Use SLX123 pcs/weights to overrule SalOrd_pos_org_Quan  */
IF OnTime_date>=MDY(05,01,2020) AND Sal_ord_pos_OrdTol_Unit='%' 	THEN Ord_Kg=WO_Prep_Fin_Ord_kg;		 /* Use SLX123 pcs/weights to overrule SalOrd_pos_org_Quan  */

IF Sal_ord_pos_del_Quan>0 AND Sal_ord_pos_back_quan=0 																						THEN InFullCheck='N.Ok';
IF Sal_ord_pos_OrdTol_Unit='pcs' 	AND ((Sales_pcs-Ord_PCS)>=Tol_min_Base AND (Sales_pcs-Ord_PCS)<=Tol_max_Base) 							THEN InFullCheck='Ok  '; 
IF Sal_ord_pos_OrdTol_Unit='%'		AND ((Sales_kg-Ord_Kg)/Ord_Kg*100>=Tol_min_Base AND (Sales_kg-Ord_Kg)/Ord_Kg*100<=Tol_max_Base)  		THEN InFullCheck='Ok  '; 
IF Sal_ord_pos_OrdTol_Unit='m'		AND ((Sales_m-Sal_Ord_pos_Min_ord_m)>=Tol_min_Base AND (Sales_m-Sal_Ord_pos_Min_ord_m)<=Tol_max_Base) 	THEN InFullCheck='Ok  ';

/* RM 14-07-2020 ADDED InFull Perc calculation */
IF Sal_ord_pos_OrdTol_Unit='m' 																			THEN Tol_MAX_Quantity=Sal_Ord_pos_Min_ord_m+Tol_max_Base;
IF Sal_ord_pos_OrdTol_Unit='m' 																			THEN Tol_MIN_Quantity=Sal_Ord_pos_Min_ord_m+Tol_min_Base;

IF Sal_ord_pos_OrdTol_Unit='m'		AND Sal_Ord_pos_Min_ord_m NE 0 		AND sales_m>Tol_MAX_Quantity 	THEN InFull_Perc=ROUND((Sales_m-Tol_MAX_Quantity)/Tol_MAX_Quantity*100,.01);
IF Sal_ord_pos_OrdTol_Unit='m'		AND Sal_Ord_pos_Min_ord_m NE 0 		AND sales_m<Tol_MIN_Quantity 	THEN InFull_Perc=ROUND((Sales_m-Tol_MIN_Quantity)/Tol_MIN_Quantity*100,.01);




IF Sal_ord_pos_OrdTol_Unit='%' 												THEN Tol_MAX_Quantity=Ord_Kg*(1+Tol_max_Base/100);
IF Sal_ord_pos_OrdTol_Unit='%' 												THEN Tol_MIN_Quantity=Ord_Kg*(1+Tol_min_Base/100);

IF Sal_ord_pos_OrdTol_Unit='%'			AND sales_kg>Tol_MAX_Quantity 		THEN InFull_Perc=ROUND((Sales_kg-Tol_MAX_Quantity)/Tol_MAX_Quantity*100,.01);
IF Sal_ord_pos_OrdTol_Unit='%'			AND sales_kg<Tol_MIN_Quantity 		THEN InFull_Perc=ROUND((Sales_kg-Tol_MIN_Quantity)/Tol_MIN_Quantity*100,.01);




IF Sal_ord_pos_OrdTol_Unit='pcs' 											THEN Tol_MAX_Quantity=Ord_PCS+Tol_max_Base;
IF Sal_ord_pos_OrdTol_Unit='pcs' 											THEN Tol_MIN_Quantity=Ord_PCS+Tol_min_Base;

IF Sal_ord_pos_OrdTol_Unit='pcs'			AND Sales_pcs>Tol_MAX_Quantity 	THEN InFull_Perc=ROUND((Sales_pcs-Tol_MAX_Quantity)/Tol_MAX_Quantity*100,.01);
IF Sal_ord_pos_OrdTol_Unit='pcs'			AND Sales_pcs<Tol_MIN_Quantity 	THEN InFull_Perc=ROUND((Sales_pcs-Tol_MIN_Quantity)/Tol_MIN_Quantity*100,.01);

/* RM 14-07-2020 ADDED InFull Perc calculation */



/*
IF Sal_ord_pos_OrdTol_Unit='pcs' 	AND sal_ord_pos_org_ord_pcs NE 0 	THEN InFull_Perc=ROUND((Sales_pcs-Ord_PCS)/Ord_PCS*100,.01);
IF Sal_ord_pos_OrdTol_Unit='%'		AND sal_ord_pos_org_ord_quan NE 0 	THEN InFull_Perc=ROUND((Sales_kg-Ord_Kg)/Ord_Kg*100,.01);
IF Sal_ord_pos_OrdTol_Unit='m'		AND Sal_Ord_pos_Min_ord_m NE 0 		THEN InFull_Perc=ROUND((Sales_m-Sal_Ord_pos_Min_ord_m)/Sal_Ord_pos_Min_ord_m*100,.01);
*/
/* Extra Check on Gutlaufmeter  */
IF CUST_NR NE '061210' AND Sal_ord_pos_Min_ord_m>0 AND InFullCheck='Ok  ' AND Sales_m<Sal_ord_pos_Min_ord_m  					THEN InFullCheck='N.Ok';

IF CUST_NR='061210' AND Sal_ord_pos_Min_ord_m>0 AND InFullCheck='Ok  ' AND Sales_m<Sal_ord_pos_Min_ord_m AND FS_Lay NE 'P---'  	THEN InFullCheck='N.Ok';

OTIF="N.Ok";
IF OnTime_Check='Ok  ' AND InFullCheck='Ok  ' 																													THEN OTIF='Ok';
IF Cust_nr IN ('777777','777778') OR Sal_ord_nr>400000 OR Dimset="" OR Sal_ord_pos_back_quan>0 OR Sal_ord_pos_del_Quan=0 OR Sal_Ord_type='STC' OR Market='IC' 	THEN OTIF="";
IF Sal_ord_bal_ord='Y' AND OTIF='Ok'  																															THEN OTIF="";
CPS_Ref=CPS;
IF CPS IN ('','-') 																																				THEN CPS='N'; 						ELSE CPS='Y';
IF Sal_ord_pos_L3y=. 																																			THEN Sal_ord_pos_L3y=0;
IF Sal_ord_pos_L3y=0 AND CPS='N' AND Substr(Cust_nr,1,3) NE '777'  																								THEN CPS_New='Y'; 					ELSE CPS_New='N';
IF WO_P_Fin_Sal_Plan_Del_Date-Sal_ord_Org_Plan_Del_Date NE 0 	AND OTIF="" AND Sales_M=0 
																AND WO_PRep_Org_Finished_date NE . 																THEN Sal_Del_Date_Check='N.Ok.'; 	ELSE Sal_Del_Date_Check='Ok.  ';
IF Irreg_Count=. 																																				THEN Irreg_Count=0;
IF (Int(Sal_ord_pos/10))*10=Sal_ord_pos 																														THEN  Sal_ord_bal_ord='N'; 			ELSE Sal_ord_bal_ord='Y';
IF (Sal_Ord_Pos_Ordtol_MIN=Tol_Min_Base AND Sal_Ord_Pos_Ordtol_MAX=Tol_Max_Base) 																				THEN Tol_check='Ok. '; 				ELSE Tol_check='N.Ok';
Total_Days=WO_Prep_org_rel_Sales_Date-DMS_Sales_Ord_Receipt_Date; Week_Days=intck('weekday',DMS_Sales_Ord_Receipt_Date,WO_Prep_org_rel_Sales_Date);
Order_Entry_Duration=((Total_days-(Total_days-Week_days))*24 + (WO_Prep_org_rel_Sales_Time-DMS_Sales_Ord_Receipt_Time)/3600);

IF Sal_ord_pos_Quan=0 																																			THEN DELETE;

/* RM 08-07-2020 ADDED CUST 061210 BALANCE ORDER CHECK  & OTIF HITS */
Rev_Salpos=Reverse(sal_ord_pos);
IF CUST_NR='061210' AND substr(Rev_Salpos,1,1)='5' 	THEN Sal_ord_bal_ord='N';
IF CUST_NR='061210' AND Sal_ord_bal_ord='Y' 		THEN OnTime_Check="";  
IF CUST_NR='061210' AND Sal_ord_bal_ord='Y' 		THEN InFullCheck=""; 
IF CUST_NR='061210' AND Sal_ord_bal_ord='Y' 		THEN OTIF="";   
RUN;


PROC SQL;
CREATE TABLE work.WO_Prep_Orders AS
SELECT 	a.*, 
		b.Fin_year 		AS OTIF_Fin_year,
		b.Fin_per  		AS OTIF_Fin_Per,
		b.Week_number 	AS OTIF_Wk_nr
FROM work.WO_Prep_Orders a LEFT OUTER JOIN db2data.Periods b ON a.Shipm_Last_Load_Date=b.Date;
QUIT;

PROC SORT DATA=work.WO_Prep_Orders nodup; BY Company Sal_ord_nr Sal_ord_pos; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (DROP TABLE DB2ADMIN.WO_Prep_Check) by baan;
QUIT;

PROC APPEND BASE=db2data.WO_Prep_Check DATA=work.WO_Prep_Orders FORCE; WHERE OTIF_Fin_year>=2019 OR OTIF_Fin_year=.; RUN;


PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.WO_Prep_Check TO USER INFODBC )  by baan;
EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.WO_Prep_Check TO USER FINODBC )  by baan;
QUIT;


