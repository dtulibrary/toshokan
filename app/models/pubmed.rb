
# Get document info from Pubmed API given pmid
# See http://www.ncbi.nlm.nih.gov/books/NBK25499/#_chapter4_EFetch_ for documentation
# See http://www.ncbi.nlm.nih.gov/books/NBK25497/#chapter2.Usage_Guidelines_and_Requiremen for usage terms

require 'httparty'

class Pubmed
  include Configured

  def self.get id
    Rails.logger.info "Calling Pubmed API for id #{id}"

    response = HTTParty.get self.url_for(id)
    if response.code == 200
      response
    else
      Rails.logger.warn "Request for Pubmed record on #{id} returned #{response.code}"
      nil
    end
  end

  def self.get_solr_document(id)
    response = self.get(id)
    unless response.nil?
      self.to_solr_document(response)
    end
  end

  private

  def self.url_for id
    sprintf Pubmed.url, {:id => id, :tool => Pubmed.tool, :email => Pubmed.email}
  end

  def self.to_solr_document response
    doc = {}
    fields = SolrDocument.field_semantics

    if (response.has_key?("PubmedArticleSet") &&
      response["PubmedArticleSet"].has_key?("PubmedArticle") &&
      response["PubmedArticleSet"]["PubmedArticle"].has_key?("MedlineCitation") &&
      response["PubmedArticleSet"]["PubmedArticle"]["MedlineCitation"].has_key?("Article"))

      doc[fields[:format]] = "article"
      article = response["PubmedArticleSet"]["PubmedArticle"]["MedlineCitation"]["Article"]

      unless article.nil?
        doc[fields[:title]] = article["ArticleTitle"] if article.has_key?("ArticleTitle")

        if article.has_key?("Journal")
          journal = article["Journal"]

          if journal.has_key?("ISSN")
            doc[fields[:issn]] = []
            journal["ISSN"].each do |v, k|
              if v == "__content__"
                doc[fields[:issn]] << k
              end
            end
          end

          if journal.has_key?("JournalIssue")
            doc[fields[:volume]] = journal["JournalIssue"]["Volume"] if journal["JournalIssue"].has_key?("Volume")
            doc[fields[:issue]] = journal["JournalIssue"]["Issue"] if journal["JournalIssue"].has_key?("Issue")
            if journal["JournalIssue"].has_key?("PubDate") && journal["JournalIssue"]["PubDate"].has_key?("Year")
              doc[fields[:year]] = journal["JournalIssue"]["PubDate"]["Year"]
            end
          end

          if journal.has_key?("Title")
            doc[fields[:jtitle]] = [journal["Title"]]
          end
        end

        if article.has_key?("Pagination") && article["Pagination"].has_key?("MedlinePgn")
          doc[fields[:pages]] = [article["Pagination"]["MedlinePgn"]] unless article["Pagination"]["MedlinePgn"].nil?
        end

        if article.has_key?("ELocationID")
          article["ELocationID"].each do |id|
            if id["EIdType"] == "doi"
              doc[fields[:doi]] = id["__content__"]
            end
          end
        end

        if article.has_key?("Abstract") && article["Abstract"].has_key?("AbstractText")
          doc[fields[:abstract]] = article["Abstract"]["AbstractText"]["__content__"]
        end

        if article.has_key?("AuthorList") && article["AuthorList"].has_key?("Author")
          doc[fields[:author]] = []
          doc[fields[:affiliation]] = []
          authors = article["AuthorList"]["Author"]
          authors = [authors] if authors.is_a?(Hash)
          authors.each do |author|
            if author.has_key?("LastName") && author.has_key?("ForeName")
              doc[fields[:author]] << "#{author['LastName']}, #{author['ForeName']}"
            end
            if author.has_key?("Affiliation")
              doc[fields[:affiliation]] << author['Affiliation']
            end
          end
        end
      end
    end

    doc
  end

end
