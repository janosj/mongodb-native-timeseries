source demo.conf

# Create the time series collection

mongosh $MDB_CONNECT_URI --eval '

db = db.getSiblingDB("stars"); 

db.telemetry.drop();

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

