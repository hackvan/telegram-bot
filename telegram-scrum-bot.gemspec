lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "telegram-bot/version"

Gem::Specification.new do |spec|
  spec.name        = 'telegram-scrum-bot'
  spec.date        = TelegramBot::RELEASE_DATE
  spec.version     = TelegramBot::VERSION
  spec.authors     = ["Diego Camacho"]
  spec.email       = 'hackvan@gmail.com'

  spec.summary     = "A custom bot with Github and Trello connection"
  spec.description = "A utility bot that permit communicate with Github and Trello API."
  spec.homepage    = "https://github.com/hackvan/telegram-bot"
  spec.license     = "MIT"

  spec.files       = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "config"]

  spec.add_dependency "telegram_bot", "~> 0.0.8"
  spec.add_dependency "github_api", "~> 0.18.2"
  spec.add_dependency "ruby-trello", "~> 2.1"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency 'rspec', '~> 3.8'
end