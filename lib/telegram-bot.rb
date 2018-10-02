require_relative 'telegram-bot/bot'

module TelegramBot
end

begin
  # Search the config/secrets.yml used for development enviroment:
  config = YAML.load_file("./config/secrets.yml")
  API_TELEGRAM_TOKEN = config['telegram']['token']
  API_TRELLO_KEY     = config['trello']['key']
  API_TRELLO_TOKEN   = config['trello']['token']
rescue Errno::ENOENT => exception
  # Search enviroment variables used for production enviroment:
  API_TELEGRAM_TOKEN = ENV['API_TELEGRAM_TOKEN']
  API_TRELLO_KEY     = ENV['API_TRELLO_KEY']
  API_TRELLO_TOKEN   = ENV['API_TRELLO_TOKEN']
end

if API_TELEGRAM_TOKEN
  TelegramBot::TelegramScrumBot.set_token(API_TELEGRAM_TOKEN)
  if API_TRELLO_KEY && API_TRELLO_TOKEN
    TelegramBot::set_trello_tokens(API_TRELLO_KEY, API_TRELLO_TOKEN)
    bot = TelegramBot::TelegramScrumBot.new(username: 'hackvan', repository: 'telegram-bot')
    bot.run
  else
    puts "API_TRELLO_KEY and API_TRELLO_TOKEN is not defined."
    exit 1
  end
else
  puts "API_TELEGRAM_TOKEN is not defined."
  exit 1
end