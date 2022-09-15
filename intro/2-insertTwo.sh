source ../demo.conf

# Create the time series collection

mongo $MDB_CONNECT_URI --eval '

db.weather.insertOne(
   {
      "metadata": { "sensorId": 5578, "type": "temperature" },
      "timestamp": ISODate("2021-05-18T00:00:00.000Z"),
      "temp": 12
   }
)

db.weather.insertOne(
   {
      "metadata": { "sensorId": 5578, "type": "temperature" },
      "timestamp": ISODate("2021-05-18T00:00:01.000Z"),
      "temp": 14
   }
)

'

