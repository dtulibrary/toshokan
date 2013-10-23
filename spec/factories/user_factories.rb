FactoryGirl.define do
  factory :user do
    factory :anonymous_user do
      skip_create

      factory :walk_in_user do
        after :build do |user|
          user.stub(:walk_in).and_return true
        end
      end
    end

    factory :logged_in_user do
      provider 'cas'
      identifier '1234' 

      factory :public_user do
      end

      factory :dtu_user do
        factory :dtu_employee do
        end

        factory :dtu_student do
        end
      end
    end
  end
end
