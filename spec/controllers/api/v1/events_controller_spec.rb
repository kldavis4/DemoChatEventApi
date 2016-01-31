require 'spec_helper'

describe Api::V1::EventsController do
  before(:each) { request.headers['Accept'] = "application/vnd.events.v1" }

  describe "GET #show" do
    before(:each) do
      @event = FactoryGirl.create :event
      get :show, id: @event.id, format: :json
    end

    it "returns the information about a reporter on a hash" do
      event_response = JSON.parse(response.body, symbolize_names: true)
      expect(event_response[:user]).to eql @event.user
    end

    it { should respond_with 200 }
  end
end
