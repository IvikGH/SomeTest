require "./exchanger.rb"
require 'spec_helper'

describe RatesWebLoader do

  FILE_PATH = 'currency_rates.csv'

  it '.load_rates_file download file wrom site' do
    File.delete(FILE_PATH) if FileTest.exist?(FILE_PATH)
    RatesWebLoader.load_rates_file

    expect(FileTest.exist?(FILE_PATH)).to be_truthy
  end

  it '.load_rates_file download CSV file' do

    unless FileTest.exist?(FILE_PATH)
      RatesWebLoader.load_rates_file
    end

    expect(File.extname(FILE_PATH)).to eq '.csv'
  end

  it '.load_rates_to_database populate database Rates table' do
    p "elements amount #{RatesDbAdapter.rates.count}"
    RatesDbAdapter.connection.run('TRUNCATE TABLE rates;')

    p "elements amount #{RatesDbAdapter.rates.count}"
    zero_elements = RatesDbAdapter.rates.count
    RatesWebLoader.load_rates_to_database
    p "elements amount #{RatesDbAdapter.rates.count}"

    expect(RatesDbAdapter.rates.count > zero_elements).to be_truthy
  end

  it '.raw_value return value if value is not "-"' do
    expect(RatesWebLoader.send(:raw_value, '1.2345')).to be_truthy
  end

  it '.raw_value return 0 if value is "-"' do
    expect(RatesWebLoader.send(:raw_value, '-')).to eq 0
  end

  it 'raw_valid? return true if date has YYYY-MM-DD format' do
    expect(RatesWebLoader.send(:raw_valid?, ['2017-04-02', '1.2345'])).to be_truthy
  end

  it 'raw_valid? return false if date has YYYY-MM-DD format or is something else' do
    expect(RatesWebLoader.send(:raw_valid?, ['xxxx', '1.2345'])).to be_falsey
    expect(RatesWebLoader.send(:raw_valid?, ['1234', '1.2345'])).to be_falsey
  end
end
