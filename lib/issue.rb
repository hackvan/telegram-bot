class Issue
  attr_accessor :id, :number, :title, :body, :state, :url

  def initialize(id:, number:, title:, body:, state:, url:)
    @id     = id
    @number = number
    @title  = title
    @body   = body
    @state  = state
    @url    = url
  end

  def to_s
    "issue:  #{@id}\n" +
    "number: #{@number}\n" +
    "title:  #{@title}\n" +
    "body:   #{@body}\n" +
    "state:  #{@state}\n" +
    "url:    #{@url}\n"
  end
end