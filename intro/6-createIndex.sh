# Data is indexed by time automatically (i.e. the bucket min and max).
# Secondary indexes can be added on the timeField and metaField.

# Example, using the following document format:
#   "timestamp": ISODate("2021-05-18T00:00:00.000Z")
#   "metadata": { "sensorId": 5578, "type": "temperature" }

mongosh $MDB_CONNECT_URI --eval '

db.weather.createIndex( { timestamp: 1, metadata: 1 } )

db.weather.createIndex( { timestamp: 1, "metadata.sensorId": 1 } )

// List indexes. Note that the default time index is not shown.
db.runCommand( {listIndexes: "weather"} )

'

