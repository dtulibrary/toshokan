FactoryGirl.define do
  factory :ability, :class => Object do
    skip_create

    after :build do |ability|
      ability.extend CanCan::Ability
    end
  end
end
