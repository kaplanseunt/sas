libname realdb7  odbc dsn='realdb7'         user="root" password="1Safetyok";
libname sofonq_l odbc dsn='SofonQ_Live'     user=Sofon  password=Sofon  ;

OPTION NOSYNTAXCHECK;
/**********************/
/* prd_bas_workcenter */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_bas_workcenter as select * from connection to baan
   (SELECT  a.t_cwoc AS code,
   			a.t_cwoc AS description
   FROM      ttirou102130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_bas_workcenter_EAP as select * from connection to baan
   (SELECT  a.t_cwoc AS code,
   			a.t_cwoc AS description
   FROM      ttirou102300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_bas_workcenter_KSI as select * from connection to baan
   (SELECT  a.t_cwoc AS code,
   			a.t_cwoc AS description
   FROM      ttirou102400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_bas_workcenter_AFM as select * from connection to baan
   (SELECT  a.t_cwoc AS code,
   			a.t_cwoc AS description
   FROM      ttirou102601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.prd_bas_workcenter DATA=work.prd_bas_workcenter_EAP; RUN;
PROC APPEND BASE=work.prd_bas_workcenter DATA=work.prd_bas_workcenter_KSI; RUN;
PROC APPEND BASE=work.prd_bas_workcenter DATA=work.prd_bas_workcenter_AFM; RUN;

PROC SORT data=work.prd_bas_workcenter nodupkey; by code; RUN;

DATA work.prd_bas_workcenter; SET work.prd_bas_workcenter ;
cleaninglossL=0;
tray1quantityL=0;
tray2quantityL=0;
archived=0;
createddate=datetime();
advancepayment=0;
days=0;
dataareaid=0;
createdby='SAS-Job';
IF CODE='EAP' THEN DELETE;
RUN;



/**************************/
/* com_fin_termsofpayment */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_fin_termsofpayment as select * from connection to baan
   (SELECT  a.t_cpay AS code,
   			a.t_dsca AS description
   FROM      ttcmcs013130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_fin_termsofpayment_EAP as select * from connection to baan
   (SELECT  a.t_cpay AS code,
   			a.t_dsca AS description
   FROM      ttcmcs013300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_fin_termsofpayment_KSI as select * from connection to baan
   (SELECT  a.t_cpay AS code,
   			a.t_dsca AS description
   FROM      ttcmcs013400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_fin_termsofpayment_AFM as select * from connection to baan
   (SELECT  a.t_cpay AS code,
   			a.t_dsca AS description
   FROM      ttcmcs013601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.com_fin_termsofpayment DATA=work.com_fin_termsofpayment_EAP; RUN;
PROC APPEND BASE=work.com_fin_termsofpayment DATA=work.com_fin_termsofpayment_KSI; RUN;
PROC APPEND BASE=work.com_fin_termsofpayment DATA=work.com_fin_termsofpayment_AFM; RUN;

PROC SORT data=work.com_fin_termsofpayment nodupkey; by code; RUN;


DATA work.com_fin_termsofpayment; SET work.com_fin_termsofpayment ;
archived=0;
createddate=datetime();
advancepayment=0;
days=0;
dataareaid=0;
createdby='SAS-Job';
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND base=realdb7.update_table data=work.com_fin_termsofpayment force; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE ( UPDATE com_fin_termsofpayment as a inner join update_table as b on a.code=b.code SET  a.description=b.description ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.com_fin_termsofpayment AS 
SELECT  a.*,	
		b.code AS Check_PaymentCode Label='Check_PaymentCode'
FROM work.com_fin_termsofpayment a LEFT OUTER JOIN RealDB7.com_fin_termsofpayment b ON a.code=b.code ;
QUIT;

PROC APPEND BASE=RealDB7.com_fin_termsofpayment DATA=work.com_fin_termsofpayment FORCE; WHERE Check_PaymentCode=''; RUN;


/******************/
/* cat_mrk_brand */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.brands as select * from connection to baan
   (SELECT  a.t_brnd AS code,
			a.t_name AS description1
FROM ttdslx310130 a);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.brands_EAP as select * from connection to baan
   (SELECT  a.t_brnd AS code,
			a.t_name AS description1
FROM ttdslx310300 a);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.brands_KSI as select * from connection to baan
   (SELECT  a.t_brnd AS code,
			a.t_name AS description1
FROM ttdslx310400 a);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.brands_AFM as select * from connection to baan
   (SELECT  a.t_brnd AS code,
			a.t_name AS description1
FROM ttdslx310601 a);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.brands DATA=work.brands_EAP; RUN;
PROC APPEND BASE=work.brands DATA=work.brands_KSI; RUN;
PROC APPEND BASE=work.brands DATA=work.brands_AFM; RUN;

PROC SORT DATA=work.brands nodupkey; BY code; RUN;

DATA work.brands; SET work.brands ;
FORMAT description $30.;
description=description1;
IF LENGTH(Description)>30 THEN description='-';
archived=0;
createddate=datetime();
dataareaid=0;
version=0;
createdby='SAS-Job';
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.brands FORCE; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE ( UPDATE cat_mrk_brand as a inner join update_table as b on a.code=b.code SET  a.description=b.description ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.brands AS 
SELECT  a.*,	
		b.code AS Check_Record Label='Check_Record'
FROM work.brands a LEFT OUTER JOIN RealDB7.cat_mrk_brand b ON a.code=b.code ;
QUIT;

PROC APPEND BASE=RealDB7.cat_mrk_brand DATA=work.brands FORCE; WHERE Check_Record=''; RUN;

/****************/
/* cat_itm_item */
/****************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Dimsets as select * from connection to baan
   (SELECT 	2 Company, 
   			'ECP' Company_Descr,
			a.t_dset Dimset,
   			a.t_cupn customerItemCode,
			a.t_dsca Description,
			a.t_dist Status,
			a.t_cuno Cust_nr,
			a.t_cuic Cust_nr_end,
			a.t_item Item1,
			b.t_imth ID_Method,
			b.t_mioq minimumorderquantity,
			b.t_sfst minimumstockquantity,
			a.t_suno Suppl_nr,
			a.t_prfl Procesflow
   FROM      ttdmdm995130 a LEFT OUTER JOIN ttdmdm012130 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Dimsets_EAP as select * from connection to baan
   (SELECT  3 Company,
   			'EAP' Company_Descr,
			a.t_dset Dimset,
   			a.t_cupn customerItemCode,
			a.t_dsca Description,
			a.t_dist Status,
			a.t_cuno Cust_nr,
			a.t_cuic Cust_nr_end,
			a.t_item Item1,
			b.t_imth ID_Method,
			b.t_mioq minimumorderquantity,
			b.t_sfst minimumstockquantity,
			a.t_suno Suppl_nr,
			a.t_prfl Procesflow
   FROM      ttdmdm995300 a LEFT OUTER JOIN ttdmdm012300 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Dimsets_KSI as select * from connection to baan
   (SELECT  4 Company,
   			'KSI' Company_Descr,
			a.t_dset Dimset,
   			a.t_cupn customerItemCode,
			a.t_dsca Description,
			a.t_dist Status,
			a.t_cuno Cust_nr,
			a.t_cuic Cust_nr_end,
			a.t_item Item1,
			b.t_imth ID_Method,
			b.t_mioq minimumorderquantity,
			b.t_sfst minimumstockquantity,
			a.t_suno Suppl_nr,
			a.t_prfl Procesflow
   FROM      ttdmdm995400 a LEFT OUTER JOIN ttdmdm012400 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Dimsets_AFM as select * from connection to baan
   (SELECT  5 Company,
   			'AFM' Company_Descr,
			a.t_dset Dimset,
   			a.t_cupn customerItemCode,
			a.t_dsca Description,
			a.t_dist Status,
			a.t_cuno Cust_nr,
			a.t_cuic Cust_nr_end,
			a.t_item Item1,
			b.t_imth ID_Method,
			b.t_mioq minimumorderquantity,
			b.t_sfst minimumstockquantity,
			a.t_suno Suppl_nr,
			a.t_prfl Procesflow
   FROM      ttdmdm995601 a LEFT OUTER JOIN ttdmdm012601 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.Dimsets DATA=work.Dimsets_EAP; RUN;
PROC APPEND BASE=work.Dimsets DATA=work.Dimsets_KSI; RUN;
PROC APPEND BASE=work.Dimsets DATA=work.Dimsets_AFM; RUN;

/* Get hist of company */
/*PROC SQL;*/
/*CREATE TABLE work.Dimsets AS*/
/*SELECT 	a.*,*/
/*		b.TRO_HIST_ALL AS TRO_HIST*/
/*FROM work.dimsets a */
/*LEFT OUTER JOIN db2data.dimset_transactions b ON a.company_descr=b.company AND a.dimset=b.dimset;*/
/*QUIT;*/

/* Get hist of total dimset */
/*PROC SQL;*/
/*CREATE TABLE work.Dimsets_Total AS*/
/*SELECT 	a.Dimset,*/
/*		SUM(a.TRO_HIST) AS TRO_HIST_ALL*/
/*FROM work.dimsets a */
/*GROUP BY a.dimset;*/
/*QUIT;*/
/*PROC SQL;*/
/*CREATE TABLE work.Dimsets AS*/
/*SELECT 	a.*,*/
/*		b.TRO_HIST_ALL*/
/*FROM work.dimsets a */
/*LEFT OUTER JOIN work.Dimsets_Total b ON a.dimset=b.dimset;*/
/*QUIT;*/
/**/
/*PROC SORT DATA=work.Dimsets; BY dimset; RUN;*/
/*DATA work.Dimsets; SET work.Dimsets;*/
/*BY dimset;*/
/*IF FIRST.dimset AND LAST.DIMSET THEN CHECK=0; ELSE CHECK=1;*/
/*RUN;*/
/**/
/*DATA work.Dimsets(DROP= CHECK); SET work.Dimsets;*/
/*IF CHECK=1 AND TRO_HIST=0 AND TRO_HIST_ALL NE 0 THEN DELETE; RUN;*/

PROC SORT DATA=work.Dimsets nodupkey; BY company dimset; RUN;

/* LINK UOM */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ITEM_UOM as select * from connection to baan
   (SELECT  2 Company,
			a.t_item  AS Item,
			a.t_cuni AS InventoryUnit,
			a.t_cuqp AS PurchaseUnit
   FROM      ttiitm001130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ITEM_UOM_EAP as select * from connection to baan
   (SELECT  3 Company,
			a.t_item  AS Item,
			a.t_cuni AS InventoryUnit,
			a.t_cuqp AS PurchaseUnit
   FROM      ttiitm001300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ITEM_UOM_KSI as select * from connection to baan
   (SELECT  4 Company,
			a.t_item  AS Item,
			a.t_cuni AS InventoryUnit,
			a.t_cuqp AS PurchaseUnit
   FROM      ttiitm001400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ITEM_UOM_AFM as select * from connection to baan
   (SELECT  5 Company,
			a.t_item  AS Item,
			a.t_cuni AS InventoryUnit,
			a.t_cuqp AS PurchaseUnit
   FROM      ttiitm001601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.ITEM_UOM data=work.ITEM_UOM_EAP; RUN;
PROC APPEND BASE=work.ITEM_UOM data=work.ITEM_UOM_KSI; RUN;
PROC APPEND BASE=work.ITEM_UOM data=work.ITEM_UOM_AFM; RUN;

PROC SQL;
CREATE TABLE work.ITEM_UOM AS
SELECT  a.*,
		b.id AS quantityUOM,
		c.id AS purchaseUOM
FROM work.ITEM_UOM a
LEFT OUTER JOIN realdb7.com_log_uom b ON a.InventoryUnit=b.code
LEFT OUTER JOIN realdb7.com_log_uom c ON a.PurchaseUnit=c.code;
QUIT;

PROC SQL;
CREATE TABLE work.Dimsets AS
SELECT  a.*,
		b.quantityUOM,
		b.purchaseUOM
FROM work.Dimsets a
LEFT OUTER JOIN work.ITEM_UOM b ON a.company=b.company AND a.Item1=b.item;
QUIT;


DATA work.Dimsets; SET work.Dimsets;
IF itemGroup=. THEN itemGroup=1;
IF quantityUOM=. THEN quantityUOM=1;
IF purchaseUOM=. THEN purchaseUOM=1;
costDistributionType="Q";
costComponent=1;
IF customerItemCode='' 		THEN customerItemCode='-';
/* Status */
IF status=1 				THEN itemstatus='DR';
IF status=2 				THEN itemstatus='AC';
IF status=3 				THEN itemstatus='BL';
IF status=4 				THEN itemstatus='BL';
version=0;
archived=0;
IF status NE 2 				THEN archived=1;
createddate=datetime();
costprice=0.00;
labelcount=1;
Code=dimset;
itemForm='C';
IF ID_Method=1 				THEN itemForm='P';
IF ID_Method=.	THEN DELETE;
IF minimumorderquantity=. 	THEN minimumorderquantity=0;
IF minimumstockquantity=. 	THEN minimumstockquantity=0;
dataAreaId=0;
IF Description="" 			THEN Description="-";
applother=0;
applpurchase=0;
applSales=0;
applSfcIssue=0;
applSfcReceipt=0;
salesprice=0;
createdby='SAS-Job';
site=company;

/* sourcingType / orderSystem / orderPolicy */
IF index(dimset,'-I')>0 THEN DO; sourcingType='PUR'; orderSystem='MRP'; orderPolicy='ORD'; END;

IF index(dimset,'-O')>0 THEN DO; sourcingType='PRD'; orderSystem='MRP'; orderPolicy='ORD'; END;

IF index(dimset,'-U')>0 THEN DO; sourcingType='PRD'; orderSystem='MRP'; orderPolicy='ORD'; END;

IF substr(dimset,1,1) IN ('1','2') AND Procesflow NE 'PO'  THEN DO; sourcingType='PRD'; orderSystem='MRP'; orderPolicy='ORD'; END;

IF substr(dimset,1,1)='3' THEN DO; sourcingType='PUR'; orderSystem='MRP'; orderPolicy='ORD'; END;
IF substr(dimset,1,1)='3' AND company=5 THEN DO; sourcingType='PUR'; orderSystem='SIC'; orderPolicy='ANO'; END;

IF substr(dimset,1,1)='9' THEN DO; sourcingType='PRD'; orderSystem='MRP'; orderPolicy='ORD'; END;

IF Procesflow='PO'  THEN DO; sourcingType='PUR'; orderSystem='MRP'; orderPolicy='ORD'; END;

IF substr(dimset,1,1)='4' THEN DO; sourcingType='PUR'; orderSystem='SIC'; orderPolicy='ANO'; END;

IF item1 IN ('LAK','PRI') THEN DO; sourcingType='PUR'; orderSystem='SIC'; orderPolicy='ANO'; END;

IF item1='FOLZKL' THEN DO; sourcingType='PUR'; orderSystem='MAN'; orderPolicy='ANO'; END;
RUN;


PROC SQL;
CREATE TABLE Work.Dimsets AS 
SELECT  a.*,
		b.ID AS itemType Label='itemType'
FROM work.Dimsets a LEFT OUTER JOIN RealDB7.cat_itm_itemtype b ON a.Item1=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Dimsets AS 
SELECT  a.*,
		b.ID AS Substrate Label='Substrate'
FROM work.Dimsets a LEFT OUTER JOIN RealDB7.cat_sub_substrate b ON a.Item1=b.code ;
QUIT;


PROC SQL;
CREATE TABLE Work.Dimsets AS 
SELECT  a.*,
		b.ID AS Supplier Label='Supplier'
FROM work.Dimsets a LEFT OUTER JOIN RealDB7.com_par_partner b ON compress(a.Suppl_nr)=compress(b.code);
QUIT;

/* CORRECTION */
DATA work.cat_itm_item; SET work.Dimsets;
IF ITEM1='OMW' THEN itemtype=17; 
RUN;

PROC SORT DATA=work.cat_itm_item nodupkey; BY code; RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.cat_itm_item FORCE; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
cat_itm_item as a inner join update_table as b on a.code=b.code

SET  
a.archived=b.archived, a.description=b.description,  a.itemstatus=b.itemstatus,
a.Substrate=b.Substrate, a.itemtype=b.itemtype, a.itemForm=b.itemForm, a.quantityUOM=b.quantityUOM, a.purchaseUOM=b.purchaseUOM
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.cat_itm_item AS 
SELECT  a.*,
		b.ID AS Check_Dimset Label='Check_Dimset'
FROM work.cat_itm_item a LEFT OUTER JOIN RealDB7.cat_itm_item b ON a.code=b.code  ;
QUIT;

PROC APPEND BASE=RealDB7.cat_itm_item DATA=work.cat_itm_item FORCE; WHERE Check_Dimset=. AND itemtype NE .; RUN;


/***** inv_itm_inventoryitem *****/
PROC SQL;
CREATE TABLE work.Dimsets AS 
SELECT  a.*,
		b.id AS item
FROM work.Dimsets a LEFT OUTER JOIN RealDB7.cat_itm_item b ON a.code=b.code ;
QUIT;

DATA work.Dimsets; SET work.Dimsets;
IF item1='ALU' AND substr(dimset,1,1)='9' THEN wfTeamForWpMaterial=13;
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.dimsets FORCE; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
inv_itm_inventoryitem as a inner join update_table as b on a.site=b.site AND a.item=b.item

SET  
a.archived=b.archived, a.costprice=b.costprice, a.labelcount=b.labelcount, a.minimumorderquantity=b.minimumorderquantity, a.minimumstockquantity=b.minimumstockquantity,
a.sourcingType=b.sourcingType, a.orderSystem=b.orderSystem, a.orderPolicy=b.orderPolicy, a.wfTeamForWpMaterial=b.wfTeamForWpMaterial
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE work.Dimsets AS 
SELECT  a.*,
		b.ID AS Check_inv_item Label='Check_inv_item'
FROM work.Dimsets a LEFT OUTER JOIN RealDB7.inv_itm_inventoryitem b ON a.site=b.site AND a.item=b.item ;
QUIT;

PROC APPEND BASE=RealDB7.inv_itm_inventoryitem DATA=work.Dimsets FORCE; WHERE Check_inv_item=. AND sourcingType NE '' ; RUN;


/*************************/
/* mat_itm_purchaseitem */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_purchaseitem as select * from connection to baan
   (SELECT 	2 Company,
			a.t_dset Dimset,
   			a.t_cupn supplieritemcode,
			a.t_suno Suppl_nr
   FROM      ttdmdm995130 a LEFT OUTER JOIN ttdmdm012130 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_purchaseitem_EAP as select * from connection to baan
   (SELECT 	3 Company,
			a.t_dset Dimset,
   			a.t_cupn supplieritemcode,
			a.t_suno Suppl_nr
   FROM      ttdmdm995300 a LEFT OUTER JOIN ttdmdm012300 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_purchaseitem_KSI as select * from connection to baan
   (SELECT 	4 Company,
			a.t_dset Dimset,
   			a.t_cupn supplieritemcode,
			a.t_suno Suppl_nr
   FROM      ttdmdm995400 a LEFT OUTER JOIN ttdmdm012400 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_purchaseitem_AFM as select * from connection to baan
   (SELECT 	5 Company,
			a.t_dset Dimset,
   			a.t_cupn supplieritemcode,
			a.t_suno Suppl_nr
   FROM      ttdmdm995601 a LEFT OUTER JOIN ttdmdm012601 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.mat_itm_purchaseitem DATA=work.mat_itm_purchaseitem_EAP; RUN;
PROC APPEND BASE=work.mat_itm_purchaseitem DATA=work.mat_itm_purchaseitem_KSI; RUN;
PROC APPEND BASE=work.mat_itm_purchaseitem DATA=work.mat_itm_purchaseitem_AFM; RUN;

DATA work.mat_itm_purchaseitem; SET work.mat_itm_purchaseitem;
WHERE Suppl_nr NE '';
RUN;


PROC SORT DATA=work.mat_itm_purchaseitem nodupkey; by company dimset; RUN;
PROC SQL;
CREATE TABLE work.mat_itm_purchaseitem AS 
SELECT  a.*,
		b.id AS item
FROM work.mat_itm_purchaseitem a LEFT OUTER JOIN RealDB7.cat_itm_item b ON a.Dimset=b.code ;
QUIT;
PROC SQL;
CREATE TABLE Work.mat_itm_purchaseitem AS 
SELECT  a.*,
		b.ID AS Supplier Label='Supplier'
FROM work.mat_itm_purchaseitem a LEFT OUTER JOIN RealDB7.com_par_partner b ON compress(a.Suppl_nr)=compress(b.code);
QUIT;


DATA work.mat_itm_purchaseitem; SET work.mat_itm_purchaseitem;
archived=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
materialSourcingSystem='SIC';
IF substr(dimset,1,1)=3 AND company IN (2,3) THEN materialSourcingSystem='PUR';
WHERE supplier NE . AND item NE .;
RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.mat_itm_purchaseitem; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
mat_itm_purchaseitem as a inner join update_table as b on a.item=b.item AND a.company=b.company

SET  
a.materialSourcingSystem=b.materialSourcingSystem
) by MySQL;
QUIT;



/* Insert New Records */
PROC SQL;
CREATE TABLE work.mat_itm_purchaseitem AS 
SELECT  a.*,
		b.ID AS check_record Label='check_record'
FROM work.mat_itm_purchaseitem a LEFT OUTER JOIN RealDB7.mat_itm_purchaseitem b ON a.item=b.item;
QUIT;
 
PROC APPEND BASE=RealDB7.mat_itm_purchaseitem DATA=work.mat_itm_purchaseitem FORCE; WHERE check_record=. ; RUN;


/*************************/
/* mat_itm_itemsupplier */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_itemsupplier as select * from connection to baan
   (SELECT 	a.t_dset Dimset,
   			a.t_cupn supplieritemcode,
			a.t_suno Suppl_nr
   FROM      ttdmdm995130 a LEFT OUTER JOIN ttdmdm012130 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_itemsupplier_EAP as select * from connection to baan
   (SELECT 	a.t_dset Dimset,
   			a.t_cupn supplieritemcode,
			a.t_suno Suppl_nr
   FROM      ttdmdm995300 a LEFT OUTER JOIN ttdmdm012300 b ON a.t_dset=b.t_dset );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.mat_itm_itemsupplier DATA=work.mat_itm_itemsupplier_EAP; RUN;

DATA work.mat_itm_itemsupplier; SET work.mat_itm_itemsupplier;
WHERE Suppl_nr NE '';
RUN;

PROC SORT DATA=work.mat_itm_itemsupplier nodupkey; by dimset; RUN;
PROC SQL;
CREATE TABLE work.mat_itm_itemsupplier AS 
SELECT  a.*,
		b.id AS item
FROM work.mat_itm_itemsupplier a LEFT OUTER JOIN RealDB7.cat_itm_item b ON a.Dimset=b.code ;
QUIT;
PROC SQL;
CREATE TABLE Work.mat_itm_itemsupplier AS 
SELECT  a.*,
		b.ID AS partner Label='partner'
FROM work.mat_itm_itemsupplier a LEFT OUTER JOIN RealDB7.com_par_partner b ON compress(a.Suppl_nr)=compress(b.code);
QUIT;
PROC SQL;
CREATE TABLE Work.mat_itm_itemsupplier AS 
SELECT  a.*,
		b.id AS Supplier Label='Supplier'
FROM work.mat_itm_itemsupplier a LEFT OUTER JOIN RealDB7.com_par_supplier b ON a.partner=b.partner;
QUIT;


DATA work.mat_itm_itemsupplier; SET work.mat_itm_itemsupplier;
archived=0;
createddate=datetime();
dataareaid=0;
itemSupplierStatus='P';
createdby='SAS-Job';
standardleadtimedays=0;
version=0;
WHERE supplier NE . AND item NE .;
RUN;

PROC SORT DATA=work.mat_itm_itemsupplier nodupkey; by item; RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.mat_itm_itemsupplier; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
mat_itm_itemsupplier as a inner join update_table as b on a.item=b.item AND a.supplier=b.supplier

SET  
a.itemSupplierStatus=b.itemSupplierStatus
) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE work.mat_itm_itemsupplier AS 
SELECT  a.*,
		b.ID AS check_record Label='check_record'
FROM work.mat_itm_itemsupplier a LEFT OUTER JOIN RealDB7.mat_itm_itemsupplier b ON a.item=b.item AND a.supplier=b.supplier;
QUIT;
 
PROC APPEND BASE=RealDB7.mat_itm_itemsupplier DATA=work.mat_itm_itemsupplier FORCE; WHERE supplier NE . AND check_record=. ; RUN;

/********************/
/* mat_itm_salesitem */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_salesitem as select * from connection to baan
   (SELECT 	2 Company, 
			a.t_dset Dimset,
   			a.t_cupn Customeritemcode,
			a.t_cuno Cust_nr,
			a.t_cuic Cust_nr_end,
			a.t_mrkt Markt_market,
			a.t_prgr Markt_prod_group,
			a.t_brnd Markt_brand
   FROM      ttdmdm995130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_salesitem_EAP as select * from connection to baan
   (SELECT 	3 Company, 
			a.t_dset Dimset,
   			a.t_cupn Customeritemcode,
			a.t_cuno Cust_nr,
			a.t_cuic Cust_nr_end,
			a.t_mrkt Markt_market,
			a.t_prgr Markt_prod_group,
			a.t_brnd Markt_brand
   FROM      ttdmdm995300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_salesitem_KSI as select * from connection to baan
   (SELECT 	4 Company, 
			a.t_dset Dimset,
   			a.t_cupn Customeritemcode,
			a.t_cuno Cust_nr,
			a.t_cuic Cust_nr_end,
			a.t_mrkt Markt_market,
			a.t_prgr Markt_prod_group,
			a.t_brnd Markt_brand
   FROM      ttdmdm995400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_itm_salesitem_AFM as select * from connection to baan
   (SELECT 	5 Company, 
			a.t_dset Dimset,
   			a.t_cupn Customeritemcode,
			a.t_cuno Cust_nr,
			a.t_cuic Cust_nr_end,
			a.t_mrkt Markt_market,
			a.t_prgr Markt_prod_group,
			a.t_brnd Markt_brand
   FROM      ttdmdm995601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.mat_itm_salesitem DATA=work.mat_itm_salesitem_EAP; RUN;
PROC APPEND BASE=work.mat_itm_salesitem DATA=work.mat_itm_salesitem_KSI; RUN;
PROC APPEND BASE=work.mat_itm_salesitem DATA=work.mat_itm_salesitem_AFM; RUN;

PROC SQL;
CREATE TABLE work.mat_itm_salesitem AS 
SELECT a.*,
		b.id AS item
FROM work.mat_itm_salesitem a LEFT OUTER JOIN RealDB7.cat_itm_item b ON a.Dimset=b.code ;
QUIT;

PROC SQL;
CREATE TABLE work.mat_itm_salesitem AS 
SELECT  a.*,
		b.ID AS Customer Label='Customer'
FROM work.mat_itm_salesitem a 
LEFT OUTER JOIN RealDB7.com_par_partner b ON compress(a.Cust_nr)=compress(b.code) ;
QUIT;


PROC SQL;
CREATE TABLE work.mat_itm_salesitem AS 
SELECT  a.*,
		b.ID AS CustomerIC Label='CustomerIC'
FROM work.mat_itm_salesitem a LEFT OUTER JOIN RealDB7.com_par_partner b ON compress(a.Cust_nr_end)=compress(b.code);
QUIT;


PROC SQL;
CREATE TABLE work.mat_itm_salesitem AS 
SELECT  a.*,
		b.id AS brand
FROM work.mat_itm_salesitem a LEFT OUTER JOIN RealDB7.cat_mrk_brand b ON a.Markt_brand=b.code ;
QUIT;

DATA work.mat_itm_salesitem; SET work.mat_itm_salesitem;
IF Markt_market='010' THEN Markt_market1='AP';
IF Markt_market='030' THEN Markt_market1='RV';
IF Markt_market='040' THEN Markt_market1='TR';
RUN;

PROC SQL;
CREATE TABLE work.mat_itm_salesitem AS 
SELECT  a.*,
		b.id AS market
FROM work.mat_itm_salesitem a LEFT OUTER JOIN RealDB7.cat_mrk_market b ON a.Markt_market1=b.code ;
QUIT;

DATA work.mat_itm_salesitem; SET work.mat_itm_salesitem;
IF customeritemcode='' 		THEN customeritemcode='-';
archived=0;
salesprice=0;
createddate=datetime();
dataareaid=0;
version=0;
IF brand=. 					THEN brand=1;
IF market=. AND company IN (2,4,5) 	THEN market=39;
IF market=. AND company=3 	THEN market=37;
createdby='SAS-Job';
WHERE customer NE .;
RUN;

PROC SORT DATA=work.mat_itm_salesitem nodupkey; BY company dimset; RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.mat_itm_salesitem; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
mat_itm_salesitem as a inner join update_table as b on a.item=b.item AND a.company=b.company 

SET  
a.customeritemcode=b.customeritemcode, a.customer=b.customer, a.CustomerIC=b.CustomerIC, a.brand=b.brand, a.market=b.market
) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE work.mat_itm_salesitem AS 
SELECT  a.*,
		b.ID AS check_record Label='check_record'
FROM work.mat_itm_salesitem a LEFT OUTER JOIN RealDB7.mat_itm_salesitem b ON a.item=b.item AND a.company=b.company ;
QUIT;
 
PROC APPEND BASE=RealDB7.mat_itm_salesitem DATA=work.mat_itm_salesitem FORCE; WHERE customer NE . AND check_record=.  AND Item NE .; RUN;

/**** ITEMS ****/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.items as select * from connection to baan
   (SELECT  a.t_item code,
			a.t_dsca Description,
			a.t_suno Suppl_nr
   FROM      ttiitm001130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.items_EAP as select * from connection to baan
   (SELECT  a.t_item code,
			a.t_dsca Description,
			a.t_suno Suppl_nr
   FROM      ttiitm001300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.items_KSI as select * from connection to baan
   (SELECT  a.t_item code,
			a.t_dsca Description,
			a.t_suno Suppl_nr
   FROM      ttiitm001400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.items_AFM as select * from connection to baan
   (SELECT  a.t_item code,
			a.t_dsca Description,
			a.t_suno Suppl_nr
   FROM      ttiitm001601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.items DATA=work.items_EAP; RUN;
PROC APPEND BASE=work.items DATA=work.items_KSI; RUN;
PROC APPEND BASE=work.items DATA=work.items_AFM; RUN;

PROC SORT DATA=work.items nodupkey; BY code; RUN;

DATA work.items; SET work.items;
itemtype=20;
itemGroup=1;
quantityUOM=1;
purchaseUOM=1;
costDistributionType="Q";
costComponent=1;
itemstatus='AC';
version=0;
archived=0;
createddate=datetime();
costprice=0.00;
labelcount=1;
salesprice=0.00;
itemForm='N';
IF minimumorderquantity=. 	THEN minimumorderquantity=0;
IF minimumstockquantity=. 	THEN minimumstockquantity=0;
dataAreaId=0;
IF Description="" 			THEN Description="-";
applother=0;
applpurchase=0;
applSales=0;
applSfcIssue=0;
applSfcReceipt=0;
createdby='SAS-Job';
WHERE substr(code,1,2)='U-';
RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.items; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
cat_itm_item as a inner join update_table as b on a.code=b.code

SET  
a.itemform=b.itemform
) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE work.items AS 
SELECT  a.*,
		b.ID AS check_record Label='check_record'
FROM work.items a LEFT OUTER JOIN RealDB7.cat_itm_item b ON a.code=b.code ;
QUIT;

PROC APPEND BASE=RealDB7.cat_itm_item DATA=work.items FORCE; WHERE check_record=.; RUN;


/***********************/
/* cat_itm_itempartner */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.partneritems as select * from connection to baan
   (SELECT  a.t_dset code,
   			a.t_cupn partnerItemCode,
			a.t_cuno Cust_nr
   FROM      ttdmdm995130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.partneritems_EAP as select * from connection to baan
   (SELECT  a.t_dset code,
   			a.t_cupn partnerItemCode,
			a.t_cuno Cust_nr
   FROM      ttdmdm995300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.partneritems_KSI as select * from connection to baan
   (SELECT  a.t_dset code,
   			a.t_cupn partnerItemCode,
			a.t_cuno Cust_nr
   FROM      ttdmdm995400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.partneritems_AFM as select * from connection to baan
   (SELECT  a.t_dset code,
   			a.t_cupn partnerItemCode,
			a.t_cuno Cust_nr
   FROM      ttdmdm995601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.partneritems DATA=work.partneritems_EAP; RUN;
PROC APPEND BASE=work.partneritems DATA=work.partneritems_KSI; RUN;
PROC APPEND BASE=work.partneritems DATA=work.partneritems_AFM; RUN;

PROC SQL;
CREATE TABLE work.partneritems AS 
SELECT a.*,
		b.ID AS partner Label='partner'
FROM work.partneritems a 
LEFT OUTER JOIN RealDB7.com_par_partner b ON compress(a.Cust_nr)=compress(b.code) ;
QUIT;


PROC SQL;
CREATE TABLE work.partneritems AS 
SELECT a.*,
		b.ID AS item Label='item'
FROM work.partneritems a 
LEFT OUTER JOIN RealDB7.cat_itm_item b ON a.code=b.code ;
QUIT;


DATA work.partneritems; SET work.partneritems ;
archived=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
WHERE item NE . AND partner NE . AND partnerItemCode NE '';
RUN;

PROC SORT DATA=work.partneritems nodupkey; BY item partner; RUN;



/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.partneritems; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
cat_itm_itempartner as a inner join update_table as b on a.item=b.item AND a.partner=b.partner

SET  
a.partnerItemCode=b.partnerItemCode
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE work.partneritems AS 
SELECT a.*,
		b.ID AS check_partneritem Label='check_partneritem'
FROM work.partneritems a LEFT OUTER JOIN RealDB7.cat_itm_itempartner b ON a.item=b.item AND a.partner=b.partner ;
QUIT;

PROC APPEND BASE=RealDB7.cat_itm_itempartner DATA=work.partneritems FORCE; WHERE check_partneritem=.; RUN;

/*******************/
/* com_par_partner  SUPPLIERS*/
/*******************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Suppliers as select * from connection to baan
   (SELECT  a.t_suno   		   		Code,
            a.t_nama   		   		Name,
			a.t_pstc		   		Suppl_postcode,
			trim(a.t_ccty) 		 AS Country_descr,
			b.t_tfcd		   		Tel_pref,
			a.t_telp		   		Suppl_tel_nr1,
			b.t_fxcd		   		Fax_pref,
			a.t_tefx		   		Suppl_fax_nr1,
			a.t_cpay		   		Cust_paym_code,
			a.t_cdec		   		Cust_term_del,
			a.t_sust		   		Partnerstatus,
			trim(a.t_ccur) 		 AS Currency_descr,
			a.t_cbrn 	 		 AS LineOfBusiness1,
			a.t_cpay		   		TermsOfPayment1,
			a.t_cdec		   		TermsOfDelivery1,
			lower(trim(a.t_clan))	Language1,
			c.t_reli 			 AS Reliability1
   FROM         ttccom020130 a 
LEFT OUTER JOIN		ttcmcs010130 b ON a.t_ccty=b.t_ccty
LEFT OUTER JOIN 	ttdpux002130 c ON a.t_suno=c.t_suno);
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Suppliers_EAP as select * from connection to baan
   (SELECT  a.t_suno   					Code,
            a.t_nama   					Name,
			a.t_pstc					Suppl_postcode,
			trim(a.t_ccty) 			 AS Country_descr,
			b.t_tfcd					Tel_pref,
			a.t_telp					Suppl_tel_nr1,
			b.t_fxcd					Fax_pref,
			a.t_tefx					Suppl_fax_nr1,
			a.t_cpay					Cust_paym_code,
			a.t_cdec					Cust_term_del,
			a.t_sust					Partnerstatus,
			trim(a.t_ccur) 			 AS	Currency_descr,
			a.t_cbrn 				 AS	LineOfBusiness1,
			a.t_cpay					TermsOfPayment1,
			a.t_cdec					TermsOfDelivery1,
			lower(trim(a.t_clan))		Language1,
			c.t_reli 				 AS Reliability1
   FROM         ttccom020300 a 
LEFT OUTER JOIN		ttcmcs010300 b ON a.t_ccty=b.t_ccty
LEFT OUTER JOIN 	ttdpux002300 c ON a.t_suno=c.t_suno);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.suppliers DATA=work.Suppliers_EAP; RUN;

PROC SORT DATA=work.suppliers nodupkey; BY code ; RUN;


DATA work.Suppliers; SET work.Suppliers;
/* Correction */
IF  Country_descr='TU' THEN Country_descr='TR';
IF  Country_descr='ZZ' THEN Country_descr='VG';
RUN;


PROC SQL;
CREATE TABLE Work.Suppliers AS 
SELECT a.*,
		b.ID AS Currency Label='Currency'
FROM work.Suppliers a LEFT OUTER JOIN realdb7.sys_loc_currency b ON   a.currency_descr=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Suppliers AS 
SELECT a.*,
		b.ID AS Country Label='Country'
FROM work.Suppliers a LEFT OUTER JOIN realdb7.sys_loc_country b ON   a.Country_descr=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Suppliers AS 
SELECT a.*,
		b.ID AS LineOfBusiness Label='LineOfBusiness'
FROM work.Suppliers a LEFT OUTER JOIN realdb7.com_par_lineofbusiness b ON   a.LineOfBusiness1=b.code ;
QUIT;

Data work.Suppliers ; SET work.Suppliers;
/* Correction */
IF Language1='gb' THEN Language1='en';
IF Language1='dk' THEN Language1='da';
IF Language1='at' THEN Language1='de';
IF Language1='us' THEN Language1='en';
IF Language1='ch' THEN Language1='cs';
IF Language1='ie' THEN Language1='en';
IF Language1='tu' THEN Language1='tr';
IF Language1='za' THEN Language1='af';
IF Language1='cn' THEN Language1='zh';
IF Language1='rs' THEN Language1='ru';
RUN;

PROC SQL;
CREATE TABLE Work.Suppliers AS 
SELECT a.*,
		b.ID AS Language Label='Language'
FROM work.Suppliers a LEFT OUTER JOIN realdb7.sys_loc_language b ON   a.Language1=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Suppliers AS 
SELECT a.*,
		b.ID AS TermsOfPayment Label='TermsOfPayment'
FROM work.Suppliers a LEFT OUTER JOIN realdb7.com_fin_termsofpayment b ON   a.TermsOfPayment1=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Suppliers AS 
SELECT a.*,
		b.ID AS TermsOfDelivery Label='TermsOfDelivery'
FROM work.Suppliers a LEFT OUTER JOIN realdb7.com_log_termsofdelivery b ON   a.TermsOfDelivery1=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Suppliers AS 
SELECT a.*,
		b.ID AS calendar Label='calendar'
FROM work.Suppliers a LEFT OUTER JOIN realdb7.com_cal_calendar b ON   a.code=b.domainentitycode;
QUIT;


/* 28-11-2023 Get Market for Company Relation */
PROC SQL;
CREATE TABLE work.Suppliers AS
SELECT  a.*,
		b.Market
FROM work.Suppliers a LEFT OUTER JOIN db2data.branches b ON a.LineOfBusiness1=b.branch;
QUIT;

PROC SORT DATA=work.Suppliers nodupkey; BY code; RUN;


DATA work.Suppliers ; SET work.Suppliers;
baanCunoSuno=Code;
partnerlegaltype="B";
version=0;
archived=0;
createddate=datetime();
partnertype=1;
Count=_N_;
creditlimitint=0;
dataareaid=0;
code=compress(code);
Partnerstatus=1;
company=2;
createdby='SAS-Job';
IF Reliability1=1 				THEN Reliability='R';
IF Reliability1=2 				THEN Reliability='N';
IF Reliability1=. 				THEN Reliability='U';
/* Market scripting */
IF Market='AP' 					THEN company=3;
/* Partner Correctie*/
IF code IN ('20331','013331') 	THEN company=3;
IF code IN ('20330','013330') 	THEN company=2;
WHERE CODE NE '';
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.Suppliers; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
com_par_partner as a inner join update_table as b on a.code=b.code

SET  
a.archived=b.archived, a.creditlimitint=b.creditlimitint, a.name=b.name, a.country=b.country, a.currency=b.currency, 
a.language=b.language, a.lineofbusiness=b.lineofbusiness, a.partnerstatus=b.partnerstatus,
a.termsofdelivery=b.termsofdelivery, a.termsofpayment=b.termsofpayment, a.calendar=b.calendar, a.baanCunoSuno=b.baanCunoSuno; ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.Suppliers AS 
SELECT a.*,
		b.ID AS Check_Supplier Label='Check_Supplier'
FROM work.Suppliers a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.code=b.code;
QUIT;

PROC APPEND BASE=RealDB7.com_par_partner DATA=work.Suppliers FORCE; WHERE Check_Supplier=.; RUN;



/********************/
/* com_par_supplier */
/********************/
PROC SQL;
CREATE TABLE work.Suppliers AS 
SELECT a.*,
		b.ID AS partner Label='partner'
FROM work.Suppliers a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.code=b.code;
QUIT;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.Suppliers; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
com_par_supplier as a inner join update_table as b on a.partner=b.partner

SET  
a.Reliability=b.Reliability; ) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE work.Suppliers AS 
SELECT a.*,
		b.Reliability AS check_par_suppl Label='check_par_suppl'
FROM work.Suppliers a LEFT OUTER JOIN RealDB7.com_par_supplier b ON a.partner=b.partner;
QUIT;

PROC APPEND BASE=RealDB7.com_par_supplier DATA=work.Suppliers FORCE; WHERE check_par_suppl=''; RUN;


/**** CUSTOMERS ****/
/*******************/
/* com_par_partner */
/*******************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Customers as select * from connection to baan
   (SELECT  'ECP'						AS Company_Descr,
			a.t_cuno   					Code,
            a.t_nama   					Name,
			a.t_pstc					Cust_postcode,
			trim(a.t_ccty) 		AS   	Country_descr,
			b.t_tfcd					Tel_pref,
			a.t_telp					Cust_tel_nr1,
			b.t_fxcd					Fax_pref,
			a.t_tefx					Cust_fax_nr1,
			a.t_pctf   					Cust_par_code,
			a.t_crte					Cust_route1,
			a.t_crlr					Creditlimitint,
			a.t_crat					Creditrating1,
			a.t_cpay					Cust_paym_code,
			a.t_cdec					Cust_term_del,
			a.t_cnpa					Partnerstatus,
			a.t_prio					Cust_prio_code,
            a.t_cbrn   					Branch,
            a.t_creg   					RepresentativeExt1,
            a.t_crep   					RepresentativeInt1,
			a.t_fovn					VatNumber,
			trim(a.t_ccur) 		AS		Currency_descr,
			trim(a.t_cbrn) 		AS		LineOfBusiness1,
			a.t_cpay					TermsOfPayment1,
			a.t_cdec					TermsOfDelivery1,
			lower(trim(a.t_clan))		Language1
   FROM         ttccom010130 a,
				ttcmcs010130 b
   WHERE        a.t_ccty   = b.t_ccty  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Customers_EAP as select * from connection to baan
   (SELECT  'EAP'						AS Company_Descr,
			a.t_cuno   					Code,
            a.t_nama   					Name,
			a.t_pstc					Cust_postcode,
			trim(a.t_ccty) 		AS   	Country_descr,
			b.t_tfcd					Tel_pref,
			a.t_telp					Cust_tel_nr1,
			b.t_fxcd					Fax_pref,
			a.t_tefx					Cust_fax_nr1,
			a.t_pctf   					Cust_par_code,
			a.t_crte					Cust_route1,
			a.t_crlr					creditlimitint,
			a.t_crat					creditrating1,
			a.t_cpay					Cust_paym_code,
			a.t_cdec					Cust_term_del,
			a.t_cnpa					partnerstatus,
			a.t_prio					Cust_prio_code,
            a.t_cbrn   					branch,
            a.t_creg   					representativeExt1,
            a.t_crep   					representativeInt1,
			a.t_fovn					VatNumber,
			trim(a.t_ccur) 		AS		currency_descr,
			trim(a.t_cbrn) 		AS		LineOfBusiness1,
			a.t_cpay					TermsOfPayment1,
			a.t_cdec					TermsOfDelivery1,
			lower(trim(a.t_clan))		Language1
   FROM         ttccom010300 a,
				ttcmcs010300 b
   WHERE        a.t_ccty   = b.t_ccty  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.Customers DATA=work.Customers_EAP FORCE; RUN;

/*****************************/
/* Get hist of company sales */
PROC SQL;
CREATE TABLE work.Sales_Cust AS
SELECT 	a.Company,
		a.Cust_nr,
		SUM(a.WEIGHT) AS WEIGHT
FROM db2data.cust_cm a 
GROUP BY a.Company, a.cust_nr;
QUIT;
PROC SQL;
CREATE TABLE work.Customers AS
SELECT 	a.*,
		b.WEIGHT
FROM work.Customers a 
LEFT OUTER JOIN work.Sales_Cust b ON a.company_descr=b.company AND a.Code=b.Cust_nr;
QUIT;

PROC SQL;
CREATE TABLE work.Sales_Total AS
SELECT a.Cust_nr,
		SUM(a.WEIGHT) AS WEIGHT_ALL
FROM db2data.cust_cm a 
GROUP BY a.cust_nr;
QUIT;
PROC SQL;
CREATE TABLE work.Customers AS
SELECT 	a.*,
		b.WEIGHT_ALL
FROM work.Customers a 
LEFT OUTER JOIN work.Sales_Total b ON a.Code=b.Cust_nr;
QUIT;

PROC SORT DATA=work.Customers; BY Code; RUN;
DATA work.Customers; SET work.Customers;
BY Code;
IF FIRST.Code AND LAST.Code THEN CHECK=0; ELSE CHECK=1;
RUN;

DATA work.Customers(DROP= CHECK); SET work.Customers;
IF CHECK=1 AND WEIGHT_ALL NOT IN (0,.) AND WEIGHT IN (0,.) THEN DELETE; RUN;

PROC SORT DATA=work.Customers nodupkey; BY Code; RUN;

DATA work.Customers; SET work.Customers;
Employee_Nr=compress(put(representativeInt1,6.));
IF  Country_descr='TU' THEN Country_descr='TR';
RUN;

/* employee nr */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.BaanUsers as select * from connection to baan
   (SELECT  	trim(a.t_cspa) 	AS Employee_Nr,
   				a.t_user 		AS BaanUser
   FROM         ttdpur980130 a 
WHERE a.t_user <> 'dummy');
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.BaanUsers_EAP as select * from connection to baan
   (SELECT  	trim(a.t_cspa) 	AS Employee_Nr,
   				a.t_user 		AS BaanUser
   FROM         ttdpur980300 a 
WHERE a.t_user <> 'dummy');
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.BaanUsers_KSI as select * from connection to baan
   (SELECT  	trim(a.t_cspa) 	AS Employee_Nr,
   				a.t_user 		AS BaanUser
   FROM         ttdpur980400 a 
WHERE a.t_user <> 'dummy');
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.BaanUsers_AFM as select * from connection to baan
   (SELECT  	trim(a.t_cspa) 	AS Employee_Nr,
   				a.t_user 		AS BaanUser
   FROM         ttdpur980601 a 
WHERE a.t_user <> 'dummy');
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.BaanUsers data=work.BaanUsers_EAP; RUN;
PROC APPEND BASE=work.BaanUsers data=work.BaanUsers_KSI; RUN;
PROC APPEND BASE=work.BaanUsers data=work.BaanUsers_AFM; RUN;
PROC SORT data=work.BaanUsers nodupkey; by Employee_Nr; RUN;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.BaanUser AS BaanUser Label='BaanUser'
FROM work.Customers a LEFT OUTER JOIN work.BaanUsers b ON   a.Employee_Nr=b.Employee_Nr ;
QUIT;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.id AS representativeint Label='representativeint'
FROM work.Customers a LEFT OUTER JOIN realdb7.sys_usr_user b ON   a.BaanUser=b.Code;
QUIT;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.ID AS Currency Label='Currency'
FROM work.Customers a LEFT OUTER JOIN realdb7.sys_loc_currency b ON   a.currency_descr=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.ID AS Country Label='Country'
FROM work.Customers a LEFT OUTER JOIN realdb7.sys_loc_country b ON   a.Country_descr=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.ID AS LineOfBusiness Label='LineOfBusiness'
FROM work.Customers a LEFT OUTER JOIN realdb7.com_par_lineofbusiness b ON   a.LineOfBusiness1=b.code ;
QUIT;

Data work.Customers ; Set work.Customers;
/* Correction */
IF Language1='gb' 	THEN Language1='en';
IF Language1='dk' 	THEN Language1='da';
IF Language1='at' 	THEN Language1='de';
IF Language1='ch' 	THEN Language1='cs';
IF Language1='rs' 	THEN Language1='ru';
IF VatNumber="" 	THEN VatNumber="-";
RUN;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.ID AS Language Label='Language'
FROM work.Customers a LEFT OUTER JOIN realdb7.sys_loc_language b ON   a.Language1=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.ID AS TermsOfPayment Label='TermsOfPayment'
FROM work.Customers a LEFT OUTER JOIN realdb7.com_fin_termsofpayment b ON   a.TermsOfPayment1=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.ID AS TermsOfDelivery Label='TermsOfDelivery'
FROM work.Customers a LEFT OUTER JOIN realdb7.com_log_termsofdelivery b ON   a.TermsOfDelivery1=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.ID AS calendar Label='calendar'
FROM work.Customers a LEFT OUTER JOIN realdb7.com_cal_calendar b ON   a.code=b.domainentitycode;
QUIT;

PROC SQL;
CREATE TABLE Work.Customers AS 
SELECT a.*,
		b.ID AS creditrating Label='creditrating'
FROM work.Customers a LEFT OUTER JOIN realdb7.com_fin_creditrating b ON   a.creditrating1=b.code;
QUIT;

/* 28-11-2023 Get Market for Company Relation */
PROC SQL;
CREATE TABLE work.Customers AS
SELECT  a.*,
		b.Market
FROM work.Customers a LEFT OUTER JOIN db2data.branches b ON a.branch=b.branch;
QUIT;

PROC SORT DATA=work.customers nodupkey; BY code; RUN;

DATA work.Customers; SET work.Customers;
baanCunoSuno=code;
partnerlegaltype="B";
version=0;
archived=0;
createddate=datetime();
partnertype=1;
Partnerstatus=1;
Count=_N_;
dataareaid=0;
createdby='SAS-Job';
/* Market scripting */
IF Market IN ('TR','RV') 				THEN company=2;
IF Market='AP' 							THEN company=3;
IF Company_Descr='AFM'					THEN company=5;
/* IC Correction */
IF code IN (' 20331','013331') 			THEN company=3;
IF code IN (' 20330','013330','013320') THEN company=2;
code=compress(code);
IF company=. 							THEN DELETE;
/* SHT dedicated to 130  */
IF code IN ('029250') 			THEN company=2;
WHERE CODE NE '';
RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.Customers; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
com_par_partner as a inner join update_table as b on a.code=b.code

SET  
a.archived=b.archived, a.creditlimitint=b.creditlimitint, a.name=b.name, a.vatnumber=b.vatnumber, a.country=b.country, a.currency=b.currency, 
a.language=b.language, a.lineofbusiness=b.lineofbusiness, a.partnerstatus=b.partnerstatus, a.company=b.company,
a.termsofdelivery=b.termsofdelivery,  a.termsofpayment=b.termsofpayment, a.calendar=b.calendar, a.baanCunoSuno=b.baanCunoSuno ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.customers AS 
SELECT a.*,
		b.ID AS Check_Customer Label='Check_Customer'
FROM work.customers a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.code=b.code;
QUIT;

PROC APPEND BASE=RealDB7.com_par_partner DATA=work.customers FORCE; WHERE Check_Customer=.; RUN;


/********************/
/* com_par_customer */
/********************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_par_customer as select * from connection to baan
   (SELECT  2							AS company,
			'ECP'						AS Company_Descr,
			a.t_cuno   					Code,
            a.t_nama   					Name,
			a.t_pstc					Cust_postcode,
			trim(a.t_ccty) 		AS   	Country_descr,
			b.t_tfcd					Tel_pref,
			a.t_telp					Cust_tel_nr1,
			b.t_fxcd					Fax_pref,
			a.t_tefx					Cust_fax_nr1,
			a.t_pctf   					Cust_par_code,
			a.t_crte					Cust_route1,
			a.t_crlr					Creditlimitint,
			a.t_crat					Creditrating1,
			a.t_cpay					Cust_paym_code,
			a.t_cdec					Cust_term_del,
			a.t_cnpa					Partnerstatus,
			a.t_prio					Cust_prio_code,
            a.t_cbrn   					Branch,
            a.t_creg   					RepresentativeExt1,
            a.t_crep   					RepresentativeInt1,
			a.t_fovn					VatNumber,
			trim(a.t_ccur) 		AS		Currency_descr,
			trim(a.t_cbrn) 		AS		LineOfBusiness1,
			a.t_cpay					TermsOfPayment1,
			a.t_cdec					TermsOfDelivery1,
			lower(trim(a.t_clan))		Language1
   FROM         ttccom010130 a,
				ttcmcs010130 b
   WHERE        a.t_ccty   = b.t_ccty  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_par_customer_EAP as select * from connection to baan
   (SELECT  3							AS company,
			'EAP'						AS Company_Descr,
			a.t_cuno   					Code,
            a.t_nama   					Name,
			a.t_pstc					Cust_postcode,
			trim(a.t_ccty) 		AS   	Country_descr,
			b.t_tfcd					Tel_pref,
			a.t_telp					Cust_tel_nr1,
			b.t_fxcd					Fax_pref,
			a.t_tefx					Cust_fax_nr1,
			a.t_pctf   					Cust_par_code,
			a.t_crte					Cust_route1,
			a.t_crlr					creditlimitint,
			a.t_crat					creditrating1,
			a.t_cpay					Cust_paym_code,
			a.t_cdec					Cust_term_del,
			a.t_cnpa					partnerstatus,
			a.t_prio					Cust_prio_code,
            a.t_cbrn   					branch,
            a.t_creg   					representativeExt1,
            a.t_crep   					representativeInt1,
			a.t_fovn					VatNumber,
			trim(a.t_ccur) 		AS		currency_descr,
			trim(a.t_cbrn) 		AS		LineOfBusiness1,
			a.t_cpay					TermsOfPayment1,
			a.t_cdec					TermsOfDelivery1,
			lower(trim(a.t_clan))		Language1
   FROM         ttccom010300 a,
				ttcmcs010300 b
   WHERE        a.t_ccty   = b.t_ccty  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.com_par_customer DATA=work.com_par_customer_EAP FORCE; RUN;

/* employee nr */
DATA work.com_par_customer; SET work.com_par_customer;
Employee_Nr=compress(put(representativeInt1,6.));
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.BaanUsers as select * from connection to baan
   (SELECT  	trim(a.t_cspa) 	AS Employee_Nr,
   				a.t_user 		AS BaanUser
   FROM         ttdpur980130 a 
WHERE a.t_user <> 'dummy');
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.BaanUsers_EAP as select * from connection to baan
   (SELECT  	trim(a.t_cspa) 	AS Employee_Nr,
   				a.t_user 		AS BaanUser
   FROM         ttdpur980300 a 
WHERE a.t_user <> 'dummy');
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.BaanUsers data=work.BaanUsers_EAP; RUN;

PROC SORT data=work.BaanUsers nodupkey; by Employee_Nr; RUN;

PROC SQL;
CREATE TABLE Work.com_par_customer AS 
SELECT a.*,
		b.BaanUser AS BaanUser Label='BaanUser'
FROM work.com_par_customer a LEFT OUTER JOIN work.BaanUsers b ON   a.Employee_Nr=b.Employee_Nr ;
QUIT;

PROC SQL;
CREATE TABLE Work.com_par_customer AS 
SELECT a.*,
		b.id AS representativeint Label='representativeint'
FROM work.com_par_customer a LEFT OUTER JOIN realdb7.sys_usr_user b ON   a.BaanUser=b.Code;
QUIT;

PROC SQL;
CREATE TABLE Work.com_par_customer AS 
SELECT a.*,
		b.ID AS creditrating Label='creditrating'
FROM work.com_par_customer a LEFT OUTER JOIN realdb7.com_fin_creditrating b ON   a.creditrating1=b.code;
QUIT;



PROC SQL;
CREATE TABLE work.com_par_customer AS 
SELECT a.*,
		b.ID AS partner label='partner'
FROM work.com_par_customer a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.code=b.code;
QUIT;

DATA work.com_par_customer; SET work.com_par_customer;
version=0;
archived=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
WHERE partner NE .;
RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.com_par_customer; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
com_par_customer as a inner join update_table as b on a.company=b.company AND a.partner=b.partner

SET  
a.creditrating=b.creditrating, a.representativeInt=b.representativeInt; ) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE work.com_par_customer AS 
SELECT a.*,
		b.partner AS check_partner Label='check_partner'
FROM work.com_par_customer a LEFT OUTER JOIN RealDB7.com_par_customer b ON a.company=b.company AND a.partner=b.partner;
QUIT;

PROC APPEND BASE=RealDB7.com_par_customer DATA=work.com_par_customer FORCE; WHERE check_partner=.; RUN;



/**********************/
/* trd_quo_mquotation */
/**********************/
PROC SQL;
CREATE TABLE work.Sofon_Quotes AS
SELECT 	'S'||a.QUOTE_NR AS documentcode,
		a.QUOTE_SUBJECT AS description1,
		a.QUOTE_DATE 	AS documentdate,
		3 				AS documenttype,
		a.CUST_NR 		AS partnercode
FROM	db2data.Sofon_Quote_header a
WHERE a.quote_status='Accepted';
QUIT;

DATA work.Sofon_Quotes; SET work.Sofon_Quotes;
archived=0;
version=0;
createddate=datetime();
dataareaid=0;
RUN;

PROC SQL;
CREATE TABLE work.Sofon_Quotes AS 
SELECT a.*,
		b.ID AS partner Label='partner',
		b.company
FROM work.Sofon_Quotes a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.partnercode=b.code;
QUIT;

PROC SORT DATA=work.Sofon_Quotes nodupkey; BY documentcode; RUN;

DATA work.Sofon_Quotes; SET work.Sofon_Quotes;
mtype='S';
FORMAT description $50.;
description=description1;
IF LENGTH(Description)>50 	THEN description='-';
IF description='' 			THEN description='-';
IF documentdate="" 			THEN documentdate=1003329900;
IF company=. 				THEN company=3;
createdby='SAS-Job';
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.Sofon_Quotes; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
trd_quo_mquotation as a inner join update_table as b on a.documentcode=b.documentcode

SET  
a.description=b.description, a.partner=b.partner, a.company=b.company; ) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE Work.Sofon_Quotes AS 
SELECT a.*,
		b.id AS Check_Quote Label='Check_Quote'
FROM work.Sofon_Quotes a LEFT OUTER JOIN RealDB7.trd_quo_mquotation b ON a.documentcode=b.documentcode ;
QUIT;

PROC APPEND BASE=RealDB7.trd_quo_mquotation DATA=work.Sofon_Quotes FORCE; WHERE Check_Quote=.; RUN;



/**********************/
/* trd_quo_mquotationline */
/**********************/
PROC SQL;
CREATE TABLE work.Sofon_Quotes_Lines AS
SELECT 	'S'||a.QUOTE_NR 				AS documentcode,
		b.QUOTE_POS 					AS documentlinenumber,
		d.SALESCONVPRICE_UPLIFT___KGNUM AS conversionprice,
		c.id 							AS quotation
FROM	db2data.Sofon_Quote_header a
INNER JOIN db2data.Sofon_quote_lines     b ON a.QUOTE_NR=b.QUOTE_NR AND a.QUOTE_VERSION=b.QUOTE_VERSION AND a.QUOTE_MINOR_VERSION=b.QUOTE_MINOR_VERSION
INNER JOIN realdb7.trd_quo_mquotation    c ON 'S'||a.QUOTE_NR=c.documentcode
INNER JOIN db2data.sofon_specs_transpose d ON b.QUOTE_NR=d.QUOTENR AND compress(put(b.QUOTE_POS,2.))=d.POSITION_ID AND b.QUOTE_VERSION=d.VERSIONNR AND b.QUOTE_MINOR_VERSION=d.MINORVERSIONNR
WHERE a.quote_status='Accepted';
QUIT;

DATA work.Sofon_Quotes_Lines; SET work.Sofon_Quotes_Lines;
archived=0;
version=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
IF conversionprice=. THEN conversionprice=0;
RUN;

PROC SORT DATA=work.Sofon_Quotes_Lines nodupkey; BY quotation documentlinenumber; RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.Sofon_Quotes_Lines; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
trd_quo_mquotationline as a inner join update_table as b on a.quotation=b.quotation AND a.documentlinenumber=b.documentlinenumber

SET  
a.conversionprice=b.conversionprice; ) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE Work.Sofon_Quotes_Lines AS 
SELECT a.*,
		b.id AS Check_QuoteLine Label='Check_QuoteLine'
FROM work.Sofon_Quotes_Lines a LEFT OUTER JOIN RealDB7.trd_quo_mquotationline b ON a.quotation=b.quotation AND a.documentlinenumber=b.documentlinenumber ;
QUIT;

PROC APPEND BASE=RealDB7.trd_quo_mquotationline DATA=work.Sofon_Quotes_Lines FORCE; WHERE Check_QuoteLine=. AND conversionprice NOT IN (.,0) /* corr bec of format, marc needs to fix it*/ AND conversionprice<10; RUN;


/*******************/
/* com_loc_address */
/*******************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.customer_address as select * from connection to baan
   (SELECT  a.t_cuno AS customer,
			a.t_name AS city,
			a.t_nama AS name1,
			a.t_namb AS name2,
			a.t_pstc AS zipcode,
			a.t_namc AS street,
			a.t_crte AS Route
   FROM      ttccom010130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.customer_address_EAP as select * from connection to baan
   (SELECT  a.t_cuno AS customer,
			a.t_name AS city,
			a.t_nama AS name1,
			a.t_namb AS name2,
			a.t_pstc AS zipcode,
			a.t_namc AS street,
			a.t_crte AS Route
   FROM      ttccom010300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.customer_address_KSI as select * from connection to baan
   (SELECT  a.t_cuno AS customer,
			a.t_name AS city,
			a.t_nama AS name1,
			a.t_namb AS name2,
			a.t_pstc AS zipcode,
			a.t_namc AS street,
			a.t_crte AS Route
   FROM      ttccom010400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.customer_address_AFM as select * from connection to baan
   (SELECT  a.t_cuno AS customer,
			a.t_name AS city,
			a.t_nama AS name1,
			a.t_namb AS name2,
			a.t_pstc AS zipcode,
			a.t_namc AS street,
			a.t_crte AS Route
   FROM      ttccom010601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.customer_address DATA=work.customer_address_EAP; RUN;
PROC APPEND BASE=work.customer_address DATA=work.customer_address_KSI; RUN;
PROC APPEND BASE=work.customer_address DATA=work.customer_address_AFM; RUN;

PROC SORT DATA=work.customer_address nodupkey; by customer; RUN;

PROC SQL;
CREATE TABLE Work.customer_address AS 
SELECT a.*,
		b.ID AS Partner Label='Partner',
		b.Country
FROM work.customer_address a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.customer=b.code ;
Quit;

DATA work.customer_address1; SET work.customer_address;
deliveryaddress=0;
invoiceaddress=1;
Code='I001';
archived=0;
addresstype='E';
createddate=datetime();
version=0;
latitude=0;
longitude=0;
transitaddress=0;
IF Route='00100' 	THEN transportmode='S';
IF Route='00200' 	THEN transportmode='A';
IF Route='00300' 	THEN transportmode='R';
IF Route='00400' 	THEN transportmode='I';
IF city='' 			THEN city='-';
IF name1='' 		THEN name1='-';
IF name2='' 		THEN name2='-';
IF street='' 		THEN street='-';
IF zipcode='' 		THEN zipcode='-';
dataareaid=0;
createdby='SAS-Job';
WHERE Partner NE . AND Country NE .;
RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.customer_address1; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
com_par_address as a inner join update_table as b on a.code=b.code AND a.partner=b.partner 

SET  
a.archived=b.archived, a.city=b.city, a.name1=b.name1, a.name2=b.name2, a.street=b.street, a.zipcode=b.zipcode, a.country=b.country, a.deliveryaddress=b.deliveryaddress, a.invoiceaddress=b.invoiceaddress
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.customer_address1 AS 
SELECT a.*,
		b.ID AS Check_Cust_Address Label='Check_Cust_Address'
FROM work.customer_address1 a LEFT OUTER JOIN RealDB7.com_par_address b ON a.Code=b.Code AND a.partner=b.partner AND b.invoiceaddress=1; 
QUIT;

PROC APPEND BASE=RealDB7.com_par_address DATA=work.customer_address1 FORCE; WHERE Check_Cust_Address=.; RUN;

/****************************/
/* com_loc_address DELIVERY */
/****************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.delivery_adress as select * from connection to baan
   (SELECT  a.t_cuno 		AS customer,
   			a.t_cdel 		AS Address_code,
			a.t_name 		AS city,
			a.t_nama 		AS name1,
			a.t_namb 		AS name2,
			a.t_pstc 		AS zipcode,
			a.t_namc 		AS street,
			a.t_crte 		AS Route,
			trim(a.t_ccty) 	AS country_descr
   FROM      ttccom013130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.delivery_adress_EAP as select * from connection to baan
   (SELECT  a.t_cuno 		AS customer,
   			a.t_cdel 		AS Address_code,
			a.t_name 		AS city,
			a.t_nama 		AS name1,
			a.t_namb 		AS name2,
			a.t_pstc 		AS zipcode,
			a.t_namc 		AS street,
			a.t_crte 		AS Route,
			trim(a.t_ccty) 	AS country_descr
   FROM      ttccom013300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.delivery_adress_KSI as select * from connection to baan
   (SELECT  a.t_cuno 		AS customer,
   			a.t_cdel 		AS Address_code,
			a.t_name 		AS city,
			a.t_nama 		AS name1,
			a.t_namb 		AS name2,
			a.t_pstc 		AS zipcode,
			a.t_namc 		AS street,
			a.t_crte 		AS Route,
			trim(a.t_ccty) 	AS country_descr
   FROM      ttccom013400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.delivery_adress_AFM as select * from connection to baan
   (SELECT  a.t_cuno 		AS customer,
   			a.t_cdel 		AS Address_code,
			a.t_name 		AS city,
			a.t_nama 		AS name1,
			a.t_namb 		AS name2,
			a.t_pstc 		AS zipcode,
			a.t_namc 		AS street,
			a.t_crte 		AS Route,
			trim(a.t_ccty) 	AS country_descr
   FROM      ttccom013601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.delivery_adress DATA=work.delivery_adress_EAP; RUN;
PROC APPEND BASE=work.delivery_adress DATA=work.delivery_adress_KSI; RUN;
PROC APPEND BASE=work.delivery_adress DATA=work.delivery_adress_AFM; RUN;

PROC SORT DATA=work.delivery_adress nodupkey; BY customer Address_code; RUN;
DATA work.delivery_adress; SET work.delivery_adress;
IF country_descr='TU' THEN country_descr='TR';
RUN;

PROC SQL;
CREATE TABLE Work.delivery_adress AS 
SELECT a.*,
		b.ID AS Partner Label='Partner'
FROM work.delivery_adress a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.customer=b.code ;
Quit;

PROC SQL;
CREATE TABLE Work.delivery_adress AS 
SELECT a.*,
		b.ID AS Country Label='Country'
FROM work.delivery_adress a LEFT OUTER JOIN realdb7.sys_loc_country b ON   a.Country_descr=b.code ;
QUIT;

DATA work.delivery_adress1; SET work.delivery_adress;
deliveryaddress=1;
invoiceaddress=0;
Code='D'||Address_code;
archived=0;
addresstype='E';
createddate=datetime();
latitude=0;
version=0;
longitude=0;
transitaddress=0;
IF Route='00100' 	THEN transportmode='S';
IF Route='00200' 	THEN transportmode='A';
IF Route='00300' 	THEN transportmode='R';
IF Route='00400' 	THEN transportmode='I';
IF city='' 			THEN city='-';
IF name1='' 		THEN name1='-';
IF name2='' 		THEN name2='-';
IF street='' 		THEN street='-';
IF zipcode='' 		THEN zipcode='-';
dataareaid=0;
createdby='SAS-Job';
WHERE Partner NE . AND Country NE .;
RUN;

/* Default deliveryDay */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.DefaultDeliveryDay as select * from connection to baan
   (SELECT  a.t_adky AS DeliveryCode,
   			a.t_dayn AS DefaultDeliveryDay1
   FROM      ttdcox111130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.DefaultDeliveryDay_EAP as select * from connection to baan
   (SELECT  a.t_adky AS DeliveryCode,
   			a.t_dayn AS DefaultDeliveryDay1
   FROM      ttdcox111300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.DefaultDeliveryDay_KSI as select * from connection to baan
   (SELECT  a.t_adky AS DeliveryCode,
   			a.t_dayn AS DefaultDeliveryDay1
   FROM      ttdcox111400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.DefaultDeliveryDay_AFM as select * from connection to baan
   (SELECT  a.t_adky AS DeliveryCode,
   			a.t_dayn AS DefaultDeliveryDay1
   FROM      ttdcox111601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.DefaultDeliveryDay data=work.DefaultDeliveryDay_EAP; RUN;
PROC APPEND BASE=work.DefaultDeliveryDay data=work.DefaultDeliveryDay_KSI; RUN;
PROC APPEND BASE=work.DefaultDeliveryDay data=work.DefaultDeliveryDay_AFM; RUN;

PROC SORT data=work.DefaultDeliveryDay nodupkey; by DeliveryCode; RUN;

DATA work.DefaultDeliveryDay; SET work.DefaultDeliveryDay;
Code='D'||substr(DeliveryCode,8,3);
CustNr=substr(DeliveryCode,2,6);
IF DefaultDeliveryDay1=1 THEN DefaultDeliveryDay=7;
IF DefaultDeliveryDay1=2 THEN DefaultDeliveryDay=1;
IF DefaultDeliveryDay1=3 THEN DefaultDeliveryDay=2;
IF DefaultDeliveryDay1=4 THEN DefaultDeliveryDay=3;
IF DefaultDeliveryDay1=5 THEN DefaultDeliveryDay=4;
IF DefaultDeliveryDay1=6 THEN DefaultDeliveryDay=5;
IF DefaultDeliveryDay1=7 THEN  DefaultDeliveryDay=6;
createdby='SAS-Job';
RUN;

PROC SQL;
CREATE TABLE work.delivery_adress1 AS
SELECT  a.*,
		b.DefaultDeliveryDay
FROM work.delivery_adress1 a 
LEFT OUTER JOIN work.DefaultDeliveryDay b ON a.customer=b.CustNr AND a.code=b.Code;
QUIT;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND base=realdb7.update_table data=work.delivery_adress1; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
com_par_address as a inner join update_table as b on a.code=b.code AND a.partner=b.partner AND b.deliveryaddress=1

SET  
a.archived=b.archived, a.city=b.city, a.name1=b.name1, a.name2=b.name2, a.street=b.street, a.zipcode=b.zipcode, a.country=b.country, a.DefaultDeliveryDay=b.DefaultDeliveryDay
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.delivery_adress1 AS 
SELECT a.*,
		b.ID AS Check_Del_Address Label='Check_Del_Address'
FROM work.delivery_adress1 a LEFT OUTER JOIN RealDB7.com_par_address b ON a.Code=b.Code AND a.partner=b.partner AND b.deliveryaddress=1; 
QUIT;

PROC APPEND BASE=RealDB7.com_par_address DATA=work.delivery_adress1 FORCE; WHERE Check_Del_Address=.; RUN;


/***************************/
/* com_loc_address INVOICE */
/***************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.invoice_adress as select * from connection to baan
   (SELECT  a.t_cuno 		AS customer,
   			a.t_ccor	 	AS Address_code,
			a.t_name 		AS city,
			a.t_nama 		AS name1,
			a.t_namb 		AS name2,
			a.t_pstc 		AS zipcode,
			a.t_namc 		AS street,
			trim(a.t_ccty) 	AS country_descr
   FROM      ttccom012130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.invoice_adress_EAP as select * from connection to baan
   (SELECT  a.t_cuno 		AS customer,
   			a.t_ccor 		AS Address_code,
			a.t_name 		AS city,
			a.t_nama 		AS name1,
			a.t_namb 		AS name2,
			a.t_pstc 		AS zipcode,
			a.t_namc 		AS street,
			trim(a.t_ccty) 	AS country_descr
   FROM      ttccom012300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.invoice_adress_KSI as select * from connection to baan
   (SELECT  a.t_cuno 		AS customer,
   			a.t_ccor 		AS Address_code,
			a.t_name 		AS city,
			a.t_nama 		AS name1,
			a.t_namb 		AS name2,
			a.t_pstc 		AS zipcode,
			a.t_namc 		AS street,
			trim(a.t_ccty) 	AS country_descr
   FROM      ttccom012400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.invoice_adress_AFM as select * from connection to baan
   (SELECT  a.t_cuno 		AS customer,
   			a.t_ccor 		AS Address_code,
			a.t_name 		AS city,
			a.t_nama 		AS name1,
			a.t_namb 		AS name2,
			a.t_pstc 		AS zipcode,
			a.t_namc 		AS street,
			trim(a.t_ccty) 	AS country_descr
   FROM      ttccom012601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.invoice_adress DATA=work.invoice_adress_EAP; RUN;
PROC APPEND BASE=work.invoice_adress DATA=work.invoice_adress_KSI; RUN;
PROC APPEND BASE=work.invoice_adress DATA=work.invoice_adress_AFM; RUN;

PROC SORT DATA=work.invoice_adress nodupkey; BY customer Address_code; RUN;

PROC SQL;
CREATE TABLE Work.invoice_adress AS 
SELECT a.*,
		b.ID AS Partner Label='Partner'
FROM work.invoice_adress a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.customer=b.code ;
Quit;

PROC SQL;
CREATE TABLE Work.invoice_adress AS 
SELECT a.*,
		b.ID AS Country Label='Country'
FROM work.invoice_adress a LEFT OUTER JOIN realdb7.sys_loc_country b ON   a.Country_descr=b.code ;
QUIT;

DATA work.invoice_adress1; SET work.invoice_adress;
deliveryaddress=0;
invoiceaddress=1;
addresstype='E';
Code='I'||Address_code;
archived=0;
createddate=datetime();
latitude=0;
version=0;
longitude=0;
transitaddress=0;
IF city='' 			THEN city='-';
IF name1=''			THEN name1='-';
IF name2='' 		THEN name2='-';
IF street='' 		THEN street='-';
IF zipcode='' 		THEN zipcode='-';
dataareaid=0;
createdby='SAS-Job';
WHERE Partner NE . AND Country NE .;
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND base=realdb7.update_table data=work.invoice_adress1; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
com_par_address as a inner join update_table as b on a.code=b.code AND a.partner=b.partner AND b.invoiceaddress=1

SET  
a.archived=b.archived, a.city=b.city, a.name1=b.name1, a.name2=b.name2, a.street=b.street, a.zipcode=b.zipcode, a.country=b.country
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.invoice_adress1 AS 
SELECT a.*,
		b.ID AS Check_Inv_Address Label='Check_Inv_Address'
FROM work.invoice_adress1 a LEFT OUTER JOIN RealDB7.com_par_address b ON a.Code=b.Code AND a.partner=b.partner AND b.invoiceaddress=1; 
QUIT;

PROC APPEND BASE=RealDB7.com_par_address DATA=work.invoice_adress1 FORCE; WHERE Check_Inv_Address=.; RUN;


/********************/
/* prd_pro_mproject */
/********************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Projects as select * from connection to baan
   (SELECT  a.t_sprj Code,
   			a.t_dsca Description,
			a.t_indt StartDate1,
			a.t_exdt EndDate1,
			a.t_acti Active
   FROM      ttdslx001130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Projects_EAP as select * from connection to baan
   (SELECT  a.t_sprj Code,
   			a.t_dsca Description,
			a.t_indt StartDate1,
			a.t_exdt EndDate1,
			a.t_acti Active
   FROM      ttdslx001300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Projects_KSI as select * from connection to baan
   (SELECT  a.t_sprj Code,
   			a.t_dsca Description,
			a.t_indt StartDate1,
			a.t_exdt EndDate1,
			a.t_acti Active
   FROM      ttdslx001400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Projects_AFM as select * from connection to baan
   (SELECT  a.t_sprj Code,
   			a.t_dsca Description,
			a.t_indt StartDate1,
			a.t_exdt EndDate1,
			a.t_acti Active
   FROM      ttdslx001601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.Projects DATA=work.Projects_EAP; RUN;
PROC APPEND BASE=work.Projects DATA=work.Projects_KSI; RUN;
PROC APPEND BASE=work.Projects DATA=work.Projects_AFM; RUN;

PROC SORT DATA=work.Projects nodupkey; BY code; RUN;

DATA Work.Projects; SET work.Projects;
FORMAT StartDate Date9.;
StartDate=StartDate1;
FORMAT EndDate Date9.;
EndDate=EndDate1;
archived=0;
version=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
WHERE Active=1 AND Code NE "" AND Startdate1 NE .;
RUN;


/* Insert New Records */
PROC SQL;
CREATE TABLE Work.Projects AS 
SELECT a.*,
		b.ID AS Check_Project Label='Check_Project'
FROM work.Projects a LEFT OUTER JOIN RealDB7.prd_pro_mproject b ON a.Code=b.Code; 
QUIT;

PROC APPEND BASE=RealDB7.prd_pro_mproject DATA=work.Projects FORCE; WHERE Check_Project=.; RUN;

/************************/
/* trd_bas_tradepartner */
/************************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Order_type as select * from connection to baan
   (SELECT  a.t_cuno AS customer,
   			a.t_cotp AS Order_type
   FROM      ttccom010130 a );
 DISCONNECT from baan;
QUIT;

PROC SQL;
CREATE TABLE Work.Order_type AS 
SELECT a.*,
		b.ID AS Partner Label='Partner'
FROM work.Order_type a LEFT OUTER JOIN realdb7.com_par_partner b ON  a.customer=b.code ;
Quit;

PROC SQL;
CREATE TABLE Work.Order_type AS 
SELECT a.*,
		b.ID AS Requesttype Label='Requesttype'
FROM work.Order_type a LEFT OUTER JOIN realdb7.trd_req_mrequesttype b ON   a.Order_type=b.code ;
QUIT;

DATA work.Order_type; SET work.Order_type;
archived=0;
version=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
WHERE Partner NE . AND Requesttype NE .;
RUN;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.Order_type AS 
SELECT a.*,
		b.partner AS Check_Order_type Label='Check_Order_type'
FROM work.Order_type a LEFT OUTER JOIN RealDB7.trd_bas_tradepartner b ON a.partner=b.partner; 
QUIT;

PROC APPEND BASE=RealDB7.trd_bas_tradepartner DATA=work.Order_type FORCE; WHERE Check_Order_type=.; RUN;


/*********************/
/* trd_ctr_mcontract */
/*********************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalesContract as select * from connection to baan
   (SELECT  'ECP' AS Company1,
			a.t_cono documentcode1,
   			a.t_cuno Customer,
   			a.t_cdes Description,
			a.t_ccrs lmeprice1,
			a.t_sdat validfromdate1,
			a.t_edat validtilldate1,
			a.t_icap Contract_status,
			a.t_ccur Currency_Descr
   FROM      ttdsls300130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalesContract_EAP as select * from connection to baan
   (SELECT  'EAP' AS Company1,
			a.t_cono documentcode1,
   			a.t_cuno Customer,
   			a.t_cdes Description,
			a.t_ccrs lmeprice1,
			a.t_sdat validfromdate1,
			a.t_edat validtilldate1,
			a.t_icap Contract_status,
			a.t_ccur Currency_Descr
   FROM      ttdsls300300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalesContract_KSI as select * from connection to baan
   (SELECT  'KSI' AS Company1,
			a.t_cono documentcode1,
   			a.t_cuno Customer,
   			a.t_cdes Description,
			a.t_ccrs lmeprice1,
			a.t_sdat validfromdate1,
			a.t_edat validtilldate1,
			a.t_icap Contract_status,
			a.t_ccur Currency_Descr
   FROM      ttdsls300400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalesContract_AFM as select * from connection to baan
   (SELECT  'AFM' AS Company1,
			a.t_cono documentcode1,
   			a.t_cuno Customer,
   			a.t_cdes Description,
			a.t_ccrs lmeprice1,
			a.t_sdat validfromdate1,
			a.t_edat validtilldate1,
			a.t_icap Contract_status,
			a.t_ccur Currency_Descr
   FROM      ttdsls300601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.SalesContract DATA=work.SalesContract_EAP; RUN;
PROC APPEND BASE=work.SalesContract DATA=work.SalesContract_KSI; RUN;
PROC APPEND BASE=work.SalesContract DATA=work.SalesContract_AFM; RUN;

PROC SORT DATA=work.SalesContract nodupkey; BY Company1 documentcode1; RUN;


PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalesContract_lines as select * from connection to baan
   (SELECT  'ECP' AS Company1,
			a.t_cono documentcode1,
			MIN(a.t_minq) AS minimumQuantityExt,
			MAX(a.t_maxq) AS maximumQuantityExt,
			MAX(a.t_cqan) AS calledQuantityExt,
			a.t_cups contractQuantityUOM1
   FROM      ttdsls301130 a 
GROUP BY a.t_cono, a.t_pono, a.t_cups);
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalesContract_lines_EAP as select * from connection to baan
   (SELECT  'EAP' AS Company1,
			a.t_cono documentcode1,
			MIN(a.t_minq) AS minimumQuantityExt,
			MAX(a.t_maxq) AS maximumQuantityExt,
			MAX(a.t_cqan) AS calledQuantityExt,
			a.t_cups contractQuantityUOM1
   FROM      ttdsls301300 a 
GROUP BY a.t_cono, a.t_pono, a.t_cups);
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalesContract_lines_KSI as select * from connection to baan
   (SELECT  'EAP' AS Company1,
			a.t_cono documentcode1,
			MIN(a.t_minq) AS minimumQuantityExt,
			MAX(a.t_maxq) AS maximumQuantityExt,
			MAX(a.t_cqan) AS calledQuantityExt,
			a.t_cups contractQuantityUOM1
   FROM      ttdsls301400 a 
GROUP BY a.t_cono, a.t_pono, a.t_cups);
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.SalesContract_lines_AFM as select * from connection to baan
   (SELECT  'EAP' AS Company1,
			a.t_cono documentcode1,
			MIN(a.t_minq) AS minimumQuantityExt,
			MAX(a.t_maxq) AS maximumQuantityExt,
			MAX(a.t_cqan) AS calledQuantityExt,
			a.t_cups contractQuantityUOM1
   FROM      ttdsls301601 a 
GROUP BY a.t_cono, a.t_pono, a.t_cups);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.SalesContract_lines DATA=work.SalesContract_lines_EAP; RUN;
PROC APPEND BASE=work.SalesContract_lines DATA=work.SalesContract_lines_KSI; RUN;
PROC APPEND BASE=work.SalesContract_lines DATA=work.SalesContract_lines_AFM; RUN;

PROC SORT DATA=work.SalesContract_lines nodupkey; BY Company1 documentcode1; RUN;

PROC SQL;
CREATE TABLE Work.SalesContract AS 
SELECT a.*,
		b.ID AS Currency Label='Currency'
FROM work.SalesContract a LEFT OUTER JOIN realdb7.sys_loc_currency b ON   a.currency_descr=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.SalesContract_lines AS 
SELECT a.*,
		b.ID AS contractQuantityUOM Label='contractQuantityUOM'
FROM work.SalesContract_lines a 
LEFT OUTER JOIN realdb7.com_log_uom b ON   a.contractQuantityUOM1=b.Code ;
QUIT;

PROC SQL;
CREATE TABLE work.SalesContract AS
SELECT  a.*,
		b.minimumQuantityExt,
		b.maximumQuantityExt,
		b.calledQuantityExt,
		b.contractQuantityUOM
FROM work.SalesContract a LEFT OUTER JOIN work.SalesContract_lines b ON a.documentcode1=b.documentcode1;
QUIT;

PROC SQL;
CREATE TABLE work.SalesContract AS 
SELECT  a.*,
		b.ID AS partner label='partner'
FROM work.SalesContract a LEFT OUTER JOIN RealDB7.com_par_partner b ON a.Customer=b.code;
QUIT;

PROC SQL;
CREATE TABLE work.SalesContract AS 
SELECT  a.*,
		b.ID AS company label='company'
FROM work.SalesContract a LEFT OUTER JOIN RealDB7.com_cmp_company b ON a.company1=b.description;
QUIT;

DATA work.SalesContract ; SET work.SalesContract;
createddate=datetime();
documentdate=date();
FORMAT baancono 6.;
baancono=compress(documentcode1);
FORMAT documentcode $15.;
IF company=3 			THEN documentcode=compress("ASC"||documentcode1);
IF company=2 			THEN documentcode=compress("CSC"||documentcode1);
version=0;
dataareaid=0;
IF description='' 		THEN description='-';
FORMAT validfromdate Date9.;
validfromdate=validfromdate1;
FORMAT validthrudate Date9.;
validthrudate=validtilldate1;
IF Contract_Status=3 	THEN DO bicontractstatus="TE"; canceled=0; closed=1; confirmed=1; archived=1; END;
IF Contract_Status=2 	THEN DO bicontractstatus="AC"; canceled=0; closed=0; confirmed=1; archived=0; END;
IF Contract_Status=1 	THEN DO bicontractstatus="FU"; canceled=0; closed=0; confirmed=1; archived=1; END;
mtype="S";
FORMAT lmeprice 10.2;
lmeprice=lmeprice1;
lmeprice=lmeprice/100;
IF lmeprice=. 			THEN lmeprice=0;
dataareaid=0;
IF minimumQuantityExt=. THEN minimumQuantityExt=0;
IF maximumQuantityExt=. THEN maximumQuantityExt=0;
IF calledQuantityExt=. 	THEN calledQuantityExt=0;
createdby='SAS-Job';
WHERE contractQuantityUOM NE .;
RUN;

PROC SORT DATA=work.SalesContract nodupkey; BY company documentcode; RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.SalesContract; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
trd_ctr_mcontract as a inner join update_table as b on a.documentcode=b.documentcode

SET  
a.bicontractstatus=b.bicontractstatus, a.calledquantityext=b.calledquantityext, a.lmeprice=b.lmeprice, a.minimumquantityext=b.minimumquantityext, a.maximumquantityext=b.maximumquantityext, a.validfromdate=b.validfromdate,
a.validthrudate=b.validthrudate, a.currency=b.currency, a.contractquantityuom=b.contractquantityuom, a.Partner=b.Partner, a.company=b.company, a.description=b.description, a.baancono=b.baancono,
a.archived=b.archived, a.canceled=b.canceled, a.closed=b.closed, a.confirmed=b.confirmed
) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE Work.SalesContract AS 
SELECT a.*,
		b.documentcode AS Check_Contract Label='Check_Contract'
FROM work.SalesContract a LEFT OUTER JOIN RealDB7.trd_ctr_mcontract b ON a.documentcode=b.documentcode; 
QUIT;

PROC APPEND BASE=RealDB7.trd_ctr_mcontract DATA=work.SalesContract FORCE; WHERE Check_Contract='' AND validfromdate NE . AND currency NE . AND lmeprice NE . AND documentcode NE '' ; RUN;

/***** Purchase Contracts *****/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.PurchaseContract as select * from connection to baan
   (SELECT  'ECP' Company1,
			a.t_cono documentcode1,
   			a.t_suno partner1,
   			a.t_cdes Description,
			a.t_ccrs lmeprice1,
			a.t_sdat validfromdate1,
			a.t_edat validtilldate1,
			a.t_icap Contract_status,
			a.t_ccur Currency_Descr
   FROM      ttdpur300130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.PurchaseContract_EAP as select * from connection to baan
   (SELECT  'EAP' Company1,
			a.t_cono documentcode1,
   			a.t_suno partner1,
   			a.t_cdes Description,
			a.t_ccrs lmeprice1,
			a.t_sdat validfromdate1,
			a.t_edat validtilldate1,
			a.t_icap Contract_status,
			a.t_ccur Currency_Descr
   FROM      ttdpur300300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.PurchaseContract_KSI as select * from connection to baan
   (SELECT  'KSI' Company1,
			a.t_cono documentcode1,
   			a.t_suno partner1,
   			a.t_cdes Description,
			a.t_ccrs lmeprice1,
			a.t_sdat validfromdate1,
			a.t_edat validtilldate1,
			a.t_icap Contract_status,
			a.t_ccur Currency_Descr
   FROM      ttdpur300400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.PurchaseContract_AFM as select * from connection to baan
   (SELECT  'AFM' Company1,
			a.t_cono documentcode1,
   			a.t_suno partner1,
   			a.t_cdes Description,
			a.t_ccrs lmeprice1,
			a.t_sdat validfromdate1,
			a.t_edat validtilldate1,
			a.t_icap Contract_status,
			a.t_ccur Currency_Descr
   FROM      ttdpur300601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.PurchaseContract DATA=work.PurchaseContract_EAP; 	  RUN;
PROC APPEND BASE=work.PurchaseContract DATA=work.PurchaseContract_KSI; 	  RUN;
PROC APPEND BASE=work.PurchaseContract DATA=work.PurchaseContract_AFM; 	  RUN;

PROC SORT DATA=work.PurchaseContract nodupkey; BY company1 documentcode1; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.PurchaseContract_lines as select * from connection to baan
   (SELECT  'ECP' Company1,
			a.t_cono documentcode1,
			MIN(a.t_minq) AS minimumQuantityExt,
			MAX(a.t_maxq) AS maximumQuantityExt,
			MAX(a.t_cqan) AS calledQuantityExt,
			a.t_cuqp contractQuantityUOM1
   FROM      ttdpur301130 a 
GROUP BY a.t_cono, a.t_pono, a.t_cuqp);
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.PurchaseContract_lines_EAP as select * from connection to baan
   (SELECT  'EAP' Company1,
			a.t_cono documentcode1,
			MIN(a.t_minq) AS minimumQuantityExt,
			MAX(a.t_maxq) AS maximumQuantityExt,
			MAX(a.t_cqan) AS calledQuantityExt,
			a.t_cuqp contractQuantityUOM1
   FROM      ttdpur301300 a 
GROUP BY a.t_cono, a.t_pono, a.t_cuqp);
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.PurchaseContract_lines_KSI as select * from connection to baan
   (SELECT  'EAP' Company1,
			a.t_cono documentcode1,
			MIN(a.t_minq) AS minimumQuantityExt,
			MAX(a.t_maxq) AS maximumQuantityExt,
			MAX(a.t_cqan) AS calledQuantityExt,
			a.t_cuqp contractQuantityUOM1
   FROM      ttdpur301400 a 
GROUP BY a.t_cono, a.t_pono, a.t_cuqp);
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.PurchaseContract_lines_AFM as select * from connection to baan
   (SELECT  'EAP' Company1,
			a.t_cono documentcode1,
			MIN(a.t_minq) AS minimumQuantityExt,
			MAX(a.t_maxq) AS maximumQuantityExt,
			MAX(a.t_cqan) AS calledQuantityExt,
			a.t_cuqp contractQuantityUOM1
   FROM      ttdpur301601 a 
GROUP BY a.t_cono, a.t_pono, a.t_cuqp);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.PurchaseContract_lines DATA=work.PurchaseContract_lines_EAP; RUN;
PROC APPEND BASE=work.PurchaseContract_lines DATA=work.PurchaseContract_lines_KSI; RUN;
PROC APPEND BASE=work.PurchaseContract_lines DATA=work.PurchaseContract_lines_AFM; RUN;

PROC SORT DATA=work.PurchaseContract_lines nodupkey; BY company1 documentcode1;    RUN;

PROC SQL;
CREATE TABLE Work.PurchaseContract AS 
SELECT  a.*,
		b.ID AS Currency Label='Currency'
FROM work.PurchaseContract a LEFT OUTER JOIN realdb7.sys_loc_currency b ON   a.currency_descr=b.code ;
QUIT;

PROC SQL;
CREATE TABLE Work.PurchaseContract_lines AS 
SELECT  a.*,
		b.ID AS contractQuantityUOM Label='contractQuantityUOM'
FROM work.PurchaseContract_lines a 
LEFT OUTER JOIN realdb7.com_log_uom b ON   a.contractQuantityUOM1=b.Code ;
QUIT;

PROC SQL;
CREATE TABLE work.PurchaseContract AS
SELECT  a.*,
		b.minimumQuantityExt,
		b.maximumQuantityExt,
		b.calledQuantityExt,
		b.contractQuantityUOM
FROM work.PurchaseContract a LEFT OUTER JOIN work.PurchaseContract_lines b ON a.company1=b.company1 AND a.documentcode1=b.documentcode1;
QUIT;


Data work.PurchaseContract ; Set Work.PurchaseContract;
createddate=datetime();
documentdate=date();
FORMAT baancono 6.;
baancono=compress(documentcode1);
FORMAT Documentcode $15.;
IF company1='EAP' 		THEN documentcode=compress("APC"||documentcode1);
IF company1='ECP' 		THEN documentcode=compress("CPC"||documentcode1);
version=0;
dataareaid=0;
IF description='' 		THEN description='-';
IF calledQuantityExt=. 	THEN calledQuantityExt=0;
IF minimumQuantityExt=. THEN minimumQuantityExt=0;
IF maximumQuantityExt=. THEN maximumQuantityExt=0;
RUN;

PROC SQL;
CREATE TABLE work.PurchaseContract AS 
SELECT  a.*,
		b.ID AS partner Label='partner'
FROM work.PurchaseContract a LEFT OUTER JOIN RealDB7.com_par_partner b ON compress(a.partner1)=b.code;
QUIT;


PROC SQL;
CREATE TABLE work.PurchaseContract AS 
SELECT  a.*,
		b.ID AS company Label='company'
FROM work.PurchaseContract a LEFT OUTER JOIN RealDB7.com_cmp_company b ON a.company1=b.description;
QUIT;


Data work.PurchaseContract ; SET work.PurchaseContract;
FORMAT validfromdate Date9.;
validfromdate=validfromdate1;
FORMAT validthrudate Date9.;
validthrudate=validtilldate1;
IF Contract_Status=3 	THEN DO bicontractstatus="TE"; canceled=0; closed=1; confirmed=1; archived=1; END;
IF Contract_Status=2 	THEN DO bicontractstatus="AC"; canceled=0; closed=0; confirmed=1; archived=0; END;
IF Contract_Status=1 	THEN DO bicontractstatus="FU"; canceled=0; closed=0; confirmed=1; archived=1; END;
mtype="P";
FORMAT lmeprice 10.2;
lmeprice=lmeprice1;
lmeprice=lmeprice/100;
IF lmeprice=. 			THEN lmeprice=0;
dataareaid=0;
createdby='SAS-Job';
WHERE contractQuantityUOM NE .;
RUN;

PROC SORT DATA=work.PurchaseContract nodupkey; BY company documentcode; RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.PurchaseContract; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
trd_ctr_mcontract as a inner join update_table as b on a.documentcode=b.documentcode AND a.company=b.company 

SET  
a.bicontractstatus=b.bicontractstatus, a.calledquantityext=b.calledquantityext, a.lmeprice=b.lmeprice, a.maximumquantityext=b.minimumquantityext, a.validfromdate=b.validfromdate,
a.validthrudate=b.validthrudate, a.currency=b.currency, a.contractquantityuom=b.contractquantityuom, a.Partner=b.Partner, a.company=b.company, a.description=b.description, a.baancono=b.baancono,
a.archived=b.archived, a.canceled=b.canceled, a.closed=b.closed, a.confirmed=b.confirmed
) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE Work.PurchaseContract AS 
SELECT a.*,
		b.documentcode AS Check_Contract Label='Check_Contract'
FROM work.PurchaseContract a LEFT OUTER JOIN RealDB7.trd_ctr_mcontract b ON a.company=b.company AND a.documentcode=b.documentcode; 
QUIT;

PROC APPEND BASE=RealDB7.trd_ctr_mcontract DATA=work.PurchaseContract FORCE; WHERE Check_Contract='' AND validfromdate NE . AND currency NE . AND lmeprice NE .; RUN;

/*************************/
/* cat_mrk_marketpartner */
/*************************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Market_Customer as select * from connection to baan
   (SELECT  a.t_cuno   		Code,
            a.t_nama   		Name,
            trim(a.t_cbrn  ) 		branch
   FROM         ttccom010130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Market_Customer_EAP as select * from connection to baan
   (SELECT  a.t_cuno   		Code,
            a.t_nama   		Name,
            trim(a.t_cbrn  ) 		branch
   FROM         ttccom010300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Market_Customer_KSI as select * from connection to baan
   (SELECT  a.t_cuno   		Code,
            a.t_nama   		Name,
            trim(a.t_cbrn  ) 		branch
   FROM         ttccom010400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Market_Customer_AFM as select * from connection to baan
   (SELECT  a.t_cuno   		Code,
            a.t_nama   		Name,
            trim(a.t_cbrn  ) 		branch
   FROM         ttccom010601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.Market_Customer data=work.Market_Customer_EAP; RUN;
PROC APPEND BASE=work.Market_Customer data=work.Market_Customer_KSI; RUN;
PROC APPEND BASE=work.Market_Customer data=work.Market_Customer_AFM; RUN;

PROC SORT data=work.Market_Customer nodupkey; by Code; RUN;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Branches as select * from connection to baan
   (SELECT  e.t_dimx   Branch,
            e.t_desc   Branch_descr,
f.t_dimx   Branch_group_code,
f.t_desc   Branch_group_descr,
g.t_dimx   Market_code,
g.t_desc   Market_descr,
h.t_dimx   Indus_code,
h.t_desc   Indus_descr
   FROM         ttfgld010120 e,
ttfgld010120 f,
ttfgld010120 g,
ttfgld010120 h
   WHERE        e.t_pdix   = f.t_dimx AND
				f.t_pdix   = g.t_dimx AND
				g.t_pdix   = h.t_dimx   );
 DISCONNECT from baan;
QUIT;


PROC SQL;
CREATE TABLE Work.Market_Customer AS 
SELECT a.*,
		b.Market_descr AS Market_descr Label='Market_descr',
		b.Market_code  AS Market_code  Label='Market_code'
FROM work.Market_Customer a 
LEFT OUTER JOIN work.Branches b ON a.Branch=b.Branch;
QUIT;

Proc sql;
create table Work.Market_Customer AS 
Select a.*,
		b.ID AS Partner Label='Partner'
From work.Market_Customer a 
LEFT OUTER JOIN RealDB7.com_par_partner b ON a.Code=b.code;
Quit;

DATA work.Market_Customer; SET work.Market_Customer;
IF Market_Code='VEH01' THEN Market_Code='RV ';
IF Market_Code='VEH02' THEN Market_Code='TR ';
IF Market_Code='IND01' THEN Market_Code='AP ';
IF Market_Code='IND03' THEN Market_Code='CID';
IF Market_Code='IND09' THEN Market_Code='OTH';
IF Market_Code='I/C01' THEN Market_Code='IC ';
IF Market_Code='SCR01' THEN Market_Code='SCR';
RUN;

Proc sql;
create table Work.Market_Customer AS 
Select a.*,
		b.ID AS Market Label='Market'
From work.Market_Customer a 
LEFT OUTER JOIN RealDB7.cat_mrk_market b ON a.Market_Code=b.code;
Quit;

DATA work.Market_Customer; SET work.Market_Customer;
archived=0;
createddate=datetime();
version=0;
dataareaid=0;
createdby='SAS-Job';
WHERE partner NE . AND market NE .;
RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.Market_Customer; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
cat_mrk_marketpartner as a inner join update_table as b on a.partner=b.partner

SET  
a.market=b.market

) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.Market_Customer AS 
SELECT a.*,
		b.ID AS Check_Part_Market Label='Check_Part_Market'
FROM work.Market_Customer a LEFT OUTER JOIN RealDB7.cat_mrk_marketpartner b ON a.partner=b.partner; 
QUIT;

PROC APPEND BASE=RealDB7.cat_mrk_marketpartner DATA=work.Market_Customer FORCE; WHERE Check_Part_Market=.; RUN;



/****************/
/* OrderType */
/****************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.OrderType as select * from connection to baan
   (SELECT  a.t_ttro Code,
   			a.t_dsca Description
   FROM      ttdmdm301130 a );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.OrderType_EAP as select * from connection to baan
   (SELECT  a.t_ttro Code,
   			a.t_dsca Description
   FROM      ttdmdm301300 a );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.OrderType_KSI as select * from connection to baan
   (SELECT  a.t_ttro Code,
   			a.t_dsca Description
   FROM      ttdmdm301400 a );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.OrderType_AFM as select * from connection to baan
   (SELECT  a.t_ttro Code,
   			a.t_dsca Description
   FROM      ttdmdm301601 a );
 DISCONNECT from baan;
QUIT;
PROC APPEND BASE=work.OrderType DATA=work.OrderType_EAP; RUN;
PROC APPEND BASE=work.OrderType DATA=work.OrderType_KSI; RUN;
PROC APPEND BASE=work.OrderType DATA=work.OrderType_AFM; RUN;


PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Workcenters_ECP as select * from connection to baan
   (SELECT  a.t_cwoc Code,
   			a.t_dsca Description
   FROM      ttirou001130 a );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Workcenters_EAP as select * from connection to baan
   (SELECT  a.t_cwoc Code,
   			a.t_dsca Description
   FROM      ttirou001300 a );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Workcenters_KSI as select * from connection to baan
   (SELECT  a.t_cwoc Code,
   			a.t_dsca Description
   FROM      ttirou001400 a );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Workcenters_AFM as select * from connection to baan
   (SELECT  a.t_cwoc Code,
   			a.t_dsca Description
   FROM      ttirou001601 a );
 DISCONNECT from baan;
QUIT;
PROC APPEND BASE=work.OrderType DATA=work.Workcenters_ECP; RUN;
PROC APPEND BASE=work.OrderType DATA=work.Workcenters_EAP; RUN;
PROC APPEND BASE=work.OrderType DATA=work.Workcenters_KSI; RUN;
PROC APPEND BASE=work.OrderType DATA=work.Workcenters_AFM; RUN;

PROC SORT DATA=work.OrderType nodupkey; BY Code; RUN;


DATA work.OrderType; SET work.OrderType;
archived=0;
createddate=datetime();
version=0;
dataareaid=0;
createdby='SAS-Job';
prShortage='A';
prSurplus='A';
RUN;

/* Insert New Records */
PROC SQL;
CREATE TABLE work.OrderType AS 
SELECT a.*,
		b.ID AS Check_OrderType Label='Check_OrderType'
FROM work.OrderType a LEFT OUTER JOIN RealDB7.prd_ord_prordertype b ON a.code=b.code; 
QUIT;

PROC APPEND BASE=RealDB7.prd_ord_prordertype DATA=work.OrderType FORCE; WHERE Check_OrderType=.; RUN;



/****************/
/* ProcessFlow */
/****************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ProcessFlow as select * from connection to baan
   (SELECT  2 AS Company,
			a.t_prfl Code,
   			MAX(a.t_dsca)  Description
   FROM      ttdmdm322130 a,
   			 ttdmdm323130 b
WHERE a.t_prfl=b.t_prfl
GROUP BY a.t_prfl );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ProcessFlow_EAP as select * from connection to baan
   (SELECT  3 AS Company,
			a.t_prfl Code,
   			MAX(a.t_dsca)  Description
   FROM      ttdmdm322300 a,
   			 ttdmdm323300 b
WHERE a.t_prfl=b.t_prfl
GROUP BY a.t_prfl );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ProcessFlow_KSI as select * from connection to baan
   (SELECT  4 AS Company,
			a.t_prfl Code,
   			MAX(a.t_dsca)  Description
   FROM      ttdmdm322400 a,
   			 ttdmdm323400 b
WHERE a.t_prfl=b.t_prfl
GROUP BY a.t_prfl );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ProcessFlow_AFM as select * from connection to baan
   (SELECT  5 AS Company,
			a.t_prfl Code,
   			MAX(a.t_dsca)  Description
   FROM      ttdmdm322601 a,
   			 ttdmdm323601 b
WHERE a.t_prfl=b.t_prfl
GROUP BY a.t_prfl );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.ProcessFlow DATA=work.ProcessFlow_EAP; RUN;
PROC APPEND BASE=work.ProcessFlow DATA=work.ProcessFlow_KSI; RUN;
PROC APPEND BASE=work.ProcessFlow DATA=work.ProcessFlow_AFM; RUN;

PROC SORT DATA=work.ProcessFlow nodupkey; BY Code; RUN;

DATA work.ProcessFlow; SET work.ProcessFlow;
archived=0;
createddate=datetime();
version=0;
dataareaid=0;
createdby='SAS-Job';
RUN;

/* Change Diff */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.ProcessFlow; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
prd_rou_processflow as a inner join update_table as b on a.code=b.code and a.company=b.company

SET  
a.Description=b.Description; ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE work.ProcessFlow AS 
SELECT a.*,
		b.ID AS Check_ProcessFlow Label='Check_ProcessFlow'
FROM work.ProcessFlow a LEFT OUTER JOIN RealDB7.prd_rou_processflow b ON upcase(a.code)=upcase(b.code);
QUIT;

PROC APPEND BASE=RealDB7.prd_rou_processflow DATA=work.ProcessFlow FORCE; WHERE Check_ProcessFlow=.; RUN;


/****************/
/* ProcessFlowStep */
/****************/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ProcessFlowStep as select * from connection to baan
   (SELECT  a.t_prfl Code,
   			a.t_seqn sequenceNumber,
			MIN(a.t_ttro) OrderType1,
			MIN(c.t_cwoc) WorkCenter1
   FROM      ttdmdm323130 a
   LEFT OUTER JOIN ttdmdm320130 b ON a.t_item=b.t_item AND a.t_ttro=b.t_ttro
   LEFT OUTER JOIN ttirou102130 c ON b.t_item=c.t_mitm AND b.t_opro=c.t_opro
WHERE a.t_item='ALU' /* 12-09-2023 item change (bec of error in real) */ 
GROUP BY a.t_prfl, a.t_seqn);
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ProcessFlowStep_EAP as select * from connection to baan
   (SELECT  a.t_prfl Code,
   			a.t_seqn sequenceNumber,
			MIN(a.t_ttro) OrderType1,
			MIN(c.t_cwoc) WorkCenter1
   FROM      ttdmdm323300 a
   LEFT OUTER JOIN ttdmdm320300 b ON a.t_item=b.t_item AND a.t_ttro=b.t_ttro
   LEFT OUTER JOIN ttirou102300 c ON b.t_item=c.t_mitm AND b.t_opro=c.t_opro
WHERE a.t_item='ALU' /* 12-09-2023 item change (bec of error in real) */ 
GROUP BY a.t_prfl, a.t_seqn );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ProcessFlowStep_KSI as select * from connection to baan
   (SELECT  a.t_prfl Code,
   			a.t_seqn sequenceNumber,
			MIN(a.t_ttro) OrderType1,
			MIN(c.t_cwoc) WorkCenter1
   FROM      ttdmdm323400 a
   LEFT OUTER JOIN ttdmdm320400 b ON a.t_item=b.t_item AND a.t_ttro=b.t_ttro
   LEFT OUTER JOIN ttirou102400 c ON b.t_item=c.t_mitm AND b.t_opro=c.t_opro
WHERE a.t_item='ALU' /* 12-09-2023 item change (bec of error in real) */ 
GROUP BY a.t_prfl, a.t_seqn );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.ProcessFlowStep_AFM as select * from connection to baan
   (SELECT  a.t_prfl Code,
   			a.t_seqn sequenceNumber,
			MIN(a.t_ttro) OrderType1,
			MIN(c.t_cwoc) WorkCenter1
   FROM      ttdmdm323601 a
   LEFT OUTER JOIN ttdmdm320601 b ON a.t_item=b.t_item AND a.t_ttro=b.t_ttro
   LEFT OUTER JOIN ttirou102601 c ON b.t_item=c.t_mitm AND b.t_opro=c.t_opro
WHERE a.t_item='ALU' /* 12-09-2023 item change (bec of error in real) */ 
GROUP BY a.t_prfl, a.t_seqn );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.ProcessFlowStep DATA=work.ProcessFlowStep_EAP; RUN;
PROC APPEND BASE=work.ProcessFlowStep DATA=work.ProcessFlowStep_KSI; RUN;
PROC APPEND BASE=work.ProcessFlowStep DATA=work.ProcessFlowStep_AFM; RUN;

PROC SORT DATA=work.ProcessFlowStep nodupkey; BY Code sequencenumber; RUN;

DATA work.ProcessFlowStep; SET work.ProcessFlowStep;
IF workcenter1='EAP' THEN workcenter1='SPL';
RUN;


PROC SQL;
CREATE TABLE work.ProcessFlowStep AS
SELECT  a.*,
		b.id AS Processflow
FROM work.processflowstep a LEFT OUTER JOIN realdb7.prd_rou_processflow b ON COMPRESS(a.code)=COMPRESS(b.code);
QUIT;

PROC SQL;
CREATE TABLE work.ProcessFlowStep AS
SELECT  a.*,
		b.id AS OrderType
FROM work.processflowstep a LEFT OUTER JOIN realdb7.prd_ord_prordertype b ON COMPRESS(a.OrderType1)=COMPRESS(b.code);
QUIT;
PROC SQL;
CREATE TABLE work.ProcessFlowStep AS
SELECT  a.*,
		b.department AS WorkCenter
FROM work.processflowstep a LEFT OUTER JOIN realdb7.prd_bas_workcenter b ON COMPRESS(a.WorkCenter1)=COMPRESS(b.baanCwoc);
QUIT;

PROC SORT DATA=work.ProcessFlowStep nodupkey; BY Processflow sequenceNumber OrderType WorkCenter; RUN;

DATA work.ProcessFlowStep; SET work.ProcessFlowStep;
archived=0;
createddate=datetime();
version=0;
dataareaid=0;
weekoffset=1;
createdby='SAS-Job';
WHERE  WorkCenter Ne . AND ProcessFlow NE . ;
RUN;

/* Change Diff */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.ProcessFlowStep; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
prd_rou_processflowstep as a inner join update_table as b ON a.Processflow=b.Processflow AND a.sequenceNumber=b.sequenceNumber 

SET  
a.OrderType=b.OrderType, a.workcenter=b.workcenter; ) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE work.ProcessFlowStep AS 
SELECT a.*,
		b.ID AS Check_ProcessFlowStep Label='Check_ProcessFlowStep'
FROM work.ProcessFlowStep a LEFT OUTER JOIN RealDB7.prd_rou_processflowstep b ON a.ProcessFlow=b.ProcessFlow AND a.sequenceNumber=b.sequenceNumber ; 
QUIT;


PROC APPEND BASE=RealDB7.prd_rou_processflowstep DATA=work.ProcessFlowStep FORCE; WHERE Check_ProcessFlowStep=. ; RUN;


/*
DATA work.ProcessFlowStep1; SET work.ProcessFlowStep; WorkCenter=4; WHERE code='SEsEef'; RUN;
PROC APPEND BASE=RealDB7.prd_rou_processflowstep DATA=work.ProcessFlowStep1 FORCE; WHERE Check_ProcessFlowStep=. AND code='SEsEef'; RUN;             Quick fix om ProcesSteps toe te voegen PW 09-08-2023*/



/******************************/
/* prd_bas_productionCustomer */
/*PROC sql;*/
/*CONNECT to odbc as baan (dsn='informix');*/
/*EXECUTE (set lock mode to wait) by baan;*/
/*CREATE table work.prd_bas_productionCustomer as select * from connection to baan*/
/*   (SELECT  a.t_cuno	AS Code,*/
/*			a.t_nobarst AS barcodeStickerCount*/
/*   FROM      ttdlra903130 a );*/
/* DISCONNECT from baan;*/
/*QUIT;*/
/**/
/*PROC SQL;*/
/*CREATE TABLE work.prd_bas_productionCustomer AS*/
/*SELECT a.*,*/
/*		b.ID AS Partner Label='Partner'*/
/*FROM work.prd_bas_productionCustomer a */
/*LEFT OUTER JOIN realdb7.com_par_partner b ON a.code=b.code;*/
/*QUIT;*/
/**/
/*DATA Work.prd_bas_productionCustomer; SET work.prd_bas_productionCustomer ;*/
/*archived=0;*/
/*createddate=datetime();*/
/*days=0;*/
/*dataareaid=0;*/
/*RUN;*/


/* Update Difference */
/*PROC SQL;*/
/*CONNECT to odbc as MySQL (dsn='realdb7');*/
/*EXECUTE (DROP  TABLE   update_table  ) by MySQL;*/
/*QUIT;*/
/**/
/*PROC APPEND base=realdb7.update_table data=work.prd_bas_productionCustomer; RUN;*/
/**/
/*PROC SQL;*/
/*CONNECT to odbc as MySQL (dsn='realdb7');*/
/*EXECUTE ( UPDATE prd_bas_productioncustomer as a inner join update_table as b on a.partner=b.partner SET  a.barcodeStickerCount=b.barcodeStickerCount ) by MySQL;*/
/*QUIT;*/

/* Insert New Records */
/*PROC SQL;*/
/*CREATE TABLE Work.prd_bas_productionCustomer AS */
/*SELECT a.*,	b.partner AS Check_BarcodeStickerCount label='Check_BarcodeStickerCount'*/
/*FROM work.prd_bas_productionCustomer a LEFT OUTER JOIN RealDB7.prd_bas_productioncustomer b ON a.partner=b.partner ;*/
/*QUIT;*/
/**/
/*PROC APPEND BASE=RealDB7.prd_bas_productioncustomer DATA=work.prd_bas_productionCustomer FORCE; WHERE Check_BarcodeStickerCount=. AND partner NE .; RUN;*/


/***************************/
/* prd_itm_productionitem */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_itm_productionitem as select * from connection to baan
   (SELECT  'ECP' 		AS Company1,
			a.t_dset 	AS Item1,
			a.t_idst 	AS InputItem1,
			a.t_prfl 	AS processFlow1,
			b.t_fnsh 	AS finish_code
   FROM      ttdmdm995130 a
LEFT OUTER JOIN ttdlrx100130 b ON a.t_dset=b.t_dset);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_itm_productionitem_EAP as select * from connection to baan
   (SELECT  'EAP' 		AS Company1,
			a.t_dset 	AS Item1,
			a.t_idst 	AS InputItem1,
			a.t_prfl 	AS processFlow1,
			b.t_fnsh 	AS finish_code
   FROM      ttdmdm995300 a
LEFT OUTER JOIN ttdlrx100300 b ON a.t_dset=b.t_dset);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_itm_productionitem_KSI as select * from connection to baan
   (SELECT  'KSI' 		AS Company1,
			a.t_dset 	AS Item1,
			a.t_idst 	AS InputItem1,
			a.t_prfl 	AS processFlow1,
			b.t_fnsh 	AS finish_code
   FROM      ttdmdm995400 a
LEFT OUTER JOIN ttdlrx100400 b ON a.t_dset=b.t_dset);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_itm_productionitem_AFM as select * from connection to baan
   (SELECT  'AFM' 		AS Company1,
			a.t_dset 	AS Item1,
			a.t_idst 	AS InputItem1,
			a.t_prfl 	AS processFlow1,
			b.t_fnsh 	AS finish_code
   FROM      ttdmdm995601 a
LEFT OUTER JOIN ttdlrx100400 b ON a.t_dset=b.t_dset);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.prd_itm_productionitem data=work.prd_itm_productionitem_EAP; RUN;
PROC APPEND BASE=work.prd_itm_productionitem data=work.prd_itm_productionitem_KSI; RUN;
PROC APPEND BASE=work.prd_itm_productionitem data=work.prd_itm_productionitem_AFM; RUN;

PROC SORT DATA=work.prd_itm_productionitem nodupkey; BY company1 Item1 finish_code; RUN;
DATA work.prd_itm_productionitem; SET work.prd_itm_productionitem;
by company1 Item1 finish_code;
IF NOT LAST.Item1 THEN DELETE;
RUN;


DATA work.prd_itm_productionitem; SET work.prd_itm_productionitem;
IF Company1='ECP' AND processFlow1='PO' THEN processFlow1='POa';
IF Company1='EAP' AND processFlow1='PO' THEN processFlow1='POe';
RUN;


PROC SQL;
CREATE TABLE work.prd_itm_productionitem AS
SELECT  a.*,
		b.ID AS Company Label='Company'
FROM work.prd_itm_productionitem a 
LEFT OUTER JOIN realdb7.com_cmp_company b ON a.Company1=b.description;
QUIT;

PROC SQL;
CREATE TABLE work.prd_itm_productionitem AS
SELECT  a.*,
		b.ID AS Item Label='Item'
FROM work.prd_itm_productionitem a 
LEFT OUTER JOIN realdb7.cat_itm_item b ON a.item1=b.code;
QUIT;

PROC SQL;
CREATE TABLE work.prd_itm_productionitem AS
SELECT  a.*,
		b.ID AS InputItem Label='InputItem'
FROM work.prd_itm_productionitem a 
LEFT OUTER JOIN realdb7.cat_itm_item b ON a.InputItem1=b.code;
QUIT;


PROC SQL;
CREATE TABLE work.prd_itm_productionitem AS
SELECT  a.*,
		b.ID AS processFlow Label='processFlow'
FROM work.prd_itm_productionitem a 
LEFT OUTER JOIN realdb7.prd_rou_processflow b ON a.processFlow1=b.code;
QUIT;


DATA Work.prd_itm_productionitem; SET work.prd_itm_productionitem ;
samplesrequired=0;
IF finish_code NE '' THEN samplesrequired=1;
archived=0;
createddate=datetime();
days=0;
dataareaid=0;
biProductionItemStatus='DR';
finishFS=1;
finishRS=1;
biFinishesReleased=0; 
blocked=0;
released=0;
retired=0;
bimetalreleased=0;
updateProductionOrders='P';
createdby='SAS-Job';
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.prd_itm_productionitem; WHERE processflow ne .; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE ( UPDATE prd_itm_productionitem as a inner join update_table as b on a.company=b.company AND a.item=b.item SET a.samplesrequired=b.samplesrequired, a.processflow=b.processflow, a.inputitem=b.inputitem ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.prd_itm_productionitem AS 
SELECT a.*,	b.item AS Check_ProductionItem Label='Check_ProductionItem'
FROM work.prd_itm_productionitem a LEFT OUTER JOIN RealDB7.prd_itm_productionitem b ON a.company=b.company AND a.item=b.item ;
QUIT;

PROC APPEND BASE=RealDB7.prd_itm_productionitem DATA=work.prd_itm_productionitem FORCE; WHERE Check_ProductionItem=.  AND processflow NE . AND item NE . ; RUN;



/*******************************/
/* prd_pln_leadtimeprocessflow */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_pln_leadtimeprocessflow as select * from connection to baan
   (SELECT  a.t_item AS substrate1,
			a.t_prfl AS processflow1,
			a.t_iltd AS internalLeadtimeDays
   FROM      ttdmdm937130 a);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_pln_leadtimeprocessflow_EAP as select * from connection to baan
   (SELECT  a.t_item AS substrate1,
			a.t_prfl AS processflow1,
			a.t_iltd AS internalLeadtimeDays
   FROM      ttdmdm937300 a);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_pln_leadtimeprocessflow_KSI as select * from connection to baan
   (SELECT  a.t_item AS substrate1,
			a.t_prfl AS processflow1,
			a.t_iltd AS internalLeadtimeDays
   FROM      ttdmdm937400 a);
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_pln_leadtimeprocessflow_AFM as select * from connection to baan
   (SELECT  a.t_item AS substrate1,
			a.t_prfl AS processflow1,
			a.t_iltd AS internalLeadtimeDays
   FROM      ttdmdm937601 a);
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.prd_pln_leadtimeprocessflow DATA=work.prd_pln_leadtimeprocessflow_EAP; RUN;
PROC APPEND BASE=work.prd_pln_leadtimeprocessflow DATA=work.prd_pln_leadtimeprocessflow_KSI; RUN;
PROC APPEND BASE=work.prd_pln_leadtimeprocessflow DATA=work.prd_pln_leadtimeprocessflow_AFM; RUN;

PROC SORT DATA=work.prd_pln_leadtimeprocessflow nodupkey; BY substrate1 processflow1; RUN;


PROC SQL;
CREATE TABLE work.prd_pln_leadtimeprocessflow AS
SELECT  a.*,
		b.ID AS substrate Label='substrate'
FROM work.prd_pln_leadtimeprocessflow a 
LEFT OUTER JOIN realdb7.cat_sub_substrate b ON a.substrate1=b.code;
QUIT;

PROC SQL;
CREATE TABLE work.prd_pln_leadtimeprocessflow AS
SELECT  a.*,
		b.ID AS processFlow Label='processFlow'
FROM work.prd_pln_leadtimeprocessflow a 
LEFT OUTER JOIN realdb7.prd_rou_processflow b ON a.processFlow1=b.code;
QUIT;

DATA Work.prd_pln_leadtimeprocessflow; SET work.prd_pln_leadtimeprocessflow ;
archived=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
WHERE processflow NE .;
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.prd_pln_leadtimeprocessflow; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE ( UPDATE prd_pln_leadtimeprocessflow as a inner join update_table as b on a.substrate=b.substrate AND a.processflow=b.processflow SET a.internalleadtimedays=b.internalleadtimedays ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.prd_pln_leadtimeprocessflow AS 
SELECT a.*,	b.id AS Check_ProductionLT Label='Check_ProductionLT'
FROM work.prd_pln_leadtimeprocessflow a LEFT OUTER JOIN RealDB7.prd_pln_leadtimeprocessflow b ON a.substrate=b.substrate AND a.processflow=b.processflow  ;
QUIT;

PROC APPEND BASE=RealDB7.prd_pln_leadtimeprocessflow DATA=work.prd_pln_leadtimeprocessflow FORCE; WHERE Check_ProductionLT=. ; RUN;



/*********************************/
/* shp_rou_defaulttransportslack */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.defaulttransportslack as select * from connection to baan
   (SELECT  2 AS site,
			a.t_grpg AS shippingMethod1,
   			a.t_crte AS transportMode1,
			a.t_ccty AS country1,
			a.t_cdec AS termsofdelivery1,
			a.t_slck AS transportslack
   FROM      ttdshp002130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.defaulttransportslack_EAP as select * from connection to baan
   (SELECT  3 AS site,
			a.t_grpg AS shippingMethod1,
   			a.t_crte AS transportMode1,
			a.t_ccty AS country1,
			a.t_cdec AS termsofdelivery1,
			a.t_slck AS transportslack
   FROM      ttdshp002300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.defaulttransportslack_KSI as select * from connection to baan
   (SELECT  4 AS site,
			a.t_grpg AS shippingMethod1,
   			a.t_crte AS transportMode1,
			a.t_ccty AS country1,
			a.t_cdec AS termsofdelivery1,
			a.t_slck AS transportslack
   FROM      ttdshp002400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.defaulttransportslack_AFM as select * from connection to baan
   (SELECT  5 AS site,
			a.t_grpg AS shippingMethod1,
   			a.t_crte AS transportMode1,
			a.t_ccty AS country1,
			a.t_cdec AS termsofdelivery1,
			a.t_slck AS transportslack
   FROM      ttdshp002601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.defaulttransportslack DATA=work.defaulttransportslack_EAP; RUN;
PROC APPEND BASE=work.defaulttransportslack DATA=work.defaulttransportslack_KSI; RUN;
PROC APPEND BASE=work.defaulttransportslack DATA=work.defaulttransportslack_AFM; RUN;


PROC SORT DATA=work.defaulttransportslack nodupkey; BY site shippingMethod1 transportMode1 country1 termsofdelivery1;  RUN;


PROC SQL;
CREATE TABLE work.defaulttransportslack AS
SELECT a.*,
		b.ID AS country Label='country'
FROM work.defaulttransportslack a 
LEFT OUTER JOIN realdb7.sys_loc_country b ON compress(a.country1)=b.code;
QUIT;

PROC SQL;
CREATE TABLE work.defaulttransportslack AS
SELECT a.*,
		b.ID AS termsofdelivery Label='termsofdelivery'
FROM work.defaulttransportslack a 
LEFT OUTER JOIN realdb7.com_log_termsofdelivery b ON a.termsofdelivery1=b.code;
QUIT;

DATA work.defaulttransportslack; SET work.defaulttransportslack;
IF shippingmethod1='1' 		THEN shippingmethod='G';
IF shippingmethod1='2' 		THEN shippingmethod='L';

IF transportMode1='00200' 	THEN transportMode='A';
IF transportMode1='00400' 	THEN transportMode='I';
IF transportMode1='00300' 	THEN transportMode='R';
IF transportMode1='00100' 	THEN transportMode='S';

archived=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.defaulttransportslack; RUN;

/*PROC SQL;*/
/*CONNECT to odbc as MySQL (dsn='realdb7');*/
/*EXECUTE ( UPDATE shp_rou_defaulttransportslack as a inner join update_table as b on a.site=b.site AND a.termsofdelivery=b.termsofdelivery AND a.transportmode=b.transportmode AND a.shippingmethod=b.shippingmethod AND a.country=b.country*/
/*SET a.transportslack=b.transportslack ) by MySQL;*/
/*QUIT;*/

/* Insert New Records */
PROC SQL;
CREATE TABLE work.defaulttransportslack AS 
SELECT a.*,	b.id AS check_record Label='check_record'
FROM work.defaulttransportslack a LEFT OUTER JOIN RealDB7.shp_rou_defaulttransportslack b ON a.site=b.site AND a.country=b.country AND a.termsofdelivery=b.termsofdelivery AND a.transportmode=b.transportmode AND a.shippingmethod=b.shippingmethod;
QUIT;

PROC APPEND BASE=RealDB7.shp_rou_defaulttransportslack DATA=work.defaulttransportslack FORCE; WHERE check_record=.; RUN;

/*********************************/
/* shp_rou_addresstransportslack */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.addresstransportslack as select * from connection to baan
   (SELECT  2 AS site,
			a.t_grpg AS shippingMethod1,
   			a.t_crte AS transportMode1,
			a.t_cuno AS partner1,
			a.t_cdel AS address1,
			a.t_slck AS transportslack
   FROM      ttdshp005130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.addresstransportslack_EAP as select * from connection to baan
   (SELECT  3 AS site,
			a.t_grpg AS shippingMethod1,
   			a.t_crte AS transportMode1,
			a.t_cuno AS partner1,
			a.t_cdel AS address1,
			a.t_slck AS transportslack
   FROM      ttdshp005300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.addresstransportslack_KSI as select * from connection to baan
   (SELECT  4 AS site,
			a.t_grpg AS shippingMethod1,
   			a.t_crte AS transportMode1,
			a.t_cuno AS partner1,
			a.t_cdel AS address1,
			a.t_slck AS transportslack
   FROM      ttdshp005400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.addresstransportslack_AFM as select * from connection to baan
   (SELECT  5 AS site,
			a.t_grpg AS shippingMethod1,
   			a.t_crte AS transportMode1,
			a.t_cuno AS partner1,
			a.t_cdel AS address1,
			a.t_slck AS transportslack
   FROM      ttdshp005601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.addresstransportslack DATA=work.addresstransportslack_EAP; RUN;
PROC APPEND BASE=work.addresstransportslack DATA=work.addresstransportslack_KSI; RUN;
PROC APPEND BASE=work.addresstransportslack DATA=work.addresstransportslack_AFM; RUN;


PROC SORT DATA=work.addresstransportslack nodupkey; BY site shippingMethod1 transportMode1 partner1 address1;  RUN;


PROC SQL;
CREATE TABLE work.addresstransportslack AS
SELECT a.*,
		b.ID AS partner Label='partner'
FROM work.addresstransportslack a 
LEFT OUTER JOIN realdb7.com_par_partner b ON compress(a.partner1)=b.code;
QUIT;


DATA work.addresstransportslack; SET work.addresstransportslack;
deladdress='D'||address1; 
IF shippingmethod1='1' 		THEN shippingmethod='G';
IF shippingmethod1='2' 		THEN shippingmethod='L';

IF transportMode1='00200' 	THEN transportMode='A';
IF transportMode1='00400' 	THEN transportMode='I';
IF transportMode1='00300' 	THEN transportMode='R';
IF transportMode1='00100' 	THEN transportMode='S';

archived=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
RUN;


PROC SQL;
CREATE TABLE work.addresstransportslack AS
SELECT a.*,
		b.ID AS address Label='address'
FROM work.addresstransportslack a 
LEFT OUTER JOIN realdb7.com_par_address b ON a.deladdress=b.code AND a.partner=b.partner;
QUIT;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.addresstransportslack; RUN;

/*PROC SQL;*/
/*CONNECT to odbc as MySQL (dsn='realdb7');*/
/*EXECUTE ( UPDATE shp_rou_addresstransportslack as a inner join update_table as b on a.site=b.site AND a.address=b.address AND a.transportmode=b.transportmode AND a.shippingmethod=b.shippingmethod*/
/*SET a.transportslack=b.transportslack ) by MySQL;*/
/*QUIT;*/

/* Insert New Records */
PROC SQL;
CREATE TABLE work.addresstransportslack AS 
SELECT a.*,	b.id AS check_record Label='check_record'
FROM work.addresstransportslack a LEFT OUTER JOIN RealDB7.shp_rou_addresstransportslack b ON a.site=b.site AND a.address=b.address AND a.transportmode=b.transportmode AND a.shippingmethod=b.shippingmethod;
QUIT;

PROC APPEND BASE=RealDB7.shp_rou_addresstransportslack DATA=work.addresstransportslack FORCE; WHERE check_record=. AND address NE .; RUN;




/************************************/
/**** prd_his_materialconsumption ***/
PROC sql;
CREATE table work.bare_hist_data AS
  	SELECT 	a.COMPANY ,	
			a.DIMSET,
			sum(a.del_quan) 	AS TRO_HIST_L6M,
			COUNT(a.tro_ord_nr) AS TRO_COUNT
	FROM  db2data.lra011 a
	LEFT OUTER JOIN db2data.dimsets b ON a.company=b.company AND a.DIMSET=b.dimset
	WHERE a.Date>=(date()-182) AND a.item IN ('ALU') AND b.Prod_group='Bare' AND a.Ord_type=80 AND a.del_quan<0
	GROUP by a.Company, a.DIMSET 
	ORDER by a.company, a.DIMSET;
QUIT;

PROC sql;
CREATE table work.bare_hist_data_Cust AS
  	SELECT 	a.Company,
	a.Dimset,
			COUNT(DISTINCT c.Dim_cust_end_nr) AS Cust_end_count
	FROM  db2data.lra011 a
	LEFT OUTER JOIN db2data.tro_ord b ON a.company=b.company AND a.tro_ord_nr=b.tro_ord_nr
	INNER JOIN      db2data.dimsets c ON b.company=c.company AND b.DIMSET=c.DIMSET
	WHERE a.Date>=(date()-182) AND a.item IN ('ALU') AND a.Ord_type=80 AND a.del_quan<0 AND c.Dim_cust_end_nr NOT IN ('777777','777778','777779','777780','777781','013330','013331','013332')
GROUP BY a.company, a.dimset;
QUIT;


PROC SQL;
CREATE TABLE work.prd_his_materialconsumption AS
SELECT  a.Company AS CompanyDescr,
		a.Dimset,
		MAX(a.TRO_HIST_L6M) 	AS consumptionInt6M,
		MAX(a.TRO_COUNT)  		AS orderCount6M,
		MAX(b.Cust_end_count) 	AS customerCount6M
FROM work.bare_hist_data a 
LEFT OUTER JOIN work.bare_hist_data_Cust b ON a.company=b.company AND a.dimset=b.DIMSET
GROUP BY a.company, a.dimset;
QUIT;

/* 1month */
PROC sql;
CREATE table work.bare_hist_data_1m AS
  	SELECT 	a.COMPANY ,	
			a.DIMSET,
			sum(a.del_quan) AS consumptionInt1M
	FROM  db2data.lra011 a
	LEFT OUTER JOIN db2data.dimsets b ON a.company=b.company AND a.DIMSET=b.dimset
	WHERE a.Date>=(date()-30) AND a.item IN ('ALU') AND b.Prod_group='Bare' AND a.Ord_type=80 AND a.del_quan<0
	GROUP by a.Company, a.DIMSET 
	ORDER by a.company, a.DIMSET;
QUIT;


PROC SQL;
CREATE TABLE work.prd_his_materialconsumption AS
SELECT  a.*,
		b.consumptionInt1M
FROM work.prd_his_materialconsumption a 
LEFT OUTER JOIN work.bare_hist_data_1m b ON a.CompanyDescr=b.company AND a.dimset=b.DIMSET;
QUIT;

/* ADD 1m data */

PROC SQL;
CREATE TABLE work.prd_his_materialconsumption AS 
SELECT  a.*,
		b.id AS item
FROM work.prd_his_materialconsumption a LEFT OUTER JOIN RealDB7.cat_itm_item b ON a.Dimset=b.code ;
QUIT;

PROC SQL;
CREATE TABLE work.prd_his_materialconsumption AS
SELECT  a.*,
		b.ID AS Company Label='Company'
FROM work.prd_his_materialconsumption a 
LEFT OUTER JOIN realdb7.com_cmp_company b ON a.CompanyDescr=b.description;
QUIT;


DATA work.prd_his_materialconsumption; SET work.prd_his_materialconsumption;
archived=0;
createddate=datetime();
dataareaid=0;
IF customerCount6M=.  THEN customerCount6M=0;
IF consumptionInt1M=. THEN consumptionInt1M=0;
createdby='SAS-Job';
RUN;

/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.prd_his_materialconsumption; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE ( UPDATE prd_his_materialconsumption as a inner join update_table as b ON a.company=b.company AND a.item=b.item
SET a.consumptionInt6M=b.consumptionInt6M, a.orderCount6M=b.orderCount6M, a.customerCount6M=b.customerCount6M, a.consumptionInt1M=b.consumptionInt1M ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE work.prd_his_materialconsumption AS 
SELECT a.*,	b.id AS check_record Label='check_record'
FROM work.prd_his_materialconsumption a LEFT OUTER JOIN RealDB7.prd_his_materialconsumption b ON a.company=b.company AND a.item=b.item;
QUIT;

PROC APPEND BASE=RealDB7.prd_his_materialconsumption DATA=work.prd_his_materialconsumption FORCE; WHERE check_record=. ; RUN;





/***********************/
/* mat_sup_supplierbatchsize */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_sup_supplierbatchsize as select * from connection to baan
   (SELECT  2 Company,
			a.t_suno supplier_t,
   			a.t_item substrate_t,
			a.t_allo alloy_t,
			a.t_detf weightByWidthFactor,
			a.t_detd batchDevisionFactor
   FROM      ttdpux027130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_sup_supplierbatchsize_EAP as select * from connection to baan
   (SELECT  3 Company,
			a.t_suno supplier_t,
   			a.t_item substrate_t,
			a.t_allo alloy_t,
			a.t_detf weightByWidthFactor,
			a.t_detd batchDevisionFactor
   FROM      ttdpux027300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_sup_supplierbatchsize_KSI as select * from connection to baan
   (SELECT  4 Company,
			a.t_suno supplier_t,
   			a.t_item substrate_t,
			a.t_allo alloy_t,
			a.t_detf weightByWidthFactor,
			a.t_detd batchDevisionFactor
   FROM      ttdpux027400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.mat_sup_supplierbatchsize_AFM as select * from connection to baan
   (SELECT  5 Company,
			a.t_suno supplier_t,
   			a.t_item substrate_t,
			a.t_allo alloy_t,
			a.t_detf weightByWidthFactor,
			a.t_detd batchDevisionFactor
   FROM      ttdpux027601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.mat_sup_supplierbatchsize DATA=work.mat_sup_supplierbatchsize_EAP; RUN;
PROC APPEND BASE=work.mat_sup_supplierbatchsize DATA=work.mat_sup_supplierbatchsize_KSI; RUN;
PROC APPEND BASE=work.mat_sup_supplierbatchsize DATA=work.mat_sup_supplierbatchsize_AFM; RUN;

PROC SQL;
CREATE TABLE work.mat_sup_supplierbatchsize AS 
SELECT  a.*,
		b.ID AS supplier Label='supplier'
FROM work.mat_sup_supplierbatchsize a 
LEFT OUTER JOIN RealDB7.com_par_partner b ON compress(a.supplier_t)=compress(b.code) AND a.company=b.company;
QUIT;

PROC SQL;
CREATE TABLE work.mat_sup_supplierbatchsize AS 
SELECT  a.*,
		b.ID AS substrate Label='substrate'
FROM work.mat_sup_supplierbatchsize a 
LEFT OUTER JOIN RealDB7.cat_sub_substrate b ON a.substrate_t=b.code ;
QUIT;

PROC SQL;
CREATE TABLE work.mat_sup_supplierbatchsize AS 
SELECT  a.*,
		b.ID AS alloy Label='alloy'
FROM work.mat_sup_supplierbatchsize a 
LEFT OUTER JOIN RealDB7.cat_sub_alloy b ON a.alloy_t=b.code ;
QUIT;

DATA work.mat_sup_supplierbatchsize; SET work.mat_sup_supplierbatchsize ;
archived=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
WHERE alloy NE . AND supplier NE .;
RUN;

PROC SORT DATA=work.mat_sup_supplierbatchsize nodupkey; BY supplier substrate alloy; RUN;



/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.mat_sup_supplierbatchsize; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
mat_sup_supplierbatchsize as a inner join update_table as b on a.supplier=b.supplier AND a.substrate=b.substrate AND a.alloy=b.alloy

SET  
a.weightByWidthFactor=b.weightByWidthFactor, a.batchDevisionFactor=b.batchDevisionFactor
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE work.mat_sup_supplierbatchsize AS 
SELECT a.*,
		b.ID AS check_record Label='check_record'
FROM work.mat_sup_supplierbatchsize a LEFT OUTER JOIN RealDB7.mat_sup_supplierbatchsize b ON a.supplier=b.supplier AND a.substrate=b.substrate AND a.alloy=b.alloy ;
QUIT;

PROC APPEND BASE=RealDB7.mat_sup_supplierbatchsize DATA=work.mat_sup_supplierbatchsize FORCE; WHERE check_record=.; RUN;



/**********************/
/* prd_ord_prcampaign */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_ord_prcampaign as select * from connection to baan
   (SELECT  a.t_cano AS code_t,
   			a.t_date AS campaignDate,
			a.t_cwoc AS workCenter_t,
			a.t_osta AS orderStatus_n
   FROM      ttdprd100130 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_ord_prcampaign_EAP as select * from connection to baan
   (SELECT  a.t_cano AS code_t,
   			a.t_date AS campaignDate,
			a.t_cwoc AS workCenter_t,
			a.t_osta AS orderStatus_n
   FROM      ttdprd100300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_ord_prcampaign_KSI as select * from connection to baan
   (SELECT  a.t_cano AS code_t,
   			a.t_date AS campaignDate,
			a.t_cwoc AS workCenter_t,
			a.t_osta AS orderStatus_n
   FROM      ttdprd100400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_ord_prcampaign_AFM as select * from connection to baan
   (SELECT  a.t_cano AS code_t,
   			a.t_date AS campaignDate,
			a.t_cwoc AS workCenter_t,
			a.t_osta AS orderStatus_n
   FROM      ttdprd100601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.prd_ord_prcampaign DATA=work.prd_ord_prcampaign_EAP; RUN;
PROC APPEND BASE=work.prd_ord_prcampaign DATA=work.prd_ord_prcampaign_KSI; RUN;
PROC APPEND BASE=work.prd_ord_prcampaign DATA=work.prd_ord_prcampaign_AFM; RUN;

PROC SORT DATA=work.prd_ord_prcampaign nodupkey; BY code_t workCenter_t; RUN;

DATA work.prd_ord_prcampaign; SET work.prd_ord_prcampaign;
IF workCenter_t='EAP' THEN workcenter_t='SPL';
RUN;

PROC SQL;
CREATE TABLE work.prd_ord_prcampaign AS
SELECT  a.*,
		b.department AS workCenter
FROM work.prd_ord_prcampaign a LEFT OUTER JOIN realdb7.prd_bas_workcenter b ON a.workCenter_t=b.baanCwoc;
QUIT;


DATA work.prd_ord_prcampaign; SET work.prd_ord_prcampaign ;
FORMAT code $7.;
code=put(code_t,7.);

FORMAT orderStatus $2.;
IF orderStatus_n=0 THEN orderStatus='PL';
IF orderStatus_n=1 THEN orderStatus='PL';
IF orderStatus_n=2 THEN orderStatus='OR';
IF orderStatus_n=3 THEN orderStatus='PR';
IF orderStatus_n=4 THEN orderStatus='RE';
IF orderStatus_n=5 THEN orderStatus='CO';
IF orderStatus_n=6 THEN orderStatus='CL';
archived=0;
createddate=datetime();
dataareaid=0;
createdby='SAS-Job';
WHERE workcenter NE .;
RUN;


/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.prd_ord_prcampaign; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE ( UPDATE prd_ord_prcampaign as a inner join update_table as b on a.code=b.code 
SET  a.orderStatus=b.orderStatus, a.workcenter=b.workcenter ) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.prd_ord_prcampaign AS 
SELECT a.*,	b.code AS Check_record Label='Check_record'
FROM work.prd_ord_prcampaign a LEFT OUTER JOIN RealDB7.prd_ord_prcampaign b ON a.code=b.code ;
QUIT;

PROC APPEND BASE=RealDB7.prd_ord_prcampaign DATA=work.prd_ord_prcampaign FORCE; WHERE Check_record=''; RUN;


/************************************/
/* mat_sup_suppliercapacityschedule */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Suppl_capacity as select * from connection to baan
   (SELECT  'ECP' AS CompanyDescr,
			a.t_suno Suppl_nr,
   			a.t_sprg Capacity_group,
			a.t_year deliveryYear,
			a.t_week deliveryWeek,
			a.t_qcap Capacity
   FROM      ttdpux022130 a  );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Suppl_capacity_EAP as select * from connection to baan
   (SELECT  'EAP' AS CompanyDescr,
			a.t_suno Suppl_nr,
   			a.t_sprg Capacity_group,
			a.t_year deliveryYear,
			a.t_week deliveryWeek,
			a.t_qcap Capacity
   FROM      ttdpux022300 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Suppl_capacity_KSI as select * from connection to baan
   (SELECT  'EAP' AS CompanyDescr,
			a.t_suno Suppl_nr,
   			a.t_sprg Capacity_group,
			a.t_year deliveryYear,
			a.t_week deliveryWeek,
			a.t_qcap Capacity
   FROM      ttdpux022400 a );
 DISCONNECT from baan;
QUIT;
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Suppl_capacity_AFM as select * from connection to baan
   (SELECT  'EAP' AS CompanyDescr,
			a.t_suno Suppl_nr,
   			a.t_sprg Capacity_group,
			a.t_year deliveryYear,
			a.t_week deliveryWeek,
			a.t_qcap Capacity
   FROM      ttdpux022601 a );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.Suppl_capacity DATA=work.Suppl_capacity_EAP; RUN;
PROC APPEND BASE=work.Suppl_capacity DATA=work.Suppl_capacity_KSI; RUN;
PROC APPEND BASE=work.Suppl_capacity DATA=work.Suppl_capacity_AFM; RUN;

DATA work.Suppl_capacity; SET work.Suppl_capacity;
WHERE deliveryYear>2022;
RUN;

PROC SORT DATA=work.Suppl_capacity nodupkey; BY  CompanyDescr suppl_nr capacity_group deliveryYear deliveryWeek; RUN;


DATA work.mat_sup_suppliercapacityschedule; SET work.Suppl_capacity ;
archived=0;
createddate=datetime();
dataareaid=0;
capacityUOM=1;
version=0;

biAvailable=0;
biReserved=0;
createdby='SAS-Job';
RUN;

PROC SQL;
CREATE TABLE work.mat_sup_suppliercapacityschedule AS
SELECT  a.*,
		b.ID AS Company Label='Company'
FROM work.mat_sup_suppliercapacityschedule a 
LEFT OUTER JOIN realdb7.com_cmp_company b ON a.CompanyDescr=b.description;
QUIT;

PROC SQL;
CREATE TABLE work.mat_sup_suppliercapacityschedule AS 
SELECT  a.*,
		b.ID AS supplier Label='supplier'
FROM work.mat_sup_suppliercapacityschedule a 
LEFT OUTER JOIN realdb7.com_par_partner b ON compress(a.Suppl_nr)=compress(b.code);
QUIT;

PROC SQL;
CREATE TABLE work.mat_sup_suppliercapacityschedule AS 
SELECT  a.*,
		b.ID AS supplierCapacityGroup Label='supplierCapacityGroup'
FROM work.mat_sup_suppliercapacityschedule a 
LEFT OUTER JOIN realdb7.mat_sup_suppliercapacitygroup b ON a.supplier=b.supplierCapacityContract AND a.Capacity_group=b.code;
QUIT;



/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.mat_sup_suppliercapacityschedule; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE ( UPDATE mat_sup_suppliercapacityschedule as a inner join update_table as b 
on a.supplierCapacityGroup=b.supplierCapacityGroup AND  a.deliveryYear=b.deliveryYear AND a.deliveryWeek=b.deliveryWeek
SET  a.Capacity=b.Capacity) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE Work.mat_sup_suppliercapacityschedule AS 
SELECT a.*,	b.supplierCapacityGroup AS Check_record label='Check_record'
FROM work.mat_sup_suppliercapacityschedule a LEFT OUTER JOIN RealDB7.mat_sup_suppliercapacityschedule b 
ON a.deliveryYear=b.deliveryYear AND a.deliveryWeek=b.deliveryWeek AND a.supplierCapacityGroup=b.supplierCapacityGroup ;
QUIT;

PROC APPEND BASE=RealDB7.mat_sup_suppliercapacityschedule DATA=work.mat_sup_suppliercapacityschedule FORCE; WHERE Check_record=. AND supplierCapacityGroup NE .; RUN;







/*******************************/
/* com_par_addressdeliveryslot */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_par_addressdeliveryslot as select * from connection to baan
   (SELECT  a.t_adky AS Address1,
			a.t_dayn AS DayOfWeek1,
			a.t_optm AS OpeningTime,
			a.t_cltm AS ClosingTime
   FROM      ttdcox110130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_par_addressdeliveryslot_EAP as select * from connection to baan
   (SELECT  a.t_adky AS Address1,
			a.t_dayn AS DayOfWeek1,
			a.t_optm AS OpeningTime,
			a.t_cltm AS ClosingTime
   FROM      ttdcox110300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_par_addressdeliveryslot_KSI as select * from connection to baan
   (SELECT  a.t_adky AS Address1,
			a.t_dayn AS DayOfWeek1,
			a.t_optm AS OpeningTime,
			a.t_cltm AS ClosingTime
   FROM      ttdcox110400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.com_par_addressdeliveryslot_AFM as select * from connection to baan
   (SELECT  a.t_adky AS Address1,
			a.t_dayn AS DayOfWeek1,
			a.t_optm AS OpeningTime,
			a.t_cltm AS ClosingTime
   FROM      ttdcox110601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.com_par_addressdeliveryslot DATA=work.com_par_addressdeliveryslot_EAP; RUN;

PROC SORT DATA=work.com_par_addressdeliveryslot nodupkey; BY Address1 DayOfWeek1; RUN;

DATA work.com_par_addressdeliveryslot1; SET work.com_par_addressdeliveryslot ;
/* address translation */
partnercode=substr(Address1,2,6);
addresscode="D"||substr(Address1,8,3);
/* day of week */
IF DayOfWeek1=1 	THEN DayOfWeekT='SU';
IF DayOfWeekT='SU' 	THEN DayOfWeek='7';

IF DayOfWeek1=2 	THEN DayOfWeekT='MO';
IF DayOfWeekT='MO' 	THEN DayOfWeek='1';

IF DayOfWeek1=3 	THEN DayOfWeekT='TU';
IF DayOfWeekT='TU' 	THEN DayOfWeek='2';

IF DayOfWeek1=4 	THEN DayOfWeekT='WE';
IF DayOfWeekT='WE' 	THEN DayOfWeek='3';

IF DayOfWeek1=5 	THEN DayOfWeekT='TH';
IF DayOfWeekT='TH' 	THEN DayOfWeek='4';

IF DayOfWeek1=6 	THEN DayOfWeekT='FR';
IF DayOfWeekT='FR' 	THEN DayOfWeek='5';

IF DayOfWeek1=7 	THEN DayOfWeekT='SA';
IF DayOfWeekT='SA' 	THEN DayOfWeek='6';

archived=0;
createddate=datetime();
dataareaid=0;
version=0;
createdby='SAS-Job';
WHERE substr(Address1,1,1)='D';
RUN;

PROC SQL;
CREATE TABLE work.com_par_addressdeliveryslot1 AS
SELECT  a.*,
		b.id AS partner
FROM work.com_par_addressdeliveryslot1 a LEFT OUTER JOIN realdb7.com_par_partner b ON a.partnercode=b.code;
QUIT;

PROC SQL;
CREATE TABLE work.com_par_addressdeliveryslot1 AS
SELECT  a.*,
		b.id AS Address
FROM work.com_par_addressdeliveryslot1 a LEFT OUTER JOIN realdb7.com_par_address b ON a.partner=b.partner AND a.addresscode=b.code;
QUIT;

PROC SORT DATA=work.com_par_addressdeliveryslot1 nodupkey; BY Address DayOfWeek; RUN;



/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;


PROC APPEND BASE=realdb7.update_table DATA=work.com_par_addressdeliveryslot1; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
com_par_addressdeliveryslot as a inner join update_table as b on a.Address=b.Address AND a.DayOfWeek=b.DayOfWeek

SET  
a.OpeningTime=b.OpeningTime, a.ClosingTime=b.ClosingTime
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE work.com_par_addressdeliveryslot1 AS 
SELECT  a.*,
		b.ID AS check_record label='check_record'
FROM work.com_par_addressdeliveryslot1 a LEFT OUTER JOIN RealDB7.com_par_addressdeliveryslot b ON a.Address=b.Address AND a.DayOfWeek=b.DayOfWeek ;
QUIT;

PROC APPEND BASE=RealDB7.com_par_addressdeliveryslot DATA=work.com_par_addressdeliveryslot1 FORCE; WHERE check_record=. AND Address NE . AND DayOfWeek NE ''; RUN;


/*********************/
/* prd_cal_prdaytype */
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_cal_prdaytype as select * from connection to baan
   (SELECT  a.t_ctod AS code,
			a.t_dsca AS description,
			a.t_pcwt AS hoursperday1
   FROM      ttirou420130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_cal_prdaytype_EAP as select * from connection to baan
   (SELECT  a.t_ctod AS code,
			a.t_dsca AS description,
			a.t_pcwt AS hoursperday1
   FROM      ttirou420300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_cal_prdaytype_KSI as select * from connection to baan
   (SELECT  a.t_ctod AS code,
			a.t_dsca AS description,
			a.t_pcwt AS hoursperday1
   FROM      ttirou420400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_cal_prdaytype_AFM as select * from connection to baan
   (SELECT  a.t_ctod AS code,
			a.t_dsca AS description,
			a.t_pcwt AS hoursperday1
   FROM      ttirou420601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.prd_cal_prdaytype DATA=work.prd_cal_prdaytype_EAP; RUN;
PROC APPEND BASE=work.prd_cal_prdaytype DATA=work.prd_cal_prdaytype_KSI; RUN;
PROC APPEND BASE=work.prd_cal_prdaytype DATA=work.prd_cal_prdaytype_AFM; RUN;

PROC SORT DATA=work.prd_cal_prdaytype nodupkey; BY code; RUN;

DATA work.prd_cal_prdaytype1; SET work.prd_cal_prdaytype ;
code=compress(code);
FORMAT hoursperday 3.1;
hoursperday=hoursperday1/100;
archived=0;
createddate=datetime();
dataareaid=0;
version=0;
createdby='SAS-Job';
RUN;



/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.prd_cal_prdaytype1; RUN;


PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
prd_cal_prdaytype as a inner join update_table as b on a.code=b.code

SET  
a.hoursperday=b.hoursperday
) by MySQL;
QUIT;

/* Insert New Records */
PROC SQL;
CREATE TABLE work.prd_cal_prdaytype1 AS 
SELECT  a.*,
		b.ID AS check_record Label='check_record'
FROM work.prd_cal_prdaytype1 a LEFT OUTER JOIN RealDB7.prd_cal_prdaytype b ON a.code=b.code;
QUIT;

PROC APPEND BASE=RealDB7.prd_cal_prdaytype DATA=work.prd_cal_prdaytype1 FORCE; WHERE check_record=.; RUN;






/*********************/
/* prd_cal_prcalendar*/
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_cal_prcalendar as select * from connection to baan
   (SELECT  a.t_cwoc AS workcenter1,
			a.t_date AS productiondate,
			a.t_ctod AS daytype1
   FROM      ttirou400130 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_cal_prcalendar_EAP as select * from connection to baan
   (SELECT  a.t_cwoc AS workcenter1,
			a.t_date AS productiondate,
			a.t_ctod AS daytype1
   FROM      ttirou400300 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_cal_prcalendar_KSI as select * from connection to baan
   (SELECT  a.t_cwoc AS workcenter1,
			a.t_date AS productiondate,
			a.t_ctod AS daytype1
   FROM      ttirou400400 a  );
 DISCONNECT from baan;
QUIT;
PROC SQL;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.prd_cal_prcalendar_AFM as select * from connection to baan
   (SELECT  a.t_cwoc AS workcenter1,
			a.t_date AS productiondate,
			a.t_ctod AS daytype1
   FROM      ttirou400601 a  );
 DISCONNECT from baan;
QUIT;

PROC APPEND BASE=work.prd_cal_prcalendar DATA=work.prd_cal_prcalendar_EAP; RUN;
PROC APPEND BASE=work.prd_cal_prcalendar DATA=work.prd_cal_prcalendar_KSI; RUN;
PROC APPEND BASE=work.prd_cal_prcalendar DATA=work.prd_cal_prcalendar_AFM; RUN;

PROC SORT DATA=work.prd_cal_prcalendar nodupkey; BY workcenter1 productiondate; RUN;

DATA work.prd_cal_prcalendar1; SET work.prd_cal_prcalendar;
archived=0;
createddate=datetime();
dataareaid=0;
version=0;
createdby='SAS-Job';
/*IF workcenter1=' SD' THEN workcenter1='SDT';*/
WHERE productiondate>MDY(01,01,2023);
RUN;

PROC SQL;
CREATE TABLE work.prd_cal_prcalendar1 AS
SELECT  a.*,
		b.department AS workcenter
FROM work.prd_cal_prcalendar1 a LEFT OUTER JOIN realdb7.prd_bas_workcenter b ON compress(a.workcenter1)=compress(b.baanCwoc); /*DV 202509: toevoeging compress voor b.baanCwoc) om ook EL en DL kalenders over te kunnen zetten*/
QUIT;


PROC SQL;
CREATE TABLE work.prd_cal_prcalendar1 AS
SELECT  a.*,
		b.id AS daytype
FROM work.prd_cal_prcalendar1 a LEFT OUTER JOIN realdb7.prd_cal_prdaytype b ON compress(a.daytype1)=b.code;
QUIT;

PROC SORT DATA=work.prd_cal_prcalendar1 nodupkey; BY workcenter productiondate; RUN;



/* Update Difference */
PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (DROP  TABLE   update_table  ) by MySQL;
QUIT;

PROC APPEND BASE=realdb7.update_table DATA=work.prd_cal_prcalendar1; RUN;

PROC SQL;
CONNECT to odbc as MySQL (dsn='realdb7');
EXECUTE (
UPDATE 
prd_cal_prcalendarentry as a inner join update_table as b on a.workcenter=b.workcenter AND a.productiondate=b.productiondate

SET  
a.daytype=b.daytype
) by MySQL;
QUIT;


/* Insert New Records */
PROC SQL;
CREATE TABLE work.prd_cal_prcalendar1 AS 
SELECT  a.*,
		b.ID AS check_record Label='check_record'
FROM work.prd_cal_prcalendar1 a LEFT OUTER JOIN RealDB7.prd_cal_prcalendarentry b ON a.workcenter=b.workcenter AND a.productiondate=b.productiondate;
QUIT;

PROC APPEND BASE=RealDB7.prd_cal_prcalendarentry DATA=work.prd_cal_prcalendar1 FORCE; WHERE check_record=. AND workcenter NE .; RUN;
