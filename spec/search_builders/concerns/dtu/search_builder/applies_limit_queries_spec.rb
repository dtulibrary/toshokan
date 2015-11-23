require 'rails_helper'

describe Dtu::SearchBuilder::AppliesLimitQueries do
  let(:scope) { CatalogController.new }
  let(:search_builder) { Dtu::SearchBuilder.new(true, scope) }
  let(:solr_parameters) { {} }
  let(:user_params) { {'l' => {'subject' => 'a subject'}} }
  before do
    allow(search_builder).to receive(:blacklight_params).and_return(user_params)
  end

  it 'is included in processed_params' do
    allow(scope).to receive(:current_user).and_return(User.new)
    expect(search_builder.processed_parameters[:fq]).to include("keywords_ts:\"a subject\"")
  end

  describe 'add_limit_fq_to_solr' do
    subject { search_builder.add_limit_fq_to_solr(solr_parameters) }
    context 'toc' do
      let(:user_params) { {'l' => {'toc' => 'Toc Reference'} } }
      it 'sets up a toc query' do
        subject
        expect(solr_parameters[:fq]).to eq ["toc_key_s:\"Toc Reference\""]
      end
    end
    context 'author' do
      let(:user_params) { {'l' => {'author' => 'Authors Name'} } }
      it 'sets up an author query' do
        subject
        expect(solr_parameters[:fq]).to eq ["author_ts:\"Authors Name\" OR editor_ts:\"Authors Name\" OR supervisor_ts:\"Authors Name\""]
      end
    end
    context 'subject' do
      let(:user_params) { {'l' => {'subject' => 'a subject'}} }
      it 'sets up a subject query' do
        subject
        expect(solr_parameters[:fq]).to eq ["keywords_ts:\"a subject\""]
      end
    end
  end
end
