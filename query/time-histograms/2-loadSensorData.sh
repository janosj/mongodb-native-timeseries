source demo.conf

# Load sensor data 


# mongoimport $MDB_CONNECT_URI --db=TSDEMO --collection=rocketSensors --file=data/sensorData.json --maintainInsertionOrder
mongoimport $MDB_CONNECT_URI --db=TSDEMO --collection=rocketSensors --file=data/notCommitted-sensorData.json.1M --maintainInsertionOrder

