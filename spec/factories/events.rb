FactoryGirl.define do
  factory :event do
    user { FFaker::Name.name }
    type "comment"
    message { FFaker::Lorem.sentence }
    otheruser ""
    date FFaker::Time.date()
  end
end