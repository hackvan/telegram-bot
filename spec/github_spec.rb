require "spec_helper"
require_relative('../lib/github')

RSpec.describe GitHubWrapper::Issues do

  let!(:issue) {GitHubWrapper::Issues.new(id: 1, number: 1, title: 'test', body: 'testing', url: 'http://localhost:3000')}
  
  describe "#new" do
    it "takes arguments and sets to Issues object." do 
      expect{
        GitHubWrapper::Issues.new(id:     1, 
                                  number: 1, 
                                  title:  'test', 
                                  body:   'testing', 
                                  url:    'http://localhost:3000')
      }.to_not raise_error
    end

    it "have public methods for instances variables." do 
      expect(issue.id).to eq(1)
      expect(issue.number).to eq(1)
      expect(issue.title).to eq('test')
      expect(issue.body).to eq('testing')
      expect(issue.url).to eq('http://localhost:3000')
    end
  end
end

RSpec.describe GitHubWrapper::GitHubConnector do

  let!(:github) {
    GitHubWrapper::GitHubConnector.new(username:   'dummy', 
                                       repository: 'dummy')
  }

  describe "#new" do
    it "have named parameters for new objects" do
      expect{ 
        GitHubWrapper::GitHubConnector.new(username:   'dummy', 
                                           repository: 'dummy')
      }.to_not raise_error
    end

    it "have public methods for instances variables." do 
      expect(github.github_object).to_not be_nil
      expect(github.username).to eq('dummy')
      expect(github.repository).to eq('dummy')
      expect(github.issues_list).to be_instance_of Array
    end
  end

end