require 'json'

class UpdateDedupOnChange
  include Sneakers::Worker
  from_queue :findit_dedup_changes,
             :durable => true,
             :ack => true

  def work(message)
    begin
      dedup_change_message = JSON.parse(message)
      ["oldDedup", "newDedup"].each do |key|
        if dedup_change_message[key].nil? || "" == dedup_change_message[key] || 0 == dedup_change_message[key]
          raise Exception.new("#{key} value must be defined and larger than zero.")
        end
      end
      old_dedup = dedup_change_message["oldDedup"].to_s
      new_dedup = dedup_change_message["newDedup"].to_s

      UpdateBookmarkDocumentId.new(old_dedup, new_dedup, logger).call

      return ack!
    rescue Exception => e
      logger.error("Failed to process message:'#{message}'. Transaction rolled back. Exception thrown: #{e.class} (exception message: #{e.message}) (exception backtrace: #{e.backtrace}).")
      return reject!
    end
  end
end
