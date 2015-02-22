require 'csv'
require 'geocoder'
require 'pry'

class CSVGeocoder
  class AddressNotFoundError < ArgumentError; end
  class GeocodingAPIError < StandardError; end
  ADDRESS_NOT_FOUND_MESSAGE = "The address column was not found in the CSV using the address label given."
  GEOCODING_API_ERROR_MESSAGE = "Geocoding API error (probably over query limit)"
  attr_accessor :csv, :address_label, :delay

  def initialize(file, address='Address')
    @address_label = address
    @delay = 0.21
    read_csv(file)
  end

  def read_csv(file)
    @csv = CSV.read(file)
  end

  def write_csv_with_geocode(file)
    merge_csv_with get_lat_lngs
    add_lat_lng_labels
    CSV.open(file, 'wb') do |csv|
      @csv.each do |row|
        csv << row
      end
    end
  end

  protected

  def get_lat_lngs
    get_addresses.map do |address|
      (skip_address? address) ? nil : (get_lat_lng address)
    end
  end

  def add_lat_lng_labels
    @csv[0][-2] = 'Latitude'
    @csv[0][-1] = 'Longitude'
  end

  def get_addresses
    begin
      @csv.map do |row|
        row[get_address_index]
      end
    rescue TypeError => e
      raise AddressNotFoundError, ADDRESS_NOT_FOUND_MESSAGE
    end
  end

  def get_lat_lng(address)
    return nil if skip_address? address
    sleep @delay
    gc = Geocoder.search(address)
    if gc.first.respond_to? :geometry
      gc.first.geometry['location']
    else
      # gc == []
      # this gem doesn't raise or return an error message,
      # just prints to stdout. we'll raise it ourselves:
      raise GeocodingAPIError, GEOCODING_API_ERROR_MESSAGE
    end
  end

  def get_address_index
    @csv[0].index(@address_label)
  end

  def skip_address?(addr)
    addr.nil? || addr.empty? || addr == @address_label
  end

  def merge_csv_with(lat_lng)
    @csv.each do |row|
      this_lat_lng = lat_lng.shift
      if this_lat_lng.nil?
        row << nil << nil
      else
        row << "#{this_lat_lng['lat']}" << "#{this_lat_lng['lng']}"
      end
    end
  end
end
