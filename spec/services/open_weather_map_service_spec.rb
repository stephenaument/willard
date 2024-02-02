require 'rails_helper'

RSpec.describe OpenWeatherMapService do
  Geocoder.configure(lookup: :test, ip_lookup: :test)

  Geocoder::Lookup::Test.add_stub(
    "New York, NY", [
      {
        'coordinates'  => [40.7143528, -74.0059731],
        'address'      => 'New York, NY, USA',
        'state'        => 'New York',
        'state_code'   => 'NY',
        'country'      => 'United States',
        'country_code' => 'US',
        'zip'          => '10001'
      }
    ]
  )

  describe '.initialize' do
    it 'geocodes the given address' do
      city = OpenWeatherMapService.new("New York, NY").city
      expect(city.zip).to eq '10001'
      expect(city.latitude).to eq 40.7143528
      expect(city.longitude).to eq -74.0059731
    end

    it 'raises an error for a garbage address' do
      allow(Geocoder).to receive(:search).and_raise(StandardError.new('use an address, please'))
      
      expect { OpenWeatherMapService.new("New Yorky") }.to raise_error OpenWeatherMapService::GeocoderError
    end

    it 'passes along serious errors' do
      allow(Geocoder).to receive(:search).and_raise(Geocoder::OverQueryLimitError)
      
      expect { OpenWeatherMapService.new("New Yorky") }.to raise_error Geocoder::OverQueryLimitError
    end

    it 'retries on timeout errors', :slow do
      tries = 3
      allow(Geocoder).to receive(:search).and_raise(Timeout::Error)
      expect(Geocoder).to receive(:search).exactly(tries).times
      expect { OpenWeatherMapService.new("New Yorky") }.to raise_error Timeout::Error
    end
  end

  describe '.fetch/#fetch' do
    let(:nyc_weather_json) do
      '{"coord":{"lon":-74.006,"lat":40.7143},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"base":"stations","main":{"temp":44.01,"feels_like":40.68,"temp_min":41.45,"temp_max":45.34,"pressure":1014,"humidity":68},"visibility":10000,"wind":{"speed":5.75,"deg":230},"clouds":{"all":100},"dt":1706829649,"sys":{"type":2,"id":2008101,"country":"US","sunrise":1706789192,"sunset":1706825546},"timezone":-18000,"id":5128581,"name":"New York","cod":200}'
    end

    before do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=17a1f98b0b6a151c6ee263d36e0551f8&lat=40.7143528&lon=-74.0059731&units=imperial").
             to_return(status: 200, body: nyc_weather_json, headers: {})
    end

    it 'returns an initialized Weather object' do
      weather = OpenWeatherMapService.fetch("New York, NY")
      expect(weather.city).to eq "New York"
      expect(weather.cached?).to be_falsey
      expect(weather.conditions).to eq "Clouds"
      expect(weather.low).to eq 41
    end

    it 'caches the weather results' do
      allow(Rails).to receive_message_chain('cache.read') { nil } 
      expect(Rails).to receive_message_chain(:cache, write: JSON.parse(nyc_weather_json))
      OpenWeatherMapService.fetch("New York, NY")
    end

    it 'returns a previously cached object' do
      allow(Rails).to receive_message_chain('cache.read') { JSON.parse(nyc_weather_json) } 
      expect(OpenWeatherMapService.fetch("New York, NY").cached?).to be true
    end

    it 'retries on timeout errors', :slow do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=17a1f98b0b6a151c6ee263d36e0551f8&lat=40.7143528&lon=-74.0059731&units=imperial").to_timeout
      tries = 3
      allow(HTTParty).to receive(:get).and_raise(Net::OpenTimeout)
      expect(HTTParty).to receive(:get).exactly(tries).times
      expect { OpenWeatherMapService.fetch("New York, NY") }.to raise_error Net::OpenTimeout
    end
  end
end
