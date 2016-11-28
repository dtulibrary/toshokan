require 'rails_helper'

describe Query do
  describe '.normalize' do
    it 'trims strings' do
      expect(Query.normalize('  query  ')).to eq 'query'
    end

    it 'replaces consecutive spaces with a single space' do
      expect(Query.normalize('field1   field2')).to eq 'field1 field2'
    end

    it 'does not replace consecutive non-spaces' do
      expect(Query.normalize('engineering')).to eq 'engineering'
    end
  end
end
