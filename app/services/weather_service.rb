require 'net/http'
require 'json'

class WeatherService
  OPENWEATHER_API_URL = 'https://api.openweathermap.org/data/2.5/weather'

  def self.get_forecast(address)
    # Geocode the address to get latitude and longitude
    coordinates = Geocoder.coordinates(address)
    return nil unless coordinates

    # Use Redis to cache the forecast
    cache_key = "weather_#{coordinates.join('_')}"
    cached_forecast = Rails.cache.read(cache_key)

    if cached_forecast
      cached_forecast[:cached] = true
      return cached_forecast
    end

    # Fetch the forecast from OpenWeather API
    uri = URI(OPENWEATHER_API_URL)
    params = {
      lat: coordinates[0],
      lon: coordinates[1],
      units: 'metric',
      appid: ENV['OPENWEATHER_API_KEY']
    }
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      forecast = JSON.parse(response.body, symbolize_names: true)

      # Cache the forecast for 30 minutes
      Rails.cache.write(cache_key, forecast, expires_in: 30.minutes)

      forecast[:cached] = false
      forecast
    else
      nil
    end
  end
end