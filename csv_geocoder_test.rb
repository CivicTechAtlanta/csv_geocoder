require 'minitest/spec'
require 'minitest/mock'
require 'minitest/autorun'
require_relative 'csv_geocoder.rb'

describe CSVGeocoder do
  describe "object creation" do
    describe "with one argument" do
      before do
        @arr_of_arr = [['a','b'], ['c','d']]
        CSV.stub :read, @arr_of_arr do
          @csvg = CSVGeocoder.new('art.csv')
        end
      end

      it "sets delay to default" do
        @csvg.delay.must_be :==, 0.21
      end

      it "sets address label to default" do
        @csvg.address_label.must_be :==, 'Address'
      end

      it "sets csv to contents of csv file specified in argument" do
        @csvg.csv.must_be :==, @arr_of_arr
      end
    end

    describe "with two arguments" do
      before do
        @arr_of_arr = [['a','b'], ['c','d']]
        CSV.stub :read, @arr_of_arr do
          @csvg = CSVGeocoder.new('art.csv', 'c')
        end
      end

      it "sets delay to default" do
        @csvg.delay.must_be :==, 0.21
      end

      it "sets address label to second argument" do
        @csvg.address_label.must_be :==, 'c'
      end

      it "sets csv to contents of csv file in first argument" do
        @csvg.csv.must_be :==, @arr_of_arr
      end
    end
  end

  it "can read a new CSV file after creation" do
    @arr_of_arr = [['a','b'], ['c','d']]
    CSV.stub :read, @arr_of_arr do
      @csvg = CSVGeocoder.new('art.csv')
    end

    @new_csv = [['e','f'],['g','h']]
    CSV.stub :read, @new_csv do
      @csvg.read_csv('new.csv')
    end
    @csvg.csv.must_be :==, @new_csv
  end

  it "writes CSV file with new geocode data" do
  end

end