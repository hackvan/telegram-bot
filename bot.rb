require 'telegram_bot'

token = '639592041:AAGemO4NNgl42xgXYKXplwUz5qnqqToUNVg'

bot = TelegramBot.new(token: token)

bot.get_updates(fail_silently: true) do |message|
  puts "@#{message.from.username}: #{message.text}"
  command = message.get_command_for(bot)

  message.reply do |reply|
    case command
    when /start/i
      reply.text = "Todo lo que puedo hacer es decir Hola. Prueba el comando /greet"
    when /greet/i
      reply.text = "Hola, #{message.from.first_name}."
    else
      reply.text = "No tengo idea de lo que el comando #{command.inspect} significa."
    end
    puts "sending #{reply.text.inspect} to @#{message.from.username}"
    reply.send_with(bot)
  end
end