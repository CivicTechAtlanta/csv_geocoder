require 'minitest/spec'
require 'minitest/mock'
require 'minitest/autorun'
require_relative 'csv_geocoder.rb'

describe CSVGeocoder do
  Gcode = Struct.new(:geometry)

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

      it "sets new_csv to nil" do
        @csvg.new_csv.must_be_nil
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

      it "sets new_csv to nil" do
        @csvg.new_csv.must_be_nil
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

  describe "add_geocode" do
    before do
    @arr_of_arr =
      [['a', 'adDrEsS', 'c'],
       ['d', 'e', 'f'],
       ['g', 'h', 'i'],
       ['j', '', 'k'],
       ['l', nil, 'm']]

    @new_csv =
      [['a', 'adDrEsS', 'c', 'Latitude', 'Longitude'],
       ['d', 'e', 'f', 'x', 'y'],
       ['g', 'h', 'i', 'x', 'y'],
       ['j', '', 'k', nil, nil],
       ['l', nil, 'm', nil, nil]]
    end
    describe "with default address label" do
      describe "and address label matches" do
        before do
          CSV.stub :read, @arr_of_arr do
            @csvg = CSVGeocoder.new('art.csv')
            @csvg.delay = 0
          end
        end

        describe "and there were no API errors" do
          before do
            gc = [Gcode.new({'location' => {'lat' => 'x', 'lng' => 'y'}})]
            Geocoder.stub :search, gc do
              @csvg.add_geocode
            end
          end

          it "should set new_csv to csv plus geocode data" do
            @csvg.new_csv.must_be :==, @new_csv
          end

          it "should keep csv unchanged" do
            # to do
          end
        end

        describe "and there were API errors" do
          before do
            gc = [nil]
            err = 'API Error'
            @result =
              [['a', 'adDrEsS', 'c', 'Latitude', 'Longitude'],
               ['d', 'e', 'f', err, err],
               ['g', 'h', 'i', err, err],
               ['j', '', 'k', nil, nil],
               ['l', nil, 'm', nil, nil]]
            Geocoder.stub :search, gc do
              @csvg.add_geocode
            end
          end

          it "should set new_csv to display errors" do
            @csvg.new_csv.must_be :==, @result
          end
        end
      end

      describe "and address label doesn't match" do
        before do
          arr_of_arr = Array.new(@arr_of_arr)
          arr_of_arr[0][1] = "Elephant"
          CSV.stub :read, arr_of_arr do
            @csvg = CSVGeocoder.new('art.csv')
            @csvg.delay = 0
          end
        end

        it "should fail with exception" do
          ->{ @csvg.add_geocode }.must_raise CSVGeocoder::AddressNotFoundError
        end
      end
    end

    describe "with custom address label" do
      describe "and address label matches" do
        before do
          # should be case insensitive, so this should work:
          @address_label = 'elEphAnt'
          arr_of_arr = Array.new(@arr_of_arr)
          arr_of_arr[0][1] = @address_label
          CSV.stub :read, arr_of_arr do
            @csvg = CSVGeocoder.new 'art.csv', 'Elephant'
            @csvg.delay = 0
          end

          @result = Array.new(@new_csv)
          @result[0][1] = @address_label
        end

        describe "and there were no API errors" do
          before do
            gc = [Gcode.new({'location' => {'lat' => 'x', 'lng' => 'y'}})]
            Geocoder.stub :search, gc do
              @csvg.add_geocode
            end
          end

          it "should set new_csv to csv plus geocode data" do
            @csvg.new_csv.must_be :==, @result
          end

          it "should keep csv unchanged" do
            # to do
          end
        end

        describe "and there were API errors" do
          before do
            gc = [nil]
            err = 'API Error'
            @result =
              [['a', @address_label, 'c', 'Latitude', 'Longitude'],
               ['d', 'e', 'f', err, err],
               ['g', 'h', 'i', err, err],
               ['j', '', 'k', nil, nil],
               ['l', nil, 'm', nil, nil]]
            Geocoder.stub :search, gc do
              @csvg.add_geocode
            end
          end

          it "should set new_csv to display errors" do
            @csvg.new_csv.must_be :==, @result
          end
        end

      end

      describe "and address label doesn't match" do
        before do
          # should be case insensitive, so this should work:
          arr_of_arr = Array.new(@arr_of_arr)
          arr_of_arr[0][1] = 'eLePHant'
          CSV.stub :read, @arr_of_arr do
            @csvg = CSVGeocoder.new 'art.csv', 'Rhinoceros'
            @csvg.delay = 0
          end
        end

        it "should set new_csv to csv plus geocode data" do
          ->{ @csvg.add_geocode }.must_raise CSVGeocoder::AddressNotFoundError
        end

        it "should keep csv unchanged" do
          # to do
        end
      end
    end
  end

  describe "write" do
    describe "when geocoded csv has been generated" do
    end

    describe "when geocoded csv has not been generated" do
    end
  end

end