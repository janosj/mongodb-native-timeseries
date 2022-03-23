
# Display the settings (e.g. current granularity) on an existing TS collection.
# (Note: output includes all collections in the active database)
# See docs: https://docs.mongodb.com/manual/core/timeseries/timeseries-granularity/#retrieve-the-granularity-of-a-time-series-collection

mongosh $MDB_CONNECT_URI --eval '
db = db.getSiblingDB("TSDEMO")
db.runCommand( { listCollections: 1 } )
'

