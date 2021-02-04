require "date"
Gem::Specification.new do |s|
  s.name = "rubygems-new"
  s.version = "0.0.1"
  s.date = Date.today.strftime("%Y-%m-%d")
  s.summary = "Rubygems plugin to generate new rubygems projects."
  s.description = "Rubygems plugin that generates new, empty, Rubygems projects, including a README, version control (e.g. git), and basic project structure."
  s.homepage = "https://github.com/KellenWatt/rubygems-new"
  s.authors = ["Kellen Watt"]

  s.files = [
    "lib/rubygems_plugin.rb",
    "lib/rubygems/commands/new_command.rb",
  ]

  s.license = "MIT"
end
