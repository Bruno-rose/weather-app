class WeatherController < ApplicationController
  def index
    if params[:address].present?
      @forecast = WeatherService.get_forecast(params[:address], :address)
      @query = params[:address]
    elsif params[:zip].present?
      @forecast = WeatherService.get_forecast(params[:zip], :zip)
      @query = params[:zip]
    end
  end
end
