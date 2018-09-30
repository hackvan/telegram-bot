require 'github_api'
require_relative 'issue'

class GitHubConnector
  attr_reader :github_object, :username, :repository, :issues_list
  
  def initialize(username:, repository:)
    @github_object = Github.new
    @username      = username
    @repository    = repository
    @issues_list   = []
  end

  def get_issues(state: 'open', order_mode: 'asc')
    begin
      issues = @github_object.issues.list user:  @username, 
                                          repo:  @repository,
                                          state: state,
                                          sort:  'created', 
                                          direction: order_mode
      issues.each do |issue|
        @issues_list << Issue.new(id:     issue.id, 
                                  number: issue.number,
                                  title:  issue.title,
                                  body:   issue.body,
                                  state:  issue.state,
                                  url:    issue.url)
      end
    rescue Github::Error::NotFound => exception
      @issues_list << "Usuario/Repositorio no encontrado"
    end
    @issues_list
  end
end

if __FILE__ == $0
  github = GitHubConnector.new(username: 'hackvan', repository: 'telegram-bot')
  github.get_issues(state: 'all').each do |issue|
    puts issue
    puts "-" * 80
  end
end

