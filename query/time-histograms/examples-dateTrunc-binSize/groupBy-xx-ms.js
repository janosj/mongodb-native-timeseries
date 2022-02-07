// Uses the binSize parameter of the $dateTrunc aggregation operator
// to return 1 document for every XX numer of milliseconds.
// For example, return 1 document for every 20 milliseconds.
// $avg is used to aggregate multiple values within each time bin.
// If a time bin has no records, then no document is returned.


BIN_SIZE = parseInt(process.env.TIME_BIN_MS);
print("Using a time bin of " + BIN_SIZE + " milliseconds.");

db = db.getSiblingDB("TSDEMO");

printjson(

  db.rocketSensors.aggregate([

    // Stage 1: Group By
    {
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

    // Stage 2: Sort
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

