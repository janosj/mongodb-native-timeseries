# Drops sensor readings collection.

source demo.conf

mongo $MDB_CONNECT_URI --eval '
db.getSiblingDB("TSDEMO").weather.drop();
'

