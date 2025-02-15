class WeatherController < ApplicationController
  def index
    if params[:address]
      @forecast = WeatherService.get_forecast(params[:address])
    end
  end
end