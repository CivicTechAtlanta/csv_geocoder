require 'csv'
require 'geocoder'

class CSVGeocoder

  attr_accessor :csv, :address_label

  def initialize(file)
    @address_label = 'Address'
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
    addr_index = get_address_index
    @csv.map do |row|
      row[addr_index]
    end
  end

  def get_lat_lng(address)
    return nil if skip_address?(address)
    sleep 0.25
    gc = Geocoder.search(address)
    gc.first.geometry['location'] if gc
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
      else this_lat_lng
        row << "#{this_lat_lng["lat"]}" << "#{this_lat_lng["lng"]}"
      end
    end
  end
end
