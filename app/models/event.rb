class Event < ActiveRecord::Base
  validates :date, :user, :type, presence: true

  #TODO need to validate the date string on an event
  alias_attribute :type, :event_type
end
