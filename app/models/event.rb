class Event < ActiveRecord::Base
  validates :user, :type, :date, :presence => true

  self.inheritance_column = nil

  #TODO need to validate the date string on an event
  #alias_attribute :type, :event_type

  #TODO probably need to allow message to be null and do a null. blank messages could be a valid test input
  # def as_json(options = {})
  #   json = {:date => date, :type => event_type, :user => user} # whatever info you want to expose
  #   if message != ""
  #     json[:message] = message
  #   end
  #   if otheruser != ""
  #     json[:otheruser] = otheruser
  #   end
  #   json
  # end
end
