
/**********************************************************************/
/****    Updating Dimset Roermond data to db2                      ****/
/**********************************************************************/

/* Roermond */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.dimsets as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dsca   	Dim_descr,
            a.t_fivw_c 	Fin_vw_code,
			a.t_txta_c	Txt_nr,
            b.t_desc   	Fin_vw_descr,
            c.t_desc   	Fin_vw_group_descr,
			d.t_subs   	Substrate,
			d.t_wdgr   	Width_group,
			d.t_argr   	Toll_Fullpr,
			d.t_clpl   	Coil_plate,
			d.t_pgrp   	Prod_group
   FROM         ttdmdm010120 a,
                ttfgld008120 b,
                ttfgld008120 c,
				ttdlra905120 d
   WHERE    substr(a.t_fivw_c,2,5)=b.t_leac AND
            b.t_plac = c.t_leac  			AND
			a.t_fivw_c = d.t_view
   ORDER  by  a.t_dset  );
CREATE table work.mdm995 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dscb   	Dim_descr2,
			a.t_prfl   	Dim_proc_flow,
			a.t_item   	Dim_item,
			a.t_cupn   	Dim_cust_partnr,
			a.t_cuno   	Dim_cust_nr,
			a.t_cuic	Dim_cust_end_nr,
			a.t_suno	Dim_suppl_nr,
			a.t_idst	Dim_inp_dims_nr,
			a.t_dist	Dim_stat_nr,
			a.t_prot	Dim_type_nr,
			a.t_mrkt	Markt_market,
			a.t_prgr	Markt_prod_group,
			a.t_brnd	Markt_brand,
			a.t_crdt	Dim_creation_date,
			a.t_note	Dim_note,
			a.t_bset	Dim_Base_dimset,
			a.t_cpri	Dim_SHT_Comp_price,
			a.t_pric	Dim_SHT_Price,
			a.t_ccur	Dim_SHT_Curr,
			a.t_adpr	Dim_SHT_Adj_Perc,
			a.t_adam	Dim_SHT_Adj_amounth
   FROM         ttdmdm995120 a
   ORDER  by  a.t_dset  );
CREATE table work.market as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_dset   	Dimset,
			a.t_mrkt	Markt_market,
			b.t_dscl	Markt_market_descl,
			b.t_dscs	Markt_market_descs,
			a.t_prgr	Markt_prod_group,
			c.t_desc	Markt_prod_group_desc,
			a.t_brnd	Markt_brand,
			d.t_name	Markt_brand_name
   FROM         ttdmdm995120 a,
   				ttdslx300120 b,
				ttdslx301120 c,
				ttdslx310120 d
   WHERE	a.t_mrkt = b.t_mrkt AND
   			a.t_prgr = c.t_prgr AND
			a.t_brnd = d.t_brnd
   ORDER  by  a.t_dset  );
CREATE table work.dim_specs as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_dset    Dimset,
   			a.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdlra220120 a
   WHERE    ((a.t_spec>'000009' AND a.t_spec<'001101') OR
			a.t_spec IN ("080020","010010","010020","011010","011020","011030","011040","012010","012020","012030","012040",
						 "020010","050120","060010","060040","060070","061010","100090","100200","100210","030010","040010" )) AND a.t_item <>'OMW'	  );
CREATE table work.dim_specs1 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_dset    Dimset,
   			b.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdmdm023120 a,
   				ttdmdm012120 b
   WHERE    a.t_dset = b.t_dset AND  
			a.t_spec>'000009' 	AND a.t_spec<'001101' 	AND
   			a.t_dset>'4000000' 	AND a.t_dset<'4599999' 	AND b.t_item <>'OMW'  );
CREATE table work.lakdim as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_pntc   	Dimset,
   			a.t_dsca    Paint_descr,
			b.t_ctnm	Paint_type,
			a.t_pnts	Paint_syst,
			a.t_cwoc	Paint_dep,
			a.t_rbbc    Paint_ral,
			c.t_ctnm	Paint_stat
   FROM         ttdqua100120 a,
   				tttadv401000 b,
				tttadv401000 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511' 	AND
			a.t_pnst=c.t_cnst AND c.t_vers='B40O' AND c.t_cpac='td' AND c.t_cdom='qua.pnst' AND c.t_cust='m511'
   ORDER  by  a.t_pntc  );
CREATE table work.laksupl as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_pntc   	Dimset,
			a.t_suno	Paint_suppl,
			b.t_valu	Paint_coverage_suppl1,
			a.t_sups	Status
   FROM         ttdqua101120 a LEFT OUTER JOIN ttdqua102120 b ON a.t_pntc = b.t_pntc 	AND a.t_suno = b.t_suno 	AND 
																 a.t_sups=4 			AND b.t_cspe = "REND_LAK" 
   ORDER  by  a.t_pntc  );
CREATE table work.grootb as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_cdac    Led_acc_nr,
            a.t_view_c  Fin_vw_code,
            b.t_desc    Led_acc_desc,
            c.t_desc    Led_acc_grp_desc
   FROM         ttdsls071120 a,
                ttfgld008120 b,
                ttfgld008120 c
   WHERE    a.t_ckds=3 			AND
            a.t_cdac = b.t_leac AND
            a.t_cwar > " " 		AND
            b.t_plac = c.t_leac AND
			a.t_cwar='ECP'  );
CREATE table work.Foil_g_m2 as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_ftyp    Foil_type,
            a.t_thck    Foil_thickn,
            a.t_sgrv    Foil_g_m2
   FROM         ttdqua150120 a  );
CREATE table work.dim_safety as select * from connection to baan
   (SELECT  'Roe'		AS Company,
			a.t_dset    Dimset,
			a.t_mioq	Dim_min_ord_quan,
			a.t_sfst	Dim_safety_stock,
			a.t_ibuq	Default_Det_size,
			CASE 
WHEN		a.t_tpur=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Purchase,
			CASE 
WHEN		a.t_tsls=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Sales
   FROM         ttdmdm012120 a  );
 DISCONNECT from baan;
QUIT;

/* Corby */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.dimsets_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dsca   	Dim_descr,
            a.t_fivw_c 	Fin_vw_code,
			a.t_txta_c	Txt_nr,
            b.t_desc   	Fin_vw_descr,
            c.t_desc   	Fin_vw_group_descr,
			d.t_subs   	Substrate,
			d.t_wdgr   	Width_group,
			d.t_argr   	Toll_Fullpr,
			d.t_clpl   	Coil_plate,
			d.t_pgrp   	Prod_group
   FROM         ttdmdm010200 a,
                ttfgld008200 b,
                ttfgld008200 c,
				ttdlra905200 d
   WHERE    substr(a.t_fivw_c,2,5)=b.t_leac and
            b.t_plac = c.t_leac  AND
			a.t_fivw_c = d.t_view
   ORDER  by  a.t_dset  );
CREATE table work.mdm995_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dscb   	Dim_descr2,
			a.t_prfl   	Dim_proc_flow,
			a.t_item   	Dim_item,
			a.t_cupn   	Dim_cust_partnr,
			a.t_cuno   	Dim_cust_nr,
			a.t_cuic	Dim_cust_end_nr,
			a.t_suno	Dim_suppl_nr,
			a.t_idst	Dim_inp_dims_nr,
			a.t_dist	Dim_stat_nr,
			a.t_prot	Dim_type_nr,
			a.t_mrkt	Markt_market,
			a.t_prgr	Markt_prod_group,
			a.t_brnd	Markt_brand,
			a.t_crdt	Dim_creation_date,
			a.t_note	Dim_note,
			a.t_bset	Dim_Base_dimset,
			a.t_cpri	Dim_SHT_Comp_price,
			a.t_pric	Dim_SHT_Price,
			a.t_ccur	Dim_SHT_Curr,
			a.t_adpr	Dim_SHT_Adj_Perc,
			a.t_adam	Dim_SHT_Adj_amounth
   FROM         ttdmdm995200 a
   ORDER  by  a.t_dset  );
CREATE table work.market_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_dset   	Dimset,
			a.t_mrkt	Markt_market,
			b.t_dscl	Markt_market_descl,
			b.t_dscs	Markt_market_descs,
			a.t_prgr	Markt_prod_group,
			c.t_desc	Markt_prod_group_desc,
			a.t_brnd	Markt_brand,
			d.t_name	Markt_brand_name
   FROM         ttdmdm995200 a,
   				ttdslx300200 b,
				ttdslx301200 c,
				ttdslx310200 d
   WHERE	a.t_mrkt = b.t_mrkt AND
   			a.t_prgr = c.t_prgr AND
			a.t_brnd = d.t_brnd
   ORDER  by  a.t_dset  );
CREATE table work.dim_specs_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_dset    Dimset,
   			a.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdlra220200 a
   WHERE    ((a.t_spec>'000009' AND a.t_spec<'001101') OR
			a.t_spec IN ("080020","010010","010020","011010","011020","011030","011040","012010","012020","012030","012040",
						 "020010","050120","060010","060040","060070","061010","100090","100200","100210","030010","040010" )) AND a.t_item <>'OMW'	  );
CREATE table work.dim_specs1_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_dset    Dimset,
   			b.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdmdm023200 a,
   				ttdmdm012200 b
   WHERE    a.t_dset = b.t_dset AND  
			a.t_spec>'000009' 	AND a.t_spec<'001101' 	AND
   			a.t_dset>'4000000' 	AND a.t_dset<'4599999' 	AND b.t_item <>'OMW'  );
CREATE table work.lakdim_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_pntc   	Dimset,
   			a.t_dsca    Paint_descr,
			b.t_ctnm	Paint_type,
			a.t_pnts	Paint_syst,
			a.t_cwoc	Paint_dep,
			a.t_rbbc    Paint_ral,
			c.t_ctnm	Paint_stat
   FROM         ttdqua100200 a,
   				tttadv401000 b,
				tttadv401000 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511' AND
			a.t_pnst=c.t_cnst AND c.t_vers='B40O' AND c.t_cpac='td' AND c.t_cdom='qua.pnst' AND c.t_cust='m511'
   ORDER  by  a.t_pntc  );
CREATE table work.laksupl_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_pntc   	Dimset,
			a.t_suno	Paint_suppl,
			b.t_valu	Paint_coverage_suppl1,
			a.t_sups	Status
   FROM         ttdqua101200 a LEFT OUTER JOIN ttdqua102200 b ON a.t_pntc = b.t_pntc AND a.t_suno = b.t_suno 	AND 
																 a.t_sups=4          AND b.t_cspe = "REND_LAK" 
   ORDER  by  a.t_pntc  );
CREATE table work.grootb_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_cdac    Led_acc_nr,
            a.t_view_c  Fin_vw_code,
            b.t_desc    Led_acc_desc,
            c.t_desc    Led_acc_grp_desc
   FROM         ttdsls071200 a,
                ttfgld008200 b,
                ttfgld008200 c
   WHERE    a.t_ckds=3 			AND
            a.t_cdac = b.t_leac AND
            a.t_cwar > " " 		AND
            b.t_plac = c.t_leac AND
			a.t_cwar='ECP'  );
CREATE table work.Foil_g_m2_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_ftyp    Foil_type,
            a.t_thck    Foil_thickn,
            a.t_sgrv    Foil_g_m2
   FROM         ttdqua150200 a  );
CREATE table work.dim_safety_Cor as select * from connection to baan
   (SELECT  'Cor'		AS Company,
			a.t_dset    Dimset,
			a.t_mioq	Dim_min_ord_quan,
			a.t_sfst	Dim_safety_stock,
			a.t_ibuq	Default_Det_size,
			CASE 
WHEN		a.t_tpur=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Purchase,
			CASE 
WHEN		a.t_tsls=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Sales
   FROM         ttdmdm012200 a  );
 DISCONNECT from baan;
QUIT;


/* ECP */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.dimsets_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dsca   	Dim_descr,
            a.t_fivw_c 	Fin_vw_code,
			a.t_txta_c	Txt_nr,
            b.t_desc   	Fin_vw_descr,
            c.t_desc   	Fin_vw_group_descr,
			d.t_subs   	Substrate,
			d.t_wdgr   	Width_group,
			d.t_argr   	Toll_Fullpr,
			d.t_clpl   	Coil_plate,
			d.t_pgrp   	Prod_group
   FROM         ttdmdm010130 a,
                ttfgld008130 b,
                ttfgld008130 c,
				ttdlra905130 d
   WHERE    substr(a.t_fivw_c,2,5)=b.t_leac and
            b.t_plac = c.t_leac  AND
			a.t_fivw_c = d.t_view
   ORDER  by  a.t_dset  );
CREATE table work.mdm995_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dscb   	Dim_descr2,
			a.t_prfl   	Dim_proc_flow,
			a.t_item   	Dim_item,
			a.t_cupn   	Dim_cust_partnr,
			a.t_cuno   	Dim_cust_nr,
			a.t_cuic	Dim_cust_end_nr,
			a.t_suno	Dim_suppl_nr,
			a.t_idst	Dim_inp_dims_nr,
			a.t_dist	Dim_stat_nr,
			a.t_prot	Dim_type_nr,
			a.t_mrkt	Markt_market,
			a.t_prgr	Markt_prod_group,
			a.t_brnd	Markt_brand,
			a.t_crdt	Dim_creation_date,
			a.t_note	Dim_note,
			a.t_bset	Dim_Base_dimset,
			a.t_cpri	Dim_SHT_Comp_price,
			a.t_pric	Dim_SHT_Price,
			a.t_ccur	Dim_SHT_Curr,
			a.t_adpr	Dim_SHT_Adj_Perc,
			a.t_adam	Dim_SHT_Adj_amounth
   FROM         ttdmdm995130 a
   ORDER  by  a.t_dset  );
CREATE table work.market_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_dset   	Dimset,
			a.t_mrkt	Markt_market,
			b.t_dscl	Markt_market_descl,
			b.t_dscs	Markt_market_descs,
			a.t_prgr	Markt_prod_group,
			c.t_desc	Markt_prod_group_desc,
			a.t_brnd	Markt_brand,
			d.t_name	Markt_brand_name
   FROM         ttdmdm995130 a,
   				ttdslx300130 b,
				ttdslx301130 c,
				ttdslx310130 d
   WHERE	a.t_mrkt = b.t_mrkt AND
   			a.t_prgr = c.t_prgr AND
			a.t_brnd = d.t_brnd
   ORDER  by  a.t_dset  );
CREATE table work.dim_specs_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_dset    Dimset,
   			a.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdlra220130 a
   WHERE    ((a.t_spec>'000009' AND a.t_spec<'001101') OR
			a.t_spec IN ("080020","010010","010020","011010","011020","011030","011040","012010","012020","012030","012040",
						 "020010","050120","060010","060040","060070","061010","100090","100200","100210","030010","040010" )) AND a.t_item <>'OMW'	  );
CREATE table work.dim_specs1_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_dset    Dimset,
   			b.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdmdm023130 a,
   				ttdmdm012130 b
   WHERE    a.t_dset = b.t_dset AND  
			a.t_spec>'000009'   AND a.t_spec<'001101'  AND
   			a.t_dset>'4000000'  AND a.t_dset<'4599999' AND b.t_item <>'OMW'  );
CREATE table work.lakdim_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_pntc   	Dimset,
   			a.t_dsca    Paint_descr,
			b.t_ctnm	Paint_type,
			a.t_pnts	Paint_syst,
			a.t_cwoc	Paint_dep,
			a.t_rbbc    Paint_ral,
			c.t_ctnm	Paint_stat
   FROM         ttdqua100130 a,
   				tttadv401000 b,
				tttadv401000 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511' AND
			a.t_pnst=c.t_cnst AND c.t_vers='B40O' AND c.t_cpac='td' AND c.t_cdom='qua.pnst' AND c.t_cust='m511'
   ORDER  by  a.t_pntc  );
CREATE table work.laksupl_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_pntc   	Dimset,
			a.t_suno	Paint_suppl,
			b.t_valu	Paint_coverage_suppl1,
			a.t_sups	Status
   FROM         ttdqua101130 a LEFT OUTER JOIN ttdqua102130 b ON a.t_pntc = b.t_pntc AND a.t_suno = b.t_suno 	AND 
																 a.t_sups=4 		 AND b.t_cspe = "REND_LAK" 
   ORDER  by  a.t_pntc  );
CREATE table work.grootb_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_cdac    Led_acc_nr,
            a.t_view_c  Fin_vw_code,
            b.t_desc    Led_acc_desc,
            c.t_desc    Led_acc_grp_desc
   FROM         ttdsls071130 a,
                ttfgld008130 b,
                ttfgld008130 c
   WHERE    a.t_ckds=3 			AND
            a.t_cdac = b.t_leac AND
            a.t_cwar > " " 		AND
            b.t_plac = c.t_leac AND
			a.t_cwar='ECP'  );
CREATE table work.Foil_g_m2_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_ftyp    Foil_type,
            a.t_thck    Foil_thickn,
            a.t_sgrv    Foil_g_m2
   FROM         ttdqua150130 a  );
CREATE table work.dim_safety_ECP as select * from connection to baan
   (SELECT  'ECP'		AS Company,
			a.t_dset    Dimset,
			a.t_mioq	Dim_min_ord_quan,
			a.t_sfst	Dim_safety_stock,
			a.t_ibuq	Default_Det_size,
			CASE 
WHEN		a.t_tpur=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Purchase,
			CASE 
WHEN		a.t_tsls=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Sales
   FROM         ttdmdm012130 a  );
 DISCONNECT from baan;
QUIT;


/* EAP */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.dimsets_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dsca   	Dim_descr,
            a.t_fivw_c 	Fin_vw_code,
			a.t_txta_c	Txt_nr,
            b.t_desc   	Fin_vw_descr,
            c.t_desc   	Fin_vw_group_descr,
			d.t_subs   	Substrate,
			d.t_wdgr   	Width_group,
			d.t_argr   	Toll_Fullpr,
			d.t_clpl   	Coil_plate,
			d.t_pgrp   	Prod_group
   FROM         ttdmdm010300 a,
                ttfgld008300 b,
                ttfgld008300 c,
				ttdlra905300 d
   WHERE    substr(a.t_fivw_c,2,5)=b.t_leac and
            b.t_plac = c.t_leac  AND
			a.t_fivw_c = d.t_view
   ORDER  by  a.t_dset  );
CREATE table work.mdm995_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dscb   	Dim_descr2,
			a.t_prfl   	Dim_proc_flow,
			a.t_item   	Dim_item,
			a.t_cupn   	Dim_cust_partnr,
			a.t_cuno   	Dim_cust_nr,
			a.t_cuic	Dim_cust_end_nr,
			a.t_suno	Dim_suppl_nr,
			a.t_idst	Dim_inp_dims_nr,
			a.t_dist	Dim_stat_nr,
			a.t_prot	Dim_type_nr,
			a.t_mrkt	Markt_market,
			a.t_prgr	Markt_prod_group,
			a.t_brnd	Markt_brand,
			a.t_crdt	Dim_creation_date,
			a.t_note	Dim_note,
			a.t_bset	Dim_Base_dimset,
			a.t_cpri	Dim_SHT_Comp_price,
			a.t_pric	Dim_SHT_Price,
			a.t_ccur	Dim_SHT_Curr,
			a.t_adpr	Dim_SHT_Adj_Perc,
			a.t_adam	Dim_SHT_Adj_amounth
   FROM         ttdmdm995300 a
   ORDER  by  a.t_dset  );
CREATE table work.market_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_dset   	Dimset,
			a.t_mrkt	Markt_market,
			b.t_dscl	Markt_market_descl,
			b.t_dscs	Markt_market_descs,
			a.t_prgr	Markt_prod_group,
			c.t_desc	Markt_prod_group_desc,
			a.t_brnd	Markt_brand,
			d.t_name	Markt_brand_name
   FROM         ttdmdm995300 a,
   				ttdslx300300 b,
				ttdslx301300 c,
				ttdslx310300 d
   WHERE	a.t_mrkt = b.t_mrkt AND
   			a.t_prgr = c.t_prgr AND
			a.t_brnd = d.t_brnd
   ORDER  by  a.t_dset  );
CREATE table work.dim_specs_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_dset    Dimset,
   			a.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdlra220300 a
   WHERE    ((a.t_spec>'000009' AND a.t_spec<'001101') OR
			a.t_spec IN ("080020","010010","010020","011010","011020","011030","011040","012010","012020","012030","012040",
						 "020010","050120","060010","060040","060070","061010","100090","100200","100210","030010","040010" )) AND a.t_item <>'OMW'	  );
CREATE table work.dim_specs1_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_dset    Dimset,
   			b.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdmdm023300 a,
   				ttdmdm012300 b
   WHERE    a.t_dset = b.t_dset AND  
			a.t_spec>'000009' 	AND a.t_spec<'001101' 	AND
   			a.t_dset>'4000000' 	AND a.t_dset<'4599999' 	AND b.t_item <>'OMW'  );
CREATE table work.lakdim_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_pntc   	Dimset,
   			a.t_dsca    Paint_descr,
			b.t_ctnm	Paint_type,
			a.t_pnts	Paint_syst,
			a.t_cwoc	Paint_dep,
			a.t_rbbc    Paint_ral,
			c.t_ctnm	Paint_stat
   FROM         ttdqua100300 a,
   				tttadv401000 b,
				tttadv401000 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511' AND
			a.t_pnst=c.t_cnst AND c.t_vers='B40O' AND c.t_cpac='td' AND c.t_cdom='qua.pnst' AND c.t_cust='m511'
   ORDER  by  a.t_pntc  );
CREATE table work.laksupl_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_pntc   	Dimset,
			a.t_suno	Paint_suppl,
			b.t_valu	Paint_coverage_suppl1,
			a.t_sups	Status
   FROM         ttdqua101300 a LEFT OUTER JOIN ttdqua102300 b ON a.t_pntc = b.t_pntc 	AND a.t_suno = b.t_suno 	AND 
																 a.t_sups=4 			AND b.t_cspe = "REND_LAK" 
   ORDER  by  a.t_pntc  );
CREATE table work.grootb_EAP as select * from connection to baan
   (SELECT  'EAP'	 	AS Company,
			a.t_cdac   	Led_acc_nr,
            a.t_view_c 	Fin_vw_code,
            b.t_desc   	Led_acc_desc,
            c.t_desc   	Led_acc_grp_desc
   FROM         ttdsls071300 a,
                ttfgld008300 b,
                ttfgld008300 c
   WHERE    a.t_ckds=3 			AND
            a.t_cdac = b.t_leac AND
            a.t_cwar > " " 		AND
            b.t_plac = c.t_leac AND
			a.t_cwar='ECP'  );
CREATE table work.Foil_g_m2_EAP as select * from connection to baan
   (SELECT  'EAP'	   AS Company,
			a.t_ftyp   Foil_type,
            a.t_thck   Foil_thickn,
            a.t_sgrv   Foil_g_m2
   FROM         ttdqua150300 a  );
CREATE table work.dim_safety_EAP as select * from connection to baan
   (SELECT  'EAP'		AS Company,
			a.t_dset    Dimset,
			a.t_mioq	Dim_min_ord_quan,
			a.t_sfst	Dim_safety_stock,
			a.t_ibuq	Default_Det_size,
			CASE 
WHEN		a.t_tpur=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Purchase,
			CASE 
WHEN		a.t_tsls=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Sales
   FROM         ttdmdm012300 a  );
 DISCONNECT from baan;
QUIT;

/* KSI */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.dimsets_KSI as select * from connection to baan
   (SELECT  'KSI'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dsca   	Dim_descr,
            a.t_fivw_c 	Fin_vw_code,
			a.t_txta_c	Txt_nr,
            b.t_desc   	Fin_vw_descr,
            c.t_desc   	Fin_vw_group_descr,
			d.t_subs   	Substrate,
			d.t_wdgr   	Width_group,
			d.t_argr   	Toll_Fullpr,
			d.t_clpl   	Coil_plate,
			d.t_pgrp   	Prod_group
   FROM         ttdmdm010400 a,
                ttfgld008400 b,
                ttfgld008400 c,
				ttdlra905400 d
   WHERE    substr(a.t_fivw_c,2,5)=b.t_leac and
            b.t_plac = c.t_leac  AND
			a.t_fivw_c = d.t_view
   ORDER  by  a.t_dset  );
CREATE table work.mdm995_KSI as select * from connection to baan
   (SELECT  'KSI'		AS Company,
			a.t_dset   	Dimset,
   			a.t_dscb   	Dim_descr2,
			a.t_prfl   	Dim_proc_flow,
			a.t_item   	Dim_item,
			a.t_cupn   	Dim_cust_partnr,
			a.t_cuno   	Dim_cust_nr,
			a.t_cuic	Dim_cust_end_nr,
			a.t_suno	Dim_suppl_nr,
			a.t_idst	Dim_inp_dims_nr,
			a.t_dist	Dim_stat_nr,
			a.t_prot	Dim_type_nr,
			a.t_mrkt	Markt_market,
			a.t_prgr	Markt_prod_group,
			a.t_brnd	Markt_brand,
			a.t_crdt	Dim_creation_date,
			a.t_note	Dim_note,
			a.t_bset	Dim_Base_dimset,
			a.t_cpri	Dim_SHT_Comp_price,
			a.t_pric	Dim_SHT_Price,
			a.t_ccur	Dim_SHT_Curr,
			a.t_adpr	Dim_SHT_Adj_Perc,
			a.t_adam	Dim_SHT_Adj_amounth
   FROM         ttdmdm995400 a
   ORDER  by  a.t_dset  );
CREATE table work.market_KSI as select * from connection to baan
   (SELECT  'KSI'		AS Company,
			a.t_dset   	Dimset,
			a.t_mrkt	Markt_market,
			b.t_dscl	Markt_market_descl,
			b.t_dscs	Markt_market_descs,
			a.t_prgr	Markt_prod_group,
			c.t_desc	Markt_prod_group_desc,
			a.t_brnd	Markt_brand,
			d.t_name	Markt_brand_name
   FROM         ttdmdm995400 a,
   				ttdslx300400 b,
				ttdslx301400 c,
				ttdslx310400 d
   WHERE	a.t_mrkt = b.t_mrkt AND
   			a.t_prgr = c.t_prgr AND
			a.t_brnd = d.t_brnd
   ORDER  by  a.t_dset  );
CREATE table work.dim_specs_KSI as select * from connection to baan
   (SELECT  'KSI'		AS Company,
			a.t_dset    Dimset,
   			a.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdlra220400 a
   WHERE    ((a.t_spec>'000009' AND a.t_spec<'001101') OR
			a.t_spec IN ("080020","010010","010020","011010","011020","011030","011040","012010","012020","012030","012040",
						 "020010","050120","060010","060040","060070","061010","100090","100200","100210","030010","040010" )) AND a.t_item <>'OMW'	  );
CREATE table work.dim_specs1_KSI as select * from connection to baan
   (SELECT  'KSI'		AS Company,
			a.t_dset    Dimset,
   			b.t_item	Dim_item,
            a.t_spec    Dim_spec,
            a.t_nval    Value
   FROM         ttdmdm023400 a,
   				ttdmdm012400 b
   WHERE    a.t_dset = b.t_dset AND  
			a.t_spec>'000009' 	AND a.t_spec<'001101' 	AND
   			a.t_dset>'4000000' 	AND a.t_dset<'4599999' 	AND b.t_item <>'OMW'  );
CREATE table work.lakdim_KSI as select * from connection to baan
   (SELECT  'KSI'		AS Company,
			a.t_pntc   	Dimset,
   			a.t_dsca    Paint_descr,
			b.t_ctnm	Paint_type,
			a.t_pnts	Paint_syst,
			a.t_cwoc	Paint_dep,
			a.t_rbbc    Paint_ral,
			c.t_ctnm	Paint_stat
   FROM         ttdqua100400 a,
   				tttadv401000 b,
				tttadv401000 c
   WHERE 	a.t_meta=b.t_cnst AND b.t_vers='B40O' AND b.t_cpac='td' AND b.t_cdom='qua.meta' AND b.t_cust='m511' AND
			a.t_pnst=c.t_cnst AND c.t_vers='B40O' AND c.t_cpac='td' AND c.t_cdom='qua.pnst' AND c.t_cust='m511'
   ORDER  by  a.t_pntc  );
CREATE table work.laksupl_KSI as select * from connection to baan
   (SELECT  'KSI'		AS Company,
			a.t_pntc   	Dimset,
			a.t_suno	Paint_suppl,
			b.t_valu	Paint_coverage_suppl1,
			a.t_sups	Status
   FROM         ttdqua101400 a LEFT OUTER JOIN ttdqua102400 b ON a.t_pntc = b.t_pntc 	AND a.t_suno = b.t_suno 	AND 
																 a.t_sups=4 			AND b.t_cspe = "REND_LAK" 
   ORDER  by  a.t_pntc  );
CREATE table work.grootb_KSI as select * from connection to baan
   (SELECT  'KSI'	 	AS Company,
			a.t_cdac   	Led_acc_nr,
            a.t_view_c 	Fin_vw_code,
            b.t_desc   	Led_acc_desc,
            c.t_desc   	Led_acc_grp_desc
   FROM         ttdsls071400 a,
                ttfgld008400 b,
                ttfgld008400 c
   WHERE    a.t_ckds=3 			AND
            a.t_cdac = b.t_leac AND
            a.t_cwar > " " 		AND
            b.t_plac = c.t_leac AND
			a.t_cwar='ECP'  );
CREATE table work.Foil_g_m2_KSI as select * from connection to baan
   (SELECT  'KSI'	   AS Company,
			a.t_ftyp   Foil_type,
            a.t_thck   Foil_thickn,
            a.t_sgrv   Foil_g_m2
   FROM         ttdqua150400 a  );
CREATE table work.dim_safety_KSI as select * from connection to baan
   (SELECT  'KSI'		AS Company,
			a.t_dset    Dimset,
			a.t_mioq	Dim_min_ord_quan,
			a.t_sfst	Dim_safety_stock,
			a.t_ibuq	Default_Det_size,
			CASE 
WHEN		a.t_tpur=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Purchase,
			CASE 
WHEN		a.t_tsls=1 THEN 'Yes' ELSE 'No' END AS 	Dim_Sales
   FROM         ttdmdm012400 a  );
 DISCONNECT from baan;
QUIT;


PROC APPEND BASE=work.dimsets 		DATA=work.dimsets_Cor; 		RUN;
PROC APPEND BASE=work.dimsets 		DATA=work.dimsets_ECP; 		RUN;
PROC APPEND BASE=work.dimsets 		DATA=work.dimsets_EAP; 		RUN;
PROC APPEND BASE=work.dimsets 		DATA=work.dimsets_KSI; 		RUN;

PROC APPEND BASE=work.mdm995 		DATA=work.mdm995_Cor; 		RUN;
PROC APPEND BASE=work.mdm995 		DATA=work.mdm995_ECP; 		RUN;
PROC APPEND BASE=work.mdm995 		DATA=work.mdm995_EAP;	 	RUN;
PROC APPEND BASE=work.mdm995 		DATA=work.mdm995_KSI;	 	RUN;

PROC APPEND BASE=work.market 		DATA=work.market_Cor; 		RUN;
PROC APPEND BASE=work.market 		DATA=work.market_ECP; 		RUN;
PROC APPEND BASE=work.market 		DATA=work.market_EAP; 		RUN;
PROC APPEND BASE=work.market 		DATA=work.market_KSI; 		RUN;

PROC APPEND BASE=work.dim_specs 	DATA=work.dim_specs_Cor; 	RUN;
PROC APPEND BASE=work.dim_specs 	DATA=work.dim_specs_ECP; 	RUN;
PROC APPEND BASE=work.dim_specs 	DATA=work.dim_specs_EAP; 	RUN;
PROC APPEND BASE=work.dim_specs 	DATA=work.dim_specs_KSI; 	RUN;

PROC APPEND BASE=work.dim_specs1 	DATA=work.dim_specs1_Cor; 	RUN;
PROC APPEND BASE=work.dim_specs1 	DATA=work.dim_specs1_ECP; 	RUN;
PROC APPEND BASE=work.dim_specs1 	DATA=work.dim_specs1_EAP; 	RUN;
PROC APPEND BASE=work.dim_specs1 	DATA=work.dim_specs1_KSI; 	RUN;

PROC APPEND BASE=work.lakdim 		DATA=work.lakdim_Cor; 		RUN;
PROC APPEND BASE=work.lakdim 		DATA=work.lakdim_ECP; 		RUN;
PROC APPEND BASE=work.lakdim 		DATA=work.lakdim_EAP; 		RUN;
PROC APPEND BASE=work.lakdim 		DATA=work.lakdim_KSI; 		RUN;

PROC APPEND BASE=work.laksupl 		DATA=work.laksupl_Cor; 		RUN;
PROC APPEND BASE=work.laksupl 		DATA=work.laksupl_ECP; 		RUN;
PROC APPEND BASE=work.laksupl 		DATA=work.laksupl_EAP; 		RUN;
PROC APPEND BASE=work.laksupl 		DATA=work.laksupl_KSI; 		RUN;

PROC APPEND BASE=work.grootb 		DATA=work.grootb_Cor; 		RUN;
PROC APPEND BASE=work.grootb 		DATA=work.grootb_ECP; 		RUN;
PROC APPEND BASE=work.grootb 		DATA=work.grootb_EAP; 		RUN;
PROC APPEND BASE=work.grootb 		DATA=work.grootb_KSI; 		RUN;

PROC APPEND BASE=work.Foil_g_m2 	DATA=work.Foil_g_m2_Cor; 	RUN;
PROC APPEND BASE=work.Foil_g_m2 	DATA=work.Foil_g_m2_ECP; 	RUN;
PROC APPEND BASE=work.Foil_g_m2 	DATA=work.Foil_g_m2_EAP; 	RUN;
PROC APPEND BASE=work.Foil_g_m2 	DATA=work.Foil_g_m2_KSI; 	RUN;

PROC APPEND BASE=work.dim_safety 	DATA=work.dim_safety_Cor; 	RUN;
PROC APPEND BASE=work.dim_safety 	DATA=work.dim_safety_ECP; 	RUN;
PROC APPEND BASE=work.dim_safety 	DATA=work.dim_safety_EAP; 	RUN;
PROC APPEND BASE=work.dim_safety 	DATA=work.dim_safety_KSI; 	RUN;


PROC SORT DATA=work.dimsets;	BY Company Fin_vw_code;
PROC SORT DATA=work.grootb;		BY Company Fin_vw_code;	RUN;

DATA work.dimsets;
MERGE work.dimsets work.grootb;
BY Company Fin_vw_code;
IF led_acc_nr="" THEN
	DO;
	Led_acc_nr=Fin_vw_code;
	Led_acc_desc=Fin_vw_descr;
	Led_acc_grp_desc=Fin_vw_group_descr;
	END;
RUN;


PROC SQL;
CREATE TABLE work.dim_substr AS
(Select     a.Company,
			a.Dimset,
			b.Dim_inp_dims_nr AS Dim_inp_dims_4
 FROM  work.mdm995 a,
 	   work.mdm995 b
 WHERE a.company=b.company AND a.Dim_inp_dims_nr = b.Dimset AND SUBSTR(b.Dim_inp_dims_nr,1,1)= '4'  );
QUIT;


DATA work.laksupl (drop=status);
SET work.laksupl;
WHERE status=4;
RUN;


PROC SORT DATA=work.dimsets;	BY Company dimset;
PROC SORT DATA=work.mdm995;		BY Company dimset;
PROC SORT DATA=work.lakdim;		BY Company dimset;
PROC SORT DATA=work.laksupl;	BY Company dimset;
PROC SORT DATA=work.market;		BY Company dimset;
PROC SORT DATA=work.dim_safety;	BY Company dimset;
PROC SORT DATA=work.dim_substr;	BY Company dimset;	RUN;

DATA work.dimsets (DROP=Paint_coverage_suppl1);
MERGE work.dimsets work.mdm995 work.lakdim work.laksupl work.market work.dim_substr work.dim_safety;;
BY company dimset;
Paint_coverage_suppl=input(Paint_coverage_suppl1,11.0);
IF 	Fin_vw_code=' ' 				THEN DELETE;
IF not first.dimset 				THEN DELETE;
IF Substr(Dim_inp_dims_nr,1,1)='4' 	THEN Dim_inp_dims_4=Dim_inp_dims_nr;
IF Dim_creation_date=. 				THEN Dim_creation_date=MDY(01,01,1900);
IF Markt_brand="" 					THEN Markt_brand="-";
IF Markt_brand_name="" 				THEN Markt_brand_name="-";
IF Dim_inp_dims_4=""  				THEN Dim_inp_dims_4="-";
RUN;

DATA work.dimsets (drop=Dim_stat_nr Dim_type_nr);
SET work.dimsets;
Dim_stat="Unknown" ;
IF Dim_stat_nr=1 											THEN Dim_stat="Initial" ;
IF Dim_stat_nr=2 											THEN Dim_stat="Active " ;
IF Dim_stat_nr=3 											THEN Dim_stat="Blocked" ;
IF Dim_stat_nr=4 											THEN Dim_stat="Closed " ;
IF Dim_type_nr=1 											THEN Dim_type="Stnd.Plt.";
IF Dim_type_nr=2 											THEN Dim_type="Toolplate";
IF Dim_type_nr=3 											THEN Dim_type="Units    ";
IF Dim_type_nr=4 											THEN Dim_type="Roofs    "; 
IF Dim_type_nr=5 											THEN Dim_type="Panels   ";
IF Dim_type_nr=6 											THEN Dim_type="Aft.Sales";
IF Dim_type_nr=7 											THEN Dim_type="Coil     ";
IF width_group='Breed' 										THEN width_group='Wide';
IF width_group='Smal' 										THEN width_group='Stnd';
IF toll_fullpr='Volb' 										THEN toll_fullpr='Stnd';
IF substr(dimset,1,1)='9' AND Substrate in ('Alu','Ste') 	THEN Prod_group='Sheet';
IF Company='Cor' AND Dim_type_nr IN (2,3,4,5,6) 			THEN width_group='Unit';
RUN;

PROC SORT DATA=work.Dim_specs  /*nodups*/Nodupkey;	BY Company Dimset Dim_item Dim_spec;			/*DV 202509; Quick fix - data issue: The ID value "_030010" occurs twice in the same BY group. */
PROC SORT DATA=work.Dim_specs1 /*nodups*/Nodupkey;	BY Company Dimset Dim_item Dim_spec;	RUN;

DATA work.dim_spec;
MERGE work.dim_specs work.dim_specs1;
BY Company Dimset Dim_item Dim_spec;
RUN;

PROC SORT DATA=work.Dim_spec  nodups;	BY Company Dimset Dim_item Dim_spec;	RUN;

DATA work.dim_spec;
SET work.dim_spec;
BY Company Dimset Dim_item Dim_spec;
if first.dim_spec AND not Last.dim_spec THEN DELETE;
if dimset='' 							THEN DELETE;
RUN;

PROC SORT DATA=work.Dim_spec nodups;	BY Company Dimset Dim_item ;	RUN;

PROC TRANSPOSE DATA= work.dim_spec OUT=work.dim_spec1 (drop=_name_ _label_) ;
BY Company Dimset Dim_item ;
   VAR Value;
    ID dim_spec ;
RUN;

DATA work.dim_spec2 (KEEP=Company dimset dim_item spec_grav width thickness plate_length hardness alloy Pretreat_fs Pretreat_rs Pretreat_wpl
						  Primer topcoat1 topcoat2 topcoat3 backcoat backcoat1 backcoat2 backcoat3 Foil_SPL Foil_EL Foil_width Foil_type kg_pcs m2_kg Paint_coverage 
						  wrapping Surf_treatment Surf_quality GRP_thickn Foil_Width_Staf Design_nr Embossing);
SET work.dim_spec1;
Spec_grav=input(substr(_000010,1,11),11.0);
Width=input(substr(_001000,1,11),11.1);
Thickness=input(substr(_001010,1,11),11.2);
Plate_length=input(substr(_001100,1,11),11.4);
Hardness=_001020;
Pretreat_fs=_010010;
Pretreat_rs=_010020;
Pretreat_wpl=_020010;
Primer=substr(_011010,1,10);	IF Primer="" 			THEN Primer="-         ";
Topcoat1=substr(_011020,1,10);	IF Topcoat1="" 			THEN Topcoat1="-         ";
Topcoat2=substr(_011030,1,10);	IF Topcoat2="" 			THEN Topcoat2="-         ";
Topcoat3=substr(_011040,1,10);	IF Topcoat3="" 			THEN Topcoat3="-         ";
Backcoat=substr(_012010,1,10);	IF Backcoat="" 			THEN Backcoat="-         ";
Backcoat1=substr(_012020,1,10);	IF Backcoat1="" 		THEN Backcoat1="-         ";
Backcoat2=substr(_012030,1,10);	IF Backcoat2="" 		THEN Backcoat2="-         ";
Backcoat3=substr(_012040,1,10);	IF Backcoat3="" 		THEN Backcoat3="-         ";
Foil_SPL=substr(_060010,1,7);	IF Foil_SPL="" 			THEN FOIL_SPL="-";
Foil_EL=substr(_061010,1,7);	IF Foil_EL="" 			THEN FOIL_EL="-";
Foil_width=input(substr(_060040,1,11),12.0);
Foil_type=substr(_060070,1,11);	IF topcoat1="" 			THEN Topcoat1="-";
IF Foil_Width>0000 AND Foil_Width<1001 					THEN Foil_Width_Staf='0000-1000';
IF Foil_Width>1000 AND Foil_Width<1301 					THEN Foil_Width_Staf='1001-1300';
IF Foil_Width>1300 AND Foil_Width<1501 			 		THEN Foil_Width_Staf='1301-1500';
IF Foil_Width>1500 AND Foil_Width<3000 					THEN Foil_Width_Staf='1501-2700';
IF Foil_Width=.											THEN Foil_Width_Staf='         ';
Paint_coverage=input(substr(_080020,1,11),11.0);
Wrapping=_100090;
IF dim_item not in ('ALU','TOLALU') 					THEN Alloy=_001040; ELSE Alloy=_001030;
Surf_Treatment=_100200;			IF Surf_treatment="" 	THEN Surf_treatment="-";
Surf_Quality=_100210;			IF Surf_Quality="" 		THEN Surf_Quality="-";
Design_nr=_030010; 				IF Design_nr='' 		THEN Design_nr='-';
Embossing=_040010; 				IF Embossing='' 		THEN Embossing='-';
_050120=translate(_050120,".",",");
IF _050120 ne "" 										THEN GRP_thickn=input(substr(_050120,1,11),11.2); ELSE GRP_thickn=0;
RUN;

PROC SQL;
Create table work.dimset_groups AS 
Select 	a.Company,
		a.Dimset,
		a.dim_item,
		b.width_grp AS Width_staf,
		b.thick_grp AS Thick_staf
FROM 		work.dim_spec2 a,
			db2data.alu_pur_staffels b  
WHERE   a.company=b.company  AND a.thickness>=b.Thick_min AND a.thickness<=b.Thick_max AND
		a.Width>=b.Width_min AND a.Width<=b.Width_max     AND
		b.Suppl_nr='Aleris' ;
QUIT;

PROC SORT DATA=work.dim_spec2 		nodups;	BY Company Dimset dim_item;
PROC SORT DATA=work.Dimsets 		nodups;	BY Company Dimset dim_item;
PROC SORT DATA=work.Dimset_groups 	nodups;	BY Company Dimset dim_item;	RUN;

DATA work.dimsets;
MERGE work.dimsets work.dim_spec2 work.dimset_groups;
BY Company Dimset dim_item;
IF Fin_vw_code='' 										THEN DELETE;
IF dimset='' 											THEN DELETE;
IF Dim_inp_dims_nr eq '' 								THEN Dim_inp_dims_nr='-';
IF Dim_Cust_nr='' 										THEN Dim_Cust_nr="-     ";
IF Dim_Cust_end_nr='' 									THEN Dim_Cust_end_nr=Dim_Cust_nr;
IF Dim_Suppl_nr='' 										THEN Dim_Suppl_nr="-     ";
IF Dim_item='' 											THEN Dim_item="-               ";
FORMAT kg_pcs 8.4; FORMAT m2_kg 8.4;
kg_pcs=0;  m2_kg=0; 
IF Dim_type='Stnd.Plt.' AND Plate_length>0 				THEN kg_pcs=Spec_grav*Width*Plate_length*Thickness/1000/1000000;
IF Dim_type='Stnd.Plt.' AND Plate_length>0 			 	THEN m2_kg=(Width/1000*Plate_length)/kg_pcs; 						ELSE m2_kg=0;
IF Dim_type='Coil'      AND Width>0  AND Spec_grav>0 	THEN m2_kg=1/(Thickness/1000)/(Spec_grav/1000); 
IF GRP_thickn > 0 									 	THEN GRP_alu_fact=(Thickness*2.8)/(Thickness*2.8+GRP_thickn*1.375); ELSE GRP_alu_fact=1; 
GRP_alu_fact=ROUND(GRP_alu_fact,0.01);
IF Width_staf='' 										THEN Width_staf='-';
IF Thick_staf='' 										THEN Thick_staf='-';
RUN;

PROC SORT DATA=work.dimsets;	BY Company Foil_type;
PROC SORT DATA=work.Foil_g_m2;	BY Company Foil_type;	RUN;

DATA work.dimsets;
MERGE work.dimsets work.Foil_g_m2;
BY Company Foil_type;
RUN;

PROC SORT DATA=work.dimsets;	BY Company Dimset;	WHERE dimset ne "";	RUN;

PROC SQL;
CREATE TABLE work.dimsets AS SELECT a.*, b.Paint_syst AS Topc1_paint_sys, b.Paint_Type AS Topc1_paint_type 
FROM work.dimsets a LEFT OUTER JOIN work.lakdim b ON a.company=b.company AND  a.Topcoat1=b.dimset;
QUIT;

PROC SQL;
CREATE TABLE work.dimsets AS SELECT a.*, b.Paint_syst AS Topc2_paint_sys, b.Paint_Type AS Topc2_paint_type 
FROM work.dimsets a LEFT OUTER JOIN work.lakdim b ON a.company=b.company AND a.Topcoat2=b.dimset;
QUIT;

PROC SQL;
CREATE TABLE work.dimsets AS SELECT a.*, b.Paint_syst AS Topc3_paint_sys, b.Paint_Type AS Topc3_paint_type 
FROM work.dimsets a LEFT OUTER JOIN work.lakdim b ON a.company=b.company AND a.Topcoat3=b.dimset;
QUIT;

DATA work.dimsets;
SET work.dimsets;
IF dimset="" 			THEN DELETE; 
IF Substrate="Sta" 		THEN Substrate="Ste";
New_prod="                                              "; New_prod_start_date=MDY(01,01,1900);  New_prod_end_date=MDY(01,01,1900);
Appl_Brand="                                              "; 
Plan_trace_group="                                              ";
FORMAT Paint_FS_layers $4.; Paint_FS_layers='1234';
IF Primer NE '-' 		THEN Paint_FS_layers=TRANSLATE(Paint_FS_layers,'P','1'); ELSE Paint_FS_layers=TRANSLATE(Paint_FS_layers,'-','1');
IF Topcoat1 NE '-' 		THEN Paint_FS_layers=TRANSLATE(Paint_FS_layers,'T','2'); ELSE Paint_FS_layers=TRANSLATE(Paint_FS_layers,'-','2');
IF Topcoat2 NE '-' 		THEN Paint_FS_layers=TRANSLATE(Paint_FS_layers,'T','3'); ELSE Paint_FS_layers=TRANSLATE(Paint_FS_layers,'-','3');
IF Topcoat3 NE '-' 		THEN Paint_FS_layers=TRANSLATE(Paint_FS_layers,'T','4'); ELSE Paint_FS_layers=TRANSLATE(Paint_FS_layers,'-','4');  
FORMAT Paint_RS_layers $4.; Paint_RS_layers='1234';
IF Backcoat NE '-' 		THEN Paint_RS_layers=TRANSLATE(Paint_RS_layers,'P','1'); ELSE Paint_RS_layers=TRANSLATE(Paint_RS_layers,'-','1');
IF Backcoat1 NE '-' 	THEN Paint_RS_layers=TRANSLATE(Paint_RS_layers,'T','2'); ELSE Paint_RS_layers=TRANSLATE(Paint_RS_layers,'-','2');
IF Backcoat2 NE '-' 	THEN Paint_RS_layers=TRANSLATE(Paint_RS_layers,'T','3'); ELSE Paint_RS_layers=TRANSLATE(Paint_RS_layers,'-','3');
IF Backcoat3 NE '-' 	THEN Paint_RS_layers=TRANSLATE(Paint_RS_layers,'T','4'); ELSE Paint_RS_layers=TRANSLATE(Paint_RS_layers,'-','4');
IF Surf_treatment="" 	THEN Surf_treatment="-";
IF Surf_Quality="" 		THEN Surf_Quality="-";
RUN;

PROC SQL;
CREATE TABLE work.surface AS
SELECT 	a.Company,
		a.Dimset,
		a.Dim_inp_dims_4,
		b.Surf_treatment,
		b.Surf_Quality
FROM  work.dimsets a LEFT OUTER JOIN work.dimsets b ON a.Company=b.Company AND a.Dim_inp_dims_4=b.dimset 
WHERE a.Dim_inp_dims_4 ne "-" AND (b.Surf_treatment ne "-" OR b.Surf_Quality ne "-");
QUIT;

PROC SORT DATA=work.dimsets;	BY Company dimset; RUN;
PROC SORT DATA=work.surface;	BY Company dimset; RUN;

DATA work.dimsets;
MERGE work.dimsets work.surface;
BY Company dimset;
FORMAT Finish_Code_FS $20.;
Finish_Code_FS="-"; 
FORMAT Finish_Code_RS $20.;
Finish_Code_RS="-"; 
FORMAT Finish_Prod_code $20.;
Finish_Prod_Code="-"; 
Sales_concept_group="-                   ";
FORMAT Prodbrand $50.;
Prodbrand="-"; 
FORMAT ProdProdBrand $50.;
ProdProdBrand="-"; 
RUN;

PROC IMPORT OUT= WORK.Dimsets_MTS
 			DATAFILE= "\\euramax.rmd\departments\Procurement\SIOP\SAS_Upload\Dimsets_Assigments.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="MTS$A1:C1000"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= WORK.Dimsets_FTO
 			DATAFILE= "\\euramax.rmd\departments\Procurement\SIOP\SAS_Upload\Dimsets_Assigments.xlsx" 
            DBMS=XLSX REPLACE;
     RANGE="FTO$A1:C1000"; 
     GETNAMES=YES;
RUN;
PROC SORT DATA=work.dimsets_MTS nodups; BY Company dimset; RUN;
PROC SORT DATA=work.dimsets_FTO nodups; BY Company dimset; RUN;

PROC SQL;
CREATE TABLE work.dimsets AS
SELECT a.*, b.MTS
FROM work.dimsets a LEFT OUTER JOIN work.Dimsets_MTS b ON a.Company=b.Company AND a.Dimset=b.Dimset;
QUIT;  
PROC SQL;
CREATE TABLE work.dimsets AS
SELECT a.*, b.FTO
FROM work.dimsets a LEFT OUTER JOIN work.Dimsets_FTO b ON a.Company=b.Company AND a.Dimset=b.Dimset;
QUIT; 

DATA work.dimsets; SET work.dimsets;
IF finish_prod_code="" 	THEN finish_prod_code="-";
IF FOIL_SPL="" 			THEN FOIL_SPL="-";
IF FOIL_EL="" 			THEN FOIL_EL="-";
RUN;

PROC SORT DATA=work.dimsets nodupkey; BY company dimset; RUN;

/* Add Detail size factor */
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Pux027 as select * from connection to baan
   (SELECT  'Roe' 			AS Company,
			a.t_suno	 	AS Suppl_Nr,
   			a.t_item		AS Item,
			a.t_allo		AS Alloy,
			a.t_detf		AS Bare_Weight_Width_Factor,
			a.t_detd		AS Detail_size_Devision_Factor
FROM ttdpux027120 a);
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Pux027_Cor as select * from connection to baan
   (SELECT  'Cor' 			AS Company,
			a.t_suno	 	AS Suppl_Nr,
   			a.t_item		AS Item,
			a.t_allo		AS Alloy,
			a.t_detf		AS Bare_Weight_Width_Factor,
			a.t_detd		AS Detail_size_Devision_Factor
FROM ttdpux027200 a);
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Pux027_ECP as select * from connection to baan
   (SELECT  'ECP' 			AS Company,
			a.t_suno	 	AS Suppl_Nr,
   			a.t_item		AS Item,
			a.t_allo		AS Alloy,
			a.t_detf		AS Bare_Weight_Width_Factor,
			a.t_detd		AS Detail_size_Devision_Factor
FROM ttdpux027130 a);
QUIT;

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE (set lock mode to wait) by baan;
CREATE table work.Pux027_EAP as select * from connection to baan
   (SELECT  'EAP' 			AS Company,
			a.t_suno	 	AS Suppl_Nr,
   			a.t_item		AS Item,
			a.t_allo		AS Alloy,
			a.t_detf		AS Bare_Weight_Width_Factor,
			a.t_detd		AS Detail_size_Devision_Factor
FROM ttdpux027300 a);
QUIT;

PROC APPEND BASE=work.Pux027 DATA=work.Pux027_COR FORCE; RUN;
PROC APPEND BASE=work.Pux027 DATA=work.Pux027_ECP FORCE; RUN;
PROC APPEND BASE=work.Pux027 DATA=work.Pux027_EAP FORCE; RUN;

PROC SQL;
CREATE TABLE work.dimsets1 AS
SELECT  a.*,
		b.Bare_Weight_Width_Factor
FROM work.dimsets a LEFT OUTER JOIN work.pux027 b ON a.Dim_suppl_nr=b.suppl_nr AND a.company=b.company AND a.Dim_item=b.Item AND a.Alloy=b.Alloy;
QUIT;

DATA work.dimsets1; SET work.dimsets1;
IF Bare_Weight_Width_Factor=. THEN Bare_Weight_Width_Factor=0;

FORMAT Dim_Cust_Nr_End_Company $3.;
IF Dim_cust_nr='013320' 							THEN Dim_Cust_Nr_End_Company='Cor'; 
IF Dim_cust_nr='013330' 							THEN Dim_Cust_Nr_End_Company='EAP'; 
IF Dim_cust_nr='013331' 							THEN Dim_Cust_Nr_End_Company='ECP'; 
IF Dim_Cust_Nr_End_Company='' 						THEN Dim_Cust_Nr_End_Company='-';
/* Corby ? */
IF Company='Cor' AND Dim_Cust_Nr_End_Company='-' 	THEN Dim_Cust_Nr_End_Company='Cor';
RUN;

PROC SQL;
CREATE TABLE work.dimsets2 AS
SELECT  a.*,
		b.Dim_Cust_End_nr AS Dim_Cust_End_nr_CHECK
FROM work.dimsets1 a
LEFT OUTER JOIN work.dimsets1 b ON a.Company='EAP' AND a.Dim_Cust_End_Nr='013320' AND b.Company='ECP' AND a.DIM_CUST_PARTNR=b.dimset;
QUIT;

DATA work.dimsets2 (DROP= Dim_Cust_End_nr_CHECK); SET work.dimsets2;
IF Company='EAP' AND Dim_Cust_End_Nr='013320' THEN Dim_Cust_End_nr=Dim_Cust_End_nr_CHECK;
RUN;


PROC SORT DATA=work.dimsets2 nodupkey; BY Company dimset; RUN;


PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE (Truncate db2admin.dimsets ignore delete triggers drop storage immediate ) by Baan;  /*
EXECUTE (Drop table dimsets) by baan;
EXECUTE (Create table DB2ADMIN.dimsets (Company						Char(3) not null,
										Dimset 						Char(11) not null,
										Dim_descr 					Char(50) not null,
										Dim_descr2 					Char(50) not null,
										Dim_note					Char(90),
										Fin_vw_code					Char(11) not null,
										Fin_vw_descr				Char(40) not null,
										Fin_vw_group_descr			Char(40) not null,
										Led_acc_nr					Char(12) not null,
										Led_acc_desc  		   		Char(40) not null,
										Led_acc_grp_desc			Char(40) not null,
										Dim_proc_flow				Char(11) not null,
										Dim_item					Char(16) not null,
										Dim_cust_partnr				Char(40) not null,
										Dim_cust_nr					Char(6) not null,
										Dim_cust_end_nr				Char(6) not null,
										Dim_Cust_Nr_End_Company		Char(3) not null,
										Dim_suppl_nr				Char(6) not null,
										Dim_inp_dims_nr				Char(11) not null,
										Dim_inp_dims_4				Char(11) not null,
										Dim_stat					Char(7) not null,
										Dim_type					Char(9) not null,
										Dim_creation_date			Date not null,
										Dim_min_ord_Quan			Integer,
										Dim_safety_stock			Integer,
										Default_Det_size			Integer,
										Substrate					Char(3) not null,
										Width_group					Char(5) not null,
										Toll_fullpr					Char(5) not null,
										Coil_plate					Char(4) not null,
										Prod_group					Char(5) not null,
										txt_nr						Integer not null,
										Spec_grav					Dec(11,0),
										Width						Dec(11,1),
										Width_staf					Char(9),
										Thickness					Dec(11,2),
										Thick_staf					Char(9),
										Plate_length				Dec(11,4),
										kg_pcs						Dec(17,4),
										m2_kg						Dec(8,4),
										Alloy						Char(11),
										Bare_Weight_Width_Factor	Dec(7,2),
										Hardness					Char(11),
										Pretreat_fs					Char(11),
										Pretreat_rs					Char(11),
										Pretreat_wpl				Char(11),
										Primer						Char(11),
										Topcoat1					Char(11),
										Topc1_paint_sys				Char(12),
										Topc1_paint_type			Char(15),
										Topcoat2					Char(11),
										Topc2_paint_sys				Char(12),
										Topc2_paint_type			Char(15),
										Topcoat3					Char(11),
										Topc3_paint_sys				Char(12),
										Topc3_paint_type			Char(15),
										Backcoat					Char(11),
										Backcoat1					Char(11),
										Backcoat2					Char(11),
										Backcoat3					Char(11),
										Foil_SPL					Char(11),
										Foil_EL						Char(11),
										Foil_width					Integer,
										Foil_type					Char(11),
										Foil_Thickn					Integer,
										Foil_g_m2					Dec(6,2),
										Foil_Width_Staf				Char(9),
										Paint_descr					Char(60),
										Paint_type					Char(15),
										Paint_syst					Char(12),
										Paint_dep					Char(3),
										Paint_ral					Char(7),
										Paint_stat					Char(15),
										Paint_suppl					Char(6),
										Paint_coverage				Integer,
										Paint_coverage_suppl		Integer,
										Wrapping					Char(11),
										Markt_Market				Char(3),
										Markt_Market_descs			Char(15),
										Markt_Market_descl			Char(40),
										Markt_Prod_group			Char(3),
										Markt_Prod_group_desc		Char(60),
										Markt_brand					Char(4),
										Markt_brand_name			Char(60),
										Appl_Brand					Char(60),
										New_Prod					Char(60),
										New_prod_start_date			Date,
										New_prod_end_date			Date, 
										Paint_FS_layers				Char(4),
										Paint_RS_layers				Char(4),
										Surf_treatment				Char(11),
										Surf_Quality				Char(11),
										GRP_thickn					Dec(5,2),
										GRP_alu_fact				Dec(5,2),
										Plan_trace_group			Char(60),
										Finish_Code_FS				Char(20), 
										Finish_Code_RS				Char(20), 
										Finish_Prod_Code			Char(20),
										Sales_concept_group			Char(20),
										MTS							Char(3), 
										FTO							Char(3),
										Design_Nr					Char(11),
										Embossing					Char(11),
										ProdBrand					Char(60),
										ProdProdBrand				Char(60),
										Dim_Purchase				Char(3),
										Dim_Sales					Char(3),
										Dim_Base_dimset				Char(12),
										Dim_SHT_Comp_price			Dec(8,4),
										Dim_SHT_Price				Dec(8,4),
										Dim_SHT_Curr				Char(3),
										Dim_SHT_Adj_Perc			Dec(8,4),
										Dim_SHT_Adj_amounth			Dec(8,4)     )) by baan;
EXECUTE ( ALTER TABLE DB2ADMIN.DIMSETS ADD CONSTRAINT DIMSET PRIMARY KEY ( Company, DIMSET) ) by Baan;	*/
EXECUTE ( INSERT INTO DB2ADMIN.DIMSETS (Company, Dimset, Dim_descr, Dim_descr2, Dim_note, Fin_vw_code, Fin_vw_descr, Fin_vw_group_descr, 
			Led_acc_nr, Led_acc_desc, Led_acc_grp_desc, Dim_proc_flow, Dim_item, Dim_cust_partnr, Dim_cust_nr, Dim_cust_end_nr, Dim_Cust_Nr_End_Company, Dim_suppl_nr,
			Dim_inp_dims_nr, Dim_inp_dims_4, Dim_stat, Dim_type, Dim_creation_date, Dim_safety_stock, Substrate, Width_group, Toll_fullpr, Coil_plate, Prod_group, txt_nr,
			Spec_grav, Width, Width_staf, Thickness, Thick_staf, Plate_length,kg_pcs, m2_kg, Alloy, Hardness, Pretreat_fs, Pretreat_rs, Pretreat_wpl,
			Primer, Topcoat1, Topc1_paint_sys, Topc1_paint_type, Topcoat2,  Topc2_paint_sys, Topc2_paint_type, Topcoat3,  Topc3_paint_sys, Topc3_paint_type, 
			Backcoat, Backcoat1, Backcoat2, Backcoat3, Foil_SPL, Foil_EL, Foil_width, Foil_type, Foil_Thickn, Foil_g_m2, Foil_Width_Staf,
			Paint_descr, Paint_type, Paint_syst, Paint_dep, Paint_ral, Paint_stat, Paint_suppl, Paint_coverage_suppl, Paint_coverage, Wrapping,
			Markt_Market, Markt_Market_descs, Markt_Market_descl, Markt_Prod_group, Markt_Prod_group_desc,
			Markt_brand, Markt_brand_name, Appl_Brand, New_Prod, New_prod_start_date, New_prod_end_date, Paint_FS_layers, Paint_RS_layers, 
			Surf_treatment, Surf_Quality, GRP_thickn, GRP_alu_fact, Plan_trace_group, Finish_code_FS, Finish_code_RS, Finish_Prod_Code, Sales_concept_group, MTS, FTO, Dim_min_ord_quan, Design_Nr, Embossing, 
			Prodbrand, ProdProdBrand, Dim_Purchase, Dim_Sales, Dim_Base_dimset, Dim_SHT_Comp_price, Dim_SHT_Price, Dim_SHT_Curr, Dim_SHT_Adj_Perc, Dim_SHT_Adj_amounth   )
			VALUES  ('Roe','-','No Dimset','No Dimset','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-',DATE('1900-01-01'),0,'-','-','-','-','-',0,
					 0,0,'-',0,'-',0,0,0,'-','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-','-',0,'-',0,0,'',
					 '-','-','-','-','-','-','-',0,0,'-',
					 '-','-','-','-','-','-','-','-','-',DATE('1900-01-01'),DATE('1900-01-01'),'-','-','-','-',0,1,'-','-','-','-','-','-','-',0,'-','-','-','-','-','-','-',0,0,'-',0,0)) by Baan;
EXECUTE ( INSERT INTO DB2ADMIN.DIMSETS (Company, Dimset, Dim_descr, Dim_descr2, Dim_note, Fin_vw_code, Fin_vw_descr, Fin_vw_group_descr, 
			Led_acc_nr, Led_acc_desc, Led_acc_grp_desc, Dim_proc_flow, Dim_item, Dim_cust_partnr, Dim_cust_nr, Dim_cust_end_nr, Dim_Cust_Nr_End_Company, Dim_suppl_nr,
			Dim_inp_dims_nr, Dim_inp_dims_4, Dim_stat, Dim_type, Dim_creation_date, Dim_safety_stock, Substrate, Width_group, Toll_fullpr, Coil_plate, Prod_group, txt_nr,
			Spec_grav, Width, Width_staf, Thickness, Thick_staf, Plate_length,kg_pcs, m2_kg, Alloy, Hardness, Pretreat_fs, Pretreat_rs, Pretreat_wpl,
			Primer, Topcoat1, Topc1_paint_sys, Topc1_paint_type, Topcoat2,  Topc2_paint_sys, Topc2_paint_type, Topcoat3,  Topc3_paint_sys, Topc3_paint_type, 
			Backcoat, Backcoat1, Backcoat2, Backcoat3, Foil_SPL, Foil_EL, Foil_width, Foil_type, Foil_Thickn, Foil_g_m2, Foil_Width_Staf,
			Paint_descr, Paint_type, Paint_syst, Paint_dep, Paint_ral, Paint_stat, Paint_suppl, Paint_coverage_suppl, Paint_coverage, Wrapping,
			Markt_Market, Markt_Market_descs, Markt_Market_descl, Markt_Prod_group, Markt_Prod_group_desc,
			Markt_brand, Markt_brand_name, Appl_Brand, New_Prod, New_prod_start_date, New_prod_end_date, Paint_FS_layers, Paint_RS_layers, 
			Surf_treatment, Surf_Quality, GRP_thickn, GRP_alu_fact, Plan_trace_group, Finish_code_FS, Finish_code_RS, Finish_Prod_Code, Sales_concept_group, MTS, FTO, Dim_min_ord_quan, Design_Nr, Embossing, 
			Prodbrand, ProdProdBrand, Dim_Purchase, Dim_Sales, Dim_Base_dimset, Dim_SHT_Comp_price, Dim_SHT_Price, Dim_SHT_Curr, Dim_SHT_Adj_Perc, Dim_SHT_Adj_amounth   )
			VALUES  ('Cor','-','No Dimset','No Dimset','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-',DATE('1900-01-01'),0,'-','-','-','-','-',0,
					 0,0,'-',0,'-',0,0,0,'-','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-','-',0,'-',0,0,'',
					 '-','-','-','-','-','-','-',0,0,'-',
					 '-','-','-','-','-','-','-','-','-',DATE('1900-01-01'),DATE('1900-01-01'),'-','-','-','-',0,1,'-','-','-','-','-','-','-',0,'-','-','-','-','-','-','-',0,0,'-',0,0)) by Baan;
EXECUTE ( INSERT INTO DB2ADMIN.DIMSETS (Company, Dimset, Dim_descr, Dim_descr2, Dim_note, Fin_vw_code, Fin_vw_descr, Fin_vw_group_descr, 
			Led_acc_nr, Led_acc_desc, Led_acc_grp_desc, Dim_proc_flow, Dim_item, Dim_cust_partnr, Dim_cust_nr, Dim_cust_end_nr, Dim_Cust_Nr_End_Company, Dim_suppl_nr,
			Dim_inp_dims_nr, Dim_inp_dims_4, Dim_stat, Dim_type, Dim_creation_date, Dim_safety_stock, Substrate, Width_group, Toll_fullpr, Coil_plate, Prod_group, txt_nr,
			Spec_grav, Width, Width_staf, Thickness, Thick_staf, Plate_length,kg_pcs, m2_kg, Alloy, Hardness, Pretreat_fs, Pretreat_rs, Pretreat_wpl,
			Primer, Topcoat1, Topc1_paint_sys, Topc1_paint_type, Topcoat2,  Topc2_paint_sys, Topc2_paint_type, Topcoat3,  Topc3_paint_sys, Topc3_paint_type, 
			Backcoat, Backcoat1, Backcoat2, Backcoat3, Foil_SPL, Foil_EL, Foil_width, Foil_type, Foil_Thickn, Foil_g_m2, Foil_Width_Staf,
			Paint_descr, Paint_type, Paint_syst, Paint_dep, Paint_ral, Paint_stat, Paint_suppl, Paint_coverage_suppl, Paint_coverage, Wrapping,
			Markt_Market, Markt_Market_descs, Markt_Market_descl, Markt_Prod_group, Markt_Prod_group_desc,
			Markt_brand, Markt_brand_name, Appl_Brand, New_Prod, New_prod_start_date, New_prod_end_date, Paint_FS_layers, Paint_RS_layers, 
			Surf_treatment, Surf_Quality, GRP_thickn, GRP_alu_fact, Plan_trace_group, Finish_code_FS, Finish_code_RS, Finish_Prod_Code, Sales_concept_group, MTS, FTO, Dim_min_ord_quan, Design_Nr, Embossing,
			Prodbrand, ProdProdBrand, Dim_Purchase, Dim_Sales, Dim_Base_dimset, Dim_SHT_Comp_price, Dim_SHT_Price, Dim_SHT_Curr, Dim_SHT_Adj_Perc, Dim_SHT_Adj_amounth   )
			VALUES  ('ECP','-','No Dimset','No Dimset','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-',DATE('1900-01-01'),0,'-','-','-','-','-',0,
					 0,0,'-',0,'-',0,0,0,'-','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-','-',0,'-',0,0,'',
					 '-','-','-','-','-','-','-',0,0,'-',
					 '-','-','-','-','-','-','-','-','-',DATE('1900-01-01'),DATE('1900-01-01'),'-','-','-','-',0,1,'-','-','-','-','-','-','-',0,'-','-','-','-','-','-','-',0,0,'-',0,0)) by Baan;
EXECUTE ( INSERT INTO DB2ADMIN.DIMSETS (Company, Dimset, Dim_descr, Dim_descr2, Dim_note, Fin_vw_code, Fin_vw_descr, Fin_vw_group_descr, 
			Led_acc_nr, Led_acc_desc, Led_acc_grp_desc, Dim_proc_flow, Dim_item, Dim_cust_partnr, Dim_cust_nr, Dim_cust_end_nr, Dim_Cust_Nr_End_Company, Dim_suppl_nr,
			Dim_inp_dims_nr, Dim_inp_dims_4, Dim_stat, Dim_type, Dim_creation_date, Dim_safety_stock, Substrate, Width_group, Toll_fullpr, Coil_plate, Prod_group, txt_nr,
			Spec_grav, Width, Width_staf, Thickness, Thick_staf, Plate_length,kg_pcs, m2_kg, Alloy, Hardness, Pretreat_fs, Pretreat_rs, Pretreat_wpl,
			Primer, Topcoat1, Topc1_paint_sys, Topc1_paint_type, Topcoat2,  Topc2_paint_sys, Topc2_paint_type, Topcoat3,  Topc3_paint_sys, Topc3_paint_type, 
			Backcoat, Backcoat1, Backcoat2, Backcoat3, Foil_SPL, Foil_EL, Foil_width, Foil_type, Foil_Thickn, Foil_g_m2, Foil_Width_Staf,
			Paint_descr, Paint_type, Paint_syst, Paint_dep, Paint_ral, Paint_stat, Paint_suppl, Paint_coverage_suppl, Paint_coverage, Wrapping,
			Markt_Market, Markt_Market_descs, Markt_Market_descl, Markt_Prod_group, Markt_Prod_group_desc,
			Markt_brand, Markt_brand_name, Appl_Brand, New_Prod, New_prod_start_date, New_prod_end_date, Paint_FS_layers, Paint_RS_layers, 
			Surf_treatment, Surf_Quality, GRP_thickn, GRP_alu_fact, Plan_trace_group, Finish_code_FS, Finish_code_RS, Finish_Prod_Code, Sales_concept_group, MTS, FTO, Dim_min_ord_quan, Design_Nr, Embossing, 
			Prodbrand, ProdProdBrand, Dim_Purchase, Dim_Sales, Dim_Base_dimset, Dim_SHT_Comp_price, Dim_SHT_Price, Dim_SHT_Curr, Dim_SHT_Adj_Perc, Dim_SHT_Adj_amounth   )
			VALUES  ('EAP','-','No Dimset','No Dimset','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-',DATE('1900-01-01'),0,'-','-','-','-','-',0,
					 0,0,'-',0,'-',0,0,0,'-','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-','-',0,'-',0,0,'',
					 '-','-','-','-','-','-','-',0,0,'-',
					 '-','-','-','-','-','-','-','-','-',DATE('1900-01-01'),DATE('1900-01-01'),'-','-','-','-',0,1,'-','-','-','-','-','-','-',0,'-','-','-','-','-','-','-',0,0,'-',0,0)) by Baan;
EXECUTE ( INSERT INTO DB2ADMIN.DIMSETS (Company, Dimset, Dim_descr, Dim_descr2, Dim_note, Fin_vw_code, Fin_vw_descr, Fin_vw_group_descr, 
			Led_acc_nr, Led_acc_desc, Led_acc_grp_desc, Dim_proc_flow, Dim_item, Dim_cust_partnr, Dim_cust_nr, Dim_cust_end_nr, Dim_Cust_Nr_End_Company, Dim_suppl_nr,
			Dim_inp_dims_nr, Dim_inp_dims_4, Dim_stat, Dim_type, Dim_creation_date, Dim_safety_stock, Substrate, Width_group, Toll_fullpr, Coil_plate, Prod_group, txt_nr,
			Spec_grav, Width, Width_staf, Thickness, Thick_staf, Plate_length,kg_pcs, m2_kg, Alloy, Hardness, Pretreat_fs, Pretreat_rs, Pretreat_wpl,
			Primer, Topcoat1, Topc1_paint_sys, Topc1_paint_type, Topcoat2,  Topc2_paint_sys, Topc2_paint_type, Topcoat3,  Topc3_paint_sys, Topc3_paint_type, 
			Backcoat, Backcoat1, Backcoat2, Backcoat3, Foil_SPL, Foil_EL, Foil_width, Foil_type, Foil_Thickn, Foil_g_m2, Foil_Width_Staf,
			Paint_descr, Paint_type, Paint_syst, Paint_dep, Paint_ral, Paint_stat, Paint_suppl, Paint_coverage_suppl, Paint_coverage, Wrapping,
			Markt_Market, Markt_Market_descs, Markt_Market_descl, Markt_Prod_group, Markt_Prod_group_desc,
			Markt_brand, Markt_brand_name, Appl_Brand, New_Prod, New_prod_start_date, New_prod_end_date, Paint_FS_layers, Paint_RS_layers, 
			Surf_treatment, Surf_Quality, GRP_thickn, GRP_alu_fact, Plan_trace_group, Finish_code_FS, Finish_code_RS, Finish_Prod_Code, Sales_concept_group, MTS, FTO, Dim_min_ord_quan, Design_Nr, Embossing, 
			Prodbrand, ProdProdBrand, Dim_Purchase, Dim_Sales, Dim_Base_dimset, Dim_SHT_Comp_price, Dim_SHT_Price, Dim_SHT_Curr, Dim_SHT_Adj_Perc, Dim_SHT_Adj_amounth   )
			VALUES  ('-','-','No Dimset','No Dimset','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-',DATE('1900-01-01'),0,'-','-','-','-','-',0,
					 0,0,'-',0,'-',0,0,0,'-','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-','-',0,'-',0,0,'',
					 '-','-','-','-','-','-','-',0,0,'-',
					 '-','-','-','-','-','-','-','-','-',DATE('1900-01-01'),DATE('1900-01-01'),'-','-','-','-',0,1,'-','-','-','-','-','-','-',0,'-','-','-','-','-','-','-',0,0,'-',0,0)) by Baan;
EXECUTE ( INSERT INTO DB2ADMIN.DIMSETS (Company, Dimset, Dim_descr, Dim_descr2, Dim_note, Fin_vw_code, Fin_vw_descr, Fin_vw_group_descr, 
			Led_acc_nr, Led_acc_desc, Led_acc_grp_desc, Dim_proc_flow, Dim_item, Dim_cust_partnr, Dim_cust_nr, Dim_cust_end_nr, Dim_Cust_Nr_End_Company, Dim_suppl_nr,
			Dim_inp_dims_nr, Dim_inp_dims_4, Dim_stat, Dim_type, Dim_creation_date, Dim_safety_stock, Substrate, Width_group, Toll_fullpr, Coil_plate, Prod_group, txt_nr,
			Spec_grav, Width, Width_staf, Thickness, Thick_staf, Plate_length,kg_pcs, m2_kg, Alloy, Hardness, Pretreat_fs, Pretreat_rs, Pretreat_wpl,
			Primer, Topcoat1, Topc1_paint_sys, Topc1_paint_type, Topcoat2,  Topc2_paint_sys, Topc2_paint_type, Topcoat3,  Topc3_paint_sys, Topc3_paint_type, 
			Backcoat, Backcoat1, Backcoat2, Backcoat3, Foil_SPL, Foil_EL, Foil_width, Foil_type, Foil_Thickn, Foil_g_m2, Foil_Width_Staf,
			Paint_descr, Paint_type, Paint_syst, Paint_dep, Paint_ral, Paint_stat, Paint_suppl, Paint_coverage_suppl, Paint_coverage, Wrapping,
			Markt_Market, Markt_Market_descs, Markt_Market_descl, Markt_Prod_group, Markt_Prod_group_desc,
			Markt_brand, Markt_brand_name, Appl_Brand, New_Prod, New_prod_start_date, New_prod_end_date, Paint_FS_layers, Paint_RS_layers, 
			Surf_treatment, Surf_Quality, GRP_thickn, GRP_alu_fact, Plan_trace_group, Finish_code_FS, Finish_code_RS, Finish_Prod_Code, Sales_concept_group, MTS, FTO, Dim_min_ord_quan, Design_Nr, Embossing, 
			Prodbrand, ProdProdBrand, Dim_Purchase, Dim_Sales, Dim_Base_dimset, Dim_SHT_Comp_price, Dim_SHT_Price, Dim_SHT_Curr, Dim_SHT_Adj_Perc, Dim_SHT_Adj_amounth   )
			VALUES  ('KSI','-','No Dimset','No Dimset','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-',DATE('1900-01-01'),0,'-','-','-','-','-',0,
					 0,0,'-',0,'-',0,0,0,'-','-','-','-','-',
					 '-','-','-','-','-','-','-','-','-','-',
					 '-','-','-','-','-','-',0,'-',0,0,'',
					 '-','-','-','-','-','-','-',0,0,'-',
					 '-','-','-','-','-','-','-','-','-',DATE('1900-01-01'),DATE('1900-01-01'),'-','-','-','-',0,1,'-','-','-','-','-','-','-',0,'-','-','-','-','-','-','-',0,0,'-',0,0)) by Baan;

EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.DIMSETS TO USER INFODBC ) 	by baan;
EXECUTE ( GRANT  SELECT ON TABLE DB2ADMIN.DIMSETS TO USER FINODBC )  	by baan;
EXECUTE ( COMMENT ON TABLE DB2ADMIN.DIMSETS IS 'Base Files' )  			by baan;  
QUIT;

PROC APPEND BASE=db2data.dimsets (BULKLOAD=YES) DATA=work.dimsets2 FORCE; RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2ADMIN.dimsets ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;
