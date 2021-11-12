source demo.conf

# Compute stats for a nanosecond-precision time window.
# Uses a 2-stage filter to achieve nanosecond precision
# while taking advantage of the available index on timestamp.

mongo $MDB_CONNECT_URI --eval '
db = db.getSiblingDB("TSDEMO");

db.rocketSensors.aggregate([

  // Stage 1: ms filter (indexed)
  {
    $match: {
      // These timestamps work with the provided json data file.
      // If you regenerate the sensorData.json file, adjust as necessary.
      timestamp: { $gte: ISODate("2021-11-10T05:47:20.330Z"), 
                   $lte: ISODate("2021-11-10T05:47:20.335Z") }
    }

  },

  // Stage 2: nanosecond filter (not indexed)
  {
    $match: {
        // These timestamps work with the provided json data file.
        // If you regenerate the sensorData.json file, adjust as necessary.
        nano: { $gte: NumberLong("1636523240331857404"), 
                $lte: NumberLong("1636523240335190751") }
    }

  },

  // Stage 3: stats
  {
    $group : {
       _id : null ,
       count: { $sum: 1 },
       minReading : { $min: "$sensorReading" },
       maxReading : { $max: "$sensorReading" },
       avgReading : { $avg: "$sensorReading" }
    }
  }

  // Stage 4: sort
  ,{
    $sort : {
       _id: 1
    }
  }
 
 ])

'
