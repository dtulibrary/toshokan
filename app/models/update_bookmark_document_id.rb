class UpdateBookmarkDocumentId
  def initialize(old_dedup, new_dedup, logger = nil)
    null_logger = Object.new; null_logger.define_singleton_method(:info, lambda { |_| })
    @logger = logger || null_logger

    @old_dedup = old_dedup
    @new_dedup = new_dedup
  end
  attr_reader :old_dedup, :new_dedup, :logger

  def call
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
        rescue => e
          logger.info("Update of Bookmark (id=#{bookmark.id}) failed!")
          raise e
        end
      end
    end

    logger.info("Updated a total of #{update_count} Bookmarks (old_dedup=#{old_dedup}) (new_dedup=#{new_dedup})!")
  end
end
