FactoryGirl.define do
  factory :event do
    user { FFaker::Name.name }
    type "comment"
    message { FFaker::Lorem.sentence }
    otheruser ""
    date FFaker::Time.date()
  end

  # trait :with_date do
  #   ignore do
  #     date_value FFaker::Time.date()
  #   end
  #
  #   after :create do |event, evaluator|
  #     FactoryGirl.
  #   end
  # end
end