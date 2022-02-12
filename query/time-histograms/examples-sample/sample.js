// These timestamps work with the provided json data file.
// If you regenerate the sensorData.json file, adjust as necessary.
start_time = ISODate("2021-11-10T17:13:31.330Z");
end_time   = ISODate("2021-11-10T17:15:27.281Z");

print("Start time: " + start_time);
print("End time  : " + end_time);
print();

NUM_POINTS = parseInt(process.env.NUM_POINTS);
print("Number of data points requested: " + NUM_POINTS);

db = db.getSiblingDB("TSDEMO");

printjson(

  db.rocketSensors.aggregate([

    // Stage 1: filter on the specified time window
    {
      $match: {
        timestamp: { $gte: start_time, $lte: end_time }
      }
    }

    // Stage 2: sample
    , {
      $sample: { size: NUM_POINTS }
    }

    // Stage 3: Sort
    , {
      $sort : {
         _id: 1
      }
    }

  ])

)

