source ../demo.conf

# Create the time series collection

mongo $MDB_CONNECT_URI --eval '

db.weather.findOne()

'

