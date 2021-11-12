source demo.conf

# Filter results (i.e. measurement details) 
# to a nanosecond-precision window.
# Uses a 2-stage filter to achieve nanosecond precision
# while taking advantage of indexes.

mongo $MDB_CONNECT_URI --eval '

DBQuery.shellBatchSize=300

db = db.getSiblingDB("TSDEMO")

db.rocketSensors.find(

      // Stage 1: Filter
      { 
        // Index-based filter
        // These timestamps work with the provided json data file.
        // If you regenerate the sensorData.json file, adjust as necessary.
        timestamp: { $gt:  ISODate("2021-11-10T05:47:20.330Z"), 
                     $lte: ISODate("2021-11-10T05:47:20.335Z") },

        // Nanosecond filter (not indexed)
        // These timestamps work with the provided json data file.
        // If you regenerate the sensorData.json file, adjust as necessary.
        nano: { $gte: NumberLong("1636523240331857404"),
                $lte: NumberLong("1636523240335190751") }

      }, 

      // Stage 2: Projection (attribute selection)
      { timestamp:1, nano:1, sensorReading:1, _id:0 })

'

