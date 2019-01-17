require 'net/http'
require 'nokogiri'

class OlxSearchCrawler
  def params
    {
      'search[region_id]' => 9,
      'search[city_id]' => 62,
      # 'search[district_id]' => 89,
      'search[dist]' => 0,
      'search[category_id]' => 1147,
      # 'search[filter_float_price:to]' => 15000,
    }
  end

  def search(query)
    appartments = []

    uri = URI('https://www.olx.ua/ajax/search/list/')
    response = Net::HTTP.post_form(uri, params.merge('q' => query))

    doc = Nokogiri::HTML(response.body)

    if doc.css('.emptynew').empty?
      doc.css('#offers_table .offer').each do |offer|
        appartmentData = {}

        offer.css('.title-cell .detailsLink').each do |title|
          appartmentData[:title] = title.content.strip
          appartmentData[:url] = title.attribute('href').content
        end

        offer.css('.bottom-cell small:nth-child(2) > span').each do |date|
          appartmentData[:date] = date.content.strip
        end

        offer.css('.thumb img').each do |image|
          appartmentData[:image] = image.attribute('src').content
        end

        offer.css('.price').each do |price|
          appartmentData[:price] = price.content.strip
        end

        next if appartmentData.empty?

        appartments << appartmentData
      end
    end

    appartments
  end

  def self.formatAppartmentData(data)
    [
      "[#{data[:title]}](#{data[:url]})",
      "*#{data[:price]}*",
      "#{data[:date]}",
    ].join("\n")
  end
end
