source demo.conf

# Filter results (i.e. measurement counts) to a 5ms window.
# Based on timestamp, so ms is the max precision.

mongo $MDB_CONNECT_URI --eval '

db = db.getSiblingDB("TSDEMO");

db.rocketSensors.aggregate([

  // Stage 1: Filter
  {
    $match: {
      // These timestamps work with the provided json data file.
      // If you regenerate the sensorData.json file, adjust as necessary.
      timestamp: { $gt:  ISODate("2021-11-10T05:47:20.330Z"), 
                   $lte: ISODate("2021-11-10T05:47:20.335Z") }
    }

  },

  // Stage 2: Group By
  {
    $group : {
       _id : "$timestamp" ,
       count: { $sum: 1 }
    }
  }

  // Stage 3: Sort
  ,{
    $sort : {
       _id: 1
    }
  }
 
 ])

'
