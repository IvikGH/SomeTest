require "./exchanger.rb"
require 'spec_helper'

describe RatesDbAdapter do

  it '.rates return rates table dataset' do
    expect(RatesDbAdapter.rates).to be_a Sequel::Postgres::Dataset
  end

  it 'Rates table raws are uniq' do
    expect(RatesDbAdapter.rates.where(date: '2017-04-07').count).to eq 1
  end

end
