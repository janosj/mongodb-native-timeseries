// Uses the $bucket aggregation stage to reduce the number of data
// points to a manageable quantity for graphing purposes.

// The number of buckets can be specified by the client
// (along with the time window).

// For example, Show me the sensorReadings over the last week in 1,000 data points.
// If a time bucket has no data, no document is returned.

// $sample can't really be used here because we need uniformly distributed time values.

// Client-side logic:
//   1) Determine the bin size (i.e. time increment) needed to break up the time window 
//      into the desired number of bins (i.e. data points)
//   2) Determine the lower bound of each bin.
//   3) Send these values to the $bucket stage.

// As an alternative, consider using $dateTrunc with the binSize parameter in a $group stage.
// Either way, you need to determine the desired bin size, but $dateTrunc/binSize will 
// determine the bucket boundaries for you.

// These timestamps work with the provided json data file.
// If you regenerate the sensorData.json file, adjust as necessary.
start_time = ISODate("2021-11-10T17:13:31.330Z");

// The upper boundary of a bucket is exclusive.
// Since I'm using this value as the upper boundary of the last bucket,
// I extend this value 1s beyond that value of the data set.
end_time   = ISODate("2021-11-10T17:15:27.281Z");

time_window_ms = end_time.getTime() - start_time.getTime();

print("Start Time: " + start_time);
print("End Time  : " + end_time);
print("Time Window (ms): " + time_window_ms);

NUM_POINTS = parseInt(process.env.NUM_POINTS);
print("Number of data points requested: " + NUM_POINTS);

bin_size_ms = Math.floor( time_window_ms / NUM_POINTS );
print("Using a bin size of " + bin_size_ms);

// Build the boundary array
bin_boundary = start_time;
BUCKETS = [];
while (bin_boundary <= end_time) {
  print("Adding bucket: " + bin_boundary);
  BUCKETS.push(bin_boundary);
  bin_boundary = new Date( bin_boundary.getTime() + bin_size_ms );
}
print(BUCKETS);
//  BUCKETS = [ ISODate("2021-11-10T17:13:31.330Z"),
//              ISODate("2021-11-10T17:13:31.340Z"),
//              ISODate("2021-11-10T17:13:31.350Z") ]


db = db.getSiblingDB("TSDEMO");

printjson(

  db.rocketSensors.aggregate([

    // Stage 1: filter on the specified time window
    {
      $match: {
        timestamp: { $gte: start_time, $lte: end_time }
      }
    }

    // Stage 2: bucket the data
    , {
      $bucket: {
        groupBy: "$timestamp",                        // Field to group by
        // Boundaries for the buckets
        boundaries: BUCKETS, 
        default: "Other",                             // Provide this or an outlier produces an error.
        output: {                                     // Output for each bucket
          "docCount": { $count: {} },
          "avgReading": { $avg: "$sensorReading" }
        }
      }
    }

    // Stage 3: Sort
    , {
      $sort : {
         _id: 1
      }
    }

    // Stage 4 (optional): provide integer values
    , {
      $addFields: { rounded: { $round: [ "$avgReading" ] } }
    }
 
  ])

)

