source ../../demo.conf

# Adds date truncation and the binSize parameter
# to allow group by arbitrary time buckets.
# The bucket size is hardcoded at 20 milliseconds.

mongosh $MDB_CONNECT_URI --eval '

config.set("displayBatchSize", 100);

db = db.getSiblingDB("TSDEMO");

db.satellite.find( { "extParty.infrequent_reading": { $exists: true} } )

'

echo "Done. Those are the system states that have the infrequent reading."

