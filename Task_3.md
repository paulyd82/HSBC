# Task 3

## Overview

You have been tasked with implementing a kdb+ based solution for a new UI feature which provides charting of different stock prices over time, based on some high frequency historical data. The universe of stocks is 5,000, with millions of records per day for each stock. The data goes back 3 years.
The requirements are:

-	The charting front end will pass in a symbol (the stock `sym`), a `start` and `end` timestamp and a `granularity`, ie how many price points to return to the chart.
-	The return object to the charting front end should be a table with `sym`,`time`,`price` columns - its count being equal to the value of the granularity.
-	Note that performance here takes priority over precision since this is just a charting function to indicate the price performance over relatively long periods of time. eg week/month(s). Granularity can be anything from 50 points to 1,000.
-	The charting service will have hundreds of users, so concurrent charting requests may happen.

Provide a high-level description of the database **design** you would propose for this solution, along with technical details around the database's features.  NB: This is not strictly a coding exercise but you may find it useful to sketch out concepts in code.
How you store and represent the data and/or at what granularity (if this is applicable) is completely your choice. Please include in your description what led you to propose each of your design choices. 
Include a high level description of any other code, processes or functionality that would have to be built in conjunction with creating this db design to serve the above requirement.

Please then consider the following:

-	What are the strongest points or your design and what are some of its limitations and challenges?
-	What is the best design you could think of if charting precision was the outmost priority?
-	What is the best design you could think of if performance was the outmost priority?

## Solution

### Database Design
#### Assumptions
Although not specified in the overview, for this solution we need to make some assumptions for design:
- There is sufficient ram to support the queries/functions outlined in the solution
- There are several cores available in order to utilise parallel processing for better performance
- The server has a reasonably fast disk 

#### High-level approach
- HDB: The HDB is a standard date-partitioned set-up with parted attribute applied ot the sym column. Shrink the data and save as a separate "rolled-up" table to disk also date-partitioned,residing alongside the raw data. The rolled-up table contains 1000 points per sym per date despite the time ranges for 1000 points being longer as per requirements. Only storing sym, time and price columns in this rolled-up table with the sym column also containing the parted attribute. At run time, spin up several instances (workers) of the HDB to allow for the below query mechanism.
- Query mechanism: Implement a gateway process, which the UI connects to, and which invokes -30! deferred response functionality. [Deferred response](https://code.kx.com/q/kb/deferred-response/) is useful for concurrent user requests without blocking the process while query executions take place. Client synchronous requests are processed asynchronously to avaialble worker processes over a handle, with kdb+ tracking which handles are expecting a response. Implementation of load balancing functionality could be applied on the gateway process, utilising the `mserve.q` script from [KX](https://code.kx.com/q/kb/load-balancing/#starting-the-primary-server).
- When a user query is sent from the UI, the function will check the date range and granularity, and then apply the data-reduction logic to further reduce the number of points from the pre-aggregated 1000 points per day for that sym to the specified number of points applicable to the date range provided. The chosen data-reduction function would be re-used in this case. See below section on Data Shrinking. 

#### Date partitioning
HDB will be partitioned by date. The function call only takes 1 sym but in most cases >=1 date, as per requirements. Partitioning by date should gain better performance across greater date ranges with peaching, automatically invoking kdb's in-build map-reduce functionality. The data volumes per sym per date are low so a query with a large date range should be able to execute very quickly with slaves activated on the HDB process on start-up and ensuring query automatically invokes parallel processing i.e. using `by date`, or `peach dates`.

Basic database partitioning is illustrated [here](https://code.kx.com/q/kb/partition/). 

#### Data Shrinking
Dynamically shrink the data as part of a custom backfill function. We want to reduce the number of data points without distorting the core trends and price movements of the sym across - preserving peaks and troughs of the values, if possible, which are of interest to traders and analysts. There are a couple of ways to do this. One is to utilise the functionality outlined within this [whitepaper](https://code.kx.com/q/wp/ts-shrink/). The Ramer-Douglas-Peucker algorithm is explained and sample code given on a dataset. The intention here would be to apply this to our own time-series dataset to significantly reduce the data points. Although there are different variations outlined within this whitepaper, it would be assumed that relevant testing and performance benchmarks would need to first be explored using our dataset.  
 
Another approach is to apply a smoothing function to the dataset. Again from a whitepaper of an ex-colleague, that can be obtained using a Low Pass Filter function. As mentioned in the whitepaper, it's a simple method to see the longer-term trends and remove the daily noise, focussing on a windowed moving average within its logic. Comparitively speaking, the LPF approach is an easier function to implement and understand, however, as it uses averging logic it may tend to lose a lot more accuracy that the Ramer-Douglas-Peucker algorithm approach. 

Considering the focus of this exercise is performance-based, the [Low Pass Filter](https://code.kx.com/q/wp/signal-processing/#smoothing) approach would be my choice. The reason being that: 
1. It appears much faster than the Ramer-Douglas-Peucker algorithm
2. It appears easier to understand and implement
3. The whitepaper outlined significant reduction in data points: 2 million down to 1,440

Again, sufficient testing and benchmarking would be vital to settling on a choice. 

#### Backfilling
If cores were available, this could potentially be completed during a weekend window or several windows, assuming most processes are not running during that time and cores were available to borrow for the executing process. It also depends on the chosen data shrinking method as they vary in performance. Since this exercise focusses on performance, let's look at what it might take to complete the 3 years of backfilling. 

Approximate calculations on timing for the quicker LPF approach: 
- 2 million to 1,440 points reduction in ~100ms.
- If we assume 2 million data points per sym per day (on average for the universe of syms - some being traded less heavily than others), then for 5000 syms for one date that's approximately a total of 100ms*5000, or 500 seconds (8mins) execution time. That's for one core. 
- Assuming 250 trading days per year, in theory that's ~33 hours needed for the execution time of 1 year of data. Utilise 3 cores, with peaching, reduces execution time down to ~11hours for 1 year of data, or ~33 hours for the full 3 years of data. 
- These are pretty rough calculations and would need to be correctly estimated via appropriate testing. They also exclude allocation time for sorting, applying attributes and enumeration.
- Assumption is that sufficient storage space is available for the extra rolled-up table that would contain the 3 columns and 5 million records (1,000 per each of the 5,000 symbols) per date partition.

<br>
<br>
<br>
<br>

### Design Strong Points, Limitations And Challenges
- HDB: Most effective design for performance. 
- Query mechanism: Most effective design for concurrent queries
- Limitation: Finding a backfill window. If it's an fx hdb there may be little scope to execute on a weekend if trading is 24/7, so it may need to run nightly post-EOD across larger time frame to complete backfill.
- Assumption the the hardware reqs are there. More challenging to do this with less cores.
- Precision is lost with roll-up of hdb data following by a further roll-up based on the date range and granularity specified by user at query time. Larger date ranges and lower granularities will impact this the most.

### Best Design For Charting Precision
- Choose a more precise data shrinking method that will mean a performance hit for user query requests.
- Implement a segmented HDB, assuming additional disk drives were avaliable. Segment by date across the drives, with parted attribute on the sym column. Due to the fact that the raw data is getting queried, and the volumes are significantly greater, the assummption is that several cores executing across just a partitioned database (as per my solution for best performance) it's likely to become IO bound and performance becoming stifled, therefore a segmented database could circumvent this potential issue, delivering increased performance across larger date ranges. This compliments the next point.
- Do not roll-up the hdb data and backfill. Instead just execute the roll-up function at query time based on the date range and granularity specified, so only 1 level of roll-up occurs. This approach will also take a performance hit but should maintain better precision. 
- If the hardware allowed, several instances of the HDB could be spun up, connected to a load balancing server/process which could help distribute user queries to the multiple HDB instances available. This method uses deferred sync calls. Utilising the [mserve.q](https://code.kx.com/q/kb/load-balancing/#starting-the-primary-server) script this could be a quick and relatively easy way to set up this solution rather than implementing a more complicated gateway with -30! deferred response.
  
### Best Design For Performance
- 
