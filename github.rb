module GitHubWrapper
  GITHUB_USERNAME = 'hackvan'
  GITHUB_REPO     = 'telegram-bot'

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
    attr_reader :github_object, :username, :repository
    
    def initialize(username: GITHUB_USERNAME, repository: GITHUB_REPO)
      @github_object = Github.new
      @username      = username
      @repository    = repository
      @issues_list   = []
    end

    def get_issues(order_mode: 'asc')
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
      @issues_list
    end
  end
end

if __FILE__ == $0
  issues = GitHubWrapper::GitHubConnector.new.get_issues
  issues.each do |issue|
    puts issue
    puts "-" * 80
  end
end

