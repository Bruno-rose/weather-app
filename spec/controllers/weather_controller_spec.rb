require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe 'GET #index' do
    context 'with a valid address' do
      it 'assigns @forecast and renders the index template' do
        forecast = { main: { temp: 15.0, temp_max: 20.0, temp_min: 10.0 }, cached: false }

        allow(WeatherService).to receive(:get_forecast).and_return(forecast)

        get :index, params: { address: '1600 Amphitheatre Parkway, Mountain View, CA' }

        expect(assigns(:forecast)).to eq(forecast)
        expect(response).to render_template(:index)
      end
    end

    context 'with an invalid address' do
      it 'does not assign @forecast' do
        allow(WeatherService).to receive(:get_forecast).and_return(nil)

        get :index, params: { address: 'Invalid Address' }

        expect(assigns(:forecast)).to be_nil
        expect(response).to render_template(:index)
      end
    end
  end
end
