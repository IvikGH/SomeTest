require './exchanger.rb'
require 'spec_helper'

describe RatesWebLoader do
  let(:redis) { Redis.new(db: 'exchanger') }

  it '.update_data populate database Rates table with updates' do
    redis.flushdb
    today_key = Time.local(2017, 4, 20).strftime('%Y-%m-%d')
    today_rate_clear = redis.get(today_key)
    RatesWebLoader.update_data
    today_rate_updated = redis.get(today_key)
    expect(today_rate_clear.nil?).to be_truthy
    expect(today_rate_updated.nil?).to be_falsey
  end

  it '.raw_value return value if value is not "-"' do
    expect(RatesWebLoader.send(:raw_value, '1.2345')).to be_truthy
  end

  it '.raw_value return 0 if value is "-"' do
    expect(RatesWebLoader.send(:raw_value, '-')).to eq 0
  end

  it 'raw_valid? return true if date has YYYY-MM-DD format' do
    expect(RatesWebLoader.send(:raw_valid?,
                               ['2017-04-02', '1.2345'])).to be_truthy
  end

  it 'raw_valid? return false if data isn"t YYYY-MM-DD format date' do
    expect(RatesWebLoader.send(:raw_valid?, ['xxxx', '1.2345'])).to be_falsey
    expect(RatesWebLoader.send(:raw_valid?, ['1234', '1.2345'])).to be_falsey
  end

  describe '.need_to_update?' do
    it 'return true if "Exchanger" Redis DB hasn"t today value' do
      redis.flushdb
      expect(RatesWebLoader.send(:need_to_update?)).to be_truthy
    end

    it 'return false if "Exchanger" Redis DB has today value' do
      RatesWebLoader.update_data
      expect(RatesWebLoader.send(:need_to_update?,
                                 Time.local(2017, 4, 20))).to be_falsey
    end
  end
end
