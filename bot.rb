require_relative 'olx_search_crawler'
require 'telegram/bot'

token = '631711838:AAEyXiiBq4d46BXwZtiJsDnL2WkvursaJaI'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    warn "New request from #{message.from.first_name} #{message.from.last_name} (#{message.from.username}) - #{message.text}"

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
