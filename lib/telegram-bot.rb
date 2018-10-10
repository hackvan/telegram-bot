require_relative 'telegram-bot/bot'

module TelegramBot
end

require 'dotenv/load'
API_TELEGRAM_TOKEN = ENV['API_TELEGRAM_TOKEN']
API_TRELLO_KEY     = ENV['API_TRELLO_KEY']
API_TRELLO_TOKEN   = ENV['API_TRELLO_TOKEN']

if API_TELEGRAM_TOKEN
  TelegramBot::TelegramScrumBot.set_token(API_TELEGRAM_TOKEN)
  if API_TRELLO_KEY && API_TRELLO_TOKEN
    TelegramBot::set_trello_tokens(API_TRELLO_KEY, API_TRELLO_TOKEN)
    bot = TelegramBot::TelegramScrumBot.new(username: 'hackvan', repository: 'telegram-bot')
    bot.run
  else
    puts "API_TRELLO_KEY and/or API_TRELLO_TOKEN is not defined."
    exit 1
  end
else
  puts "API_TELEGRAM_TOKEN is not defined."
  exit 1
end