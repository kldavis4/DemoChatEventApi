require 'date'

class Api::V1::EventsController < ApplicationController
  wrap_parameters false
  respond_to :json

  def show
    @event = Event.find(params[:id])
    respond_with(@event)
  end

  def create
    event = Event.new(event_params)
    if event.save
      render json: { status: "ok" }, status: 200, location: [:api, event]
    else
      render json: { errors: event.errors }, status: 422
    end
  end

  def clear
    Event.delete_all
    render json: { status: "ok" }, status: 200
  end

  def index
    if params[:from].present? && params[:to].present?
      errors = nil
      begin
        fromDate = DateTime.strptime(params[:from],'%FT%TZ')
      rescue ArgumentError
        errors = { errors: {from: "Invalid 'from' date"}}
      end

      begin
        toDate = DateTime.strptime(params[:to],'%FT%TZ')
      rescue ArgumentError
        if errors == nil
          errors = { errors: { to: "Invalid 'to' date"} }
        else
          errors[:errors]['to'] = "Invalid 'to' date"
        end
      end

      if errors != nil
        render json: errors, status: 400
        return
      end

      @events = Event.where(["date >= ? and date <= ?", fromDate, toDate]).sort_by &:date
    else
      @events = Event.all.sort_by &:date
    end

    respond_with(@events)
  end

  def summary
    render json: { status: "ok" }, status: 200
  end

  private

    def event_params
      params.permit(:user, :date, :type, :otheruser, :message)
    end
end
