require 'hashie/mash'

# This class adapts the openweathermap.org response to our internal model.
class Weather
  # The wind.degrees value gives the direction the wind is coming _from_.
  # We want to show an arrow depicting the direction of the wind, so, pointing
  # in the opposite direction.
  DIRECTIONS_TO_MATERIAL_ICON_KEYS = {
    'N'  => 'south',
    'NE' => 'south_west',
    'E'  => 'west',
    'SE' => 'north_west',
    'S'  => 'north',
    'SW' => 'north_east',
    'W'  => 'east',
    'NW' => 'south_east',
  }

  attr_reader :response

  def initialize(weather_response)
    @response = Hashie::Mash.new(weather_response)
  end

  def cached?
    response.cached
  end

  def city
    response.name
  end

  def conditions
    response.weather.first.main
  end

  def high
    response.main.temp_max.round
  end

  def humidity
    response.main.humidity
  end

  def low
    response.main.temp_min.round
  end

  def pressure
    response.main.pressure
  end

  def temperature
    response.main.temp.round
  end

  def wind_direction_icon
    DIRECTIONS_TO_MATERIAL_ICON_KEYS[closest_direction]
  end

  def wind_speed
    @response.wind.speed
  end

  private

  # There are only 8 material icon arrows representing the cardinal and
  # ordinal directions. We need to translate the wind direction degrees
  # (0 to 365) into a hash key for the DIRECTIONS_TO_MATERIAL_ICON_KEYS.
  def closest_direction
    DIRECTIONS_TO_MATERIAL_ICON_KEYS.keys[degrees_to_index]
  end

  def degrees_to_index
    ((@response.wind.deg / 45.0).round) % 8
  end
end
