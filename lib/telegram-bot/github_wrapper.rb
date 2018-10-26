module TelegramBot
  module GitHubWrapper
    require 'httparty'
    class Repository
      include HTTParty
      require_relative 'version'

      base_uri("https://api.github.com/repos")
      @@headers = { 'User-Agent': "telegram-scrum-bot-#{TelegramBot::VERSION}" }
      
      attr_reader :username, :repository, :description, :private_repo, :issues

      def initialize(username:, repository:, description:, private_repo:)
        @username     = username
        @repository   = repository
        @description  = description
        @private_repo = private_repo
        @issues       = []
      end

      # Find a particular repository
      def self.find(username:, repository:)
        response = get("/#{username}/#{repository}", headers: @@headers)

        if response.success?
          self.new(
            username:     username,
            repository:   repository,
            description:  response.fetch("description", ""),
            private_repo: response.fetch("private", "")
          )
        else
          raise HTTParty::Error, response.parsed_response
        end
      end
      
      alias_method :private?, :private_repo
      
      # Returns the issues from a public repository
      def get_issues(state: 'all', sort: 'created', order_direction: 'asc')
        query = {
          "state"     => state,
          "sort"      => sort,
          "direction" => order_direction
        }

        response = self.class.get(
          "/#{@username}/#{@repository}/issues",
          headers: @@headers,
          query:   query
        )

        if response.success?
          JSON.parse(response.body).each do |issue|
            @issues << Issue.new(
              id:     issue.fetch('id', ''),
              number: issue.fetch('number', ''),
              title:  issue.fetch('title', ''),
              body:   issue.fetch('body', ''),
              state:  issue.fetch('state', ''),
              url:    issue.fetch('url', '')
            )
          end
        else
          raise HTTParty::Error, response.parsed_response
        end
        @issues
      end
    end

    class Issue
      attr_accessor :id, :number, :title, :body, :state, :url

      def initialize(id:, number:, title:, body:, state:, url:)
        self.id     = id
        self.number = number
        self.title  = title
        self.body   = body
        self.state  = state
        self.url    = url
      end

      def to_s
        "issue:  #{id}\n" +
        "number: #{number}\n" +
        "title:  #{title}\n" +
        "body:   #{body}\n" +
        "state:  #{state}\n" +
        "url:    #{url}\n"
      end
    end
  end
end

if __FILE__ == $0
  begin
    github = TelegramBot::GitHubWrapper::Repository.find(username: 'hackvan', repository: 'telegram-bot')
    puts "repository:   #{github.username}/#{github.repository}"
    puts "private repo: #{github.private?}"
    github.get_issues(state: "open").each do |issue|
      puts issue
      puts "-" * 80
    end
  rescue TypeError => e
    puts "User/Repository not found: #{e}"
  rescue StandardError => e
    puts "Error: #{e}"
  end
end