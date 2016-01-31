class Event < ActiveRecord::Base
  validates :date, :user, :type, presence: true

  #TODO need to validate the date string on an event
  alias_attribute :type, :event_type

  def as_json(options = {})
    json = {:date => date, :type => event_type, :user => user} # whatever info you want to expose
    if message != ""
      json[:message] = message
    end
    if otheruser != ""
      json[:otheruser] = otheruser
    end
    json
  end
end
