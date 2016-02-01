class Event < ActiveRecord::Base
  validates :user, :type, :date, :presence => true

  self.inheritance_column = nil

  #TODO need to validate the date string on an event
  #alias_attribute :type, :event_type

  #TODO restrict invalid post body types to the ones that are specified

  def as_json(options={})
    super(:only => [:user, :type, :date, :message, :otheruser])
  end

  def serializable_hash(options)
    super(options).select { |_, v| v }
  end
end
