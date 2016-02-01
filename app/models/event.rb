class Event < ActiveRecord::Base
  validates :user, :type, :date, :presence => true

  self.inheritance_column = nil

  #TODO need to validate the date string on an event
  #alias_attribute :type, :event_type

  #TODO restrict invalid post body types to the ones that are specified
end
