/ 
Example o fhow to start a q process and load file:
q ~/HSBC/q/vwap_funcs.q
\
 
/ 
loadCSV loads the CSV from location ~/HSBC/data/fx_data.csv
Columns: sym (symbol), time(temporal), price (float), size (long)
\
loadCSV:{
    0N!"Loading CSV file ~/HSBC/data/fx_data.csv";
    colnames:`sym`time`price`size;
    .data.t:flip colnames!("STFJ";",") 0:`$"~/HSBC/data/fx_data.csv"
    0N!"CSV file successfully loaded. Count ", string count .data.t;
 };

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
    select TWAP:TWAP:(next time – time) wavg price by sym from t where sym in syms, time within (start_time;end_time)
 };

/
.data.t is the pre-loaded table from csv @ loadCSV
calcVWAP[s;st;et]
s = sym or list of syms
st = start time
et = end time
e.g. calcVWAP[`CADUSD`USDEUR;11:30:00;12:00:00]
Returns 2 column table of sym and VWAP values
Catches and prints error if encountered
\
calcVWAP:{[s;st;et]
    .[vwapFunc;(.data.t;s;st;et);{0N!"Failed to execute vwapFunc due to ",x}]
 };

/
.data.t is the pre-loaded table from csv @ loadCSV
calcTWAP[s;st;et]
s = sym or list of syms
st = start time
et = end time
e.g. calcTWAP[`CADUSD`USDEUR;11:30:00;12:00:00]
Returns 2 column table of sym and TWAP values
Catches and prints error if encountered
\
calcTWAP:{[s;st;et]
    .[twapFunc;(.data.t;s;st;et);{0N!"Failed to execute twapFunc due to ",x}]
 };

loadCSV[]
