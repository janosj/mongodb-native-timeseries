source ../../demo.conf

# Adds date truncation and the binSize parameter
# to allow group by arbitrary time buckets.
# The bucket size is hardcoded at 1 second.

mongosh $MDB_CONNECT_URI --eval '

config.set("displayBatchSize", 100);

db = db.getSiblingDB("TSDEMO");

db.satellite.aggregate([

  // Stage 1: Sort
  // Using the $last operator, which is not meaningful unless data is sorted.
  // Looking at all data. For most use cases you would first filter by time window.
  {
    $sort : {
       timestamp: 1
    }
  }

  // Stage 2: Group By
  , {
    $group : {
        _id: {
           timeBin: {
              $dateTrunc: {
                 date: "$timestamp", unit: "millisecond", binSize: 1000
              }
           }
        }
        // Be careful here to operate at the desired level of the document.
        // The last value of a subdocument is not the same thing as the last
        // values of that subdocuments attributes.
        //,extParty : { $last: "$extParty" }
        , position : { $last: "$extParty.position" }
        , velocity : { $last: "$extParty.velocity" }
        , infrequentReading : { $last: "$extParty.infrequent_reading" }
    }
  }

  , {
    $fill: {
      sortBy: { "_id.timeBin": 1 },
      output: {
        "infrequentReading": { method: "locf" }
      }
    }
  }

  , {
    $densify: {
      field: "_id.timeBin",
      //partitionByFields: ,
      range: {
        bounds: "full",
        step: 1,
        unit: "second"
      }
    }
  }

  , {
    $addFields: {
      timestamp: "$_id.timeBin"
    }
  }

  , { $out: "resultsNoGaps" } 

 ])

'

echo "Almost there."
echo "Check 'resultsNoGaps' collection for output."
echo "Note that where previously there were gaps, there are now documents."
echo "Still To Do: the newly added documents are blank."

