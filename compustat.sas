/*
  Sample sas file to query Compustat Fundamental Annual (Funda)
  
  Sample query to filter potential strong performing firms:
  - minimum market cap of $1 billion
  - return on assets exceeding 5%
  
  For these firms, retrieve:
  - company name (conm)
  - ticker symbol (tic)
  - industry code (sich)
  - sales growth (year over year increase in sale)
  - return on assets (ni/at)
  
  Overview of variables in Funda: https://wrds-web.wharton.upenn.edu/wrds/tools/variable.cfm?library_id=129&file_id=65811
  
*/

/* Initial dataset */
data a_firms (keep = gvkey fyear tic conm sich sale ni at prcc_f csho);
set comp.funda;
/* Require fiscal year to be 2014 and 2015 (two years needed to compute sales growth) */
where fyear IN (2014, 2015);
/* General filter to drop doubles from Compustat Funda */
if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
run;

/* Sort (probably already sorted by gvkey and fyear) */
proc sort data=a_firms; by gvkey fyear;run;

/* Filter firms */
data b_strongfirms;
set a_firms;
/* Get previous year sales using IFN function: IFN (condition, value if true, value if false, value if missing) 
  Period (.) means missing, so if the gvkey is not the same, and fyear is not the next year, set sale_lag to missing
*/
sale_lag = ifn(gvkey=lag(gvkey) and fyear=lag(fyear)+1, lag(sale), . );  
/* Positive sale_lag, positive assets */
if sale_lag > 0 and at > 0;
/* Non-missing net income, assets, (lagged) sales, stock price or #shares. cmiss function computes #missing variables */
if cmiss ( of ni at sale sale_lag prcc_f csho) eq 0;
/* Minimum market cap */
if prcc_f * csho > 1000;
/* return on assets */
roa = ni / at;
/* Minimum return on assets */
if roa > 0.05;
/* sales growth */
growth = sale / sale_lag -1;
run;

/* Print */
proc print data=b_strongfirms (obs=10); run;