require 'csv'
require 'geocoder'

class CSVGeocoder

	attr_accessor :csv, :address_label

	def initialize(file)
		@address_label = 'Address'
		set_csv(file)
	end

	def set_csv(file)
		@csv = CSV.read(file)
	end

	def get_address_index
		@csv[0].index(@address_label)
	end

	def get_lat_lng(address)
		return nil if address.nil?
		sleep 0.25
		gc = Geocoder.search(address)
		gc.first.geometry['location'] if gc
	end

	def get_addresses
		addr_index = get_address_index
		@csv.map do |row|
			row[addr_index]
		end
	end

	def get_lat_lngs
		get_addresses.map do |address|
			(address.nil? || address.empty? || (address == @address_label)) ? nil : (get_lat_lng address)
		end
	end

end
