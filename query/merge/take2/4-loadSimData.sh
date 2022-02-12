source demo.conf

# Load sensor data 
# Use Compass to show data in MongoDB

# Nanosecond converter (epoch to human-readable date) is available here:
# https://www.epochconverter.com/

mongoimport $MDB_CONNECT_URI --db=TSDEMO --collection=satellite --file=data/simData.json --maintainInsertionOrder

