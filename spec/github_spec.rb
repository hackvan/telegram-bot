require "spec_helper"
require_relative('../lib/github')

RSpec.describe GitHubConnector do

  let!(:github) {
    GitHubConnector.new(username:   'dummy', 
                        repository: 'dummy')
  }

  describe "#new" do
    it "have named parameters for new objects" do
      expect{ 
        GitHubConnector.new(username:   'dummy', 
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