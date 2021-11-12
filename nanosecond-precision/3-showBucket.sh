source demo.conf

# Display an underlying bucket.
# Draw the distinction between the backend storage structure
# (implemented automatically by MongoDB Time Series) vs.
# how clients interact with the data (1 document per measurement).

# Note: Shell is required here, as Compass does not surface system collections

mongo $MDB_CONNECT_URI --eval '
db = db.getSiblingDB("TSDEMO")
db.system.buckets.rocketSensors.findOne()
'

