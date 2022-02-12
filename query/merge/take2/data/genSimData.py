#!/usr/bin/env python3

import json
import time
import math
import random

outputFileName = "simData.json"
outputFile = open(outputFileName, 'w')

numReadings = 100
#numReadings = 1000000

freqHz = 60
timeIncMS = round( 1 / freqHz * 1000 )
print("Simulating {} readings at {} Hz ({} ms)...".format(numReadings, freqHz, timeIncMS))

print('Generating data...')

sensorReadingDoc =  { "timestamp" : "<replace>",
                      "metadata": { "source": "Simulation" },
                      "simData": {
                        "soc": "<replace>",
                        "dissipation": "<replace>",
                        "vBatt": "<replace>",
                        "iBatt": "<replace>",
                        "solarViewFactor": "<replace>"
                      }
                    }

# Current time in milliseconds
#startTimeMS = round( time.time_ns() / 1000000 )
startTimeMS = 1644550227638
# print("Time in milliseconds since the epoch:", startTimeMS)

sensorTimeMS = startTimeMS

for x in range(numReadings):

  # See here for how to represent dates in JSON files:
  # https://docs.mongodb.com/manual/reference/mongodb-extended-json/#bson-data-types-and-associated-representations
  # Use str to get quotes around the sensorTimeMS value
  sensorReadingDoc['timestamp'] = { "$date": {"$numberLong": str(sensorTimeMS) } }

  sensorTimeMS += timeIncMS

  sensorReadingDoc['simData']['soc'] = float(random.randrange(0, 100))/100
  sensorReadingDoc['simData']['dissipation'] = float(random.randrange(0, 100))/100
  sensorReadingDoc['simData']['vBatt'] = float(random.randrange(0, 100))/100
  sensorReadingDoc['simData']['iBatt'] = float(random.randrange(0, 100))/100
  sensorReadingDoc['simData']['solarViewFactor'] = float(random.randrange(0, 100))/100

  #output result
  outputFile.write(json.dumps(sensorReadingDoc) + "\n")

