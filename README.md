CSV Geocoder
============

Adds latitude and longitude information to your CSV file.

Usage
-----

    csv_file = CSVGeocoder.new 'origfile.csv'
    csv_file.address_label = "Street Address" # optional, defaults to "Address"
    csv_file.write_csv_with_geocode 'newfile.csv'