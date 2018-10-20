module Trello
  SCRUM_LISTS = ['Backlog', 'To Do', 'Done'].freeze

  class Board
    attr_accessor :id, :name, :desc, :closed, :lists
    
    def initialize(id:, name:, desc:, closed:)
      @id     = id
      @name   = name
      @desc   = desc
      @closed = closed
      @lists  = []
    end

    def self.find_by_name(name:)
      board = nil
      json_board = API::get_boards.detect do |board|
        board[:name] =~ /#{name}/
      end
      if json_board
        board = self.new(
          id:     json_board[:id],
          name:   json_board[:name],
          desc:   json_board[:desc],
          closed: json_board[:closed] 
        )
        board.get_trello_lists
      end
      board
    end

    def self.create(name:, desc:)
      board = self.find_by_name(name: name)
      unless board
        json_board = API::post_board(name: name, desc: desc)
        board = self.new(
          id:     json_board[:id],
          name:   json_board[:name],
          desc:   json_board[:desc],
          closed: json_board[:closed] 
        )
        board.close_default_lists
        board.create_scrum_lists
      end
      board
    end

    def open_lists
      @lists.select { |list| !list.closed }
    end

    def get_trello_lists
      self.lists = []
      API::get_lists(id_board: self.id).each do |list|
        self.lists << Trello::List.new(
          id:       list[:id],
          name:     list[:name],
          id_board: self.id
        )
      end
      self.open_lists
    end

    def create_scrum_lists
      self.get_trello_lists
      SCRUM_LISTS.reverse.each do |name, index|
        list = self.open_lists.detect { |list| list.name =~ /#{name}/i }
        self.lists << List.create(name: name, id_board: self.id) unless list
      end
      self.open_lists
    end

    def close_default_lists
      self.get_trello_lists.each do |list|
        unless SCRUM_LISTS.include?(list.name)
          list.close
        end
      end
      # self.lists.delete_if do |list|
      #   unless SCRUM_LISTS.include?(list.name)
      #     API::put_list(id_list: list.id, closed: true)
      #     true # Return true to remove from the @Lists Array.
      #   end
      # end
      self.open_lists
    end
  end

  class List
    attr_accessor :id, :name, :closed, :id_board, :cards

    def initialize(id:, name:, closed: false, id_board:)
      @id       = id
      @name     = name
      @closed   = closed
      @id_board = id_board
      @cards    = []
    end

    def self.create(name:, id_board:)
      json_list = API::post_list(id_board: id_board, name: name)
      List.new(
        id:       json_list[:id],
        name:     json_list[:name],
        id_board: json_list[:id_board]
      )
    end

    def close
      json_list = API::put_list(id_list: self.id, closed: true)
      self.closed = true if json_list
      self
    end

    def get_trello_cards
      @cards
    end
  end

  class Card
    attr_accessor :id, :name, :desc, :closed, :id_board, :id_list

    def initialize(id:, name:, desc: '', closed: false, id_board:, id_list:)
      @id       = id
      @name     = name
      @desc     = desc
      @closed   = closed
      @id_board = id_board
      @id_list  = id_list
    end
  end

  module API
    require 'dotenv/load'
    require 'httparty'
    require_relative 'version'
    API_TRELLO_KEY   = ENV['API_TRELLO_KEY']
    API_TRELLO_TOKEN = ENV['API_TRELLO_TOKEN']
    BOARD_DESC       = 'Handling issues from the repository'

    @@base_uri    = 'https://api.trello.com/1'
    @@board_name  = 'Telegram Bot'
    @@headers     = { 'User-Agent': "telegram-scrum-bot-#{TelegramBot::VERSION}" }
    @@trello_auth = {
      "key"   => API_TRELLO_KEY,
      "token" => API_TRELLO_TOKEN
    }

    class HTTPError < HTTParty::Error
    end
    
    def self.get_boards
      uri     = "#{@@base_uri}/members/me/boards"
      boards  = []
      
      response = HTTParty.get(
        uri,
        headers: @@headers,
        query:   @@trello_auth
      )
      if response.success?
        JSON.parse(response.body, symbolize_names: true).each do |board|
          boards << board
        end
      else
        raise HTTPError, response.parsed_response
      end
      boards
    end

    def self.post_board(name:, desc: BOARD_DESC)
      uri     = "#{@@base_uri}/boards"
      board   = nil
      options = { 
        "name" => name,
        "desc" => desc
      }
      options = @@trello_auth.merge(options)

      response = HTTParty.post(
        uri,
        headers: @@headers,
        query:   options
      )
      if response.success?
        board = JSON.parse(response.body, symbolize_names: true)
      else
        raise HTTPError, response.parsed_response
      end
      board
    end

    def self.get_lists(id_board:, filter: "open")
      uri     = "#{@@base_uri}/boards/#{id_board}/lists"
      lists   = []
      options = { "filter" => filter }
      options = @@trello_auth.merge(options)

      response = HTTParty.get(
        uri,
        headers: @@headers,
        query:   options
      )
      if response.success?
        JSON.parse(response.body, symbolize_names: true).each do |list|
          lists << list
        end
      else
        raise HTTPError, response.parsed_response
      end
      lists
    end

    def self.post_list(id_board:, name:)
      uri     = "#{@@base_uri}/board/#{id_board}/lists"
      list    = nil
      options = { "name" => name }
      options = @@trello_auth.merge(options)

      response = HTTParty.post(
        uri,
        headers: @@headers,
        query:   options
      )
      if response.success?
        list = JSON.parse(response.body, symbolize_names: true)
      else
        raise HTTPError, response.parsed_response
      end
      list
    end

    def self.put_list(id_list:, name: nil, closed: nil, id_board: nil)
      uri     = "#{@@base_uri}/lists/#{id_list}"
      list    = nil
      options = {}
      options["name"]    = name if name
      options["closed"]  = closed unless closed.nil?
      options["idBoard"] = id_board if id_board
      options = @@trello_auth.merge(options)

      response = HTTParty.put(
        uri,
        headers: @@headers,
        query:   options
      )
      if response.success?
        list = JSON.parse(response.body, symbolize_names: true)
      else
        raise HTTPError, response.parsed_response
      end
      list
    end

    def self.get_cards(id_list:, filter: "open")
      uri     = "#{@@base_uri}/lists/#{id_list}/cards"
      cards   = []
      options = { "filter" => filter }
      options = @@trello_auth.merge(options)

      response = HTTParty.get(
        uri,
        headers: @@headers,
        query:   options
      )
      if response.success?
        JSON.parse(response.body, symbolize_names: true).each do |card|
          cards << card
        end
      else
        raise HTTPError, response.parsed_response
      end
      cards
    end

    def self.post_card(id_list:, name:, desc: '', pos: 'bottom')
      uri     = "#{@@base_uri}/cards"
      card    = nil
      options = { 
        "idList" => id_list,
        "name"   => name,
        "desc"   => desc,
        "pos"    => pos
      }
      options = @@trello_auth.merge(options)

      response = HTTParty.post(
        uri,
        headers: @@headers,
        query:   options
      )
      if response.success?
        card = JSON.parse(response.body, symbolize_names: true)
      else
        raise HTTPError, response.parsed_response
      end
      card
    end

    def self.put_card(id_card:, name: nil, desc: nil, closed: nil, id_list: nil)
      uri     = "#{@@base_uri}/cards/#{id_card}"
      card    = nil
      options = {}
      options["name"]   = name if name
      options["desc"]   = desc if desc
      options["closed"] = closed unless closed.nil?
      options["idList"] = id_list if id_list
      options = @@trello_auth.merge(options)

      response = HTTParty.put(
        uri,
        headers: @@headers,
        query:   options
      )
      if response.success?
        card = JSON.parse(response.body, symbolize_names: true)
      else
        raise HTTPError, response.parsed_response
      end
      card
    end
  end
end


if __FILE__ == $0
  begin
    # puts Trello::API.get_boards
    # puts Trello::API.get_lists(id_board: "5bbeb6ee99b2a176c7a85e78", filter: 'open')
    # puts Trello::API.put_list(id_list: "5bc0fbdc8eb4855ed50fe3e1", name: 'Testing List 2')
    # puts Trello::API.put_list(id_list: "5bbeb6ee99b2a176c7a85e7b", closed: true)
    # puts Trello::API.put_list(id_list: "5bbeb6ee99b2a176c7a85e7a", closed: true)
    # puts Trello::API.put_list(id_list: "5bbeb6ee99b2a176c7a85e79", closed: true)    
    # puts Trello::API.post_list(id_board: "5bbeb6ee99b2a176c7a85e78", name: "Testing List")
    # puts Trello::API.get_cards(id_list: "5bc0fbdc8eb4855ed50fe3e1", filter: 'open')
    # puts Trello::API.post_card(id_list: "5bc0fbdc8eb4855ed50fe3e1", name: "Testing 3")
    # puts Trello::API.put_card(id_card: "5bc15e55dc6b880ae886ae6e", name: "Testing 2.1")
    # puts Trello::API.put_card(id_card: "5bc0ff79fbd3cd3ef9fd8d56", name: "Tarjeta 1.2", closed: true)
    
    # puts Trello::Board.find_by_name(name: "Telegram Bot").close_default_lists.inspect
    puts Trello::Board.create(name: "Telegram Bot 2", desc: "Testing Description").inspect

  rescue Trello::API::HTTPError => error
    puts "#{Trello::API::HTTPError} - #{error.message}"
    exit 1
  end
end