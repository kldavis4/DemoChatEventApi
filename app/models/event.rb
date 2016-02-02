class Event < ActiveRecord::Base
  #Required fields
  validates :user, :type, :date, :presence => true

  self.inheritance_column = nil

  #Limit fields serialized to (user, type, date, message and otheruser)
  def as_json(options={})
    super(:only => [:user, :type, :date, :message, :otheruser])
  end

  def serializable_hash(options)
    super(options).select { |_, v| v }
  end
end
