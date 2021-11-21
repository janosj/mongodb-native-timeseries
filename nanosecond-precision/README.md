# mongodb-native-timeseries

An example of how to implement nanosecond precision using MongoDB native time series capabilities. 
Since MongoDB timestamps only support millisecond precision, a workaround is to 
store nanoseconds (since epoch) as an additional field alongside each measurement. 
