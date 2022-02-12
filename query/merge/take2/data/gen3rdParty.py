#!/usr/bin/env python3

import json
import time
import math
import random

outputFileName = "3rdPartyData.json"
outputFile = open(outputFileName, 'w')

numReadings = 100
#numReadings = 1000000

freqHz = 60
timeIncMS = round( 1 / freqHz * 1000 )
print("Simulating {} readings at {} Hz ({} ms)...".format(numReadings, freqHz, timeIncMS))

initialPositionZ = 1
positionInc = 1

print('Generating data...')

sensorReadingDoc =  { "timestamp" : "<replace>",
                      "metadata": { "source": "3rd Party" },
                      "extParty": {
                        "position": "<replace>",
                        "velocity": "<replace>"
                      }
                    }

# Current time in milliseconds
# startTimeMS = round( time.time_ns() / 1000000 )

# Current time in milliseconds
#startTimeMS = round( time.time_ns() / 1000000 )
startTimeMS = 1644550227638

# print("Time in milliseconds since the epoch:", startTimeMS)

sensorTimeMS = startTimeMS
positionReading = [ 0, 0, 0 ]
velocityReading = [ 0, 0, 0 ]

for x in range(numReadings):

  # See here for how to represent dates in JSON files:
  # https://docs.mongodb.com/manual/reference/mongodb-extended-json/#bson-data-types-and-associated-representations
  # Use str to get quotes around the sensorTimeMS value
  sensorReadingDoc['timestamp'] = { "$date": {"$numberLong": str(sensorTimeMS) } }

  sensorTimeMS += timeIncMS

  positionReading[0] = random.randrange(6000, 7000, 3)
  positionReading[1] = random.randrange(6000, 7000, 3)
  positionReading[2] += positionInc
  sensorReadingDoc['extParty']['position'] = positionReading

  velocityReading[0] = random.randrange(1, 10, 3)
  velocityReading[1] = random.randrange(1, 10, 3)
  velocityReading[2] += positionInc
  sensorReadingDoc['extParty']['velocity'] = velocityReading

  #output result
  outputFile.write(json.dumps(sensorReadingDoc) + "\n")

