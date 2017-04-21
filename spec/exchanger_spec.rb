require './exchanger.rb'
require 'spec_helper'

describe Exchanger do
  it '.exchange method return "0.0" for unavailable rate' do
    expect(Exchanger.exchange(100, '2017-04-02')).to eq 0.0
  end

  context 'for singe date' do
    subject { Exchanger.exchange(100, '2017-04-07') }

    it '.exchange method return proper value for single date query' do
      expect(subject).to eq 106.3
    end

    it '.exchange method return Float type value for single date query' do
      expect(subject).to be_a Float
    end
  end

  context 'for multiple dates' do
    before :each do
      @result = Exchanger.exchange(100, ['2017-04-07', '2017-04-02',
                                         '2017-02-07', '2017-04-07'])
    end

    it '.exchange method return array of proper values for several dates' do
      exp_result = [106.3, 0.0, 106.75, 106.3]

      expect(@result).to eq exp_result
    end

    it '.exchange method return Array type value for single date query' do
      expect(@result).to be_a Array
    end
  end
end
