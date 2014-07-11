
FeatureFlipper.features do

  in_state :development do
  end

  in_state :unstable do
    feature :mendeley, :description => "Use Mendeley API instead of Web Importer"
  end

  in_state :staging do
    feature :nal_map, :description => "Show Google Maps for NAL"
  end

  in_state :live do
    feature :book_suggest, :description => 'Enable users to suggest books for acquistion'
    feature :cant_find_it, :description => 'Display sidebar links to Cant find forms'
    feature :alis, :description => "Show loan info from Alis"
    feature :cff_resolver, :description => "Use OpenURL resolver in CFFs"
  end

end

FeatureFlipper::Config.states = {
  :development => ['development', 'test'].include?(Rails.env),
  :unstable    => ['development', 'test', 'unstable'].include?(Rails.env),
  :staging     => ['development', 'test', 'unstable', 'staging'].include?(Rails.env),
  :live        => true
}
