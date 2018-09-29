module TrelloWrapper
  require 'trello'

  TRELLO_DEVELOPER_PUBLIC_KEY = "a92140e65b1dfcc1732ea92fd7d245f9"
  TRELLO_MEMBER_TOKEN = "55c9929d59625226047e258743a810d7dbba6db2b53a3678cc7454c13562a449"

  Trello.configure do |config|
    config.developer_public_key = TRELLO_DEVELOPER_PUBLIC_KEY
    config.member_token = TRELLO_MEMBER_TOKEN
  end

  BOARD_NAME = 'Telegram Bot'
  BOARD_DESC = 'Handling issues from the repository'
  LIST_NAMES = ['Backlog', 'To Do', 'Done']

  class TrelloConnector
    require_relative 'github'
    attr_reader :statistics
    
    def initialize
      @statistics = { boards_created: 0, lists_created: 0, cards_created: 0 }
      @board = find_or_create_board_by_name
      create_scrum_lists!(@board)
      close_default_lists!(@board)
      populate_issues_cards!
    end

    private
    def find_or_create_board_by_name(board_name: BOARD_NAME, board_desc: BOARD_DESC)
      board = Trello::Board.all.detect do |board|
        board.name =~ /#{board_name}/
      end

      unless board
        # Crear el tablero del repositorio:
        board = Trello::Board.create(name: board_name, description: board_desc)
        @statistics[:boards_created] += 1
      end
      board
    end

    def create_scrum_lists!(board)
      # Crear las listas para el Sprint(Scrum):
      LIST_NAMES.reverse.each do |name, index|
        list = board.lists.detect { |list| list.name =~ /#{name}/i }
        unless list 
          Trello::List.create(name: name, board_id: board.id, pos: index)
          @statistics[:lists_created] += 1
        end
      end
      self
    end

    def close_default_lists!(board)
      # Cerrar las listas que no se van a utilizar:
      # board.lists.each(&:close!)
      board.lists.each do |list|
        unless LIST_NAMES.include?(list.name)
          list.update_fields(closed: true)
          list.save
        end
      end
    end

    def populate_issues_cards!
      # Buscar la lista de Backlog:
      backlog_list = @board.lists.detect { |list| list.name =~ /backlog/i }
      if backlog_list
        # Obtener el listado de Issues del repositorio:
        GitHubWrapper::GitHubConnector.new.get_issues(order_mode: 'desc').each do |issue|
          # Buscar si la tarjeta de ese incidente ya fue agregada al backlog:
          card = backlog_list.cards.detect { |c| c.name =~ /^##{issue.number}\s[-]/i }
          unless card
            # Crear la tarjeta dentro de la lista de backlog:
            Trello::Card.create(name: "##{issue.number} - #{issue.title}", desc: issue.body, list_id: backlog_list.id)
            @statistics[:cards_created] += 1
          end
        end
      end
      self
    end
  end
end

if __FILE__ == $0
  trello = TrelloWrapper::TrelloConnector.new
  puts "Estadisticas del proceso:"
  puts "-" * 20
  puts "Tableros Creados: #{trello.statistics[:boards_created]}"
  puts "Listas Creadas:   #{trello.statistics[:lists_created]}"
  puts "Tarjetas Creadas: #{trello.statistics[:cards_created]}"
end