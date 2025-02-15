Geocoder.configure(
  lookup: :nominatim, # Use Nominatim as the geocoding service
  units: :km,         # Use kilometers for distance calculations
  timeout: 3          # Timeout for geocoding service
)
