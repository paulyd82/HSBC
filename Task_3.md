# HSBC

### TASK #3:
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

