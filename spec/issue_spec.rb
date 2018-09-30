require "spec_helper"
require_relative('../lib/issue')

RSpec.describe Issue do

  let!(:issue) {Issue.new(id: 1, number: 1, title: 'test', body: 'testing', state: 'open', url: 'http://localhost:3000')}
  
  describe "#new" do
    it "takes arguments and sets to Issues object." do 
      expect{
        Issue.new(id:     1, 
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