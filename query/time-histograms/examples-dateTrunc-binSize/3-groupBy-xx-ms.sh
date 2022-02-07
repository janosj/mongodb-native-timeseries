# Uses the binSize parameter of the $dateTrunc aggregation operator
# to return 1 document for every XX numer of milliseconds.
# For example, return 1 document for every 20 milliseconds.
# $avg is used to aggregate multiple values within each time bin.
# If a time bin has no records, no document is returned.


# Fetch the MongoDB connection string
source ../demo.conf


if [ -z "$1" ]; then
    echo "Usage: groupBy-xx-ms.sh <bin-size-in-milliseconds>"
    exit 1
fi


# Used to pass the specified time bin to the javascript function.
export TIME_BIN_MS=$1

mongosh $MDB_CONNECT_URI --file groupBy-xx-ms.js

