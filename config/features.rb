
FeatureFlipper.features do
  
  in_state :development do
    feature :alert,        :description => "Journal and search alerts"
    feature :book_suggest, :description => 'Enable users to suggest books for acquistion'
    feature :cant_find_it, :description => 'Display sidebar links to Cant find forms'
  end

  in_state :unstable do
  end

  in_state :staging do
    feature :nal_map, :description => "Show Google Maps for NAL"
    feature :book_suggest, :description => 'Enable users to suggest books for acquistion'
    feature :cant_find_it, :description => 'Display sidebar links to Cant find forms'
  end

  in_state :live do    
    feature :toc,     :description => "Display table of contents on journal records"
  end

end

FeatureFlipper::Config.states = {
  :development => ['development', 'test'].include?(Rails.env),
  :unstable    => ['development', 'test', 'unstable'].include?(Rails.env),
  :staging     => ['development', 'test', 'unstable', 'staging'].include?(Rails.env),
  :live        => true
}
