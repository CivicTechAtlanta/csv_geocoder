CSV Geocoder
============

Adds latitude and longitude information to your CSV file.

Usage
-----

    csvg = CSVGeocoder.new 'origfile.csv'
    csvg.write_csv_with_geocode 'newfile.csv'

Specify Address Label
---------------------

The label for the address column is assumed to be 'Address' by default. If it is not, you can specify the column name in the initializer like this:

    csvg = CSVGeocoder.new 'origfile.csv', 'street address'

Delay
-----

CSV Geocoder runs on an artificial delay to avoid API query limits. The delay is set to 0.21 because Google's current limit is 5 queries per second. You can change the delay manually like this:

    csvg = CSVGeocoder.new 'origfile.csv'
    csvg.delay = 0.15
    csvg.write_csv_with_geocode 'newfile.csv'