require_relative 'olx_search_crawler'
require 'telegram/bot'
require 'logger'

BOT_TOKEN = '<TOKEN>'

logger = Logger.new('usage.log', 'daily')
logger.info("Starting...")

Telegram::Bot::Client.run(BOT_TOKEN) do |bot|
  bot.listen do |message|
    logger.info("New request from #{message.from.first_name} #{message.from.last_name} (#{message.from.username}) - #{message.text}")
    warn

    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    else
      crawler = OlxSearchCrawler.new
      results = crawler.search(message.text)

      results.each do |result|
        bot.api.send_message(chat_id: message.chat.id, text: OlxSearchCrawler.formatAppartmentData(result), parse_mode: 'Markdown')
      end
    end
  end
end
