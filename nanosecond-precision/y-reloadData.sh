# Convenience script.
# Drops existing table and reloads the sensor data.

./z-cleanup.sh
./1-createTable.sh
./2-loadSensorData.sh

