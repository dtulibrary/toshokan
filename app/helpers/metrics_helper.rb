# Most of these methods have moved to Dtu::DocumentPresenter::Metrics
# and Presenter classes in the Dtu::Metrics:: namespace
module MetricsHelper

  # Render the embed script for including altmetric javascript
  def altmetric_embed_script
    Dtu::Metrics::AltmetricPresenter.altmetric_embed_script
  end
end