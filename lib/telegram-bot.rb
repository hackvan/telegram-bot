require_relative 'telegram-bot/bot'

module TelegramBot
end

config = YAML.load_file("./config/secrets.yml")
TelegramBot::TelegramScrumBot.set_token(config['telegram']['token'])
TelegramBot::set_trello_tokens(config['trello']['key'], config['trello']['token'])
bot = TelegramBot::TelegramScrumBot.new(username: 'hackvan', repository: 'telegram-bot')
bot.run