class Api::V1::EventsController < ApplicationController
  wrap_parameters false
  respond_to :json

  def show
    respond_with Event.find(params[:id])
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

  private

    def event_params
      params.permit(:user, :date, :type, :otheruser, :message)
    end
end
