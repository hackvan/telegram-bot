module TrelloWrapper
  require 'trello'
  
  TRELLO_DEVELOPER_PUBLIC_KEY = "a92140e65b1dfcc1732ea92fd7d245f9"
  TRELLO_MEMBER_TOKEN = "55c9929d59625226047e258743a810d7dbba6db2b53a3678cc7454c13562a449"

  Trello.configure do |config|
    config.developer_public_key = TRELLO_DEVELOPER_PUBLIC_KEY
    config.member_token = TRELLO_MEMBER_TOKEN
  end

  BOARD_DESC = 'Handling issues from the repository'
  LIST_NAMES = ['Backlog', 'To Do', 'Done']

  class TrelloConnector
    attr_reader :github_username, :github_repository, :board_name, :statistics
    
    def initialize(username:, repository:)
      @statistics        = { boards_created: 0, lists_created: 0, cards_created: 0 }
      @github_username   = username
      @github_repository = repository
      @board_name        = @github_repository.split(/[-_]/i).map(&:capitalize).join(' ')

      @board = find_or_create_board_by_name
      create_scrum_lists!(@board)
      close_default_lists!(@board)
      # archive_existing_cards!
      populate_issues_cards!
    end

    def show_statistics
      "Estadisticas del proceso:\n" +
      "-" * 25 + "\n" +
      "Tableros Creados: #{@statistics[:boards_created]}\n" +
      "Listas Creadas:   #{@statistics[:lists_created]}\n" +
      "Tarjetas Creadas: #{@statistics[:cards_created]}\n"
    end

    private
    def find_or_create_board_by_name
      board = Trello::Board.all.detect do |board|
        board.name =~ /#{@board_name}/
      end

      unless board
        board = Trello::Board.create(name: @board_name, description: BOARD_DESC)
        @statistics[:boards_created] += 1
      end
      board
    end

    def find_backlog_list
      @board.lists.detect { |list| list.name =~ /backlog/i }
    end

    def create_scrum_lists!(board)
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
      board.lists.each do |list|
        unless LIST_NAMES.include?(list.name)
          list.update_fields(closed: true)
          list.save
        end
      end
    end

    def archive_existing_cards!
      find_backlog_list.archive_all_cards
    end

    def populate_issues_cards!
      backlog_list = find_backlog_list
      if backlog_list
        github = GitHubConnector.new(username: @github_username, repository: @github_repository)
        github.get_issues.each do |issue|
          if issue.instance_of?(Issue)
            card = backlog_list.cards.detect { |c| c.name =~ /^##{issue.number}\s[-]/i }

            unless card
              Trello::Card.create(name: "##{issue.number} - #{issue.title}", desc: issue.body, list_id: backlog_list.id)
              @statistics[:cards_created] += 1
            end
          end
        end
      end
      self
    end
  end
end

if __FILE__ == $0
  require_relative 'github'
  trello = TrelloWrapper::TrelloConnector.new(username: 'hackvan', repository: 'telegram-bot')
  puts trello.show_statistics
end