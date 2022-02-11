source demo.conf

# Create the time series collection

mongosh $MDB_CONNECT_URI --eval '

db.createCollection(
    "weather",
    {
       timeseries: {
          timeField: "timestamp",
          metaField: "metadata",
          granularity: "hours"
       }
    }
)

'

