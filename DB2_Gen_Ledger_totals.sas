/********************************************************************************/
/**** Please also update script at e:\sas\data\sas_script                    ****/

OPTION NOSYNTAXCHECK;

libname db2data  odbc dsn='db2ecp' schema=DB2ADMIN user=db2admin password=aachen;
libname db2fin   odbc dsn='db2ecp' schema=DB2FIN user=db2admin password=aachen;

/***************************************************************/
/******    Updating tfgld201/202/203/204 Roermond Data    ******/
/***************************************************************/

PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE ( SET LOCK MODE TO WAIT) by baan ;

 CREATE table work.gld201 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				b.t_desc    gro_oms
    FROM        ttfgld201120 a,
                ttfgld008120 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041')))                       );
 CREATE table work.gld203 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms
    FROM        ttfgld203120 a,
                ttfgld008120 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041')))                   );
 CREATE table work.gld202 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				a.t_fqt1	mut_gew,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld202120 a,
                ttfgld008120 b,
				ttfgld010120 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx  and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))                    );
 CREATE table work.gld204 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld204120 a,
                ttfgld008120 b,
				ttfgld010120 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))                          );
 CREATE table work.finper as select * from connection to baan
   (SELECT  a.t_year   fjaar,
            a.t_prno   fper,
            a.t_stdt   datum,
			b.t_leac   grootb,
			b.t_desc   gro_oms,
			b.t_subl   tel_niv
   FROM         ttfgld005120 a,
   				ttfgld008120 b
   WHERE    a.t_ptyp=1 	 );
 DISCONNECT from baan;
RUN;

DATA work.f_gro (keep=fin_jaar fin_per saldo grootb gro_oms tel_niv);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar>2012 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.f_dim (keep=fin_jaar fin_per saldo grootb gro_oms);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar=year(date())-1 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.gld203;
SET work.gld203;
fin_per=0;
RUN;

DATA work.gld204;
SET work.gld204;
fin_per=0;
RUN;

proc sort data=work.gld203;
by fin_jaar grootb fin_per eenheid;
proc sort data=work.gld201;
by fin_jaar grootb fin_per eenheid; 
run;

DATA work.samen1;
merge work.gld203 work.gld201;
by fin_jaar grootb fin_per eenheid;
run;

PROC SORT data=work.samen1;
BY fin_jaar grootb fin_per gro_oms;
RUN;

PROC MEANS data=work.samen1 NOPRINT;
VAR beg_sal deb_mut cre_mut;
BY fin_jaar grootb fin_per gro_oms;
OUTPUT OUT=work.samen1_1  SUM(beg_sal deb_mut cre_mut)=beg_sal deb_mut cre_mut;
RUN;

PROC SORT data=work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
PROC SORT data=work.f_gro;
BY fin_jaar grootb fin_per gro_oms;
RUN;

data work.samen1_2;
merge work.f_gro work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen1_2;
BY fin_jaar grootb fin_per;
RUN;

DATA work.gro_mut (drop=_type_ _freq_);
SET work.samen1_2;
BY fin_jaar grootb fin_per;
RETAIN saldo;
if first.grootb and fin_per=0 then saldo=beg_sal; 
if first.grootb and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.grootb then saldo=saldo+deb_mut-cre_mut;
dim_type=0;
dim_cod="-";
dim_oms="nvt";
if tel_niv=. then tel_niv=0;
RUN;


proc sort data=work.gld204;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
proc sort data=work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

DATA work.samen2;
merge work.gld204 work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

PROC SORT data=work.samen2;
BY fin_jaar grootb dim_type dim_cod fin_per gro_oms dim_oms;
RUN;

PROC MEANS data=work.samen2 NOPRINT;
VAR beg_sal deb_mut cre_mut mut_gew;
BY fin_jaar grootb dim_type dim_cod tel_niv fin_per gro_oms dim_oms;
OUTPUT OUT=work.samen2_1  SUM(beg_sal deb_mut cre_mut mut_gew)=beg_sal deb_mut cre_mut gew_mut;
RUN;

DATA work.samen2_w;
SET work.samen2_1;
RUN;

PROC SORT data=work.samen2_1 nodupkeys;
BY fin_jaar dim_type dim_cod tel_niv grootb gro_oms dim_oms;
RUN;

DATA work.samen2_2 (drop = _freq_ _type_ beg_sal cre_mut deb_mut fin_per gew_mut);
set work.samen2_1;
RUN;

PROC SORT data=work.samen2_2;
BY fin_jaar dim_type dim_cod grootb;
RUN;

proc sql;
create table work.samen2_3 as
 select * from work.samen2_2 a left join work.f_dim b on a.grootb=b.grootb;
 run;

PROC SORT data=work.samen2_3;
BY fin_jaar dim_type dim_cod grootb fin_per;
PROC SORT data=work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
RUN;

data work.samen2_4 (drop=_type_ _freq_);
merge work.samen2_3 work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RUN;

DATA work.dim_mut;
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
where dim_type=1;
RUN;

DATA work.dim_mutx (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Count_lev Counter);
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=+deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
WHERE grootb>'30000' and grootb<'31000' AND Fin_jaar>2012 AND fin_per NE .;
Company="Roe";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
IF Mut_weight=. THEN Mut_weight=0;
Count_lev=tel_niv;
Counter=_n_;
RUN;

data work.gro_tot;
set work.dim_mut;
run;

PROC Append base=work.gro_tot data=work.gro_mut force;
run;

PROC SORT data=work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RUN;

DATA work.gro_tot (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Cum_weight Count_lev Counter);
SET work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RETAIN gew_cum;
IF gew_mut=. then gew_mut=0;
IF first.fin_jaar then gew_cum=gew_mut;
IF not first.fin_jaar THEN gew_cum=gew_cum+gew_mut;
Company="Roe";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
Cum_weight=gew_cum;
Count_lev=tel_niv;
Counter=_n_;
WHERE Fin_jaar > 2012 AND fin_per NE .;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
/*
EXECUTE (Delete from DB2FIN.Gld_totals WHERE Fin_year>2012 AND Company='Roe' ) by baan;
EXECUTE (Delete from DB2FIN.Gld_totals WHERE Company='Cor' ) by baan;
*/

EXECUTE (Drop table DB2FIN.Gld_totals) by baan;
EXECUTE 
(Create table DB2FIN.Gld_totals ( 	Company				Char(3) not null,
										Fin_Year 			Integer not null,
										Fin_Per				Integer not null,
										Led_acc_nr			Char(12) not null,
										Dim_type			Integer not null,
										Dim_code			Char(6) not null,
										Start_value			Dec(16,4) not null,
										Deb_mut				Dec(16,4) not null,
										Cre_mut				Dec(16,4) not null,
										Balans				Dec(16,4) not null,
										Mut_weight			Dec(12,0) not null,
										Cum_weight			Dec(12,0) not null,
										Count_lev			Integer,
										Counter				Integer not null ) in DB2INFOSPACE
 ) by baan;
EXECUTE ( ALTER TABLE DB2FIN.Gld_totals ADD CONSTRAINT DATE PRIMARY KEY 
				( Company, Fin_year, Fin_per, Led_acc_nr, Dim_type, Dim_code, Counter) ) by Baan;
EXECUTE ( GRANT  SELECT ON TABLE DB2FIN.Gld_totals TO USER INFODBC )  by baan;
EXECUTE ( GRANT  SELECT ON TABLE DB2FIN.Gld_totals TO USER FINODBC )  by baan;
EXECUTE ( COMMENT ON TABLE DB2FIN.Gld_totals IS 'Matrix Files' )  by baan;
QUIT;  

PROC APPEND base=DB2FIN.Gld_totals data=work.gro_tot;
RUN;


PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
/*
EXECUTE (Delete from DB2FIN.Gld_Sales WHERE Fin_year>2012 AND Company='Roe' ) by baan;
EXECUTE (Delete from DB2FIN.Gld_Sales WHERE Company='Cor' ) by baan;
*/
EXECUTE (Drop table DB2FIN.Gld_Sales) by baan;
EXECUTE 
(Create table DB2FIN.Gld_Sales		 ( 	Company				Char(3) not null,
										Fin_Year 			Integer not null,
										Fin_Per				Integer not null,
										Led_acc_nr			Char(12) not null,
										Dim_type			Integer not null,
										Dim_code			Char(6) not null,
										Start_value			Dec(16,4) not null,
										Deb_mut				Dec(16,4) not null,
										Cre_mut				Dec(16,4) not null,
										Balans				Dec(16,4) not null,
										Mut_weight			Dec(12,0) not null,
										Count_lev			Integer,
										Counter				Integer not null ) in DB2INFOSPACE
 ) by baan;
EXECUTE ( ALTER TABLE DB2FIN.Gld_Sales ADD CONSTRAINT DATE PRIMARY KEY 
				( Company, Fin_year, Fin_per, Led_acc_nr, Dim_type, Dim_code, Counter) ) by Baan;
EXECUTE ( GRANT  SELECT ON TABLE DB2FIN.Gld_Sales TO USER INFODBC )  by baan;
EXECUTE ( GRANT  SELECT ON TABLE DB2FIN.Gld_Sales TO USER FINODBC )  by baan;
EXECUTE ( COMMENT ON TABLE DB2FIN.Gld_Sales IS 'Matrix Files' )  by baan;
QUIT;  

PROC APPEND base=DB2FIN.Gld_Sales data=work.dim_mutx;
RUN;



/***************************************************************/
/******    Updating tfgld201/202/203/204 Corby Data       ******/
/***************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE ( SET LOCK MODE TO WAIT) by baan ;
 CREATE table work.gld201 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				b.t_desc    gro_oms
    FROM        ttfgld201200 a,
                ttfgld008200 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041'))) 					  );
 CREATE table work.gld203 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms
    FROM        ttfgld203200 a,
                ttfgld008200 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld202 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				a.t_fqt1	mut_gew,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld202200 a,
                ttfgld008200 b,
				ttfgld010200 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx  and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld204 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld204200 a,
                ttfgld008200 b,
				ttfgld010200 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					   );
 CREATE table work.finper as select * from connection to baan
   (SELECT  a.t_year   fjaar,
            a.t_prno   fper,
            a.t_stdt   datum,
			b.t_leac   grootb,
			b.t_desc   gro_oms,
			b.t_subl   tel_niv

   FROM         ttfgld005200 a,
   				ttfgld008200 b
   WHERE    a.t_ptyp=1 				  );
 DISCONNECT from baan;
RUN;

DATA work.f_gro (keep=fin_jaar fin_per saldo grootb gro_oms tel_niv);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar>2006 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.f_dim (keep=fin_jaar fin_per saldo grootb gro_oms);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar=year(date())-1 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.gld203;
SET work.gld203;
fin_per=0;
RUN;

DATA work.gld204;
SET work.gld204;
fin_per=0;
RUN;

proc sort data=work.gld203;
by fin_jaar grootb fin_per eenheid;
proc sort data=work.gld201;
by fin_jaar grootb fin_per eenheid; 
run;

DATA work.samen1;
merge work.gld203 work.gld201;
by fin_jaar grootb fin_per eenheid;
run;

PROC SORT data=work.samen1;
BY fin_jaar grootb fin_per gro_oms;
RUN;

PROC MEANS data=work.samen1 NOPRINT;
VAR beg_sal deb_mut cre_mut;
BY fin_jaar grootb fin_per gro_oms;
OUTPUT OUT=work.samen1_1  SUM(beg_sal deb_mut cre_mut)=beg_sal deb_mut cre_mut;
RUN;

PROC SORT data=work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
PROC SORT data=work.f_gro;
BY fin_jaar grootb fin_per gro_oms;
RUN;

data work.samen1_2;
merge work.f_gro work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen1_2;
BY fin_jaar grootb fin_per;
RUN;

DATA work.gro_mut (drop=_type_ _freq_);
SET work.samen1_2;
BY fin_jaar grootb fin_per;
RETAIN saldo;
if first.grootb and fin_per=0 then saldo=beg_sal; 
if first.grootb and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.grootb then saldo=saldo+deb_mut-cre_mut;
dim_type=0;
dim_cod="-";
dim_oms="nvt";
if tel_niv=. then tel_niv=0;
RUN;

proc sort data=work.gld204;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
proc sort data=work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

DATA work.samen2;
merge work.gld204 work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

PROC SORT data=work.samen2;
BY fin_jaar grootb dim_type dim_cod fin_per gro_oms dim_oms;
RUN;

PROC MEANS data=work.samen2 NOPRINT;
VAR beg_sal deb_mut cre_mut mut_gew;
BY fin_jaar grootb dim_type dim_cod tel_niv fin_per gro_oms dim_oms;
OUTPUT OUT=work.samen2_1  SUM(beg_sal deb_mut cre_mut mut_gew)=beg_sal deb_mut cre_mut gew_mut;
RUN;

DATA work.samen2_w;
SET work.samen2_1;
RUN;

PROC SORT data=work.samen2_1 nodupkeys;
BY fin_jaar dim_type dim_cod tel_niv grootb gro_oms dim_oms;
RUN;

DATA work.samen2_2 (drop = _freq_ _type_ beg_sal cre_mut deb_mut fin_per gew_mut);
set work.samen2_1;
RUN;

PROC SORT data=work.samen2_2;
BY fin_jaar dim_type dim_cod grootb;
RUN;

proc sql;
create table work.samen2_3 as
 select * from work.samen2_2 a left join work.f_dim b on a.grootb=b.grootb;
 run;

PROC SORT data=work.samen2_3;
BY fin_jaar dim_type dim_cod grootb fin_per;
PROC SORT data=work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
RUN;

data work.samen2_4 (drop=_type_ _freq_);
merge work.samen2_3 work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RUN;

DATA work.dim_mut;
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
where dim_type=1;
RUN;


DATA work.dim_mutx (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Count_lev Counter);
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=+deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
WHERE grootb>'30000' and grootb<'31000';

Company="Cor";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
IF Mut_weight=. THEN Mut_weight=0;
Count_lev=tel_niv;
Counter=_n_;
RUN;

data work.gro_tot;
set work.dim_mut;
run;

PROC Append base=work.gro_tot data=work.gro_mut force;
run;

PROC SORT data=work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RUN;

DATA work.gro_tot (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Cum_weight Count_lev Counter);
SET work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RETAIN gew_cum;
IF gew_mut=. then gew_mut=0;
IF first.fin_jaar then gew_cum=gew_mut;
IF not first.fin_jaar THEN gew_cum=gew_cum+gew_mut;

Company="Cor";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
Cum_weight=gew_cum;
Count_lev=tel_niv;
Counter=_n_;
RUN;

PROC APPEND base=DB2FIN.Gld_totals data=work.gro_tot;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_totals ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;

PROC APPEND base=DB2FIN.Gld_Sales data=work.dim_mutx;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_sales ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;

/***************************************************************/
/******    Updating tfgld201/202/203/204 ECP Data       ******/
/***************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE ( SET LOCK MODE TO WAIT) by baan ;
 CREATE table work.gld201 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				b.t_desc    gro_oms
    FROM        ttfgld201130 a,
                ttfgld008130 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041'))) 					  );
 CREATE table work.gld203 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms
    FROM        ttfgld203130 a,
                ttfgld008130 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld202 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				a.t_fqt1	mut_gew,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld202130 a,
                ttfgld008130 b,
				ttfgld010130 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx  and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld204 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld204130 a,
                ttfgld008130 b,
				ttfgld010130 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					   );
 CREATE table work.finper as select * from connection to baan
   (SELECT  a.t_year   fjaar,
            a.t_prno   fper,
            a.t_stdt   datum,
			b.t_leac   grootb,
			b.t_desc   gro_oms,
			b.t_subl   tel_niv

   FROM         ttfgld005130 a,
   				ttfgld008130 b
   WHERE    a.t_ptyp=1 				  );
 DISCONNECT from baan;
RUN;

DATA work.f_gro (keep=fin_jaar fin_per saldo grootb gro_oms tel_niv);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar>2006 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.f_dim (keep=fin_jaar fin_per saldo grootb gro_oms);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar=year(date())-1 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.gld203;
SET work.gld203;
fin_per=0;
RUN;

DATA work.gld204;
SET work.gld204;
fin_per=0;
RUN;

proc sort data=work.gld203;
by fin_jaar grootb fin_per eenheid;
proc sort data=work.gld201;
by fin_jaar grootb fin_per eenheid; 
run;

DATA work.samen1;
merge work.gld203 work.gld201;
by fin_jaar grootb fin_per eenheid;
run;

PROC SORT data=work.samen1;
BY fin_jaar grootb fin_per gro_oms;
RUN;

PROC MEANS data=work.samen1 NOPRINT;
VAR beg_sal deb_mut cre_mut;
BY fin_jaar grootb fin_per gro_oms;
OUTPUT OUT=work.samen1_1  SUM(beg_sal deb_mut cre_mut)=beg_sal deb_mut cre_mut;
RUN;

PROC SORT data=work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
PROC SORT data=work.f_gro;
BY fin_jaar grootb fin_per gro_oms;
RUN;

data work.samen1_2;
merge work.f_gro work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen1_2;
BY fin_jaar grootb fin_per;
RUN;

DATA work.gro_mut (drop=_type_ _freq_);
SET work.samen1_2;
BY fin_jaar grootb fin_per;
RETAIN saldo;
if first.grootb and fin_per=0 then saldo=beg_sal; 
if first.grootb and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.grootb then saldo=saldo+deb_mut-cre_mut;
dim_type=0;
dim_cod="-";
dim_oms="nvt";
if tel_niv=. then tel_niv=0;
RUN;

proc sort data=work.gld204;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
proc sort data=work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

DATA work.samen2;
merge work.gld204 work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

PROC SORT data=work.samen2;
BY fin_jaar grootb dim_type dim_cod fin_per gro_oms dim_oms;
RUN;

PROC MEANS data=work.samen2 NOPRINT;
VAR beg_sal deb_mut cre_mut mut_gew;
BY fin_jaar grootb dim_type dim_cod tel_niv fin_per gro_oms dim_oms;
OUTPUT OUT=work.samen2_1  SUM(beg_sal deb_mut cre_mut mut_gew)=beg_sal deb_mut cre_mut gew_mut;
RUN;

DATA work.samen2_w;
SET work.samen2_1;
RUN;

PROC SORT data=work.samen2_1 nodupkeys;
BY fin_jaar dim_type dim_cod tel_niv grootb gro_oms dim_oms;
RUN;

DATA work.samen2_2 (drop = _freq_ _type_ beg_sal cre_mut deb_mut fin_per gew_mut);
set work.samen2_1;
RUN;

PROC SORT data=work.samen2_2;
BY fin_jaar dim_type dim_cod grootb;
RUN;

proc sql;
create table work.samen2_3 as
 select * from work.samen2_2 a left join work.f_dim b on a.grootb=b.grootb;
 run;

PROC SORT data=work.samen2_3;
BY fin_jaar dim_type dim_cod grootb fin_per;
PROC SORT data=work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
RUN;

data work.samen2_4 (drop=_type_ _freq_);
merge work.samen2_3 work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RUN;

DATA work.dim_mut;
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
where dim_type=1;
RUN;


DATA work.dim_mutx (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Count_lev Counter);
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=+deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
WHERE grootb>'30000' and grootb<'31000';

Company="ECP";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
IF Mut_weight=. THEN Mut_weight=0;
Count_lev=tel_niv;
Counter=_n_;
RUN;

data work.gro_tot;
set work.dim_mut;
run;

PROC Append base=work.gro_tot data=work.gro_mut force;
run;

PROC SORT data=work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RUN;

DATA work.gro_tot (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Cum_weight Count_lev Counter);
SET work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RETAIN gew_cum;
IF gew_mut=. then gew_mut=0;
IF first.fin_jaar then gew_cum=gew_mut;
IF not first.fin_jaar THEN gew_cum=gew_cum+gew_mut;

Company="ECP";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
Cum_weight=gew_cum;
Count_lev=tel_niv;
Counter=_n_;
RUN;

PROC APPEND base=DB2FIN.Gld_totals data=work.gro_tot;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_totals ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;

PROC APPEND base=DB2FIN.Gld_Sales data=work.dim_mutx;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_sales ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;



/***************************************************************/
/******    Updating tfgld201/202/203/204 EAP Data       ******/
/***************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE ( SET LOCK MODE TO WAIT) by baan ;
 CREATE table work.gld201 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				b.t_desc    gro_oms
    FROM        ttfgld201300 a,
                ttfgld008300 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041'))) 					  );
 CREATE table work.gld203 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms
    FROM        ttfgld203300 a,
                ttfgld008300 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld202 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				a.t_fqt1	mut_gew,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld202300 a,
                ttfgld008300 b,
				ttfgld010300 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx  and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld204 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld204300 a,
                ttfgld008300 b,
				ttfgld010300 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					   );
 CREATE table work.finper as select * from connection to baan
   (SELECT  a.t_year   fjaar,
            a.t_prno   fper,
            a.t_stdt   datum,
			b.t_leac   grootb,
			b.t_desc   gro_oms,
			b.t_subl   tel_niv

   FROM         ttfgld005300 a,
   				ttfgld008300 b
   WHERE    a.t_ptyp=1 				  );
 DISCONNECT from baan;
RUN;

DATA work.f_gro (keep=fin_jaar fin_per saldo grootb gro_oms tel_niv);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar>2006 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.f_dim (keep=fin_jaar fin_per saldo grootb gro_oms);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar=year(date())-1 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.gld203;
SET work.gld203;
fin_per=0;
RUN;

DATA work.gld204;
SET work.gld204;
fin_per=0;
RUN;

proc sort data=work.gld203;
by fin_jaar grootb fin_per eenheid;
proc sort data=work.gld201;
by fin_jaar grootb fin_per eenheid; 
run;

DATA work.samen1;
merge work.gld203 work.gld201;
by fin_jaar grootb fin_per eenheid;
run;

PROC SORT data=work.samen1;
BY fin_jaar grootb fin_per gro_oms;
RUN;

PROC MEANS data=work.samen1 NOPRINT;
VAR beg_sal deb_mut cre_mut;
BY fin_jaar grootb fin_per gro_oms;
OUTPUT OUT=work.samen1_1  SUM(beg_sal deb_mut cre_mut)=beg_sal deb_mut cre_mut;
RUN;

PROC SORT data=work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
PROC SORT data=work.f_gro;
BY fin_jaar grootb fin_per gro_oms;
RUN;

data work.samen1_2;
merge work.f_gro work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen1_2;
BY fin_jaar grootb fin_per;
RUN;

DATA work.gro_mut (drop=_type_ _freq_);
SET work.samen1_2;
BY fin_jaar grootb fin_per;
RETAIN saldo;
if first.grootb and fin_per=0 then saldo=beg_sal; 
if first.grootb and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.grootb then saldo=saldo+deb_mut-cre_mut;
dim_type=0;
dim_cod="-";
dim_oms="nvt";
if tel_niv=. then tel_niv=0;
RUN;

proc sort data=work.gld204;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
proc sort data=work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

DATA work.samen2;
merge work.gld204 work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

PROC SORT data=work.samen2;
BY fin_jaar grootb dim_type dim_cod fin_per gro_oms dim_oms;
RUN;

PROC MEANS data=work.samen2 NOPRINT;
VAR beg_sal deb_mut cre_mut mut_gew;
BY fin_jaar grootb dim_type dim_cod tel_niv fin_per gro_oms dim_oms;
OUTPUT OUT=work.samen2_1  SUM(beg_sal deb_mut cre_mut mut_gew)=beg_sal deb_mut cre_mut gew_mut;
RUN;

DATA work.samen2_w;
SET work.samen2_1;
RUN;

PROC SORT data=work.samen2_1 nodupkeys;
BY fin_jaar dim_type dim_cod tel_niv grootb gro_oms dim_oms;
RUN;

DATA work.samen2_2 (drop = _freq_ _type_ beg_sal cre_mut deb_mut fin_per gew_mut);
set work.samen2_1;
RUN;

PROC SORT data=work.samen2_2;
BY fin_jaar dim_type dim_cod grootb;
RUN;

proc sql;
create table work.samen2_3 as
 select * from work.samen2_2 a left join work.f_dim b on a.grootb=b.grootb;
 run;

PROC SORT data=work.samen2_3;
BY fin_jaar dim_type dim_cod grootb fin_per;
PROC SORT data=work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
RUN;

data work.samen2_4 (drop=_type_ _freq_);
merge work.samen2_3 work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RUN;

DATA work.dim_mut;
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
where dim_type=1;
RUN;


DATA work.dim_mutx (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Count_lev Counter);
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=+deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
WHERE grootb>'30000' and grootb<'31000';

Company="EAP";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
IF Mut_weight=. THEN Mut_weight=0;
Count_lev=tel_niv;
Counter=_n_;
RUN;

data work.gro_tot;
set work.dim_mut;
run;

PROC Append base=work.gro_tot data=work.gro_mut force;
run;

PROC SORT data=work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RUN;

DATA work.gro_tot (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Cum_weight Count_lev Counter);
SET work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RETAIN gew_cum;
IF gew_mut=. then gew_mut=0;
IF first.fin_jaar then gew_cum=gew_mut;
IF not first.fin_jaar THEN gew_cum=gew_cum+gew_mut;

Company="EAP";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
Cum_weight=gew_cum;
Count_lev=tel_niv;
Counter=_n_;
RUN;

PROC APPEND base=DB2FIN.Gld_totals data=work.gro_tot;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_totals ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;

PROC APPEND base=DB2FIN.Gld_Sales data=work.dim_mutx;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_sales ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;



/***************************************************************/
/******    Updating tfgld201/202/203/204 KSI Data         ******/
/***************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE ( SET LOCK MODE TO WAIT) by baan ;
 CREATE table work.gld201 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				b.t_desc    gro_oms
    FROM        ttfgld201400 a,
                ttfgld008400 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041'))) 					  );
 CREATE table work.gld203 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms
    FROM        ttfgld203400 a,
                ttfgld008400 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld202 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				a.t_fqt1	mut_gew,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld202400 a,
                ttfgld008400 b,
				ttfgld010400 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx  and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld204 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld204400 a,
                ttfgld008400 b,
				ttfgld010400 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					   );
 CREATE table work.finper as select * from connection to baan
   (SELECT  a.t_year   fjaar,
            a.t_prno   fper,
            a.t_stdt   datum,
			b.t_leac   grootb,
			b.t_desc   gro_oms,
			b.t_subl   tel_niv

   FROM         ttfgld005400 a,
   				ttfgld008400 b
   WHERE    a.t_ptyp=1 				  );
 DISCONNECT from baan;
RUN;

DATA work.f_gro (keep=fin_jaar fin_per saldo grootb gro_oms tel_niv);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar>2006 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.f_dim (keep=fin_jaar fin_per saldo grootb gro_oms);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar=year(date())-1 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.gld203;
SET work.gld203;
fin_per=0;
RUN;

DATA work.gld204;
SET work.gld204;
fin_per=0;
RUN;

proc sort data=work.gld203;
by fin_jaar grootb fin_per eenheid;
proc sort data=work.gld201;
by fin_jaar grootb fin_per eenheid; 
run;

DATA work.samen1;
merge work.gld203 work.gld201;
by fin_jaar grootb fin_per eenheid;
run;

PROC SORT data=work.samen1;
BY fin_jaar grootb fin_per gro_oms;
RUN;

PROC MEANS data=work.samen1 NOPRINT;
VAR beg_sal deb_mut cre_mut;
BY fin_jaar grootb fin_per gro_oms;
OUTPUT OUT=work.samen1_1  SUM(beg_sal deb_mut cre_mut)=beg_sal deb_mut cre_mut;
RUN;

PROC SORT data=work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
PROC SORT data=work.f_gro;
BY fin_jaar grootb fin_per gro_oms;
RUN;

data work.samen1_2;
merge work.f_gro work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen1_2;
BY fin_jaar grootb fin_per;
RUN;

DATA work.gro_mut (drop=_type_ _freq_);
SET work.samen1_2;
BY fin_jaar grootb fin_per;
RETAIN saldo;
if first.grootb and fin_per=0 then saldo=beg_sal; 
if first.grootb and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.grootb then saldo=saldo+deb_mut-cre_mut;
dim_type=0;
dim_cod="-";
dim_oms="nvt";
if tel_niv=. then tel_niv=0;
RUN;

proc sort data=work.gld204;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
proc sort data=work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

DATA work.samen2;
merge work.gld204 work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

PROC SORT data=work.samen2;
BY fin_jaar grootb dim_type dim_cod fin_per gro_oms dim_oms;
RUN;

PROC MEANS data=work.samen2 NOPRINT;
VAR beg_sal deb_mut cre_mut mut_gew;
BY fin_jaar grootb dim_type dim_cod tel_niv fin_per gro_oms dim_oms;
OUTPUT OUT=work.samen2_1  SUM(beg_sal deb_mut cre_mut mut_gew)=beg_sal deb_mut cre_mut gew_mut;
RUN;

DATA work.samen2_w;
SET work.samen2_1;
RUN;

PROC SORT data=work.samen2_1 nodupkeys;
BY fin_jaar dim_type dim_cod tel_niv grootb gro_oms dim_oms;
RUN;

DATA work.samen2_2 (drop = _freq_ _type_ beg_sal cre_mut deb_mut fin_per gew_mut);
set work.samen2_1;
RUN;

PROC SORT data=work.samen2_2;
BY fin_jaar dim_type dim_cod grootb;
RUN;

proc sql;
create table work.samen2_3 as
 select * from work.samen2_2 a left join work.f_dim b on a.grootb=b.grootb;
 run;

PROC SORT data=work.samen2_3;
BY fin_jaar dim_type dim_cod grootb fin_per;
PROC SORT data=work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
RUN;

data work.samen2_4 (drop=_type_ _freq_);
merge work.samen2_3 work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RUN;

DATA work.dim_mut;
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
where dim_type=1;
RUN;


DATA work.dim_mutx (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Count_lev Counter);
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=+deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
WHERE grootb>'30000' and grootb<'31000';

Company="KSI";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
IF Mut_weight=. THEN Mut_weight=0;
Count_lev=tel_niv;
Counter=_n_;
RUN;

data work.gro_tot;
set work.dim_mut;
run;

PROC Append base=work.gro_tot data=work.gro_mut force;
run;

PROC SORT data=work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RUN;

DATA work.gro_tot (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Cum_weight Count_lev Counter);
SET work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RETAIN gew_cum;
IF gew_mut=. then gew_mut=0;
IF first.fin_jaar then gew_cum=gew_mut;
IF not first.fin_jaar THEN gew_cum=gew_cum+gew_mut;

Company="KSI";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
Cum_weight=gew_cum;
Count_lev=tel_niv;
Counter=_n_;
RUN;

PROC APPEND base=DB2FIN.Gld_totals data=work.gro_tot;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_totals ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;

PROC APPEND base=DB2FIN.Gld_Sales data=work.dim_mutx;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_sales ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;


/***************************************************************/
/******    Updating tfgld201/202/203/204 EGR Data         ******/
/***************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE ( SET LOCK MODE TO WAIT) by baan ;
 CREATE table work.gld201 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				b.t_desc    gro_oms
    FROM        ttfgld201900 a,
                ttfgld008900 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041'))) 					  );
 CREATE table work.gld203 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms
    FROM        ttfgld203900 a,
                ttfgld008900 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld202 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				a.t_fqt1	mut_gew,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld202900 a,
                ttfgld008900 b,
				ttfgld010900 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx  and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld204 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld204900 a,
                ttfgld008900 b,
				ttfgld010900 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					   );
 CREATE table work.finper as select * from connection to baan
   (SELECT  a.t_year   fjaar,
            a.t_prno   fper,
            a.t_stdt   datum,
			b.t_leac   grootb,
			b.t_desc   gro_oms,
			b.t_subl   tel_niv

   FROM         ttfgld005900 a,
   				ttfgld008900 b
   WHERE    a.t_ptyp=1 				  );
 DISCONNECT from baan;
RUN;

DATA work.f_gro (keep=fin_jaar fin_per saldo grootb gro_oms tel_niv);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar>2006 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.f_dim (keep=fin_jaar fin_per saldo grootb gro_oms);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar=year(date())-1 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.gld203;
SET work.gld203;
fin_per=0;
RUN;

DATA work.gld204;
SET work.gld204;
fin_per=0;
RUN;

proc sort data=work.gld203;
by fin_jaar grootb fin_per eenheid;
proc sort data=work.gld201;
by fin_jaar grootb fin_per eenheid; 
run;

DATA work.samen1;
merge work.gld203 work.gld201;
by fin_jaar grootb fin_per eenheid;
run;

PROC SORT data=work.samen1;
BY fin_jaar grootb fin_per gro_oms;
RUN;

PROC MEANS data=work.samen1 NOPRINT;
VAR beg_sal deb_mut cre_mut;
BY fin_jaar grootb fin_per gro_oms;
OUTPUT OUT=work.samen1_1  SUM(beg_sal deb_mut cre_mut)=beg_sal deb_mut cre_mut;
RUN;

PROC SORT data=work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
PROC SORT data=work.f_gro;
BY fin_jaar grootb fin_per gro_oms;
RUN;

data work.samen1_2;
merge work.f_gro work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen1_2;
BY fin_jaar grootb fin_per;
RUN;

DATA work.gro_mut (drop=_type_ _freq_);
SET work.samen1_2;
BY fin_jaar grootb fin_per;
RETAIN saldo;
if first.grootb and fin_per=0 then saldo=beg_sal; 
if first.grootb and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.grootb then saldo=saldo+deb_mut-cre_mut;
dim_type=0;
dim_cod="-";
dim_oms="nvt";
if tel_niv=. then tel_niv=0;
RUN;

proc sort data=work.gld204;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
proc sort data=work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

DATA work.samen2;
merge work.gld204 work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

PROC SORT data=work.samen2;
BY fin_jaar grootb dim_type dim_cod fin_per gro_oms dim_oms;
RUN;

PROC MEANS data=work.samen2 NOPRINT;
VAR beg_sal deb_mut cre_mut mut_gew;
BY fin_jaar grootb dim_type dim_cod tel_niv fin_per gro_oms dim_oms;
OUTPUT OUT=work.samen2_1  SUM(beg_sal deb_mut cre_mut mut_gew)=beg_sal deb_mut cre_mut gew_mut;
RUN;

DATA work.samen2_w;
SET work.samen2_1;
RUN;

PROC SORT data=work.samen2_1 nodupkeys;
BY fin_jaar dim_type dim_cod tel_niv grootb gro_oms dim_oms;
RUN;

DATA work.samen2_2 (drop = _freq_ _type_ beg_sal cre_mut deb_mut fin_per gew_mut);
set work.samen2_1;
RUN;

PROC SORT data=work.samen2_2;
BY fin_jaar dim_type dim_cod grootb;
RUN;

proc sql;
create table work.samen2_3 as
 select * from work.samen2_2 a left join work.f_dim b on a.grootb=b.grootb;
 run;

PROC SORT data=work.samen2_3;
BY fin_jaar dim_type dim_cod grootb fin_per;
PROC SORT data=work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
RUN;

data work.samen2_4 (drop=_type_ _freq_);
merge work.samen2_3 work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RUN;

DATA work.dim_mut;
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
where dim_type=1;
RUN;


DATA work.dim_mutx (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Count_lev Counter);
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=+deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
WHERE grootb>'30000' and grootb<'31000';

Company="EGR";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
IF Mut_weight=. THEN Mut_weight=0;
Count_lev=tel_niv;
Counter=_n_;
RUN;

data work.gro_tot;
set work.dim_mut;
run;

PROC Append base=work.gro_tot data=work.gro_mut force;
run;

PROC SORT data=work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RUN;

DATA work.gro_tot (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Cum_weight Count_lev Counter);
SET work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RETAIN gew_cum;
IF gew_mut=. then gew_mut=0;
IF first.fin_jaar then gew_cum=gew_mut;
IF not first.fin_jaar THEN gew_cum=gew_cum+gew_mut;

Company="EGR";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
Cum_weight=gew_cum;
Count_lev=tel_niv;
Counter=_n_;
RUN;

PROC APPEND base=DB2FIN.Gld_totals data=work.gro_tot; WHERE Fin_per <> .;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_totals ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;

PROC APPEND base=DB2FIN.Gld_Sales data=work.dim_mutx;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_sales ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;



/***************************************************************/
/******    Updating tfgld201/202/203/204 EGH Data         ******/
/***************************************************************/
PROC sql;
CONNECT to odbc as baan (dsn='informix');
EXECUTE ( SET LOCK MODE TO WAIT) by baan ;
 CREATE table work.gld201 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				b.t_desc    gro_oms
    FROM        ttfgld201910 a,
                ttfgld008910 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041'))) 					  );
 CREATE table work.gld203 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms
    FROM        ttfgld203910 a,
                ttfgld008910 b
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				(((a.t_leac>'10000' and a.t_leac<'30000') or (a.t_leac>'31009' and a.t_leac<'40000')) and 
                  (a.t_leac not in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                                    '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                                    '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                                    '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld202 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
   				a.t_prno    fin_per,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fdah	deb_mut,
				a.t_fcah    cre_mut,
				a.t_fqt1	mut_gew,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld202910 a,
                ttfgld008910 b,
				ttfgld010910 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx  and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					  );
 CREATE table work.gld204 as select * from connection to baan
   (SELECT      a.t_year    fin_jaar,
				a.t_leac    grootb,
				a.t_dtyp    dim_type,
				a.t_dimx    dim_cod,
				a.t_ccur    eenheid,
				a.t_fobh    beg_sal,
				b.t_desc    gro_oms,
				c.t_desc    dim_oms,
				c.t_subl    tel_niv
    FROM        ttfgld204910 a,
                ttfgld008910 b,
				ttfgld010910 c
    WHERE       a.t_leac = b.t_leac and
				a.t_year > 2006 and
				a.t_dtyp = c.t_dtyp and
				a.t_dimx = c.t_dimx and
				((a.t_leac>'30000' and a.t_leac<'31000') or (a.t_leac>'40001' and a.t_leac<'50000') or 
                 (a.t_leac in ('31121','32011','32021','32051','32071','32111','32211','32311','32411',
                               '32511','32521','33011','33051','33071','33081','33111','33112','33113',
                               '33115','33117','33118','33119','35011','35021','35031','35041','35051','35071',
                               '35611','35911','35919','35921','35922','32031','32041')))					   );
 CREATE table work.finper as select * from connection to baan
   (SELECT  a.t_year   fjaar,
            a.t_prno   fper,
            a.t_stdt   datum,
			b.t_leac   grootb,
			b.t_desc   gro_oms,
			b.t_subl   tel_niv

   FROM         ttfgld005910 a,
   				ttfgld008910 b
   WHERE    a.t_ptyp=1 				  );
 DISCONNECT from baan;
RUN;

DATA work.f_gro (keep=fin_jaar fin_per saldo grootb gro_oms tel_niv);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar>2006 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.f_dim (keep=fin_jaar fin_per saldo grootb gro_oms);
SET work.finper;
fin_per=fper;
fin_jaar=fjaar;
WHERE fjaar=year(date())-1 and datum<(date()) and datum>MDY(01,01,1990);
RUN;

DATA work.gld203;
SET work.gld203;
fin_per=0;
RUN;

DATA work.gld204;
SET work.gld204;
fin_per=0;
RUN;

proc sort data=work.gld203;
by fin_jaar grootb fin_per eenheid;
proc sort data=work.gld201;
by fin_jaar grootb fin_per eenheid; 
run;

DATA work.samen1;
merge work.gld203 work.gld201;
by fin_jaar grootb fin_per eenheid;
run;

PROC SORT data=work.samen1;
BY fin_jaar grootb fin_per gro_oms;
RUN;

PROC MEANS data=work.samen1 NOPRINT;
VAR beg_sal deb_mut cre_mut;
BY fin_jaar grootb fin_per gro_oms;
OUTPUT OUT=work.samen1_1  SUM(beg_sal deb_mut cre_mut)=beg_sal deb_mut cre_mut;
RUN;

PROC SORT data=work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
PROC SORT data=work.f_gro;
BY fin_jaar grootb fin_per gro_oms;
RUN;

data work.samen1_2;
merge work.f_gro work.samen1_1;
BY fin_jaar grootb fin_per gro_oms;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen1_2;
BY fin_jaar grootb fin_per;
RUN;

DATA work.gro_mut (drop=_type_ _freq_);
SET work.samen1_2;
BY fin_jaar grootb fin_per;
RETAIN saldo;
if first.grootb and fin_per=0 then saldo=beg_sal; 
if first.grootb and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.grootb then saldo=saldo+deb_mut-cre_mut;
dim_type=0;
dim_cod="-";
dim_oms="nvt";
if tel_niv=. then tel_niv=0;
RUN;

proc sort data=work.gld204;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
proc sort data=work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

DATA work.samen2;
merge work.gld204 work.gld202;
by fin_jaar grootb dim_type dim_cod fin_per eenheid;
run;

PROC SORT data=work.samen2;
BY fin_jaar grootb dim_type dim_cod fin_per gro_oms dim_oms;
RUN;

PROC MEANS data=work.samen2 NOPRINT;
VAR beg_sal deb_mut cre_mut mut_gew;
BY fin_jaar grootb dim_type dim_cod tel_niv fin_per gro_oms dim_oms;
OUTPUT OUT=work.samen2_1  SUM(beg_sal deb_mut cre_mut mut_gew)=beg_sal deb_mut cre_mut gew_mut;
RUN;

DATA work.samen2_w;
SET work.samen2_1;
RUN;

PROC SORT data=work.samen2_1 nodupkeys;
BY fin_jaar dim_type dim_cod tel_niv grootb gro_oms dim_oms;
RUN;

DATA work.samen2_2 (drop = _freq_ _type_ beg_sal cre_mut deb_mut fin_per gew_mut);
set work.samen2_1;
RUN;

PROC SORT data=work.samen2_2;
BY fin_jaar dim_type dim_cod grootb;
RUN;

proc sql;
create table work.samen2_3 as
 select * from work.samen2_2 a left join work.f_dim b on a.grootb=b.grootb;
 run;

PROC SORT data=work.samen2_3;
BY fin_jaar dim_type dim_cod grootb fin_per;
PROC SORT data=work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
RUN;

data work.samen2_4 (drop=_type_ _freq_);
merge work.samen2_3 work.samen2_w;
BY fin_jaar dim_type dim_cod grootb fin_per;
if deb_mut=. then deb_mut=0;
if cre_mut=. then cre_mut=0;
RUN;

PROC SORT data=work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RUN;

DATA work.dim_mut;
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
where dim_type=1;
RUN;


DATA work.dim_mutx (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Count_lev Counter);
SET work.samen2_4;
BY fin_jaar grootb dim_type dim_cod fin_per;
RETAIN saldo;
if first.dim_cod and fin_per=0 then saldo=beg_sal; 
if first.dim_cod and fin_per ne 0 then saldo=+deb_mut-cre_mut; 
if not first.dim_cod then saldo=saldo+deb_mut-cre_mut;
WHERE grootb>'30000' and grootb<'31000';

Company="EGH";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
IF Mut_weight=. THEN Mut_weight=0;
Count_lev=tel_niv;
Counter=_n_;
RUN;

data work.gro_tot;
set work.dim_mut;
run;

PROC Append base=work.gro_tot data=work.gro_mut force;
run;

PROC SORT data=work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RUN;

DATA work.gro_tot (keep=Company Fin_year Fin_per Led_acc_nr Dim_type Dim_code Start_value Deb_mut Cre_mut
						balans Mut_weight Cum_weight Count_lev Counter);
SET work.gro_tot;
BY grootb dim_type dim_cod fin_jaar fin_per;
RETAIN gew_cum;
IF gew_mut=. then gew_mut=0;
IF first.fin_jaar then gew_cum=gew_mut;
IF not first.fin_jaar THEN gew_cum=gew_cum+gew_mut;

Company="EGH";
Fin_year=fin_jaar;
Led_acc_nr=grootb;
Dim_code=dim_cod;
balans=saldo;
Start_value=beg_sal;
IF Start_value=. THEN Start_value=0;
Mut_weight=gew_mut;
Cum_weight=gew_cum;
Count_lev=tel_niv;
Counter=_n_;
RUN;

PROC APPEND base=DB2FIN.Gld_totals data=work.gro_tot; WHERE Fin_per <> .;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_totals ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;

PROC APPEND base=DB2FIN.Gld_Sales data=work.dim_mutx;
RUN;

PROC SQL;
CONNECT to odbc as baan (dsn='db2ecp');
EXECUTE ( CALL ADMIN_CMD('RUNSTATS ON TABLE DB2FIN.Gld_sales ON KEY COLUMNS AND INDEXES ALL ALLOW WRITE ACCESS')  )  by baan ;
QUIT;
