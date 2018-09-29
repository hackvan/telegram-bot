require 'telegram_bot'
require_relative 'github'

telegram_token = '639592041:AAGemO4NNgl42xgXYKXplwUz5qnqqToUNVg'

bot = TelegramBot.new(token: telegram_token)

bot.get_updates(fail_silently: true) do |message|
  puts "@#{message.from.username}: #{message.text}"
  command = message.get_command_for(bot)

  message.reply do |reply|
    case command
    when /start/i
      reply.text = "Hola #{message.from.first_name}, para iniciar puedes utilizar el comando /setup."
    when /setup/i
      reply.text = "Por favor indica el @usuario de github:"
    when /issues/i
      issues  = GitHubWrapper::GitHubConnector.new
      reply.text = "Incidentes para: @#{issues.username}/#{issues.repository}:\n\n"
      issues.get_issues.each do |issue|
        reply.text << "  id: #{issue.number}\n  #{issue.body}\n"
        reply.text << "  -----\n\n"
      end
    else
      reply.text = "No tengo idea de lo que el comando #{command.inspect} significa."
    end
    puts "sending #{reply.text.inspect} to @#{message.from.username}"
    reply.send_with(bot)
  end
end