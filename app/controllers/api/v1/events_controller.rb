class Api::V1::EventsController < ApplicationController
  respond_to :json

  def show
    respond_with Event.find(params[:id])
  end
end
