# Time Series

A common requirement in time series applications is to produce
line charts with time on the X axis and the sensor reading on the Y axis.

Clients will typically seek to limit the amount of data returned to a 
manageable number of data points. One way to do this is to provide a 
desired resolution, e.g. "Show me last week's data at 30 minute intervals".
This type of request can be satisfied using $dateTrunc's binSize parameter 
in a $group aggregation stage.

Clients may also wish to specify the desired number of data points, 
e.g. "Show me last week's data in 1,000 data points". 
The best approach here is for the client to simply determine the time interval
required to generate the desired number of data points, and use $dateTrunc 
and the binSize parameter as described above. An alternative approach is to 
use the $bucket operator, but this ends up being more work for the client:
not only does the client have to determine the appropriate time interval, but
has to additionally provide the upper and lower bounds for each time bucket.
Since that later step is done automatically by $dateTrunc/binSize, there's
really no benefit to using $bucket in this use case. Furthermore, the performance
of $bucket decreases significantly as the number of buckets increases, such that
producing just 1,000 data points may prove to be a prohibitively expensive operation. 
Code is provided for both approaches.

