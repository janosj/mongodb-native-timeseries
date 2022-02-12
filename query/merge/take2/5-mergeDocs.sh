source ./demo.conf

# Displays points at millisecond granularity.
# Since the timestamp is itself millicsecond granularity,
# no additional date truncating or binning is required.
# Multiple points per millisecond are aggregated into a single $avg measurement.


mongosh $MDB_CONNECT_URI --eval '

config.set("displayBatchSize", 100);

db = db.getSiblingDB("TSDEMO");

db.satellite.aggregate([

  // Stage 1: Group By & Merge
  { 
    $group: { 
        _id: "$timestamp", 
         mergedDoc: { $mergeObjects: "$$ROOT" } 
    } 
  }

  // Stage 2: Sort
  , {
    $sort : {
       _id: 1
    }
  }

  // Stage 3: Project
  , {
    $project : {
       "mergedDoc.metadata": 0,
       "mergedDoc._id": 0
    }
  }

 ])

'
