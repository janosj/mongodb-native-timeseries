source demo.conf

# Create the time series collection

mongo $MDB_CONNECT_URI --eval '

db.rocketSensors.drop();

db.createCollection(
    "rocketSensors",
    {
       timeseries: {
          timeField: "timestamp",
          metaField: "metadata",
          granularity: "seconds"
       }
    }
)

'

