#!/usr/bin/env python3

# Do not change without review data characteristics.
# Setting of 3 produces 2-5 sensor readings per second,
# which works well to demonstrate various features at 1 second resolution.
freqHz = 3

import json
import time
import math
import random

outputFileName = "system_state.json"
outputFile = open(outputFileName, 'w')

numReadings = 1000
numInfrequentConditions = 0
#numReadings = 1000000

timeIncMS = round( 1 / freqHz * 1000 )
print("Simulating {} system states at {} Hz ({} ms)...".format(numReadings, freqHz, timeIncMS))

initialPositionZ = 1
positionInc = 1

print('Generating data...')

sensorReadingDoc =  { "timestamp" : "<replace>",
                      "metadata": { "source": "3rd Party" },
                      "extParty": "<replace>"
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

offlineCount = 0
for x in range(numReadings):

  # See here for how to represent dates in JSON files:
  # https://docs.mongodb.com/manual/reference/mongodb-extended-json/#bson-data-types-and-associated-representations
  # Use str to get quotes around the sensorTimeMS value
  sensorReadingDoc['timestamp'] = { "$date": {"$numberLong": str(sensorTimeMS) } }

  # Introduce some randomness to the timestamps
  sensorTimeMS += ( timeIncMS + random.randrange(-300, 300) )

  # Introduce some gaps
  sensorOffline = random.randrange(0,100)
  if sensorOffline < 5:
    # a 5-second gap
    sensorTimeMS += 5000
    offlineCount += 1

  thisSubDoc = { "position": "<replace>",
                 "velocity": "<replace>",
                 "infrequent_reading": "<replace>" }

  positionReading[0] = random.randrange(6000, 7000, 3)
  positionReading[1] = random.randrange(6000, 7000, 3)
  positionReading[2] += positionInc
  thisSubDoc['position'] = positionReading

  velocityReading[0] = random.randrange(1, 10, 3)
  velocityReading[1] = random.randrange(1, 10, 3)
  velocityReading[2] += positionInc
  thisSubDoc['velocity'] = velocityReading

  # Demonstrate gap filling 
  randomInclude = random.randint(1,10000)
  #print("random value: " + str(randomInclude))
  if randomInclude < 2000:
    #print("Including random value")
    thisSubDoc['infrequent_reading'] = randomInclude
    numInfrequentConditions += 1
  else:
    thisSubDoc.pop("infrequent_reading")

  #print(json.dumps(thisSubDoc))
  sensorReadingDoc['extParty'] = thisSubDoc
  #print(json.dumps(sensorReadingDoc) + "\n")

  #output result
  outputFile.write(json.dumps(sensorReadingDoc) + "\n")

print("Generated: " + str(numReadings) + " system states.")
print("3 Hz produces 2 - 5 readings per second.")
print("Only " + str(numInfrequentConditions) + " of those have the infrequent sensor reading.")
print( str(offlineCount) + " multi-second time gaps were introduced.")

