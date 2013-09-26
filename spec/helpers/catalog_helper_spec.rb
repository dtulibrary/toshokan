require "spec_helper"

describe CatalogHelper do

  describe '#normalize_year' do
    it 'does not modify three- or four-digit years' do
       helper.normalize_year(2006, 2, 2012).should eq 2006
    end

    it 'does not modify three- or four-digit years' do
      helper.normalize_year(569, 2, 2012).should eq 569
    end

    it 'should convert one- or two-digit years to four-digit' do
      helper.normalize_year(12, 2, 2012).should eq 2012
      helper.normalize_year(20, 2, 2012).should eq 1920
    end

    it 'should convert one- or two-digit years correctly when near end of century' do
      helper.normalize_year(12, 2, 2099).should eq 2012
      helper.normalize_year(01, 2, 2099).should eq 2101
      helper.normalize_year(01, 2, 2099).should eq 2101
    end
  end


  describe '#normalize_range' do
    it 'does not modify a valid range' do
      range = {'begin' => '2006', 'end' => '2012'}
      assert(range == normalize_year_range(range))
    end

    it 'does not modify open ranges' do
      range = {'begin' => '2006', 'end' => ''}
      helper.normalize_year_range(range).should eq range

      range = {'begin' => '', 'end' => '2012'}
      helper.normalize_year_range(range).should eq range

      range = {'begin' => '', 'end' => ''}
      helper.normalize_year_range(range).should eq range
    end

    it 'should convert non-integer arguments into open ends' do
      range = {'begin' => 'a', 'end' => '2012'}
      helper.normalize_year_range(range).should eq({'begin' => '', 'end' => '2012'})
    end

    it 'should convert one/two digit years to four-digit' do
      range = {'begin' => '06', 'end' => '12'}
      helper.normalize_year_range(range).should eq({'begin' => '2006', 'end' => '2012'})
    end

    it 'should push end to begin if delta is negative' do
      range = {'begin' => '2012', 'end' => '2006'}
      helper.normalize_year_range(range).should eq({'begin' => '2012', 'end' => '2012'})
    end
  end
end
