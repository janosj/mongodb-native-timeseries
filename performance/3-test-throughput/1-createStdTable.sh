source demo.conf

# Create a standard collection
# Required if sharding

mongosh $MDB_CONNECT_URI --eval '

db = db.getSiblingDB("stars"); 

db.telemetry.drop();

db.createCollection(
    "telemetry"
)

'

