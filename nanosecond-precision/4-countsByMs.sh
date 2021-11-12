source demo.conf

# Display document counts per millisecond.

# Since timestamp is limited to milliseconds, 
# nanosecond precision will result in multiple
# documents with the same millisecond timestamp.

mongo $MDB_CONNECT_URI --eval '

DBQuery.shellBatchSize=300

db = db.getSiblingDB("TSDEMO");

db.rocketSensors.aggregate([

  // Stage 1: Group By
  {
    $group : {
       _id : "$timestamp" ,
       count: { $sum: 1 }
    }
  }

  // Stage 2: Sort
  ,{
    $sort : {
       _id: 1
    }
  }
 
 ])

'
