# Shrinks a data set.

# Example: Copy first 100 lines of input file to reduced output file.
sed -n '1,10000p' notCommitted-sensorData.1M.json > sensorData.10k.json

