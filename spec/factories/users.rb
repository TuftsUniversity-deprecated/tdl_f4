require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence :username do |n|
      "user#{User.count}_#{n}"
    end
    password 'password'    
  end
end
