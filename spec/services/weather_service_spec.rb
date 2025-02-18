require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:valid_address) { '1600 Amphitheatre Parkway, Mountain View, CA' }
  let(:valid_zip) { '94043' }
  let(:coordinates) { [ 37.4223, -122.0846 ] }
  let(:postal_code) { '94043' }
  let(:geocoder_result) {
    double('Geocoder::Result',
      latitude: coordinates[0],
      longitude: coordinates[1],
      postal_code: postal_code
    )
  }
  let(:mock_response) {
    double('Net::HTTPSuccess',
      is_a?: true,
      body: '{"main":{"temp":15.0,"temp_max":20.0,"temp_min":10.0}}')
  }

  describe '.geocode_address' do
    it 'returns coordinates and postal code for valid address' do
      allow(Geocoder).to receive(:search).with(valid_address)
        .and_return([ geocoder_result ])

      result = WeatherService.geocode_address(valid_address)

      expect(result[:coordinates]).to eq(coordinates)
      expect(result[:postal_code]).to eq(postal_code)
    end
  end

  describe '.get_forecast' do
    context 'with address search' do
      before do
        allow(Geocoder).to receive(:coordinates).with(valid_address).and_return(coordinates)
        allow(Net::HTTP).to receive(:get_response).and_return(mock_response)
      end

      it 'returns forecast data for valid address' do
        forecast = WeatherService.get_forecast(valid_address, :address)

        expect(forecast).not_to be_nil
        expect(forecast[:main][:temp]).to eq(15.0)
      end

      it 'includes postal code in the forecast response' do
        allow(Geocoder).to receive(:search).with(valid_address)
          .and_return([ geocoder_result ])

        forecast = WeatherService.get_forecast(valid_address, :address)

        expect(forecast[:postal_code]).to eq(postal_code)
      end
    end

    context 'with zip code search' do
      before do
        allow(Geocoder).to receive(:coordinates).with(valid_zip).and_return(coordinates)
        allow(Net::HTTP).to receive(:get_response).and_return(mock_response)
      end

      it 'returns forecast data for valid zip code' do
        forecast = WeatherService.get_forecast(valid_zip, :zip)

        expect(forecast).not_to be_nil
        expect(forecast[:main][:temp]).to eq(15.0)
      end
    end

    context 'with caching' do
      let(:cached_forecast) {
        { main: { temp: 15.0, temp_max: 20.0, temp_min: 10.0 }, cached: true }
      }

      before do
        allow(Geocoder).to receive(:coordinates).with(valid_zip).and_return(coordinates)
        allow(Rails.cache).to receive(:read).and_return(cached_forecast)
      end

      it 'returns cached forecast when available' do
        forecast = WeatherService.get_forecast(valid_zip, :zip)

        expect(forecast).to eq(cached_forecast)
        expect(forecast[:cached]).to be true
      end
    end
  end
end
