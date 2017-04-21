require './exchanger.rb'
require 'spec_helper'

describe RatesDbAdapter do
  it '.connection return Redis class instance object' do
    expect(RatesDbAdapter.connection).to be_a Redis
  end
end
