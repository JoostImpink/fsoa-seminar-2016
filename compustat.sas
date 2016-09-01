/*
  Sample sas file to query Compustat Fundamental Annual (Funda)
  
  Sample query to filter potential strong performing firms:
  - minimum market cap of $1 billion
  - return on assets exceeding 10%
  
  For these firms, retrieve:
  - company name (conm)
  - ticker symbol (tic)
  - industry code (sich)
  - sales growth (year over year increase in sale)
  - return on assets (ni/at)
  
  Overview of variables in Funda: https://wrds-web.wharton.upenn.edu/wrds/tools/variable.cfm?library_id=129&file_id=65811
  
*/

/* Initial dataset */
data a_firms (keep = gvkey fyear tic conm sich sale ni at);
set comp.funda;
/* Require fiscal year to be 2015 */
where fyear eq 2015;
/* General filter to drop doubles from Compustat Funda */
if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
run;

/* Sort (probably already sorted by gvkey and fyear) */
proc sort data=a_firms; by gvkey fyear;run;

/* Filter firms */
data b_strongfirms;
set a_firms;
/* Get previous year sales using IFN function: IFN (condition, value if true, value if false, value if missing) */
sale_lag = ifn(gvkey=lag(gvkey) and fyear=lag(fyear)+1, lag(sale) );  
/* Non-missing net income, assets, sales, or lagged sales, cmiss funciton computes #missing variables */
if cmiss ( of ni at sale sale_lag ) eq 0;
/* Minimum return on assets, make sure net income is positive -- just in case assets are negative */
if ni > 0 and ni / at > 0.1;
/* return on assets */
roa = ni / at;
/* sales growth */
growth = sale / sale_lag -1;
run;
