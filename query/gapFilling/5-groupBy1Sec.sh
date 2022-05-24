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

  // Stage 3: Sort results
  , {
    $sort : {
       "_id.timeBin": 1
    }
  }

 ])

'

echo "Results show the system state of the simulation every second,"
echo "using the last known value within each 1-second window."
echo "Anywhere multiple documents exist within a window, they have been reduced to a single document."
echo "However, the 'infrequent_reading' may be  reported as NULL if there's no value within in the window."
echo "And, there may be gaps (i.e. no documents) where the sensors went offine for multiple seconds."

