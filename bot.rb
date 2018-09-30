require 'telegram_bot'
require 'logger'


require_relative 'lib/github'
require_relative 'lib/trello'

github_username   = 'hackvan'
github_repository = 'telegram-bot'
telegram_token    = '639592041:AAGemO4NNgl42xgXYKXplwUz5qnqqToUNVg'

logger = Logger.new(STDOUT, Logger::DEBUG)
bot = TelegramBot.new(token: telegram_token, logger: logger)
logger.debug "starting telegram bot"

def get_answer_from_user(bot, logger)
  answer = bot.get_updates(fail_silently: true).last
  logger.info "@#{answer.from.username}: #{answer.text}"
  result = answer.text
  answer.reply do |reply|
    reply.text = "la configuracion ha sido actualizada a: #{result}"
    reply.send_with(bot)
  end
  result
end

bot.get_updates(fail_silently: true) do |message|
  logger.info "@#{message.from.username}: #{message.text}"
  require_answer = false
  command = message.get_command_for(bot)

  message.reply do |reply|
    case command
    when /start/i
      reply.text = "Hola #{message.from.first_name}, para iniciar puedes utilizar el comando /setup."
    when /setup/i
      reply.text = "Bienvenido al asistente de configuración del bot:"
    when /setgithubuser/i
      reply.text = "Por favor indica el @usuario de github:"
      require_answer = true
    when /getgithubuser/i
      reply.text = "La configuración del @usuario de github es: #{github_username}"
    when /setgithubrepository/i
      reply.text = "Por favor indica el nombre del repositorio de github:"
    when /getgithubrepository/i
      reply.text = "La configuración del repositorio de github es: #{github_repository}"
    when /help/i
      reply.text = "Yo puedo ayudarte a consultar tus Issues del repositorio y a sincronizarlos con tu tablero de Trello.\n"
      reply.text << "Puedes controlarme enviandome los siguientes comandos:\n\n"
      reply.text << "/start - mensaje de bienvenida\n"
      reply.text << "/setup - asistente de configuración del bot\n"
      reply.text << "/setgithubuser - establece la configuración del usuario de github\n"
      reply.text << "/getgithubuser - obtiene la configuración del usuario de github\n"
      reply.text << "/setgithubrepository - establece la configuración del repositorio de github\n"
      reply.text << "/getgithubrepository - obtiene la configuración del repositorio de github\n"
      reply.text << "/issues - consultar el listado de Issues en el repositorio de Github\n"
      reply.text << "/trello - sincroniza los issues del repositorio en un tablero de Trello\n"
    when /issues/i
      if github_username.empty?
        reply.text = "Debe indicar el usuario de Github, puede hacerlo con /setgithubuser"
      elsif github_repository.empty?
        reply.text = "Debe indicar el repositorio de Github, puede hacerlo con /setgithubrepository"
      else
        issues  = GitHubWrapper::GitHubConnector.new(username: github_username, repository: github_repository)
        reply.text = "Incidentes registrados en: @#{issues.username}/#{issues.repository}:\n\n"
        issues.get_issues.each do |issue|
          reply.text << "  issue ##{issue.number}\n  #{issue.title}\n"
          reply.text << "  -----\n\n"
        end
      end
    when /trello/i
      if github_username.empty?
        reply.text = "Debe indicar el usuario de Github, puede hacerlo con /setgithubuser"
      elsif github_repository.empty?
        reply.text = "Debe indicar el repositorio de Github, puede hacerlo con /setgithubrepository"
      else
        trello = TrelloWrapper::TrelloConnector.new
        reply.text = "Sincronización de issues de GitHub a Trello\n\n"
        reply.text << "Estadisticas del proceso:\n"
        reply.text << "-" * 20 + "\n"
        reply.text << "Tableros Creados: #{trello.statistics[:boards_created]}\n"
        reply.text << "Listas Creadas:   #{trello.statistics[:lists_created]}\n"
        reply.text << "Tarjetas Creadas: #{trello.statistics[:cards_created]}"
      end
    else
      reply.text = "No tengo idea de lo que el comando #{command.inspect} significa."
    end
    puts "sending #{reply.text.inspect} to @#{message.from.username}"
    reply.send_with(bot)

    if require_answer
      github_username = get_answer_from_user(bot, logger)
    end
  end
end

