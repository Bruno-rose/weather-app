require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  describe '.get_forecast' do
    let(:valid_address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
    let(:invalid_address) { 'Invalid Address' }

    context 'with a valid address' do
      it 'returns forecast data' do
        allow(Geocoder).to receive(:coordinates).with(valid_address).and_return([37.4223, -122.0846])

        mock_response = double('Net::HTTPSuccess', is_a?: true, body: '{
          "main": {
            "temp": 15.0,
            "temp_max": 20.0,
            "temp_min": 10.0
          }
        }')
        allow(Net::HTTP).to receive(:get_response).and_return(mock_response)

        forecast = WeatherService.get_forecast(valid_address)

        expect(forecast).not_to be_nil
        expect(forecast[:main][:temp]).to eq(15.0)
        expect(forecast[:main][:temp_max]).to eq(20.0)
        expect(forecast[:main][:temp_min]).to eq(10.0)
      end
    end

    context 'with an invalid address' do
      it 'returns nil' do
        allow(Geocoder).to receive(:coordinates).with(invalid_address).and_return(nil)

        forecast = WeatherService.get_forecast(invalid_address)

        expect(forecast).to be_nil
      end
    end

    context 'with cached data' do
      it 'returns cached forecast' do
        allow(Geocoder).to receive(:coordinates).with(valid_address).and_return([37.4223, -122.0846])

        cached_forecast = { main: { temp: 15.0, temp_max: 20.0, temp_min: 10.0 }, cached: true }
        allow(Rails.cache).to receive(:read).and_return(cached_forecast)

        forecast = WeatherService.get_forecast(valid_address)

        expect(forecast).not_to be_nil
        expect(forecast[:cached]).to be true
        expect(forecast[:main][:temp]).to eq(15.0)
      end
    end
  end
end