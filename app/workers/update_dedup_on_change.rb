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

      logger.info("Updating Bookmarks (old_dedup=#{old_dedup}) (new_dedup=#{new_dedup}) ...")

      update_count = 0
      Bookmark.transaction do
        bookmarks_to_be_updated = Bookmark.where(:document_id => old_dedup)
        update_count = bookmarks_to_be_updated.count
        bookmarks_to_be_updated.each do |bookmark|
          logger.info("Updating Bookmark (id=#{bookmark.id}) (old_dedup=#{old_dedup}) (new_dedup=#{new_dedup}) ...")
          begin
            bookmark.document_id = new_dedup
            bookmark.save!
            logger.info("Bookmark (id=#{bookmark.id}) updated!")
          rescue Exception => e
            logger.info("Update of Bookmark (id=#{bookmark.id}) failed!")
            raise e
          end
        end
      end

      logger.info("Updated a total of #{update_count} Bookmarks (old_dedup=#{old_dedup}) (new_dedup=#{new_dedup})!")

      return ack!
    rescue Exception => e
      logger.error("Failed to process message:'#{message}'. Transaction rolled back. Exception thrown: #{e.class} (exception message: #{e.message}) (exception backtrace: #{e.backtrace}).")
      return reject!
    end
  end
end
