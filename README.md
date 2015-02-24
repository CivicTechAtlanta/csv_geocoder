CSV Geocoder
============

Adds latitude and longitude information to your CSV file.

Usage
-----

    some_data = CSVGeocoder.new 'some_data.csv'
    some_data.add_geocode
    some_data.write 'data_with_geocode.csv'

Alternately, you may chain the methods:

    CSVGeocoder.new('some_data.csv').add_geocode.write 'data_with_geocode.csv'

Specify Address Label
---------------------

The label for the address column is assumed to be 'Address' by default. If it is not, you can specify the column name in the initializer like this:

    some_data = CSVGeocoder.new 'some_data.csv', 'street address'

The address label is case insensitive.

Delay
-----

CSV Geocoder runs on an artificial delay to avoid API query limits. The delay is set to 0.21 because Google's current limit is 5 queries per second. You can change the delay manually like this:

    some_data = CSVGeocoder.new 'some_data.csv'
    some_data.delay = 0.15
    some_data.write 'data_with_geocode.csv'