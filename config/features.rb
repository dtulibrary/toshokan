
FeatureFlipper.features do
  
  in_state :development do
  	feature :alert, :description => "Journal and search alerts"
  end

  in_state :staging do
  	feature :nal_map, :description => "Show Google Maps for NAL"
  end

  in_state :live do    
  end

end

FeatureFlipper::Config.states = {
  :development => ['development', 'test'].include?(Rails.env),
  :staging 	   => ['development', 'test', 'unstable', 'staging'].include?(Rails.env),
  :live        => true
}