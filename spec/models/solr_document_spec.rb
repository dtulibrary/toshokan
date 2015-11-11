# -*- encoding : utf-8 -*-
require 'rails_helper'

describe SolrDocument do
  let(:solr_response) { { 'highlighting' => highlighting_values } }
  let(:document) { SolrDocument.new({ id: '2059', cluster_id_ss: '598732111' }, solr_response ) }
  let(:highlighting_values) { {"2059"=>{"abstract_ts"=>["highlight value 1"]}} }

  describe 'has_highlight_field?' do
    it 'is able to find highlights corresponding to doc["id"]' do
      expect(document.has_highlight_field?('abstract_ts')).to eq true
    end
  end
  describe 'highlight_field' do
    it 'is able to find highlights corresponding to doc["id"]' do
      expect(document.highlight_field('abstract_ts')).to eq  ["highlight value 1"]
    end
  end
end