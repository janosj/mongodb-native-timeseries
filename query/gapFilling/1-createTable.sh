source ../../demo.conf

# Create the time series collection

mongosh $MDB_CONNECT_URI --eval '

db.satellite.drop();

db.createCollection(
    "satellite",
    {
       timeseries: {
          timeField: "timestamp",
          metaField: "metadata",
          granularity: "seconds"
       }
    }
)

'

echo "If ok, time series collection created."

