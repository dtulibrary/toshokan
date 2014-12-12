module Toshokan
  module SearchParametersHelpers
    def add_access_filter solr_parameters = {}, user_parameters = {}
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "access_ss:#{Rails.application.config.search[:dtu]}" if can? :search, :dtu
      solr_parameters[:fq] << "access_ss:#{Rails.application.config.search[:pub]}" if can? :search, :public
      solr_parameters
    end

    def add_inclusive_access_filter solr_parameters = {}, user_parameters = {}
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "access_ss:(#{Rails.application.config.search[:dtu]} OR #{Rails.application.config.search[:pub]})"
      solr_parameters
    end
  end


end