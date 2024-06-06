# HSBC
HSBC Interview Tasks

OVERVIEW:
The tasks below range from more simple requirements to a wider design exercise and are intended to allow you to showcase your knowledge and expertise, and to allow us to discuss these solutions in a follow-up meeting.  It is down to your judgement to provide a balance of detail for offline review vs expediency and details which can be discussed separately.
Common requirements and notes for all tasks:
  •	The basis of the project should be kdb/q and coding exercises should bear this in mind.  Design exercises may consider other languages or technology stacks.
  •	Work for the below should either be uploaded to an online account on github (other sites blocked) and the link shared, or sent as a zip file.
  •	Any documentation on how to run solutions should be provided to an appropriate level of detail.
  •	Background material to assist you can be found at https://code.kx.com/
  •	Guidelines for coding standards:
    o	Treat the structure of the data and code as a proof of concept, but with the expectation to rapidly port to a production quality codebase
    o	As such, whilst a PoC this needs to run in a stable and supportable manner
    o	This extends to testing and appropriate test coverage; please provide a simple overview as to how you have tested the solution provided.  The testing mechanism is up to you.
    o	Unless stated otherwise, the choice of how to structure the output (files, names, locations) is entirely yours.

TASK #1:
The purpose of this task is for you to write a function to calculate the VWAP (volume-weighted average price) for input data, consisting of a timeseries of pricing data with prices and sizes for different fx (foreign exchange) currencies.  If time permits, you can extend this to also write a TWAP (time-weighted average price) function.
There should be 4 outcomes for this project:
1.	An input file with data you have created in csv format
2.	A function which, given a time range and a list of symbols as inputs, returns the VWAP (TWAP) for each of these symbols as a table
3.	A command to start a q process which will load this function
4.	Example of how to call the function

TASK #2:
The purpose of this mini project is for you to write a function to calculate the conditional market VWAP (volume-weighted average price) corresponding to a set of client orders.
The implicit/required underlying data consist of 2 tables
1.	a clientorders table with the following columns: `id`version`sym`time`side`limit`start`end.  Each record in this table corresponds to a client order.

sym is the financial instrument corresponding to that order
start/end are timestamps denoting the order lifetime (.e.g order with id=1 starts at 2021.01.01D09:00 and ends at 2021.01.01.D10:30).
side denotes whether the order is requesting to buy or sell the instrument.
limit is the limit price (ie buy at most at this price, or sell at least at this price).
Each order has a unique id and the limit price of an order may change over time, in which case its version will increment. If the limit does change for an id, you can assume that the start/end times are unaffected, ie as per the initial order's version start and end time.
2.	a markettrades table with the following columns: `sym`time`price`volume. sym is again the financial instrument, whereas price and volume denotes the market traded price and size at the time.
Example of clientorders (you should aim to build a more comprehensive input):

<IMAGE>

(For both tables, think about how the prices per symbol change over time to make a more realistic input)
Conditional market VWAP for a given order, is defined as the market vwap during the lifetime of a client order, which is conditional (ie within the limit) to that order's limit price at the time (eg. if the limit price for a buy order is 10.0, then any market prints >10.0 would not be included, and the opposite for a sell order).
In other words, over the course of the order's life cycle, include market trades which could have filled the order.
Acceptance Criteria:
  •	Your function will take a client order and market trades tables as inputs and return a table which contains one record per client id , the sym,start and end columns, and an extra column, the conditional vwap described above.
  •	A sample/example run of the function with some input/output should be documented (it can be part of tests).

TASK #3:
You have been tasked with implementing a kdb+ based solution for a new UI feature which provides charting of different stock prices over time, based on some high frequency historical data. The universe of stocks is 5,000, with millions of records per day for each stock. The data goes back 3 years.
The requirements are:
  •	The charting front end will pass in a symbol (the stock sym), a start and end timestamp and a granularity, ie how many price points to return to the chart.
  •	The return object to the charting front end should be a table with sym,time,price columns - its count being equal to the value of the granularity.
  •	Note that performance here takes priority over precision since this is just a charting function to indicate the price performance over relatively long periods of time. eg week/month(s). Granularity can be anything from 50 points to 1,000.
  •	The charting service will have hundreds of users, so concurrent charting requests may happen.
Provide a high-level description of the database design you would propose for this solution, along with technical details around the database's features.  NB: This is not strictly a coding exercise but you may find it useful to sketch out concepts in code.
How you store and represent the data and/or at what granularity (if this is applicable) is completely your choice. Please include in your description what led you to propose each of your design choices. 
Include a high level description of any other code, processes or functionality that would have to be built in conjunction with creating this db design to serve the above requirement.
Please then consider the following:
  •	What are the strongest points or your design and what are some of its limitations and challenges?
  •	What is the best design you could think of if charting precision was the outmost priority?
  •	What is the best design you could think of if performance was the outmost priority?

