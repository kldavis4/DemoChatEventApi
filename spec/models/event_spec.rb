require 'spec_helper'

describe Event do
  let (:event) { FactoryGirl.build :event }
  subject { event }
  
  it { should respond_to(:user) }
  it { should respond_to(:type) }
  it { should respond_to(:date) }
  it { should respond_to(:message) }
  it { should respond_to(:otheruser) }
  
  it { should validate_presence_of :user }
  it { should validate_presence_of :type }
  it { should respond_to(:date) }
end
