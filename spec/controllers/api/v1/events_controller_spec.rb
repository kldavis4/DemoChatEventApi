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

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        @event_attributes = FactoryGirl.attributes_for :event
        post :create, @event_attributes, format: :json
      end

      it "renders the json representation for the event record just created" do
        event_response = JSON.parse(response.body, symbolize_names: true)
        expect(event_response[:status]).to eql "ok"
      end

      it { should respond_with 200 }
    end

    context "when is not created" do
      before(:each) do
        #notice I'm not including the user
        @invalid_event_attributes = { message: "This is a test" }
        post :create, @invalid_event_attributes, format: :json
      end

      it "renders an errors json" do
        event_response = JSON.parse(response.body, symbolize_names: true)
        expect(event_response).to have_key(:errors)
      end

      it "renders the json errors on why the event could not be created" do
        event_response = JSON.parse(response.body, symbolize_names: true)
        expect(event_response[:errors][:user]).to include "can't be blank"
        expect(event_response[:errors][:type]).to include "can't be blank"
        expect(event_response[:errors][:date]).to include "can't be blank"
      end

      it { should respond_with 422 }
    end
  end
end
