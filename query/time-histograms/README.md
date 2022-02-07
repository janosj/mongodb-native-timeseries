# Time Histograms

A common requirement in time series applications is to produce
line charts with time on the X axis and the sensor reading on the Y axis.

In this situation, clients will typically seek to limit the amount of data to a 
manageable number of data points. One way to do this is to provide a 
desired resolution, e.g. "Show me last week's data at 30 minute intervals".
This type of request can be satisfied using the *$dateTrunc* operator with its
*binSize* parameter in a *$group* aggregation stage.

Clients might prefer instead to specify the desired number of data points, 
e.g. "Show me last week's data in 1,000 data points". 
The best approach here is for the client to simply determine the time interval
required to generate the desired number of data points, and continue using
*$dateTrunc* and *binSize* as described above. An alternative approach is to 
use the $bucket operator, but this ends up being more work for the client:
not only does the client have to determine the appropriate time interval, but
has to additionally provide the upper and lower bounds for each time bucket.
Since that later step is done automatically by $dateTrunc/binSize, there's
really no benefit to using $bucket in this use case. Furthermore, the performance
of $bucket decreases significantly as the number of buckets increases, such that
producing just 1,000 data points may prove to be a prohibitively expensive operation. 
There is a *$bucketAuto* operator which might address some of these concerns, 
but note that *$bucketAuto* seeks to evenly distribute the documents across the buckets,
while clients seek data points that are evenly distributed across the X axis (time).

The provided code demonstrates the use of *$dateTrunc* and *$bucket*.

