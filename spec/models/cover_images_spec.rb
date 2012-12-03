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

    context 'when document has both issn_s and isbn_s fields' do
      it 'should return an url pointing to issn_s field' do
        document = { 'issn_s' => ['12345678'], 'isbn_s' => ['123456789abcd'] }
        CoverImages.url_for(document).should match /\/12345678\/native.png/
      end
    end

    context 'when document only has issn_s field' do
      it 'should return an url pointing to isbn_s field' do
        document = { 'issn_s' => ['12345678'] }
        CoverImages.url_for(document).should match /\/12345678\/native.png/
      end
    end

    context 'when document only has isbn_s field' do
      it 'should return an url pointing to isbn_s field' do
        document = { 'isbn_s' => ['123456789abcd'] }
        CoverImages.url_for(document).should match /\/123456789abcd\/native.png/
      end
    end

    context 'when document has neither issn_s nor isbn_s fields' do
      it 'should return an url pointing to fake id: XXXXXXXX' do
        CoverImages.url_for({}).should match /\/XXXXXXXX\/native.png/
      end
    end

  end

end

