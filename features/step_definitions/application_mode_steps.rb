Given /^the application runs in "(.*?)" mode$/ do |mode|
  Rails.application.config.stub(:application_mode).and_return(mode.to_sym)
end

