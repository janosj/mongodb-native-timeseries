source demo.conf

# See here:
# https://docs.mongodb.com/manual/reference/command/shardCollection/#mongodb-dbcommand-dbcmd.shardCollection

mongo $MDB_CONNECT_URI --eval "

db = db.getSiblingDB('admin')

// Enable sharding on the database.
// See here:
// https://docs.mongodb.com/manual/reference/method/sh.enableSharding/
// https://docs.mongodb.com/manual/reference/command/enableSharding/#mongodb-dbcommand-dbcmd.enableSharding

db.adminCommand( { enableSharding: 'stars' } )

// Shard the collection.
// See here:
// https://docs.mongodb.com/manual/reference/method/sh.shardCollection/#mongodb-method-sh.shardCollection
// https://docs.mongodb.com/manual/reference/command/shardCollection/#mongodb-dbcommand-dbcmd.shardCollection

// Note: This use the process ID as a shard key, such that each process writes to a different shard.
// Simple to understand, but not a great choice, because the chunks are indivisible and lead to jumbo chunks.
// To see the jumbo chunk flag, run sh.status() and look for the jumbo indicator.
// The default chunk size in MongoDB is 64 MB.
// See here for details: https://docs.mongodb.com/manual/tutorial/clear-jumbo-flag/
// To resolve the issue, refine (or redefine) the shard key to use a better key (e.g. a compound key).

db.adminCommand( { shardCollection: 'stars.telemetry', key: { 'metadata.group': 1, timestamp: 1 }, false, {numInitialChunks:5000} );

// Pre-split the empty collection into 3 chunks.
// Based on a 3-shard configuration, each shard will get 1 chunk.
// Each chunk will grow and grow, without possibility of a split. 
// See here:
// https://docs.mongodb.com/v4.4/reference/command/split/
// https://docs.mongodb.com/manual/reference/command/split/#mongodb-dbcommand-dbcmd.split

//db.adminCommand( { split: 'tsperf.sensorReadings', middle: { process: 1 } } )
//db.adminCommand( { split: 'tsperf.sensorReadings', middle: { process: 2 } } )

// Display sharding config and chunk info
// See here:
// https://docs.mongodb.com/manual/reference/method/sh.status/
// https://docs.mongodb.com/manual/reference/method/db.printShardingStatus/#mongodb-method-db.printShardingStatus
// db.status()
db.printShardingStatus()

"

echo "Sharding setup complete."
echo "See script comments for configuration details."

