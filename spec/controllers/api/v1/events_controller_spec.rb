require 'spec_helper'

describe Api::V1::EventsController do
  before(:each) { request.headers['Accept'] = "application/vnd.events.v1" }

  describe "GET #show" do
    before(:each) do
      @event = FactoryGirl.create :event
      get :show, id: @event.id, format: :json
    end

    it "returns the information about an event on a hash" do
      event_response = JSON.parse(response.body, symbolize_names: true)
      expect(event_response[:user]).to eql @event.user
    end

    it { should respond_with 200 }
  end

  describe "GET #index" do
    context "two events and no filter" do
      before(:each) do
        @event1 = FactoryGirl.create :event
        @event2 = FactoryGirl.create :event
        get :index, format: :json
      end

      it "returns all events" do
        events_response = JSON.parse(response.body, symbolize_names: true)
        expect(events_response[:events].length).to eql 2
      end

      it { should respond_with 200 }
    end

    context "three events selecting one with filter" do
      before(:each) do
        @event1 = FactoryGirl.create :event, :date => Date.new(2016, 1, 1)
        @event2 = FactoryGirl.create :event, :date => Date.new(2016, 1, 2)
        @event3 = FactoryGirl.create :event, :date => Date.new(2016, 1, 3)
        get :index, :from => '2016-01-02T00:00:00Z', :to => '2016-01-02T23:59:59Z', format: :json
      end

      it "returns single filtered event" do
        events_response = JSON.parse(response.body, symbolize_names: true)
        expect(DateTime.strptime(events_response[:events][0][:date],'%FT%TZ')).to eql Date.new(2016, 1, 2)
        expect(events_response[:events].length).to eql 1
      end

      it { should respond_with 200 }
    end

    context "invalid to/from parameters" do
      before(:each) do
        get :index, :from => 'XXXXX', :to => 'XXXX', format: :json
      end

      it "renders an errors json" do
        event_response = JSON.parse(response.body, symbolize_names: true)
        expect(event_response).to have_key(:errors)
      end

      it "renders the json errors on why the params are invalid" do
        event_response = JSON.parse(response.body, symbolize_names: true)
        expect(event_response[:errors][:to]).to eql "Invalid 'to' date"
        expect(event_response[:errors][:from]).to eql "Invalid 'from' date"
      end

      it { should respond_with 400 }
    end
  end

  describe "POST #clear" do
    before(:each) do
      post :clear
    end

    it "returns status ok" do
      clear_response = JSON.parse(response.body, symbolize_names: true)
      expect(clear_response[:status]).to eql "ok"
    end

    it "has cleared all events" do
      expect(Event.count(:all)).to eql 0
    end
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
        #notice it is missing type, date, user
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
