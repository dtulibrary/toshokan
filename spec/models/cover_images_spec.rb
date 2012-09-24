require 'spec_helper'

describe CoverImages do
  
  describe '.config' do
    it 'should return a configuration object' do
      CoverImages.config.should be_kind_of CoverImages::Configuration
    end
  end

  describe '.configure' do
    it 'should return a configuration object' do
      CoverImages.config.should be_kind_of CoverImages::Configuration
    end
  end

  describe '.url_for' do

    context 'when document has both issn_t and isbn_t fields' do
      it 'should return an url pointing to issn_t field' do
        document = { 'issn_t' => ['12345678'], 'isbn_t' => ['123456789abcd'] }
        CoverImages.url_for(document).should match /\/12345678\/native.png/
      end
    end

    context 'when document only has issn_t field' do
      it 'should return an url pointing to isbn_t field' do
        document = { 'issn_t' => ['12345678'] }
        CoverImages.url_for(document).should match /\/12345678\/native.png/
      end
    end

    context 'when document only has isbn_t field' do
      it 'should return an url pointing to isbn_t field' do
        document = { 'isbn_t' => ['123456789abcd'] }
        CoverImages.url_for(document).should match /\/123456789abcd\/native.png/
      end
    end

    context 'when document has neither issn_t nor isbn_t fields' do
      it 'should return an url pointing to fake id: XXXXXXXX' do
        CoverImages.url_for({}).should match /\/XXXXXXXX\/native.png/
      end
    end

  end

end

