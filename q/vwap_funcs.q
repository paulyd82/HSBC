////////////////////////////
///////// Task 1 ///////////
////////////////////////////
/ 
Example of how to start a q process and load file:
q ~/HSBC/q/vwap_funcs.q
Assumption is the cloned HSBC repo resides in the home dir
\
 
/ 
load the CSV from location ~/HSBC/data/fx_data.csv
Columns: sym (symbol), time(temporal), price (float), size (long)
\
0N!"Loading CSV file ~/HSBC/data/fx_data.csv";
fx:1_flip `sym`time`price`size!("SPFJ";",") 0: hsym `$"~/HSBC/data/fx_data.csv";
0N!"CSV file successfully loaded. Count ", string count fx;

/
vwapFunc is called by calcVWAP
\
vwapFunc:{[t;syms;start_time;end_time]
    select VWAP:size wavg price by sym from t where sym in syms, time within (start_time;end_time)
 };

/
twapFunc is called by calcTWAP
\
twapFunc:{[t;syms;start_time;end_time]
    select TWAP:(next[time]-time) wavg price by sym from t where sym in syms, time within (start_time;end_time)
 };

/
fx is the pre-loaded table from csv
calcVWAP[fx;s;st;et]
s = sym or list of syms
st = start time
et = end time
e.g. calcVWAP[fx;`CADUSD`USDEUR;11:30:00;12:00:00]
Returns 2 column table of sym and VWAP values
Catches and prints error if encountered
\
calcVWAP:{[fx;s;st;et]
    .[vwapFunc;(fx;s;st;et);{0N!"Failed to execute vwapFunc due to ",x}]
 };

/
fx is the pre-loaded table from csv
calcTWAP[fx;s;st;et]
s = sym or list of syms
st = start time
et = end time
e.g. calcTWAP[fx;`CADUSD`USDEUR;11:30:00;12:00:00]
Returns 2 column table of sym and TWAP values
Catches and prints error if encountered
\
calcTWAP:{[fx;s;st;et]
    .[twapFunc;(fx;s;st;et);{0N!"Failed to execute twapFunc due to ",x}]
 };


////////////////////////////
///////// Task 2 ///////////
////////////////////////////

0N!"Loading CSV file ~/HSBC/data/clientorders.csv";
clientorders:1_flip `id`version`sym`time`side`limit`start`end!("JISPSFPP";",") 0: hsym `$"~/HSBC/data/clientorders.csv";
0N!"CSV file successfully loaded. Count ", string count clientorders;
0N!"Loading CSV file ~/HSBC/data/marketrades.csv";
martektrades:1_flip `sym`time`price`volume!("SPFJ";",") 0: hsym `$"~/HSBC/data/marketrades.csv";
0N!"CSV file successfully loaded. Count ", string count martektrades;   

condVWAPFunc:{[cliOrds;mktrades]
    t:aj[`sym`time;cliOrds;mktrades];
    t:update condMet:1b from t where ((side=`B) and (limit<=price)) or ((side=`S) and (limit>=price));
    t:update condVWAP:volume wavg price by sym from t where condMet;
    select sym,start,end,condVWAP from t
 };

/
clientorders and martektrades are pre-loaded tables from csvs
calcCondVWAP[clientorders;martektrades]
e.g. calcCondVWAP[clientorders;martektrades]
Returns 4 column table of sym,start,end and condVWAP values
Catches and prints error if encountered
\
calcCondVWAP:{[clientorders;martektrades]
    .[condVWAPFunc;(clientorders;martektrades);{0N!"Failed to execute condVWAPFunc due to ",x}]
 };