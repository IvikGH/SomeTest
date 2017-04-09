require 'rubygems'
require 'mechanize'
require 'byebug'
require 'sequel'
require 'csv'

class RatesDbAdapter

  @db = Sequel.postgres('exchanger', user: 'postgres',
                                     password: 'D2c47812',
                                     host: 'localhost')
  def self.connection
    @db
  end

  def self.rates
    @db[:rates]
  end
end

class RatesWebLoader

  DOWNLOAD_PAGE = 'https://sdw.ecb.europa.eu/quickview.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A'
  FILE_LINK_TEXT = 'CSV - Character Separated'
  FILE_PATH = 'currency_rates.csv'


  @agent = Mechanize.new
  @rates = RatesDbAdapter.rates

  def self.update_data
    load_rates_to_database
  end

  private

  def self.load_rates_to_database
    File.delete(FILE_PATH)

    load_rates_file

    p 'load data from CSV file to database'
    CSV.foreach("currency_rates.csv") do |raw|
      begin
        @rates.insert(date: raw[0], rate: raw_value(raw[1])) if raw_valid?(raw)
      rescue Sequel::UniqueConstraintViolation
        next
      end
    end
    p 'all data loaded to database'
  end

  def self.load_rates_file
    p 'loading rates from WWW'
    page = @agent.get(DOWNLOAD_PAGE)
    page = @agent.page.link_with(:text => 'Data Download').click
    page.links.each do |link|
      @agent.get(link.href)
           .save('currency_rates.csv') if (/#{ FILE_LINK_TEXT }/ =~ link.text)
    end
    p 'file loaded'
  end

  def self.raw_value(value)
    return 0 if value == '-'
    value
  end

  def self.raw_valid?(raw)
    /^\d{4}(-\d{2}){2}/ =~ raw[0]
  end
end

class Exchanger
  @rates = RatesDbAdapter.rates

  def self.exchange(amount, *dates)
    dates.flatten! if dates.first.is_a?(Array)
    dates.map! do |date|
      begin
        (amount * @rates.first(date: date)[:rate].to_f).round(4)
      rescue NoMethodError
        next
      end
    end
    dates.length > 1 ? dates : dates.first
  end

end

# Exchanger.exchange(100, '2017-04-07')
# Exchanger.exchange(false, 100, ['2017-04-07', '2017-04-02', '2017-02-07', '2017-04-07'])
