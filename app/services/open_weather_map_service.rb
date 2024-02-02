class OpenWeatherMapService
  GEOCODER_CONFIGURATION_ERRORS = [
    SocketError,
    Geocoder::OverQueryLimitError,
    Geocoder::RequestDenied,
    Geocoder::InvalidRequest,
    Geocoder::InvalidApiKey,
    Geocoder::ServiceUnavailable,
  ]
  GEOCODER_MAX_ATTEMPTS = 3
  GEOCODER_RETRY_INTERVAL = 5 # seconds
  OPEN_WEATHER_MAP_URL = "https://api.openweathermap.org/data/2.5/weather"
  RETRY_INCREMENT = 5 # seconds
  WEATHER_MAX_ATTEMPTS = 3

  attr_reader :city

  def initialize(address)
    @geocoder_tries = 0
    @weather_tries = 0
    @geocoder_sleep = 0
    @weather_sleep = 0
    @city = geocode sanitize(address)
  end

  class << self
    def fetch(address)
      new(address).fetch
    end
  end

  def fetch
    Weather.new(check_cache || write_and_return_cache)
  end

  def check_cache
    cached_response = Rails.cache.read(city.zip)
    cached_response.merge({cached: true}) if cached_response.present?
  end

  def write_and_return_cache
    Rails.cache.write(city.zip, weather_response)
    weather_response
  end

  def weather_response
    @weather_tries += 1

    params = {
      lat: city.latitude,
      lon: city.longitude,
      appid: ENV['OPENWEATHERMAP_KEY'],
      units: 'imperial',
    }

    @weather_response ||= JSON.parse(HTTParty.get(OPEN_WEATHER_MAP_URL, query: params))
  rescue Net::OpenTimeout => e
    Rails.logger.warn "OpenWeatherMapService#weather_response: call timed out retrying - attempt #{@weather_tries}"

    if @weather_tries < WEATHER_MAX_ATTEMPTS
      sleep @weather_sleep += RETRY_INCREMENT
      weather_response
    else
      Rails.logger.error "OpenWeatherMapService#wether_response: #{e.message}"
      Rails.logger.error "Connection timed out while attempting to open a connection."
      Rails.logger.debug e.backtrace.join("\n")

      raise
    end
  rescue Net::ReadTimeout => e
    Rails.logger.warn "OpenWeatherMapService#weather_response: call timed out retrying - attempt #{@weather_tries}"

    if @weather_tries < WEATHER_MAX_ATTEMPTS
      sleep @weather_sleep += RETRY_INCREMENT
      weather_response
    else
      Rails.logger.error "OpenWeatherMapService#wether_response: #{e.message}"
      Rails.logger.error "Connection established, but the server took too long to respond."
      Rails.logger.debug e.backtrace.join("\n")

      raise
    end
  rescue => e
    Rails.logger.info "OpenWeatherMapService#weather_response: problem encountered while querying the weather api: #{e}"
    raise WeatherServiceError.new("weather lookup failed, #{e}")
  end

  private

  # Returning the first result `.first` is okay for a start, but we should return
  # the list and allow the user to choose which location they were looking for.
  def geocode(address)
    @geocoder_tries += 1
    Geocoder.search(address).first  
  rescue Timeout::Error => e
    Rails.logger.warn "OpenWeatherMapService#geocode: call timed out retrying - attempt #{@geocoder_tries}"

    if @geocoder_tries < GEOCODER_MAX_ATTEMPTS
      sleep @geocoder_sleep += RETRY_INCREMENT
      geocode(address)
    else
      Rails.logger.error "OpenWeatherMapService#geocode: #{e.message}"
      Rails.logger.debug e.backtrace.join("\n")

      raise
    end
  rescue *GEOCODER_CONFIGURATION_ERRORS => e
    Rails.logger.fatal "OpenWeatherMapService#geocode: #{e.message}"
    Rails.logger.debug e.backtrace.join("\n")

    raise
  rescue => e
    Rails.logger.warn "OpenWeatherMapService#geocode: #{e.message}"
    raise GeocoderError.new("address not found, #{e}")
  end

  def sanitize(address)
    address.gsub(/[^0-9a-z\s,.-]/i, '')
  end

  class GeocoderError < StandardError; end
  class WeatherServiceError < StandardError; end
end
