source demo.conf

# Create the time series collection

mongo $MDB_CONNECT_URI --eval '

db.createCollection(
    "sensorReadings",
    {
       timeseries: {
          timeField: "timestamp",
          metaField: "metadata",
          granularity: "seconds"
       }
    }
)

'

