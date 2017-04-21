require 'rubygems'
require 'mechanize'
require 'byebug'
# require 'sequel'
require 'redis'
require 'csv'

# RatesDbAdapter provide connection to database
class RatesDbAdapter
  @db = Redis.new(db: 'exchanger')
  def self.connection
    @db
  end
end

# RatesWebLoader respond for load data from WWW to database
class RatesWebLoader
  DOWNLOAD_PAGE = 'https://sdw.ecb.europa.eu/quickview.do?SERIES_KEY=120.EXR.D.USD.EUR.SP00.A'.freeze
  FILE_LINK_TEXT = 'CSV - Character Separated'.freeze

  @agent = Mechanize.new
  @redis = RatesDbAdapter.connection

  class << self
    def update_data
      return unless need_to_update?
      rates = load_rates_updates
      load_rates_to_database(rates)
    end

    private

    def need_to_update?(date = Time.new)
      @redis.get(date.strftime('%Y-%m-%d')).nil?
    end

    def load_rates_updates
      p 'loading rates from WWW'
      page = @agent.get(DOWNLOAD_PAGE)
      page = @agent.page.link_with(text: 'Data Download').click
      csv_link = nil
      page.links.each do |link|
        csv_link = link.href if /#{ FILE_LINK_TEXT }/ =~ link.text
      end
      page_csv = @agent.get(csv_link)
      p 'data loaded'

      CSV.parse(page_csv.body)
    end

    def raw_value(value)
      return 0 if value == '-'
      value
    end

    def raw_valid?(raw)
      /^\d{4}(-\d{2}){2}/ =~ raw[0]
    end

    def load_rates_to_database(data)
      p 'loading updates to database'

      data.each do |raw|
        next unless raw_valid?(raw)
        break unless @redis.get(raw[0]).nil?

        @redis.set(raw[0], raw_value(raw[1]))
      end
      p 'all data loaded to database'
    end
  end
end

# Exchanger calculate data
class Exchanger
  RatesWebLoader.update_data
  @redis = RatesDbAdapter.connection

  def self.exchange(amount, *dates)
    dates.flatten! if dates.first.is_a?(Array)
    dates = @redis.mget(dates)
    dates.map! do |date|
      (amount * date.to_f).round(4)
    end
    dates.length > 1 ? dates : dates.first
  end
end

# p Exchanger.exchange(100, '1999-01-04')
# Exchanger.exchange(false, 100, ['2017-04-07', '2017-04-02', '2017-04-07'])
