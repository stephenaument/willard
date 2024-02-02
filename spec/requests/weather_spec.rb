require 'rails_helper'

RSpec.describe "Weather", type: :request do
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

  describe "GET /" do
    it "renders the form" do
      get "/"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Willard tells you the weather!")
    end
  end

  describe "GET /?address=10001" do
    let(:nyc_weather_json) do
      '{"coord":{"lon":-74.006,"lat":40.7143},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"base":"stations","main":{"temp":44.01,"feels_like":40.68,"temp_min":41.45,"temp_max":45.34,"pressure":1014,"humidity":68},"visibility":10000,"wind":{"speed":5.75,"deg":230},"clouds":{"all":100},"dt":1706829649,"sys":{"type":2,"id":2008101,"country":"US","sunrise":1706789192,"sunset":1706825546},"timezone":-18000,"id":5128581,"name":"New York","cod":200}'
    end

    before do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=17a1f98b0b6a151c6ee263d36e0551f8&lat=40.7143528&lon=-74.0059731&units=imperial").
             to_return(status: 200, body: nyc_weather_json, headers: {})
    end

    it "displays the results" do
      get "/", params: { address: "New York, NY" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("New York")
      expect(response.body).to include("44")
      expect(response.body).to include("Clouds")
    end
  end
end
