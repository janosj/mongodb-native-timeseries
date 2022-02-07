source ../demo.conf

# Adds date truncation and the binSize parameter
# to allow group by arbitrary time buckets.
# The bucket size is hardcoded at 20 milliseconds.

mongosh $MDB_CONNECT_URI --eval '

config.set("displayBatchSize", 100);

db = db.getSiblingDB("TSDEMO");

db.rocketSensors.aggregate([

  // Stage 1: Group By
  {
    $group : {
        _id: {
           timeBin: {
              $dateTrunc: {
                 date: "$timestamp", unit: "millisecond", binSize: 20
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

'
