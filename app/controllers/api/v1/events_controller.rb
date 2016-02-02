require 'date'

ROUND_MINS = 100
ROUND_HOURS = 10000
ROUND_DAYS = 1000000

class Api::V1::EventsController < ApplicationController
  wrap_parameters false
  respond_to :json

  def show
    @event = Event.find(params[:id])
    respond_with(@event)
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
        render json: { status: "error" }, status: 400
        return
      end

      @events = Event.where("date >= '%s' and date <= '%s'" % [fromDate.strftime('%F %T.%6N'), toDate.strftime('%F %T.%6N')]).sort_by &:date
    else
      @events = Event.all.sort_by &:date
    end

    respond_with(@events)
  end

  def summary
    errors = nil
    fromDate = nil
    toDate = nil
    by = 'day'

    if params[:from].present? && params[:to].present?
      begin
        fromDate = DateTime.strptime(params[:from],'%FT%TZ')
      rescue ArgumentError
        errors = { errors: {from: "Invalid 'from' date"}}
      end

      begin
        toDate = DateTime.strptime(params[:to],'%FT%TZ')
      rescue ArgumentError
        msg = "Invalid 'to' date"
        if errors == nil
          errors = { errors: { to: msg} }
        else
          errors[:errors]['to'] = msg
        end
      end
    end

    if params[:by].present?
      by = params[:by]
      if by != 'day' && by != 'hour' && by != 'minute'
        msg = "Expected 'day', 'hour', or 'minute"
        if errors == nil
          errors = { errors: { by: msg}}
        else
          errors[:errors]['by'] = msg
        end
      end
    end

    if errors != nil
      render json: { status: "error" }, status: 400
      return
    end

    filter = ""
    if fromDate != nil && toDate != nil
      filter = "where date >= '%s' and date <= '%s'" % [fromDate.strftime('%F %T.%6N'), toDate.strftime('%F %T.%6N')]
    end

    date_rounder = ROUND_DAYS
    case by
    when'hour'
      date_rounder = ROUND_HOURS
    when 'minute'
      date_rounder = ROUND_MINS
    end

    records = Event.connection.select_all("select (cast(strftime('%Y%m%d%H%M%S',date) as integer) / #{date_rounder}) * #{date_rounder} as timeframe,"\
                                            "sum(case when type = 'comment' then 1 else 0 end) as comments,"\
                                            "sum(case when type = 'highfive' then 1 else 0 end) as highfives,"\
                                            "sum(case when type = 'enter' then 1 else 0 end) as enters,"\
                                            "sum(case when type = 'leave' then 1 else 0 end) as leaves from events " + filter + " group by timeframe")

    results = Array.new()

    records.each do |record|
      #Format the timeframe into the rolled up date format and add to the results array
      record[:date] = DateTime.strptime(record['timeframe'].to_s,'%Y%m%d%H%M%S').strftime('%FT%TZ')

      #Exclude the original timeframe key
      results.push(record.except('timeframe'))
    end

    render json: { events: results }, status: 200
  end

  def clear
    Event.delete_all
    render json: { status: "ok" }, status: 200
  end

  def create
    event = Event.new(event_params)
    if event.save
      render json: { status: "ok" }, status: 200, location: [:api, event]
    else
      render json: { status: "error" }, status: 422
    end
  end

  private

    def event_params
      params.permit(:user, :date, :type, :otheruser, :message)
    end
end
