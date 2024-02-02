require 'rails_helper'

RSpec.describe Weather, type: :model do
  describe '.new' do
    it 'maps an api response hash to a weather object' do
      api_response = JSON.parse('{"coord":{"lon":-97.1131,"lat":33.2346},"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],"base":"stations","main":{"temp":69.85,"feels_like":68.7,"temp_min":67.75,"temp_max":71.74,"pressure":1023,"humidity":46},"visibility":10000,"wind":{"speed":4.61,"deg":140},"clouds":{"all":0},"dt":1706725371,"sys":{"type":2,"id":2091273,"country":"US","sunrise":1706707506,"sunset":1706745506},"timezone":-21600,"id":0,"name":"Denton","cod":200}')
      subject = Weather.new(api_response.merge({ cached: true }))
      expect(subject.cached?).to be true
      expect(subject.city).to eq "Denton"
      expect(subject.conditions).to eq "Clear"
      expect(subject.high).to eq 72
      expect(subject.humidity).to eq 46
      expect(subject.low).to eq 68
      expect(subject.pressure).to eq 1023
      expect(subject.temperature).to eq 70
      expect(subject.wind_direction_icon).to eq "north_west"
      expect(subject.wind_speed).to eq 4.61 

    api_response = JSON.parse('{"coord":{"lon":-123.1193,"lat":49.2497},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"base":"stations","main":{"temp":55.18,"feels_like":54.12,"temp_min":50.29,"temp_max":58.44,"pressure":997,"humidity":79},"visibility":10000,"wind":{"speed":15.01,"deg":100},"clouds":{"all":100},"dt":1706729190,"sys":{"type":2,"id":2011597,"country":"CA","sunrise":1706715938,"sunset":1706749558},"timezone":-28800,"id":6173331,"name":"Vancouver","cod":200}')
      subject = Weather.new(api_response.merge({ cached: true }))
      expect(subject.cached?).to be true
      expect(subject.city).to eq "Vancouver"
      expect(subject.conditions).to eq "Clouds"
      expect(subject.high).to eq 58
      expect(subject.humidity).to eq 79
      expect(subject.low).to eq 50
      expect(subject.pressure).to eq 997
      expect(subject.temperature).to eq 55
      expect(subject.wind_direction_icon).to eq "west"
      expect(subject.wind_speed).to eq 15.01
    end
  end

  describe '#wind_direction_icon' do
    it 'translates degrees to material icon keys' do
      {
        12 => 'south',
        42 => 'south_west',
        90 => 'west',
        91 => 'west',
        185 => 'north',
        209 => 'north_east',
        271 => 'east',
        315 => 'south_east',
        355 => 'south',
      }.each_pair do |deg, direction|
        subject = Weather.new({ wind: { deg: deg } })
        expect(subject.wind_direction_icon).to eq direction
      end
    end
  end
end
