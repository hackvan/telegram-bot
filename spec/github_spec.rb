require "spec_helper"
require_relative('../lib/telegram-bot/github_wrapper')

RSpec.describe TelegramBot::GitHubWrapper::Repository do

  let!(:github) do
    TelegramBot::GitHubWrapper::Repository.new(username:    'dummy', 
                                               repository:  'dummy',
                                               description: 'dummy',
                                               private_repo: false)
  end

  describe "#new" do
    it "have named parameters for new objects" do
      expect{ 
        TelegramBot::GitHubWrapper::Repository.new(username:    'dummy', 
                                                   repository:  'dummy',
                                                   description: 'dummy',
                                                   private_repo: false)
      }.to_not raise_error
    end

    it "have public methods for instances variables." do 
      expect(github.username).to eq('dummy')
      expect(github.repository).to eq('dummy')
      expect(github.description).to eq('dummy')
      expect(github.private_repo).to be false
      expect(github.issues).to be_instance_of Array
    end
  end

end

RSpec.describe TelegramBot::GitHubWrapper::Issue do

  let!(:issue) {TelegramBot::GitHubWrapper::Issue.new(id: 1, number: 1, title: 'test', body: 'testing', state: 'open', url: 'http://localhost:3000')}
  
  describe "#new" do
    it "takes arguments and sets to Issues object." do 
      expect{
        TelegramBot::GitHubWrapper::Issue.new(id:     1, 
                                              number: 1, 
                                              title:  'test', 
                                              body:   'testing', 
                                              state:  'open',
                                              url:    'http://localhost:3000')
      }.to_not raise_error
    end

    it "have public methods for instances variables." do 
      expect(issue.id).to eq(1)
      expect(issue.number).to eq(1)
      expect(issue.title).to eq('test')
      expect(issue.body).to eq('testing')
      expect(issue.state).to eq('open')
      expect(issue.url).to eq('http://localhost:3000')
    end
  end
end