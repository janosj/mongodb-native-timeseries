
# Display bucketing information.


mongosh $MDB_CONNECT_URI --eval '
db = db.getSiblingDB("TSDEMO")
db.weather.stats()
'

