source demo.conf

# Create the time series collection

mongo $MDB_CONNECT_URI --eval '

db = db.getSiblingDB("stars"); 

db.sensorReadings.drop();

db.createCollection(
    "telemetry",
    {
       timeseries: {
          timeField: "timestamp",
          metaField: "metadata",
          granularity: "seconds"
          bucketMaxSpanSeconds: 3600
       }
    }
)

'

