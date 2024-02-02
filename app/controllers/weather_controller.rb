class WeatherController < ApplicationController

  # OpenWeatherMapService calls 2 external apis, so this should probably be 
  # refactored from a direct call into a background job. 
  # We would then display a spinner to the user and update the client once we
  # have a result via TurboStreams or old fashioned polling.
  def index
    @address = params[:address]

    if @address.present?
      logger.debug "WeatherController#index: address submitted - #{@address}"
      @weather = OpenWeatherMapService.fetch @address
    end

  rescue => e
    Honeybadger.notify e
    flash.now[:error] = e.message
  end
end
