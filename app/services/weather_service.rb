require 'net/http'
require 'json'

class WeatherService
  OPENWEATHER_API_URL = 'https://api.openweathermap.org/data/2.5/weather'
  CACHE_EXPIRY = 30.minutes

  def self.get_forecast(query, type = :address)
    case type
    when :address
      location_data = geocode_address(query)
    when :zip
      location_data = geocode_zip(query)
    end

    return nil unless location_data && location_data[:coordinates]

    cached_forecast = fetch_from_cache(location_data)
    return cached_forecast if cached_forecast

    fetch_and_cache_forecast(location_data)
  end

  private

  def self.geocode_address(address)
    result = Geocoder.search(address).first
    return nil unless result
    
    {
      coordinates: [result.latitude, result.longitude],
      postal_code: result.postal_code
    }
  end

  def self.geocode_zip(zip)
    result = Geocoder.search(zip).first
    return nil unless result
    
    {
      coordinates: [result.latitude, result.longitude],
      postal_code: result.postal_code
    }
  end

  def self.fetch_from_cache(location_data)
    cache_key = generate_cache_key(location_data[:coordinates])
    cached_forecast = Rails.cache.read(cache_key)
    
    if cached_forecast
      cached_forecast[:cached] = true
      cached_forecast[:postal_code] = location_data[:postal_code]
      cached_forecast
    end
  end

  def self.fetch_and_cache_forecast(location_data)
    response = fetch_from_api(location_data[:coordinates])
    return nil unless response.is_a?(Net::HTTPSuccess)

    forecast = parse_and_cache_response(response, location_data[:coordinates])
    forecast[:postal_code] = location_data[:postal_code]
    forecast[:cached] = false
    forecast
  end

  def self.fetch_from_api(coordinates)
    uri = URI(OPENWEATHER_API_URL)
    uri.query = URI.encode_www_form(api_params(coordinates))
    Net::HTTP.get_response(uri)
  end

  def self.api_params(coordinates)
    {
      lat: coordinates[0],
      lon: coordinates[1],
      units: 'metric',
      appid: ENV['OPENWEATHER_API_KEY']
    }
  end

  def self.parse_and_cache_response(response, coordinates)
    forecast = JSON.parse(response.body, symbolize_names: true)
    cache_key = generate_cache_key(coordinates)
    Rails.cache.write(cache_key, forecast, expires_in: CACHE_EXPIRY)
    forecast
  end

  def self.generate_cache_key(coordinates)
    "weather/#{coordinates.join(',')}"
  end
end