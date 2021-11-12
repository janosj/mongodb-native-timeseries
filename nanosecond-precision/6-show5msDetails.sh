source demo.conf

# Filter results (i.e. measurement details) to a 5ms window.
# Based on timestamp, so ms is the max precision.

mongo $MDB_CONNECT_URI --eval '

DBQuery.shellBatchSize=300

db = db.getSiblingDB("TSDEMO")

db.rocketSensors.find(

      // Stage 1: Filter
      { 
        // These timestamps work with the provided json data file.
        // If you regenerate the sensorData.json file, adjust as necessary.
        timestamp: { $gt:  ISODate("2021-11-10T05:47:20.330Z"), 
                     $lte: ISODate("2021-11-10T05:47:20.335Z") }
      }, 

      // Stage 2: Projection (attribute selection)
      { timestamp:1, nano:1, sensorReading:1, _id:0 })

'

