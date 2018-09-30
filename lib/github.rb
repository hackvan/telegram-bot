module GitHubWrapper
  require 'github_api'

  class Issues
    attr_accessor :id, :number, :title, :body, :url

    def initialize(id:, number:, title:, body:, url:)
      @id     = id
      @number = number
      @title  = title
      @body   = body
      @url    = url
    end

    def to_s
      "issue:  #{@id}\n" +
      "number: #{@number}\n" +
      "title:  #{@title}\n" +
      "body:   #{@body}\n" +
      "url:    #{@url}\n"
    end
  end

  class GitHubConnector
    attr_reader :github_object, :username, :repository, :issues_list
    
    def initialize(username:, repository:)
      @github_object = Github.new
      @username      = username
      @repository    = repository
      @issues_list   = []
    end

    def get_issues(order_mode: 'asc')
      begin
        issues = @github_object.issues.list user: @username, 
                                            repo: @repository, 
                                            sort: 'created', 
                                            direction: order_mode
        issues.each do |issue|
          @issues_list << Issues.new(id:     issue.id, 
                                    number: issue.number,
                                    title:  issue.title,
                                    body:   issue.body,
                                    url:    issue.url)
        end
      rescue Github::Error::NotFound => exception
        @issues_list << "Usuario/Repositorio no encontrado"
      end
      @issues_list
    end
  end
end

if __FILE__ == $0
  issues = GitHubWrapper::GitHubConnector.new(username: 'hackvan', repository: 'telegram-bot')
  issues.get_issues.each do |issue|
    puts issue
    puts "-" * 80
  end
end

