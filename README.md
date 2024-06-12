# README

### The Package
You will likely have executed a `git clone` on this repo from my [github](https://github.com/paulyd82/HSBC/tree/main). 

#### Some assumptions for this project:

- The user is on a Linux server with q installed.
- The package, once cloned, *may* be named "HSBC-main". Please rename it to HSBC. If not, please ignore.
```bash
mv HSBC-main HSBC
```
- The repository has been cloned into the home/root directory of your user/appuser. If not, feel free to move it to your home dir.
```bash
mv HSBC ~/.
```
<br>

### Start-up

#### Start q process for Tasks 1 and 2
Once the package is ready in the correct location you can then run the following commands to start the q process. On start-up it automatically loads the CSV files and q functions from the package:

```bash
cd ~/HSBC
./run_q.sh
```

Successful start-up should be illustrated with the following example messages logged to your q session (note the counts may differ, but should be > 0):

```q
"Loading CSV file /home/pduffy/HSBC/data/fx_data.csv"
"CSV file successfully loaded. Count 150"
"Loading CSV file /home/pduffy/HSBC/data/clientorders_data.csv"
"CSV file successfully loaded. Count 75"
"Loading CSV file /home/pduffy/HSBC/data/markettrades_data.csv"
"CSV file successfully loaded. Count 50"
```
Upon loading, the 3 tables associated with these tasks should subsequently be available for inspection as part of assessment:

```q 
select from fx
select from clientorders
select from markettrades
```

The function to load the CSVs is error trapped and the logged error should be intuitively handled by the user.

#### Task 1 Execution

VWAP

- Function call format:
```q 
calcVWAP[fx;s;st;et]

// fx: the name of the pre-loaded table from csv
// s: sym or list of syms
// st: start time
// et: end time
```


- Example call:
```q 
calcVWAP[fx;`USDEUR;11:30:00;12:00:00]
calcVWAP[fx;`CADUSD`SGDUSD;11:00:00;12:00:00]

// inspect table fx for appropriate sym and time range parameters for any other calls
```
- Returns a 2 column table of `sym` and `VWAP` values
- Catches and prints error if encountered

TWAP

- Function call format:
```q 
calcTWAP[fx;s;st;et]

// fx: the name of the pre-loaded table from csv
// s: sym or list of syms
// st: start time
// et: end time
```


- Example call:
```q 
calcTWAP[fx;`USDEUR;11:30:00;12:00:00]
calcTWAP[fx;`CADUSD`SGDUSD;11:00:00;12:00:00]

// inspect table fx for appropriate sym and time range parameters for any other calls
```
- Returns a 2 column table of `sym` and `TWAP` values
- Catches and prints error if encountered

#### Task 2 Execution

Conditional VWAP

- Function call format:
```q 
calcCondVWAP[clientorders;markettrades]

// clientorders:  the name of the pre-loaded table from csv
// markettrades:  the name of the pre-loaded table from csv
```


- Example call:
```q 
calcCondVWAP[clientorders;markettrades]
```
- Returns a 4 column table of `sym`, `start`, `end` and `condVWAP` values
- Catches and prints error if encountered


### Unit Tests

#### Background

For the purposes of this task I have implemebted the k4unit testing framework from KX. Further information on it can be found [here](https://code.kx.com/q/kb/unit-tests/). Tests are not exhaustive but should cover most of the basic checks that would be needed. Unfortunately, I was unable to successfully load in the vwap functions as part of the tests, and I did not get enough time to resolve. I did however created the tests themselves, albeit they are failing, to illustrate some level of testing coverage required for this exercise. 

For simplicity I have created a run script that automates most of the loading functions required to execute the tests, with just a few steps needed for the user, as outlined below.

#### Starting The q Process
Start up the q process and load in the unit testing script:

```bash
cd ~/HSBC
./run_tests.sh
```

Run the following to inspect the tests:
```q 
KUT
```

To inspect results: 
```q 
KUTR

// or some other examples:
show select from KUTR where not ok
show select from KUTR where not okms
show select count i by ok,okms,action from KUTR
show select count i by ok,okms,action,file from KUTR
```

Running the following saves the table KUtr to a file KUTR.csv:
```q 
KUstr[] 
```