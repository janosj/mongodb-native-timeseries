#!/usr/bin/env python3

import json
import time
import math

outputFileName = "sensorData.100k.json"
outputFile = open(outputFileName, 'w')

#numReadings = 100
numReadings = 100000

freqHz = 8700
timeIncMS = 1 / freqHz * 1000
timeIncNS = round(timeIncMS * 1000000)
print("Simulating {} readings at {} Hz ({} ms, about every {} nanoseconds)...".format(numReadings, freqHz, timeIncMS,  timeIncNS))

initialReading = 1
readingInc = 1

print('Generating data...')

sensorReadingDoc =  { "timestamp" : "<replace>",
                      "sensorReading": "<replace>",
                      "nano": "<replace>"
                    }

# Current time in nanoseconds
# Works on Python 3.9.7 (mac), but not the version available on RHEL.
startTimeNanoSec = time.time_ns()
# Print the time in nanoseconds since the epoch
# print("Time in nanoseconds since the epoch:", startTimeNanoSec)

sensorTimeNS = startTimeNanoSec
sensorTimeMS = round(startTimeNanoSec / 1000000)
sensorReading = initialReading

for x in range(numReadings):

  # See here for how to represent dates in JSON files:
  # https://docs.mongodb.com/manual/reference/mongodb-extended-json/#bson-data-types-and-associated-representations
  # Use str to get quotes around the sensorTimeMS value
  sensorReadingDoc['timestamp'] = { "$date": {"$numberLong": str(sensorTimeMS) } }

  sensorReadingDoc['nano'] = sensorTimeNS
  sensorReadingDoc['sensorReading'] = sensorReading

  #output result
  outputFile.write(json.dumps(sensorReadingDoc) + "\n")

  sensorTimeNS += timeIncNS
  sensorTimeMS = math.trunc(sensorTimeNS / 1000000)
  sensorReading += readingInc

