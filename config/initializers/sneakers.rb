$LOAD_PATH.push("app/workers")

require 'sneakers'
require 'update_dedup_on_change'

Sneakers.configure({
  :amqp => Rails.application.config.dedup_changes_mq[:amqp_url],
  :exchange => 'dedup_changes',
  :exchange_options => {
    :type => :fanout,
    :durable => true,
    :auto_delete => false
  },
  :workers => 1,
  :prefetch => 1,
  :threads => 1
})

Sneakers.logger.level = Logger::INFO

$WORKERS = [UpdateDedupOnChange]
