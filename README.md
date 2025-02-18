# Weather App

A Ruby on Rails application that retrieves and caches weather forecasts for given addresses using the OpenWeather API.

## Features

- Address-based weather lookup
- Postal code (ZIP) based weather lookup
- 30-minute forecast caching by location
- Cache status indicator
- Responsive design for mobile and desktop
- Error handling for invalid addresses/API failures

## Technical Details

### Architecture

The application follows a service-oriented architecture with the following key components:

- **WeatherController**: Handles HTTP requests and coordinates between services
- **ForecastService**: Core service managing weather data retrieval and caching
- **LocationService**: Handles address/zip geocoding
- **Cacheable**: Reusable caching functionality

### Design Patterns

- **Service Objects**: Separates business logic from controllers
- **Concern**: Shared caching behavior via `Cacheable` module
- **Configuration Object**: Centralized config management via `WeatherApp::Configuration`

## Setup

1. Clone the repository
```bash
git clone https://github.com/yourusername/weather-app.git
cd weather-app
```

2. Install dependencies
```bash
bundle install
```

3. Configure environment variables
```bash
cp .env.example .env
# Edit .env and add your OpenWeather API key
```

4. Setup database
```bash
rails db:create db:migrate
```

5. Start the server
```bash
rails server
```

## Testing

The application includes comprehensive test coverage using RSpec:

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/services/weather/forecast_service_spec.rb
```

### Test Coverage

- Controller specs for request handling
- Service specs for business logic
- Integration tests for end-to-end functionality

## Caching Strategy

- Forecasts are cached for 30 minutes using Rails' cache store
- Cache keys are based on geocoded coordinates
- Cache duration is configurable via environment variables
- Visual indicator shows when results are from cache

## API Integration

- Uses OpenWeather API for forecast data
- Geocoding via Geocoder gem
- Configurable API timeout and retry settings
- Error handling for API failures

## Production Deployment

The application includes Docker support for production deployment:

```bash
# Build Docker image
docker build -t weather_app .

# Run container
docker run -p 3000:3000 weather_app
```
