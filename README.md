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
