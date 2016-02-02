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

  describe "GET #summary" do
    context "four events over 4 days with default params" do
      before(:each) do
        @event1 = FactoryGirl.create :event, :date => Date.new(2016, 1, 1), :type => 'enter'
        @event2 = FactoryGirl.create :event, :date => Date.new(2016, 1, 2), :type => 'comment'
        @event3 = FactoryGirl.create :event, :date => Date.new(2016, 1, 3), :type => 'highfive'
        @event4 = FactoryGirl.create :event, :date => Date.new(2016, 1, 4), :type => 'leave'
        get :summary, format: :json
      end

      it "returns a summary with 4 dates each with one event type" do
        events_response = JSON.parse(response.body, symbolize_names: true)

        expect(events_response[:events].length).to eql 4

        total_enters = 0
        total_leaves = 0
        total_comments = 0
        total_highfives = 0
        events_response[:events].each do |event|
          total_enters = total_enters + event[:enters]
          total_leaves = total_leaves + event[:leaves]
          total_highfives = total_highfives + event[:highfives]
          total_comments = total_comments + event[:comments]
        end

        expect(total_enters).to eql 1
        expect(total_leaves).to eql 1
        expect(total_highfives).to eql 1
        expect(total_comments).to eql 1
      end

      it { should respond_with 200 }
    end

    context "four events over 4 days filtering across 4 days" do
      before(:each) do
        @event1 = FactoryGirl.create :event, :date => Date.new(2016, 1, 1), :type => 'enter'
        @event2 = FactoryGirl.create :event, :date => Date.new(2016, 1, 2), :type => 'comment'
        @event3 = FactoryGirl.create :event, :date => Date.new(2016, 1, 3), :type => 'highfive'
        @event4 = FactoryGirl.create :event, :date => Date.new(2016, 1, 4), :type => 'leave'
        get :summary, :from => '2016-01-01T00:00:00Z', :to => '2016-01-04T23:59:59Z', :by => 'day', format: :json
      end

      it "returns a summary with 4 dates each with one event type" do
        events_response = JSON.parse(response.body, symbolize_names: true)

        expect(events_response[:events].length).to eql 4

        total_enters = 0
        total_leaves = 0
        total_comments = 0
        total_highfives = 0
        events_response[:events].each do |event|
          total_enters = total_enters + event[:enters]
          total_leaves = total_leaves + event[:leaves]
          total_highfives = total_highfives + event[:highfives]
          total_comments = total_comments + event[:comments]
        end

        expect(total_enters).to eql 1
        expect(total_leaves).to eql 1
        expect(total_highfives).to eql 1
        expect(total_comments).to eql 1
      end

      it { should respond_with 200 }
    end

    context "four events over 4 hours" do
      before(:each) do
        @event1 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 1, 0, 0), :type => 'enter'
        @event2 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 2, 0, 0), :type => 'comment'
        @event3 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 3, 0, 0), :type => 'highfive'
        @event4 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 0, 0), :type => 'leave'
        get :summary, :from => '2016-01-01T00:00:00Z', :to => '2016-01-01T23:59:59Z', :by => 'hour', format: :json
      end

      it "returns a summary with 4 date times each with one event type" do
        events_response = JSON.parse(response.body, symbolize_names: true)

        expect(events_response[:events].length).to eql 4

        total_enters = 0
        total_leaves = 0
        total_comments = 0
        total_highfives = 0
        events_response[:events].each do |event|
          total_enters = total_enters + event[:enters]
          total_leaves = total_leaves + event[:leaves]
          total_highfives = total_highfives + event[:highfives]
          total_comments = total_comments + event[:comments]
        end

        expect(total_enters).to eql 1
        expect(total_leaves).to eql 1
        expect(total_highfives).to eql 1
        expect(total_comments).to eql 1
      end

      it { should respond_with 200 }
    end

    context "four events over 4 minutes" do
      before(:each) do
        @event1 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 1, 0), :type => 'enter'
        @event2 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 2, 0), :type => 'comment'
        @event3 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 3, 0), :type => 'highfive'
        @event4 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 4, 0), :type => 'leave'
        get :summary, :from => '2016-01-01T00:00:00Z', :to => '2016-01-01T23:59:59Z', :by => 'minute', format: :json
      end

      it "returns a summary with 4 date times each with one event type" do
        events_response = JSON.parse(response.body, symbolize_names: true)

        expect(events_response[:events].length).to eql 4

        total_enters = 0
        total_leaves = 0
        total_comments = 0
        total_highfives = 0
        events_response[:events].each do |event|
          total_enters = total_enters + event[:enters]
          total_leaves = total_leaves + event[:leaves]
          total_highfives = total_highfives + event[:highfives]
          total_comments = total_comments + event[:comments]
        end

        expect(total_enters).to eql 1
        expect(total_leaves).to eql 1
        expect(total_highfives).to eql 1
        expect(total_comments).to eql 1
      end

      it { should respond_with 200 }
    end

    context "four events over 2 minutes" do
      before(:each) do
        @event1 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 1, 0), :type => 'enter'
        @event2 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 1, 18), :type => 'comment'
        @event3 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 4, 0), :type => 'highfive'
        @event4 = FactoryGirl.create :event, :date => DateTime.new(2016, 1, 1, 4, 4, 15), :type => 'leave'
        get :summary, :from => '2016-01-01T00:00:00Z', :to => '2016-01-01T23:59:59Z', :by => 'minute', format: :json
      end

      it "returns a summary with 4 date times each with one event type" do
        events_response = JSON.parse(response.body, symbolize_names: true)

        expect(events_response[:events].length).to eql 2

        total_enters = 0
        total_leaves = 0
        total_comments = 0
        total_highfives = 0
        events_response[:events].each do |event|
          total_enters = total_enters + event[:enters]
          total_leaves = total_leaves + event[:leaves]
          total_highfives = total_highfives + event[:highfives]
          total_comments = total_comments + event[:comments]
        end

        expect(total_enters).to eql 1
        expect(total_leaves).to eql 1
        expect(total_highfives).to eql 1
        expect(total_comments).to eql 1
      end

      it { should respond_with 200 }
    end

    context "invalid to/from/by parameters" do
      before(:each) do
        get :summary, :from => 'XXXXX', :to => 'XXXX', :by => 'second', format: :json
      end

      it "renders an errors json" do
        event_response = JSON.parse(response.body, symbolize_names: true)
        expect(event_response).to have_key(:errors)
      end

      it "renders the json errors on why the params are invalid" do
        event_response = JSON.parse(response.body, symbolize_names: true)
        expect(event_response[:errors][:to]).to eql "Invalid 'to' date"
        expect(event_response[:errors][:from]).to eql "Invalid 'from' date"
        expect(event_response[:errors][:by]).to eql "Expected 'day', 'hour', or 'minute"
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
