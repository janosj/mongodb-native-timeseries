// Uses the binSize parameter of the $dateTrunc aggregation operator
// to return 1 document for every XX numer of milliseconds.
// For example, return 1 document for every 20 milliseconds.
// $avg is used to aggregate multiple values within each time bin.
// If a time bin has no records, then no document is returned.


BIN_SIZE = parseInt(process.env.TIME_BIN_MS);
print("Using a time bin of " + BIN_SIZE + " milliseconds.");

db = db.getSiblingDB("TSDEMO");

// These timestamps work with the provided json data file.
// If you regenerate the sensorData.json file, adjust as necessary.
start_time = ISODate("2021-11-10T17:13:31.330Z");
end_time   = ISODate("2021-11-10T17:15:27.281Z");

printjson(

  db.rocketSensors.aggregate([

    // Stage 1: filter on the specified time window
    {
      $match: {
        timestamp: { $gte: start_time, $lte: end_time }
      }
    }

    // Stage 2: Group By
    , {
      $group : {
          _id: {
             timeBin: {
                $dateTrunc: {
                   date: "$timestamp", unit: "millisecond", binSize: BIN_SIZE
                }
             }
          },
          avgReading : { $avg: "$sensorReading" }
      }
    }

    // Stage 3: Sort
    , {
      $sort : {
         _id: 1
      }
    }

    // Stage 3 (optional): provide an integer value
    , {
      $addFields: { rounded: { $round: [ "$avgReading" ] } }
    }
 
  ])

)

