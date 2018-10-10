require 'yaml'
require 'telegram_bot'
require 'logger'

require_relative 'github_wrapper'
require_relative 'trello'

module TelegramBot
  class TelegramScrumBot
    attr_accessor :github_username, :github_repository
    attr_reader   :logger, :bot, :user_message
    
    def self.set_token(token)
      @@telegram_token = token
    end

    def initialize(username:, repository:)
      @github_username   = username
      @github_repository = repository
      
      @logger = Logger.new(STDOUT, Logger::DEBUG)
      @bot    = TelegramBot.new(token: @@telegram_token, logger: @logger)
      @logger.debug "starting telegram bot"
    end

    def start
      message = "Hola #{@user_message.from.first_name}, para iniciar puedes utilizar el comando /setup."
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def setup
      message =  "Bienvenido al asistente de configuración del bot:\n\n"
      if @github_username.empty? || @github_repository.empty?
        if @github_username.empty?
          message << "Debe establecer el usuario de Github con /setgithubuser\n"
        end
        if @github_repository.empty?
          message << "Debe establecer el repositorio de Github con /setgithubrepository\n"
        end
      else
        message << "Todo se encuentra correctamente configurado, consulte /help para mas información\n"
      end
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def set_github_user
      message = "Por favor defina el usuario de github a utilizar:"
      {
        bot_message:     message,
        require_answer:  true,
        answer_variable: :github_username
      }
    end

    def get_github_user
      message = "La configuración establecida para el usuario de github es: #{@github_username}"
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def set_github_repository
      message = "Por favor defina el repositorio de github a utilizar:"
      {
        bot_message:     message,
        require_answer:  true,
        answer_variable: :github_repository
      }
    end

    def get_github_repository
      message = "La configuración establecida para el repositorio de github es: #{@github_repository}"
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def help
      message = "Hola soy Scrum Hackathon Bot, puedo ayudarte consultando Issues de un repositorio y a sincronizarlos con un tablero de Trello.\n\n"
      message << "Puedes controlarme con los siguientes comandos:\n\n"
      message << "/start - mensaje de bienvenida\n"
      message << "/setup - asistente de configuración del bot\n\n"
      message << "Configuraciones:\n"
      message << "/setgithubuser - establece la configuración del usuario de github\n"
      message << "/setgithubrepository - establece la configuración del repositorio de github\n\n"
      message << "/getgithubuser - obtiene la configuración del usuario de github\n"    
      message << "/getgithubrepository - obtiene la configuración del repositorio de github\n\n"
      message << "Comandos:\n"
      message << "/issues - consultar el listado de Issues en el repositorio de Github\n"
      message << "/trello - sincroniza los issues del repositorio en un tablero de Trello\n"
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def thanks
      message = "You welcome!"
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def get_github_issues
      if @github_username.empty?
        message = "Debe indicar el usuario de Github, puede hacerlo con /setgithubuser"
      elsif @github_repository.empty?
        message = "Debe indicar el repositorio de Github, puede hacerlo con /setgithubrepository"
      else
        begin
          github = GitHubWrapper::Repository.find(
                     username:   @github_username, 
                     repository: @github_repository
                   )

          message = "Incidentes registrados en: @#{github.username}/#{github.repository}:\n\n"
          github.get_issues(state: 'open').each do |issue|
            if issue.instance_of?(GitHubWrapper::Issue)
              message << "  issue ##{issue.number}\n  #{issue.title}\n"
              message << "  -----\n\n"
            else
              message << issue
            end
          end
        rescue TypeError => e
          message << "User/Repository not found: #{e}"
        rescue StandardError => e
          message << "Error: #{e}"
        end
      end
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def update_trello
      if github_username.empty?
        message = "Debe indicar el usuario de Github, puede hacerlo con /setgithubuser"
      elsif github_repository.empty?
        message = "Debe indicar el repositorio de Github, puede hacerlo con /setgithubrepository"
      else
        trello = TelegramBot::TrelloConnector.new(
                   username: @github_username, 
                   repository: @github_repository
                 )
        message = trello.show_statistics
      end
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def no_response_for(command)
      message = "No tengo idea de lo que el comando #{command.inspect} significa."
      {
        bot_message:     message,
        require_answer:  false,
        answer_variable: nil
      }
    end

    def get_answer_from_user
      answer = @bot.get_updates(fail_silently: true).last
      @logger.info "@#{answer.from.username}: #{answer.text}"
      result = answer.text
      answer.reply do |reply|
        reply.text = "la configuracion ha sido actualizada a: #{result}"
        reply.send_with(bot)
      end
      result
    end

    def run
      @bot.get_updates(fail_silently: true) do |user_message|
        @logger.info "@#{user_message.from.username}: #{user_message.text}"
        @user_message = user_message
        command       = user_message.get_command_for(@bot)
        
        user_message.reply do |reply|
          case command
          when /start/i
            result_hash = start
          when /setup/i
            result_hash = setup
          when /thanks/i
            result_hash = thanks
          when /setgithubuser/i
            result_hash = set_github_user
          when /getgithubuser/i
            result_hash = get_github_user
          when /setgithubrepository/i
            result_hash = set_github_repository
          when /getgithubrepository/i
            result_hash = get_github_repository
          when /help/i
            result_hash = help
          when /issues/i
            result_hash = get_github_issues
          when /trello/i
            result_hash = update_trello
          else
            result_hash = no_response_for(command)
          end

          reply.text = result_hash[:bot_message]
          puts "sending #{reply.text.inspect} to @#{user_message.from.username}"
          reply.send_with(@bot)

          if result_hash[:require_answer]
            response = get_answer_from_user
            instance_variable_set("@#{result_hash[:answer_variable]}", response)
          end
        end
      end
    end
  end
end

if __FILE__ == $0
  require 'dotenv/load'
  API_TELEGRAM_TOKEN = ENV['API_TELEGRAM_TOKEN']
  API_TRELLO_KEY     = ENV['API_TRELLO_KEY']
  API_TRELLO_TOKEN   = ENV['API_TRELLO_TOKEN']
  TelegramBot::TelegramScrumBot.set_token(API_TELEGRAM_TOKEN)
  TelegramBot::set_trello_tokens(API_TRELLO_KEY, API_TRELLO_TOKEN)
  bot = TelegramBot::TelegramScrumBot.new(username: 'hackvan', repository: 'telegram-bot')
  bot.run
end