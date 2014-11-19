require 'rails_helper'

describe CoverImages do
  
  describe '.extract_identifier' do

    context 'when document has both issn_ss and isbn_ss fields' do
      it 'should return an url pointing to issn_ss field' do
        document = { 'issn_ss' => ['12345678'], 'isbn_ss' => ['123456789abcd'] }
        expect(CoverImages.extract_identifier(document) ).to eq '12345678'
      end
    end

    context 'when document only has issn_ss field' do
      it 'should return an url pointing to isbn_ss field' do
        document = { 'issn_ss' => ['12345678'] }
        expect( CoverImages.extract_identifier(document) ).to eq '12345678'
      end
    end

    context 'when document only has isbn_ss field' do
      it 'should return an url pointing to isbn_ss field' do
        document = { 'isbn_ss' => ['123456789a', '123456789abcd'] }
        expect(CoverImages.extract_identifier(document) ).to eq '123456789abcd'
      end
    end

    context 'when document has neither issn_ss nor isbn_ss fields' do
      it 'should return an url pointing to fake id: XXXXXXXX' do
        expect(CoverImages.extract_identifier({}) ).to eq 'XXXXXXXX'
      end
    end

  end

  describe '.url_for' do
    before do
      config = CoverImages.config
      config.url = '/cover_images_url'
      config.api_key = 'cover_images_api_key'
    end

    it 'returns a URL for the cover image' do
      expect(CoverImages.url_for('12345678') ).to eq '/cover_images_url/cover_images_api_key/12345678/native.png'
    end
  end

  describe '.get' do
    it 'calls HTTParty.get and returns response' do
      expect( HTTParty ).to receive(:get).with('/cover_images_url/cover_images_api_key/12345678/native.png').and_return 'IMAGE'
      expect( CoverImages.get('12345678') ).to eq 'IMAGE'
    end
  end

end

