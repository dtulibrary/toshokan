Rails.application.config.to_prepare do
  Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
  Delayed::Worker.destroy_failed_jobs = false
  Delayed::Worker.delay_jobs = Rails.application.config.delay_jobs
  Delayed::Worker.max_attempts = 5
end
